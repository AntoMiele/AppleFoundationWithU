//
//  SettingsView.swift
//  Map_iOS
//
//  Created by san-2 on 20/10/25.
//

import SwiftUI

struct SettingsView: View {
    // Stati per animazione dei pulsanti
    @State private var pressedSecret: Bool = false
    @State private var pressedContact: Bool = false
    
    // Stati per NavigationLink
    @State private var secretsignal: Bool = false
    @State private var contact: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Sfondo principale
                Color.cobaltblue
                    .ignoresSafeArea()
                
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
                    
                    // Sezione con i pulsanti
                    VStack(spacing: 15) {
                        // Pulsante "Reset your secret signal"
                        NavigationLink(destination: SOSConfigView(), isActive: $secretsignal) {
                            Text("Reset your secret signal")
                                .font(.system(size: 22, weight: .light))
                                .foregroundStyle(.black)
                                .frame(width: 260, height: 50)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .shadow(color: .white.opacity(0.3), radius: 20)
                                .scaleEffect(pressedSecret ? 0.95 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        pressedSecret = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        pressedSecret = false
                                        secretsignal = true
                                    }
                                }
                        }
                        
                        // Pulsante "Go to favorite contacts"
                        NavigationLink(destination: ContactSettingsView(), isActive: $contact) {
                            Text("Go to favorite contacts")
                                .font(.system(size: 22, weight: .light))
                                .foregroundStyle(.black)
                                .frame(width: 260, height: 50)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .shadow(color: .white.opacity(0.3), radius: 20)
                                .scaleEffect(pressedContact ? 0.95 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        pressedContact = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        pressedContact = false
                                        contact = true
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 40)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
