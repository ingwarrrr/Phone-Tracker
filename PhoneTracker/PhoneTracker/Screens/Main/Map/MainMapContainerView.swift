//
//  MainMapContainerView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit

struct MainMapContainerView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @Binding var mode: MapMode
    
    @Binding var currentUser: MemberInfo?
    @Binding var previewZone: ZoneInfo?
    @Binding var previewHistory: MemberInfo?
    @Binding var selectedHistoryPosition: LocationData?
    
    @Binding var people: [MemberInfo]
    var zones: [ZoneInfo] = []
    var personHistory: [LocationData] = []
    
    var body: some View {
        UnifiedMapView(
            region: $region,
            mapType: $mapType,
            mode: $mode,
            currentUser: $currentUser,
            previewZone: $previewZone,
            previewHistory: $previewHistory,
            selectedHistoryPosition: $selectedHistoryPosition,
            people: $people,
            zones: zones,
            peopleHistory: personHistory
        )
        .edgesIgnoringSafeArea(.top)
    }
}
