//
//  LoggingAdapter.swift
//

import Foundation

public struct LoggingAdapter : RequestAdapter {
    public enum LogLevel : Int, Sendable {
        case none
        case info
        case debug
    }
    
    struct Log {
        let level: LogLevel
        
        public func message(_ msg: @autoclosure () -> String, level: LogLevel) {
            guard level.rawValue <= self.level.rawValue else { return }
            print(msg())
        }

        public func message(_ utf8Data: @autoclosure () -> Data?, level: LogLevel) {
            guard level.rawValue <= self.level.rawValue else { return }
            let stringValue = utf8Data().flatMap({ String(data: $0, encoding: .utf8 )}) ?? "<empty>"
            message(stringValue, level: level)
        }
    }

    private let log: Log

    public init(logLevel: LogLevel = .info) {
        log = Log(level: logLevel)
    }

    public func beforeSend(_ request: URLRequest) {
        guard let url = request.url?.absoluteString else { return }
        let method = request.httpMethod ?? ""
        log.message("📡 \(method) \(url)", level: .info)
        if let body = request.httpBody {
            log.message("Request body:", level: .debug)
            log.message(body, level: .debug)
        }
        if let headers = request.allHTTPHeaderFields?.keys {
            for header in headers {
                log.message("Header field: \(header): \(request.allHTTPHeaderFields![header]!)", level: .debug)
            }
        }
    }

    public func onResponse(response: URLResponse?, data: Data?) {
        guard let http = response as? HTTPURLResponse else { return }
        log.message("⬇️ Received HTTP \(http.statusCode) from \(http.url?.absoluteString ?? "<?>")", level: .info)
        log.message("Body: ", level: .debug)
        log.message(data, level: .debug)
    }

    public func onError(request: URLRequest, error: APIError) {
        log.message("❌ ERROR: \(error)", level: .info)
    }
}
