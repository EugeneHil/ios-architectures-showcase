import Foundation

/// Async CRUD storage consumed by every architecture sample.
///
/// Methods are async and throwing on purpose: each pattern has to surface
/// loading and error states the way its idiom prescribes.
protocol TodoRepository: Sendable {
    func fetchAll() async throws -> [Todo]
    func add(_ todo: Todo) async throws
    func update(_ todo: Todo) async throws
    func delete(id: UUID) async throws
}

enum TodoRepositoryError: Error, Equatable {
    case notFound
    case storageFailed(String)
}
