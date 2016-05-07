//
//  RoundedBlockNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/6/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class RoundedBlockNode: SKSpriteNode {
    
    func setup() {
        let scale = CGFloat(RandomFloat(min: 0.5, max: 1.0))
        self.setScale(scale)
        
        let physicsSize = CGSize(width: self.frame.width * 0.96, height: self.frame.height * 0.96)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.dynamic = false
        self.position = CGPoint(x: 256, y: 128)
        
        self.physicsBody!.categoryBitMask = CollisionTypes.FallingBlock.rawValue
        
        self.physicsBody!.contactTestBitMask = CollisionTypes.Background.rawValue | CollisionTypes.Mellow.rawValue
        self.name = "fallingBlock"
    }
}
