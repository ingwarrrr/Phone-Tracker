//
//  GeoIPDetails.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import SwiftUI
import MapKit

struct GeoIPDetails: Codable {
    let ip: String?
    let hostname: String?
    let cityName: String?
    let regionName: String?
    let countryName: String?
    let latitude: Double?
    let longitude: Double?
    let organization: String?
    let postalCode: String?
    let timezone: String?
    
    var locationCoordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
