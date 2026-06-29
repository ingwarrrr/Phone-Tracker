//
//  AuthTokens.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct AuthTokens: Codable {
    let accessToken: String?
    let accessExpiry: String?
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access"
        case accessExpiry = "accessExpiresAt"
        case refreshToken = "refresh"
    }
}
