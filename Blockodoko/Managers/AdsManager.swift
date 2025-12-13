//
//  AdsManager.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 12.12.2025.
//
import GoogleMobileAds
import SwiftUI
import UIKit
import Combine

final class AdsManager: NSObject, ObservableObject {
    static let shared = AdsManager()

    final let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    final let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    private var rewardedAd: RewardedAd?
    private var interstitialAd: InterstitialAd?

    @Published var isRewardedAdLoaded: Bool = false
    @Published var insterstitialAdLoaded: Bool = false

    override init() {
        super.init()
        loadRewardedAd()
        loadInterstitialAd()
    }

    var isAdsRemoved: Bool {
//        return UserDefaults.standard.bool(forKey: "isAdsRemoved")
        false
    }
    
    // MARK: - 1. REWARDED AD (Ödüllü)

    func loadRewardedAd() {
        let request = Request()

        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Rewarded ad failed to load: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            self?.isRewardedAdLoaded = self?.rewardedAd != nil
            print("🎁 Ödüllü Reklam Hazır!")
        }
    }

    func showRewardedAd(onReward: @escaping (Int) -> Void) {
        guard let root = getRootViewController() else { return }

        if let ad = rewardedAd {
            ad.present(from: root) {
                let reward = ad.adReward
                print("Reward received: \(reward.amount) \(reward.type)")
                onReward(100)
            }
        } else {
            print("Ad wasn't ready")
            loadRewardedAd()
        }
    }

    // MARK: - 2. REWARDED AD (Ödülü Katla)
    func showDoubleRewardAd(amount: Int, onReward: @escaping (Int) -> Void) {
        guard let root = getRootViewController() else { return }
        
        if let ad = rewardedAd {
            ad.present(from: root) {
                let reward = ad.adReward
                print("Reward received: \(reward.amount) \(reward.type)")
                onReward(amount)
            }
        } else {
            print("Ad wasn't ready")
            loadRewardedAd()
            onReward(amount)
        }
    }
    
    // MARK: - 2. INTERSTITIAL AD (Geçiş)
    
    func loadInterstitialAd() {
        if isAdsRemoved { return }
        
        let request = Request() // GADRequest -> Request
        
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Interstitial failed to load: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            self?.insterstitialAdLoaded = self?.interstitialAd != nil
            print("📺 Geçiş Reklamı Hazır!")
        }
    }
    
    func showInterstitialAd() {
        if isAdsRemoved { return }
        
        guard let root = getRootViewController() else { return }
        
        if let ad = interstitialAd {
            ad.present(from: root)
        } else {
            print("Interstitial wasn't ready")
            loadInterstitialAd()
        }
    }
    
    // MARK: - Helper: Root ViewController Bulucu
    private func getRootViewController() -> UIViewController? {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return screen.windows.first?.rootViewController
    }
}

// MARK: - Delegate (GADFullScreenContentDelegate -> FullScreenContentDelegate)
extension AdsManager: FullScreenContentDelegate {
    
    // GADFullScreenPresentingAd -> FullScreenPresentingAd
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed. Loading next one...")
        
        if ad is RewardedAd {
            loadRewardedAd()
        } else if ad is InterstitialAd {
            loadInterstitialAd()
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        if ad is RewardedAd { loadRewardedAd() }
        else if ad is InterstitialAd { loadInterstitialAd() }
    }
}
