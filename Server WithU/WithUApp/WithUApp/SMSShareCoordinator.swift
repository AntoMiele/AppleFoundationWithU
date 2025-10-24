import SwiftUI
import CoreLocation
import MessageUI
import UIKit
internal import Combine

final class SMSShareCoordinator: NSObject, ObservableObject {
    static let shared = SMSShareCoordinator()

    @Published var pendingSMS: PendingSMS? = nil

    
    // MARK: - Payload queued for sending
    struct PendingSMS: Equatable {
        let recipients: [String] // numeri di telefono (stringhe, es. "+39...")
        let body: String         // testo del messaggio (con link posizione)

        static func == (lhs: PendingSMS, rhs: PendingSMS) -> Bool {
            lhs.recipients == rhs.recipients && lhs.body == rhs.body
        }
    }

    // Lazy: viene creato solo quando serve, con self già inizializzato
    private lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        return lm
    }()

    

    @MainActor
    func queueLocalSMS(note: String? = nil, preferAppleMaps: Bool = false) {
        let recipients = loadContacts()
        guard !recipients.isEmpty else {
            print("[SMSShareCoordinator] No contacts saved under key 'contacts'")
            return
        }

        requestWhenInUseIfNeeded()
        getOneShotLocation { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                print("[SMSShareCoordinator] Location error: \(err.localizedDescription)")
            case .success(let coord):
                let lat = String(format: "%.5f", coord.latitude)
                let lon = String(format: "%.5f", coord.longitude)
                let link = preferAppleMaps
                    ? "https://maps.apple.com/?ll=\(lat),\(lon)&q=SOS"
                    : "https://maps.google.com/?q=\(lat),\(lon)"

                var body = "[SOS] Position: \(link)"
                if let note, !note.isEmpty { body += "\n\(note)" }

                DispatchQueue.main.async {
                    self.pendingSMS = PendingSMS(recipients: recipients, body: body)
                }
            }
        }
    }

    private func loadContacts() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: "contacts"),
              let list = try? JSONDecoder().decode([Contatto].self, from: data) else { return [] }
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
        
        locationManager.requestLocation()
        // salva la closure come nel tuo codice originale
        self.locationCompletion = completion
    }

    private var locationCompletion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
}

extension SMSShareCoordinator: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.last?.coordinate {
            locationCompletion?(.success(coord))
        } else {
            locationCompletion?(.failure(NSError(
                domain: "SMSShareCoordinator",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Localization not available"]
            )))
        }
        locationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(.failure(error))
        locationCompletion = nil
    }
}
