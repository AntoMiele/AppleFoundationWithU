import SwiftUI

/*@main
struct WithUApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootFlow()
                .preferredColorScheme(.light)
        }
    }
}

@MainActor
struct AppRootFlow: View {
    enum Route: Hashable { case siri, contacts, map }

    @State private var path: [Route] = []
    @State private var showSplash = true
    private let splashDuration: TimeInterval = 1.0

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if showSplash {
                    SfondoView()
                        .task {
                            
                            try? await Task.sleep(nanoseconds: UInt64(splashDuration * 1_000_000_000))
                            showSplash = false
                            path.append(.siri)
                        }
                } else {
                    SiriView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .siri:     SiriView()
                case .contacts: ContactsView()
                case .map:      MapView()
                }
            }
        }
    }
}*/

@main
struct WithUApp: App {
    var body: some Scene {

        WindowGroup {
            NavigationStack {
                //ContactsView()
                SiriView()
                 //.sosSharePresenter() // importantissimo: presenter per il composer SMS
                 }

            }
        }
    }
