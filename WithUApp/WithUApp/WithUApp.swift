import SwiftUI

@main
struct WithUApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MapView()
                    .sosSharePresenter() // importantissimo: presenter per il composer SMS
            }
            // Intercetta gli URL custom (es. withu://sos?note=...)
            .onOpenURL { url in
                handleCustomURL(url)
            }
        }
    }

    /// Gestore semplice per gli URL del tipo withu://sos?note=...
    private func handleCustomURL(_ url: URL) {
        guard let scheme = url.scheme, scheme.lowercased() == "withu" else { return }

        // Esempi di URL possibili:
        // withu://sos
        // withu://sos?note=Emergenza%20al%20parco
        if url.host?.lowercased() == "sos" {
            // Estrai eventuale parametro "note"
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let note = comps?.queryItems?.first(where: { $0.name == "note" })?.value

            // Avvia il flusso locale per preparare l'SMS
            SMSShareCoordinator.shared.queueLocalSMS(note: note ?? "SOS via Shortcut")
        }
    }
}
