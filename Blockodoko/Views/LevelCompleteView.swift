//
//  LevelCompleteView.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 12.12.2025.
//


import SwiftUI

struct LevelCompleteView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var adsManager: AdsManager

    var baseReward: Int = 50
    let onNextLevel: () -> Void
    
    // Animasyon ve Durumlar
    @State private var isAnimating = false
    @State private var hasWatchedAd = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.5))

            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .orange.opacity(0.6), radius: 20, x: 0, y: 0)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)

                    Text("LEVEL COMPLETED!")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text("+ \(baseReward) Coins Earned")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
                .padding(.top, 20)
                let _ = print("loaded1:", adsManager.isRewardedAdLoaded)
                if !adsManager.isAdsRemoved && adsManager.isRewardedAdLoaded {
                    Button(action: {
                        HapticManager.shared.buttonTap()

                        AdsManager.shared.showRewardedAd { rewardAmount in
                            StoreManager.shared.onCoinPurchase?(rewardAmount)
                            HapticManager.shared.success()

                            withAnimation {
                                hasWatchedAd = true
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.tv.fill")
                                .font(.title3)

                            Text("WATCH & EARN")
                                .font(.headline)
                                .fontWeight(.heavy)

                            HStack(spacing: 4) {
                                Text("X2")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .foregroundColor(.yellow)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "00b09b"), Color(hex: "96c93d")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "00b09b").opacity(0.4), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    let _ = print("loaded:", adsManager.isRewardedAdLoaded)
                } else if hasWatchedAd {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Bonus Collected!")
                    }
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .frame(height: 60)
                }

                Button(action: {
                    HapticManager.shared.buttonTap()
                    onNextLevel()
                }) {
                    HStack {
                        Text("NEXT LEVEL")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 340)
            .background(Color.themeBackground.opacity(0.9)) // Koyu tema arka plan
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isAnimating ? 1 : 0.8)
            .opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LevelCompleteView(baseReward: 175, onNextLevel: {})
        .environmentObject(GameViewModel())
        .environmentObject(AdsManager.shared)
}
