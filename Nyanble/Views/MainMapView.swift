import SwiftUI
import MapKit
import CoreLocation

struct MainMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var recommendedPlaces: [RecommendedPlace] = []
    @State private var selectedPlace: RecommendedPlace?

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(recommendedPlaces, id: \.id) { place in
                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                        Button {
                            selectedPlace = place
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.pink)
                                .font(.title)
                                .accessibilityLabel(Text(place.name))
                        }
                    }
                }
            }
            .onAppear {
                if let loc = locationManager.location {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
                // TODO: 最初のおすすめ場所取得などをここに
            }
            .ignoresSafeArea()

            if let selected = selectedPlace {
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text(selected.name)
                            .font(.headline)
                        Text(selected.detail)
                            .font(.subheadline)
                        Button("保存") {
                            // TODO: SwiftData保存処理
                        }
                        Button("閉じる") {
                            selectedPlace = nil
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 6)
                }
                .padding()
            }
        }
    }
}

#Preview {
    MainMapView()
}
