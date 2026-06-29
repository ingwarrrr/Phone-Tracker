//
//  PhoneTrackerApp.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 09.03.2026.
//

import SwiftUI
import MapKit
import Factory

@main
struct Location_Tracker_9App: App {
    
    // MARK: - Adapters
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegateProxy
    
    // MARK: - Environment
    @Environment(\.scenePhase) var lifecyclePhase
    
    // MARK: - Injected State Objects
    @InjectedObject(\.networkService) private var networkService
    @InjectedObject(\.notificationService) private var notificationService
    @InjectedObject(\.locationService) private var locationService
    @InjectedObject(\.firebaseAuthService) private var firebaseAuthService
    @InjectedObject(\.adaptyService) private var adaptyService
    @InjectedObject(\.remoteConfigService) private var remoteConfigService
    
    // MARK: - Injected Services
    @Injected(\.userDefaultsService) private var userDefaultsService
    
    // MARK: - Local State
    @State private var isLaunchScreenVisible = true
    
    // MARK: - Scene Body
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunchScreenVisible {
                    LaunchScreen()
                        .transition(.opacity)
                } else {
                    contentRouter
                }
            }
            .onAppear {
                bootstrapApplication()
            }
            .background(AppColors.mainBG)
            .ignoresSafeArea(.keyboard)
            .preferredColorScheme(.dark)
        }
        .onChange(of: lifecyclePhase) { newPhase in
            handleLifecycleTransition(newPhase)
        }
    }
    
    // MARK: - Content Router
    @ViewBuilder
    private var contentRouter: some View {
        let isFlowA = remoteConfigService.appFlow == .flowOne
        
        if !userDefaultsService.hasCompletedOnboarding {
            onboardingSection(isFlowA: isFlowA)
        } else if !userDefaultsService.hasCompletedPromo {
            promosSection(isFlowA: isFlowA)
        } else {
            MainView()
        }
    }
    
    // MARK: - Onboarding
    @ViewBuilder
    private func onboardingSection(isFlowA: Bool) -> some View {
        if isFlowA {
            OnboardingFirstView {
                userDefaultsService.hasCompletedOnboarding = true
            }
        } else {
            OnboardingSecondView {
                userDefaultsService.hasCompletedOnboarding = true
            }
        }
    }
    
    // MARK: - Promo Offers
    @ViewBuilder
    private func promosSection(isFlowA: Bool) -> some View {
        let showClose = remoteConfigService.showCloseBtn
        
        if isFlowA {
            if userDefaultsService.isInitialLaunch {
                OfferFirstView(showDismissBTN: showClose) {
                    userDefaultsService.hasCompletedPromo = true
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                OfferSecondView(showDismissBTN: showClose, isFlowFirst: true) {
                    userDefaultsService.hasCompletedPromo = true
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        } else {
            OfferSecondView(showDismissBTN: showClose) {
                userDefaultsService.hasCompletedPromo = true
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Bootstrap
    private func bootstrapApplication() {
        Task {
            async let remoteTask: () = fetchRemoteFeatureFlags()
//            async let paywallTask: () = fetchSubscriptionContent()
            
            _ = await (remoteTask/*, paywallTask*/)
            
            if !adaptyService.hasActiveSubscription, networkService.currentMapCoordinate == CLLocationCoordinate2D() {
                await resolveIPGeolocation()
            }
            
            await MainActor.run {
                isLaunchScreenVisible = false
            }
        }
    }
    
    private func fetchRemoteFeatureFlags() async {
        _ = await remoteConfigService.fetchConfig()
    }
    
    private func fetchSubscriptionContent() async {
        do {
            try await adaptyService.refreshProfile()
            await adaptyService.loadPaywallContent()
        } catch {
            print("Adapty error: \(error.localizedDescription)")
        }
    }
    
    private func resolveIPGeolocation() async {
        do {
            let _ = try await networkService.validateSession()
            let _ = try await networkService.fetchIPBasedLocation()
        } catch {
            print("IP info error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Lifecycle Handler
    private func handleLifecycleTransition(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            notificationService.isAppInForeground = true
            locationService.refreshLastActiveTimestamp()
            locationService.evaluateAutoDisableCondition()
        case .background:
            if userDefaultsService.isInitialLaunch {
                userDefaultsService.isInitialLaunch = false
            }
            notificationService.isAppInForeground = false
            notificationService.refreshScheduledAlerts(subscriptionActive: adaptyService.hasActiveSubscription)
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}
