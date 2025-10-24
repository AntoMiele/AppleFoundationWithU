import Foundation
import CoreLocation

// MARK: - Config
struct SOSBackendConfig {
    /// Metti qui l'URL del tuo backend, ad es: "https://xxx.ngrok.app/"
    /// Lascialo nil per DISABILITARE le chiamate HTTP (solo log).
    var baseURL: URL? = nil

    /// Se il server la richiede (es. "Bearer <token>"). Lascia "" se non serve.
    var apiKey: String = ""

    /// Path dell'endpoint (cambialo se usi /sos)
    var path: String = "sosOnce"

    var isConfigured: Bool { baseURL != nil }
    var endpoint: URL? { baseURL?.appendingPathComponent(path) }
}

enum SOSError: Error {
    case noContacts
    case noLocation
    case networking(String)
}

final class SOSDispatcher: NSObject {
    static let shared = SOSDispatcher()

    // MARK: - SERVER
    //INSERIRE QUI LA CONFIGURAZIONE DEL SERVER
    //E la KEY_API
    
    
    /// Quando avrai un server, imposta baseURL e (se serve) apiKey.
    var backend = SOSBackendConfig(
        baseURL: nil,             // ← lascia nil finché non hai un server
        apiKey: "",               // ← metti qui il token se richiesto (es. "abc123")
        path: "sosOnce"           // ← oppure "sos" se il tuo endpoint è /sos
    )

    // Location
    private let locationManager = CLLocationManager()
    private var locationCallback: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

    // Background/default session (in DEBUG uso .default per test più semplici)
    private lazy var session: URLSession = {
        #if DEBUG
        let cfg = URLSessionConfiguration.default
        return URLSession(configuration: cfg, delegate: self, delegateQueue: nil)
        #else
        // Se vuoi davvero background in produzione, puoi tornare a .background + delegate
        let cfg = URLSessionConfiguration.background(withIdentifier: "com.yourcompany.withu.sos.bg")
        cfg.waitsForConnectivity = true
        cfg.sessionSendsLaunchEvents = true
        return URLSession(configuration: cfg, delegate: self, delegateQueue: nil)
        #endif
    }()

    private var taskCompletions: [Int: (Result<Void, SOSError>) -> Void] = [:]
    private var taskData: [Int: Data] = [:]

    // MARK: - API pubblica
    func sendSOSNow(note: String? = nil, completion: @escaping (Result<Void, SOSError>) -> Void) {
        let contacts = readContacts()
        guard !contacts.isEmpty else {
            completion(.failure(.noContacts))
            return
        }

        requestWhenInUseIfNeeded()

        getOneShotLocation { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                completion(.failure(.noLocation))
            case .success(let coord):
                self.postSOS(contacts: contacts, coord: coord, note: note, completion: completion)
            }
        }
    }

    // MARK: - Interni
    private func readContacts() -> [String] {
        if let data = UserDefaults.standard.data(forKey: "contacts"),
           let list = try? JSONDecoder().decode([Contatto].self, from: data) {
            return list.map(\.telefono)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return []
    }

    private func requestWhenInUseIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    private func getOneShotLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        locationCallback = completion
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }

    private func postSOS(contacts: [String],
                         coord: CLLocationCoordinate2D,
                         note: String?,
                         completion: @escaping (Result<Void, SOSError>) -> Void) {

        // Costruisci il JSON da inviare
        let latStr = String(format: "%.5f", coord.latitude)
        let lonStr = String(format: "%.5f", coord.longitude)
        let link = "https://maps.google.com/?q=\(latStr),\(lonStr)"

        let body: [String: Any] = [
            "contacts": contacts,
            "lat": coord.latitude,
            "lon": coord.longitude,
            "note": note ?? "",
            "link": link
        ]

        // 🔎 DEBUG: stampa il JSON che invieresti
        if let pretty = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
           let prettyString = String(data: pretty, encoding: .utf8) {
            print("[SOSDispatcher] JSON to send:\n\(prettyString)")
        }

        // ❗️Se il server NON è configurato, fermati qui con successo "simulato"
        guard backend.isConfigured, let url = backend.endpoint else {
            print("[SOSDispatcher] Skipping network call (no server configured).")
            completion(.success(())) // consideralo "ok" per non mostrare errore in UI
            return
        }

        // Prepara la richiesta
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !backend.apiKey.isEmpty {
            req.setValue("Bearer \(backend.apiKey)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        // Avvia la task (delegate-based, anche con .default)
        let task = session.dataTask(with: req)
        taskCompletions[task.taskIdentifier] = completion
        taskData[task.taskIdentifier] = Data()
        task.resume()
    }
}

// MARK: - CLLocationManagerDelegate
extension SOSDispatcher: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let c = locations.last?.coordinate {
            locationCallback?(.success(c))
        } else {
            locationCallback?(.failure(SOSError.noLocation))
        }
        locationCallback = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCallback?(.failure(error))
        locationCallback = nil
    }
}

// MARK: - URLSession Delegate (comune per .default e .background)
extension SOSDispatcher: URLSessionDataDelegate, URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if var buf = taskData[dataTask.taskIdentifier] {
            buf.append(data)
            taskData[dataTask.taskIdentifier] = buf
        } else {
            taskData[dataTask.taskIdentifier] = data
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            taskData[task.taskIdentifier] = nil
            taskCompletions[task.taskIdentifier] = nil
        }
        guard let completion = taskCompletions[task.taskIdentifier] else { return }

        if let error = error {
            print("[SOSDispatcher] URLSession error:", error.localizedDescription)
            DispatchQueue.main.async { completion(.failure(.networking(error.localizedDescription))) }
            return
        }

        let status = (task.response as? HTTPURLResponse)?.statusCode ?? -1
        let bodyString = taskData[task.taskIdentifier].flatMap { String(data: $0, encoding: .utf8) } ?? ""
        print("[SOSDispatcher] HTTP status:", status)
        print("[SOSDispatcher] Response body:", bodyString)

        if (200...299).contains(status) {
            DispatchQueue.main.async { completion(.success(())) }
        } else {
            let msg = "HTTP \(status) \(bodyString)"
            DispatchQueue.main.async { completion(.failure(.networking(msg))) }
        }
    }
}
