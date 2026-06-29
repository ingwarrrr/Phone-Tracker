//
//  GroupUpdateData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct GroupUpdateData: Codable {
    let groupName: String
    
    enum CodingKeys: String, CodingKey {
        case groupName = "label"
    }
}
