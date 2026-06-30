//
//  OnboardingFirstView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import AVKit
import Factory

struct OnboardingFirstView: View {
    @State private var currentPage = 0
    @State private var visibleNotificationIndices: [Int] = []
    @State private var animationTasks: [DispatchWorkItem] = []
    @Injected(\.notificationService) private var notificationService
    
    let titles = Localizable.Onboard.titles
    let descriptions = Localizable.Onboard.descriptions
    let backgroundNames = AssetCatalog.onboardingSlidesA
    let lottieNames = AssetCatalog.onboardingAnimationsA
    let iconNames = AssetCatalog.alertAvatars
    
    var onContinue: () -> Void
    
    private var isIPhoneSE: Bool {
        return UIScreen.main.bounds.width <= 375 && UIScreen.main.bounds.height <= 667
    }
    
    let notificationData: [RemoteNotificationPayload] = [
        RemoteNotificationPayload(
            alertTitle: String(format: Localizable.Notification.exit, "Marry", "Office"),
            alertBody: "",
            receivedAt: Date(),
            type: .general,
            autoDismissEnabled: false
        ),
        RemoteNotificationPayload(
            alertTitle: String(format: Localizable.Notification.entry, "Mark", "Cafe"),
            alertBody: "",
            receivedAt: Date(),
            type: .general,
            autoDismissEnabled: false
        ),
        RemoteNotificationPayload(
            alertTitle: String(format: Localizable.Notification.exit, "Garry", "Home"),
            alertBody: "",
            receivedAt: Date(),
            type: .general,
            autoDismissEnabled: false
        ),
        RemoteNotificationPayload(
            alertTitle: String(format: Localizable.Notification.sos, "Mark"),
            alertBody: Localizable.Notification.seeLocation,
            receivedAt: Date(),
            type: .emergency,
            autoDismissEnabled: false
        )
    ]
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<titles.count, id: \.self) { index in
                    ZStack {
                        VStack(spacing: 0) {
                            if index == 0 {
                                AnimatingView(
                                    name: lottieNames[index],
                                    isPlaying: currentPage == index
                                )
                                .frame(width: 264, height: 240)
                                .offset(x: 70)
                            }
                            if index == 1 {
                                AnimatingView(
                                    name: lottieNames[index],
                                    isPlaying: currentPage == index
                                )
                                .frame(maxWidth: .infinity)
                                .offset(y: -35)
                            }
                            if index == 2 {
                                notificationsStack
                                    .frame(height: 300)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                            }
                            if index == 3 {
                                AnimatingView(
                                    name: lottieNames[index],
                                    isPlaying: currentPage == index
                                )
                                .frame(maxWidth: .infinity)
                                .offset(y: -20)
                            }
                            
                            Spacer(minLength: 1)
                            
                            Text(titles[index])
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                            
                            Text(descriptions[index])
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 88)
                            
                            GradientButton(
                                title: Localizable.Common.continueText,
                                showPlusIcon: false
                            ) {
                                handleContinueAction(for: index)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(index)
                    }
                    .background(
                        ZStack(alignment: .top) {
                            Image(backgroundNames[index])
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                        }
                    )
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            
            VStack {
                Spacer()
                
                OnboardingPageControl(pageCount: titles.count, page: currentPage)
                    .padding(.bottom, 84)
            }
        }
        .onChange(of: currentPage) { newPage in
            handlePageChange(newPage)
        }
        .onDisappear {
            stopAllAnimations()
        }
        .background(AppColors.mainBG)
    }
    
    // MARK: - Notifications Stack
    private var notificationsStack: some View {
        ZStack {
            ForEach(0..<notificationData.count, id: \.self) { index in
                if visibleNotificationIndices.contains(index) {
                    NotificationView(
                        showNotification: .constant(true),
                        notificationData: notificationData[index],
                        iconName: iconNames[index],
                        showXmark: false
                    )
                    .rotationEffect(rotationAngle(for: index))
                    .offset(y: offsetForNotification(index))
                    .zIndex(Double(notificationData.count + index))
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.8)
                                .combined(with: .opacity)
                                .combined(with: .offset(y: 50))
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.3)),
                            removal: .opacity.animation(.easeInOut(duration: 0.3))
                        )
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func rotationAngle(for index: Int) -> Angle {
        let angles: [Double] = [-3, 2, -1, 4]
        return Angle(degrees: angles[index % angles.count])
    }
    
    private func offsetForNotification(_ index: Int) -> CGFloat {
        return CGFloat(index * 70)
    }
    
    private func handlePageChange(_ newPage: Int) {
        if newPage == 2 {
            requestNotificationsPermission()
            startNotificationAnimation()
        } else {
            stopAllAnimations()
        }
    }
    
    private func startNotificationAnimation() {
        stopAllAnimations()
        
        guard self.currentPage == 2 else { return }
        runAnimationCycle()
    }
    
    private func stopAllAnimations() {
        animationTasks.forEach { $0.cancel() }
        animationTasks.removeAll()
        
        visibleNotificationIndices.removeAll()
    }
    
    private func runAnimationCycle() {
        guard currentPage == 2 else { return }
        
        visibleNotificationIndices.removeAll()
        
        for index in 0..<notificationData.count {
            let task = DispatchWorkItem {
                guard currentPage == 2 else { return }
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    if !visibleNotificationIndices.contains(index) {
                        visibleNotificationIndices.append(index)
                    }
                }
            }
            
            animationTasks.append(task)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5, execute: task)
        }
        
        let hideTask = DispatchWorkItem {
            guard currentPage == 2 else { return }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                visibleNotificationIndices.removeAll()
            }
            
            let nextCycleTask = DispatchWorkItem {
                guard currentPage == 2 else { return }
                self.runAnimationCycle()
            }
            
            self.animationTasks.append(nextCycleTask)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: nextCycleTask)
        }
        
        animationTasks.append(hideTask)
        let totalAnimationTime = Double(notificationData.count) * 0.9 + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + totalAnimationTime, execute: hideTask)
    }
    
    private func requestNotificationsPermission() {
        notificationService.solicitPermission { granted in
            print("Notifications Permission status \(granted)")
        }
    }
    
    private func handleContinueAction(for index: Int) {
        stopAllAnimations()
        
        if index == titles.count - 1 {
            onContinue()
        } else {
            withAnimation {
                currentPage = index + 1
            }
        }
    }
}

#Preview {
    OnboardingFirstView(onContinue: { })
}
