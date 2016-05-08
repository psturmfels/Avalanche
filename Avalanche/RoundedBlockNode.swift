//
//  RoundedBlockNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/6/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class RoundedBlockNode: SKSpriteNode {
    var physicsSize: CGSize!
    var fallSpeed: CGFloat = -75.0
    
    func setup() {
        let scale = CGFloat(RandomFloat(min: 0.5, max: 1.0))
        self.setScale(scale)
        
        physicsSize = CGSize(width: self.frame.width * 0.96, height: self.frame.height * 0.96)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.mass = 1000000.0
        
        self.position = CGPoint(x: 256, y: 300)
        
        self.physicsBody!.categoryBitMask = CollisionTypes.FallingBlock.rawValue
        
        self.physicsBody!.contactTestBitMask = CollisionTypes.Background.rawValue | CollisionTypes.Mellow.rawValue
        self.name = "fallingBlock"
    }
    
    func becomeBackground() {
        self.physicsBody!.categoryBitMask = CollisionTypes.Background.rawValue
        self.physicsBody!.dynamic = false
        let fadeAction = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1.0, duration: 0.5)
        self.runAction(fadeAction)
    }
    
    func beginFalling() {
        self.physicsBody!.velocity.dy = fallSpeed
    }
    
}
