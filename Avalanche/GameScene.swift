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
    
    func generateRandomBlock() {
        let randomXVal = CGFloat(RandomDouble(min: 32.0, max: Double(self.size.width) - 32.0))
        let randomColor = RandomInt(min: 1, max: 6)
        let roundedBlock = RoundedBlockNode(imageNamed: "RoundedBlock\(randomColor)")
        roundedBlock.setup()
        roundedBlock.position.x = randomXVal
        roundedBlock.position.y = self.size.height
        roundedBlock.beginFalling()
        worldNode.addChild(roundedBlock)
    }
    
    func repeatGenerating(shouldContinue: Bool) {
        if shouldContinue {
            let waitAction = SKAction.waitForDuration(1.0)
            worldNode.runAction(waitAction, completion: { 
                self.generateRandomBlock()
                self.repeatGenerating(true)
            })
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        
        worldNode = SKNode()
        worldNode.position = self.position
        self.addChild(worldNode)
        self.repeatGenerating(true)
        
        let floor = RoundedBlockNode(color: UIColor.blackColor(), size: CGSize(width: 2 * self.size.width, height: self.size.height))
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
        
        //Handle mellow landing on the background or a falling block
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue {
            if contactPoint.y < (mellow.position.y - (mellow.physicsSize.height * 0.40)) {
                if contactPoint.y > (secondBody.node!.position.y + secondBody.node!.frame.height * 0.4) {
                    mellow.isTouchingGround = true
                }
            }
        }
        
        //Handle a falling block landing on the background
        if secondBody.categoryBitMask == CollisionTypes.FallingBlock.rawValue {
            if firstBody.categoryBitMask == CollisionTypes.Background.rawValue {
                if let block = secondBody.node as? RoundedBlockNode, background = firstBody.node as? RoundedBlockNode {
                    block.becomeBackground()
                    if contactPoint.y > (background.position.y + background.physicsSize.height * 0.4)
                        && contactPoint.y < (block.position.y - block.physicsSize.height * 0.4) {
                        let heightDifference = (block.position.y - block.size.height) - (background.position.y - background.size.height)
                        block.position.y -= heightDifference
                        block.becomeBackground()
                    }
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
            if contactPoint.y < (mellow.position.y - (mellow.physicsSize.height * 0.40)) {
                if contactPoint.y > (secondBody.node!.position.y + secondBody.node!.frame.height * 0.4) {
                    mellow.isTouchingGround = false
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //for touch in touches {
        //let location = touch.locationInNode(self)
        if  mellow.isTouchingGround {
            mellow.jump()
        }
        //}
    }
    
    override func update(currentTime: CFTimeInterval) {
        if let data = self.motionManager.accelerometerData {
            mellow.setdx(withAcceleration: data.acceleration.x)
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
