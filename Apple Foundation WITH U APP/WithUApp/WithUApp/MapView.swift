import SwiftUI
import MapKit
internal import Combine

struct MapView: View {
    @State private var showConfig: Bool = false
    @State private var pressed: Bool = false
    @State private var sosPressed: Bool = false   // <- aggiunto per l’animazione del pulsante SOS

    @State private var sending: Bool = false
    @State private var showSOSError: Bool = false
    @State private var errorText: String?
    @State private var showCheck: Bool = false
    @State private var showingAdd: Bool = false
    @State private var showingSettings: Bool = false

    @State var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: .init(latitude: 41.8, longitude: 14.47),
            span: .init(latitudeDelta: 1.2, longitudeDelta: 1.2)
        )
    )

    private let tick = Timer.publish(every: 120, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Map(position: $position)
                .ignoresSafeArea(.all)

            VStack {
                Spacer()

                // Pulsante centrale AVVIA/STOP
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        pressed.toggle()
                    }
                    sending.toggle()
                    if sending {
                        inviaPosizione(note: "Location sharing activated")
                    }
                } label: {
                    Image(systemName: sending ? "square.circle" : "location.circle")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 100, height: 100)
                }
                .buttonStyle(.glass)
                .clipShape(Circle())
                .scaleEffect(pressed ? 0.9 : 1.0)
                .shadow(color: .black.opacity(0.4), radius: 20)
                .padding(.bottom, 12)

                Text(sending ? "Location sharing active" : "Sharing not active")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
            }
        }
        .onReceive(tick) { _ in
            guard sending else { return }
            inviaPosizione(note: "Location update")
        }

        //SOS
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        sosPressed.toggle()
                    }
                    SOSDispatcher.shared.sendSOSNow(note: "SOS") { result in
                        switch result {
                        case .success:
                            showingAdd = true
                            showCheck = true
                        case .failure(let e):
                            errorText = exception(error: e)
                            showSOSError = true
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 85, height: 85) // ← 🔹 Dimensione effettiva del pulsante
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: .red.opacity(0.5), radius: 15, y: 4)

                        Image(systemName: "sos")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.red)
                    }
                    .scaleEffect(sosPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: sosPressed)
                }
                .buttonStyle(.plain)
                .alert("SOS", isPresented: $showingAdd) {
                    Button("Close", role: .cancel) { }
                } message: {
                    Text("We sent your position to your contacts...")
                }
            }

            // Settings
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape.circle")
                }
            }
        }

        .alert("Send error", isPresented: $showSOSError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorText ?? "Something went wrong...")
        }

        .sheet(isPresented: $showCheck) {
            CheckView()
        }
    }

    // MARK: - Funzioni
    private func inviaPosizione(note: String) {
        SOSDispatcher.shared.sendSOSNow(note: note) { result in
            switch result {
            case .success: break
            case .failure(let e):
                errorText = exception(error: e)
                showSOSError = true
            }
        }
    }

    private func exception(error: SOSError) -> String {
        switch error {
        case .noContacts:
            return "Nobody contacts. Add some in Settings."
        case .noLocation:
            return "Impossible to get your position. Enable GPS or permission to access your location."
        case .networking(let msg):
            return "Network issue: \(msg)"
        }
    }
}

#Preview {
    NavigationStack {
        MapView()
            //.sosSharePresenter()
    }
}
