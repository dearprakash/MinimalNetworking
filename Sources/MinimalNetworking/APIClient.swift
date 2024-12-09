//
//  APIClient.swift
//

import Foundation


public final class ApiClient: GenericAPI, Sendable {
    
    let session: URLSession
    nonisolated(unsafe) private var adapters: [RequestAdapter] = []

    public init(configuration: URLSessionConfiguration, adapters: [RequestAdapter] = []) {
        self.session = URLSession(configuration: configuration)
        self.adapters = adapters
    }
    
    public convenience init() {
        self.init(configuration: .default)
    }
    
    public func send<T: Codable>(type: T.Type, with request: Request) async throws -> Result<T, APIError> {
        var urlRequest = request.builder.toURLRequest()
        self.adapters.forEach { $0.adapt(&urlRequest) }
        self.adapters.forEach { $0.beforeSend(urlRequest) }

        let (data, response) = try await session.data(for: urlRequest)
        self.adapters.forEach { $0.onResponse(response: response, data: data) }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.unknownResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                return .failure(.expiredToken)
            }
            return .failure(.requestError(httpResponse.statusCode))
        }
        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode(T.self, from: data)
            self.adapters.forEach { $0.onSuccess(request: urlRequest) }
            return .success(result)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Failed to decode due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
            return .failure(.decodingError(.keyNotFound(key, context)))
        } catch DecodingError.typeMismatch(let key, let context) {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            if errorResponse.status != "Success" {
                return .failure(.noResult(errorResponse.status))
            }
            print("Failed to decode due to type mismatch \(key) – \(context.debugDescription)")
            return .failure(.decodingError(.typeMismatch(key, context)))
        } catch DecodingError.valueNotFound(let type, let context) {
            print("Failed to decode due to missing \(type) value – \(context.debugDescription)")
            return .failure(.decodingError(.valueNotFound(type, context)))
        } catch DecodingError.dataCorrupted(_) {
            print("Failed to decode because it appears to be invalid JSON")
            return .failure(.unknownResponse)
        } catch {
            self.adapters.forEach { $0.onError(request: urlRequest, error: APIError.unknownResponse) }
            return .failure(.unhandledResponse)
        }
     }
}
