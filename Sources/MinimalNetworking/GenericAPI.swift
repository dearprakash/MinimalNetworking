//
//  GenericAPI.swift
//

import Foundation

protocol GenericAPI: Sendable {
    var session: URLSession { get }
    func fetch<T: Codable>(type: T.Type, with request: URLRequest) async throws -> T
    func send<T: Codable>(type: T.Type, with request: Request) async throws -> Result<T, APIError>

}

extension GenericAPI {
    func fetch<T: Codable>(type: T.Type, with request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknownResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.requestError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.unhandledResponse
        }
    }
}
