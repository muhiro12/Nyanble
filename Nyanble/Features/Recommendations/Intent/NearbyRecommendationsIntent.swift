import AppIntents
import Foundation
import SwiftUI
import FoundationModels

struct NearbyRecommendationsIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = [RecommendedPlace]

    static let title: LocalizedStringResource = "Show Nearby Recommendations"
    static let supportedModes: IntentModes = .foreground

    static func perform(_ input: Input) async throws -> Output {
        let session = LanguageModelSession()
        let prompt = """
        Suggest three interesting places for today's outing. For each, provide a short name and description.
        """

        let response = try await session.respond(
            to: prompt,
            generating: AIRecommendations.self
        )

        return response.content.places.map {
            RecommendedPlace(name: $0.name, detail: $0.detail)
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let places = try await Self.perform(())

        return .result(
            dialog: "Here are some places near you.",
            view: RecommendedPlacesView(places: places)
        )
    }
}
