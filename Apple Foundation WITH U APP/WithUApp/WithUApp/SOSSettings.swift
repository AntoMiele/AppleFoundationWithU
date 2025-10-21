//classe per la gestione dei comandi di Siri e Intent

import SwiftUI
import UIKit
internal import Combine     //dati reattivi come @Publisher


//definisco una classe per modificare un oggetto condiviso (singleton) --> Conserva e pubblica la frase segreta dell'utente
final class SOSSettings: ObservableObject {
    static let shared = SOSSettings()
    //Per notificare SwiftUI quando la frase viene notificata si usa @Published
    @Published var secretPhrase: String {
        //salvataggio della frase quando viene modificata
        didSet { UserDefaults.standard.set(secretPhrase, forKey: Self.key) }
    }
    
    //chiave per accedere alla frase dell'utente
    private static let key = "sos.secretPhrase"
    //recupera la frase
    private init() {
        self.secretPhrase = UserDefaults.standard.string(forKey: Self.key) ?? ""
    }
}

//Struttura per la configurazione della frase
    //L'utente al primo accesso scrive la frase e il programma salva quella frase in UserDefault
    //(memoria di tutti gli iPhone per le configurazioni utente, come tema scuro-chiaro, nome utente e comandi tramite una combinazione chiave valore)
struct SOSConfigView: View {
    @StateObject private var settings = SOSSettings.shared
    @State private var draft = ""
    @State private var savedToast = false
    @State private var copiedToast = false
    @Environment(\.dismiss) private var dismiss

    //Body della View --> con qualche piccola modifica è un copia-incolla nella SettingUI (sovrascrivere la frase che l'utente vuole modificare)
    
    var body: some View {
        Form {
            Section(header: Text("Secret SOS phrase")) {
                TextField("Insert your SOS phrase here", text: $draft)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(true)

                //pop up grafico per poter scrivere e salvare
                VStack(alignment: .leading, spacing: 6) {
                    Text("Set your SOS phrase").font(.subheadline).bold()
                    Text("""
                    1) “Hey Siri, \(draft.isEmpty ? (settings.secretPhrase.isEmpty ? "your SOS phrase" : settings.secretPhrase) : draft) on \(appName())”.
                    2) Optional: Create a **Command** with the same phrase to just say “Hey Siri, …”.
                    """)
                    // il 2 se volessimo fare il tutorial del comando
                    .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.top, 4)
                
                //Buttons
                HStack {
                    Button("Save") {
                        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !cleaned.isEmpty { settings.secretPhrase = cleaned }
                        draft = settings.secretPhrase
                        savedToast = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Copy") {
                        UIPasteboard.general.string = (draft.isEmpty ? settings.secretPhrase : draft)
                        copiedToast = true
                    }
                    .buttonStyle(.bordered)

                    Button {
                        if let url = URL(string: "shortcuts://") { UIApplication.shared.open(url) }
                    } label: {
                        Label("Commands shortcut", systemImage: "")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Secret phrase")
        .onAppear { draft = settings.secretPhrase }
        .overlay(alignment: .bottom) {
            //quando l'utente salva o copia esce un piccolo slide che specifica che la frase è stata salvata
            Group {
                if savedToast { ToastView(text: "Word saved") }
                else if copiedToast { ToastView(text: "") }
            }
            .padding(.bottom, 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: savedToast || copiedToast)
        }
       
    }
//Struttura la frase da dire a Siri del tipo "Ehi Siri, che bella la luna su WithU"
        //ATTENZIONE A MODIFICARLA, CREDO POSSA CREARE CONFLITTUALITA'
    private func appName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "WithU"
    }
}

//Struttura per il bunner
struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
