//
//  NotificationView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI

struct NotificationView: View {
    @Binding var showNotification: Bool
    @State private var hideNotificationTimer: Timer?
    var notificationData: RemoteNotificationPayload?
    var iconName: String = AssetCatalog.settingsAvatar
    var showXmark: Bool = true
    
    private let notificationHeight: CGFloat = 64
    private let autoHideDelay: TimeInterval = 5
    
    var body: some View {
        if showNotification, let data = notificationData {
            HStack(spacing: 0) {
                iconBlock(for: data.type)
                
                textBlock(for: data.type, title: data.alertTitle, message: data.alertBody)
                    .padding(.leading, data.type == .emergency ? 24 : data.type == .lowPower ? 12 : 0)
                    .padding(.vertical)
                
                Spacer()
                
                if showXmark {
                    Button(action: {
                        hideNotification()
                    }) {
                        Image(AssetCatalog.notificationCross)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 16)
                }
            }
            .frame(minHeight: notificationHeight)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            .onAppear {
                setupAutoHideIfNeeded(data.autoDismissEnabled)
            }
            .onDisappear {
                hideNotificationTimer?.invalidate()
            }
        }
    }
    
    // MARK: - Icon Block
    @ViewBuilder
    private func iconBlock(for type: PushType) -> some View {
        ZStack(alignment: .bottom) {
            Image(iconName)
                .resizable()
                .frame(width: 32, height: 32)
                .cornerRadius(12)
                .background(
                    AppColors.mainBG.cornerRadius(12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 3, y: 3)
            
            iconContent(for: type)
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
    }
    
    @ViewBuilder
    private func iconContent(for type: PushType) -> some View {
        switch type {
        case .lowPower:
            ZStack {
                Image(AssetCatalog.powerLow)
                    .resizable()
                    .frame(width: 12, height: 12)
            }
            .frame(width: 20, height: 20)
            .cornerRadius(10)
            .rotationEffect(Angle(degrees: -90))
            .background(
                Circle().fill(.white)
            )
            .offset(x: 18)
        case .emergency:
            Text(Localizable.Common.sos)
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .cornerRadius(12)
                .background(
                    Color.red.cornerRadius(12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                )
                .offset(x: 24)
        case .general, .regionEntered, .regionExited:
            Group { }
        }
    }
    
    // MARK: - Text Block
    @ViewBuilder
    private func textBlock(for type: PushType, title: String, message: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            if let message = message, message != "" {
                Text(message)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Methods
    private func setupAutoHideIfNeeded(_ shouldAutoHide: Bool) {
        if shouldAutoHide {
            hideNotificationTimer = Timer.scheduledTimer(withTimeInterval: autoHideDelay, repeats: false) { _ in
                hideNotification()
            }
        }
    }
    
    private func hideNotification() {
        withAnimation {
            showNotification = false
        }
        hideNotificationTimer?.invalidate()
    }
}

#Preview {
    NotificationView(
        showNotification: .constant(true),
        notificationData:
            RemoteNotificationPayload(
                alertTitle: "Title",
                alertBody: "Body body body",
                receivedAt: Date(),
                type: .emergency,
                autoDismissEnabled: false
            )
    )
}
