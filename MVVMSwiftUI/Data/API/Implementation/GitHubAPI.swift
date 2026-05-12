//
//  GitHubAPI.swift
//  MVVMSwiftUI
//

import Foundation
@preconcurrency import Moya
import FactoryKit
import Alamofire

// MARK: - API Target Definition

enum GitHubAPI: BaseTargetType, Sendable {
    case searchRepositories(query: String, page: Int, perPage: Int)
    case getRepository(owner: String, repo: String)

    nonisolated var baseURL: URL {
        guard let url = URL(string: "https://api.github.com") else {
            fatalError("Invalid base URL")
        }
        return url
    }

    nonisolated var requiresAuth: Bool {
        false
    }

    nonisolated var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        case .getRepository(let owner, let repo):
            return "/repos/\(owner)/\(repo)"
        }
    }

    nonisolated var method: Moya.Method {
        return .get
    }

    nonisolated var task: Moya.Task {
        switch self {
        case .searchRepositories(let query, let page, let perPage):
            return .requestParameters(
                parameters: [
                    "q": query,
                    "page": page,
                    "per_page": perPage,
                    "sort": "stars",
                    "order": "desc"
                ],
                encoding: URLEncoding.default
            )
        case .getRepository:
            return .requestPlain
        }
    }

    nonisolated var sampleData: Data {
        Data()
    }
}

// MARK: - Response Models

struct GitHubSearchResponse: Decodable {
    let totalCount: Int
    let items: [GitHubRepo]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

// MARK: - DI Registration

extension Container {
    var gitHubApiService: Factory<APIService<GitHubAPI>> {
        Factory(self) {
            self.apiService()
        }
        .singleton
    }
}
