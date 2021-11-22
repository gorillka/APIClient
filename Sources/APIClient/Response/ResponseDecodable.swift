//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

public protocol ResponseDecodable {
    associatedtype RawValue: Any
    associatedtype FinalValue: Any = RawValue
    associatedtype FallbackValue: Any = AnyObject

    var unwrapKey: String { get }
    var decoder: JSONDecoder? { get }

    func decode(_ response: HTTPResponse, decoder: JSONDecoder) throws -> RawValue

    func finalize(rawValue: RawValue) throws -> FinalValue
}

public extension ResponseDecodable {
    var unwrapKey: String { "" }
    var decoder: JSONDecoder? { nil }

    func decode(_ response: HTTPResponse) throws -> RawValue {
        try decode(response, decoder: decoder ?? JSONDecoder())
    }
}

public extension ResponseDecodable where FinalValue == RawValue {
    func finalize(rawValue: RawValue) throws -> FinalValue { rawValue }
}

public extension ResponseDecodable where RawValue: Decodable {
    func decode(_ response: HTTPResponse, decoder: JSONDecoder) throws -> RawValue {
        let decoder = self.decoder ?? decoder
        let data: Data
        if RawValue.self == Empty.self {
            data = Empty.data
        } else {
            data = response.body
        }

        do {
            return try decoder.decode(RawValue.self, from: data)
        } catch {
            throw HTTPError.decodingError(error, data: response.body)
        }
    }
}

public extension ResponseDecodable where RawValue == Data {
    func decode(_ response: HTTPResponse, decoder: JSONDecoder) throws -> RawValue { response.body }
}

public extension ResponseDecodable where RawValue == Unwrap<FinalValue> {
    func decode(_ data: Data, decoder: JSONDecoder) throws -> FinalValue {
        let decoder = self.decoder ?? decoder
        decoder.userInfo = [.unwrapKey: unwrapKey]

        do {
            let unwrapResult = try decoder.decode(Unwrap<FinalValue>.self, from: data)
            return try finalize(rawValue: unwrapResult)
        } catch {
            throw HTTPError.decodingError(error, data: data)
        }
    }

    func finalize(rawValue: RawValue) throws -> FinalValue { rawValue.value }
}
