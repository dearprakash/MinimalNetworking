//
//  Request.swift
//

import Foundation

public enum HTTPMethod : String {
    case get
    case post
    case put
    case delete
}

public struct Request {
    let builder: RequestBuilder
    
    init(builder: RequestBuilder) {
        self.builder = builder
    }
    
    public static func basic(method: HTTPMethod = .get,
                             baseURL: URL,
                             path: String,
                             params: [URLQueryItem]? = nil) -> Request {
        let builder = BasicRequestBuilder(method: method,
                                          baseURL: baseURL,
                                          path: path,
                                          params: params)
        return Request(builder: builder)
    }
    
    public static func post<Body : Model>(method: HTTPMethod = .post,
                                          baseURL: URL,
                                          path: String,
                                          additionalHeaders: [String: String] = [:],
                                          params: [URLQueryItem]? = nil,
                                          body: Body?) -> Request {
        let builder = PostRequestBuilder(method: method,
                                         baseURL: baseURL,
                                         path: path,
                                         additionalHeaders: additionalHeaders,
                                         params: params,
                                         body: body)
        return Request(builder: builder)
    }
    
    public static func delete<Body : Model>(method: HTTPMethod = .delete,
                                          baseURL: URL,
                                          path: String,
                                          additionalHeaders: [String: String] = [:],
                                          params: [URLQueryItem]? = nil,
                                          body: Body?) -> Request {
        let builder = DeleteRequestBuilder(method: method,
                                           baseURL: baseURL,
                                           path: path,
                                           additionalHeaders: additionalHeaders,
                                           params: params,
                                           body: body)
        return Request(builder: builder)
    }


    public static func put<Body : Model>(method: HTTPMethod = .put,
                                          baseURL: URL,
                                          path: String,
                                          additionalHeaders: [String: String] = [:],
                                          params: [URLQueryItem]? = nil,
                                          body: Body?) -> Request {
        let builder = PostRequestBuilder(method: method,
                                         baseURL: baseURL,
                                         path: path,
                                         additionalHeaders: additionalHeaders,
                                         params: params, body: body)
        return Request(builder: builder)
    }

}
