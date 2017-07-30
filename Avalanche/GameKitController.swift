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
    //MARK: AchievementTableViewHandler Properties
    static var achievementDescriptions: [GKAchievementDescription] = [GKAchievementDescription]()
    static var achievementProgress: [String:Double] = [String:Double]()
    static var achievementImages: [String:UIImage] = [String:UIImage]()
    static var achievementsAreLoaded: Bool = false
    
    static var localPlayerIsAuthenticated: Bool {
        get {
            let localPlayer = GKLocalPlayer.localPlayer()
            return localPlayer.isAuthenticated
        }
    }
    
    //MARK: LeaderboardTableViewHandler Properties
    static var scoresAreLoaded: Bool = false
    
    static var leaderboards: [GKLeaderboard]!
    static var scores: [String: [GKScore]] = [String: [GKScore]]()
    static var currentLeaderboard: String?
    
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
    
    static var lastPauseDate: Date?
    
    static var lastUnpauseDate: Date? {
        didSet {
            if let pauseDate = lastPauseDate, let unpauseDate = lastUnpauseDate {
                let secondsSinceLastPause: Double = unpauseDate.timeIntervalSince(pauseDate)
                if secondsSinceLastPause > 30.0 {
                    GameKitController.report(Achievement.AFK, withPercentComplete: 100.0)
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
        case .TestRun, .Interested, .Dedicated, .Committed:
            let pastProgress: Double = GameKitController.getAchievementProgress(achievementType: .Committed)
            let numTimesPlayed: Int = Int(pastProgress * 5.0)
            let percentComplete: Double = pastProgress + 0.2
            
            if numTimesPlayed < 10 {
                if numTimesPlayed == 10 {
                    GameKitController.report(.TestRun, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.TestRun, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Interested, withPercentComplete: percentComplete)
                GameKitController.report(.Dedicated, withPercentComplete: percentComplete)
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
            } else if numTimesPlayed < 100 {
                if numTimesPlayed == 99 {
                    GameKitController.report(.Interested, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.Interested, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Dedicated, withPercentComplete: percentComplete)
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
            } else if numTimesPlayed < 250 {
                if numTimesPlayed == 249 {
                    GameKitController.report(.Dedicated, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.Dedicated, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
            } else if numTimesPlayed < 500 {
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
            }
            
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
        case .Squashed, .Flattened, .Pancaked:
            let numDeathsByCrushed: Int = Int(getAchievementProgress(achievementType: .Pancaked))
            let percentComplete: Double = Double(numDeathsByCrushed + 1)
            if numDeathsByCrushed < 25 {
                if numDeathsByCrushed == 24 {
                    GameKitController.report(.Squashed, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.Squashed, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Flattened, withPercentComplete: percentComplete)
                GameKitController.report(.Pancaked, withPercentComplete: percentComplete)
            } else if numDeathsByCrushed < 50 {
                if numDeathsByCrushed == 49 {
                    GameKitController.report(.Flattened, withPercentComplete: 100.0)
                } else {
                    GameKitController.report(.Flattened, withPercentComplete: percentComplete)
                }
                
                GameKitController.report(.Pancaked, withPercentComplete: percentComplete)
            } else if numDeathsByCrushed < 100 {
                GameKitController.report(.Pancaked, withPercentComplete: percentComplete)
            }
            
        default:
            return
        }
    }
    
    static func loadAchievementArray() {
        if let unwrappedAchievements = GameKitController.achievements, unwrappedAchievements.count > 0 {
            return
        }
        
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
                
                for achievementProgressObject in unwrappedAchievements {
                    if let identifier = achievementProgressObject.identifier {
                        GameKitController.achievementProgress[identifier] = achievementProgressObject.percentComplete
                    }
                }
                
                GameKitController.achievementsAreLoaded = true
            }
        })
        GKAchievementDescription.loadAchievementDescriptions { (descriptions, error) in
            if let error = error {
                NSLog("Failed to load achievement descriptions with error \(error).")
            }
            
            guard let descriptions = descriptions else {
                NSLog("Failed to unwrap achievements.")
                return
            }
            
            GameKitController.achievementDescriptions = descriptions
            for achievement in GameKitController.achievementDescriptions {
                if let identifier = achievement.identifier {
                    achievement.loadImage(completionHandler: { (image, error) in
                        if let _ = error  {
                            NSLog("Failed to load image for achievement '\(achievement.title!)'")
                        } else if let image = image {
                            GameKitController.achievementImages[identifier] = image
                        }
                    })
                }
            }
        }
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
    
    //MARK: Leaderboards
    static func loadGameCenterLeaderboards() {
        if GameKitController.scoresAreLoaded {
            return
        }
        
        if GameKitController.currentLeaderboard == nil {
            GameKitController.currentLeaderboard = LeaderboardTypes.classic.rawValue
        }
        
        let localPlayer = GKLocalPlayer.localPlayer()
        guard localPlayer.isAuthenticated else {
            return
        }
        
        GKLeaderboard.loadLeaderboards { (leaderboards, error) in
            if let error = error {
                NSLog("Failed to load leaderboards with error \(error)")
            }
            
            guard let leaderboards = leaderboards else {
                NSLog("Failed to unwrap leaderboards")
                return
            }
            
            GameKitController.leaderboards = leaderboards
            
            for leaderboard in GameKitController.leaderboards {
                leaderboard.playerScope = GKLeaderboardPlayerScope.global
                leaderboard.range = NSRange(location: 1, length: 25)
                leaderboard.loadScores(completionHandler: { (scores, error) in
                    if let error = error {
                        NSLog("Failed to load scores for \(leaderboard.identifier!) with error \(error)")
                    }
                    
                    if let scores = scores {
                        GameKitController.scores[leaderboard.identifier!] = scores
                    } else {
                        NSLog("Failed to unwrap scores for leaderboard \(leaderboard.identifier!)")
                        GameKitController.scores[leaderboard.identifier!] = []
                    }
                    
                })
            }
            GameKitController.scoresAreLoaded = true
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
