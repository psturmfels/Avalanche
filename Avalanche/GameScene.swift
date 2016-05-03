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
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        worldNode = SKNode()
        worldNode.position = self.position
        self.addChild(worldNode)
        
        let floor = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: 2 * self.size.width, height: self.size.height))
        floor.position = CGPoint(x: self.size.width / 2, y: -floor.size.height / 3)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: floor.size)
        floor.physicsBody!.dynamic = false
        floor.name = "floor"
        worldNode.addChild(floor)
        var counter = 1
        
        for _ in 0...10 {
            let redReference = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 40, height: self.size.height / 2))
            var nextY = floor.position.y + floor.frame.height / 2 + redReference.frame.height * CGFloat(counter)
            redReference.position = CGPoint(x: redReference.frame.width, y: nextY)
            redReference.name = "red"
            worldNode.addChild(redReference)
            counter += 1
            
            let greenReference = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: 40, height: self.size.height / 2))
            nextY = floor.position.y + floor.frame.height / 2 + greenReference.frame.height * CGFloat(counter)
            greenReference.position = CGPoint(x: greenReference.frame.width, y: nextY)
            greenReference.name = "green"
            worldNode.addChild(greenReference)
            counter += 1
        }
        
        
        mellow = MellowNode(imageNamed: "standing")
        mellow.setup()
        self.addChild(mellow)
        
        motionManager.startAccelerometerUpdates()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if location.y > self.size.height / 2 {
                mellow.physicsBody!.dynamic = true
                mellow.jump()
            }
            else {
                mellow.physicsBody!.dynamic = false
            }
        }
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
