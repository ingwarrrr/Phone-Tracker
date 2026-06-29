//
//  RemoteNotificationPayload.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import SwiftUI

struct RemoteNotificationPayload {
    let alertTitle: String
    let alertBody: String
    let receivedAt: Date
    let type: PushType
    let autoDismissEnabled: Bool
}
