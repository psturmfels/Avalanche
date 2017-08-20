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
    
    static let storeTableHandler: StoreTableViewHandler = StoreTableViewHandler()
    
    static func getNumCoins() -> Int {
        if let numCoins = mutableStoreDictionary[coinsName] as? Int {
            return numCoins
        } else {
            return 0
        }
    }
    
    static func addCoins(_ numCoins: Int) {
        guard numCoins > 0 else {
            return
        }
        
        let currentNumCoins: Int = getNumCoins()
        let newNumCoins: Int = currentNumCoins + numCoins
        mutableStoreDictionary.setValue(newNumCoins, forKey: coinsName)
        mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
        
        postNotification(withName: "numCoinsChanged", andUserInfo: ["numCoins": newNumCoins])
    }
    
    static func subtractCoins(_ numCoins: Int) {
        guard numCoins > 0 else {
            return
        }
        
        let currentNumCoins: Int = getNumCoins()
        let newNumCoins: Int = currentNumCoins - numCoins
        mutableStoreDictionary.setValue(newNumCoins, forKey: coinsName)
        mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
        
        postNotification(withName: "numCoinsChanged", andUserInfo: ["numCoins": newNumCoins])
    }
    
    static func getPurchaseStatus(ofType purchaseType: Purchase) -> Bool {
        switch purchaseType {
        case .StashOCoins, .PileOCoins, .TreasureChest, .RemoveAds, .SupportTheDev:
            return false
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
        case .StashOCoins, .PileOCoins, .TreasureChest, .RemoveAds, .SupportTheDev:
            return
        default:
            mutableStoreDictionary.setValue(status, forKey: purchaseType.rawValue)
            mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
        }
    }
}
