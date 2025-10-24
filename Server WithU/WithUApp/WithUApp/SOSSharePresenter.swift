import SwiftUI
import MessageUI

// Presenter che mostra il composer SMS o, se non disponibile, lo Share Sheet.
private struct SOSSharePresenterModifier: ViewModifier {
    @StateObject private var coord = SMSShareCoordinator.shared

    @State private var showSMS = false
    @State private var showShare = false
    @State private var recipients: [String] = []
    @State private var bodyText: String = ""

    func body(content: Content) -> some View {
        content
            .onChange(of: coord.pendingSMS) { newValue in
                guard let payload = newValue else { return }
                recipients = payload.recipients
                bodyText = payload.body

                if MFMessageComposeViewController.canSendText() {
                    showSMS = true
                } else {
                    showShare = true
                }

                // reset per trigger successivi
                DispatchQueue.main.async {
                    SMSShareCoordinator.shared.pendingSMS = nil
                }
            }
            // SMS composer
            .sheet(isPresented: $showSMS) {
                SMSComposerView(recipients: recipients, body: bodyText) { _ in
                    showSMS = false
                }
            }
            // Fallback Share Sheet (WhatsApp, Telegram, Mail…)
            .sheet(isPresented: $showShare) {
                ShareSheet(items: [bodyText])
            }
    }
}

// Estensione che rende disponibile .sosSharePresenter() su tutte le View
extension View {
    func sosSharePresenter() -> some View {
        self.modifier(SOSSharePresenterModifier())
    }
}
