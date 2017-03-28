//
//  PowerUp.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/19/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {
    var physicsSize: CGSize!
    var type: PowerUpTypes!
    
    func setup(atPoint point: CGPoint, withType: PowerUpTypes) {
        self.position = point
        self.type = withType
        self.size = CGSize(width: 56.0, height: 56.0)
        
        self.texture = SKTexture(imageNamed: self.type.rawValue)
        
        physicsSize = CGSize(width: self.frame.width, height: self.frame.height)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.isDynamic = false
        
        self.zPosition = 10.0
        
        self.physicsBody!.categoryBitMask = CollisionTypes.powerUp.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = CollisionTypes.mellow.rawValue
        
        //TODO: ADD WOBBLE ACTION
        let upVector: CGVector = CGVector(dx: 0.0, dy: 10.0)
        let downVector: CGVector = CGVector(dx: 0.0, dy: -10.0)
        let wobbleUp: SKAction = SKAction.move(by: upVector, duration: 0.7)
        let wobbleDown: SKAction = SKAction.move(by: downVector, duration: 0.7)
        let wait: SKAction = SKAction.wait(forDuration: 0.3)
        let sequence: SKAction = SKAction.sequence([wobbleUp, wait, wobbleDown, wait])
        let repeatForever: SKAction = SKAction.repeatForever(sequence)
        self.run(repeatForever)
    }
    
    func remove() {
        self.removeFromParent()
    }
}
