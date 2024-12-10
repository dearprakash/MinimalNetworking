//
//  RequestBuilder.swift
//

import Foundation

public protocol RequestBuilder {
    var method: HTTPMethod { get set }
    var baseURL: URL { get set }
    var path: String { get set }
    var params: [URLQueryItem]? { get set }
    var headers: [String : String] { get set }
    var data: Data? { get set }
    func encodeRequestBody() -> Data?
    func toURLRequest() -> URLRequest
}

public extension RequestBuilder {
    var data: Data? {
        nil
    }
}

public extension RequestBuilder {
    func encodeRequestBody() -> Data? {
        return nil
    }

    func toURLRequest() -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = params
        let url = components.url!

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue.uppercased()
        request.httpBody = encodeRequestBody()
        return request
    }
}

struct BasicRequestBuilder : RequestBuilder {
    var method: HTTPMethod
    var baseURL: URL
    var path: String
    var params: [URLQueryItem]?
    var headers: [String : String] = [:]
    var data: Data?
}

struct PostRequestBuilder<Body : Model> : RequestBuilder {
    public var method: HTTPMethod
    public var baseURL: URL
    public var path: String
    public var params: [URLQueryItem]?
    public var headers: [String : String] = [:]
    public var body: Body?
    public var data: Data?

    public init(method: HTTPMethod = .post,
                baseURL: URL,
                path: String,
                additionalHeaders: [String: String] = [:],
                params: [URLQueryItem]? = nil,
                body: Body?,
                data: Data? = nil) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.params = params
        self.body = body
        self.headers["Content-Type"] = "application/json"
        self.data = data
        
        for key in additionalHeaders.keys {
            self.headers[key] = additionalHeaders[key]
        }
    }

    public func encodeRequestBody() -> Data? {
        if let data { return data }
        guard let body = body else { return nil }
        do {
            let encoder = Body.encoder
            return try encoder.encode(body)
        } catch {
            print("Error encoding request body: \(error)")
            return nil
        }
    }
}

struct DeleteRequestBuilder<Body : Model> : RequestBuilder {
    public var method: HTTPMethod
    public var baseURL: URL
    public var path: String
    public var params: [URLQueryItem]?
    public var headers: [String : String] = [:]
    public var body: Body?
    public var data: Data?

    public init(method: HTTPMethod = .delete,
                baseURL: URL,
                path: String,
                additionalHeaders: [String: String] = [:],
                params: [URLQueryItem]? = nil,
                body: Body?) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.params = params
        self.body = body
        self.headers["Content-Type"] = "application/json"
        self.headers["Accept"] = "application/json"
        
        for key in additionalHeaders.keys {
            self.headers[key] = additionalHeaders[key]
        }
    }

    public func encodeRequestBody() -> Data? {
        guard let body = body else { return nil }
        do {
            let encoder = Body.encoder
            return try encoder.encode(body)
        } catch {
            print("Error encoding request body: \(error)")
            return nil
        }
    }
}


