//
//  File.swift
//
//
//  Created by Georhii Kasilov on 26.10.2023.
//

import Foundation
import Network

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet,
    ]
}
