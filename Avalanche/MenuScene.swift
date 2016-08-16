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
    var isTouchingPlay: Bool = false
    
    //MARK: Button Methods
    func playTapped() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Game Scene
        let gameScene: GameScene = GameScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        gameScene.scaleMode = .ResizeFill

        let transition = SKTransition.crossFadeWithDuration(0.5)
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
    
    
    //MARK: View Methods
    override func didMoveToView(view: SKView) {
        createPlayButton()
    }
    
    //MARK: Creation Methods
    func createPlayButton() {
        let screenCenter = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        isTouchingPlay = false
        
        playButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        playButton.text = "Play"
        playButton.fontColor = UIColor.whiteColor()
        playButton.fontSize = 64.0
        playButton.position = screenCenter
        self.addChild(playButton)
    }
    
    //MARK: Touch Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouchingPlay = false
        for touch in touches {
            let location = touch.locationInNode(self)
            let objects = nodesAtPoint(location) as [SKNode]
            
            //If any of the touches begins at a play button,
            //the user is then holding the play button down
            if objects.contains(playButton) {
                isTouchingPlay = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Assume that the user moved the touch outside of the play button range to begin with
        let copy = isTouchingPlay
        isTouchingPlay = false
        
        //If the play button was held down before the move
        if copy {
            for touch in touches {
                let location = touch.locationInNode(self)
                let objects = nodesAtPoint(location) as [SKNode]
                
                if objects.contains(playButton) {
                    //And if any of the touches remained on the play button,
                    //the user is still holding the play button down
                    isTouchingPlay = true
                    break
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouchingPlay {
            //This is the "touch-up-inside" pattern:
            //The play button is tapped if a touch began and ended inside the play button
            isTouchingPlay = false
            playTapped()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouchingPlay = false
    }
    
    
}
