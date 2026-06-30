//
//  OnboardingSecondView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit
import Factory

enum AppRoute: Hashable {
    case phoneNumber
    case phoneVerification(String)
}

struct OnboardingSecondView: View {
    @State private var navigationPath = NavigationPath()
    @Injected(\.notificationService) private var notificationService
    var onContinue: () -> Void
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Image(AssetCatalog.onboardingBackgroundB)
                    .resizable()
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    AnimatingView(
                        name: AssetCatalog.onboardingAnimationB
                    )
                    .offset(y: -2 * geometry.safeAreaInsets.top - 5)
                    .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    Text(Localizable.Onboard.keepSafe)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    
                    GradientButton(
                        title: Localizable.Common.continueText,
                        showPlusIcon: false,
                        action: {
                            navigationPath.append(AppRoute.phoneNumber)
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    
                    agreementText
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .phoneNumber:
                    PhoneNumberInputView(
                        navigationPath: $navigationPath
                    )
                    .navigationBarHidden(true)
                case .phoneVerification:
                    PhoneNumberVerificationView(
                        onVerificationComplete: {
                            onContinue()
                        }
                    )
                    .navigationBarHidden(true)
                }
            }
        }
        .onAppear {
            requestNotificationsPermission()
        }
        .background(AppColors.mainBG)
    }
    
    private var agreementTextShort: some View {
        HStack(spacing: 4) {
            Text(Localizable.Onboard.byContinuing)
            
            Button(action: {
                openBrowser(AppConstants.privacyPageURL)
            }) {
                Text(Localizable.Settings.privacyPolicy)
                    .underline()
            }
            
            Text(Localizable.Common.and)
            
            Button(action: {
                openBrowser(AppConstants.termsPageURL)
            }) {
                Text(Localizable.Settings.termsOfUse)
                    .underline()
            }
        }
        .frame(height: 48)
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(.white.opacity(0.4))
        .padding(.bottom, 8)
    }
    
    private var agreementText: some View {
        VStack(spacing: 4) {
            Text(Localizable.Onboard.byContinuing)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.4))
            
            HStack(spacing: 4) {
                Button(action: {
                    openBrowser(AppConstants.privacyPageURL)
                }) {
                    Text(Localizable.Settings.privacyPolicy)
                        .underline()
                }
                
                Text(Localizable.Common.and)
                
                Button(action: {
                    openBrowser(AppConstants.termsPageURL)
                }) {
                    Text(Localizable.Settings.termsOfUse)
                        .underline()
                }
            }
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(.white.opacity(0.4))
        }
        .padding(.bottom, 8)
    }
    
    private func openBrowser(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func requestNotificationsPermission() {
        notificationService.solicitPermission { _ in }
    }
}

#Preview {
    OnboardingSecondView(
        onContinue: { }
    )
}
