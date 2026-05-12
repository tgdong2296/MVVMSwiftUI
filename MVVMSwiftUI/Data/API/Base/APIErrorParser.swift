//
//  APIErrorParser.swift
//  VMPatternSwiftUI
//

import Foundation
@preconcurrency import Moya
import Alamofire

enum APIErrorParser: Sendable {
    
    /// Parses a MoyaError into a domain-specific APIError
    nonisolated static func parse(_ error: MoyaError) -> APIError {
        switch error {
        case .statusCode(let response):
            return parseHTTPStatusCode(response.statusCode, data: response.data)
            
        case let .underlying(underlyingError, response):
            // Check for Alamofire/URLSession-level errors
            if let afError = underlyingError.asAFError {
                return parseAlamofireError(afError)
            }
            
            let nsError = underlyingError as NSError
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                NSURLErrorNetworkConnectionLost:
                return .noInternetConnection
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorCancelled:
                return .cancelled
            default:
                if let response {
                    return parseHTTPStatusCode(response.statusCode, data: response.data)
                }
                return .unknown(underlyingError)
            }
            
        case .objectMapping(let error, _):
            return .decodingFailed(error)
            
        case .encodableMapping(let error):
            return .decodingFailed(error)
            
        case .parameterEncoding(let error):
            return .unknown(error)
            
        default:
            return .unknown(error)
        }
    }
    
    // MARK: - Private
    
    nonisolated private static func parseHTTPStatusCode(_ statusCode: Int, data: Data) -> APIError {
        let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
        
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500...599:
            return .serverError(statusCode: statusCode)
        default:
            return .network(statusCode: statusCode, response: errorResponse)
        }
    }
    
    nonisolated private static func parseAlamofireError(_ error: AFError) -> APIError {
        switch error {
        case .sessionTaskFailed(let underlyingError):
            let nsError = underlyingError as NSError
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                NSURLErrorNetworkConnectionLost:
                return .noInternetConnection
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorCancelled:
                return .cancelled
            default:
                return .unknown(underlyingError)
            }
        default:
            return .unknown(error)
        }
    }
}
