//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct HTTPResponse {
    public let request: HTTPRequest
    public let body: Data
    public let response: HTTPURLResponse

    public init(request: HTTPRequest, response: HTTPURLResponse, data: Data? = nil) {
        self.request = request
        self.body = data ?? Data()
        self.response = response
    }
}

public extension HTTPResponse {
    var statusCode: HTTPStatus { .init(statusCode: response.statusCode) }

    var headers: HTTPHeaders {
        guard let allHeaderFields = response.allHeaderFields as? [String: String] else {
            return .init()
        }

        return .init(allHeaderFields.map { $0 })
    }

    var message: String { HTTPURLResponse.localizedString(forStatusCode: Int(statusCode.code)) }
}

public extension HTTPResponse {
    /// Returns the ``HTTPResponse`` if the ``statusCode`` falls within the specified range.
    /// - Parameter statusCodes: The range of acceptable status code.
    /// - throws: ``HTTPError.Code.invalidStatusCode`` when others are encountered.
    func filter<R: RangeExpression>(statusCodes: R) throws -> HTTPResponse where R.Bound == UInt {
        guard statusCodes.contains(statusCode.code) else {
            throw NetworkError(
                code: .invalidStatusCode,
                request: request,
                response: self
            )
        }

        return self
    }

    /// Returns the ``HTTPResponse`` if it has the specified ``statusCode``.
    /// - Parameter statusCode: The acceptable stats code.
    /// - throws: ``HTTPError.Code.invalidStatusCode`` when others are encountered.
    func filter(statusCode: HTTPStatus) throws -> HTTPResponse {
        try filter(statusCodes: statusCode.code ... statusCode.code)
    }

    /// Returns the ``HTTPResponse`` if the ``statusCode`` falls within the range 200 - 299.
    /// - throws: ``HTTPError.Code.invalidStatusCode`` when others are encountered.
    func filterSuccessfulStatusCodes() throws -> HTTPResponse {
        try filter(statusCodes: 200 ... 299)
    }
}

extension HTTPResponse: CustomStringConvertible {
    public var description: String { "Status Code: \(statusCode), Data Length: \(body.count)" }
}

extension HTTPResponse: CustomDebugStringConvertible {
    public var debugDescription: String { description }
}

extension HTTPResponse: Equatable {
    public static func == (lhs: HTTPResponse, rhs: HTTPResponse) -> Bool {
        lhs.body == rhs.body
            && lhs.response == rhs.response
    }
}

public extension Result where Success == HTTPResponse, Failure == NetworkError {
    var request: HTTPRequest {
        switch self {
        case let .success(response): return response.request
        case let .failure(error): return error.request
        }
    }

    var response: HTTPResponse {
        switch self {
        case let .success(response): return response
        case let .failure(error): return error.response
        }
    }
}
