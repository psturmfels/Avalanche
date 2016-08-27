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
    var fallSpeed: CGFloat = -150.0 {
        didSet {
            self.physicsBody!.velocity.dy = fallSpeed
        }
    }
    
    //MARK: Creation Method
    func setup(minFallSpeed: Float, maxFallSpeed: Float) {
        let scale = CGFloat(RandomFloat(min: 0.5, max: 1.75))
        self.setScale(scale)
        
        physicsSize = CGSize(width: self.frame.width * 0.90, height: self.frame.height * 0.90)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.mass = 1000000.0
        
        self.position = CGPoint(x: 256, y: 300)
        self.zPosition = 10.0
        
        self.physicsBody!.categoryBitMask = CollisionTypes.FallingBlock.rawValue
        
        self.physicsBody!.collisionBitMask = CollisionTypes.Background.rawValue | CollisionTypes.Mellow.rawValue
        self.physicsBody!.contactTestBitMask = CollisionTypes.Background.rawValue | CollisionTypes.Mellow.rawValue | CollisionTypes.FallingBlock.rawValue
        self.name = "fallingBlock"
        
        fallSpeed = RandomCGFloat(min: minFallSpeed, max: maxFallSpeed)
    }
    
    //MARK: Game Methods
    func becomeBackground() {
        self.physicsBody!.dynamic = false
        self.runAction(SKAction.moveBy(CGVector(dx: 0, dy: -2.0), duration: 0.0))
        self.physicsBody!.categoryBitMask = CollisionTypes.Background.rawValue
        let fadeAction = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1.0, duration: 0.5)
        self.runAction(fadeAction)
    }
    
}
