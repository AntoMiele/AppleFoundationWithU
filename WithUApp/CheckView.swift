//
//  SOSView.swift
//  Map_iOS
//
//  Created by san-2 on 20/10/25.
//

import SwiftUI

struct CheckView: View {
    @State private var pressed: Bool = false

    var body: some View {
        ZStack {
            // Sfondo principale
            Color.cobaltblue.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        pressed.toggle()
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 110, weight: .bold))
                        .foregroundStyle(.green)
                        .scaleEffect(pressed ? 0.9 : 1.0)
                        .shadow(color: .white.opacity(0.4), radius: 15)
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 10) {
                    Text("All right!")
                        .font(.system(size: 25, weight: .semibold))
                    Text("The emergency message has been sent")
                        .font(.system(size: 13))
                        .opacity(0.8)
                }
                .foregroundColor(.white)
                .padding(.vertical, 25)
                .padding(.horizontal, 40)
                .background(.ultraThinMaterial) // effetto vetroso
                .cornerRadius(25)
                .shadow(radius: 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    CheckView()
}

