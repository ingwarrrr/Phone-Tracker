//
//  AppServiceContainer.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 31.03.2026.
//

import Factory

extension Container {
    
    // MARK: - Services
    
    var adaptyService: Factory<SubscriptionManager> {
        self { SubscriptionManager() }
            .singleton
    }
    
    var powerLevelService: Factory<PowerLevelService> {
        self { PowerLevelService() }
    }
    
    var firebaseAuthService: Factory<FirebaseAuthService> {
        self { FirebaseAuthService() }
            .singleton
    }
    
    var locationService: Factory<LocationService> {
        self { LocationService() }
            .singleton
    }
    
    var networkService: Factory<NetworkService> {
        self { NetworkService() }
            .singleton
    }
    
    var notificationService: Factory<NotificationService> {
        self { NotificationService() }
            .singleton
    }
    
    var remoteConfigService: Factory<RemoteConfigService> {
        self { RemoteConfigService() }
            .singleton
    }
    
    var socketConnectionService: Factory<SocketConnectionService> {
        self { SocketConnectionService() }
            .singleton
    }
    
    var userDefaultsService: Factory<UserDefaultsService> {
        self { UserDefaultsService() }
            .singleton
    }
}
