//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation

/// All errors returned by HTTP.
public enum HTTPError: Swift.Error {
    case missingURL
    case wrongUsage(String)

    /// Something went wrong while encoding request parameters.
    case codingError(String)

    /// Something went wrong while decoding the response.
    case decodingError(Swift.Error, data: Data?)

    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(HTTPResponse)

    /// Decoding your `RawValue` type failed, but decoding to your `FallbackValue` was successful.
    case fallbackDecode(Decodable)

    case noResponse
    case noData
    case noInternetConnection
    
    /// Something went wrong while trying to parse response data.
    /// Throw this error if something goes wrong while calling Request.finalize().
    case resourceExtractionError(String)
    case failureDecode(Decodable)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingURL:
            return "Missing URL."

        case let .wrongUsage(message):
            return message

        case let .codingError(message):
            return "Coding error: \(message)."

        case let .decodingError(error, _):
            let message = "Decoding Error: \(error.localizedDescription)."

            guard let error = error as? DecodingError else {
                return message
            }

            return "\(message) \(error.description)."

        case .statusCode:
            return "Status code didn't fall within the given range."

        case .fallbackDecode:
            return "Decoding to RawResource failed, but FallbackResource was successful."

        case .noResponse:
            return "No response."

        case .noData:
            return "No data."
            
        case .noInternetConnection:
            return "Internet connection is not available"

        case let .resourceExtractionError(message):
            return "Resource Extraction Error: The raw result could not be turned into the final resource: \(message)."

        case let .failureDecode(decodable):
            return "Failure to decode \(decodable.self)."
        }
    }
}
