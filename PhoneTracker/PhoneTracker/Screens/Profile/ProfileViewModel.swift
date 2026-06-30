//
//  ProfileViewModel.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import Combine
import CoreLocation
import Factory

class SettingsViewModel: ObservableObject {
    @Published var locationAccess: Bool = false
    @Published var notifications: Bool = false
    @Published var showBattery: Bool = false
    @Published var backgroundUpdates: Bool = true
    @Published var showingDeleteAlert = false
    @Published var showEditProfile = false
    @Published var profileImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var currentUser: MemberInfo? = nil
    
    @Injected(\.networkService) private var networkService
    @Injected(\.locationService) private var locationService
    @Injected(\.notificationService) private var notificationService
    @Injected(\.powerLevelService) private var batteryService
    @Injected(\.userDefaultsService) private var userDefaults
    
    var userName: String {
        currentUser?.displayName ?? ""
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupUserObserver()
        loadPermissionStatuses()
        setupAppStateObservers()
    }
    
    private func setupUserObserver() {
        networkService.$activeProfile
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Permission Management
    
    func loadPermissionStatuses() {
        locationAccess = locationService.currentAuthStatus == .authorizedAlways ||
                        locationService.currentAuthStatus == .authorizedWhenInUse
        
        notificationService.verifyPermissionState { [weak self] status in
            DispatchQueue.main.async {
                self?.notifications = status
            }
        }
        
        showBattery = batteryService.monitoringPermitted
        backgroundUpdates = locationService.backgroundTrackingAllowed
    }
    
    func toggleBatteryInfo(_ enabled: Bool) {
        if enabled {
            batteryService.grantMonitoringAccess { [weak self] granted in
                DispatchQueue.main.async {
                    self?.showBattery = granted
                }
            }
        } else {
            batteryService.revokeMonitoringAccess()
            showBattery = false
        }
    }
    
    func toggleBackgroundUpdates(_ enabled: Bool) {
        backgroundUpdates = enabled
        locationService.backgroundTrackingAllowed = enabled
    }
    
    // MARK: - Account Management
    
    func deleteAccount() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            _ = try await networkService.removeProfile()
            clearAllLocalData()
            
            await MainActor.run {
                self.isLoading = false
                NotificationCenter.default.post(name: .profileDidDelete, object: nil)
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    private func clearAllLocalData() {
        currentUser = nil
        profileImage = nil
        
        locationService.memberAddressCache = [:]
        locationService.areaAddressCache = [:]
        
        userDefaults.wipeAllSensitiveData()
        networkService.purgeCredentials()
    }
    
    // MARK: - Profile Management
    
    func updateUserName(_ newName: String) {
        isLoading = true
        
        Task {
            do {
                guard let currentUser = networkService.activeProfile else {
                    throw NetworkError.unauthorized
                }
                
                let payload = ProfileUpdateData(
                    displayName: newName,
                    batteryLevel: currentUser.batteryLevel
                )
                
                _ = try await networkService.modifyProfile(payload)
                _ = try await networkService.fetchActiveProfile()
                
                await MainActor.run {
                    self.isLoading = false
                    NotificationCenter.default.post(name: .preferencesDidUpdate, object: nil)
                    print("User name updated to: \(newName)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Failed to update user name: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateProfileImage(_ image: UIImage) {
        isLoading = true
        profileImage = image
        
        Task {
            do {
                guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                    throw NetworkError.decodingError
                }
                
                let mediaAdapter = try await networkService.uploadProfilePicture(imagePayload: imageData)
                _ = try await networkService.fetchActiveProfile()
                
                await MainActor.run {
                    NotificationCenter.default.post(name: .preferencesDidUpdate, object: nil)
                    self.isLoading = false
                    print("Profile image updated successfully. Media ID: \(mediaAdapter.id)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.profileImage = nil
                    print("Failed to upload profile image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sendFeedback(subject: String, body: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "mailto"
        urlComponents.path = AppConstants.supportEmail
        urlComponents.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        
        guard let url = urlComponents.url else { return }
        
        UIApplication.shared.open(url)
    }
    
    func openBrowser(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - App State Observers
    
    private func setupAppStateObservers() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.loadPermissionStatuses()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.loadPermissionStatuses()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
