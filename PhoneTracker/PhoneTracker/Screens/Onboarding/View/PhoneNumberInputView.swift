//
//  PhoneNumberInputView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import Factory

struct PhoneNumberInputView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var contactCoordinator = PhoneContactPickerCoordinator()
    @Injected(\.userDefaultsService) private var userDefaultsService
    @Injected(\.networkService) private var networkService
    
    @State private var phoneNumber: String = ""
    @State private var selectedCountry: PhoneCountry = PhoneCountry.availableCountries.first(where: { $0.countryCode == "US" }) ?? PhoneCountry.availableCountries[0]
    @State private var showCountryPicker = false
    @State private var showContactPicker = false
    @State private var searchText = ""
    
    @FocusState private var isPhoneFieldFocused: Bool
    
    var body: some View {
        ZStack {
            ZStack {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Image(AssetCatalog.dismissIcon)
                        .frame(width: 24, height: 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 8)
            .padding(.trailing, 24)
            
            VStack(spacing: 0) {
                Spacer()
                
                Text(Localizable.Onboard.enterNumber)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                
                Text(Localizable.Onboard.privacyNotice)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                
                HStack(spacing: 0) {
                    Button(action: {
                        isPhoneFieldFocused = false
                        showCountryPicker = true
                    }) {
                        HStack(spacing: 0) {
                            Text(selectedCountry.flagEmoji)
                                .font(.system(size: 25))
                                .frame(width: 20, height: 20)
                                .cornerRadius(10)
                                .padding(.leading, 10)
                            
                            Text(selectedCountry.dialCode)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                            
                            Image(AssetCatalog.chevronDown)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 10)
                        }
                        .frame(height: 40)
                        .background(.white.opacity(0.12))
                        .cornerRadius(10)
                        .padding(.leading, 4)
                    }
                    .padding(.trailing, 10)
                    
                    TextField("", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.trailing)
                        .placeholder(
                            phoneNumber,
                            placeholder: "(999) 999-99-99",
                            color: .white.opacity(0.4)
                        )
                        .focused($isPhoneFieldFocused)
                    
                }
                .onChange(of: phoneNumber) { newValue in
                    let numbers = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    let limitedNumbers = String(numbers.prefix(15))
                    phoneNumber = formatPhoneInput(limitedNumbers)
                }
                .frame(height: 48)
                .background(.white.opacity(0.12))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom)
                
                GradientButton(
                    title: Localizable.Common.continueText,
                    showPlusIcon: false,
                    isEnabled: !phoneNumber.isEmpty,
                    action: {
                        savePhoneNumber()
                        navigationPath.append(AppRoute.phoneVerification(formatPhoneNumber()))
                    }
                )
                .disabled(phoneNumber.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
                
                Button {
                    showContactPicker = true
                } label: {
                    HStack(spacing: 12) {
                        Image(AssetCatalog.personIcon)
                            .frame(width: 24, height: 24)
                        
                        Text(Localizable.Onboard.chooseFromContacts)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Spacer()
            }
            
            if showCountryPicker {
                FloatingPanel(
                    isVisible: $showCountryPicker,
                    panelHeight: UIScreen.main.bounds.height * 0.95,
                    panelRadius: 46
                ) {
                    CountryCodePicker(
                        selectedCountry: $selectedCountry,
                        searchText: $searchText,
                        isPresented: $showCountryPicker
                    )
                    .onDisappear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isPhoneFieldFocused = true
                        }
                    }
                }
            }
        }
        .background(AppColors.mainBG)
        .sheet(isPresented: $showContactPicker) {
            PhoneContactPicker(coordinator: contactCoordinator)
        }
        .onReceive(contactCoordinator.$detectedCountry) { country in
            if let country = country {
                selectedCountry = country
            }
        }
        .onReceive(contactCoordinator.$selectedPhoneNumber) { number in
            if !number.isEmpty {
                phoneNumber = number
                showContactPicker = false
            }
        }
        .onAppear {
            Task {
                await handleAuthorization()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPhoneFieldFocused = true
            }
        }
        .onTapGesture {
            isPhoneFieldFocused = false
        }
    }
    
    private func savePhoneNumber() {
        userDefaultsService.promoContactNumber = formatPhoneNumber()
    }
    
    private func formatPhoneNumber() -> String {
        return "+\(selectedCountry.dialCode.replacingOccurrences(of: "+", with: "")) \(phoneNumber)"
    }
    
    private func handleAuthorization() async {
        do {
            let authAdapter = try await networkService.validateSession()
            
        } catch {
            print("Authorization process error: \(error.localizedDescription)")
        }
    }
    
    private func formatPhoneInput(_ input: String) -> String {
        let numbers = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let limitedNumbers = String(numbers.prefix(15))
        
        if limitedNumbers.isEmpty {
            return ""
        }
        
        switch limitedNumbers.count {
        case 1...3:
            return limitedNumbers
        case 4...6:
            let firstPart = limitedNumbers.prefix(3)
            let secondPart = limitedNumbers.dropFirst(3)
            return "(\(firstPart)) \(secondPart)"
        case 7...8:
            let firstPart = limitedNumbers.prefix(3)
            let secondPart = limitedNumbers.dropFirst(3).prefix(3)
            let thirdPart = limitedNumbers.dropFirst(6)
            return "(\(firstPart)) \(secondPart)-\(thirdPart)"
        case 9...10:
            let firstPart = limitedNumbers.prefix(3)
            let secondPart = limitedNumbers.dropFirst(3).prefix(3)
            let thirdPart = limitedNumbers.dropFirst(6).prefix(2)
            let fourthPart = limitedNumbers.dropFirst(8)
            return "(\(firstPart)) \(secondPart)-\(thirdPart)-\(fourthPart)"
        default:
            return limitedNumbers
        }
    }
}

#Preview {
    PhoneNumberInputView(
        navigationPath: .constant(NavigationPath())
    )
}
