//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

@frozen
public enum HTTPMethod {
    case get, delete
    case post, put, patch
    case custom(_ value: String)
}

extension HTTPMethod {
    enum HasBody {
        case yes, no, unlikely
    }

    var hasRequestBody: HasBody {
        switch self {
        case .post,
             .put,
             .patch:
            return .yes

        case .get,
             .delete:
            fallthrough

        default:
            return .unlikely
        }
    }
}

extension HTTPMethod: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        switch value.uppercased() {
        case HTTPMethod.get.description:
            self = .get

        case HTTPMethod.delete.description:
            self = .delete

        case HTTPMethod.post.description:
            self = .post

        case HTTPMethod.put.description:
            self = .put

        case HTTPMethod.patch.description:
            self = .patch

        default:
            self = .custom(value)
        }
    }
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        switch self {
        case .get:
            return "GET"

        case .delete:
            return "DELETE"

        case .post:
            return "POST"

        case .put:
            return "PUT"

        case .patch:
            return "PATCH"

        case let .custom(value):
            return value.uppercased()
        }
    }
}

extension HTTPMethod: CustomDebugStringConvertible {
    public var debugDescription: String { description }
}

extension HTTPMethod: Hashable {}
