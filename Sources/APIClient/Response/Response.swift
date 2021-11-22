//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

@frozen
public enum Response<Value> {
    case pending
    case executing(Double)
    case suspended(Double)
    case finished(Value)
    case cancelled
}

public extension Response {
    var value: Value? {
        switch self {
        case let .finished(value):
            return value

        default:
            return nil
        }
    }

    var progress: Double {
        switch self {
        case .pending,
             .cancelled:
            return 0

        case let .executing(value),
             let .suspended(value):
            return value

        case .finished:
            return 1
        }
    }
}

public extension Response {
    var isExecuting: Bool {
        switch self {
        case .executing:
            return true

        default:
            return false
        }
    }

    var isSuspended: Bool {
        switch self {
        case .suspended:
            return true

        default:
            return false
        }
    }

    var isFinished: Bool {
        switch self {
        case .finished,
             .cancelled:
            return true

        default:
            return false
        }
    }

    var isCancelled: Bool {
        switch self {
        case .cancelled:
            return true

        default:
            return false
        }
    }
}

public extension Response where Value == Void {
    func map() -> Response<Void> {
        map { _ in () }
    }
}

public extension Response {
    func map<NewValue>(_ transform: (Value) -> NewValue) -> Response<NewValue> {
        switch self {
        case .pending:
            return .pending

        case let .executing(value):
            return .executing(value)

        case let .suspended(value):
            return .suspended(value)

        case let .finished(value):
            return .finished(transform(value))

        case .cancelled:
            return .cancelled
        }
    }

    func flatMap<NewValue>(_ transform: (Value) -> Response<NewValue>) -> Response<NewValue> {
        switch self {
        case .pending:
            return .pending

        case let .executing(value):
            return .executing(value)

        case let .suspended(value):
            return .suspended(value)

        case let .finished(value):
            return transform(value)

        case .cancelled:
            return .cancelled
        }
    }
}

extension Response: Equatable where Value: Equatable {}
extension Response: Hashable where Value: Hashable {}
