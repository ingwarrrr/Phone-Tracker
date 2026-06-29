//
//  FirebaseAuthData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct FirebaseAuthData: Codable {
    let firebaseJwt: String
    
    enum CodingKeys: String, CodingKey {
        case firebaseJwt = "auth_jwt_firebase"
    }
}
