//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine

/// A basic, closure-based ``Responder``.
public struct BasicResponder: Responder {
    /// The stored responder closure.
    private let closure: (HTTPRequest) throws -> AnyPublisher<HTTPResponse, Swift.Error>

    /// Create a new ``BasicResponder``.
    ///
    /// - Parameter closure: Responder closure.
    public init(closure: @escaping (HTTPRequest) throws -> AnyPublisher<HTTPResponse, Swift.Error>) {
        self.closure = closure
    }

    /// See ``Responder``.
    public func respond(to request: HTTPRequest) -> AnyPublisher<HTTPResponse, Swift.Error> {
        do {
            return try closure(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
