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
    @State private var isSheetPresented = true

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
            .onChange(of: locationManager.location) { oldLocation, newLocation in
                guard let loc = newLocation else { return }
                let centerCoordinate = loc.coordinate
                cameraPosition = .region(MKCoordinateRegion(
                    center: centerCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
                Task {
                    await fetchRecommendedPlaces(for: centerCoordinate)
                }
            }
            .task {
                locationManager.requestLocation()
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $isSheetPresented) {
            RecommendedPlacesSheet(
                recommendedPlaces: recommendedPlaces,
                selectPlace: { place in
                    isSheetPresented = false
                    selectedPlace = place
                },
                updateAction: {
                    Task {
                        guard let coordinate = cameraPosition.region?.center else {
                            return
                        }
                        await fetchRecommendedPlaces(for: coordinate)
                    }
                }
            )
            .presentationDetents([.fraction(0.3), .fraction(0.8)])
        }
        .sheet(item: $selectedPlace) { place in
            RecommendedPlaceDetailView(place: place)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    isSheetPresented = true
                } label: {
                    Label("Show Places List", systemImage: "list.bullet")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    locationManager.requestLocation()
                } label: {
                    Label("Update Location", systemImage: "location")
                }
            }
        }
    }
}

extension MainMapView {
    func fetchRecommendedPlaces(for coordinate: CLLocationCoordinate2D) async {
        do {
            let query = RecommendationQuery(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let results = try await RecommendationsIntent.perform(query)
            recommendedPlaces = results
        } catch {
            print("Intentによるおすすめ場所取得に失敗: \(error)")
        }
    }
}

#Preview {
    MainMapView()
}
