//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Foundation
import Logging

public protocol Configurable {
    var logger: Logger { get }
    var delegate: APIClientDelegate? { get }
    var delegateQueue: OperationQueue? { get }
    var timeout: Double { get }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    var encodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
}

public struct Configuration: Configurable {
    // MARK: Public Properties

    public let delegate: APIClientDelegate?
    public let logger: Logger
    public let timeout: TimeInterval
    public let decodingStrategy: JSONDecoder.KeyDecodingStrategy
    public let encodingStrategy: JSONEncoder.KeyEncodingStrategy

    // MARK: Inits

    public init(
        _ delegate: APIClientDelegate? = APIClientDelegate(),
        logger: Logger = Logger(label: "com.github.gorillka.APIClient"),
        timeout: TimeInterval = 60,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        encodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
    ) {
        self.delegate = delegate
        self.logger = logger
        self.timeout = timeout
        self.decodingStrategy = decodingStrategy
        self.encodingStrategy = encodingStrategy
    }
}

public extension Configurable {
    static var `default`: Configurable { Configuration() }

    var timeout: Double { 60 }
    var delegateQueue: OperationQueue? { nil }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
    var encodingStrategy: JSONEncoder.KeyEncodingStrategy { .useDefaultKeys }
}

extension Configurable {
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout

        return config
    }
}
