import AppIntents
import CoreLocation
import FoundationModels
import SwiftUI

struct NearbyRecommendationsIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = [RecommendedPlace]

    static let title: LocalizedStringResource = "Show Nearby Recommendations"
    static let supportedModes: IntentModes = .foreground

    static func fetchLocation() async -> CLLocation {
        let fetcher = LocationFetcher()
        return await fetcher.fetch()
    }

    static func perform(_ input: Input) async throws -> Output {
        let location = await fetchLocation()
        let session = LanguageModelSession()
        let prompt = """
        Suggest three interesting places near latitude \(location.coordinate.latitude), longitude \(location.coordinate.longitude) for today's outing. For each, provide a short name and description.
        """

        let response = try await session.respond(
            to: prompt,
            generating: AIRecommendations.self
        )

        return response.content.places.map {
            RecommendedPlace(
                name: $0.name,
                detail: $0.detail,
                latitude: location.coordinate.latitude + Double.random(in: -0.005...0.005),
                longitude: location.coordinate.longitude + Double.random(in: -0.005...0.005)
            )
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        .result(
            value: try await Self.perform(()),
            dialog: "Here are some places near you."
        )
    }
}
