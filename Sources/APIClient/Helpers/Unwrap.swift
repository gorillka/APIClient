//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public struct Unwrap<Value: Decodable> {
    public let value: Value
}

extension Unwrap: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        let unwrapKey = decoder.userInfo[.unwrapKey] as? String

        if let unwrapKey = unwrapKey, !unwrapKey.isEmpty {
            guard let key = DynamicCodingKeys(stringValue: unwrapKey) else {
                throw HTTPError
                    .resourceExtractionError(
                        "Failed to unwrap type \(Value.self) from Unwrap response, couldn't find object with key \(unwrapKey)."
                    )
            }

            guard let decoded = try? container.decode(Value.self, forKey: key) else {
                throw HTTPError
                    .resourceExtractionError(
                        "Failed to unwrap type \(Value.self) from Unwrap response. Couldn't decode object for key \(unwrapKey)."
                    )
            }
            self.init(value: decoded)
        }

        let decodedObjects = container.allKeys.compactMap { key -> Value? in
            guard let key = DynamicCodingKeys(stringValue: key.stringValue) else {
                return nil
            }

            return try? container.decode(Value.self, forKey: key)
        }

        if decodedObjects.isEmpty {
            throw HTTPError
                .resourceExtractionError(
                    "Failed to unwrap type \(Value.self) from Unwrap response, couldn't decode any objects."
                )
        }

        guard decodedObjects.count == 1, let decoded = decodedObjects.first else {
            throw HTTPError
                .resourceExtractionError(
                    "Failed to unwrap type \(Value.self) from Unwrap response, decoded \(decodedObjects.count) objects where only 1 was expected. Try setting a `smartunwrapKey` to specify a single object."
                )
        }

        self.init(value: decoded)
    }
}

extension Unwrap {
    private struct DynamicCodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            nil
        }
    }
}
