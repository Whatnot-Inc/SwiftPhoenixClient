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

        // Make channel with Socket API to receive messages.
        // The "phoenix" channel must not be joined or left.
        // When done using channel – make sure to remove it from the channels list.
        let channel = channel("phoenix")

        let heartbeat = Push(
            channel: channel,
            event: ChannelEvent.heartbeat,
            timeout: timeout
        )
            .receive("ok") { [weak self] _ in
                self?.channels.removeAll { $0 === channel }
            }
            .receive("error") { [weak self] message in
                self?.channels.removeAll { $0 === channel }
                self?.abnormalClose("manual heartbeat error (\(message.payload))")
            }
            .receive("timeout") { [weak self] _ in
                self?.channels.removeAll { $0 === channel }
                self?.abnormalClose("manual heartbeat timeout (\(timeout))")
            }
        
        // Channel that is not joined won't allow sending messages.
        // Send the heartbeat directly instead.
        heartbeat.send()
    }
}
