//
//  SOSContentView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 22.03.2026.
//

import SwiftUI

struct SOSContentView: View {
    let icon: AnyView
    let title: String
    let subtitle: String
    let horizontalPadding: CGFloat
    
    init<Icon: View>(icon: Icon, title: String, subtitle: String, horizontalPadding: CGFloat = 50) {
        self.icon = AnyView(icon)
        self.title = title
        self.subtitle = subtitle
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        VStack(spacing: 0) {
            icon
                .padding(.bottom, 24)
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
            Text(subtitle)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
        }
        .padding(.horizontal, horizontalPadding)
    }
}
