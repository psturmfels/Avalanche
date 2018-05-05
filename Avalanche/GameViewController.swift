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
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {
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
    var interstitial: GADInterstitial!
    var currentAlert: UIAlertController?
    
    //MARK: View Methods
    override func viewDidLoad() {
        interstitial = createAndLoadInterstitial()
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.displayDismissAlert(notification:)), name: NSNotification.Name(rawValue: "alertRequested"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showInterstitialAd), name: NSNotification.Name(rawValue: "showInterstitialAd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.displayActivityView), name: NSNotification.Name(rawValue: "displayActivityView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.closeActivityView), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
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
    
    //MARK: GAD Methods
    @objc func showInterstitialAd() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            postNotification(withName: "InterstitialAdFinished")
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial: GADInterstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        let request: GADRequest = GADRequest()
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        postNotification(withName: "InterstitialAdFinished")
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        postNotification(withName: "InterstitialAdFinished")
    }
    
    //MARK: Alert Methods
    @objc func displayDismissAlert(notification: Notification) {
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
    
    @objc func displayActivityView() {
        currentAlert = UIAlertController(title: nil, message: "", preferredStyle: .alert)

        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: currentAlert!.view.bounds)
        loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        loadingIndicator.isUserInteractionEnabled = false
        
        currentAlert!.view.addSubview(loadingIndicator)
        self.present(currentAlert!, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [unowned self] in
            if let _ = self.currentAlert {
                self.closeActivityView()
                
                let title: String = "Error"
                let message: String = "Something went wrong with your purchase. Please try again."
                let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                let dismissAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
                alertView.addAction(dismissAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    @objc func closeActivityView() {
        if let currentAlert = currentAlert {
            currentAlert.dismiss(animated: true, completion: nil)
        }
        currentAlert = nil
    }
    
    //MARK: GameKit Methods
    @objc func authenticationStatusDidChange(notification: Notification) {
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
