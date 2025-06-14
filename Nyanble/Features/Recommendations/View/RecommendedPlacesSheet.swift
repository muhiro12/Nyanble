import SwiftUI

struct RecommendedPlacesSheet: View {
    @State private var isUpdating = false
    let recommendedPlaces: [RecommendedPlace]
    let selectPlace: (RecommendedPlace) -> Void
    let updateAction: () async -> Void

    var body: some View {
        NavigationStack {
            List(recommendedPlaces, id: \.id) { place in
                Button {
                    selectPlace(place)
                } label: {
                    VStack(alignment: .leading) {
                        Text(place.name).font(.body)
                        Text(place.detail).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Recommended Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isUpdating = true
                        Task {
                            await updateAction()
                            isUpdating = false
                        }
                    }) {
                        if isUpdating {
                            ProgressView()
                        } else {
                            Label("Update", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(isUpdating)
                }
            }
        }
    }
}

#Preview {
    RecommendedPlacesSheet(
        recommendedPlaces: [
            RecommendedPlace(name: "Cat Cafe Shibuya", detail: "Relax with cats in the heart of Shibuya", latitude: 35.6595, longitude: 139.7005),
            RecommendedPlace(name: "Neko Shrine", detail: "A small shrine dedicated to cats", latitude: 35.6895, longitude: 139.6917)
        ],
        selectPlace: { _ in },
        updateAction: {
            try? await Task.sleep(for: .seconds(1))
        }
    )
}
