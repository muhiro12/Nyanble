import Foundation
import CoreLocation

final class WeatherFetcher {
    private struct CacheKey: Hashable {
        let latitude: Double
        let longitude: Double
        let day: Date
    }

    private var cache: [CacheKey: (info: WeatherInfo, timestamp: Date)] = [:]

    func fetch(for coordinate: CLLocationCoordinate2D, date: Date) async -> WeatherInfo {
        let day = Calendar.current.startOfDay(for: date)
        let key = CacheKey(latitude: coordinate.latitude, longitude: coordinate.longitude, day: day)
        if let cached = cache[key], Date().timeIntervalSince(cached.timestamp) < 3600 {
            return cached.info
        }
        let info = WeatherInfo(date: date, summary: "Sunny", temperature: 23)
        cache[key] = (info, Date())
        return info
    }
}
