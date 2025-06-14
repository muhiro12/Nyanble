import Foundation

protocol IntentPerformer {
    associatedtype Input
    associatedtype Output
    static func perform(_ input: Input) async throws -> Output
}
