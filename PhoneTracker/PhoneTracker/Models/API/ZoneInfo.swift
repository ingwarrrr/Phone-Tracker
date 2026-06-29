//
//  ZoneInfo.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct ZoneInfo: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let creationDate: String
    let modificationDate: String
    var zoneName: String
    var zoneIcon: String
    let creatorId: Int
    var boundaryCoordinates: [Double]
    var formattedAddress: String
    var radius: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case creationDate = "created_at"
        case modificationDate = "updated_at"
        case zoneName = "label"
        case zoneIcon = "icon"
        case creatorId = "userId"
        case boundaryCoordinates = "coords_data_array"
        case formattedAddress = "addressLabel"
        case radius = "radiusData"
    }
}
