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

    static func fetchLocation() async -> CLLocation {
        let fetcher = LocationFetcher()
        return await fetcher.fetch()
    }

    static func perform(_ input: Input) async throws -> Output {
        let location = await fetchLocation()
        return try await RecommendationsForLocationIntent.perform((latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        .result(
            value: try await Self.perform(()),
            dialog: "Here are some places near you."
        )
    }
}
