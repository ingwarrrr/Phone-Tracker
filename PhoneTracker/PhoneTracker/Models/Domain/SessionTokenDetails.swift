//
//  SessionTokenDetails.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct SessionTokenDetails {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiryDate: Date
    
    var isExpired: Bool {
        return Date() >= accessTokenExpiryDate
    }
}
