//
//  ProfileNavigationRow.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI

struct SettingNavigationRow: View {
    let icon: String
    let title: String
    let showArrow: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width: 12)
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Spacer()
                
                if showArrow {
                    Image(AssetCatalog.settingsDisclosure)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .frame(height: 56)
            .background(
                VStack {
                    Spacer()
                    
                    Divider()
                        .background(Color.white.opacity(0.08))
                }
            )
        }
    }
}
