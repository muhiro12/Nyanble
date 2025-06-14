import AppIntents
import Foundation

struct WeatherInfo: AppEntity {
    nonisolated let id: String
    let date: Date
    let summary: String
    let temperature: Double

    nonisolated static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Weather")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: summary),
            subtitle: LocalizedStringResource(stringLiteral: "\(Int(temperature))°C")
        )
    }

    static let defaultQuery = WeatherInfoQuery()

    init(id: String = UUID().uuidString, date: Date, summary: String, temperature: Double) {
        self.id = id
        self.date = date
        self.summary = summary
        self.temperature = temperature
    }
}

struct WeatherInfoQuery: EntityQuery {
    func entities(for identifiers: [WeatherInfo.ID]) throws -> [WeatherInfo] {
        []
    }

    func suggestedEntities() throws -> [WeatherInfo] {
        []
    }
}
