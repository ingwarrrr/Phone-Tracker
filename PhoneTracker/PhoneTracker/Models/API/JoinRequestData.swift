//
//  JoinRequestData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct JoinRequestData: Codable {
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case code = "inviteCode"
    }
}
