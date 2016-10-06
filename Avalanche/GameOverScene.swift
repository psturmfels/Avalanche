//
//  GameOverScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    var replayButton: ButtonNode!
    var menuButton: ButtonNode!
    var highScore: Int!
    var highScoreLabel: SKLabelNode!
    
    
    //MARK: Initializing Methods
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        replayButton = ButtonNode()
        menuButton = ButtonNode()
        
        let center: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        replayButton = ButtonNode(imageNamed: "replayNormal")
        replayButton.setup(atPosition: center, withName: "Replay", normalTextureName: "replayNormal", highlightedTextureName: "replayHighlighted")
        replayButton.position.y += replayButton.frame.height * 0.5 + 10
        
        menuButton = ButtonNode(imageNamed: "menuNormal")
        menuButton.setup(atPosition: center, withName: "Menu", normalTextureName: "menuNormal", highlightedTextureName: "menuHighlighted")
        menuButton.position.y -= menuButton.frame.height * 0.5 + 10
        
        highScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        highScoreLabel.fontSize = 42.0
        highScoreLabel.text = "Score: \(highScore!) ft"
        highScoreLabel.position = center
        highScoreLabel.position.y += replayButton.frame.height + highScoreLabel.frame.height * 1.4
        
        self.addChild(replayButton)
        self.addChild(menuButton)
        self.addChild(highScoreLabel)
    }
 
    //MARK: Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Replay" {
                    replayButton.didPress()
                    break
                }
                else if object.name == "Menu" {
                    menuButton.didPress()
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if replayButton.isPressed {
            replayButton.didRelease()
            transitionToReplay()
        }
        else if menuButton.isPressed {
            menuButton.didRelease()
            transitionToMenu()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Replay" || object.name == "Menu" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            replayButton.didRelease()
            menuButton.didRelease()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        replayButton.didRelease()
        menuButton.didRelease()
    }

    //MARK: Transition Methods
    func transitionToMenu() {
        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(menuScene, transition: transition)
    }
    
    func transitionToReplay() {
        let gameScene = GameScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)
        gameScene.scaleMode = .resizeFill
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
}

