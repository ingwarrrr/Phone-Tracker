//
//  ZoneAnnotation.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit

class ZoneAnnotation: MKPointAnnotation {
    var zone: ZoneInfo
    
    init(zone: ZoneInfo) {
        self.zone = zone
        super.init()
        self.title = zone.zoneName
        self.subtitle = zone.formattedAddress
        self.coordinate = CLLocationCoordinate2D(
            latitude: zone.boundaryCoordinates[1],
            longitude: zone.boundaryCoordinates[0]
        )
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
