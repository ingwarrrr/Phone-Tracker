//
//  TabContentView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 22.03.2026.
//

import SwiftUI
import MapKit

struct TabContentView: View {
    @Binding var selectedTab: NavigationTab?
    @Binding var region: MKCoordinateRegion
    @Binding var showOffer: Bool
    @ObservedObject var peopleVM: PeopleViewModel
    @ObservedObject var zonesVM: ZonesViewModel
    @ObservedObject var historyVM: HistoryViewModel
    
    var body: some View {
        ZStack {
            if let selectedTab = selectedTab {
                switch selectedTab {
                case .members:
                    PeopleView(peopleVM: peopleVM, region: $region, showOffer: $showOffer)
                        .id(NavigationTab.members)
                case .zones:
                    ZonesView(zonesVM: zonesVM, region: $region, showOffer: $showOffer)
                        .id(NavigationTab.zones)
                case .history:
                    HistoryView(historyVM: historyVM, region: $region, showOffer: $showOffer)
                        .id(NavigationTab.history)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
    }
}
