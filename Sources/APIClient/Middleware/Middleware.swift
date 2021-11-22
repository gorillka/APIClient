//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine

public protocol Middleware {
    func respond(to request: HTTPRequest, chainingTo next: Responder) -> AnyPublisher<HTTPResponse, Swift.Error>
}

public extension Array where Element == Middleware {
    func makeResponder(chainingTo responder: Responder) -> Responder {
        var responder = responder

        for middleware in reversed() {
            responder = middleware.makeResponder(chainingTo: responder)
        }

        return responder
    }
}

public extension Middleware {
    func makeResponder(chainingTo responder: Responder) -> Responder {
        HTTPMiddlewareResponder(middleware: self, responder: responder)
    }
}

private struct HTTPMiddlewareResponder: Responder {
    var middleware: Middleware
    var responder: Responder

    init(middleware: Middleware, responder: Responder) {
        self.middleware = middleware
        self.responder = responder
    }

    func respond(to request: HTTPRequest) -> AnyPublisher<HTTPResponse, Swift.Error> {
        middleware.respond(to: request, chainingTo: responder)
    }
}
