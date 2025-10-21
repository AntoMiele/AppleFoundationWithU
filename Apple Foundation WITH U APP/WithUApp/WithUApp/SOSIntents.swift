import AppIntents
import SwiftUI

// Intent principale: “frase segreta” → prepara SMS e apre l’app
struct SOSImmediateIntent: AppIntent {
    static var title: LocalizedStringResource = "Invia SOS"
    static var description = IntentDescription("Prepara un messaggio SOS con la tua posizione e apre l'app per confermare l'invio.")

    @Parameter(title: "Nota", default: "")
    var nota: String

    // Apriamo l’app quando eseguito da Siri/Comandi
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        SMSShareCoordinator.shared.queueLocalSMS(note: nota.isEmpty ? "SOS via Siri" : nota)
        return .result(value: "SOS pronto all'invio.")
    }
}

// (Opzionale) In futuro: avvia condivisione periodica ecc.
// struct StartShareIntent: AppIntent { ... }
// struct ExtendShareIntent: AppIntent { ... }

// App Shortcuts: frasi suggerite, inclusa la frase segreta salvata
struct SOSShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .red

    static var appShortcuts: [AppShortcut] {
        let secret = SOSSettings.shared.secretPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        // fallback se la frase è vuota
        let phrase = secret.isEmpty ? "SOS in \(.applicationName)" : "\(secret) in \(.applicationName)"

        return [
            AppShortcut(
                intent: SOSImmediateIntent(nota: ""),
                phrases: [
                    // suggerimenti (l'utente può personalizzare)
                    phrase,
                    "Invia SOS in \(.applicationName)",
                    "Condividi posizione in \(.applicationName)"
                ],
                shortTitle: "SOS",
                systemImageName: "exclamationmark.triangle.fill"
            )
        ]
    }
}
