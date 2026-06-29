//
//  UserLabelUpdate.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct UserLabelUpdate: Codable {
    let customName: String
    
    enum CodingKeys: String, CodingKey {
        case customName = "customUserLabel"
    }
}
