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
        "Don't stop climbing!\nGood luck!"
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
        createTapToContinue()
    }
    
    //MARK: Initialization Methods
    func createTapToContinue() {
        let tapToContinue: SKLabelNode = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        tapToContinue.fontSize = 16.0
        tapToContinue.text = "(tap to continue)"
        tapToContinue.name = "tapToContinue"
        tapToContinue.position = scrollingText.position
        tapToContinue.position.y -= 3 * tapToContinue.frame.height
        
        runBlink(onNode: tapToContinue)
        
        self.addChild(tapToContinue)
    }
    
    func createMenuButton() {
        menuButton = ButtonNode(imageNamed: "pauseNormal")
        
        let xPos: CGFloat = menuButton.size.width * 0.5 + 20
        let yPos: CGFloat = self.frame.height - xPos
        let buttonPos: CGPoint = CGPoint(x: xPos, y: yPos)
        
        menuButton.setup(atPosition: buttonPos, withName: "Menu", normalTextureName: "menuNormal", highlightedTextureName: "menuHighlighted")
        
        self.addChild(menuButton)
    }
    
    func createCenterBlock(_ minFallSpeed: Float, maxFallSpeed: Float) {
        let centerX: CGFloat = self.frame.midX
        let randomColor: Int = RandomInt(min: 1, max: 8)
        let roundedBlock: RoundedBlockNode = RoundedBlockNode(imageNamed: "RoundedBlock\(randomColor)")
        
        roundedBlock.setup(minFallSpeed, maxFallSpeed: maxFallSpeed)
        
        roundedBlock.position.x = centerX
        roundedBlock.position.y = 1.5 * self.size.height - worldNode.position.y
        
        worldNode.addChild(roundedBlock)
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
        if let tapToContinue = self.childNode(withName: "tapToContinue") {
            tapToContinue.removeFromParent()
        }
        
        switch tutorialIndex {
        case 0:
            let mellowPoint: CGPoint = CGPoint(x: 30, y: self.size.height * 0.5 - 50.0)
            createMellow(atPoint: mellowPoint)
            createExplosion(atPoint: self.mellow.position)
        case 2:
            createExplosion(atPoint: self.mellow.position)
        case 3:
            createExplosion(atPoint: self.mellow.position)
        case 4:
            if tutorialProgress < -1 {
                let mellowPoint: CGPoint = CGPoint(x: 30, y: self.size.height * 0.5 - 50.0)
                createMellow(atPoint: mellowPoint)
                createExplosion(atPoint: self.mellow.position)
            }
        case 5:
            createExplosion(atPoint: self.mellow.position)
        case 6:
            if tutorialProgress < -1 {
                mellow = MellowNode(imageNamed: "standing")
                let mellowPos: CGPoint = CGPoint(x: self.frame.midX, y: self.size.height * 0.7)
                //Most of the initialization of the mellow is done in setup()
                mellow.setup(mellowPos)
                self.addChild(mellow)
                createExplosion(atPoint: self.mellow.position)
            }
        default:
            break
        }
        
        self.resetLabel(withText: self.tutorialMessages[self.tutorialIndex + 1])
    }
    
    func newTaskBegan() {
        if (tutorialIndex == 4 || tutorialIndex == 6) && tutorialProgress > 4 {
            createTapToContinue()
            tutorialProgress = -10
            return
        }
        
        self.tutorialIndex += 1
        self.tutorialProgress = 1
        switch tutorialIndex {
        case 1:
            let rightMove: SKSpriteNode = SKSpriteNode(imageNamed: "playNormal")
            let leftMove: SKSpriteNode = SKSpriteNode(imageNamed: "playNormal")
            leftMove.xScale = -1.0
            rightMove.position = CGPoint(x: self.frame.width - rightMove.frame.width * 0.5 - 20, y: self.frame.midY)
            leftMove.position = CGPoint(x: leftMove.frame.width * 0.5 + 20, y: self.frame.midY)
            
            runBlink(onNode: rightMove)
            runBlink(onNode: leftMove)
            
            rightMove.name = "rightMove"
            leftMove.name = "leftMove"
            
            self.addChild(rightMove)
            self.addChild(leftMove)
        case 4:
            let blockAction: SKAction = SKAction.run {
                self.createCenterBlock(-250, maxFallSpeed: -250)
            }
            let waitAction: SKAction = SKAction.wait(forDuration: 1.0)
            
            let sequence: SKAction = SKAction.sequence([blockAction, waitAction, blockAction, waitAction, blockAction])
            self.run(sequence)
        case 6:
            createLava()
            risingLava.position.y = -risingLava.frame.height * 0.5
            risingLava.physicsBody?.velocity.dy = 45.0
            
            let slowDown: SKAction = SKAction.run {
                if self.risingLava.physicsBody!.velocity.dy > 0.0 {
                    self.risingLava.physicsBody?.velocity.dy -= 1.0
                }
            }
            let waitAction: SKAction = SKAction.wait(forDuration: 0.15)
            var actions: [SKAction] = []
            for _ in 0..<45 {
                actions.append(slowDown)
                actions.append(waitAction)
            }
            
            let sequence: SKAction = SKAction.sequence(actions)
            risingLava.run(sequence) {
                if self.tutorialProgress == 1 {
                    self.didCompleteCurrentTask()
                }
            }
        case 7:
            createTapToContinue()
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
        
        if tutorialIndex == 7 {
            transitionToGameScene()
            return
        }
        
        if tutorialIndex == 0 && tutorialProgress == 1 {
            tutorialProgress = 2
            didCompleteCurrentTask()
        }
        
        if tutorialIndex == 4 && tutorialProgress < -1 {
            didCompleteCurrentTask()
            tutorialProgress = 1
        }
        
        if tutorialIndex == 6 && tutorialProgress < -1 {
            didCompleteCurrentTask()
            tutorialProgress = 1
        }
        
        if noButtonsTapped && tutorialIndex >= 3 {
            if tutorialIndex == 3 && tutorialProgress == 1 {
                didCompleteCurrentTask()
                tutorialProgress = 2
            }
            
            
            if tutorialIndex == 5 && tutorialProgress == 1 {
                let mellowOnLeftWall: Bool = mellow.leftSideInContact > 0 && abs(mellow.physicsBody!.velocity.dx) < 10
                let mellowOnRightWall: Bool = mellow.rightSideInContact > 0 && abs(mellow.physicsBody!.velocity.dx) < 10
                let mellowOnWall: Bool = mellowOnLeftWall || mellowOnRightWall
                let mellowOnGround: Bool = mellow.bottomSideInContact > 0 && mellow.physicsBody!.velocity.dy < 10
                
                if !mellowOnGround && mellowOnWall {
                    didCompleteCurrentTask()
                    tutorialProgress = 2
                }
            }
            
            mellow.jump()
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
            menuButton.didRelease(didActivate: true)
            transitionToMenu()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuButton.didRelease()
    }
    
    //MARK: Override Game Scene Methods
    override func mellowDestroyed(_ by: DeathTypes) {
        //Remove the mellow's physicsBody so it doesn't slide
        mellow.physicsBody = nil
        //Animate through the crushed textures
        var crushedTextures: [SKTexture] = [SKTexture]()
        for i in 1...7 {
            crushedTextures.append(SKTexture(imageNamed: "crushed\(i)"))
        }
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 0.14)
        mellow.run(moveAction)
        let crushedAction = SKAction.animate(with: crushedTextures, timePerFrame: 0.02)
        
        if by == .crushed {
            mellow.run(crushedAction, completion: {
                //Crushed sound effects
                
                self.playSoundEffectNamed("MellowCrushed.wav", waitForCompletion: false)
                
                self.createExplosion(atPoint: self.mellow.position)
                
                self.mellow.removeFromParent()
            })
        } else {
            self.playSoundEffectNamed("MellowBurned.wav", waitForCompletion: false)
            mellow.run(crushedAction, completion: {
                
                //Add the fire after getting crushed
                let mellowBurned = SKEmitterNode(fileNamed: "MellowBurned")!
                mellowBurned.zPosition = 20
                mellowBurned.position = self.mellow.position
                mellowBurned.position.y -= self.mellow.physicsSize.height * 0.3
                self.addChild(mellowBurned)
                
                self.mellow.removeFromParent()
            })
        }
        
        tutorialProgress = 5
        if tutorialIndex < 7 {
            resetLabel(withText: "Didn't I just say\nnot to do that?")
        }
    }
    
    override func turnToBackground(_ block: RoundedBlockNode) {
        block.becomeBackground()
        if tutorialIndex == 4 {
            tutorialProgress += 1
            if tutorialProgress == 4 {
                didCompleteCurrentTask()
            }
        }
    }
    
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
    
    //MARK: Convenience Methods
    func runBlink(onNode node: SKNode) {
        let fadeOut: SKAction = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        let fadeIn: SKAction = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let waitAction: SKAction = SKAction.wait(forDuration: 0.4)
        let sequence: SKAction = SKAction.sequence([fadeOut, fadeIn, waitAction])
        let blinkForever: SKAction = SKAction.repeatForever(sequence)
        
        node.run(blinkForever, withKey: "Blink")
    }
    
    //MARK: Transition Methods
    func transitionToGameScene() {
        GameKitController.report(Achievement.Student, withPercentComplete: 100.0)
        let gameScene: ClassicModeScene = ClassicModeScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)
        gameScene.scaleMode = .resizeFill
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
    
    override func transitionToMenu() {
        let menuScene: MenuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(menuScene, transition: transition)
    }
}
