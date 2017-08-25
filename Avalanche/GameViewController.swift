//
//  GameViewController.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/21/16.
//  Copyright (c) 2016 LooseFuzz. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
//    var gameCenterVC: GKGameCenterViewController!
    
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if !oldValue && gameCenterIsAuthenticated {
                localPlayer = GKLocalPlayer.localPlayer()
                loadGameCenterData()
            }
        }
    }
    var currentGameCenterViewControllerState: GKGameCenterViewControllerState = GKGameCenterViewControllerState.default
    var localPlayer: GKLocalPlayer!
    var menuScene: MenuScene!
    
    //MARK: View Methods
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.displayDismissAlert(notification:)), name: NSNotification.Name(rawValue: "alertRequested"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.displayBuyCancelAlert(notification:)), name: NSNotification.Name(rawValue: "buyRequested"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.presentGameCenterViewController), name: NSNotification.Name(rawValue: "presentScores"), object: nil)
        
        self.view = SKView(frame: UIScreen.main.bounds)
        
        //Load the menu scene on startup
        menuScene = MenuScene(size: self.view.frame.size)
        menuScene.scaleMode = .resizeFill
        
        //Load the leaderboard
//        self.gameCenterVC = GKGameCenterViewController()
//        self.gameCenterVC.gameCenterDelegate = self
//        self.gameCenterVC.viewState = self.currentGameCenterViewControllerState
//        self.gameCenterVC.leaderboardTimeScope = GKLeaderboardTimeScope.week
        
        let skView = self.view as! SKView
        skView.showsPhysics = false
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        skView.presentScene(menuScene)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    //MARK: Alert Methods
    func displayDismissAlert(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: String] else {
            return
        }
        guard let title = dictionary["title"] else {
            return
        }
        guard let message = dictionary["message"] else {
            return
        }
        
        let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
        alertView.addAction(dismissAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    func displayBuyCancelAlert(notification: Notification) {
        print("Displaying buy cancel alert")
        guard let dictionary = notification.userInfo as? [String: String] else {
            return
        }
        guard let title = dictionary["title"] else {
            return
        }
        guard let message = dictionary["message"] else {
            return
        }
        guard let purchaseName = dictionary["purchaseName"] else {
            return
        }
        guard let purchaseType = Purchase(rawValue: purchaseName) else {
            return
        }
        
        
        let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let buyAction: UIAlertAction = UIAlertAction(title: "Buy", style: UIAlertActionStyle.default) { (action) in
            StoreKitController.buy(purchaseType: purchaseType)
            postNotification(withName: "ReloadStoreTable")
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertView.addAction(buyAction)
        alertView.addAction(cancelAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: GameKit Methods
    func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    //MARK: GKGameCenterControllerDelegate
    func loadGameCenterData() {
        guard localPlayer.isAuthenticated else {
            return
        }
        
//        localPlayer.loadDefaultLeaderboardIdentifier { (string, error) in
//            if error != nil {
//                NSLog("Could not load leaderboard: \(error!)")
//            }
//            else if let identifier = string {
//                //Load the gameCenterViewController
//                self.gameCenterVC.leaderboardIdentifier = identifier
//            }
//        }
        
    }
    
//    func presentGameCenterViewController() {
//        guard localPlayer.isAuthenticated else {
//            return
//        }
//        
//        self.present(gameCenterVC, animated: true, completion: nil)
//    }
//    
//    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
//        currentGameCenterViewControllerState = gameCenterViewController.viewState
//        gameCenterViewController.dismiss(animated: true, completion: nil)
//    }
    
}
