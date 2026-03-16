//
//  Decimal.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import Foundation

extension Decimal {
    func discountPercentage(comparedTo weeklyPrice: Decimal) -> Int {
        guard self > 0, weeklyPrice > 0 else { return 0 }
        
        let weeklyEquivalent = weeklyPrice * 4
        var discountDecimal = (1 - (self / weeklyEquivalent)) * 100
        
        var roundedDiscount = Decimal()
        NSDecimalRound(&roundedDiscount, &discountDecimal, 0, .plain)
        
        return (roundedDiscount as NSDecimalNumber).intValue
    }
}
