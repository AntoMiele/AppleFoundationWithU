//  SOSDispatcher.swift
//  Map_iOS
//
//  Invio SOS automatico: legge contatti da UserDefaults, prende posizione 1-shot,
//  chiama il backend /sosOnce che invia l’SMS con link mappa.

import Foundation
import CoreLocation

struct SOSBackendConfig {
    let baseURL: URL    // URL del server backend per inviare la posizione
    let apiKey: String  // API key
    var sosOnceURL: URL { baseURL.appendingPathComponent("sosOnce") }
}

enum SOSError: Error {
    case noContacts
    case noLocation
    case networking(String)
}

final class SOSDispatcher: NSObject {
    static let shared = SOSDispatcher()

    // Configura qui il tuo backend
    var backend = SOSBackendConfig(
        baseURL: URL(string: "http://...")!, // ← Inserire URL del server
        apiKey: "API_KEY"                   // ← Stessa API di .env
    )

    private let locationManager = CLLocationManager()
    private var locationCallback: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

    // URLSession background per essere affidabili anche a schermo spento
    private lazy var bgSession: URLSession = {
        let cfg = URLSessionConfiguration.background(withIdentifier: "it.WithU.sos.bg")
        cfg.sessionSendsLaunchEvents = true
        cfg.allowsConstrainedNetworkAccess = true
        cfg.allowsExpensiveNetworkAccess = true
        return URLSession(configuration: cfg)
    }()

    // MARK: Public API

    /// Invia SOS immediato: 1) legge contatti; 2) prende posizione; 3) POST /sosOnce
    func sendSOSNow(note: String? = nil, completion: @escaping (Result<Void, SOSError>) -> Void) {
        let contacts = readContacts()
        guard !contacts.isEmpty else { completion(.failure(.noContacts)); return }

        requestAlwaysIfNeeded()

        getOneShotLocation { [weak self] result in
            switch result {
            case .failure:
                completion(.failure(.noLocation))
            case .success(let coord):
                self?.postSOS(contacts: contacts, coord: coord, note: note, completion: completion)
            }
        }
    }

    // MARK: Interni

    private func readContacts() -> [String] {
        if let data = UserDefaults.standard.data(forKey: "contacts"),
           let list = try? JSONDecoder().decode([Contatto].self, from: data) {
            return list.map(\.telefono).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
        return []
    }

    private func requestAlwaysIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
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

        var req = URLRequest(url: backend.sosOnceURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(backend.apiKey)", forHTTPHeaderField: "Authorization")

        // LINK UNIVERSALE (Google Maps) — breve e compatibile
        let latStr = String(format: "%.5f", coord.latitude)
        let lonStr = String(format: "%.5f", coord.longitude)
        let link = "https://maps.google.com/?q=\(latStr),\(lonStr)"

        let body: [String: Any] = [
            "contacts": contacts, // E.164 (+39…)
            "lat": coord.latitude,
            "lon": coord.longitude,
            "note": note ?? "",
            "link": link          // opzionale: se preferisci generarlo server-side, toglilo
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = bgSession.dataTask(with: req) { data, resp, err in
            if let err = err {
                DispatchQueue.main.async { completion(.failure(.networking(err.localizedDescription))) }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }
        task.resume()
    }
}

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
