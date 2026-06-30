//
//  PaywallOptionView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI

struct OfferOptionView: View {
    let option: SubscriptionOption
    let isSelected: Bool
    
    private var borderColor: Color {
        isSelected ? .white : AppColors.promoViolet
    }
    
    private var bgColor: Color {
        isSelected ? .white : .black.opacity(0.01)
    }
    
    private var foregroundColor: Color {
        isSelected ? AppColors.promoViolet : .white
    }
    
    private var typeTextColor: Color {
        isSelected ? .black : .white
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(AppColors.promoViolet)
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(.white.opacity(0.2))
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(option.priceTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(typeTextColor)
                
                Text(option.priceText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(typeTextColor.opacity(0.4))
            }
            
            Spacer()
            
            if !option.description.isEmpty {
                Text(option.description)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(foregroundColor.opacity(isSelected ? 0.25 : 0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(foregroundColor.opacity(0.15), lineWidth: 1)
                    )
            }
        }
        .frame(height: 58)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(bgColor)
        )
    }
}

#Preview {
    OfferOptionView(
        option:
            SubscriptionOption(type: .weekly, price: 7, priceTitle: "Weekly", priceText: "$7.99/week", description: "MOST POPULAR", isHighlighted: true, adaptyProduct: nil),
        isSelected: true
    )
}
