import SwiftUI

struct SiriView: View {
    @StateObject private var settings = SOSSettings.shared
    @State private var showConfig = false
    @State private var pressed: Bool = false
    @State private var goToContact: Bool = false   // stato per navigazione

    var body: some View {
        NavigationStack {
            ZStack {
                // Sfondo principale
                Color.cobaltblue.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Titolo principale
                    Group {
                        Text("Write your")
                        Text("secret phrase")
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .light))
                    .onTapGesture { showConfig = true }
                    
                    Spacer()
                    
                    // Punto interrogativo
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.red)
                        .padding(.bottom, 30)
                    
                    // "Tell to Siri"
                    Text("Tell to Siri")
                        .foregroundStyle(.white)
                        .font(.system(size: 36, weight: .light))
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Bottone microfono con glass
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            pressed.toggle()
                        }
                        showConfig = true
                    } label: {
                        Image(systemName: "keyboard.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 90, height: 90)
                    }
                    .buttonStyle(.glass)
                    .clipShape(Circle())
                    .scaleEffect(pressed ? 0.9 : 1.0)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                    .padding(.bottom, 50)
                    
                    Spacer()
                }

                // Pulsante "Next" visibile solo se la frase segreta non è configurata
                if settings.secretPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: ContactsView(), isActive: $goToContact) {
                                Button {
                                    goToContact = true
                                } label: {
                                    Text("Next")
                                        .font(.system(size: 22, weight: .light))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(20)
                                        .shadow(color: .white.opacity(0.3), radius: 10)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 30)
                            .padding(.trailing, 30)
                        }
                    }
                }
            }
            // Se la frase non è configurata, mostra la config
            .onAppear {
                if settings.secretPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    DispatchQueue.main.async { showConfig = true }
                }
            }
            // Sheet di configurazione
            .sheet(isPresented: $showConfig) {
                NavigationView {
                    SOSConfigView()
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    SiriView()
}
