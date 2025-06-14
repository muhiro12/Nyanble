//
//  NearbyRecommendationsIntent.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
//

import AppIntents
import CoreLocation
import FoundationModels

struct NearbyRecommendationsIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = [RecommendedPlace]

    static let title: LocalizedStringResource = "Show Nearby Recommendations"
    static let supportedModes: IntentModes = .foreground

    static func perform(_: Input) async throws -> Output {
        let location = await LocationManager().fetchCurrentLocation()
        return try await RecommendationsIntent.perform(
            RecommendationsIntentInput(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude)
        )
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        .result(
            value: try await Self.perform(()),
            dialog: "Here are some places near you."
        )
    }
}
