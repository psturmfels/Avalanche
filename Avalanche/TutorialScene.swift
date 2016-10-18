//
//  TutorialScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 10/18/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class TutorialScene: GameScene {
    var menuButton: ButtonNode!
    
    var scrollingText: SKLabelNode!
    fileprivate let tutorialMessages: [String] = [
        "Welcome to the\ntutorial!",
        "Tilt to move\nleft and right",
        "Go off the side\n of the screen",
        "Tap to jump",
        "Don't get crushed\nby the falling blocks",
        "You can wall-jump\nTry jumping off\nthe side of the block",
        "Don't touch\nthe rising lava",
        ""
    ]
    var tutorialIndex: Int = 0
    var tutorialProgress: Int = 1
    
    override func didMove(to view: SKView) {
        scrollingText = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        scrollingText.fontSize = 32.0
        scrollingText.verticalAlignmentMode = .center
        scrollingText.text = tutorialMessages[tutorialIndex]
        scrollingText = scrollingText.multilined()
        scrollingText.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 1.3)
        self.addChild(scrollingText)
        
        currentGameState = .tutorial
        
        createMenuButton()
        createWorld()
        //        createMellow()
        createFloor()
        //        createLava()
        createLabels()
        createBackground()
        //        createControlButton()
        //        createPauseNode()
        //        createBackgroundNotifications()
        //        startMusic()
    }
    
    //MARK: Initialization Methods
    func createMenuButton() {
        menuButton = ButtonNode(imageNamed: "pauseNormal")
        
        let xPos: CGFloat = menuButton.size.width * 0.5 + 20
        let yPos: CGFloat = self.frame.height - xPos
        let buttonPos: CGPoint = CGPoint(x: xPos, y: yPos)
        
        menuButton.setup(atPosition: buttonPos, withName: "Menu", normalTextureName: "menuNormal", highlightedTextureName: "menuHighlighted")
        
        self.addChild(menuButton)
    }
    
    func createExplosion(atPoint point: CGPoint) {
        let mellowCrushedExplosion = SKEmitterNode(fileNamed: "MellowCrushed")!
        mellowCrushedExplosion.position = point
        mellowCrushedExplosion.zPosition = 20
        self.addChild(mellowCrushedExplosion)
    }
    
    //MARK: Scrolling Text Methods
    func dismissText() {
        let leftShudder1: SKAction = SKAction.moveBy(x: -20.0, y: 0.0, duration: 0.1)
        let leftShudder2: SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.1)
        let leftShudder3: SKAction = SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.1)
        
        let rightSweep: SKAction = SKAction.moveTo(x: 2 * self.frame.width + scrollingText.frame.width, duration: 0.5)
        let moveSequence: SKAction = SKAction.sequence([leftShudder1, leftShudder2, leftShudder3, rightSweep])
        scrollingText.run(moveSequence)
    }
    
    func scrollLabel(withText text: String) {
        scrollingText.removeFromParent()
        let dummyLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        dummyLabel.fontSize = 32.0
        dummyLabel.verticalAlignmentMode = .center
        dummyLabel.text = text
        
        scrollingText = dummyLabel.multilined()
        scrollingText.position = CGPoint(x: -2 * self.frame.width , y: self.frame.midY * 1.3)
        self.addChild(scrollingText)
        
        let offset: CGFloat = 35.0
        let rightSweep: SKAction = SKAction.moveTo(x: self.frame.midX + offset, duration: 0.5)
        let leftShudder1: SKAction = SKAction.moveBy(x: -20.0, y: 0.0, duration: 0.1)
        let leftShudder2: SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.1)
        let leftShudder3: SKAction = SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.1)
        let moveSequence: SKAction = SKAction.sequence([rightSweep, leftShudder1, leftShudder2, leftShudder3])
        scrollingText.run(moveSequence) {
            self.newTaskBegan()
        }
    }
    
    func resetLabel(withText text: String) {
        let leftShudder1: SKAction = SKAction.moveBy(x: -20.0, y: 0.0, duration: 0.1)
        let leftShudder2: SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.1)
        let leftShudder3: SKAction = SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.1)
        
        let rightSweep: SKAction = SKAction.moveTo(x: 2 * self.frame.width, duration: 0.5)
        let moveSequence: SKAction = SKAction.sequence([leftShudder1, leftShudder2, leftShudder3, rightSweep])
        scrollingText.run(moveSequence) {
            self.scrollLabel(withText: text)
        }
    }
    
    //MARK: Task Methods
    func didCompleteCurrentTask() {
        switch tutorialIndex {
        case 0:
            createMellow()
            createExplosion(atPoint: self.mellow.position)
        case 2:
            createExplosion(atPoint: self.mellow.position)
        case 3:
            createExplosion(atPoint: self.mellow.position)
        default:
            break
        }
        
        self.resetLabel(withText: self.tutorialMessages[self.tutorialIndex + 1])
    }
    
    func newTaskBegan() {
        self.tutorialIndex += 1
        self.tutorialProgress = 1
        switch tutorialIndex {
        case 1:
            let rightMove: SKSpriteNode = SKSpriteNode(imageNamed: "playNormal")
            let leftMove: SKSpriteNode = SKSpriteNode(imageNamed: "playNormal")
            leftMove.xScale = -1.0
            rightMove.position = CGPoint(x: self.frame.width - rightMove.frame.width * 0.5 - 20, y: self.frame.midY)
            leftMove.position = CGPoint(x: leftMove.frame.width * 0.5 + 20, y: self.frame.midY)
            
            let fadeOut: SKAction = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
            let fadeIn: SKAction = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            let waitAction: SKAction = SKAction.wait(forDuration: 0.7)
            let sequence: SKAction = SKAction.sequence([fadeOut, fadeIn, waitAction])
            let blinkForever: SKAction = SKAction.repeatForever(sequence)
            
            rightMove.run(blinkForever)
            leftMove.run(blinkForever)
            
            rightMove.name = "rightMove"
            leftMove.name = "leftMove"
            
            self.addChild(rightMove)
            self.addChild(leftMove)
        default:
            break
        }
    }
    
    //MARK: Touch Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var noButtonsTapped: Bool = true
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Menu" {
                    menuButton.didPress()
                    noButtonsTapped = false
                    return
                }
            }
        }
        
        if tutorialIndex == 0 {
            didCompleteCurrentTask()
        }
        
        if noButtonsTapped && tutorialIndex >= 3 {
            mellow.jump()
            if tutorialIndex == 3 && tutorialProgress == 1 {
                didCompleteCurrentTask()
                tutorialProgress = 2
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Menu" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            menuButton.didRelease()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if menuButton.isPressed {
            menuButton.didRelease()
            transitionToMenu()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuButton.didRelease()
    }
    
    //MARK: Override Game Scene Methods
    override func mellowAccel() {
        if let data = self.motionManager.accelerometerData {
            mellow.setdx(withAcceleration: data.acceleration.x)
            if tutorialIndex == 1 && tutorialProgress > 0 {
                if data.acceleration.x > 0.2 {
                    if let rightMove = self.childNode(withName: "rightMove") {
                        createExplosion(atPoint: rightMove.position)
                        rightMove.removeFromParent()
                    }
                    
                    if tutorialProgress % 3 == 0 {
                        tutorialProgress = 0
                        didCompleteCurrentTask()
                    }
                    else if tutorialProgress % 2 != 0 {
                        tutorialProgress *= 2
                    }
                } else if data.acceleration.x < -0.2 {
                    if let leftMove = self.childNode(withName: "leftMove") {
                        createExplosion(atPoint: leftMove.position)
                        leftMove.removeFromParent()
                    }
                    
                    if tutorialProgress % 2 == 0 {
                        tutorialProgress = 0
                        didCompleteCurrentTask()
                    }
                    else if tutorialProgress % 3 != 0 {
                        tutorialProgress *= 3
                    }
                }
            }
        }
        
        
        if mellow.bottomSideInContact == 0 {
            //Add the wall-cling animations if the mellow is touching a wall and is off the ground
            if mellow.leftSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "leftwallcling")
            }
            else if mellow.rightSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "rightwallcling")
            }
        }
    }
    
    override func mellowContain() {
        //Make the mellow "wrap-around" the screen
        //if it goes off the horizontal edges
        let mellowTwoThirds: CGFloat = (2.0 / 3.0) * mellow.frame.width
        let mellowTwiceHeight: CGFloat = 2 * mellow.frame.height
        let mellowThriceHeight: CGFloat = 3 * mellow.frame.height
        
        if mellow.position.x < -mellow.frame.width / 3 {
            mellow.position.x += self.size.width + mellowTwoThirds
            if tutorialIndex == 2 && tutorialProgress == 1 {
                tutorialProgress = 2
                didCompleteCurrentTask()
            }
        }
        else if mellow.position.x > self.size.width + mellow.frame.width / 3 {
            mellow.position.x -= self.size.width + mellowTwoThirds
            if tutorialIndex == 2 && tutorialProgress == 1 {
                tutorialProgress = 2
                didCompleteCurrentTask()
            }
        }
        
        //If the mellow gets too close to the top or bottom of the screen,
        //move the world as opposed to the mellow, ensuring that
        //the mellow always stays on the screen.
        if mellow.position.y > self.size.height - mellowThriceHeight {
            let difference: CGFloat = mellow.position.y - (self.size.height - mellowThriceHeight)
            mellow.position.y = self.size.height - mellowThriceHeight
            self.worldNode.position.y -= difference
        }
        else if mellow.position.y < mellowTwiceHeight {
            let difference: CGFloat = mellowTwiceHeight - mellow.position.y
            mellow.position.y = mellowTwiceHeight
            self.worldNode.position.y += difference
        }
    }
    
    
    //MARK: Transition Methods
    func transitionToMenu() {
        let menuScene: MenuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(menuScene, transition: transition)
    }
}
