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
    var originalFallSpeed: CGFloat = -150.0
    
    //MARK: Creation Method
    func setup(_ minFallSpeed: Float, maxFallSpeed: Float) {
        let scale: CGFloat = CGFloat(RandomFloat(min: 0.6, max: 1.8))
        self.setScale(scale)
        
        physicsSize = CGSize(width: self.frame.width * 0.98, height: self.frame.height * 0.98)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.mass = 1000000.0
        
        self.position = CGPoint(x: 256, y: 300)
        self.zPosition = 10.0
        
        self.physicsBody!.categoryBitMask = CollisionTypes.fallingBlock.rawValue
        
        self.physicsBody!.collisionBitMask = CollisionTypes.background.rawValue | CollisionTypes.mellow.rawValue
        self.physicsBody!.contactTestBitMask = CollisionTypes.background.rawValue | CollisionTypes.mellow.rawValue | CollisionTypes.fallingBlock.rawValue
        self.name = "fallingBlock"
        
        self.fallSpeed = RandomCGFloat(min: minFallSpeed, max: maxFallSpeed)
        self.originalFallSpeed = fallSpeed
    }
    
    //MARK: Game Methods
    func becomeBackground() {
        self.name = "backgroundBlock"
        self.physicsBody!.isDynamic = false
        self.run(SKAction.move(by: CGVector(dx: 0, dy: -2.0), duration: 0.0))
        self.physicsBody!.categoryBitMask = CollisionTypes.background.rawValue
        let fadeAction = SKAction.colorize(with: UIColor.black, colorBlendFactor: 1.0, duration: 0.5)
        self.run(fadeAction)
    }
}
