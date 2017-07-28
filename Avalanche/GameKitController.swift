//
//  GameKitController.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 10/21/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import UIKit
import GameKit

class GameKitController: NSObject {
    var localPlayerIsAuthenticated: Bool {
        get {
            let localPlayer = GKLocalPlayer.localPlayer()
            return localPlayer.isAuthenticated
        }
    }
    
    //MARK: Achievement-specific properties
    static var lastJumpDate: Date? {
        didSet {
            if let previousJumpDate = oldValue, let currentJumpDate = lastJumpDate {
                let secondsSinceLastJump: Double = currentJumpDate.timeIntervalSince(previousJumpDate)
                if secondsSinceLastJump > 10.0 {
                    GameKitController.report(Achievement.EarthBound, withPercentComplete: 100.0)
                }
            }
        }
    }
    
    static var lastMoveDate: Date? {
        didSet {
            if let previousMoveDate = oldValue, let currentMoveDate = lastMoveDate {
                let secondsSinceLastMove: Double = currentMoveDate.timeIntervalSince(previousMoveDate)
                if secondsSinceLastMove > 10.0 {
                    GameKitController.report(Achievement.Stoic, withPercentComplete: 100.0)
                }
            }
        }
    }
    
    //MARK: Helper Properties
    static var achievements: [GKAchievement]?
    
    static let leaderboardTableHandler: LeaderboardTableViewHandler = LeaderboardTableViewHandler()
    static let achievementTableHandler: AchievementTableViewHandler = AchievementTableViewHandler()
    
    static func report(_ score: Int, toLeaderboard leaderboard: LeaderboardTypes) {
        postNotification(withName: "reportScore", andUserInfo: ["highScore": score, "leaderboard": leaderboard.rawValue])
    }
    
    static func report(_ achievement: Achievement, withPercentComplete percentComplete: Double) {
        postNotification(withName: "reportAchievement", andUserInfo: ["achievementName": achievement.rawValue, "percentComplete": percentComplete])
    }
    
    static var mutableAchievementsDictionary: NSMutableDictionary!
    static var achievementDictionaryURL: URL!
    
    override init() {        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportScore), name: NSNotification.Name("reportScore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportAchievement), name: NSNotification.Name("reportAchievement"), object: nil)
    }
    
    //MARK: Achievements
    static func getAchievementProgress(achievementType: Achievement) -> Double {
        let achievementName: String = achievementType.rawValue
        if let achievementArray = GameKitController.achievements, achievementArray.count > 0 {
            for achievement in achievementArray {
                if let identifier = achievement.identifier, identifier == achievementName {
                    return achievement.percentComplete
                }
            }
        } else  {
            let achievementsDefaultsFile: URL = Bundle.main.url(forResource: "Achievements", withExtension: "plist")!
            let achievementsDefaultsDictionary: NSDictionary = NSDictionary(contentsOf: achievementsDefaultsFile)!
            
            let userDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            if let achievementsDirectory = NSURL(fileURLWithPath: userDirectory).appendingPathComponent("Achievements.plist") {
                if let achievementsDictionary = NSDictionary(contentsOf: achievementsDirectory) {
                    let mutableAchievementsDictionary: NSMutableDictionary = achievementsDictionary.mutableCopy() as! NSMutableDictionary
                    if let percentComplete = mutableAchievementsDictionary[achievementName] as? Double {
                        return percentComplete
                    }
                } else {
                    if let percentComplete = achievementsDefaultsDictionary[achievementName] as? Double {
                        return percentComplete
                    }
                }
            }
        }
        
        return 0.0
    }
    
    static func updateAchievementProgress(achievementType: Achievement, percentComplete: Double) {
        let achievementName: String = achievementType.rawValue
        if let achievementArray = GameKitController.achievements {
            for index in 0..<achievementArray.count {
                if achievementArray[index].identifier == achievementName {
                    GameKitController.achievements![index].percentComplete = percentComplete
                }
            }
        }
        
        GameKitController.mutableAchievementsDictionary.setValue(percentComplete, forKey: achievementName)
        GameKitController.mutableAchievementsDictionary.write(to: GameKitController.achievementDictionaryURL, atomically: true)
    }
    
    static func madeProgressTowardsAchievement(achievementType: Achievement) {
        switch achievementType {
        case .Smores, .Singed, .Pyromaniac:
            let numDeathsByFire: Int = Int(getAchievementProgress(achievementType: .Pyromaniac))
            let percentComplete: Double = Double(numDeathsByFire + 1)
            if numDeathsByFire < 25 {
                if numDeathsByFire == 24 {
                    GameKitController.report(.Smores, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.Smores, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Singed, withPercentComplete: percentComplete)
                GameKitController.report(.Pyromaniac, withPercentComplete: percentComplete)
            } else if numDeathsByFire < 50 {
                if numDeathsByFire == 49 {
                    GameKitController.report(.Singed, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.Singed, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Pyromaniac, withPercentComplete: percentComplete)
            } else if numDeathsByFire < 100 {
                GameKitController.report(.Pyromaniac, withPercentComplete: percentComplete)
            }
        default:
            return
        }
    }
    
    static func loadAchievementArray() {
        GKAchievement.loadAchievements(completionHandler: { (fetchedAchievements, error) in
            if error != nil {
                NSLog("There was an error while fetching completed achievements: \(error!)")
            }
            if let unwrappedAchievements = fetchedAchievements {
                GameKitController.achievements = unwrappedAchievements
                for achievement in unwrappedAchievements {
                    if let identifier = achievement.identifier {
                        let percentComplete: Double = achievement.percentComplete
                        GameKitController.mutableAchievementsDictionary.setValue(percentComplete, forKey: identifier)
                    }
                }
                GameKitController.mutableAchievementsDictionary.write(to: GameKitController.achievementDictionaryURL, atomically: true)
            }
        })
    }
    
    func reportAchievement(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: Any] else {
            return
        }
        
        guard let achievementName = dictionary["achievementName"] as? String else {
            return
        }
        
        guard let percentComplete = dictionary["percentComplete"] as? Double else {
            return
        }
        
        if let achievementType = Achievement(rawValue: achievementName) {
            GameKitController.updateAchievementProgress(achievementType: achievementType, percentComplete: percentComplete)
        }
        
        let localPlayer = GKLocalPlayer.localPlayer()
        guard localPlayer.isAuthenticated else {
            return
        }

        let achievement: GKAchievement = GKAchievement(identifier: achievementName, player: localPlayer)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { (error) in
            if error != nil {
                NSLog("Could not report achievement: \(error!)")
            }
        }
    }
    
    //MARK: Scores
    func reportScore(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: Any] else {
            return
        }
        
        guard let highScore: Int = dictionary["highScore"] as? Int else {
            return
        }
        
        guard let leaderboardIdentifier: String = dictionary["leaderboard"] as? String else {
            return
        }
        
        let localPlayer = GKLocalPlayer.localPlayer()
        guard localPlayer.isAuthenticated else {
            return
        }
        
        let scoreObject: GKScore = GKScore(leaderboardIdentifier: leaderboardIdentifier, player: localPlayer)
        scoreObject.value = Int64(highScore)
        
        GKScore.report([scoreObject], withCompletionHandler: { (error) in
            if error != nil {
                NSLog("Could not report score \(scoreObject) to leaderboard \(leaderboardIdentifier)")
            }
        })
    }
    
    //MARK: Authentication
    static func authenticateLocalPlayer() {
        DispatchQueue.main.async {
            let localPlayer = GKLocalPlayer.localPlayer()
            if localPlayer.isAuthenticated {
                postNotification(withName: "authenticationStatusChanged", andUserInfo: ["isAuthenticated":true])
                loadAchievementArray()
                return
            }
            
            localPlayer.authenticateHandler = { (viewController: UIViewController?, error: Error?) -> Void in
                unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                if viewController != nil {
                    
                    if let rootViewController = appDelegate.window?.rootViewController {
                        rootViewController.present(viewController!, animated: true, completion: nil)
                    }
                }
                else if localPlayer.isAuthenticated {
                    postNotification(withName: "authenticationStatusChanged", andUserInfo: ["isAuthenticated":true])
                    loadAchievementArray()
                }
                else {
                    postNotification(withName: "authenticationStatusChanged", andUserInfo: ["isAuthenticated":false])
                }
            }
        }
    }
}
