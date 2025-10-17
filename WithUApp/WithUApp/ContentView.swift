//
//  ContentView.swift
//  Map_iOS
//
//  Created by san-12 on 15/10/25.
//

//Necessari permessi facendo Map_iOS -> info -> Privacy per la posizione da condividere

//INSERIRE L'INTERFACCIA MAPPA

import SwiftUI
import MapKit

struct MapView: View {
    
        @State var position: MapCameraPosition = .region(MKCoordinateRegion(
            
            //punto della mappa
            center: .init(latitude: 47.498167,longitude: 8.726667),
            
            //zoom
            span: .init(latitudeDelta: 2.5, longitudeDelta: 2.5)
        ))

        var body: some View {
            ZStack{
                Map(position: $position)
                .ignoresSafeArea(.all)
            }
        
    }
}

#Preview {
    MapView()
}


//Cerchio dell'utente
/*
struct ContentView: View {
    let locationManager = CLLocationManager()
    @State var distance: CLLocationDistance = 500.0
    @State var defaultLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        ZStack{
            Map(position: $position) {
                MapCircle(center:  locationManager.location?.coordinate ?? defaultLocation, radius: distance)
                    .foregroundStyle(Color(white: 0.4, opacity: 0.25))
                    .stroke(.orange, lineWidth: 2)
                UserAnnotation()
            }
            .ignoresSafeArea(.all)
            .onAppear{self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
}
*/
