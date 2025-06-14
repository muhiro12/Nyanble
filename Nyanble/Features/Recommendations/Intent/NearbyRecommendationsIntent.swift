import AppIntents
import Foundation
import SwiftUI
import FoundationModels
import CoreLocation

struct NearbyRecommendationsIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = [RecommendedPlace]

    static let title: LocalizedStringResource = "Show Nearby Recommendations"
    static let supportedModes: IntentModes = .foreground

    static func fetchLocation() async -> CLLocation {
        await withCheckedContinuation { continuation in
            class Delegate: NSObject, CLLocationManagerDelegate {
                let continuation: CheckedContinuation<CLLocation, Never>
                init(_ continuation: CheckedContinuation<CLLocation, Never>) {
                    self.continuation = continuation
                }
                func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                    if let loc = locations.first {
                        continuation.resume(returning: loc)
                    } else {
                        continuation.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
                    }
                }
                func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                    continuation.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
                }
            }

            let manager = CLLocationManager()
            let delegate = Delegate(continuation)
            manager.delegate = delegate
            if manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }
            manager.requestLocation()
        }
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
