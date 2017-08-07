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
    static var arcadeName: String = "arcadeUnlocked"
    static var adsName: String = "adsRemoved"
    
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
    
    static func setArcadeStatus(toStatus status: Bool) {
        mutableStoreDictionary.setValue(status, forKey: arcadeName)
        mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
    }
    
    static func setAdsStatus(toStatus status: Bool) {
        mutableStoreDictionary.setValue(status, forKey: adsName)
        mutableStoreDictionary.write(to: storeDictionaryURL, atomically: true)
    }
}
