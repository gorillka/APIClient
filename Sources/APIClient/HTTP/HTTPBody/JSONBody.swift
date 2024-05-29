//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct JSONBody: HTTPBody {
    public let additionalHeaders: HTTPHeaders
    private let encodeHandler: () throws -> Data

    public init<Value: Encodable>(
        _ value: Value,
        additionalHeaders: HTTPHeaders = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.additionalHeaders = additionalHeaders
        self.encodeHandler = { try encoder.encode(value) }
    }

    public func encode() throws -> Data { try encodeHandler() }
}
