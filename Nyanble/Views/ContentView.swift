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

    var body: some View {
        NavigationView {
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
            .navigationTitle("Nearby Places Map")
            .task {
                locationManager.requestLocation()
                isLoadingNearbyPlaces = true
                defer { isLoadingNearbyPlaces = false }
                do {
                    // Wait briefly for location update
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    var region: MKCoordinateRegion
                    if let userLocation = locationManager.location?.coordinate {
                        region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                        cameraPosition = .region(region)
                    } else if let currentRegion = cameraPosition.region {
                        region = currentRegion
                    } else {
                        // fallback
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
            .sheet(isPresented: Binding.constant(!nearbyPlaces.isEmpty)) {
                RecommendedPlacesView(places: nearbyPlaces)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showPlaceDetail) {
                if let place = selectedPlace {
                    PlaceDetailSheet(place: place, onSaveFavorite: {
                        saveFavorite(place: place)
                        showPlaceDetail = false
                    })
                }
            }
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
