
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
    
    func setup(atPoint point: CGPoint) {
        self.position = point
        self.zPosition = -5.0
        
        physicsSize = CGSize(width: self.frame.width * 0.98, height: self.frame.height * 0.98)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.isDynamic = false
        
        self.physicsBody!.categoryBitMask = CollisionTypes.oneWayDisabled.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = 0
        
        self.lightingBitMask = 1
        self.shadowedBitMask = 1
    }
    
    
}
