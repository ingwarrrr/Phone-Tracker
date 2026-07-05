//
//  HistoryPointAnnotation.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit

class HistoryPointAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String? = nil
    var subtitle: String? = nil
    
    override init() {
        self.coordinate = kCLLocationCoordinate2DInvalid
        super.init()
    }
}
