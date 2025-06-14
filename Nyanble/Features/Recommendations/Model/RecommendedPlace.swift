import Foundation

struct RecommendedPlace: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let detail: String
}
