//
//  InviteInfo.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct InviteInfo: Codable, Identifiable {
    let id: Int
    let creationDate: String
    let modificationDate: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case creationDate = "created_at"
        case modificationDate = "updated_at"
        case code = "inviteCode"
    }
}
