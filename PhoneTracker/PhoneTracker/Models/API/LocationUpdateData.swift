//
//  LocationUpdateData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct LocationUpdateData: Codable {
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case latitude = "latitudeData"
        case longitude = "longitudeData"
    }
}
