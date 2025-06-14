import SwiftUI
import MapKit

struct RecommendedPlaceDetailView: View {
    let place: RecommendedPlace
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(place.name)
                    .font(.title).bold()
                Text("緯度: \(place.latitude)")
                Text("経度: \(place.longitude)")
                Spacer()
            }
            .padding()
            .navigationTitle("場所の詳細")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isFavorite.toggle()
                        print(isFavorite ? "お気に入りに追加" : "お気に入り解除")
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}
