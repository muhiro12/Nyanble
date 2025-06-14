import AppIntents
import CoreLocation

struct WeatherByDateIntent: AppIntent, IntentPerformer {
    typealias Input = Date
    typealias Output = WeatherInfo

    @Parameter(
        title: "Date",
        requestValueDialog: "Enter date"
    )
    var date: Date

    static let title: LocalizedStringResource = "Check Weather"
    static let supportedModes: IntentModes = .foreground

    static var parameterSummary: some ParameterSummary {
        Summary("Check weather for \(\.$date)")
    }

    static func perform(_ input: Date) async throws -> WeatherInfo {
        let location = await LocationFetcher().fetch()
        let fetcher = WeatherFetcher()
        return await fetcher.fetch(for: location.coordinate, date: input)
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        .result(
            value: try await Self.perform(date),
            dialog: "Here is the forecast."
        )
    }
}
