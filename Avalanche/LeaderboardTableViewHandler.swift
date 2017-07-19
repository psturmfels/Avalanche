//
//  LeaderboardTableViewHandler.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 2/19/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import UIKit
import GameKit

class LeaderboardTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    var expandedPath: IndexPath?
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if !oldValue && gameCenterIsAuthenticated {
                loadGameCenterLeaderboards()
            }
        }
    }
    var scoresAreLoaded: Bool = false
    
    var leaderboards: [GKLeaderboard]!
    var scores: [String: [GKScore]] = [String: [GKScore]]()
    var currentLeaderboard: String?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(LeaderboardTableViewHandler.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
    }
    
    //MARK: GameCenter Methods
    func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                self.gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    func loadGameCenterLeaderboards() {
        let localPlayer = GKLocalPlayer.localPlayer()
        guard localPlayer.isAuthenticated else {
            return
        }
        
        localPlayer.loadDefaultLeaderboardIdentifier { (defaultIdentifier, error) in
            if let error = error {
                NSLog("Error loading default leaderboard identifier: \(error)")
            }
            
            guard let defaultIdentifier = defaultIdentifier else {
                NSLog("Failed to unwrap default leaderboard identifier")
                return
            }
            
            if self.currentLeaderboard == nil {
                self.currentLeaderboard = defaultIdentifier
            }
        }
        
        GKLeaderboard.loadLeaderboards { (leaderboards, error) in
            if let error = error {
                NSLog("Failed to load leaderboards with error \(error)")
            }
            
            guard let leaderboards = leaderboards else {
                NSLog("Failed to unwrap leaderboards")
                return
            }
            
            self.leaderboards = leaderboards
            
            for leaderboard in self.leaderboards {
                leaderboard.playerScope = GKLeaderboardPlayerScope.global
                leaderboard.range = NSRange(location: 1, length: 25)
                leaderboard.loadScores(completionHandler: { (scores, error) in
                    if let error = error {
                        NSLog("Failed to load scores for \(leaderboard.identifier!) with error \(error)")
                    }
                    
                    if let scores = scores {
                        self.scores[leaderboard.identifier!] = scores
                    } else {
                        NSLog("Failed to unwrap scores for leaderboard \(leaderboard.identifier!)")
                        self.scores[leaderboard.identifier!] = []
                    }
                    
                })
            }
            self.scoresAreLoaded = true
        }
    }
    
    //MARK: UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard scoresAreLoaded else {
            return 0
        }
        guard let currentLeaderboard = self.currentLeaderboard else {
            return 0
        }
        guard let scoreArray = self.scores[currentLeaderboard] else {
            return 0
        }
        
        return scoreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard scoresAreLoaded else {
            return LeaderboardTableViewCell()
        }
        guard let currentLeaderboard = self.currentLeaderboard else {
            return LeaderboardTableViewCell()
        }
        guard let scoreArray = self.scores[currentLeaderboard] else {
            return LeaderboardTableViewCell()
        }
        
        let cell: LeaderboardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardTableViewCell") as! LeaderboardTableViewCell
        
        let row: Int = indexPath.row
        if let expandedPath = self.expandedPath, expandedPath == indexPath {
            cell.isExpanded = true
        } else {
            cell.isExpanded = false
        }
        
        cell.score = scoreArray[row]
        
        return cell
    }
    
    //MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let expandedPath = self.expandedPath else {
            return LeaderboardTableViewCell.defaultHeight
        }
        
        if indexPath == expandedPath {
            guard scoresAreLoaded else {
                return LeaderboardTableViewCell.defaultHeight
            }
            guard let currentLeaderboard = self.currentLeaderboard else {
                return LeaderboardTableViewCell.defaultHeight
            }
            guard let scoreArray = self.scores[currentLeaderboard] else {
                return LeaderboardTableViewCell.defaultHeight
            }
            
            guard let userName = scoreArray[indexPath.row].player?.alias else {
                return LeaderboardTableViewCell.defaultHeight
            }
            var scoreString: String = "\(scoreArray[indexPath.row].value)"
            if let unwrappedScoreFormatted = scoreArray[indexPath.row].formattedValue {
                scoreString = unwrappedScoreFormatted
            }
            
            return LeaderboardTableViewCell.expandedHeightNecessary(forUser: userName, andScore: scoreString)
            
        } else {
            return LeaderboardTableViewCell.defaultHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == self.expandedPath {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell: LeaderboardTableViewCell = tableView.cellForRow(at: indexPath) as! LeaderboardTableViewCell
            cell.wasDeselected()
            
            self.expandedPath = nil
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            if let expandedPath = self.expandedPath {
                LeaderboardTableViewHandler.deselectRowIn(tableView, atIndex: expandedPath, true)
            }
            
            self.expandedPath = indexPath
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            
            let cell: LeaderboardTableViewCell = tableView.cellForRow(at: indexPath) as! LeaderboardTableViewCell
            cell.wasSelected()
        }
    }
    
    
    //MARK: Helper functions
    class func deselectAllAScores(_ tableView: UITableView, _ animated: Bool) {
        if let selectedIndices: [IndexPath] = tableView.indexPathsForSelectedRows {
            for selectedIndex in selectedIndices {
                if let cell: LeaderboardTableViewCell = tableView.cellForRow(at: selectedIndex) as? LeaderboardTableViewCell {
                    cell.wasDeselected()
                }
                
                tableView.deselectRow(at: selectedIndex, animated: animated)
            }
        }
        let zeroIndex: IndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: zeroIndex, at: UITableViewScrollPosition.top, animated: animated)
    }
    
    class func deselectRowIn(_ tableView: UITableView, atIndex index: IndexPath, _ animated: Bool) {
        if let cell: LeaderboardTableViewCell = tableView.cellForRow(at: index) as? LeaderboardTableViewCell {
            cell.wasDeselected()
        }
    }
    
}
