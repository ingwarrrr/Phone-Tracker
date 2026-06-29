//
//  MemberInfo.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct MemberInfo: Codable, Identifiable, Hashable {
    let id: Int
    let creationDate: String?
    let lastUpdateDate: String?
    var displayName: String
    let batteryLevel: Int?
    let avatar: AssetInfo?
    var currentPosition: LocationData?
    let teamId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creationDate = "created_at"
        case lastUpdateDate = "updated_at"
        case displayName = "label"
        case batteryLevel = "batteryData"
        case avatar = "media"
        case currentPosition = "lastPosition"
        case teamId = "groupId"
    }
}
