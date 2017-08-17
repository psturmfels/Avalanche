//
//  StoreTableViewHandler.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/14/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import UIKit
import GameKit
import StoreKit

class StoreTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var tableView: UITableView?
    
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if !oldValue && gameCenterIsAuthenticated {
                
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
        self.tableView = table
    }
    
    //MARK: GameCenter Methods
    func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                self.gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    //MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StoreTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StoreTableViewCell", for: indexPath) as! StoreTableViewCell
        cell.indexPath = indexPath //TODO: REMOVE THIS
        cell.updateCellUI()
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StoreTableViewCell.expandedHeightNecessary(forDescription: "")
    }
}
