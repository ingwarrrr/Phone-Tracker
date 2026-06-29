//
//  LocationData.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct LocationData: Codable, Identifiable, Hashable {
    let id: Int
    let creationDate: String
    let modificationDate: String
    var coordinatesList: [Double]
    let associatedZone: ZoneInfo?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creationDate = "created_at"
        case modificationDate = "updated_at"
        case coordinatesList = "coords_data_array"
        case associatedZone = "zone"
    }
}
