//
//  MainViewModel.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit
import Combine
import Factory

class MainViewModel: ObservableObject {
    @Injected(\.locationService) var locationService
    @Injected(\.networkService) private var networkService
    @Injected(\.powerLevelService) private var batteryService
    
    private var cancellables = Set<AnyCancellable>()
    
    private var lastSentPowerLevel: Int?
    
    init() {
        setupLocationTracking()
        setupBatteryService()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Location Tracking
    
    private func setupLocationTracking() {
        locationService.positionStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updateLocation(location)
            }
            .store(in: &cancellables)
    }
    
    private func updateLocation(_ location: CLLocation) {
        Task {
            do {
                print("Sending location to server...")
                try await networkService.reportCurrentPosition(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
                print("Location sent successfully")
            } catch {
                print("Error sending location: \(error)")
            }
        }
    }
    
    private func setupBatteryService() {
        batteryService.$currentChargePercentage
            .removeDuplicates()
            .sink { [weak self] value in
                self?.updateBatteryPowerLevel(value)
            }
            .store(in: &cancellables)
    }
    
    private func updateBatteryPowerLevel(_ value: Int?) {
        guard value != lastSentPowerLevel, let currentUser = networkService.activeProfile else { return }
        
        Task {
            do {
                let batteryValue: Int?
                
                if let value = value {
                    if value == 0 {
                        batteryValue = 0
                    } else {
                        let powerLevel = max(abs(UIDevice.current.batteryLevel) * 100, 0)
                        batteryValue = Int(powerLevel)
                    }
                } else {
                    batteryValue = 0
                }
                
                let payload = ProfileUpdateData(
                    displayName: currentUser.displayName,
                    batteryLevel: batteryValue
                )
                
                _ = try await networkService.modifyProfile(payload)
                lastSentPowerLevel = batteryValue
                
            } catch {
                print("Failed to update battery level: \(error)")
            }
        }
    }
}
