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
    let refreshControl: UIRefreshControl = UIRefreshControl()
    weak var tableView: UITableView?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(LeaderboardTableViewHandler.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
    }
    
    func setDelegateAndSource(forTable table: UITableView) {
        table.delegate = self
        table.dataSource = self
        table.refreshControl = self.refreshControl
        self.tableView = table
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(self.viewRefreshed), for: UIControlEvents.valueChanged)
    }
    
    @objc func viewRefreshed() {
        let dateAhead: DispatchTime = DispatchTime.now() + .seconds(1)
        
        DispatchQueue.main.asyncAfter(deadline: dateAhead) {
            GameKitController.refreshGameCenterLeaderboards()
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
    
    func loadGameCenterLeaderboards() {
        GameKitController.loadGameCenterLeaderboards()
    }
    
    //MARK: UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard GameKitController.scoresAreLoaded else {
            return 0
        }
        guard let currentLeaderboard = GameKitController.currentLeaderboard else {
            return 0
        }
        guard let scoreArray = GameKitController.scores[currentLeaderboard] else {
            return 0
        }
        
        return scoreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard GameKitController.scoresAreLoaded else {
            return LeaderboardTableViewCell()
        }
        guard let currentLeaderboard = GameKitController.currentLeaderboard else {
            return LeaderboardTableViewCell()
        }
        guard let scoreArray = GameKitController.scores[currentLeaderboard] else {
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
            guard GameKitController.scoresAreLoaded else {
                return LeaderboardTableViewCell.defaultHeight
            }
            guard let currentLeaderboard = GameKitController.currentLeaderboard else {
                return LeaderboardTableViewCell.defaultHeight
            }
            guard let scoreArray = GameKitController.scores[currentLeaderboard] else {
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
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
            
            let cell: LeaderboardTableViewCell = tableView.cellForRow(at: indexPath) as! LeaderboardTableViewCell
            cell.wasSelected()
        }
    }
    
    
    //MARK: Helper functions
    static func deselectAllAScores(_ tableView: UITableView, _ animated: Bool) {
        if let selectedIndices: [IndexPath] = tableView.indexPathsForSelectedRows {
            for selectedIndex in selectedIndices {
                if let cell: LeaderboardTableViewCell = tableView.cellForRow(at: selectedIndex) as? LeaderboardTableViewCell {
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
        if let cell: LeaderboardTableViewCell = tableView.cellForRow(at: index) as? LeaderboardTableViewCell {
            cell.wasDeselected()
        }
    }
    
}
