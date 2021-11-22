//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public protocol HTTPBody {
    var isEmpty: Bool { get }
    var additionalHeaders: HTTPHeaders { get }

    func encode() throws -> Data
}

public extension HTTPBody {
    var isEmpty: Bool { false }
    var additionalHeaders: HTTPHeaders { .init() }
}

// MARK: - Empty HTTPBody

extension Empty: HTTPBody {
    public var isEmpty: Bool { true }

    public func encode() throws -> Data { Empty.data }
}
