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
    static func setPropertiesToNil() {
        GameKitController.lastJumpDate = nil
        GameKitController.lastMoveDate = nil
        GameKitController.lastPauseDate = nil
        GameKitController.lastUnpauseDate = nil
    }
    
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
    
    static var lastPauseDate: Date? {
        didSet {
            if let _ = lastPauseDate {
                lastJumpDate = nil
                lastMoveDate = nil
            }
        }
    }
    
    static var lastUnpauseDate: Date? {
        didSet {
            if let pauseDate = lastPauseDate, let unpauseDate = lastUnpauseDate {
                lastJumpDate = Date()
                lastMoveDate = Date()
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
    static var mutableAchievementStatusDictionary: NSMutableDictionary!
    static var statusDictionaryURL: URL!
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportScore), name: NSNotification.Name("reportScore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportAchievement), name: NSNotification.Name("reportAchievement"), object: nil)
    }
    
    //MARK: Achievements
    static func readAchievementsDictionary() {
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
    }
    
    static func readStatusDictionary() {
        guard let statusDefaultsFile: URL = Bundle.main.url(forResource: "AchievementStatus", withExtension: "plist") else {
            NSLog("Unable to find default status file")
            return
        }
        guard let statusDefaultsDictionary: NSDictionary = NSDictionary(contentsOf: statusDefaultsFile) else {
            NSLog("Unable to open default status dictionary")
            return
        }
        
        let userDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        if let statusDirectory = NSURL(fileURLWithPath: userDirectory).appendingPathComponent("AchievementStatus.plist") {
            GameKitController.statusDictionaryURL = statusDirectory
            if let statusDictionary = NSDictionary(contentsOf: statusDirectory) {
                GameKitController.mutableAchievementStatusDictionary = statusDictionary.mutableCopy() as! NSMutableDictionary
            } else {
                statusDefaultsDictionary.write(to: statusDirectory, atomically: true)
                GameKitController.mutableAchievementStatusDictionary = statusDefaultsDictionary.mutableCopy() as! NSMutableDictionary
            }
        }
    }
    
    static func resetAllAchievements() {
        let fileManager: FileManager = FileManager.default
        do {
            try fileManager.removeItem(at: achievementDictionaryURL)
        } catch {
            NSLog("Unable to remove file at \(achievementDictionaryURL.path) with thrown error \(error).")
        }
        
        GKAchievement.resetAchievements { (error) in
            if let error = error {
                NSLog("Unable to reset achievement progress with error \(error)")
            }
        }
        readStatusDictionary()
        readAchievementsDictionary()
    }
    
    static func achievementIsNew(achievementType: Achievement) -> Bool {
        if let isNew = mutableAchievementStatusDictionary[achievementType.rawValue] as? Bool {
            return isNew
        } else {
            return false
        }
    }
    
    static func getBestScoreAndDate(arcade: Bool = false) -> (Int, Date) {
        if arcade {
            guard let bestScoreDate = mutableAchievementsDictionary["BestScoreDateArcade"] as? Date else {
                return (0, Date())
            }
            guard let bestScore = mutableAchievementsDictionary["BestScoreArcade"] as? Int else {
                return (0, Date())
            }
            return (bestScore, bestScoreDate)
        } else {
            guard let bestScoreDate = mutableAchievementsDictionary["BestScoreDate"] as? Date else {
                return (0, Date())
            }
            guard let bestScore = mutableAchievementsDictionary["BestScore"] as? Int else {
                return (0, Date())
            }
            return (bestScore, bestScoreDate)
        }
    }
    
    static func set(bestScore score: Int, andDate date: Date, arcade: Bool = false) {
        let (currentBest, _): (Int, Date) = getBestScoreAndDate(arcade: arcade)
        guard score > currentBest else {
            return
        }
        
        if arcade {
            mutableAchievementsDictionary.setValue(date, forKey: "BestScoreDateArcade")
            mutableAchievementsDictionary.setValue(score, forKey: "BestScoreArcade")
        } else {
            mutableAchievementsDictionary.setValue(date, forKey: "BestScoreDate")
            mutableAchievementsDictionary.setValue(score, forKey: "BestScore")
        }
        mutableAchievementsDictionary.write(to: achievementDictionaryURL, atomically: true)
    }
    
    static func setAchievementStatus(achievementType: Achievement, isNew: Bool) {
        mutableAchievementStatusDictionary.setValue(isNew, forKey: achievementType.rawValue)
        mutableAchievementStatusDictionary.write(to: statusDictionaryURL, atomically: true)
    }
    
    static func getAchievementProgress(achievementType: Achievement) -> Double {
        let achievementName: String = achievementType.rawValue
        if let achievementArray = GameKitController.achievements, achievementArray.count > 0 {
            for achievement in achievementArray {
                if let identifier = achievement.identifier, identifier == achievementName {
                    return achievement.percentComplete
                }
            }
        } else if let percentComplete = mutableAchievementsDictionary[achievementType.rawValue] as? Double {
            return percentComplete
        }
        else {
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
        
        GameKitController.achievementProgress[achievementType.rawValue] = percentComplete
        GameKitController.mutableAchievementsDictionary.setValue(percentComplete, forKey: achievementName)
        GameKitController.mutableAchievementsDictionary.write(to: GameKitController.achievementDictionaryURL, atomically: true)
    }
    
    static func madeProgressTowardsAchievement(achievementType: Achievement) {
        switch achievementType {
        case .AntMan, .DayBreak, .Jumper, .Octane, .TimeWarp:
            let pastProgress: Double = GameKitController.getAchievementProgress(achievementType: achievementType)
            let percentComplete: Double = pastProgress + 1.0
            GameKitController.report(achievementType, withPercentComplete: percentComplete)
            
        case .Gifted, .Blessed, .Powered:
            let pastProgress: Double = GameKitController.getAchievementProgress(achievementType: .Powered)
            let numPowerUpsCollected: Int = Int(pastProgress * 5.0) + 1
            let percentComplete: Double = pastProgress + 0.2
            
            if numPowerUpsCollected >= 500 && numPowerUpsCollected <= 550 {
                GameKitController.report(.Powered, withPercentComplete: 100.0)
            } else if numPowerUpsCollected >= 250 {
                GameKitController.report(.Powered, withPercentComplete: percentComplete)
                GameKitController.report(.Blessed, withPercentComplete: 100.0)
            } else if numPowerUpsCollected >= 100 {
                GameKitController.report(.Powered, withPercentComplete: percentComplete)
                GameKitController.report(.Blessed, withPercentComplete: percentComplete)
                GameKitController.report(.Gifted, withPercentComplete: 100.0)
            } else {
                GameKitController.report(.Powered, withPercentComplete: percentComplete)
                GameKitController.report(.Blessed, withPercentComplete: percentComplete)
                GameKitController.report(.Gifted, withPercentComplete: percentComplete)
            }
            
        case .ThirtyLives:
            let pastProgress: Int = Int(GameKitController.getAchievementProgress(achievementType: .ThirtyLives))
            let percentComplete: Double = Double(pastProgress + 1)
            
            if pastProgress >= 30 && pastProgress < 100 {
                GameKitController.report(.ThirtyLives, withPercentComplete: 100.0)
            } else if pastProgress < 100 {
                GameKitController.report(.ThirtyLives, withPercentComplete: percentComplete)
            }
        case .TestRun, .Interested, .Dedicated, .Committed:
            let pastProgress: Double = GameKitController.getAchievementProgress(achievementType: .Committed)
            let numTimesPlayed: Int = Int(pastProgress * 5.0) + 1
            let percentComplete: Double = pastProgress + 0.2
            
            if numTimesPlayed >= 500 && numTimesPlayed <= 550 {
                GameKitController.report(.Committed, withPercentComplete: 100.0)
            } else if numTimesPlayed >= 250 {
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
                GameKitController.report(.Dedicated, withPercentComplete: 100.0)
            } else if numTimesPlayed >= 100 {
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
                GameKitController.report(.Dedicated, withPercentComplete: percentComplete)
                GameKitController.report(.Interested, withPercentComplete: 100.0)
            } else if numTimesPlayed >= 10 {
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
                GameKitController.report(.Dedicated, withPercentComplete: percentComplete)
                GameKitController.report(.Interested, withPercentComplete: percentComplete)
                GameKitController.report(.TestRun, withPercentComplete: 100.0)
            } else {
                GameKitController.report(.Committed, withPercentComplete: percentComplete)
                GameKitController.report(.Dedicated, withPercentComplete: percentComplete)
                GameKitController.report(.Interested, withPercentComplete: percentComplete)
                GameKitController.report(.TestRun, withPercentComplete: percentComplete)
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
        
        GameKitController.refreshAchievementArray()
    }
    
    static func refreshAchievementArray() {
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
    
    @objc func reportAchievement(notification: Notification) {
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
            let previousPercentComplete: Double = GameKitController.getAchievementProgress(achievementType: achievementType)
            if previousPercentComplete == 100.0 {
                return
            }
            
            
            if percentComplete == 100.0 {
                GameKitController.updateAchievementProgress(achievementType: achievementType, percentComplete: percentComplete)            
                GameKitController.setAchievementStatus(achievementType: achievementType, isNew: true)
            }
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
        
        GameKitController.refreshGameCenterLeaderboards()
    }
    
    static func refreshGameCenterLeaderboards() {
        if GameKitController.currentLeaderboard == nil {
            GameKitController.currentLeaderboard = LeaderboardTypes.classic.rawValue
        }
        
        let localPlayer = GKLocalPlayer.localPlayer()
        guard localPlayer.isAuthenticated else {
            GameKitController.authenticateLocalPlayer()
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
    @objc func reportScore(notification: Notification) {
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
