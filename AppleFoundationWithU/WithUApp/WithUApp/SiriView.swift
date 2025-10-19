
//
import SwiftUI


struct SiriView: View {
    @StateObject private var settings = SOSSettings.shared
    @State private var showConfig = false
    @State private var pressed: Bool = false //stato per animazione bottone
    
    var body: some View {
            ZStack {
                // Sfondo principale
                Color.cobaltblue.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Titolo principale
                    Group {
                        Text("Record your")
                        Text("secret phrase")
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .light))
                    .onTapGesture { showConfig = true }
                    
                    Spacer()
                    
                    // Punto interrogativo
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 70, height: 80)
                        .foregroundStyle(.yellow)
                        .padding(.bottom, 30)
                    
                    // "Tell to Siri"
                    Text("Tell to Siri")
                        .foregroundStyle(.white)
                        .font(.system(size: 36, weight: .light))
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    //Bottone microfono con glass
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            pressed.toggle()
                        }
                        // azione da eseguire
                        showConfig = true
                    } label: {
                        Image(systemName: "mic.fill")
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
            }
        //in caso la frase non è configurata
        .onAppear {
            //Comparsa banner una volta
           if settings.secretPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async { showConfig = true}
            }
            
            
            /*comparsa del banner ogni volta che si apre l'app
            DispatchQueue.main.async {
                showConfig = true
            }*/
        
            
        }
        
        
        .sheet(isPresented: $showConfig) {
            
            //se l'utente va a tappare sul mic, allora fai uscire il banner
            NavigationView {SOSConfigView()}.presentationDetents([.medium, .large])
                                                     
                                                     
        }
    }
            
}
        
    


#Preview {
    SiriView()
}
