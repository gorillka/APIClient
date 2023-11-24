//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

extension DecodingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let DecodingError.dataCorrupted(context):
            return "Data Corrupt: \(context.debugDescription) \(context.codingPathDescription)"
        case let DecodingError.keyNotFound(key, context):
            return "Key \(key) not found: \(context.debugDescription) \(context.codingPathDescription)"
        case let DecodingError.valueNotFound(value, context):
            return "Value \(value) not found: \(context.debugDescription) \(context.codingPathDescription)"
        case let DecodingError.typeMismatch(type, context):
            return "Type \(type) mismatch: \(context.debugDescription) \(context.codingPathDescription)"
        default:
            return localizedDescription
        }
    }
}

extension DecodingError.Context {
    var codingPathDescription: String {
        // Drop first "Index 0" coding key as it's not helpful for describing the coding path
        let stringValues = codingPath.dropFirst().map(\.stringValue).joined(separator: ", ")
        return "Path: " + stringValues
    }
}
