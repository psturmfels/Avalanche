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
    let refreshControl: UIRefreshControl = UIRefreshControl()
    weak var tableView: UITableView?
    
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
    
    func setDelegateAndSource(forTable table: UITableView) {
        table.delegate = self
        table.dataSource = self
        if #available(iOS 10.0, *) {
            table.refreshControl = self.refreshControl
            self.refreshControl.tintColor = UIColor.white
            self.refreshControl.addTarget(self, action: #selector(self.viewRefreshed), for: UIControlEvents.valueChanged)
        }
        self.tableView = table
    }
    
    @objc func viewRefreshed() {
        guard #available(iOS 10.0, *) else {
            return
        }
        
        let dateAhead: DispatchTime = DispatchTime.now() + .seconds(1)
        
        DispatchQueue.main.asyncAfter(deadline: dateAhead) {
            GameKitController.refreshAchievementArray()
            if let tableView = self.tableView {
                tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: GameCenter Methods
    @objc func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                self.gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    func loadGameCenterAchievements() {
        GameKitController.loadAchievementArray()
    }
    
    //MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GameKitController.achievementsAreLoaded {
            return GameKitController.achievementDescriptions.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard GameKitController.achievementsAreLoaded else {
            return AchievementTableViewCell()
        }
        
        let cell: AchievementTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AchievementTableViewCell", for: indexPath) as! AchievementTableViewCell
        let row: Int = indexPath.row
        
        let achievementIdentifier: String = GameKitController.achievementDescriptions[row].identifier!
        
        if let achievementProgress = GameKitController.achievementProgress[achievementIdentifier] {
            cell.achievementProgress = achievementProgress
        } else {
            cell.achievementProgress = 0.0
        }
        
        if let achievementImage = GameKitController.achievementImages[achievementIdentifier] {
            cell.achievementImage = achievementImage
        } else {
            cell.achievementImage = AchievementTableViewCell.defaultAchievementImage
        }
        
        if let expandedPath = self.expandedPath, expandedPath == indexPath {
            cell.isExpanded = true
        } else {
            cell.isExpanded = false
        }
        
        cell.achievement = GameKitController.achievementDescriptions[row]
        
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
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
            
            let cell: AchievementTableViewCell = tableView.cellForRow(at: indexPath) as! AchievementTableViewCell
            cell.wasSelected()
            if cell.isNew {
                cell.removeNew()
                cell.isNew = false
                if let identifier = cell.achievement?.identifier {
                    if let type = Achievement(rawValue: identifier) {
                        GameKitController.setAchievementStatus(achievementType: type, isNew: false)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let expandedPath = self.expandedPath else {
            return AchievementTableViewCell.defaultHeight
        }
        
        if indexPath == expandedPath {
            guard GameKitController.achievementsAreLoaded else {
                return AchievementTableViewCell.defaultHeight
            }
            
            let achievementIdentifier: String = GameKitController.achievementDescriptions[indexPath.row].identifier!
            let achievedDescription: String = GameKitController.achievementDescriptions[indexPath.row].achievedDescription!
            let unachievedDescription: String = GameKitController.achievementDescriptions[indexPath.row].unachievedDescription!
            
            if let achievementProgress = GameKitController.achievementProgress[achievementIdentifier] {
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    //MARK: Helper functions
    static func deselectAllAchievements(_ tableView: UITableView, _ animated: Bool) {
        if let selectedIndices: [IndexPath] = tableView.indexPathsForSelectedRows {
            for selectedIndex in selectedIndices {
                if let cell: AchievementTableViewCell = tableView.cellForRow(at: selectedIndex) as? AchievementTableViewCell {
                    cell.wasDeselected()
                }
                
                tableView.deselectRow(at: selectedIndex, animated: animated)
            }
        }
        let zeroIndex: IndexPath = IndexPath(row: 0, section: 0)
        let numRows: Int = tableView.numberOfRows(inSection: 0)
        guard numRows > 0 else {
            return
        }
        tableView.scrollToRow(at: zeroIndex, at: UITableViewScrollPosition.top, animated: animated)
    }
    
    static func deselectRowIn(_ tableView: UITableView, atIndex index: IndexPath, _ animated: Bool) {
        if let cell: AchievementTableViewCell = tableView.cellForRow(at: index) as? AchievementTableViewCell {
            cell.wasDeselected()
        }
    }
}
