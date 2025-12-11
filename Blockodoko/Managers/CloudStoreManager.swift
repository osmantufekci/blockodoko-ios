//
//  CloudStoreManager.swift
//  Blockodoko
//
//  Created by Osman Tüfekçi on 11.12.2025.
//
import Foundation

final class CloudStoreManager {
    static let shared = CloudStoreManager()
    private let store = NSUbiquitousKeyValueStore.default

    private init() {
        // iCloud'dan veri değişimi bildirimi
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeExternally),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )

        let synced = store.synchronize()
        print("☁️ [DEBUG] iCloud Başlatıldı. Senkronizasyon isteği: \(synced ? "Başarılı" : "Başarısız")")

        // Mevcut veriyi yazdır
        printCurrentState()
    }

    @objc func didChangeExternally(notification: NSNotification) {
        let changeReason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
        let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]

        print("☁️ [DEBUG] DIŞARIDAN VERİ GELDİ! 📥")
        print("   - Sebep: \(changeReason ?? -1)")
        print("   - Değişen Anahtarlar: \(changedKeys ?? [])")

        NotificationCenter.default.post(name: .cloudDataUpdated, object: nil)
        printCurrentState()
    }

    func save(level: Int, coins: Int) {
        print("☁️ [DEBUG] iCloud'a Kaydediliyor... 📤 (Level: \(level), Coins: \(coins))")
        store.set(Int64(level), forKey: "userCurrentLevel")
        store.set(Int64(coins), forKey: "gm_coins")
        let success = store.synchronize()
        print("   - Sync Komutu Gönderildi: \(success ? "✅" : "❌")")
    }

    func getLevel() -> Int {
        return Int(store.longLong(forKey: "userCurrentLevel"))
    }

    func getCoins() -> Int {
        return Int(store.longLong(forKey: "gm_coins"))
    }

    // Debug için mevcut durumu konsola dök
    func printCurrentState() {
        let dict = store.dictionaryRepresentation
        print("🔍 [DEBUG] Şu anki iCloud Verisi: \(dict)")
    }
}

extension Notification.Name {
    static let cloudDataUpdated = Notification.Name("cloudDataUpdated")
}
