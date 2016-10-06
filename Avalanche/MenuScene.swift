//
//  MenuScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/23/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var playButton: ButtonNode!
    var scoresButton: ButtonNode!
    
    //MARK: Button Methods
    func playTapped() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Game Scene
        let gameScene: GameScene = GameScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        gameScene.scaleMode = .resizeFill
        
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
    
    
    //MARK: View Methods
    override func didMove(to view: SKView) {
        createPlayButton()
    }
    
    //MARK: Creation Methods
    func createPlayButton() {
        let center: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        playButton = ButtonNode(imageNamed: "playTextNormal")
        playButton.setup(atPosition: center, withName: "Play", normalTextureName: "playTextNormal", highlightedTextureName: "playTextHighlighted")
        playButton.position.y += playButton.frame.height * 0.5 + 10
        
        scoresButton = ButtonNode(imageNamed: "scoresNormal")
        scoresButton.setup(atPosition: center, withName: "Scores", normalTextureName: "scoresNormal", highlightedTextureName: "scoresHighlighted")
        scoresButton.position.y -= scoresButton.frame.height * 0.5 + 10
        
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
                else if object.name == "Scores" {
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
            playTapped()
        } else if scoresButton.isPressed {
            scoresButton.didRelease()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        playButton.didRelease()
        scoresButton.didRelease()
    }
    
    
}
