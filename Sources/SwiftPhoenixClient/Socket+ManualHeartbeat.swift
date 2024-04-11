//
//  Socket+ManualHeartbeat.swift
//  SwiftPhoenixClient
//
//  Created by Daniel Garbien on 11/4/24.
//  Copyright © 2024 SwiftPhoenixClient. All rights reserved.
//

import Foundation

public extension Socket {
    func sendManualHeartbeat(timeout: TimeInterval) {
        guard isConnected else {
            return
        }
        let heartbeat = makeHeartbeat(
            timeout: timeout
        )
            .receive("timeout") { [weak self] _ in
                self?.abnormalClose("manual heartbeat timeout (\(timeout))")
            }
            .receive("error") { [weak self] message in
                self?.abnormalClose("manual heartbeat error (\(message.payload))")
            }
        heartbeat.send()
    }
}

private extension Socket {
    func makeHeartbeat(timeout: TimeInterval) -> Push {
        Push(
            channel: Channel(
                topic: "phoenix",
                socket: self
            ),
            event: ChannelEvent.heartbeat,
            timeout: timeout
        )
    }
}
