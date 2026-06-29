//
//  PhoneCountry.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 21.03.2026.
//

import SwiftUI

struct PhoneCountry: Codable, Hashable, Identifiable {
    var id: String { countryCode }
    var countryName: String
    var dialCode: String
    var countryCode: String
    var flagEmoji: String {
        countryCode.unicodeScalars.reduce(into: "") {
            if let scalar = UnicodeScalar(127397 + $1.value) {
                $0.unicodeScalars.append(scalar)
            }
        }
    }

    static let availableCountries: [PhoneCountry] = {
        guard let url = Bundle.main.url(forResource: "PhoneCountryCodes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let countries = try? JSONDecoder().decode([PhoneCountry].self, from: data) else {
            return []
        }
        return countries
    }()
}
