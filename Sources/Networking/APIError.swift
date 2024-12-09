//
//  APIError.swift
//

import Foundation

public enum APIError : Error, Sendable {
    case unknownResponse
    case expiredToken
    case networkError(Error)
    case requestError(Int)
    case serverError(Int)
    case decodingError(DecodingError)
    case noResult(String)
    case unhandledResponse
}

extension APIError : CustomStringConvertible {
    static func error(from response: URLResponse?) -> APIError? {
        guard let http = response as? HTTPURLResponse else {
            return .unknownResponse
        }
            
        switch http.statusCode {
        case 200...299: return nil
        case 400...499: return .requestError(http.statusCode)
        case 500...599: return .serverError(http.statusCode)
        default: return .unhandledResponse
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .unknownResponse: return "Unknown Response"
        case .expiredToken: return "Session has been Expired, Try logging in again"
        case .networkError(let error): return "Network Error: \(error.localizedDescription)"
        case .requestError(let statusCode): return "HTTP \(statusCode)"
        case .serverError(let statusCode): return "Server error (HTTP \(statusCode))"
        case .decodingError(let decodingError): return "Decoding error: \(decodingError)"
        case .noResult(let message): return "Server returned \(message)"
        case .unhandledResponse: return "Unhandled response"
        }
    }
    
    public var description: String {
        localizedDescription
    }
}
