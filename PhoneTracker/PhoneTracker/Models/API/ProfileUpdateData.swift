//
//  ProfileUpdateData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct ProfileUpdateData: Codable {
    let displayName: String
    let batteryLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "label"
        case batteryLevel = "batteryData"
    }
}
