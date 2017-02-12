//
//  GameTableViewHandler.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 2/12/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import UIKit
import GameKit

class AchievementTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    var expandedRow: IndexPath!
    var normalHeight: CGFloat = 50.0
    var expandedHeight: CGFloat = 200.0
    var achievementDescriptions: [GKAchievementDescription]!
    var achievementProgress: [GKAchievement]!
    
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if !oldValue && gameCenterIsAuthenticated {
                loadGameCenterAchievements()
            }
        }
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AchievementTableViewHandler.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
    }
    
    
    //MARK: GameCenter Methods
    func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                self.gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    func loadGameCenterAchievements() {
        GKAchievement.loadAchievements { (achievements, error) in
            if error != nil {
                NSLog("Failed to load achievement progress with error \(error)")
            }
            
            guard let achievements = achievements else {
                NSLog("Failed to unwrap achievements.")
                return
            }
            
            self.achievementProgress = achievements
        }
        
        GKAchievementDescription.loadAchievementDescriptions { (descriptions, error) in
            if error != nil {
                NSLog("Failed to load achievement descriptions with error \(error).")
            }
            
            guard let descriptions = descriptions else {
                NSLog("Failed to unwrap achievements.")
                return
            }
            
            self.achievementDescriptions = descriptions
            for achievement in self.achievementDescriptions {
                achievement.loadImage(completionHandler: { (image, error) in
                    if error != nil {
                        NSLog("Failed to load image for achievement '\(achievement.title)'")
                    }
                })
            }
        }
    }
    
    //MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if gameCenterIsAuthenticated {
            return achievementDescriptions.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AchievementTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AchievementTableViewCell", for: indexPath) as! AchievementTableViewCell
        let row: Int = indexPath.row
        
        cell.achievement = achievementDescriptions[row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.expandedRow = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let expandedRow = self.expandedRow else {
            return normalHeight
        }
        if indexPath == expandedRow {
            return expandedHeight
        } else {
            return normalHeight
        }
    }
}
