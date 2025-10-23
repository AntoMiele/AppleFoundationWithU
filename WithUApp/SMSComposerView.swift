//
//  SMSComposerView.swift
//  Map_iOS
//
//  Created by san-12 on 21/10/25.
//

//Contenitore per comporre l'SMS da mandare ai contatti (MessageUI)
import SwiftUI
import MessageUI


struct SMSComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String
    var onFinish: ((MessageComposeResult) -> Void)? = nil

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: SMSComposerView
        init(_ parent: SMSComposerView) { self.parent = parent }
        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                          didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                self.parent.onFinish?(result)
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.recipients = recipients
        vc.body = body
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}



