import CoreLocation
import MapKit

struct PlaceResolver {
    func resolvePlaces(_ llmPlaces: [AIRecommendedPlace], near center: CLLocation) async -> [RecommendedPlace] {
        await withTaskGroup(of: RecommendedPlace?.self) { group in
            for place in llmPlaces {
                group.addTask {
                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = place.name
                    request.region = MKCoordinateRegion(center: center.coordinate,
                                                         latitudinalMeters: 2000,
                                                         longitudinalMeters: 2000)
                    guard let mapItem = try? await MKLocalSearch(request: request).start().mapItems.first,
                          let location = mapItem.placemark.location,
                          location.distance(from: center) <= 100 else { return nil }

                    let directionsRequest = MKDirections.Request()
                    directionsRequest.source = .init(placemark: .init(coordinate: center.coordinate))
                    directionsRequest.destination = mapItem
                    directionsRequest.transportType = .walking
                    _ = try? await MKDirections(request: directionsRequest).calculate().routes.first

                    return RecommendedPlace(name: place.name,
                                             detail: place.detail,
                                             latitude: location.coordinate.latitude,
                                             longitude: location.coordinate.longitude)
                }
            }

            var results: [RecommendedPlace] = []
            for await place in group {
                if let place {
                    results.append(place)
                }
            }
            return results
        }
    }
}
