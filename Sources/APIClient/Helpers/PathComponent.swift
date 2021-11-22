//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public enum PathComponent {
    case path(String)
    case parameter(key: String, value: String)
}

private extension PathComponent {
    var isPathComponent: Bool {
        switch self {
        case .path:
            return true

        case .parameter:
            return false
        }
    }

    var isParameter: Bool {
        switch self {
        case .path:
            return false

        case .parameter:
            return true
        }
    }
}

extension PathComponent: Equatable {
    public static func == (lhs: PathComponent, rhs: PathComponent) -> Bool {
        lhs.description == rhs.description
    }
}

// MARK: - ExpressibleByStringLiteral

extension PathComponent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let components = value.split(separator: "=")

        if components.count == 2, let key = components.first, let value = components.last {
            self = .parameter(key: String(key), value: String(value))
        } else {
            self = .path(value)
        }
    }
}

// MARK: - CustomStringConvertible

extension PathComponent: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .path(path):
            return path

        case let .parameter(key, value):
            return "\(key)=\(value)"
        }
    }
}

public extension String {
    /// Converts a string into `[PathComponent]`.
    var pathComponents: [PathComponent] {
        let components = split(separator: "?")
        var pathComponents: [String] = []

        if components.count == 2 {
            let paths = components.first?
                .split(separator: "/") ?? []
            let parameters = components.last?
                .split(separator: "&") ?? []
            pathComponents = (paths + parameters).map(String.init)
        } else if let first = components.first {
            if first.contains("/") {
                pathComponents = first.split(separator: "/").map(String.init)
            } else if first.contains("&") {
                pathComponents = first.split(separator: "&").map(String.init)
            }
        }

        return pathComponents
            .filter { !$0.isEmpty }
            .map(PathComponent.init)
    }
}

public extension Sequence where Element == PathComponent {
    /// Converts an array of ``PathComponent`` into a readable path string.
    ///
    ///     galaxies?page=1&size=10
    ///
    var string: String {
        [
            filter(\.isPathComponent).map(\.description).joined(separator: "/"),
            filter(\.isParameter).map(\.description).joined(separator: "&"),
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "?")
    }

    var path: [PathComponent] { filter(\.isPathComponent) }
    var query: [PathComponent] { filter(\.isParameter) }
}
