import Foundation
import SwiftUI
import AppIntents

protocol IntentPerformer {
    associatedtype Input
    associatedtype Output
    static func perform(_ input: Input) throws -> Output
}

struct RecommendedPlace: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let detail: String
}

struct RecommendedPlacesView: View {
    let places: [RecommendedPlace]

    var body: some View {
        List(places) { place in
            VStack(alignment: .leading) {
                Text(place.name).bold()
                Text(place.detail).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}

struct NearbyRecommendationsIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = [RecommendedPlace]

    static let title: LocalizedStringResource = "Show Nearby Recommendations"
    static let supportedModes: IntentModes = .foreground

    static func perform(_ input: Input) throws -> Output {
        [
            RecommendedPlace(name: "Nyan Park", detail: "A nice park to relax."),
            RecommendedPlace(name: "Cat Cafe", detail: "Enjoy drinks with cats."),
            RecommendedPlace(name: "River Walk", detail: "Beautiful riverside path.")
        ]
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let places = try Self.perform(())

        return .result(
            dialog: "Here are some places near you.",
            view: RecommendedPlacesView(places: places)
        )
    }
}
