//
//  ZoneUpdateData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct ZoneUpdateData: Codable {
    let zoneTitle: String?
    let zoneSymbol: String?
    let centerLat: Double?
    let centerLng: Double?
    let locationAddress: String?
    let zoneRadius: Int?
    
    enum CodingKeys: String, CodingKey {
        case zoneTitle = "label"
        case zoneSymbol = "icon"
        case centerLat = "latitudeData"
        case centerLng = "longitudeData"
        case locationAddress = "addressLabel"
        case zoneRadius = "radiusData"
    }
}
