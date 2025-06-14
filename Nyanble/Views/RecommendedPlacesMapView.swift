import SwiftUI
import MapKit

struct RecommendedPlacesMapView: View {
    let places: [RecommendedPlace]
    @State private var region: MKCoordinateRegion
    @StateObject private var locationManager = LocationManager()

    init(places: [RecommendedPlace]) {
        self.places = places
        if let first = places.first {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: places) { place in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}
