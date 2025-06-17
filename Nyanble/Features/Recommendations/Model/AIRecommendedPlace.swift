import Foundation
import FoundationModels

@Generable
struct AIRecommendedPlace {
    @Guide(description: "Short name of the place")
    var name: String

    @Guide(description: "Description of the place")
    var detail: String
}
