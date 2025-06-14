import AppIntents

struct RecommendedPlaceQuery: EntityQuery {
    func entities(for identifiers: [RecommendedPlace.ID]) async throws -> [RecommendedPlace] {
        []
    }
}
