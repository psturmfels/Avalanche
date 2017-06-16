
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
            return CGSize(width: self.size.width * 0.98 * self.yScale, height: self.size.height * 0.98 * self.xScale)
        }
    }
    var detectorNodeLarge: SKNode!
    var detectorNodeSmall: SKNode!
    
    func setup(atPoint point: CGPoint) {
        self.position = point
        self.zPosition = -20.0
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.physicsSize)
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
    
    
}
