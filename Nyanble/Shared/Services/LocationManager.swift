import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var location: CLLocation?
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Never>?
    private var streamContinuations: [UUID: AsyncStream<CLLocation>.Continuation] = [:]

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.requestLocation()
    }

    func fetchCurrentLocation() async -> CLLocation {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            requestLocation()
        }
    }

    func locationUpdates() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            let id = UUID()
            streamContinuations[id] = continuation
            if let location {
                continuation.yield(location)
            }
            continuation.onTermination = { [weak self] _ in
                self?.streamContinuations[id] = nil
            }
            requestLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.first ?? CLLocation(latitude: 35.6812, longitude: 139.7671)
        location = loc
        continuation?.resume(returning: loc)
        continuation = nil
        for continuation in streamContinuations.values {
            continuation.yield(loc)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let fallback = CLLocation(latitude: 35.6812, longitude: 139.7671)
        continuation?.resume(returning: fallback)
        continuation = nil
        print("Location error: \(error.localizedDescription)")
    }
}
