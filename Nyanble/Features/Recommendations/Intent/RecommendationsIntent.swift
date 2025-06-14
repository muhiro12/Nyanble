//
//  RecommendationsIntent.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
//

import AppIntents
import CoreLocation
import FoundationModels

struct RecommendationsIntent: AppIntent, IntentPerformer {
    typealias Input = (latitude: Double, longitude: Double)
    typealias Output = [RecommendedPlace]

    @Parameter(
        title: "Latitude",
        requestValueDialog: "Enter latitude"
    )
    var latitude: Double

    @Parameter(
        title: "Longitude",
        requestValueDialog: "Enter longitude"
    )
    var longitude: Double

    static let title: LocalizedStringResource = "Show Recommendations For Location"
    static let supportedModes: IntentModes = .foreground

    static var parameterSummary: some ParameterSummary {
        Summary("Show recommendations for \(\.$latitude), \(\.$longitude)")
    }

    static func perform(_ input: Input) async throws -> Output {
        let session = LanguageModelSession()
        let prompt = """
        Suggest three interesting places near latitude \(input.latitude), longitude \(input.longitude) for today's outing. For each, provide a short name and description.
        """
        let response = try await session.respond(
            to: prompt,
            generating: AIRecommendations.self
        )
        return response.content.places.map {
            RecommendedPlace(
                name: $0.name,
                detail: $0.detail,
                latitude: $0.latitude,
                longitude: $0.longitude
            )
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let results = try await Self.perform((latitude, longitude))
        return .result(
            value: results,
            dialog: "Here are some places near that location."
        )
    }
}
