//
//  TestHelpers.swift
//  MVVMSwiftUITests
//

import Foundation
@testable import MVVMSwiftUI

enum TestError: Error, LocalizedError, Equatable {
    case mock

    var errorDescription: String? { "Mock error" }
}

extension GitHubRepo {
    static func make(
        id: Int = 1,
        name: String = "test-repo",
        fullName: String = "owner/test-repo",
        description: String? = "A test repo",
        htmlUrl: String = "https://github.com/owner/test-repo",
        language: String? = "Swift",
        stargazersCount: Int = 100,
        forksCount: Int = 10,
        openIssuesCount: Int = 5,
        isPrivate: Bool = false,
        updatedAt: String? = "2024-01-01T00:00:00Z",
        owner: GitHubOwner = GitHubOwner(login: "owner", avatarUrl: nil)
    ) -> GitHubRepo {
        GitHubRepo(
            id: id,
            name: name,
            fullName: fullName,
            description: description,
            htmlUrl: htmlUrl,
            language: language,
            stargazersCount: stargazersCount,
            forksCount: forksCount,
            openIssuesCount: openIssuesCount,
            isPrivate: isPrivate,
            updatedAt: updatedAt,
            owner: owner
        )
    }
}
