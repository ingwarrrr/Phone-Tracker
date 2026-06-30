//
//  CountryCodePicker.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI

struct CountryCodePicker: View {
    @Binding var selectedCountry: PhoneCountry
    @Binding var searchText: String
    @Binding var isPresented: Bool
    
    var filteredCountries: [PhoneCountry] {
        searchText.isEmpty ? PhoneCountry.availableCountries :
        PhoneCountry.availableCountries.filter {
            $0.countryName.lowercased().contains(searchText.lowercased()) ||
            $0.dialCode.lowercased().contains(searchText.lowercased()) ||
            $0.countryCode.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack {
            Capsule().frame(width: 39, height: 5)
                .foregroundColor(.white.opacity(0.1))
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            HStack {
                HStack {
                    Image(AssetCatalog.magnifyIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    TextField("", text: $searchText)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .autocorrectionDisabled()
                        .placeholder(
                            searchText,
                            placeholder: Localizable.Onboard.search,
                            color: .white.opacity(0.4)
                        )
                }
                .padding(.leading)
                .frame(height: 46)
                .background(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.white.opacity(0.04), lineWidth: 1)
                )
                .cornerRadius(15)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text(Localizable.Common.cancel)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                }
                .padding(.leading)
            }
            .frame(height: 46)
            .padding(.horizontal, 24)
            
            List(filteredCountries) { country in
                Button(action: {
                    selectedCountry = country
                    isPresented = false
                }) {
                    ZStack(alignment: .bottom) {
                        HStack(spacing: 4) {
                            Text(country.flagEmoji)
                            
                            Text(country.countryName)
                            
                            Spacer()
                            
                            Text(country.dialCode)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .frame(height: 55)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(AppColors.mainBG)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.mainBG)
            .padding(.top, 8)
            .padding(.horizontal, 24)
        }
        .onDisappear {
            searchText = ""
            if isPresented {
                isPresented = false
            }
        }
        .cornerRadius(32)
        .background(AppColors.mainBG)
    }
}

#Preview {
    CountryCodePicker(
        selectedCountry: .constant(PhoneCountry(countryName: "USA", dialCode: "+1", countryCode: "+1")),
        searchText: .constant(""),
        isPresented: .constant(true)
    )
}
