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
    @State private var nearbyPlaces: [RecommendedPlace] = []
    @State private var selectedScreen: Int = 0

    var body: some View {
        NavigationView {
            Group {
                switch selectedScreen {
                case 0:
                    MainMapView()
                case 1:
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
                        Image(systemName: "list.bullet")
                            .foregroundColor(selectedScreen == 2 ? .accentColor : .primary)
                    }
                }
            }
        }
    }

    private func screenTitle() -> String {
        switch selectedScreen {
        case 0: return "Main Map"
        case 1: return "Recommended List"
        default: return "Nyanble"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
