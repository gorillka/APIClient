//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct DataBody: HTTPBody {
    public var isEmpty: Bool { data.isEmpty }
    public let additionalHeaders: HTTPHeaders

    private let data: Data

    public init(_ data: Data, additionalHeaders: HTTPHeaders = .init()) {
        self.data = data
        self.additionalHeaders = additionalHeaders
    }

    public func encode() throws -> Data { data }
}
