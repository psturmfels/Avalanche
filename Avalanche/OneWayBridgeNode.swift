
//
//  OneWayBridge.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 6/6/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class OneWayBridgeNode: SKSpriteNode {
    var physicsSize: CGSize {
        get {
            return CGSize(width: self.size.width * 0.98, height: self.size.height * 0.98)
        }
    }
    var detectorNodeLarge: SKNode!
    var detectorNodeSmall: SKNode!
    var relativePosition: CGPoint {
        get {
            return self.position
        }
    }
    
    func setup(atPoint point: CGPoint) {
        self.position = point
        self.zPosition = -20.0
        
        if let texture = self.texture {
            self.physicsBody = SKPhysicsBody(texture: texture, size: self.physicsSize)
        } else {
            self.physicsBody = SKPhysicsBody(rectangleOf: self.physicsSize)
        }
        
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.isDynamic = false
        
        self.physicsBody!.categoryBitMask = CollisionTypes.oneWayEnabled.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = 0
        
        self.lightingBitMask = 1
        self.shadowedBitMask = 1
        
        detectorNodeLarge = SKNode()
        detectorNodeLarge.position = CGPoint.zero
        let expandedSizeLarge: CGSize = CGSize(width: self.frame.width * 1.1, height: self.frame.height * 3.0)
        detectorNodeLarge.physicsBody = SKPhysicsBody(rectangleOf: expandedSizeLarge)
        detectorNodeLarge.physicsBody!.usesPreciseCollisionDetection = true
        detectorNodeLarge.physicsBody!.categoryBitMask = CollisionTypes.oneWayDetector.rawValue
        detectorNodeLarge.physicsBody!.collisionBitMask = 0
        detectorNodeLarge.physicsBody!.contactTestBitMask = 0
        detectorNodeLarge.physicsBody!.isDynamic = false
        detectorNodeLarge.physicsBody!.restitution = 0.0
        
        self.addChild(detectorNodeLarge)
        
        detectorNodeSmall = SKNode()
        detectorNodeSmall.position = CGPoint.zero
        let expandedSizeSmall: CGSize = CGSize(width: self.frame.width * 1.05 , height: self.frame.height * 1.5)
        detectorNodeSmall.physicsBody = SKPhysicsBody(rectangleOf: expandedSizeSmall)
        detectorNodeSmall.physicsBody!.usesPreciseCollisionDetection = true
        detectorNodeSmall.physicsBody!.categoryBitMask = CollisionTypes.oneWayDetector.rawValue
        detectorNodeSmall.physicsBody!.collisionBitMask = 0
        detectorNodeSmall.physicsBody!.contactTestBitMask = 0
        detectorNodeSmall.physicsBody!.isDynamic = false
        detectorNodeSmall.physicsBody!.restitution = 0.0
        
        self.addChild(detectorNodeSmall)
    }
    
    func allowMovement() {
        self.physicsBody!.isDynamic = true
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.mass = 1000000.0
        
        detectorNodeLarge.physicsBody!.isDynamic = true
        detectorNodeLarge.physicsBody!.restitution = 0.0
        detectorNodeLarge.physicsBody!.affectedByGravity = false
        detectorNodeLarge.physicsBody!.allowsRotation = false
        detectorNodeLarge.physicsBody!.linearDamping = 0.0
        detectorNodeLarge.physicsBody!.mass = 1000000.0
        
        detectorNodeSmall.physicsBody!.isDynamic = true
        detectorNodeSmall.physicsBody!.restitution = 0.0
        detectorNodeSmall.physicsBody!.affectedByGravity = false
        detectorNodeSmall.physicsBody!.allowsRotation = false
        detectorNodeSmall.physicsBody!.linearDamping = 0.0
        detectorNodeSmall.physicsBody!.mass = 1000000.0
    }
    
    func stopMovement() {
        self.physicsBody!.isDynamic = false
        detectorNodeLarge.physicsBody!.isDynamic = false
        detectorNodeSmall.physicsBody!.isDynamic = false
    }
    
    func setDownwardMotion(dy: CGFloat) {
        self.physicsBody!.velocity.dy = dy
        detectorNodeLarge.physicsBody!.velocity.dy = dy
        detectorNodeSmall.physicsBody!.velocity.dy = dy
    }
}
