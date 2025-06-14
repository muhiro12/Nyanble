import Combine
import CoreLocation
import Foundation

/// LocationManager is a robust location provider that integrates the functionality of the previous LocationFetcher,
/// allowing both continuous location updates and single-shot location fetches.
///
/// - The `fetchCurrentLocation()` method provides a suspendable way to get the current location once,
///   suitable for single-use location requests.
/// - It also handles location authorization and fallback coordinates internally,
///   ensuring a reliable location is always returned.
/// - Continuous location updates are available via the `locationUpdates()` AsyncStream, and current location
///   is published via the `@Published var location`.
///
/// This class fully integrates LocationFetcher features for single-shot and streaming location needs.
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var location: CLLocation?
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Never>?
    private var streamContinuations: [UUID: AsyncStream<CLLocation>.Continuation] = [:]

    private let fallbackLocation = CLLocation(latitude: 35.6812, longitude: 139.7671) // Tokyo Station fallback

    override init() {
        super.init()
        manager.delegate = self
    }

    /// Asynchronously fetches the current location once.
    ///
    /// This method suspends until a location is obtained or fallback is used.
    /// It integrates the previous LocationFetcher’s functionality by:
    /// - Handling authorization requests as needed.
    /// - Returning a fallback location (Tokyo Station) if the location cannot be determined.
    ///
    /// This makes it suitable for single-shot location requests where continuous monitoring is not required.
    ///
    /// - Returns: The current CLLocation, or a fallback location if unavailable.
    func fetchCurrentLocation() async -> CLLocation {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            requestLocation()
        }
    }

    /// Provides an AsyncStream of location updates for continuous monitoring.
    /// The current cached location (if any) is yielded immediately upon stream creation.
    ///
    /// - Returns: AsyncStream emitting CLLocation updates.
    func locationUpdates() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            let id = UUID()
            DispatchQueue.main.async {
                self.streamContinuations[id] = continuation
            }
            if let location {
                continuation.yield(location)
            }
            continuation.onTermination = { [weak self] _ in
                DispatchQueue.main.async {
                    self?.streamContinuations[id] = nil
                }
            }
            requestLocation()
        }
    }

    private func requestLocation() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.first ?? fallbackLocation
        location = loc
        continuation?.resume(returning: loc)
        continuation = nil
        for continuation in streamContinuations.values {
            continuation.yield(loc)
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        // On failure, resume with fallback location for single-shot fetches
        continuation?.resume(returning: fallbackLocation)
        continuation = nil
        print("Location error: \(error.localizedDescription)")
    }
}
