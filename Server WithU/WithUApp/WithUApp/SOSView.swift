import SwiftUI

struct SOSView: View {
    @State private var pressed: Bool = false
    @State private var sending = false
    @State private var showOK = false
    @State private var errorText: String?

    var body: some View {
        ZStack {
            Color.cobaltblue.ignoresSafeArea()

            VStack {
                Spacer()

                Text("Something wrong?")
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .light))
                    .padding(.bottom, 10)

                ZStack {
                    Color.red
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    Text("SOS")
                        .foregroundStyle(.white)
                        .font(.system(size: 30, weight: .bold))
                        .padding(80)
                }

                VStack(spacing: 10) {
                    Text("We'll prepare a message to your favorite contacts with your location.")
                        .font(.system(size: 17, weight: .bold))
                        .opacity(0.9)
                }
                .foregroundColor(.white)
                .padding(.vertical, 25)
                .padding(.horizontal, 40)
                .background(.ultraThinMaterial)
                .cornerRadius(25)
                .shadow(radius: 10)
                .padding(.bottom, 40)

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { pressed.toggle() }
                    sending = true
                    // Prepara SMS con posizione + contatti (la UI lo presenterà via .sosSharePresenter())
                    SMSShareCoordinator.shared.queueLocalSMS(note: "SOS by tap")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        sending = false
                        showOK = true // facoltativo: feedback locale
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(.green)
                        .frame(width: 90, height: 90)
                }
                .buttonStyle(.glass)
                .clipShape(Circle())
                .scaleEffect(pressed ? 0.9 : 1.0)
                .shadow(color: .white.opacity(0.3), radius: 20)
                .padding(.bottom, 50)
                .disabled(sending)

                Spacer()
            }
        }
        .alert("Something goes wrong", isPresented: Binding(get: { errorText != nil }, set: { _ in errorText = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorText ?? "")
        }
        .sheet(isPresented: $showOK) { CheckView() }
    }
}

#Preview {
    SOSView()
}
