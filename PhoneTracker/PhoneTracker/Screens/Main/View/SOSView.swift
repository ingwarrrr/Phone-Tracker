//
//  SOSView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 22.03.2026.
//

import SwiftUI
import Combine
import MapKit
import Factory

enum SOSViewType {
    case noPeople
    case sending
}

struct SOSView: View {
    @Injected(\.networkService) private var networkService
    @Injected(\.locationService) private var locationService
    
    @Binding var isPresented: Bool
    @Binding var type: SOSViewType
    @State private var countdown: Int = 10
    @State private var isSendingCompleted = false
    @State private var progress: Double = 0.0
    @State private var startTime: Date?
    
    private let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private var icon: any View {
        type == .noPeople ? confirmationIcon : sendingIcon
    }
    
    private var title: String {
        type == .noPeople ? Localizable.Notification.noOneReceive : Localizable.Notification.sosSentToPeople
    }
    
    private var subtitle: String {
        type == .noPeople ? Localizable.Notification.invitePeople : Localizable.Notification.clickedByMistake
    }
    
    private var buttonText: String {
        type == .noPeople ? Localizable.Common.ok.uppercased() : Localizable.Common.cancel
    }
    
    var body: some View {
        ZStack {
            Image(AssetCatalog.emergencySentBackground)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                Spacer()
                
                SOSContentView(
                    icon: icon,
                    title: title,
                    subtitle: !isSendingCompleted ? subtitle : ""
                )
                
                if type == .sending {
                    Spacer()
                    Spacer()
                    if !isSendingCompleted {
                        sendingButton
                            .padding(.bottom, 60)
                    }
                } else {
                    sendingButton
                    Spacer()
                    Spacer()
                }
            }
        }
        .onReceive(progressTimer) { _ in
            updateProgress()
        }
        .onDisappear {
            cleanupTimers()
        }
        .onAppear {
            resetState()
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Button(action: { isPresented = false }) {
                Image(AssetCatalog.notificationCross)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    private var confirmationIcon: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(AppColors.emergencyRed)
            .frame(width: 60, height: 60)
            .overlay(
                Text(Localizable.Common.sos)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.white)
            )
    }
    
    private var sendingIcon: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.red,
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .frame(width: 70, height: 70)
                .rotationEffect(Angle(degrees: -90))
            
            Text(Localizable.Common.sos)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var sendingButton: some View {
        Button(action: { isPresented = false }) {
            Text(buttonText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
        }
    }
    
    private func updateProgress() {
        guard type == .sending && !isSendingCompleted else { return }
        
        if startTime == nil {
            startTime = Date()
        }
        
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        progress = min(elapsed / 10.0, 1.0)
        countdown = max(10 - Int(elapsed), 0)
        
        if progress >= 1.0 {
            Task {
                await sendSOSSignal()
            }
        }
    }
    
    private func sendSOSSignal() async {
        guard let location = locationService.lastKnownCoordinate else { return isPresented = false }
        do {
            withAnimation {
                isSendingCompleted = true
                cleanupTimers()
            }
            try await networkService.triggerEmergencySignal(
                lat: location.latitude,
                lon: location.longitude
            )
        } catch {
            isPresented = false
        }
    }
    
    private func resetState() {
        countdown = 10
        isSendingCompleted = false
        progress = 0.0
        startTime = nil
    }
    
    private func cleanupTimers() {
        progressTimer.upstream.connect().cancel()
    }
}

#Preview {
    Group {
        SOSView(isPresented: .constant(true), type: .constant(.sending))
    }
}
