//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

public struct Middlewares {
    public enum Position {
        case beginning
        case end
    }

    private var storage: [Middleware]

    public init() {
        self.storage = []
    }

    public mutating func use(_ middleware: Middleware, at position: Position = .end) {
        switch position {
        case .beginning:
            storage.append(middleware)
        case .end:
            storage.insert(middleware, at: 0)
        }
    }

    public mutating func use(_ middlewares: [Middleware]) {
        storage.append(contentsOf: middlewares)
    }

    internal func resolve() -> [Middleware] { storage }
}
