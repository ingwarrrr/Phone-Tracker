//
//  PhoneNumberPopup.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import Factory

struct PhoneNumberPopup: View {
    @Injected(\.userDefaultsService) private var userDefaultsService
    @Binding var showPopup: Bool
    @Binding var verificationStatus: VerificationStage
    
    var body: some View {
        ZStack {
            if showPopup {
                VStack {
                    HStack(spacing: 8) {
                        AnimatingView(name: verificationStatus.imageName)
                            .frame(width: verificationStatus.iconSize, height: verificationStatus.iconSize)
                            .id(verificationStatus.imageName)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userDefaultsService.promoContactNumber)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text(verificationStatus.text)
                                .foregroundColor(verificationStatus.color)
                                .font(.system(size: 16, weight: .regular))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(minHeight: 70)
                    .background(.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 4)
                    .padding(.horizontal)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showPopup)
                    .animation(.easeInOut(duration: 0.3), value: verificationStatus)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    PhoneNumberPopup(showPopup: .constant(true), verificationStatus: .constant(.dispatchingRequest))
}

