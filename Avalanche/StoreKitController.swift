//
//  StoreKitController.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/6/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import StoreKit

class StoreKitController: NSObject {
    static var mutableStoreDictionary: NSMutableDictionary!
    static var storeDictionaryURL: URL!
    static var coinsName: String = "numCoins"
    static let defaultCoinCost: Int = 2500
        
    static func getNumCoins() -> Int {
        if let numCoins = mutableStoreDictionary[coinsName] as? Int {
            return numCoins
        } else {
            return 0
        }
    }
    
    static func shouldShowAd() -> Bool {
        if StoreKitController.getPurchaseStatus(ofType: Purchase.RemoveAds) {
            return false
        } else {
            if let parity = mutableStoreDictionary["AdParity"] as? Int {
                let newParity: Int = (parity + 1) % 3
                mutableStoreDictionary.setValue(newParity, forKey: "AdParity")
                mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
                return parity == 2
            } else {
                return false
            }
        }
    }
    
    static func getPurchaseStatus(ofType purchaseType: Purchase) -> Bool {
        switch purchaseType {
        default:
            if let status = mutableStoreDictionary.value(forKey: purchaseType.rawValue) as? Bool {
                return status
            } else {
                return false
            }
        }
    }
    
    static func setPurchaseStatus(ofType purchaseType: Purchase, newStatus status: Bool) {
        switch purchaseType {
        default:
            mutableStoreDictionary.setValue(status, forKey: purchaseType.rawValue)
            mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
        }
    }
    
    static func readPurchasesFromStore() {
        guard let storeDefaultsFile: URL = Bundle.main.url(forResource: "StorePurchases", withExtension: "plist") else {
            NSLog("Unable to find default store file")
            return
        }
        
        guard let storeDefaultsDictionary: NSDictionary = NSDictionary(contentsOf: storeDefaultsFile) else {
            NSLog("Unable to open default store dictionary")
            return
        }
        
        let userDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if let storeDirectory = NSURL(fileURLWithPath: userDirectory).appendingPathComponent("StorePurchases.plist") {
            StoreKitController.storeDictionaryURL = storeDirectory
            
            if let storeDictionary = NSDictionary(contentsOf: storeDirectory) {
                StoreKitController.mutableStoreDictionary = storeDictionary.mutableCopy() as! NSMutableDictionary
                StoreKitController.mutableStoreDictionary = storeDictionary as! NSMutableDictionary
            } else {
                storeDefaultsDictionary.write(to: storeDirectory, atomically: true)
                StoreKitController.mutableStoreDictionary = storeDefaultsDictionary.mutableCopy() as! NSMutableDictionary
            }
        }
    }
    
    static func resetStoreFile() {
        let fileManager: FileManager = FileManager.default
        do {
            try fileManager.removeItem(at: storeDictionaryURL)
        } catch {
            NSLog("Unable to remove file at \(storeDictionaryURL.path) with thrown error \(error).")
        }
        
        readPurchasesFromStore()
        postNotification(withName: "ReloadStoreTable")
        postNotification(withName: "numCoinsChanged", andUserInfo: ["numCoins": 0])
        postNotification(withName: "arcadeModeStatusDidChange")
    }
}
