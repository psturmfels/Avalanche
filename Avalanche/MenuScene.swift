//
//  MenuScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/23/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var playButton: ButtonLabelNode!
    var scoresButton: ButtonLabelNode!
    var tutorialButton: ButtonNode!
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
    
    func transitionToTutorial() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Tutorial Scene
        let tutorialScene: TutorialScene = TutorialScene(fileNamed: "GameScene")!
        tutorialScene.size = self.size
        tutorialScene.scaleMode = .resizeFill
        
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(tutorialScene, transition: transition)
    }
    
    //MARK: View Methods
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self, selector: #selector(MenuScene.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
        
        createMenuButtons()
        
        GameKitController.authenticateLocalPlayer()
    }
    
    //MARK: GameKit Methods
    func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                gameCenterIsAuthenticated = newAuthenticationStatus
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
        
        tutorialButton = ButtonNode(imageNamed: "tutorialNormal")
        let rightX: CGFloat = self.frame.width - tutorialButton.frame.width * 0.5 - 20
        let botY: CGFloat = tutorialButton.frame.height * 0.5 + 20
        tutorialButton.setup(atPosition: CGPoint(x: rightX, y: botY), withName: "Tutorial", normalTextureName: "tutorialNormal", highlightedTextureName: "tutorialHighlighted")
        
        self.addChild(playButton)
        self.addChild(scoresButton)
        self.addChild(tutorialButton)
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
                else if object.name == "Tutorial" {
                    tutorialButton.didPress()
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
            tutorialButton.didRelease()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playButton.isPressed {
            playButton.didRelease()
            transitionToGame()
        } else if scoresButton.isPressed {
            scoresButton.didRelease()
            if gameCenterIsAuthenticated {
                postNotification(withName: "presentScores")
            }
        } else if tutorialButton.isPressed {
            tutorialButton.didRelease()
            transitionToTutorial()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        playButton.didRelease()
        scoresButton.didRelease()
        tutorialButton.didRelease()
    }
}
