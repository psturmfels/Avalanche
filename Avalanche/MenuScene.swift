//
//  MenuScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/23/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var playButton: SKLabelNode!
    var isTouchingPlay = false
    
    func playTapped() {
        let gameScene = GameScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        let transition = SKTransition.crossFadeWithDuration(0.5)
        gameScene.scaleMode = .AspectFill
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
    
    override func didMoveToView(view: SKView) {
        let screenCenter = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        
        isTouchingPlay = false
        
        playButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        playButton.text = "Play"
        playButton.fontColor = UIColor.whiteColor()
        playButton.fontSize = 64.0
        playButton.position = screenCenter
        self.addChild(playButton)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouchingPlay = false
        for touch in touches {
            let location = touch.locationInNode(self)
            let objects = nodesAtPoint(location) as [SKNode]
            
            if objects.contains(playButton) {
                isTouchingPlay = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouchingPlay = false
        for touch in touches {
            let location = touch.locationInNode(self)
            let objects = nodesAtPoint(location) as [SKNode]
            
            if objects.contains(playButton) {
                isTouchingPlay = true
                break
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouchingPlay {
            isTouchingPlay = false
            playTapped()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouchingPlay = false
    }
    
    
}
