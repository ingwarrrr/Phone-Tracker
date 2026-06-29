//
//  AuthAdapter.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct SessionInfo: Codable {
    let tokens: AuthTokens?
    let profile: LoginResponse?
    
    enum CodingKeys: String, CodingKey {
        case tokens = "tokensValues"
        case profile = "user"
    }
}
