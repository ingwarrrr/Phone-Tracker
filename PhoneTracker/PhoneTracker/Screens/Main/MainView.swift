//
//  MainView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit
import Factory

struct MainView: View {
    @StateObject private var mainVM = MainViewModel()
    @StateObject private var peopleVM = PeopleViewModel()
    @StateObject private var zonesVM = ZonesViewModel()
    @StateObject private var historyVM = HistoryViewModel()
    @StateObject private var settingsVM = SettingsViewModel()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var mapType: MKMapType = .standard
    @State private var currentMapMode: MapMode = .members
    
    @State private var selectedTab: NavigationTab? = .members
    @State private var tapSettings = false
    @State private var showOffer = false
    @State private var showSOSView = false
    @State private var showPushView = false
    @State private var sosViewType: SOSViewType = .noPeople
    @State private var currentNotification: RemoteNotificationPayload?
    
    @InjectedObject(\.remoteConfigService) private var remoteConfigService
    
    private var shouldShowSendingSOS: Bool {
        let otherUsersCount = peopleVM.users.filter { user in
            user.id != peopleVM.currentUser?.id
        }.count
        return otherUsersCount > 0
    }
    
    private var shouldHideControls: Bool {
        switch selectedTab {
        case .members:
            return (peopleVM.isExpanded && peopleVM.hasPeople) || peopleVM.hasSubviewsActive
        case .zones:
            return zonesVM.isExpanded
        case .history:
            return (historyVM.isExpanded && peopleVM.hasPeople) && !historyVM.showHistoryCompactView
        case .none:
            return false
        }
    }
    
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.height <= 667
    }
    
    private var previewZone: Binding<ZoneInfo?> {
        Binding(
            get: { zonesVM.editingZone ?? zonesVM.temporaryZone },
            set: {
                if zonesVM.isCreatingNewZone {
                    zonesVM.temporaryZone = $0
                } else {
                    zonesVM.editingZone = $0
                }
            }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                MainMapContainerView(
                    region: $region,
                    mapType: $mapType,
                    mode: $currentMapMode,
                    currentUser: $peopleVM.currentUser,
                    previewZone: previewZone,
                    previewHistory: $historyVM.viewedHistory,
                    selectedHistoryPosition: $historyVM.selectedHistoryPosition,
                    people: $peopleVM.users,
                    zones: zonesVM.zones,
                    personHistory: historyVM.filteredHistoryLocations
                )
                
                ControlsView(
                    tapSettings: $tapSettings,
                    shouldHideControls: shouldHideControls,
                    onLayersTap: {
                        changeMapType()
                    },
                    onSOSTap: {
                        centerMapOnUserLocation()
                        sosViewType = shouldShowSendingSOS ? .sending : .noPeople
                        showSOSView = true
                    },
                    onLocationTap: {
                        centerMapOnUserLocation()
                    }
                )
                
                TabContentView(
                    selectedTab: $selectedTab,
                    region: $region,
                    showOffer: $showOffer,
                    peopleVM: peopleVM,
                    zonesVM: zonesVM,
                    historyVM: historyVM
                )
                
                Rectangle()
                    .fill(AppColors.mainBG)
                    .frame(height: 30)
                    .background(AppColors.mainBG)
                
                MainTabBar(selectedTab: $selectedTab, onTab: { tab in
                    handleTabSelection(tab)
                })
                
                if historyVM.showDatePicker {
                    FullScreenCalendarView(
                        selectedDate: $historyVM.selectedDate,
                        onDismiss: {
                            historyVM.showDatePicker = false
                        },
                        onDateSelected: { date in
                            historyVM.onDateSelected(date)
                            historyVM.showDatePicker = false
                        }
                    )
                }
                
                notificationView
            }
        }
        .onAppear {
            setupNotificationObservers()
        }
        .fullScreenCover(isPresented: $tapSettings) {
            SettingsView(settingsVM: settingsVM)
        }
        .fullScreenCover(isPresented: $showOffer) {
            let ifFlowOne = remoteConfigService.appFlow == .flowOne
            let showCloseBtn = ifFlowOne ? true : remoteConfigService.showCloseBtn
            
            OfferSecondView(showDismissBTN: showCloseBtn, isFlowFirst: ifFlowOne) {
                showOffer = false
            }
        }
        .fullScreenCover(isPresented: $showSOSView) {
            SOSView(isPresented: $showSOSView, type: $sosViewType)
        }
        .onChange(of: historyVM.shouldSwitchToPeopleTab) { _, newValue in
            if newValue {
                selectedTab = .members
                withAnimation {
                    peopleVM.showInviteView = true
                }
                historyVM.shouldSwitchToPeopleTab = false
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            updateMapMode(for: newValue)
        }
    }
    
    private var notificationView: some View {
        VStack {
            NotificationView(
                showNotification: $showPushView,
                notificationData: currentNotification
            )
            .padding(.horizontal, 4)
            
            Spacer()
        }
    }
    
    private func centerMapOnUserLocation() {
        guard let userLocation = mainVM.locationService.lastKnownCoordinate else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: userLocation,
                span: region.span
            )
        }
    }
    
    private func changeMapType() {
        switch mapType {
        case .standard:
            mapType = .hybrid
        case .hybrid:
            mapType = .satellite
        case .satellite:
            mapType = .standard
        default:
            mapType = .standard
        }
    }
    
    private func handleTabSelection(_ tab: NavigationTab) {
        if selectedTab == tab {
            selectedTab = nil
        } else {
            selectedTab = tab
        }
    }
    
    private func updateMapMode(for tab: NavigationTab?) {
        switch tab {
        case .members:
            currentMapMode = .members
        case .zones:
            currentMapMode = .zones
        case .history:
            currentMapMode = .history
        case .none:
            currentMapMode = .members
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .showOverlayAlert,
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo,
               let notificationData = userInfo["notification"] as? RemoteNotificationPayload {
                showNotification(with: notificationData)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .profileDidDelete,
            object: nil,
            queue: .main
        ) { _ in
            Task {
                await resetVMs()
                
                await peopleVM.performInitial()
                
                await MainActor.run {
                    selectedTab = .members
                    tapSettings = false
                    peopleVM.isExpandedByTap = false
                    peopleVM.isExpandedByTap = true
                }
            }
        }
    }
    
    private func resetVMs() {
        peopleVM.resetPeople()
        zonesVM.resetZones()
        historyVM.resetHistory()
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .profileDidDelete, object: nil)
        NotificationCenter.default.removeObserver(self, name: .showOverlayAlert, object: nil)
    }
    
    private func showNotification(with data: RemoteNotificationPayload) {
        currentNotification = data
        
        if showPushView {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showPushView = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showPushView = true
                }
            }
        } else {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showPushView = true
            }
        }
    }
}
