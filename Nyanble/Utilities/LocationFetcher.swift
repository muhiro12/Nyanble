//
//  LocationFetcher.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
//

import CoreLocation

final class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Never>?

    func fetch() async -> CLLocation {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.delegate = self
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                continuation.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations.first ?? CLLocation(latitude: 35.6812, longitude: 139.7671))
        continuation = nil
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
        continuation = nil
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            continuation?.resume(returning: CLLocation(latitude: 35.6812, longitude: 139.7671))
            continuation = nil
        default: break
        }
    }
}
