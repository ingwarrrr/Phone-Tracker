//
//  HistoryQuery.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import Foundation

struct HistoryQuery: Codable {
    let targetDate: String?
    let timezone: String?
    
    enum CodingKeys: String, CodingKey {
        case targetDate = "date"
        case timezone = "tz"
    }
}
