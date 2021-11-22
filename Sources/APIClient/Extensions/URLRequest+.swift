//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

extension URLRequest {
    init(_ request: HTTPRequest) throws {
        guard let url = URL(string: request.string) else {
            throw HTTPError.missingURL
        }

        self.init(url: url)
        self.httpMethod = request.method.description

        if request.method.hasRequestBody == .yes {
            self.httpBody = try request.body.encode()
        }
        request
            .headers
            .forEach { setValue($0.value, forHTTPHeaderField: $0.name) }
    }
}
