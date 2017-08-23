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
    
    static func getAllActivePowerUps() -> [PowerUpTypes] {
        var activePowerUps: [PowerUpTypes] = [PowerUpTypes.timeSlow, PowerUpTypes.mellowSlow]
        
        if getPurchaseStatus(ofType: Purchase.DayTime) {
            activePowerUps.append(PowerUpTypes.day)
            activePowerUps.append(PowerUpTypes.night)
        }
        if getPurchaseStatus(ofType: Purchase.JetPack) {
            activePowerUps.append(PowerUpTypes.jetPack)
            activePowerUps.append(PowerUpTypes.ballAndChain)
        }
        if getPurchaseStatus(ofType: Purchase.Shrink) {
            activePowerUps.append(PowerUpTypes.shrink)
            activePowerUps.append(PowerUpTypes.grow)
        }
        if getPurchaseStatus(ofType: Purchase.Teleport) {
            activePowerUps.append(PowerUpTypes.teleport)
            activePowerUps.append(PowerUpTypes.flip)
        }
        
        if getPurchaseStatus(ofType: Purchase.DoubleRandom) {
            activePowerUps.append(PowerUpTypes.doubleRandom)
        }
        if getPurchaseStatus(ofType: Purchase.PowerBeGone) {
            activePowerUps.append(PowerUpTypes.removeAll)
        }
        if getPurchaseStatus(ofType: Purchase.Rewind) {
            activePowerUps.append(PowerUpTypes.resetPowerUps)
        }
        
        return activePowerUps
    }
    
    static func getPositiveActivePowerUps() -> [PowerUpTypes]  {
        var activePowerUps: [PowerUpTypes] = [PowerUpTypes.timeSlow]
        
        if getPurchaseStatus(ofType: Purchase.DayTime) {
            activePowerUps.append(PowerUpTypes.day)
        }
        if getPurchaseStatus(ofType: Purchase.JetPack) {
            activePowerUps.append(PowerUpTypes.jetPack)
        }
        if getPurchaseStatus(ofType: Purchase.Shrink) {
            activePowerUps.append(PowerUpTypes.shrink)
        }
        if getPurchaseStatus(ofType: Purchase.Teleport) {
            activePowerUps.append(PowerUpTypes.teleport)
        }
        
        return activePowerUps
    }
    
    static func getNegativeActivePowerUps() -> [PowerUpTypes]  {
        var activePowerUps: [PowerUpTypes] = [PowerUpTypes.mellowSlow]
        
        if getPurchaseStatus(ofType: Purchase.DayTime) {
            activePowerUps.append(PowerUpTypes.night)
        }
        if getPurchaseStatus(ofType: Purchase.JetPack) {
            activePowerUps.append(PowerUpTypes.ballAndChain)
        }
        if getPurchaseStatus(ofType: Purchase.Shrink) {
            activePowerUps.append(PowerUpTypes.grow)
        }
        if getPurchaseStatus(ofType: Purchase.Teleport) {
            activePowerUps.append(PowerUpTypes.flip)
        }
        
        return activePowerUps
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
    }
}
