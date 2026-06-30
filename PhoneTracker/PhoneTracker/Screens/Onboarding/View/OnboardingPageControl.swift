//
//  OnboardingPageControl.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI

struct OnboardingPageControl: View {
    let pageCount: Int
    let page: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(index == page ? 1.0 : 0.12))
                    .frame(
                        width: index == page ? 18 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: page)
            }
        }
    }
}
