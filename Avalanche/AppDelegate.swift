//
//  AppDelegate.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/21/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import UIKit
import GameKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var gameViewController: GameViewController!
    var gameKitController: GameKitController!
    
    func loadGameKitControllerClass() {
        guard let achievementsDefaultsFile: URL = Bundle.main.url(forResource: "Achievements", withExtension: "plist") else {
            NSLog("Unable to find default achievement file")
            return
        }
        guard let achievementsDefaultsDictionary: NSDictionary = NSDictionary(contentsOf: achievementsDefaultsFile) else {
            NSLog("Unable to open default achievement dictionary")
            return
        }
        
        let userDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if let achievementsDirectory = NSURL(fileURLWithPath: userDirectory).appendingPathComponent("Achievements.plist") {
            GameKitController.achievementDictionaryURL = achievementsDirectory
            
            if let achievementsDictionary = NSDictionary(contentsOf: achievementsDirectory) {
                GameKitController.mutableAchievementsDictionary = achievementsDictionary.mutableCopy() as! NSMutableDictionary
            } else {
                achievementsDefaultsDictionary.write(to: achievementsDirectory, atomically: true)
                GameKitController.mutableAchievementsDictionary = achievementsDefaultsDictionary.mutableCopy() as! NSMutableDictionary
            }
        }
        
        guard let statusDefaultsFile: URL = Bundle.main.url(forResource: "AchievementStatus", withExtension: "plist") else {
            NSLog("Unable to find default status file")
            return
        }
        guard let statusDefaultsDictionary: NSDictionary = NSDictionary(contentsOf: statusDefaultsFile) else {
            NSLog("Unable to open default status dictionary")
            return
        }
        if let statusDirectory = NSURL(fileURLWithPath: userDirectory).appendingPathComponent("AchievementStatus.plist") {
            GameKitController.statusDictionaryURL = statusDirectory
            if let statusDictionary = NSDictionary(contentsOf: statusDirectory) {
                GameKitController.mutableAchievementStatusDictionary = statusDictionary.mutableCopy() as! NSMutableDictionary
            } else {
                statusDefaultsDictionary.write(to: statusDirectory, atomically: true)
                GameKitController.mutableAchievementStatusDictionary = statusDefaultsDictionary.mutableCopy() as! NSMutableDictionary
            }
        }        
        
        gameKitController = GameKitController()
        //Initialize the GameCenter Player
        GameKitController.authenticateLocalPlayer()
    }
    
    func loadStoreKitControllerClass() {
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
    
    func setMusicPreferences() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            NSLog("Unable to share audio session with error \(error)")
        }
        
        let userPreferences: UserDefaults = UserDefaults.standard
        
        guard let defaultPreferencesFile: URL = Bundle.main.url(forResource: "DefaultPreferences", withExtension: "plist") else {
            NSLog("Unable to find default preferences file")
            return
        }
        guard let defaultPreferencesDictionary: NSDictionary = NSDictionary(contentsOf: defaultPreferencesFile) else {
            NSLog("Unable to open default preferences dictionary")
            return
        }
        
        userPreferences.register(defaults: defaultPreferencesDictionary as! [String : Any])
        
        userPreferences.set(!AVAudioSession.sharedInstance().isOtherAudioPlaying, forKey: "SoundEffects")
        userPreferences.set(!AVAudioSession.sharedInstance().isOtherAudioPlaying, forKey: "Audio")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        loadGameKitControllerClass()
        loadStoreKitControllerClass()
        setMusicPreferences()
        
        //Bring up the gameViewController
        gameViewController = GameViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.black
        self.window!.rootViewController = gameViewController
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        GameKitController.lastPauseDate = Date()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

