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
    
    lazy var achievements: [GKAchievement] = {
        var achievementArray: [GKAchievement] = []
        GKAchievement.loadAchievements(completionHandler: { (fetchedAchievements, error) in
            if error != nil {
                NSLog("There was an error while fetching completed achievements: \(error!)")
            }
            if let unwrappedAchievements = fetchedAchievements {
                achievementArray = unwrappedAchievements
                for achievement in achievementArray {
                    print(achievement)
                }
            }
        })
        return achievementArray
    }()
    
    static let leaderboardTableHandler: LeaderboardTableViewHandler = LeaderboardTableViewHandler()
    static let achievementTableHandler: AchievementTableViewHandler = AchievementTableViewHandler()
    
    class func report(_ score: Int, toLeaderboard leaderboard: LeaderboardTypes) {
        postNotification(withName: "reportScore", andUserInfo: ["highScore": score, "leaderboard": leaderboard.rawValue])
    }
    
    class func report(_ achievement: Achievement, withPercentComplete percentComplete: Double) {
        postNotification(withName: "reportAchievement", andUserInfo: ["achievementName": achievement.rawValue, "percentComplete": percentComplete])
    }
    
    var mutableAchievementsDictionary: NSMutableDictionary!
    var achievementDictionaryURL: URL!
    
    override init() {        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportScore), name: NSNotification.Name("reportScore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportAchievement), name: NSNotification.Name("reportAchievement"), object: nil)
    }
    
    //MARK: Achievements
    
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
        
        self.mutableAchievementsDictionary.setValue(percentComplete, forKey: achievementName)
        self.mutableAchievementsDictionary.write(to: self.achievementDictionaryURL, atomically: true)
        
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
    class func authenticateLocalPlayer() {
        DispatchQueue.main.async {
            let localPlayer = GKLocalPlayer.localPlayer()
            if localPlayer.isAuthenticated {
                postNotification(withName: "authenticationStatusChanged", andUserInfo: ["isAuthenticated":true])
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
                }
                else {
                    postNotification(withName: "authenticationStatusChanged", andUserInfo: ["isAuthenticated":false])
                }
            }
        }
    }
}
