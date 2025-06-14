//
//  ContentView.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    @State private var isLoadingNearbyPlaces = false
    @State private var nearbyPlaces: [RecommendedPlace] = []
    @State private var selectedPlace: RecommendedPlace?
    @State private var showPlaceDetail = false
    @State private var selectedScreen: Int = 0 // 0: メインマップ, 1: おすすめ場所マップ, 2: リスト

    var body: some View {
        NavigationView {
            Group {
                switch selectedScreen {
                case 0:
                    MainMapView()
                case 1:
                    VStack {
                        Map(position: $cameraPosition) {
                            UserAnnotation()
                            ForEach(nearbyPlaces) { place in
                                Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                                    Button {
                                        selectedPlace = place
                                        showPlaceDetail = true
                                    } label: {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.red)
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                case 2:
                    RecommendedPlacesView(places: nearbyPlaces)
                default:
                    MainMapView()
                }
            }
            .navigationTitle(Text(screenTitle()))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        selectedScreen = 0
                    } label: {
                        Image(systemName: "globe")
                            .foregroundColor(selectedScreen == 0 ? .accentColor : .primary)
                    }
                    Button {
                        selectedScreen = 1
                    } label: {
                        Image(systemName: "map")
                            .foregroundColor(selectedScreen == 1 ? .accentColor : .primary)
                    }
                    Button {
                        selectedScreen = 2
                    } label: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(selectedScreen == 2 ? .accentColor : .primary)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if selectedScreen == 0 {
                        Button {
                            locationManager.requestLocation()
                        } label: {
                            Label("Update Location", systemImage: "location")
                        }
                    } else if selectedScreen == 1 {
                        Button {
                            Task {
                                await reloadNearbyPlaces()
                            }
                        } label: {
                            Label("Reload", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .sheet(isPresented: $showPlaceDetail) {
                if let place = selectedPlace {
                    PlaceDetailSheet(place: place, onSaveFavorite: {
                        saveFavorite(place: place)
                        showPlaceDetail = false
                    })
                }
            }
            .task {
                if selectedScreen == 1 {
                    await reloadNearbyPlaces()
                }
            }
        }
    }

    private func screenTitle() -> String {
        switch selectedScreen {
        case 0: return "Main Map"
        case 1: return "Recommended Map"
        case 2: return "Recommended List"
        default: return "Nyanble"
        }
    }

    private func reloadNearbyPlaces() async {
        isLoadingNearbyPlaces = true
        defer { isLoadingNearbyPlaces = false }
        do {
            locationManager.requestLocation()
            try await Task.sleep(nanoseconds: 1_000_000_000)
            var region: MKCoordinateRegion
            if let userLocation = locationManager.location?.coordinate {
                region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                cameraPosition = .region(region)
            } else if let currentRegion = cameraPosition.region {
                region = currentRegion
            } else {
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            }
            let results = try await NearbyRecommendationsIntent.perform(())
            nearbyPlaces = results.map { recommended in
                RecommendedPlace(
                    name: recommended.name,
                    detail: recommended.detail,
                    latitude: recommended.latitude,
                    longitude: recommended.longitude
                )
            }
        } catch {
            print("Failed to get recommendations: \(error)")
        }
    }

    private func saveFavorite(place: RecommendedPlace) {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
