//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine
import Foundation

public final class APIClient {
    // MARK: Public Properties

    public var middleware = Middlewares()

    // MARK: Private Properties

    private var store = Set<AnyCancellable>()
    private var taskProgress: [Int: AnyCancellable] = [:]
    private let configuration: Configurable

    private lazy var session = URLSession(
        configuration: configuration.configuration,
        delegate: configuration.delegate,
        delegateQueue: configuration.delegateQueue
    )

    private let networkMonitor = NetworkMonitor()

    // MARK: Inits

    public init(_ configuration: Configurable = Configuration.default) {
        self.configuration = configuration

        networkMonitor.startMonitoring()
    }

    deinit {
        networkMonitor.stopMonitoring()
    }

    // MARK: Public Methods

    public final func send<ResponseValue>(
        _ request: Request<ResponseValue>,
        progress: PassthroughSubject<Double, Never>? = nil
    ) -> AnyPublisher<ResponseValue, Swift.Error> {
        if !networkMonitor.isConnected {
            return Fail(error: HTTPError.noInternetConnection)
                .eraseToAnyPublisher()
        }

        let basicResponder = BasicResponder { [weak self] request in
            guard let self = self else { return Combine.Empty().eraseToAnyPublisher() }

            let urlRequest: URLRequest
            do {
                urlRequest = try URLRequest(request)
            } catch {
                return Combine.Fail(error: error).eraseToAnyPublisher()
            }

            let result = PassthroughSubject<HTTPResponse, Swift.Error>()
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    return result.send(completion: .failure(error))
                }

                guard let response = response as? HTTPURLResponse else {
                    return result.send(completion: .failure(HTTPError.noResponse))
                }

                let httpResponse = HTTPResponse(request: request, response: response, data: data)
                result.send(httpResponse)
                result.send(completion: .finished)
            }

            if let progress = progress {
                self.taskProgress[task.taskIdentifier] = self.configuration.delegate?
                    .progress
                    .filter { $0.id == task.taskIdentifier }
                    .map(\.progress)
                    .sink(receiveCompletion: progress.send, receiveValue: progress.send)
            }

            task.resume()
            return result
                .handleEvents(receiveCompletion: { [weak self] _ in
                    self?.taskProgress[task.taskIdentifier] = nil
                }, receiveCancel: { [weak self] in
                    task.cancel()
                    self?.taskProgress[task.taskIdentifier] = nil
                })
                .eraseToAnyPublisher()
        }

        return middleware
            .resolve()
            .makeResponder(chainingTo: basicResponder)
            .respond(to: request.underlyingRequest)
            .tryMap(request.decode)
            .eraseToAnyPublisher()
    }
}

public extension APIClient {
    func send<Value>(
        _ value: Value,
        progress: PassthroughSubject<Double, Never>? = nil
    ) -> AnyPublisher<Value.RawValue, Swift.Error>
        where Value: ResponseDecodable & RequestRepresentable,
        Value.RawValue: Decodable, Value.FallbackValue: Decodable
    {
        send(value.request(), progress: progress)
    }

    func send<Value>(
        _ value: Value,
        progress: PassthroughSubject<Double, Never>? = nil
    ) -> AnyPublisher<Value.RawValue, Swift.Error>
        where Value: ResponseDecodable & RequestRepresentable,
        Value.RawValue: Decodable
    {
        send(value.request(), progress: progress)
    }
}
