//
//  SOSIntents.swift
//  WithU
//
//  Creato per gestire gli App Intents di Siri e Comandi Rapidi
//

/*import AppIntents
import SwiftUI

// MARK: - Intent principale
// Siri o Comandi Rapidi → prepara un SMS SOS con la posizione
struct SOSImmediateIntent: AppIntent {
    static var title: LocalizedStringResource = "Invia SOS"
    static var description = IntentDescription("Prepara un messaggio SOS con la tua posizione e apre l'app per confermare l'invio.")

    @Parameter(title: "Nota", default: "")
    var nota: String

    // Apri l’app quando l’intent viene eseguito
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        // Chiama il coordinatore che prepara il messaggio
        SMSShareCoordinator.shared.queueLocalSMS(note: nota.isEmpty ? "SOS via Siri" : nota)
        return .result(value: "SOS pronto all'invio.")
    }
}

// MARK: - Shortcuts visibili in Comandi/Siri
struct SOSShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .red

    static var appShortcuts: [AppShortcut] {
        // Frase segreta salvata dall'utente (da SOSSettings.shared)
        let secret = SOSSettings.shared.secretPhrase.trimmingCharacters(in: .whitespacesAndNewlines)

        // Se non c’è frase, usa quella di default
        let phraseString = secret.isEmpty ? "SOS in WithU" : "\(secret) in WithU"

        // Converti in LocalizedStringResource (tipo richiesto da AppShortcuts)
        let phrase1 = LocalizedStringResource("phraseString")
        let phrase2 = LocalizedStringResource("Invia SOS in WithU")
        let phrase3 = LocalizedStringResource("Condividi posizione in WithU")

        return [
          AppShortcut(
 //               intent: SOSImmediateIntent(nota: ""),
//                phrases: [phrase1, phrase2, phrase3],
                shortTitle: "SOS",
                systemImageName: "exclamationmark.triangle.fill"
            )
        ]
    }
}
*/
