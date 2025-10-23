import SwiftUI

@main
struct WithUApp: App {
    var body: some Scene {
        
        WindowGroup {
            NavigationStack {
                //ContactsView()
                MapView()
                 .sosSharePresenter() // importantissimo: presenter per il composer SMS
                 }
                
            }
        }
    }

