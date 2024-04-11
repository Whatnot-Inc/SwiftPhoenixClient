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
        let channel = Channel(
            topic: "phoenix",
            socket: self
        )
        let heartbeat = Push(
            channel: channel,
            event: ChannelEvent.heartbeat,
            timeout: timeout
        )
            .receive("timeout") { [weak self] _ in
                self?.abnormalClose("manual heartbeat timeout (\(timeout))")
                _ = channel // retain channel for the lifetime of heartbeat
            }
            .receive("error") { [weak self] message in
                self?.abnormalClose("manual heartbeat error (\(message.payload))")
            }
        heartbeat.send()
    }
}
