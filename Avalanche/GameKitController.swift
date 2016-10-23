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
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.authenticateLocalPlayer), name: NSNotification.Name(rawValue: "attemptToAuthenticate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameKitController.reportScore), name: NSNotification.Name("reportScore"), object: nil)
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
    
    func reportScore(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: Int] else {
            return
        }
        
        guard let highScore = dictionary["highScore"] else {
            return
        }
        
        //        guard let leaderBoard: Int = dictionary["leaderboard"] else {
        //            return
        //        }
        
        let localPlayer = GKLocalPlayer.localPlayer()
        guard localPlayer.isAuthenticated else {
            return
        }
        
        localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (identifier, error) in
            if error != nil {
                NSLog("Could not load leaderboard: \(error!)")
            } else if let leaderboardIdentifier = identifier {
                let scoreObject: GKScore = GKScore(leaderboardIdentifier: leaderboardIdentifier, player: localPlayer)
                scoreObject.value = Int64(highScore)
                
                GKScore.report([scoreObject], withCompletionHandler: { (error) in
                    if error != nil {
                        NSLog("Could not report score \(scoreObject) to leaderboard \(leaderboardIdentifier)")
                    }
                })
            }
        })
        
    }
    
    func authenticateLocalPlayer() {
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
