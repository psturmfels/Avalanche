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

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    var gameCenterVC: GKGameCenterViewController!
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if gameCenterIsAuthenticated {
                localPlayer = GKLocalPlayer.localPlayer()
                loadGameCenterViewController()
                menuScene.gameCenterIsAuthenticated = true
            }
        }
    }
    var currentGameCenterViewControllerState: GKGameCenterViewControllerState = GKGameCenterViewControllerState.leaderboards
    var localPlayer: GKLocalPlayer!
    var menuScene: MenuScene!
    
    //MARK: View Methods
    override func viewDidLoad() {
        self.view = SKView(frame: UIScreen.main.bounds)
        
        //Load the menu scene on startup
        menuScene = MenuScene(size: self.view.frame.size)
        menuScene.scaleMode = .resizeFill
        
        //Load the leaderboard
        self.gameCenterVC = GKGameCenterViewController()
        self.gameCenterVC.gameCenterDelegate = self
        self.gameCenterVC.viewState = self.currentGameCenterViewControllerState
        self.gameCenterVC.leaderboardTimeScope = GKLeaderboardTimeScope.week
        
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
    
    //MARK: GKGameCenterControllerDelegate
    func loadGameCenterViewController() {
        if gameCenterIsAuthenticated && localPlayer.isAuthenticated {
            localPlayer.loadDefaultLeaderboardIdentifier { (string, error) in
                if error != nil {
                    NSLog("Could not load leaderboard: \(error!)")
                }
                else if let identifier = string {
                    //Load the gameCenterViewController
                    self.gameCenterVC.leaderboardIdentifier = identifier
                }
            }
        }
    }
    
    func presentGameCenterViewController() {
        if gameCenterIsAuthenticated && localPlayer.isAuthenticated {
            self.present(gameCenterVC, animated: true, completion: nil)
        }
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        currentGameCenterViewControllerState = gameCenterViewController.viewState
        
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
