//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine
import Foundation
import Logging

public struct HTTPRequest {
    public var method: HTTPMethod = .get
    public var headers: HTTPHeaders = .init()
    public var body: HTTPBody = Empty() {
        didSet { headers.add(contentsOf: body.additionalHeaders) }
    }

    public let logger: Logger

    private var uri = URI()

    public init(logger: Logger = .init(label: "network.request")) {
        self.logger = logger
    }
}

public extension HTTPRequest {
    static var `default`: HTTPRequest { HTTPRequest() }
    var string: String { uri.string }

    var scheme: URI.Scheme {
        get { .init(uri.scheme) }
        set { uri.scheme = newValue.value }
    }

    var host: String? {
        get { uri.host }
        set { uri.host = newValue }
    }

    var path: [PathComponent] {
        get { uri.path.pathComponents }
        set { uri.path = newValue.path.string }
    }

    var query: [PathComponent] {
        get { uri.query?.pathComponents ?? [] }
        set { uri.query = newValue.query.string }
    }
    
    var port: Int? {
        get { uri.port }
        set { uri.port = newValue }
    }
}

public extension HTTPRequest {
    func scheme(_ scheme: URI.Scheme) -> HTTPRequest {
        var copy = self
        copy.scheme = scheme

        return copy
    }

    func host(_ host: String) -> HTTPRequest {
        var copy = self
        copy.host = host

        return copy
    }

    func method(_ method: HTTPMethod) -> HTTPRequest {
        var copy = self
        copy.method = method

        return copy
    }

    func path(_ path: [PathComponent]) -> HTTPRequest {
        var copy = self
        copy.path = path

        return copy
    }

    func path(@PathComponentBuilder _ builder: () -> [String]) -> HTTPRequest {
        var copy = self
        copy.path = Array(builder)

        return copy
    }

    func query(_ query: [PathComponent]) -> HTTPRequest {
        var copy = self
        copy.query = query

        return copy
    }

    func query(@PathComponentBuilder _ builder: () -> [String]) -> HTTPRequest {
        var copy = self
        copy.query = Array(builder)

        return copy
    }

    func addQuery<E: Encodable>(_ encodable: E) -> HTTPRequest {
        var copy = self
        copy.query = query

        do {
            try copy.query.append(encodable)
        } catch {}

        return copy
    }

    func body(_ body: HTTPBody) -> HTTPRequest {
        var copy = self
        copy.body = body

        return copy
    }

    func addHeaders(@HTTPHeadersBuilder _ builder: () -> [(String, String)]) -> HTTPRequest {
        var copy = self
        copy.headers.add(contentsOf: builder())

        return copy
    }
}

public extension HTTPRequest {
    func chaining(to next: Responder) -> AnyPublisher<HTTPResponse, Swift.Error> {
        next.respond(to: self)
    }
}

extension HTTPRequest: Equatable {
    public static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        guard let lhsData = try? lhs.body.encode(), let rhsData = try? rhs.body.encode() else { return false }

        return lhs.method == rhs.method
            && lhs.headers == rhs.headers
            && lhsData == rhsData
            && lhs.uri.string == rhs.uri.string
    }
}

extension HTTPRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(method)
        hasher.combine(headers)
        hasher.combine(uri)
        if let data = try? body.encode() {
            hasher.combine(data)
        }
    }
}

extension HTTPRequest: CustomStringConvertible {
    public var description: String {
        [
            "URL": uri.string,
            "METHOD": method.description,
            "HEADERS": headers.description,
        ]
        .map { "\($0.key):\n  \($0.value)" }
        .joined(separator: "\n")
    }
}

public extension HTTPRequest {
    var curl: String {
        var result = "curl -k "

        result += "-X \(method.description) \\\n"
        headers
            .headers
            .forEach { result += "-H \"\($0.0): \($0.1)\" \\\n" }

        if let body = try? body.encode(), !body.isEmpty,
           let string = String(data: body, encoding: .utf8), !string.isEmpty
        {
            result += "-d '\(string)' \\\n"
        }

        result += string

        return result
    }
}
