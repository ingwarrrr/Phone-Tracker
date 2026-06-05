//
//  AppDelegate.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import AppsFlyerLib
import Factory

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Dependencies
    @Injected(\.adaptyService) private var subscriptionManager
    @Injected(\.notificationService) private var alertCoordinator
    
    // MARK: - Launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        configureAttributionSDK()
        
        NotificationCenter.default.addObserver(
            self,
            selector: NSSelectorFromString("launchAttributionCollector"),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        Messaging.messaging().delegate = alertCoordinator
        alertCoordinator.verifyPermissionState { _ in }
        
        return true
    }
    
    // MARK: - APNs Registration
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        alertCoordinator.processAPNsToken(token: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError fault: Error
    ) {
        alertCoordinator.processAPNsFailure(fault)
    }
    
    // MARK: - Remote Notification
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification payload: [AnyHashable: Any],
        fetchCompletionHandler completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard payload["aps"] as? [String: AnyObject] != nil else {
            completion(.failed)
            return
        }
    }
    
    // MARK: - Attribution Setup
    private func configureAttributionSDK() {
        AppsFlyerLib.shared().appsFlyerDevKey = "AppsFlyerConstants.devKey"
        AppsFlyerLib.shared().appleAppID = "AppsFlyerConstants.appID"
        
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #else
        AppsFlyerLib.shared().isDebug = false
        #endif
        
        AppsFlyerLib.shared().delegate = self
    }
    
    @objc
    func launchAttributionCollector() {
        AppsFlyerLib.shared().start()
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ rawPayload: [AnyHashable: Any]) {
        let uid = AppsFlyerLib.shared().getAppsFlyerUID()
        subscriptionManager.processAttributionUpdate(rawPayload, identifier: uid)
    }
    
    func onConversionDataFail(_ fault: any Error) {
        print("AppsFlyer onConversionDataFail: \(fault.localizedDescription)")
    }
}
