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
    typealias Input = RecommendationQuery
    typealias Output = [RecommendedPlace]

    @Parameter(
        title: "Latitude",
        requestValueDialog: "Enter latitude"
    )
    var latitude: Double?

    @Parameter(
        title: "Longitude",
        requestValueDialog: "Enter longitude"
    )
    var longitude: Double?

    @Parameter(
        title: "Location Name",
        requestValueDialog: "Enter location name"
    )
    var name: String?

    static let title: LocalizedStringResource = "Show Recommendations For Location"
    static let supportedModes: IntentModes = .foreground

    static var parameterSummary: some ParameterSummary {
        Summary("Show recommendations", \(\.$name), \(\.$latitude), \(\.$longitude))
    }

    static func perform(_ input: Input) async throws -> Output {
        guard !input.isEmpty else { throw RecommendationsError.missingInput }

        let session = LanguageModelSession()

        var conditions: [String] = []
        if let name = input.name {
            conditions.append("around \(name)")
        }
        if let lat = input.latitude, let lon = input.longitude {
            conditions.append("near latitude \(lat), longitude \(lon)")
        } else if let lat = input.latitude {
            conditions.append("near latitude \(lat)")
        } else if let lon = input.longitude {
            conditions.append("near longitude \(lon)")
        }

        let conditionText = conditions.joined(separator: " ")
        let prompt = """
        Suggest three interesting places \(conditionText) for today's outing. For each, provide a short name and description.
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
        let results = try await Self.perform(RecommendationQuery(latitude: latitude, longitude: longitude, name: name))
        return .result(
            value: results,
            dialog: "Here are some places near that location."
        )
    }
}
