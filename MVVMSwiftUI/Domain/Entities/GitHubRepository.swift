//
//  GitHubRepository.swift
//  MVVMSwiftUI
//

import Foundation

struct GitHubRepo: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let htmlUrl: String
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let isPrivate: Bool
    let updatedAt: String?
    let owner: GitHubOwner

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case htmlUrl = "html_url"
        case language
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case isPrivate = "private"
        case updatedAt = "updated_at"
        case owner
    }
}
