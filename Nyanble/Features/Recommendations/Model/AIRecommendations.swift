import Foundation

@Generable
struct AIRecommendations {
    @Guide(description: "A list of recommended nearby places", .count(3))
    var places: [AIRecommendedPlace]
}
