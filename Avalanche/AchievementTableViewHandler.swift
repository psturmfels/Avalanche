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
    var expandedPath: IndexPath?
    var achievementDescriptions: [GKAchievementDescription]!
    var achievementProgress: [String:Double] = [String:Double]()
    var achievementImages: [String:UIImage] = [String:UIImage]()
    
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if !oldValue && gameCenterIsAuthenticated {
                loadGameCenterAchievements()
            }
        }
    }
    var achievementsAreLoaded: Bool = false
    
    var staticAchievements: [GKAchievementDescription] = [GKAchievementDescription]() //TODO: DELETE ME
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AchievementTableViewHandler.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
        
        for _ in 0...50 {
            let achievement: GKAchievementDescription = GKAchievementDescription()
            staticAchievements.append(achievement)
        } //TODO: DELETE ME 
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
            
            for achievementProgressObject in achievements {
                if let identifier = achievementProgressObject.identifier {
                    self.achievementProgress[identifier] = achievementProgressObject.percentComplete
                }
            }
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
                if let identifier = achievement.identifier {
                    achievement.loadImage(completionHandler: { (image, error) in
                        if error != nil {
                            NSLog("Failed to load image for achievement '\(achievement.title)'")
                        } else if let image = image {
                            self.achievementImages[identifier] = image
                        }
                    })
                    
                }
            }
//            self.achievementsAreLoaded = true
//            TODO: UNCOMMENT ME
        }
    }
    
    //MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if achievementsAreLoaded {
            return achievementDescriptions.count
        }
        else {
            return staticAchievements.count
//            TODO: FIX ME
//            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard achievementsAreLoaded else {
            let cell: AchievementTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AchievementTableViewCell", for: indexPath) as! AchievementTableViewCell
            let row: Int = indexPath.row
            
            if let expandedPath = self.expandedPath, expandedPath == indexPath {
                cell.isExpanded = true
            } else {
                cell.isExpanded = false
            }
            
            cell.achievement = staticAchievements[row]
            
            return cell
            
//            TODO: DELETE ME
//            return AchievementTableViewCell()
        }
        
        let cell: AchievementTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AchievementTableViewCell", for: indexPath) as! AchievementTableViewCell
        let row: Int = indexPath.row
        
        let achievementIdentifier: String = achievementDescriptions[row].identifier!
        
        if let achievementProgress = self.achievementProgress[achievementIdentifier] {
            cell.achievementProgress = achievementProgress
        } else {
            cell.achievementProgress = 0.0
        }
        
        if let achievementImage = self.achievementImages[achievementIdentifier] {
            cell.achievementImage = achievementImage
        } else {
            cell.achievementImage = AchievementTableViewCell.defaultAchievementImage
        }
        
        if let expandedPath = self.expandedPath, expandedPath == indexPath {
            cell.isExpanded = true
        } else {
            cell.isExpanded = false
        }
        
        cell.achievement = achievementDescriptions[row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == self.expandedPath {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell: AchievementTableViewCell = tableView.cellForRow(at: indexPath) as! AchievementTableViewCell
            cell.wasDeselected()
            
            self.expandedPath = nil
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            if let expandedPath = self.expandedPath {
                AchievementTableViewHandler.deselectRowIn(tableView, atIndex: expandedPath, true)
            }
                
            self.expandedPath = indexPath
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            
            let cell: AchievementTableViewCell = tableView.cellForRow(at: indexPath) as! AchievementTableViewCell
            cell.wasSelected()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let expandedPath = self.expandedPath else {
            return AchievementTableViewCell.defaultHeight
        }
        
        if indexPath == expandedPath {
            guard achievementsAreLoaded else {
                return AchievementTableViewCell.expandedHeightNecessary(forDescription: "This is a description for an achievement that has not yet been achieved by the local player.")
//                TODO: FIX ME
//                return AchievementTableViewCell.defaultHeight
            }
            
            let achievementIdentifier: String = achievementDescriptions[indexPath.row].identifier!
            let achievedDescription: String = achievementDescriptions[indexPath.row].achievedDescription!
            let unachievedDescription: String = achievementDescriptions[indexPath.row].unachievedDescription!
            
            if let achievementProgress = self.achievementProgress[achievementIdentifier] {
                if achievementProgress == 100.0 {
                    return AchievementTableViewCell.expandedHeightNecessary(forDescription: achievedDescription)
                } else {
                    return AchievementTableViewCell.expandedHeightNecessary(forDescription: unachievedDescription)
                }
            }
            
            return AchievementTableViewCell.expandedHeightNecessary(forDescription: unachievedDescription)
        } else {
            return AchievementTableViewCell.defaultHeight
        }
    }
    
    //MARK: Helper functions
    class func deselectAllAchievements(_ tableView: UITableView, _ animated: Bool) {
        if let selectedIndices: [IndexPath] = tableView.indexPathsForSelectedRows {
            for selectedIndex in selectedIndices {
                if let cell: AchievementTableViewCell = tableView.cellForRow(at: selectedIndex) as? AchievementTableViewCell {
                    cell.wasDeselected()
                }
                
                tableView.deselectRow(at: selectedIndex, animated: animated)
            }
        }
        let zeroIndex: IndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: zeroIndex, at: UITableViewScrollPosition.top, animated: animated)
    }
    
    class func deselectRowIn(_ tableView: UITableView, atIndex index: IndexPath, _ animated: Bool) {
        if let cell: AchievementTableViewCell = tableView.cellForRow(at: index) as? AchievementTableViewCell {
            cell.wasDeselected()
        }
    }
}
