//
//  GameScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/21/16.
//  Copyright (c) 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion

enum GameStates: Int {
    case GameInProgress = 1
    case GameOver = 2
}

enum ButtonStates {
    case Empty
    case ReplayTapped
    case MenuTapped
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var worldNode: SKNode!
    let motionManager: CMMotionManager = CMMotionManager()
    var mellow: MellowNode!
    var floor: RoundedBlockNode!
    var risingLava: SKSpriteNode!
    var bestSoFar: Int = 0
    var bestLabel: SKLabelNode!
    var currentLabel: SKLabelNode!
    var shouldContinueSpawning = true
    var currentGameState = GameStates.GameInProgress
    var currentButtonState = ButtonStates.Empty
    
    func gameOver() {
        currentGameState = .GameOver
        let screenCenter = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        
        let replayButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        replayButton.fontSize = 48.0
        replayButton.fontColor = UIColor.whiteColor()
        replayButton.text = "Replay"
        replayButton.position = CGPoint(x: screenCenter.x, y: screenCenter.y + replayButton.frame.height)
        replayButton.name = "Replay"
        replayButton.zPosition = 300
        
        let menuButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        menuButton.fontSize = 48.0
        menuButton.fontColor = UIColor.whiteColor()
        menuButton.text = "Menu"
        menuButton.position = CGPoint(x: screenCenter.x, y: screenCenter.y - menuButton.frame.height)
        menuButton.name = "Menu"
        menuButton.zPosition = 300
        
        self.addChild(replayButton)
        self.addChild(menuButton)
    }
    
    func generateRandomBlock(prevPoint: CGPoint) -> CGPoint {
        let randomXVal = CGFloat(RandomDouble(min: 0.0, max: Double(self.size.width)))
        
        let randomColor = RandomInt(min: 1, max: 6)
        let roundedBlock = RoundedBlockNode(imageNamed: "RoundedBlock\(randomColor)")
        roundedBlock.setup()
        roundedBlock.position.x = randomXVal
        roundedBlock.position.y = 2.0 * self.size.height - worldNode.position.y
        roundedBlock.beginFalling()
        worldNode.addChild(roundedBlock)
        return CGPoint(x: randomXVal, y: self.size.height)
    }
    
    func repeatGenerating(shouldContinue: Bool, prevPoint: CGPoint) {
        if shouldContinue {
            let waitAction = SKAction.waitForDuration(1.0)
            worldNode.runAction(waitAction, completion: {
                let nextPoint = self.generateRandomBlock(prevPoint)
                self.repeatGenerating(self.shouldContinueSpawning, prevPoint: nextPoint)
            })
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        
        worldNode = SKNode()
        worldNode.position = self.position
        self.addChild(worldNode)
        self.repeatGenerating(true, prevPoint: CGPoint(x: 0.0, y: self.size.height))
        
        mellow = MellowNode(imageNamed: "standing")
        let mellowPos = CGPoint(x: 30, y: self.size.height * 0.5 - 40.0)
        mellow.setup(mellowPos)
        self.addChild(mellow)
        
        floor = RoundedBlockNode(color: UIColor.blackColor(), size: CGSize(width: 2 * self.size.width, height: self.size.height))
        floor.position = CGPoint(x: self.size.width / 2, y: -floor.size.height / 3)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: floor.size)
        floor.physicsBody!.dynamic = false
        floor.physicsBody!.restitution = 0.0
        floor.physicsBody!.categoryBitMask = CollisionTypes.Background.rawValue
        floor.physicsSize = floor.frame.size
        floor.physicsBody!.collisionBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.FallingBlock.rawValue
        floor.physicsBody!.contactTestBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.FallingBlock.rawValue
        floor.name = "floor"
        worldNode.addChild(floor)
        
        
        let lavaColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.3)
        let lavaSize = CGSize(width: self.size.width + mellow.physicsSize.width * 2.0, height: self.size.height + mellow.physicsSize.height)
        risingLava = SKSpriteNode(color: lavaColor, size: lavaSize)
        risingLava.position = CGPoint(x: lavaSize.width / 2.0, y: -lavaSize.height * 0.9)
        risingLava.physicsBody = SKPhysicsBody(rectangleOfSize: lavaSize)
        risingLava.physicsBody!.dynamic = true
        risingLava.physicsBody!.affectedByGravity = false
        risingLava.physicsBody!.allowsRotation = false
        risingLava.physicsBody!.linearDamping = 0.0
        risingLava.physicsBody!.categoryBitMask = CollisionTypes.Lava.rawValue
        risingLava.physicsBody!.collisionBitMask = 0x00000000
        risingLava.physicsBody!.contactTestBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.Background.rawValue | CollisionTypes.FallingBlock.rawValue
        risingLava.physicsBody!.velocity.dy = 30
        risingLava.name = "lava"
        worldNode.addChild(risingLava)
        
        bestLabel = SKLabelNode(fontNamed: "Arial")
        bestLabel.text = "0 ft"
        bestLabel.fontSize = 36.0
        bestLabel.position = CGPoint(x: self.frame.width * 0.94, y: self.frame.height * 0.93)
        bestLabel.zPosition = 30.0
        bestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(bestLabel)
        
        currentLabel = SKLabelNode(fontNamed: "Arial")
        currentLabel.text = "0 ft"
        currentLabel.fontSize = 30.0
        currentLabel.position = CGPoint(x: self.frame.width * 0.94, y: self.frame.height * 0.88)
        currentLabel.zPosition = 30.0
        currentLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(currentLabel)
        
        motionManager.startAccelerometerUpdates()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactPoint = contact.contactPoint
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue && (secondBody.categoryBitMask == 2 || secondBody.categoryBitMask == 4) {
            //Handle mellow landing on the background or a falling block
            let block = secondBody.node! as! RoundedBlockNode
            let blockYPos: CGFloat = block.position.y + worldNode.position.y
            let blockTopEdge: CGFloat = blockYPos + block.physicsSize.height * 0.4
            let blockLeftEdge: CGFloat = block.position.x - block.physicsSize.width * 0.4
            let blockRightEdge: CGFloat = block.position.x + block.physicsSize.width * 0.4
            
            let mellowBotEdge: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.4
            let mellowRightEdge: CGFloat = mellow.position.x + mellow.physicsSize.width * 0.4
            let mellowLeftEdge: CGFloat = mellow.position.x - mellow.physicsSize.width * 0.4
            
            let blockTopLessMellowBot: Bool = blockTopEdge < mellowBotEdge
            let yPosDiff: CGFloat = abs(blockYPos - mellow.position.y)
            let xPosDiff: CGFloat = abs(block.position.x - mellow.position.x)
            let combinedHeights: CGFloat = block.physicsSize.height * 0.5 + mellow.physicsSize.height * 0.4
            let combinedWidths: CGFloat = block.physicsSize.width * 0.5 + mellow.physicsSize.width * 0.5
            
            if blockTopLessMellowBot && xPosDiff < combinedWidths {
                mellow.bottomSideInContact += 1
            }
            else if blockRightEdge < mellowLeftEdge && yPosDiff < combinedHeights {
                mellow.leftSideInContact += 1
                mellow.physicsBody!.velocity.dx = 0
            }
            else if mellowRightEdge < blockLeftEdge && yPosDiff < combinedHeights {
                mellow.rightSideInContact += 1
                mellow.physicsBody!.velocity.dx = 0
            }
                //Handle the mellow getting crushed by a falling block
            else if mellow.bottomSideInContact > 0 {
                if contactPoint.y > (mellow.position.y + mellow.physicsSize.height * 0.35) {
                    if let block = secondBody.node as? RoundedBlockNode where block.physicsBody!.categoryBitMask == CollisionTypes.FallingBlock.rawValue {
                        if contactPoint.y < (block.position.y + worldNode.position.y - block.physicsSize.height * 0.35) &&
                            abs(mellow.physicsBody!.velocity.dy) < 10 {
                            mellow.physicsBody = nil
                            
                            var crushedTextures = [SKTexture]()
                            for i in 1...7 {
                                crushedTextures.append(SKTexture(imageNamed: "crushed\(i)"))
                            }
                            let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: -10), duration: 0.14)
                            mellow.runAction(moveAction)
                            let crushedAction = SKAction.animateWithTextures(crushedTextures, timePerFrame: 0.02)
                            mellow.runAction(crushedAction, completion: {
                                let mellowCrushedExplosion = SKEmitterNode(fileNamed: "MellowCrushed")!
                                mellowCrushedExplosion.position = self.mellow.position
                                mellowCrushedExplosion.zPosition = 200
                                self.addChild(mellowCrushedExplosion)
                                self.mellow.removeFromParent()
                                self.shouldContinueSpawning = false
                            })
                            let gameOverAction = SKAction.waitForDuration(1.0)
                            self.runAction(gameOverAction) {
                                self.gameOver()
                            }
                        }
                    }
                }
            }
        }
        else if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue && secondBody.categoryBitMask == CollisionTypes.Lava.rawValue {
            mellow.physicsBody = nil
            
            var crushedTextures = [SKTexture]()
            for i in 1...7 {
                crushedTextures.append(SKTexture(imageNamed: "crushed\(i)"))
            }
            let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: -10), duration: 0.14)
            mellow.runAction(moveAction)
            let crushedAction = SKAction.animateWithTextures(crushedTextures, timePerFrame: 0.02)
            self.risingLava.physicsBody!.velocity.dy = 0
            mellow.runAction(crushedAction, completion: {
                let mellowBurned = SKEmitterNode(fileNamed: "MellowBurned")!
                mellowBurned.zPosition = 200
                mellowBurned.position = self.mellow.position
                mellowBurned.position.y -= self.mellow.physicsSize.height * 0.3
                self.addChild(mellowBurned)
                self.mellow.removeFromParent()
                self.shouldContinueSpawning = false
            })
            let gameOverAction = SKAction.waitForDuration(1.0)
            self.runAction(gameOverAction) {
                self.gameOver()
            }
        }
            //Handle a falling block landing on the background
        else if secondBody.categoryBitMask == CollisionTypes.FallingBlock.rawValue {
            if firstBody.categoryBitMask == CollisionTypes.Background.rawValue {
                if let block = secondBody.node as? RoundedBlockNode, _ = firstBody.node as? RoundedBlockNode {
                    block.becomeBackground()
                }
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue && (secondBody.categoryBitMask == 2 || secondBody.categoryBitMask == 4) {
            let block = secondBody.node! as! RoundedBlockNode
            let blockYPos: CGFloat = block.position.y + worldNode.position.y
            let blockTopEdge: CGFloat = blockYPos + block.physicsSize.height * 0.4
            let blockLeftEdge: CGFloat = block.position.x - block.physicsSize.width * 0.4
            let blockRightEdge: CGFloat = block.position.x + block.physicsSize.width * 0.4
            
            let mellowBotEdge: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.4
            let mellowRightEdge: CGFloat = mellow.position.x + mellow.physicsSize.width * 0.4
            let mellowLeftEdge: CGFloat = mellow.position.x - mellow.physicsSize.width * 0.4
            
            let blockTopLessMellowBot: Bool = blockTopEdge < mellowBotEdge
            let yPosDiff: CGFloat = abs(blockYPos - mellow.position.y)
            let xPosDiff: CGFloat = abs(block.position.x - mellow.position.x)
            let combinedHeights: CGFloat = block.physicsSize.height * 0.6 + mellow.physicsSize.height * 0.5
            let combinedWidths: CGFloat = block.physicsSize.width * 0.6 + mellow.physicsSize.width * 0.5
            
            
            //print("Ended contact: \(contactPoint) with \(block.position)")
            if  mellow.bottomSideInContact > 0 && blockTopLessMellowBot && xPosDiff < combinedWidths  {
                mellow.bottomSideInContact -= 1
            }
            if mellow.leftSideInContact > 0 && blockRightEdge < mellowLeftEdge && yPosDiff < combinedHeights {
                mellow.leftSideInContact -= 1
            }
            if mellow.rightSideInContact > 0 && mellowRightEdge < blockLeftEdge && yPosDiff < combinedHeights {
                mellow.rightSideInContact -= 1
            }
        }
        else if firstBody.categoryBitMask != CollisionTypes.Mellow.rawValue && secondBody.categoryBitMask == CollisionTypes.Lava.rawValue {
            if let removeBlock = firstBody.node as? RoundedBlockNode where removeBlock.parent != nil {
                removeBlock.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        
        if currentGameState == .GameInProgress {
            mellow.jump()
        }
        else {
            currentButtonState = .Empty
            for touch in touches {
                let location = touch.locationInNode(self)
                let objects = nodesAtPoint(location) as [SKNode]
                for object in objects {
                    if object.name == "Replay" {
                        currentButtonState = .ReplayTapped
                        break
                    }
                    if object.name == "Menu" {
                        currentButtonState = .MenuTapped
                        break
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentGameState == .GameOver {
            currentButtonState = .Empty
            for touch in touches {
                let location = touch.locationInNode(self)
                let objects = nodesAtPoint(location) as [SKNode]
                for object in objects {
                    if object.name == "Replay" {
                        currentButtonState = .ReplayTapped
                        break
                    }
                    if object.name == "Menu" {
                        currentButtonState = .MenuTapped
                        break
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentGameState == .GameOver {
            switch currentButtonState {
            case .ReplayTapped:
                self.removeFromParent()
                let gameScene = GameScene(fileNamed: "GameScene")!
                gameScene.size = self.size
                let transition = SKTransition.crossFadeWithDuration(0.5)
                gameScene.scaleMode = .AspectFill
                self.scene!.view!.presentScene(gameScene, transition: transition)
            case .MenuTapped:
                currentButtonState = .Empty
                self.removeFromParent()
                let menuScene = MenuScene(size: self.size)
                menuScene.scaleMode = .AspectFill
                let transition = SKTransition.crossFadeWithDuration(0.5)
                self.scene!.view!.presentScene(menuScene, transition: transition)
            case .Empty: break
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if currentGameState == .GameOver {
            currentButtonState = .Empty
        }
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        let distance = ((mellow.position.y - mellow.physicsSize.height / 2.0) - (worldNode.position.y)) / 10.0 - 11.0
        currentLabel.text = "\(Int(distance)) ft"
        if Int(distance) > bestSoFar {
            bestSoFar = Int(distance)
            bestLabel.text = "\(bestSoFar) ft"
        }
        
        if risingLava.physicsBody != nil {
            let lavaYPos = worldNode.position.y + risingLava.position.y
            let distanceToLava = Double(mellow.position.y - lavaYPos - risingLava.frame.height * 0.5)
            let newLavaRisingSpeed = 40.0 - 35.0 * pow(M_PI, -0.003 * distanceToLava)
            risingLava.physicsBody!.velocity.dy = CGFloat(newLavaRisingSpeed)
        }
        
        if mellow.physicsBody != nil {
            if mellow.physicsBody!.velocity.dy > 700 {
                mellow.physicsBody!.velocity.dy *= 0.9
            }
        }
        
        if let data = self.motionManager.accelerometerData where self.mellow.physicsBody != nil {
            mellow.setdx(withAcceleration: data.acceleration.x)
        }
        if mellow.bottomSideInContact == 0 {
            if mellow.leftSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "leftwallcling")
            }
            else if mellow.rightSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "rightwallcling")
            }
        }
        
        if mellow.position.x < -mellow.frame.width / 3 {
            mellow.position.x += (self.size.width + (2.0 / 3.0) * mellow.frame.width )
        }
        else if mellow.position.x > self.size.width + mellow.frame.width / 3 {
            mellow.position.x -= (self.size.width + (2.0 / 3.0) * mellow.frame.width)
        }
        
        if mellow.position.y > self.size.height - 2 * mellow.frame.height {
            let difference = mellow.position.y - (self.size.height - 2 * mellow.frame.height)
            mellow.position.y = self.size.height - 2 * mellow.frame.height
            self.worldNode.position.y -= difference
        }
        else if mellow.position.y < 2 * mellow.frame.height {
            let difference = 2 * mellow.frame.height - mellow.position.y
            mellow.position.y = 2 * mellow.frame.height
            self.worldNode.position.y += difference
        }
    }
}
