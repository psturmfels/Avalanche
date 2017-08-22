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
    
    var purchaseList: [Purchase] = Purchase.allPurchases
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AchievementTableViewHandler.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StoreTableViewHandler.reloadTableView), name: NSNotification.Name("ReloadStoreTable"), object: nil)
    }
    
    func reloadTableView() {
        if let tableView = self.tableView {
            tableView.reloadData()
        }
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
        return purchaseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StoreTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StoreTableViewCell", for: indexPath) as! StoreTableViewCell
        let row: Int = indexPath.row
        cell.purchaseType = purchaseList[row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StoreTableViewCell.defaultHeight
    }
    
    static func scrollToLast(_ tableView: UITableView, animated: Bool = true) {
        let numberOfRows: Int = tableView.numberOfRows(inSection: 0)
        guard numberOfRows > 0 else {
            return
        }
        let indexPath: IndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: animated)
    }
}
