//
//  MenuScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/23/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import GameKit

class MenuScene: SKScene {
    var playButton: ButtonLabelNode!
    var scoresButton: ButtonLabelNode!
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if gameCenterIsAuthenticated {
                scoresButton.alpha = 1.0
            } else {
                scoresButton.alpha = 0.5
            }
        }
    }
    
    //MARK: Button Methods
    func transitionToGame() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Game Scene
        let gameScene: ClassicModeScene = ClassicModeScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        gameScene.scaleMode = .resizeFill
        
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
    
    //MARK: View Methods
    override func didMove(to view: SKView) {
        createMenuButtons()
        
        let localPlayer = GKLocalPlayer.localPlayer()
        gameCenterIsAuthenticated = localPlayer.isAuthenticated
        
        if !gameCenterIsAuthenticated {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            DispatchQueue.main.async {
                appDelegate.authenticateLocalPlayer()
            }
        }
    }
    
    //MARK: Creation Methods
    func createMenuButtons() {
        let center: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        playButton = ButtonLabelNode()
        playButton.setup(withText: "Classic: ", withFontSize: 48.0, withButtonName: "Play", normalTextureName: "playMenuNormal", highlightedTextureName: "playMenuHighlighted", atPosition: center)
        playButton.position.y += playButton.height * 0.5 + 10
 
        scoresButton = ButtonLabelNode()
        scoresButton.setup(withText: "Scores: ", withFontSize: 48.0, withButtonName: "Scores", normalTextureName: "scoresNormal", highlightedTextureName: "scoresHighlighted", atPosition: center)
        scoresButton.position.y -= scoresButton.height * 0.5 + 10
        scoresButton.alpha = 0.5
        
        self.addChild(playButton)
        self.addChild(scoresButton)
    }
    
    //MARK: Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Play" {
                    playButton.didPress()
                    break
                }
                else if object.name == "Scores" && gameCenterIsAuthenticated {
                    scoresButton.didPress()
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Play" || object.name == "Scores" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            playButton.didRelease()
            scoresButton.didRelease()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playButton.isPressed {
            playButton.didRelease()
            transitionToGame()
        } else if scoresButton.isPressed {
            scoresButton.didRelease()
            if gameCenterIsAuthenticated {
                let parentViewController = self.view!.window!.rootViewController as! GameViewController
                parentViewController.presentGameCenterViewController()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        playButton.didRelease()
        scoresButton.didRelease()
    }
}
