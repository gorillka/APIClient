//
// Copyright © 2021. Orynko Artem
//
// MIT license, see LICENSE file for details
//

import Combine
import Foundation

open class APIClientDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    typealias TaskProgress = (id: Int, progress: Double)

    // MARK: Public Properties

    var progress: AnyPublisher<TaskProgress, Never> { progressSubject.eraseToAnyPublisher() }

    // MARK: Private Properties

    private let progressSubject = PassthroughSubject<TaskProgress, Never>()

    // MARK: - URLSessionTaskDelegate

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        progressSubject
            .send((task.taskIdentifier, task.progress.fractionCompleted))
    }
}
