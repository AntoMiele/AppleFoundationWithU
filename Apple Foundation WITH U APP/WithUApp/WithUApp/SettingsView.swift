//
//  SettingsView.swift
//  Map_iOS
//
//  Created by san-2 on 20/10/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var pressed: Bool = false
    @State private var secretsignal: Bool = false
    @State private var contact: Bool = false
    
    
    var body: some View {
        ZStack {
            // Sfondo principale
            Color.cobaltblue.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Icona e titolo
                VStack {
                    Image(systemName: "gearshape.circle")
                        .font(.system(size: 110, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    
                    Text("Settings")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.bottom, 30)
                }
                
                // Sezione con le “bubbole”
                VStack(spacing: 15) {
                    
                    Button {
                        
                        secretsignal = true
                    } label: {
                        Text("Reset your secret signal")
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(.black)
                            .frame(width: 260, height: 50)
                    }
                    .buttonStyle(.glass)
                    .scaleEffect(pressed ? 0.9 : 1.0)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                    
                    Button {
                       
                        contact = true
                    } label: {
                        Text("Go to favorite contacts")
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(.black)
                            .frame(width: 260, height: 50)
                    }
                    .buttonStyle(.glass)
                    .scaleEffect(pressed ? 0.9 : 1.0)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                }
                .padding(.vertical, 25)        // margine sopra/sotto uniforme
                .padding(.horizontal, 40)
                .background(.ultraThinMaterial)
                .cornerRadius(25)
                .shadow(radius: 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    SettingsView()
}
