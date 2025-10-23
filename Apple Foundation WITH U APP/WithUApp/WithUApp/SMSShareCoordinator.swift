//
// SMSShareCoordinator.swift
// Map_iOS
//
// Coordina la preparazione di un SMS locale (recipients + body) e notifica la UI
// per presentare il composer in-app. Usalo insieme a `SMSComposerView.swift`
//
// - App Intents / Siri chiamano `SMSShareCoordinator.shared.queueLocalSMS(note:)`
// - La UI (root view) deve includere `.sosSharePresenter()` una volta per ascoltare
//

import SwiftUI
import CoreLocation
internal import Combine

// MARK: - Tipi

/// Payload pubblicato quando è pronto un SMS da mostrare
struct PendingSMS: Equatable {
    let recipients: [String]
    let body: String

    static func == (lhs: PendingSMS, rhs: PendingSMS) -> Bool {
        lhs.recipients == rhs.recipients && lhs.body == rhs.body
    }
}



// MARK: - Coordinator

final class SMSShareCoordinator: NSObject, ObservableObject {
    static let shared = SMSShareCoordinator()

    // Quando non nullo, la UI deve presentare il composer con questi dati
    @Published var pendingSMS: PendingSMS? = nil

    private let locationManager = CLLocationManager()
    private var locationCompletion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - API pubblica

    /// Coda la preparazione di un SMS con posizione + contatti e pubblica `pendingSMS`
    /// - Nota: questa funzione ottiene la posizione one-shot e poi pubblica; non mostra UI direttamente.
    @MainActor
    func queueLocalSMS(note: String? = nil, preferAppleMaps: Bool = false) {
        // 1) Carica contatti
        let recipients = loadContacts()
        guard !recipients.isEmpty else {
            print("[SMSShareCoordinator] No one contact found (key: 'contacts')")
            return
        }

        // 2) Richiedi permesso se necessario e prendi posizione one-shot
        requestWhenInUseIfNeeded()
        getOneShotLocation { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err):
                print("[SMSShareCoordinator] Position error: \(err.localizedDescription)")
            case .success(let coord):
                // 3) Costruisci link (Google Maps per massima compatibilità)
                let lat = String(format: "%.5f", coord.latitude)
                let lon = String(format: "%.5f", coord.longitude)
                let link = preferAppleMaps
                    ? "https://maps.apple.com/?ll=\(lat),\(lon)&q=SOS"
                    : "https://maps.google.com/?q=\(lat),\(lon)"

                var body = "[SOS] Posizione: \(link)"
                if let note, !note.isEmpty { body += "\n\(note)" }

                DispatchQueue.main.async {
                    self.pendingSMS = PendingSMS(recipients: recipients, body: body)
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadContacts() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: "contacts"),
              let list = try? JSONDecoder().decode([Contatto].self, from: data) else {
            return []
        }
        return list.map(\.telefono)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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
        locationCompletion = completion
        // ensure delegate already set in init
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension SMSShareCoordinator: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.last?.coordinate {
            locationCompletion?(.success(coord))
        } else {
            locationCompletion?(.failure(NSError(domain: "SMSShareCoordinator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Localization not available"])))
        }
        locationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(.failure(error))
        locationCompletion = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // puoi loggare o reagire qui se necessario
    }
}

// MARK: - ViewModifier che presenta il composer in risposta a pendingSMS

struct SOSSharePresenter: ViewModifier {
    @StateObject private var coord = SMSShareCoordinator.shared
    @State private var showSMS = false
    @State private var recipients: [String] = []
    @State private var bodyText: String = ""

    func body(content: Content) -> some View {
        content
            .onChange(of: coord.pendingSMS) { newValue in
                guard let payload = newValue else { return }
                recipients = payload.recipients
                bodyText = payload.body
                showSMS = true
                // resetta la coda in modo che successive chiamate vengano rilevate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    SMSShareCoordinator.shared.pendingSMS = nil
                }
            }
            .sheet(isPresented: $showSMS) {
                // Presenta il composer in-app. Assicura che SMSComposerView sia definito una sola volta nel progetto.
                SMSComposerView(recipients: recipients, body: bodyText) { _ in
                    showSMS = false
                }
            }
    }
}

extension View {
    /// Aggiungi questo modifier nella root view (es. MapView o ContentView) una sola volta:
    /// .sosSharePresenter()
    func sosSharePresenter() -> some View {
        self.modifier(SOSSharePresenter())
    }
}
