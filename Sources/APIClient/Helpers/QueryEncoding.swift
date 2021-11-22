//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct QueryEncoding {
    private let arrayEncoding: ArrayEncoding
    private let boolEncoding: BoolEncoding
    private let encodingKeyStrategy: JSONEncoder.KeyEncodingStrategy

    internal init(
        arrayEncoding: QueryEncoding.ArrayEncoding = .noBrackets,
        boolEncoding: QueryEncoding.BoolEncoding = .numeric,
        encodingKeyStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
    ) {
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
        self.encodingKeyStrategy = encodingKeyStrategy
    }

    internal func encode(_ encodable: Encodable) throws -> [PathComponent] {
        let params = try encodable
            .convertToDictionary(encodingKeyStrategy)

        return params
            .keys
            .sorted(by: <)
            .flatMap { queryComponents(from: $0, value: params[$0]!) }
            .map(PathComponent.parameter)
    }

    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    private func queryComponents(from key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(from: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(from: arrayEncoding.encode(key), value: value)
            }
        } else if let value = value as? NSNumber {
            value.isBool
                ? components.append((escape(key), escape(boolEncoding.encode(value: value.boolValue))))
                : components.append((escape(key), escape("\(value)")))
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    private func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
    }
}

public extension QueryEncoding {
    /// Encoding to use for `Bool` values.
    enum BoolEncoding {
        /// Encodes `true` as `1`, `false` as `0`.
        case numeric
        /// Encodes `true` as "true", `false` as "false". This is the default encoding.
        case literal

        /// Encodes the given `Bool` as a `String`.
        ///
        /// - Parameter value: The `Bool` to encode.
        ///
        /// - Returns:         The encoded `String`.
        func encode(value: Bool) -> String {
            switch self {
            case .numeric:
                return value ? "1" : "0"

            case .literal:
                return value ? "true" : "false"
            }
        }
    }

    /// Encoding to use for `Array` values.
    enum ArrayEncoding {
        /// An empty set of square brackets ("[]") are appended to the key for every value. This is the default encoding.
        case brackets
        /// No brackets are appended to the key and the key is encoded as is.
        case noBrackets

        /// Encodes the key according to the encoding.
        ///
        /// - Parameter key: The `key` to encode.
        /// - Returns:       The encoded key.
        func encode(_ key: String) -> String {
            switch self {
            case .brackets: return "\(key)[]"
            case .noBrackets: return key
            }
        }
    }
}

private extension Encodable {
    func convertToDictionary(_ strategy: JSONEncoder.KeyEncodingStrategy) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = strategy

        let json: Any
        do {
            let paramsData = try encoder.encode(self)
            json = try JSONSerialization.jsonObject(with: paramsData)
        } catch {
            throw HTTPError.codingError(error.localizedDescription)
        }

        guard let params = json as? [String: Any] else {
            throw HTTPError.codingError("Failed to unwrap parameter dictionary")
        }

        return params
    }
}

private extension NSNumber {
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    static let afURLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#{}@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}
