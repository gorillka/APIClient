//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct JSONBody: HTTPBody {
    public var additionalHeaders: HTTPHeaders = {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return headers
    }()

    private let encodeHandler: () throws -> Data

    public init<Value: Encodable>(_ value: Value, encoder: JSONEncoder = .init()) {
        self.encodeHandler = { try encoder.encode(value) }
    }

    public func encode() throws -> Data { try encodeHandler() }
}
