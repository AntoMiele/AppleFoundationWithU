//classe per la gestione dei comandi di Siri e Intent

import SwiftUI
import UIKit
internal import Combine

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

struct SOSConfigView: View {
    @StateObject private var settings = SOSSettings.shared
    @State private var draft = ""
    @State private var savedToast = false
    @State private var copiedToast = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Frase segreta SOS")) {
                TextField("Inserisci la frase (es. Che bella la luna)", text: $draft)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(true)

                //pop up grafico per poter scrivere e salvare
                VStack(alignment: .leading, spacing: 6) {
                    Text("Imposta la tua frase segreta").font(.subheadline).bold()
                    Text("""
                    1) “Ehi Siri, \(draft.isEmpty ? (settings.secretPhrase.isEmpty ? "la tua frase" : settings.secretPhrase) : draft) su \(appName())”.
                    2) Facoltativo: crea un **Comando** con la stessa frase per dire solo “Ehi Siri, …”.
                    """)// il 2 se volessimo fare il tutorial
                    .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.top, 4)

                HStack {
                    Button("Salva") {
                        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !cleaned.isEmpty { settings.secretPhrase = cleaned }
                        draft = settings.secretPhrase
                        savedToast = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Copia") {
                        UIPasteboard.general.string = (draft.isEmpty ? settings.secretPhrase : draft)
                        copiedToast = true
                    }
                    .buttonStyle(.bordered)

                    Button {
                        if let url = URL(string: "shortcuts://") { UIApplication.shared.open(url) }
                    } label: {
                        Label("Apri Comandi", systemImage: "")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Frase SOS")
        .onAppear { draft = settings.secretPhrase }
        .overlay(alignment: .bottom) {
            Group {
                if savedToast { ToastView(text: "Frase salvata") }
                else if copiedToast { ToastView(text: "Frase copiata") }
            }
            .padding(.bottom, 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: savedToast || copiedToast)
        }
       
    }

    private func appName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "WithU"
    }
}

struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

/*#Preview {
    SOSConfigView()
}
*/
