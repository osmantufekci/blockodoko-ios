//
//  ShopView.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 12.12.2025.
//
import SwiftUI
import StoreKit

struct ShopView: View {
    @StateObject var storeManager = StoreManager.shared
    @EnvironmentObject var navigation: NavigationManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("SHOP")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                
                if storeManager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(storeManager.products) { product in
                                ProductRow(product: product) {
                                    Task {
                                        await storeManager.purchase(product)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            // Ekran açılınca ürünleri yükle
            await storeManager.loadProducts()
        }
    }
}

// Ürün Kartı Tasarımı
struct ProductRow: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        HStack {
            // İkon (Basit mantık)
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Satın Al Butonu
            Button(action: action) {
                Text(product.displayPrice)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    var iconName: String {
        if product.type == .consumable { return "bitcoinsign.circle.fill" }
        return "eye.slash.fill" // Remove Ads
    }
}

#Preview {
    NavigationStack {
        NavigationView {
            ShopView()
        }
    }
}
