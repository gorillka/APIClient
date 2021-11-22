//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct NetworkError: Swift.Error {
    /// The high-level classification of this error
    public let code: Code

    /// The HTTPRequest that resulted in this error
    public let request: HTTPRequest

    /// Any HTTPResponse (partial or otherwise) that we might have
    public let response: HTTPResponse

    /// If we have more information about the error that caused this, stash it here
    public let underlyingError: Swift.Error?

    internal init(code: NetworkError.Code, request: HTTPRequest, response: HTTPResponse, error: Swift.Error? = nil) {
        self.code = code
        self.request = request
        self.response = response
        self.underlyingError = error
    }
}

public extension NetworkError {
    enum Code {
        case invalidStatusCode
        case fallbackDecode

        case unknown
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .invalidStatusCode:
            return "Status code didn't fall within the given range."

        case .fallbackDecode:
            return "Decoding to RawResource failed, but FallbackResource was successful."

        case .unknown:
            return "Unknown error."
        }
    }
}
