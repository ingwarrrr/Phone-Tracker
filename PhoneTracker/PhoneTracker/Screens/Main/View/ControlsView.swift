//
//  ControlsView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 22.03.2026.
//

import SwiftUI

struct ControlsView: View {
    @Binding var tapSettings: Bool
    var shouldHideControls: Bool = false
    
    var onLayersTap: (() -> Void)? = nil
    var onSOSTap: (() -> Void)? = nil
    var onLocationTap: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            VStack {
                ControlButton(
                    iconName: AssetCatalog.settingsButton,
                    action: { tapSettings.toggle() }
                )
                
                Spacer()
            }
            
            Spacer()
            
            VStack(spacing: 14) {
                ControlButton(
                    iconName: AssetCatalog.layersButton,
                    action: { onLayersTap?() }
                )
                
                EmergencyButton(
                    action: { onSOSTap?() }
                )
                
                ControlButton(
                    iconName: AssetCatalog.locateButton,
                    action: { onLocationTap?() }
                )
                .cornerRadius(24)
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .opacity(shouldHideControls ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: shouldHideControls)
        .disabled(shouldHideControls)
    }
}
