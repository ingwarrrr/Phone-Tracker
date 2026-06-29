//
//  LoginResponse.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct LoginResponse: Codable {
    let accountId: Int
    let accountName: String
    
    enum CodingKeys: String, CodingKey {
        case accountId = "userId"
        case accountName = "userName"
    }
}
