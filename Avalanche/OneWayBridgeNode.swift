
//
//  OneWayBridge.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 6/6/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class OneWayBridgeNode: SKSpriteNode {
    var physicsSize: CGSize!
    var detectorNode: SKNode!
    
    func setup(atPoint point: CGPoint) {
        self.position = point
        self.zPosition = -20.0
        
        physicsSize = CGSize(width: self.frame.width * 0.98, height: self.frame.height * 0.98)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.isDynamic = false
        
        self.physicsBody!.categoryBitMask = CollisionTypes.oneWayEnabled.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = 0
        
        self.lightingBitMask = 1
        self.shadowedBitMask = 1
        
        detectorNode = SKNode()
        detectorNode.position = CGPoint.zero
        let expandedSize: CGSize = CGSize(width: self.frame.width * 1.1, height: self.frame.height * 3.0)
        detectorNode.physicsBody = SKPhysicsBody(rectangleOf: expandedSize)
        detectorNode.physicsBody!.usesPreciseCollisionDetection = true
        detectorNode.physicsBody!.categoryBitMask = CollisionTypes.oneWayDisabled.rawValue
        detectorNode.physicsBody!.collisionBitMask = 0
        detectorNode.physicsBody!.contactTestBitMask = 0
        detectorNode.physicsBody!.isDynamic = false
        detectorNode.physicsBody!.restitution = 0.0
        
        self.addChild(detectorNode)
    }
    
    
}
