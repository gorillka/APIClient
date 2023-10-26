//
// Copyright © 2021. Georhii Kasilov
//
// MIT license, see LICENSE file for details
//

import Combine
import Foundation
import Network

public final class NetworkMonitor: ObservableObject {
    // MARK: Public Properties

    @Published private(set) var path: NWPath?

    static let shared = NetworkMonitor()

    // MARK: Private Properties

    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "networkMonitor.monitorQueue")

    private init() {
        self.monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.path = path
        }

        monitor.start(queue: monitorQueue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

public extension NetworkMonitor {
    var isConnected: Bool { path?.status == .satisfied }

    var currentConnectionType: NWInterface.InterfaceType? {
        guard let path = path else { return nil }

        return NWInterface.InterfaceType.allCases.first(where: { path.usesInterfaceType($0) })
    }
}
