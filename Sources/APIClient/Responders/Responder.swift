//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine

public protocol Responder {
    func respond(to request: HTTPRequest) -> AnyPublisher<HTTPResponse, Swift.Error>
}
