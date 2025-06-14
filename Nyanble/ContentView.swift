//
//  ContentView.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showNearbyPlaces = false
    @State private var nearbyPlaces: [RecommendedPlace] = []

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button("Nearby Places") {
                        do {
                            nearbyPlaces = try NearbyRecommendationsIntent.perform(())
                            showNearbyPlaces = true
                        } catch {
                            print("Failed to get recommendations: \(error)")
                        }
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $showNearbyPlaces) {
            RecommendedPlacesView(places: nearbyPlaces)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
