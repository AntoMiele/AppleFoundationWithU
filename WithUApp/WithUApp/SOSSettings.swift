//
//  SOSSettings.swift
//  WithU
//
//  Gestione della frase segreta e integrazione "Aggiungi a Siri"
//

import SwiftUI
import UIKit
internal import Combine
import Intents
import IntentsUI

// MARK: - Singleton per la frase segreta
final class SOSSettings: ObservableObject {
    static let shared = SOSSettings()
    @Published var secretPhrase: String {
        didSet { UserDefaults.standard.set(secretPhrase, forKey: Self.key) }
    }

    private static let key = "sos.secretPhrase"

    private init() {
        self.secretPhrase = UserDefaults.standard.string(forKey: Self.key) ?? ""
    }
}

// MARK: - View di configurazione
struct SOSConfigView: View {
    @StateObject private var settings = SOSSettings.shared
    @State private var draft = ""
    @State private var savedToast = false
    @State private var copiedToast = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Secret SOS phrase")) {
                TextField("Insert your SOS phrase here", text: $draft)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Set your SOS phrase").font(.subheadline).bold()
                    Text("""
                    1) “Hey Siri, \(draft.isEmpty ? (settings.secretPhrase.isEmpty ? "your SOS phrase" : settings.secretPhrase) : draft) on \(appName())”.
                    2) Optional: Create a **Command** with the same phrase to just say “Hey Siri, …”.
                    """)
                    .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.top, 4)

                HStack {
                    Button {
                        // Apri l'app Comandi come alternativa
                        if let url = URL(string: "shortcuts://") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Commands shortcut", systemImage: "bolt.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Secret phrase")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Undo") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveAndOfferSiri()
                }
                .bold()
            }
        }
        .onAppear { draft = settings.secretPhrase }
        .overlay(alignment: .bottom) {
            Group {
                if savedToast { ToastView(text: "Word saved") }
                else if copiedToast { ToastView(text: "") } // kept for compatibility, adjust text if needed
            }
            .padding(.bottom, 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: savedToast || copiedToast)
        }
    }

    // MARK: - Azioni

    private func saveAndOfferSiri() {
        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleaned.isEmpty {
            settings.secretPhrase = cleaned
            draft = settings.secretPhrase
            savedToast = true

            // Presenta la UI "Aggiungi a Siri" con la frase appena salvata
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                presentAddToSiri(phrase: cleaned)
            }

            // Chiudi lo sheet dopo una piccola attesa (la UI di sistema verrà mostrata sopra)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                dismiss()
            }
        } else {
            // Se è vuoto, azzera e non mostra la UI
            settings.secretPhrase = ""
            draft = ""
            savedToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                savedToast = false
            }
        }
    }

    // MARK: - Aggiungi a Siri

    /// Crea NSUserActivity con suggestedInvocationPhrase e mostra INUIAddVoiceShortcutViewController
 
    private func presentAddToSiri(phrase: String) {
        let activity = NSUserActivity(activityType: "it.withu.sos.sendSOS")
        activity.title = "Invia SOS"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.suggestedInvocationPhrase = phrase
        activity.userInfo = ["source": "siri-phrase"]
        activity.becomeCurrent()

        // Availability check e creazione shortcut
        if #available(iOS 12.0, *) {
            let shortcut = INShortcut(userActivity: activity)

            guard let top = topViewController() else {
                print("[SOSConfigView] Top view controller non trovato")
                // fallback: apri Comandi
                if let url = URL(string: "shortcuts://") { UIApplication.shared.open(url) }
                return
            }

            let addVC = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            let delegate = AddVoiceShortcutDelegate()
            addVC.delegate = delegate

            // Mantieni il delegate vivo finché il controller è visibile
            objc_setAssociatedObject(addVC, &AssociatedKeys.addVoiceDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            top.present(addVC, animated: true)
            return
        } else {
            // iOS < 12 — fallback apri Comandi
            print("[SOSConfigView] INShortcut non disponibile (iOS < 12). Apri Comandi come fallback.")
            if let url = URL(string: "shortcuts://") { UIApplication.shared.open(url) }
            return
        }
    }



    // Trova il top-most UIViewController per presentare UI UIKit da SwiftUI
    private func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }

    private func appName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "WithU"
    }
}

// MARK: - Delegate helper per INUIAddVoiceShortcutViewController

private class AddVoiceShortcutDelegate: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Associazione objc per mantenere vivo il delegate

private enum AssociatedKeys {
    // variabile mutabile il cui indirizzo useremo come chiave univoca
    static var addVoiceDelegateKey: Int = 0
}


// MARK: - UIViewController utility: trova il topMost VC
private extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController, let top = nav.topViewController {
            return top.topMostViewController()
        }
        if let tab = self as? UITabBarController, let sel = tab.selectedViewController {
            return sel.topMostViewController()
        }
        return self
    }
}

// MARK: - ToastView (piccolo badge informativo)
struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    SOSConfigView()
}
