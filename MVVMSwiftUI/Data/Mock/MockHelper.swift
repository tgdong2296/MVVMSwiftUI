//
//  MockHelper.swift
//  VMPatternSwiftUI
//

import Foundation
@preconcurrency import Moya

/// Loads mock JSON data from files in the Data/Mock folder.
enum MockHelper: Sendable {
    
    /// Loads mock JSON data from a file in the bundle.
    /// - Parameter fileName: The name of the JSON file (without extension).
    /// - Returns: The raw Data contents of the file.
    nonisolated static func loadJSON(from fileName: String) -> Data {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Mock file \(fileName).json not found in bundle.")
        }
        return data
    }
    
    /// Creates a Moya `EndpointClosure` that returns stubbed responses from JSON files.
    /// - Parameter mapping: A closure that maps each target to a JSON file name.
    /// - Returns: An `EndpointClosure` suitable for `MoyaProvider`.
    nonisolated static func stubbedEndpointClosure<T: BaseTargetType>(
        mapping: @escaping (T) -> String
    ) -> MoyaProvider<T>.EndpointClosure {
        return { target in
            let jsonFileName = mapping(target)
            let data = loadJSON(from: jsonFileName)
            return Endpoint(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, data) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
    }
    
    /// Creates a stubbed `MoyaProvider` that serves responses from local JSON files.
    /// - Parameter mapping: A closure that maps each target to a JSON file name.
    /// - Returns: A `MoyaProvider` configured for immediate stubbing.
    nonisolated static func stubbedProvider<T: BaseTargetType>(
        mapping: @escaping (T) -> String
    ) -> MoyaProvider<T> {
        return MoyaProvider<T>(
            endpointClosure: stubbedEndpointClosure(mapping: mapping),
            stubClosure: MoyaProvider.delayedStub(1)
        )
    }
}
