//
//  ProductID.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 12.12.2025.
//
import Foundation
import StoreKit
import Combine

enum ProductID: String, CaseIterable {
    case unknown = ""
    case coins500 = "Blockodoko.500" // 2,99
    case coins1000 = "Blockodoko.1000" // 5,98
    case coins2500 = "Blockodoko.2500" // BEST: 9,99 - %65
    case removeAds = "Blockodoko.RemoveAds" // 9,99

    init?(_ rawValue: String) {
        self = ProductID(rawValue: rawValue) ?? .unknown
    }

    var amount: Int {
        return switch self {
        case .coins500: 500
        case .coins1000: 1000
        case .coins2500: 2500
        case .removeAds: 0
        case .unknown: 0
        }
    }
}

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false

    var onCoinPurchase: ((Int) -> Void)?
    
    private var updates: Task<Void, Never>? = nil

    private init() {
        updates = newTransactionListenerTask()
    }

    deinit {
        updates?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            let ids = ProductID.allCases.map { $0.rawValue }
            let products = try await Product.products(for: ids)
            self.products = products.sorted(by: { $0.price < $1.price })

            await updatePurchasedProducts()
            
            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            isLoading = false
        }
    }
    
    // 2. Satın Alma Fonksiyonu
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // İşlem başarılı, şimdi doğrula ve uygula
                let transaction = try checkVerified(verification)
                
                // İçeriği ver
                await handlePurchase(transaction: transaction)
                
                // İşlemi kapat (Apple'a bittiğini bildir)
                await transaction.finish()
                
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    // 3. Geçmiş Alımları Güncelle (Restore)
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    // 4. İşlem Doğrulama ve İçerik Verme
    private func handlePurchase(transaction: Transaction) async {
        if transaction.productType == .consumable {
            // Coin Paketleri
            let coinAmount: Int
            coinAmount = ProductID(transaction.productID)?.amount ?? 0

            onCoinPurchase?(coinAmount)

            HapticManager.shared.useJoker()
            
        } else if transaction.productType == .nonConsumable {
            purchasedProductIDs.insert(transaction.productID)
            UserDefaults.standard.set(true, forKey: "isAdsRemoved")
        }
    }
    
    // Güvenlik Kontrolü
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // Arka Planda Dinleyici (Uygulama kapalıyken alınanlar vs için)
    private func newTransactionListenerTask() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? await self.checkVerified(result) {
                    await self.handlePurchase(transaction: transaction)
                    await transaction.finish()
                }
            }
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
