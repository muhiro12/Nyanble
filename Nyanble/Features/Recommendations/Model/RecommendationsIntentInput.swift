import Foundation

struct RecommendationsIntentInput {
    var latitude: Double?
    var longitude: Double?
    var name: String?

    init(latitude: Double? = nil, longitude: Double? = nil, name: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }

    var isEmpty: Bool {
        latitude == nil && longitude == nil && name == nil
    }
}
