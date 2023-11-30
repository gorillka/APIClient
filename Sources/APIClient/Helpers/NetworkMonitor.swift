//
// Copyright © 2021. Georhii Kasilov
//
// MIT license, see LICENSE file for details
//

import Combine
import Foundation
import Network

final class NetworkMonitor {
    // MARK: Private Properties

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "networkMonitor.monitorQueue")

    // MARK: Lifecycle

    deinit {
        stopMonitoring()
    }

    // MARK: Public Methods

    func startMonitoring() {
        monitor.start(queue: monitorQueue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

extension NetworkMonitor {
    var isConnected: Bool { monitor.currentPath.status == .satisfied }

    var currentConnectionType: NWInterface.InterfaceType? {
        let path = monitor.currentPath

        return NWInterface.InterfaceType.allCases.first(where: { path.usesInterfaceType($0) })
    }
}
