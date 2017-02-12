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
