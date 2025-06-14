import AppIntents
import Foundation

struct RecommendedPlace: AppEntity {
    nonisolated let id: String

    let name: String
    let detail: String
    let latitude: Double
    let longitude: Double

    nonisolated static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recommended Place")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name), subtitle: LocalizedStringResource(stringLiteral: detail))
    }

    static let defaultQuery = RecommendedPlaceQuery()

    init(id: String = UUID().uuidString, name: String, detail: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.detail = detail
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct RecommendedPlaceQuery: EntityQuery {
    func entities(for identifiers: [RecommendedPlace.ID]) throws -> [RecommendedPlace] {
        []
    }

    func suggestedEntities() throws -> [RecommendedPlace] {
        []
    }
}
