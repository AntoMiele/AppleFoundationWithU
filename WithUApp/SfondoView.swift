//
//  ContentView.swift
//  CreazioneView
//
//  Created by san-6 on 16/10/25.
//

// MARK: - MANCA IL LOGO E IL CARICAMENTO
/// Passa a Siri se è primo accesso, altrimenti a MapView

import SwiftUI

extension Color {
    init(hex: String) {
        //lettura dei caratteri e dichiarazione della variabile
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
         
        //rimozione di # dal codice del colore
        if hex.hasPrefix("#") {
           _ = scanner.scanCharacter()
        }
        
        //controllo del colore per rosso, verde e blu
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xFF0000) >> 16) / 255
            let g = Double((hexNumber & 0x00FF00) >> 8) / 255
            let b = Double(hexNumber & 0x0000FF) / 255
            
            self.init(red: r, green: g, blue: b)
            return
               
        }
        
        //inizializza i colori a 0
        self.init(red: 0, green: 0, blue: 0)
        
        }
    
    //preleva il colore dal valore hex
    static let cobaltblue = Color(hex: "607AB7")
    
    }



struct ContentView: View {
    @State private var isAnimating = false
        var body: some View {
            VStack {
              Image(systemName: "Logo App WithU") //immagine
                    .resizable()
                    .frame(width: 350, height: 350)
                    .foregroundStyle(.white)  //colore baffo
                    
                    .scaleEffect(isAnimating ? 2.5 : 1.0)
            }.onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                    isAnimating = true
                }
        }
    }

    
}


struct SfondoView: View {
    var body: some View {
        ZStack{
            Color.cobaltblue.ignoresSafeArea()
            Image("Logo App WithU")
                 .resizable()
                 .frame(width: 350, height: 350)
                 .foregroundStyle(.white)
                
        }.ignoresSafeArea()
    }
    
        
    }

#Preview {
SfondoView()
}
