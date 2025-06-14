import SwiftUI
import MapKit

struct RecommendedPlacesMapView: View {
    let places: [RecommendedPlace]
    @State private var cameraPosition: MapCameraPosition
    @StateObject private var locationManager = LocationManager()

    init(places: [RecommendedPlace]) {
        self.places = places
        if let first = places.first {
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        } else {
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        }
    }

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(places) { place in
                Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                    Image(systemName: "mappin")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}
