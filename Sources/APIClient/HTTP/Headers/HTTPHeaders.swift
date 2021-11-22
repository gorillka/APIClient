
import Foundation

/// A representation of a block of HTTP header fields.
///
/// HTTP header fields are a complex data structure. The most natural representation
/// for these is a sequence of two-tuples of field name and field value, both as
/// strings. This structure preserves that representation, but provides a number of
/// convenience features in addition to it.
///
/// For example, this structure enables access to header fields based on the
/// case-insensitive form of the field name, but preserves the original case of the
/// field when needed. It also supports recomposing headers to a maximally joined
/// or split representation, such that header fields that are able to be repeated
/// can be represented appropriately.
public struct HTTPHeaders: CustomStringConvertible, ExpressibleByDictionaryLiteral {
    @usableFromInline
    internal var headers: [(String, String)]

    public var description: String {
        headers.description
    }

    internal var names: [String] {
        headers.map(\.0)
    }

    private var values: [String] { headers.map(\.1) }

    internal func isConnectionHeader(_ name: String) -> Bool {
        name.utf8.compareCaseInsensitiveASCIIBytes(to: "connection".utf8)
    }

    /// Construct a `HTTPHeaders` structure.
    ///
    /// - parameters
    ///     - headers: An initial set of headers to use to populate the header block.
    ///     - allocator: The allocator to use to allocate the underlying storage.
    public init(_ headers: [(String, String)] = []) {
        // Note: this initializer exists because of https://bugs.swift.org/browse/SR-7415.
        // Otherwise we'd only have the one below with a default argument for `allocator`.
        self.headers = headers
    }

    /// Construct a `HTTPHeaders` structure.
    ///
    /// - parameters
    ///     - elements: name, value pairs provided by a dictionary literal.
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init(elements)
    }

    /// Add a header name/value pair to the block.
    ///
    /// This method is strictly additive: if there are other values for the given header name
    /// already in the block, this will add a new entry.
    ///
    /// - Parameter name: The header field name. For maximum compatibility this should be an
    ///     ASCII string. For future-proofing with HTTP/2 lowercase header names are strongly
    ///     recommended.
    /// - Parameter value: The header field value to add for the given name.
    public mutating func add(name: String, value: String) {
        precondition(!name.utf8.contains(where: { !$0.isASCII }), "name must be ASCII")
        headers.append((name, value))
    }

    /// Add a sequence of header name/value pairs to the block.
    ///
    /// This method is strictly additive: if there are other entries with the same header
    /// name already in the block, this will add new entries.
    ///
    /// - Parameter contentsOf: The sequence of header name/value pairs. For maximum compatibility
    ///     the header should be an ASCII string. For future-proofing with HTTP/2 lowercase header
    ///     names are strongly recommended.
    @inlinable
    public mutating func add<S: Sequence>(contentsOf other: S) where S.Element == (String, String) {
        headers.reserveCapacity(headers.count + other.underestimatedCount)
        for (name, value) in other {
            add(name: name, value: value)
        }
    }

    /// Add another block of headers to the block.
    ///
    /// - Parameter contentsOf: The block of headers to add to these headers.
    public mutating func add(contentsOf other: HTTPHeaders) {
        headers.append(contentsOf: other.headers)
    }

    /// Add a header name/value pair to the block, replacing any previous values for the
    /// same header name that are already in the block.
    ///
    /// This is a supplemental method to `add` that essentially combines `remove` and `add`
    /// in a single function. It can be used to ensure that a header block is in a
    /// well-defined form without having to check whether the value was previously there.
    /// Like `add`, this method performs case-insensitive comparisons of the header field
    /// names.
    ///
    /// - Parameter name: The header field name. For maximum compatibility this should be an
    ///     ASCII string. For future-proofing with HTTP/2 lowercase header names are strongly
    //      recommended.
    /// - Parameter value: The header field value to add for the given name.
    public mutating func replaceOrAdd(name: String, value: String) {
        remove(name: name)
        add(name: name, value: value)
    }

    /// Remove all values for a given header name from the block.
    ///
    /// This method uses case-insensitive comparisons for the header field name.
    ///
    /// - Parameter name: The name of the header field to remove from the block.
    public mutating func remove(name nameToRemove: String) {
        headers.removeAll { name, _ in
            if nameToRemove.utf8.count != name.utf8.count {
                return false
            }

            return nameToRemove.utf8.compareCaseInsensitiveASCIIBytes(to: name.utf8)
        }
    }

    /// Retrieve all of the values for a give header field name from the block.
    ///
    /// This method uses case-insensitive comparisons for the header field name. It
    /// does not return a maximally-decomposed list of the header fields, but instead
    /// returns them in their original representation: that means that a comma-separated
    /// header field list may contain more than one entry, some of which contain commas
    /// and some do not. If you want a representation of the header fields suitable for
    /// performing computation on, consider `subscript(canonicalForm:)`.
    ///
    /// - Parameter name: The header field name whose values are to be retrieved.
    /// - Returns: A list of the values for that header field name.
    public subscript(name: String) -> [String] {
        headers.reduce(into: []) { target, lr in
            let (key, value) = lr
            if key.utf8.compareCaseInsensitiveASCIIBytes(to: name.utf8) {
                target.append(value)
            }
        }
    }

    /// Retrieves the first value for a given header field name from the block.
    ///
    /// This method uses case-insensitive comparisons for the header field name. It
    /// does not return the first value from a maximally-decomposed list of the header fields,
    /// but instead returns the first value from the original representation: that means
    /// that a comma-separated header field list may contain more than one entry, some of
    /// which contain commas and some do not. If you want a representation of the header fields
    /// suitable for performing computation on, consider `subscript(canonicalForm:)`.
    ///
    /// - Parameter name: The header field name whose first value should be retrieved.
    /// - Returns: The first value for the header field name.
    public func first(name: String) -> String? {
        guard !headers.isEmpty else {
            return nil
        }

        return headers.first { header in header.0.isEqualCaseInsensitiveASCIIBytes(to: name) }?.1
    }

    /// Checks if a header is present
    ///
    /// - parameters:
    ///     - name: The name of the header
    //  - returns: `true` if a header with the name (and value) exists, `false` otherwise.
    public func contains(name: String) -> Bool {
        for kv in headers {
            if kv.0.utf8.compareCaseInsensitiveASCIIBytes(to: name.utf8) {
                return true
            }
        }
        return false
    }

    /// Retrieves the header values for the given header field in "canonical form": that is,
    /// splitting them on commas as extensively as possible such that multiple values received on the
    /// one line are returned as separate entries. Also respects the fact that Set-Cookie should not
    /// be split in this way.
    ///
    /// - Parameter name: The header field name whose values are to be retrieved.
    /// - Returns: A list of the values for that header field name.
    public subscript(canonicalForm name: String) -> [Substring] {
        let result = self[name]

        guard !result.isEmpty else {
            return []
        }

        // It's not safe to split Set-Cookie on comma.
        guard name.lowercased() != "set-cookie" else {
            return result.map { $0[...] }
        }

        return result.flatMap { $0.split(separator: ",").map { $0.trimWhitespace() } }
    }
}

public extension HTTPHeaders {
    /// The total number of headers that can be contained without allocating new storage.
    var capacity: Int {
        self.headers.capacity
    }

    /// Reserves enough space to store the specified number of headers.
    ///
    /// - Parameter minimumCapacity: The requested number of headers to store.
    mutating func reserveCapacity(_ minimumCapacity: Int) {
        headers.reserveCapacity(minimumCapacity)
    }
}

extension HTTPHeaders: RandomAccessCollection {
    public typealias Element = (name: String, value: String)

    public struct Index: Comparable {
        fileprivate let base: Array<(String, String)>.Index
        public static func < (lhs: Index, rhs: Index) -> Bool {
            lhs.base < rhs.base
        }
    }

    public var startIndex: HTTPHeaders.Index {
        .init(base: headers.startIndex)
    }

    public var endIndex: HTTPHeaders.Index {
        .init(base: headers.endIndex)
    }

    public func index(before i: HTTPHeaders.Index) -> HTTPHeaders.Index {
        .init(base: headers.index(before: i.base))
    }

    public func index(after i: HTTPHeaders.Index) -> HTTPHeaders.Index {
        .init(base: headers.index(after: i.base))
    }

    public subscript(position: HTTPHeaders.Index) -> Element {
        headers[position.base]
    }
}

extension HTTPHeaders: Equatable {
    public static func == (lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
        guard lhs.headers.count == rhs.headers.count else {
            return false
        }
        let lhsNames = Set(lhs.names.map { $0.lowercased() })
        let rhsNames = Set(rhs.names.map { $0.lowercased() })
        guard lhsNames == rhsNames else {
            return false
        }

        for name in lhsNames {
            guard lhs[name].sorted() == rhs[name].sorted() else {
                return false
            }
        }

        return true
    }
}

extension HTTPHeaders: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(names)
        hasher.combine(values)
    }
}

extension Character {
    var isASCIIWhitespace: Bool {
        self == " " || self == "\t" || self == "\r" || self == "\n" || self == "\r\n"
    }
}

private extension UInt8 {
    var isASCII: Bool {
        self <= 127
    }
}

private extension Substring {
    func trimWhitespace() -> Substring {
        var me = self
        while me.first?.isASCIIWhitespace == .some(true) {
            me = me.dropFirst()
        }
        while me.last?.isASCIIWhitespace == .some(true) {
            me = me.dropLast()
        }
        return me
    }
}
