//
//  MemberRemovalData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct MemberRemovalData: Codable {
    let targetUserId: Int
    
    enum CodingKeys: String, CodingKey {
        case targetUserId = "userId"
    }
}
