//
//  MemberAnnotation.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import MapKit

class PersonAnnotation: MKPointAnnotation {
    var personID: Int
    var batteryLevel: Int?
    var avatarURL: String?
    var person: MemberInfo
    var isCurrentUser: Bool = false
    
    init(person: MemberInfo, isCurrentUser: Bool = false) {
        self.personID = person.id
        self.person = person
        self.isCurrentUser = isCurrentUser
        
        if isCurrentUser && !UserDefaultsService().batteryTrackingEnabled {
            self.batteryLevel = 0
        } else {
            self.batteryLevel = person.batteryLevel
        }
        
        self.avatarURL = person.avatar?.url
        super.init()
        self.title = person.displayName
        
        if let coordinates = person.currentPosition?.coordinatesList, coordinates.count >= 2 {
            let latitude = coordinates[1]
            let longitude = coordinates[0]
            
            if CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            }
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
    func update(with person: MemberInfo) {
        self.batteryLevel = person.batteryLevel
        self.avatarURL = person.avatar?.url
        self.title = person.displayName
        
        if self.isCurrentUser && !UserDefaultsService().batteryTrackingEnabled {
            self.batteryLevel = 0
        }
        
        if let newCoordinates = person.currentPosition?.coordinatesList, newCoordinates.count >= 2 {
            let newCoordinate = CLLocationCoordinate2D(
                latitude: newCoordinates[1],
                longitude: newCoordinates[0]
            )
            
            UIView.animate(withDuration: 1.0) {
                self.coordinate = newCoordinate
            }
        }
    }
}
