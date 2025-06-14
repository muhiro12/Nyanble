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
            .task {
                let centerCoordinate: CLLocationCoordinate2D
                if let loc = locationManager.location {
                    centerCoordinate = loc.coordinate
                } else {
                    centerCoordinate = CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125)
                }
                cameraPosition = .region(MKCoordinateRegion(
                    center: centerCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
                await fetchRecommendedPlaces(for: centerCoordinate)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: .constant(true)) {
            RecommendedPlacesSheet(
                recommendedPlaces: recommendedPlaces,
                selectPlace: { place in selectedPlace = place },
                updateAction: {
                    let centerCoordinate: CLLocationCoordinate2D
                    if let loc = locationManager.location {
                        centerCoordinate = loc.coordinate
                    } else {
                        centerCoordinate = CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125)
                    }
                    Task {
                        await fetchRecommendedPlaces(for: centerCoordinate)
                    }
                }
            )
            .presentationDetents([.fraction(0.12), .fraction(0.32), .fraction(0.7)])
            .interactiveDismissDisabled()
        }
        // selectedPlaceをバインディングした.sheetを追加し、詳細ビューを表示する
        .sheet(item: $selectedPlace) { place in
            RecommendedPlaceDetailView(place: place)
        }
    }
}

extension MainMapView {
    func fetchRecommendedPlaces(for coordinate: CLLocationCoordinate2D) async {
        do {
            let results = try await RecommendationsIntent.perform((latitude: coordinate.latitude, longitude: coordinate.longitude))
            recommendedPlaces = results
        } catch {
            print("Intentによるおすすめ場所取得に失敗: \(error)")
        }
    }
}

#Preview {
    MainMapView()
}
