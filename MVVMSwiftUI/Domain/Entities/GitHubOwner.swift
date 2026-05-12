//
//  GitHubOwner.swift
//  MVVMSwiftUI
//

import Foundation

struct GitHubOwner: Decodable, Hashable, Sendable {
    let login: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
