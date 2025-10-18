
//
import SwiftUI


struct SiriView: View {
    @StateObject private var settings = SOSSettings.shared
    @State private var showConfig = false
    
    
    var body: some View {
        ZStack{
            Color.cobaltblue.ignoresSafeArea()
            VStack {
                VStack {
                    VStack{
                        
                        //Frase iniziale
                        Spacer()
                        Group {
                            Text("Record your")
                            Text("secret phrase")
                        }
                        .foregroundStyle(Color.white)
                        .font(.system(size: 40, weight: .light, design: .default))
                        .onTapGesture {showConfig = true
                        }
                        
                        
                        
                    }
                }
                //punto interrogativo
                ZStack{
                    Color.cobaltblue.ignoresSafeArea()
                    Image(systemName: "questionmark.circle") //immagine
                        .resizable()
                        .frame(width: 70, height: 80)
                        .foregroundStyle(.yellow)
                }
                
                //tell to siri
                Text("Tell to Siri")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 40, weight: .light, design: .default))
                //.font(weight: .bold))
                    .padding(.top, 60)
                
                Spacer()
                
                
                //microfono
                ZStack{
                    Color.cobaltblue.ignoresSafeArea()
                    Image(systemName: "mic.fill") //immagine
                        .resizable()
                        .frame(width: 60, height: 80)
                        .foregroundStyle(.white)
                }
                Spacer()
                
            }
        }
        //in caso la frase non è configurata
        .onAppear {
            if settings.secretPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async { showConfig = true}
            }
            
        }
        
        
        .sheet(isPresented: $showConfig) {
            NavigationView {SOSConfigView()}.presentationDetents([.medium, .large])
                                                     
                                                     
        }
    }
            
}
        
    


#Preview {
    SiriView()
    
}
