import Foundation
import FoundationModels

@Generable
struct AIRecommendations {
    @Guide(description: "A list of recommended nearby places", .count(10))
    var places: [AIRecommendedPlace]
}
