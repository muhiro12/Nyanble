import AppIntents
import Foundation
import SwiftUI
import FoundationModels
import CoreLocation

final class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Never>?

    func fetch() async -> CLLocation {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.delegate = self
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                continuation.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations.first ?? CLLocation(latitude: 35.6812, longitude: 139.7671))
        continuation = nil
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
        continuation = nil
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            continuation?.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
            continuation = nil
        default: break
        }
    }
}

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
        let places = try await Self.perform(())

        return .result(
            dialog: "Here are some places near you.",
            view: RecommendedPlacesView(places: places)
        )
    }
}
