//
//  MockSearchRepositoriesUseCase.swift
//  MVVMSwiftUITests
//

import Foundation
@testable import MVVMSwiftUI

@MainActor
final class MockSearchRepositoriesUseCase: SearchRepositoriesUseCaseType {

    var result: [GitHubRepo] = []
    var error: Error?

    private(set) var callCount = 0
    private(set) var capturedQuery: String?
    private(set) var capturedPage: Int?
    private(set) var capturedPerPage: Int?

    func execute(query: String, page: Int, perPage: Int) async throws -> [GitHubRepo] {
        callCount += 1
        capturedQuery = query
        capturedPage = page
        capturedPerPage = perPage
        if let error = error { throw error }
        return result
    }
}
