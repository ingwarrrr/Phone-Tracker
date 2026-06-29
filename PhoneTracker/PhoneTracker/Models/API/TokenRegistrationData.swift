//
//  TokenRegistrationData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct TokenRegistrationData: Codable {
    let deviceToken: String
    
    enum CodingKeys: String, CodingKey {
        case deviceToken = "pushToken"
    }
}
