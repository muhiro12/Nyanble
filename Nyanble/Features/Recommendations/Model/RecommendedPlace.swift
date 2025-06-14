import Foundation
import AppIntents

struct RecommendedPlace: Identifiable, Hashable, AppEntity {
    let id: UUID
    let name: String
    let detail: String
    let latitude: Double
    let longitude: Double

    init(id: UUID = UUID(), name: String, detail: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.detail = detail
        self.latitude = latitude
        self.longitude = longitude
    }

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recommended Place")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: name,
            subtitle: detail
        )
    }

    static let defaultQuery = RecommendedPlaceQuery()
}
