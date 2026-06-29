//
//  ZoneCreationData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct ZoneCreationData: Codable {
    let title: String
    let symbol: String
    let lat: Double?
    let lng: Double?
    let addressTitle: String?
    let radius: Int?
    
    enum CodingKeys: String, CodingKey {
        case title = "label"
        case symbol = "icon"
        case lat = "latitudeData"
        case lng = "longitudeData"
        case addressTitle = "addressLabel"
        case radius = "radiusData"
    }
}
