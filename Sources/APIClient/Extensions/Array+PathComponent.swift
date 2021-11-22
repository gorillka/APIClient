//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public extension Array where Element == PathComponent {
    mutating func append(
        _ encodable: Encodable,
        arrayEncoding: QueryEncoding.ArrayEncoding = .noBrackets,
        boolEncoding: QueryEncoding.BoolEncoding = .numeric,
        encodingKeyStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
    ) throws {
        let encoder = QueryEncoding(
            arrayEncoding: arrayEncoding,
            boolEncoding: boolEncoding,
            encodingKeyStrategy: encodingKeyStrategy
        )
        self += try encoder.encode(encodable)
    }
}
