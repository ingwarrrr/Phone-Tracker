//
//  PaywallSecondView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit
import Adapty
import Factory

struct OfferSecondView: View {
    @Environment(\.dismiss) private var dismiss
    @InjectedObject(\.adaptyService) private var adaptyService
    @Injected(\.networkService) private var networkService
    
    @State private var selectedOption: SubscriptionOption?
    @State private var options: [SubscriptionOption] = []
    @State private var isProcessingPurchase = false
    @State private var purchaseError: String?
    
    private let backgroundImageName: String = AssetCatalog.promoBackgroundA
    private var featuresListTexts: [String] = AssetCatalog.promoFeatureIcons
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.height <= 667
    }
    
    let showDismissBTN: Bool
    let isFlowFirst: Bool
    let onComplete: () -> Void
    
    public init(showDismissBTN: Bool, isFlowFirst: Bool = false, onComplete: @escaping () -> Void = {}) {
        self.showDismissBTN = showDismissBTN
        self.isFlowFirst = isFlowFirst
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundContentView
            
            VStack {
                if !isFlowFirst {
                    AnimatingView(name: AssetCatalog.onboardingVideoB)
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.7)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        if let error = adaptyService.loadingFailure {
                            errorView(error)
                        } else {
                            contentView
                        }
                    }
                    .background(
                        AppColors.mainBG
                            .cornerRadius(46, corners: [.topLeft, .topRight])
                            .edgesIgnoringSafeArea(.bottom)
                    )
                    
                    Image(AssetCatalog.promoIconSet)
                        .resizable()
                        .frame(width: 231, height: 116)
                        .offset(y: -42)
                }
            }
            
            if showDismissBTN {
                closeButton
            } else {
                PhoneNumberPopup(
                    showPopup: .constant(true),
                    verificationStatus: .constant(.confirmedSuccess)
                )
            }
            
            if isProcessingPurchase  {
                loadingView
            }
        }
        .onAppear {
            // TODO: use loadAdaptyProducts after receiving the link to the real products
//        loadAdaptyProducts()
            loadTestProducts()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.white)
            Text("Error loading subscriptions")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 16)
            Text(error.localizedDescription)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
            
            GradientButton(title: "Retry") {
                // TODO: use loadAdaptyProducts after receiving the link to the real products
//                loadAdaptyProducts()
                loadTestProducts()
            }
            .padding(.top, 24)
            .padding(.horizontal)
            .padding(.bottom)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        Group {
            headerSection
            featuresGrid
            optionsList
            cancelationText
            subscribeButton
            footerButtons
        }
    }
    
    private var backgroundContentView: some View {
        Group {
            let mapRegion = MKCoordinateRegion(
                center: networkService.currentMapCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0042, longitudeDelta: 0.0042)
            )
            
            PhoneNumberMapView(region: .constant(mapRegion))
                .ignoresSafeArea()
        }
    }
    
    private var closeButton: some View {
        VStack {
            Button(action: {
                onComplete()
                dismiss()
            }) {
                Image(AssetCatalog.dismissIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 32, height: 32)
            .padding(.top, 8)
            .padding(.trailing, 24)
            .disabled(isProcessingPurchase)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    private var headerSection: some View {
        Text(Localizable.Offer.protectMatters)
            .foregroundColor(.white)
            .font(.system(size: 28, weight: .semibold))
            .multilineTextAlignment(.center)
            .padding(.top, isSmallDevice ? 66 : 86)
            .padding(.bottom, isSmallDevice ? 8 : 24)
    }
    
    private var featuresGrid: some View {
        VStack(spacing: isSmallDevice ? 8 : 16) {
//            InfiniteFeaturesRow(direction: .leftToRight)
//                .frame(height: 24)
//            InfiniteFeaturesRow(direction: .rightToLeft)
//                .frame(height: 24)
        }
        .overlay {
            Image(AssetCatalog.promoFeatureImage)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: isSmallDevice ? 56 : 64)
        }
        .padding(.bottom, isSmallDevice ? 8 : 32)
    }
    
    private var optionsList: some View {
        VStack(spacing: 0) {
            ForEach(options) { option in
                OfferOptionView(
                    option: option,
                    isSelected: selectedOption?.id == option.id
                )
                .onTapGesture {
                    withAnimation {
                        selectedOption = option
                    }
                }
                .disabled(isProcessingPurchase )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 4)
        )
        .padding(.bottom, isSmallDevice ? 8 : 16)
        .padding(.horizontal, 24)
    }
    
    private var cancelationText: some View {
        Text(Localizable.Offer.cancelAnytime)
            .foregroundColor(.white.opacity(0.4))
            .font(.system(size: 14, weight: .regular))
    }
    
    private var subscribeButton: some View {
        GradientButton(
            title: Localizable.Common.continueText,
            showPlusIcon: false
        ) {
            handleSubscription()
        }
        .disabled(selectedOption == nil || adaptyService.isLoadingData || isProcessingPurchase )
        .padding(.vertical, isSmallDevice ? 4 : 8)
        .padding(.horizontal, 24)
    }
    
    private var footerButtons: some View {
        HStack {
            Button(action: {
                openBrowser(AppConstants.termsPageURL)
            }) {
                Text(Localizable.Settings.termsOfUse)
            }
            .disabled(isProcessingPurchase)
            
            Spacer()
            
            Button(action: {
                restorePurchases()
            }) {
                Text(Localizable.Offer.restore)
            }
            .disabled(isProcessingPurchase)
            
            Spacer()
            
            Button(action: {
                openBrowser(AppConstants.privacyPageURL)
            }) {
                Text(Localizable.Settings.privacyPolicy)
            }
            .disabled(isProcessingPurchase)
        }
        .foregroundColor(.white.opacity(0.4))
        .font(.system(size: 12, weight: .regular))
        .padding(.horizontal, 32)
    }
    
    // MARK: - Methods
    
    private func loadAdaptyProducts() {
        let adaptyProducts = adaptyService.availableProducts(for: AppConstants.adaptyPlacementFirst)
        
        if !adaptyProducts.isEmpty {
            options = createSubscriptionOptions(from: adaptyProducts)
            selectedOption = options.first(where: { $0.isHighlighted }) ?? options.first
        }
    }
    
    private func loadTestProducts() {
        options = createTestSubscriptionOptions()
        selectedOption = options.first(where: { $0.isHighlighted }) ?? options.first
    }
    
    private func createTestSubscriptionOptions() -> [SubscriptionOption] {
        return [
            SubscriptionOption(
                type: .monthly,
                price: 14.99,
                priceTitle: "Monthly",
                priceText: "$15.99/month",
                description: "Save 25%",
                isHighlighted: false
            ),
            SubscriptionOption(
                type: .weekly,
                price: 4.99,
                priceTitle: "Weekly",
                priceText: "$7.99/week",
                description: "Most Popular",
                isHighlighted: true
            ),
            SubscriptionOption(
                type: .annual,
                price: 99.99,
                priceTitle: "Annual",
                priceText: "$79.99/year",
                description: "Best Value",
                isHighlighted: false
            )
        ]
    }
    
    private func createSubscriptionOptions(from products: [AdaptyPaywallProduct]) -> [SubscriptionOption] {
        let options = products.map { product in
            let subscriptionType = getSubscriptionType(from: product)
            let isHighlighted = subscriptionType == .weekly
            let priceText = formatPriceText(for: subscriptionType, product: product)
            let priceTitle = formatPriceTitle(for: subscriptionType, product: product)
            
            return SubscriptionOption(
                type: subscriptionType,
                price: product.price,
                priceTitle: priceTitle,
                priceText: priceText,
                description: getDescription(for: subscriptionType),
                isHighlighted: isHighlighted,
                adaptyProduct: product
            )
        }
        
        return options.sorted { $0.isHighlighted && !$1.isHighlighted }
    }
    
    private func formatPriceText(for type: SubscriptionOption.SubscriptionType, product: AdaptyPaywallProduct) -> String {
        if let localizedPrice = product.localizedPrice {
            switch type {
            case .weekly:
                return "\(localizedPrice)/\(Localizable.Common.week)"
            case .monthly:
                return "\(localizedPrice)/\(Localizable.Common.month)"
            case .annual:
                return "\(localizedPrice)/\(Localizable.Common.year)"
            }
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let priceString = formatter.string(from: product.price as NSDecimalNumber) ?? "\(product.price)"
        
        switch type {
        case .weekly:
            return "\(priceString)/\(Localizable.Common.week)"
        case .monthly:
            return "\(priceString)/\(Localizable.Common.month)"
        case .annual:
            return "\(priceString)/\(Localizable.Common.year)"
        }
    }
    
    private func formatPriceTitle(for type: SubscriptionOption.SubscriptionType, product: AdaptyPaywallProduct) -> String {
        switch type {
        case .weekly:
            return Localizable.Common.weekly
        case .monthly:
            return Localizable.Common.monthly
        case .annual:
            return Localizable.Common.annual
        }
    }
    
    private func getSubscriptionType(from product: AdaptyPaywallProduct) -> SubscriptionOption.SubscriptionType {
        let productId = product.vendorProductId.lowercased()
        
        if productId.contains("week") || productId.contains("weekly") {
            return .weekly
        } else if productId.contains("year") || productId.contains("annual") {
            return .annual
        } else {
            return .monthly
        }
    }
    
    private func getDescription(for type: SubscriptionOption.SubscriptionType) -> String {
        switch type {
        case .monthly:
            let discount = calculateDiscount()
            return String(format: Localizable.Offer.savePercent, discount)
        case .weekly:
            return Localizable.Offer.mostPopular
        case .annual:
            return Localizable.Offer.bestValue
        }
    }
    
    private func calculateDiscount() -> Int {
        let adaptyProducts = adaptyService.availableProducts(for: AppConstants.adaptyPlacementFirst)
        
        if !adaptyProducts.isEmpty {
            guard let weeklyProduct = adaptyProducts.first(where: { $0.vendorProductId.lowercased().contains("week") }),
                  let monthlyProduct = adaptyProducts.first(where: { $0.vendorProductId.lowercased().contains("month") }) else {
                return 0
            }
            
            let weeklyPrice = weeklyProduct.price
            let monthlyPrice = monthlyProduct.price
            
            return SubscriptionOption.calculateDiscount(weeklyPrice: weeklyPrice, monthlyPrice: monthlyPrice)
        } else {
            return 0
        }
    }
    
    private func handleSubscription() {
        guard let selected = selectedOption,
              let adaptyProduct = selected.adaptyProduct else { return }
        
        isProcessingPurchase = true
        
        Task {
            do {
                let purchaseResult = try await adaptyService.executePurchase(adaptyProduct)
                
                try await adaptyService.refreshProfile()
                
                await MainActor.run {
                    isProcessingPurchase = false
                    
                    if adaptyService.hasActiveSubscription {
                        onComplete()
                        dismiss()
                    } else {
                        purchaseError = "Purchase completed but subscription is not active"
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessingPurchase = false
                    
                    purchaseError = "Purchase failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func restorePurchases() {
        isProcessingPurchase = true
        
        Task {
            do {
                let profile = try await adaptyService.recoverPreviousPurchases()
                
                await MainActor.run {
                    isProcessingPurchase = false
                    if adaptyService.hasActiveSubscription {
                        onComplete()
                        dismiss()
                    } else {
                        purchaseError = "No active subscriptions found"
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessingPurchase = false
                    purchaseError = "Restore failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func openBrowser(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    OfferSecondView(showDismissBTN: false)
}
