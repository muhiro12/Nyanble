import SwiftUI

struct RecommendedPlacesView: View {
    let places: [RecommendedPlace]

    var body: some View {
        List(places) { place in
            VStack(alignment: .leading) {
                Text(place.name).bold()
                Text(place.detail).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
