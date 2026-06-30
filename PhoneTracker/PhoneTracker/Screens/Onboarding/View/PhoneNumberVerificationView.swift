//
//  PhoneNumberVerificationView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import Combine
import MapKit
import Lottie
import Factory

struct PhoneNumberVerificationView: View {
    @Injected(\.userDefaultsService) private var userDefaultsService
    @Injected(\.networkService) private var networkService
    @State private var showVerificationPopup = false
    @State private var showVerifiedBadge = false
    @State private var verificationStatus: VerificationStage = .dispatchingRequest
    @State private var mapZoomLevel: Double = 2
    @State private var mapRegion: MKCoordinateRegion
    
    var onVerificationComplete: () -> Void

    init(onVerificationComplete: @escaping () -> Void) {
        self.onVerificationComplete = onVerificationComplete
        
        let initialSpan: Double = 0.1
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(),
            span: MKCoordinateSpan(
                latitudeDelta: initialSpan,
                longitudeDelta: initialSpan
            )
        )
        _mapRegion = State(initialValue: initialRegion)
    }
    
    var body: some View {
        ZStack {
            PhoneNumberMapView(
                region: $mapRegion,
                verticalOffsetPercent: 0
            )
            .ignoresSafeArea()
            
            AnimatingView(name: AssetCatalog.onboardingVideoB)
                .ignoresSafeArea()
            
            PhoneNumberPopup(
                showPopup: $showVerificationPopup,
                verificationStatus: $verificationStatus
            )
        }
        .animation(.easeInOut(duration: 0.3), value: verificationStatus)
        .onAppear {
            showVerificationPopup = true
            startVerificationProcess()
        }
        .onChange(of: mapZoomLevel) { newZoomLevel in
            updateMapRegion(with: newZoomLevel)
        }
        .onChange(of: verificationStatus) { newStatus in
            handleStatusChange(newStatus)
        }
        .onChange(of: showVerifiedBadge) { newState in
            if newState {
                onVerificationComplete()
                userDefaultsService.hasCompletedOnboarding = true
            }
        }
    }
    
    private func updateMapRegion(with zoomLevel: Double) {
        let baseSpan: Double = 0.1
        let zoomedSpan = baseSpan / zoomLevel
        
            mapRegion = MKCoordinateRegion(
                center: networkService.currentMapCoordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: zoomedSpan,
                    longitudeDelta: zoomedSpan
                )
            )
    }
    
    private func startVerificationProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            verificationStatus = .fetchingDetails
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            verificationStatus = .decodingPayload
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            verificationStatus = .confirmedSuccess
        }
    }
    
    private func handleStatusChange(_ newStatus: VerificationStage) {
        switch newStatus {
        case .dispatchingRequest, .fetchingDetails, .decodingPayload:
            withAnimation(.easeIn(duration: 1.0)) {
                mapZoomLevel *= 2.0
            }
        case .confirmedSuccess:
            withAnimation(.easeIn(duration: 1.0)) {
                mapZoomLevel *= 2.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showVerifiedBadge = true
                }
            }
        }
    }
}

#Preview {
    PhoneNumberVerificationView(
        onVerificationComplete: {}
    )
}
