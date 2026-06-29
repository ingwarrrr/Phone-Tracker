//
//  SubscriptionOption.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import Adapty

struct SubscriptionOption: Identifiable {
    let id = UUID()
    let type: SubscriptionType
    let price: Decimal
    let priceTitle: String
    let priceText: String
    let description: String
    var isHighlighted: Bool = false
    var adaptyProduct: AdaptyPaywallProduct?
    
    enum SubscriptionType: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case annual = "Annual"
    }
    
    static func calculateDiscount(weeklyPrice: Decimal, monthlyPrice: Decimal) -> Int {
        guard weeklyPrice > 0, monthlyPrice > 0 else { return 0 }
        let weeklyEquivalent = weeklyPrice * 4
        var discountDecimal = (1 - (monthlyPrice / weeklyEquivalent)) * 100
        
        var roundedDiscount = Decimal()
        NSDecimalRound(&roundedDiscount, &discountDecimal, 0, .plain)
        
        return (roundedDiscount as NSDecimalNumber).intValue
    }
}
