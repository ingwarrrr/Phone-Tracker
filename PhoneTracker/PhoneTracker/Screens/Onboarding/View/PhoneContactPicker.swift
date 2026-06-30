//
//  PhoneContactPicker.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import Combine
import Contacts
import ContactsUI
import PhoneNumberKit

struct PhoneContactPicker: UIViewControllerRepresentable {
    let coordinator: PhoneContactPickerCoordinator
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
}

class PhoneContactPickerCoordinator: NSObject, CNContactPickerDelegate, ObservableObject {
    @Published var selectedPhoneNumber: String = ""
    @Published var detectedCountry: PhoneCountry?
    
    private let phoneNumberUtility = PhoneNumberUtility()
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumberValue = contact.phoneNumbers.first?.value.stringValue {
            parsePhoneNumber(phoneNumberValue)
        }
    }
    
    private func parsePhoneNumber(_ number: String) {
        do {
            let parsedNumber = try phoneNumberUtility.parse(number)
            let countryCode = parsedNumber.countryCode
            let nationalNumber = parsedNumber.nationalNumber
            
            if let country = findCountryByCountryCode(Int(countryCode)) {
                detectedCountry = country
                selectedPhoneNumber = String(nationalNumber)
            } else {
                fallbackParse(number)
            }
            
        } catch {
            fallbackParse(number)
        }
    }
    
    private func findCountryByCountryCode(_ countryCode: Int) -> PhoneCountry? {
        if countryCode == 1 {
            if let usa = PhoneCountry.availableCountries.first(where: { $0.countryCode == "US" }) {
                return usa
            }
        }
        
        return PhoneCountry.availableCountries.first { country in
            let cleanDialCode = country.dialCode.replacingOccurrences(of: "+", with: "")
            return Int(cleanDialCode) == countryCode
        }
    }
    
    private func fallbackParse(_ number: String) {
        let cleanedNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleanedNumber.count >= 5 {
            detectedCountry = PhoneCountry.availableCountries.first(where: { $0.countryCode == "US" })
            selectedPhoneNumber = cleanedNumber
            return
        }
        
        selectedPhoneNumber = cleanedNumber
    }
}
