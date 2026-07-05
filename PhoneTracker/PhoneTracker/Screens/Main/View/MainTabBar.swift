//
//  MainTabBar.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 22.03.2026.
//

import SwiftUI

struct MainTabBar: View {
    @Binding var selectedTab: NavigationTab?
    
    var onTab: ((NavigationTab) -> Void)? = nil
    private let tabs: [NavigationTab] = NavigationTab.allCases
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 46)
        .padding(.bottom, isSmallDevice ? 32 : 0)
        .background(AppColors.mainBG)
        .cornerRadius(46, corners: [.topLeft, .topRight])
        .overlay(topDivider, alignment: .top)
    }
    
    private var topDivider: some View {
        RoundedRectangle(cornerRadius: 46)
            .stroke(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .white.opacity(0.4), location: 0.2),
                        .init(color: .white.opacity(0.4), location: 0.8),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 1
            )
            .shadow(color: .black, radius: 4)
            .cornerRadius(46, corners: [.topLeft, .topRight])
            .mask(
                VStack {
                    Rectangle()
                        .frame(height: 23)
                    Spacer()
                }
            )
    }
    
    private func tabButton(for tab: NavigationTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTab?(tab)
            }
        } label: {
            VStack(spacing: 4) {
                Image(tab.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.2))
                
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.2))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.height <= 667
    }
}
