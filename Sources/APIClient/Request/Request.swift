//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct Request<Value>: Identifiable {
    public let id = UUID()
    public let underlyingRequest: HTTPRequest
    public let decode: (HTTPResponse) throws -> Value

    public init(
        _ request: HTTPRequest,
        decode: @escaping (HTTPResponse) throws -> Value
    ) {
        self.underlyingRequest = request
        self.decode = decode
    }
}

public extension Request where Value: Decodable {
    // MARK: - Simple Request

    init<R: ResponseDecodable>(
        _ responseValue: R,
        request: HTTPRequest,
        decoder: JSONDecoder = .init()
    ) where Value == R.RawValue {
        self.init(request) {
            try responseValue.decode($0, decoder: decoder)
        }
    }

    // MARK: - Simple Fallback Request

    init<R: ResponseDecodable>(
        responseValue: R,
        request: HTTPRequest,
        decoder: JSONDecoder = .init()
    ) where Value == R.RawValue, R.FallbackValue: Decodable {
        self.init(request) { response in
            switch response.statusCode.code {
            case 200 ... 299:
                return try responseValue.decode(response, decoder: decoder)

            default:
                let error = try decoder.decode(R.FallbackValue.self, from: response.body)
                let fallbackError = HTTPError.fallbackDecode(error)

                throw NetworkError(code: .fallbackDecode, request: request, response: response, error: fallbackError)
            }
        }
    }

    // MARK: - Unwrapped Request

    init<R: ResponseDecodable>(
        _ responseValue: R,
        request: HTTPRequest,
        decoder: JSONDecoder = .init()
    ) where Value == R.FinalValue, R.RawValue == Unwrap<Value> {
        self.init(request) {
            try responseValue.decode($0.body, decoder: decoder)
        }
    }

    // MARK: - Unwrapped Fallback Request

    init<R: ResponseDecodable>(
        responseValue: R,
        request: HTTPRequest,
        decoder: JSONDecoder = .init()
    ) where Value == R.FinalValue, R.RawValue == Unwrap<Value>, R.FallbackValue: Decodable {
        self.init(request) { response in
            switch response.statusCode.code {
            case 200 ... 299:
                return try responseValue.decode(response.body, decoder: decoder)

            default:
                let error = try decoder.decode(R.FallbackValue.self, from: response.body)

                let fallbackError = HTTPError.fallbackDecode(error)

                throw NetworkError(code: .fallbackDecode, request: request, response: response, error: fallbackError)
            }
        }
    }
}

extension Request: Hashable {
    public static func == (lhs: Request<Value>, rhs: Request<Value>) -> Bool {
        lhs.underlyingRequest == rhs.underlyingRequest
            && lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(underlyingRequest)
        hasher.combine(id)
    }
}
