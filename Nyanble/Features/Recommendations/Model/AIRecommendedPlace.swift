import Foundation
import FoundationModels

@Generable
struct AIRecommendedPlace {
    @Guide(description: "Short name of the place")
    var name: String

    @Guide(description: "Description of the place")
    var detail: String

    @Guide(description: "Latitude of the place")
    var latitude: Double

    @Guide(description: "Longitude of the place")
    var longitude: Double
}
