//
//  GameScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/21/16.
//  Copyright (c) 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion

enum ContactTypes: UInt32 {
    case Mellow = 1
    case Block = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var worldNode: SKNode!
    let motionManager: CMMotionManager = CMMotionManager()
    var mellow: MellowNode!
    var floor: RoundedBlockNode!
    var bestSoFar: Int = 0
    var bestLabel: SKLabelNode!
    var currentLabel: SKLabelNode!
    var shouldContinueSpawning = true
    
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
        
        floor = RoundedBlockNode(color: UIColor.blackColor(), size: CGSize(width: 2 * self.size.width, height: self.size.height))
        floor.position = CGPoint(x: self.size.width / 2, y: -floor.size.height / 3)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: floor.size)
        floor.physicsBody!.dynamic = false
        floor.physicsBody!.restitution = 0.0
        floor.physicsBody!.categoryBitMask = CollisionTypes.Background.rawValue
        floor.physicsSize = floor.frame.size
        floor.physicsBody!.contactTestBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.FallingBlock.rawValue
        floor.name = "floor"
        worldNode.addChild(floor)
        
        mellow = MellowNode(imageNamed: "standing")
        mellow.setup()
        self.addChild(mellow)
        
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
        
        
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue {
            //Handle mellow landing on the background or a falling block
            let floorYPos = secondBody.node!.position.y + worldNode.position.y
            let block = secondBody.node! as! RoundedBlockNode
            if contactPoint.y < (mellow.position.y - (mellow.physicsSize.height * 0.3)) &&
                contactPoint.y > (floorYPos + block.physicsSize.height * 0.3) {
                mellow.isTouchingGround = true
            }
            else if contactPoint.x < (mellow.position.x - mellow.physicsSize.width * 0.4) &&
                contactPoint.x > (block.position.x + block.physicsSize.width * 0.4)
            {
                mellow.leftSideInContact = true
            }
            else if contactPoint.x > (mellow.position.x + mellow.physicsSize.width * 0.4) &&
                contactPoint.x < (block.position.x - block.physicsSize.width * 0.4) {
                mellow.rightSideInContact = true
            }
                //Handle the mellow getting crushed by a falling block
            else if mellow.isTouchingGround {
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
                                self.addChild(mellowCrushedExplosion)
                                self.mellow.removeFromParent()
                                self.shouldContinueSpawning = false
                            })
                        }
                    }
                }
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
        
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue {
            let contactPoint = contact.contactPoint
            let floorYPos = secondBody.node!.position.y + worldNode.position.y
            let block = secondBody.node! as! RoundedBlockNode
            if contactPoint.y < (mellow.position.y - (mellow.physicsSize.height * 0.3)) &&
                contactPoint.y > (floorYPos + secondBody.node!.frame.height * 0.3) &&
                abs(contactPoint.x - mellow.position.x) < mellow.physicsSize.width / 2.2 {
                mellow.isTouchingGround = false
            }
            else if contactPoint.x < (mellow.position.x - mellow.physicsSize.width * 0.4) &&
                contactPoint.x > (block.position.x + block.physicsSize.width * 0.4)
            {
                mellow.leftSideInContact = false
            }
            else if contactPoint.x > (mellow.position.x + mellow.physicsSize.width * 0.4) &&
                contactPoint.x < (block.position.x - block.physicsSize.width * 0.4) {
                mellow.rightSideInContact = false
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //for touch in touches {
        //let location = touch.locationInNode(self)
        mellow.jump()
        //}
    }
    
    override func update(currentTime: CFTimeInterval) {
        let distance = ((mellow.position.y - mellow.physicsSize.height / 2.0) - (worldNode.position.y)) / 5.0 - 22.0
        currentLabel.text = "\(Int(distance)) ft"
        if Int(distance) > bestSoFar {
            bestSoFar = Int(distance)
            bestLabel.text = "\(bestSoFar) ft"
        }
        
        if mellow.physicsBody != nil {
            if mellow.physicsBody!.velocity.dy > 700 {
                mellow.physicsBody!.velocity.dy *= 0.9
            }
        }
        
        if let data = self.motionManager.accelerometerData where self.mellow.physicsBody != nil {
            mellow.setdx(withAcceleration: data.acceleration.x)
        }
        
        if mellow.leftSideInContact {
            print("leftSideInContact")
            mellow.texture = SKTexture(imageNamed: "leftwallcling")
        }
        else if mellow.rightSideInContact {
            print("rightSideInContact")
            mellow.texture = SKTexture(imageNamed: "rightwallcling")
        }
        else {
            print("not touching either")
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
