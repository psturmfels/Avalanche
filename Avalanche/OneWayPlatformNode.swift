//
//  OneWayPlatformNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 6/18/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class OneWayPlatformNode: RoundedBlockNode {
    let topNode: OneWayPlatformTopNode = OneWayPlatformTopNode()

    override func setFallSpeed() {
        super.setFallSpeed()
        topNode.setDownwardMotion(dy: fallSpeed)
    }
    
    //MARK: Creation Method
    override func setup(_ minFallSpeed: Float, maxFallSpeed: Float) {
        let scale: CGFloat = CGFloat(RandomFloat(min: 1.0, max: 1.4))
        self.setScale(scale)
        
        physicsSize = CGSize(width: self.size.width * 0.98, height: self.size.height * 0.98)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        self.physicsBody!.restitution = 0.0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.mass = 1000000.0
        
        self.position = CGPoint(x: 256, y: 300)
        self.zPosition = -10.0
        
        self.physicsBody!.categoryBitMask = CollisionTypes.oneWayPlatformBottom.rawValue
        self.physicsBody!.collisionBitMask = CollisionTypes.background.rawValue | CollisionTypes.oneWayEnabled.rawValue | CollisionTypes.oneWayDisabled.rawValue
        self.physicsBody!.contactTestBitMask = CollisionTypes.background.rawValue | CollisionTypes.fallingBlock.rawValue | CollisionTypes.oneWayEnabled.rawValue | CollisionTypes.oneWayDisabled.rawValue
        self.name = "fallingBlock"
        
        
        self.lightingBitMask = 1
        self.shadowedBitMask = 1
        self.shadowCastBitMask = 1
        
        let topNodeX: CGFloat = 0.0
        let topNodeY: CGFloat = 0.3 * physicsSize.height
        let topNodePos: CGPoint = CGPoint(x: topNodeX, y: topNodeY)
        
        let topNodeSize: CGSize = CGSize(width: physicsSize.width, height: physicsSize.height * 0.15)
        topNode.size = topNodeSize
        topNode.setup(atPoint: topNodePos)
        topNode.allowMovement()
        self.addChild(topNode)
        
        self.fallSpeed = RandomCGFloat(min: minFallSpeed, max: maxFallSpeed)
        self.originalFallSpeed = fallSpeed
    }

    
    override func becomeBackground() {
        self.name = "backgroundBlock"
        self.physicsBody!.isDynamic = false
        topNode.stopMovement()
        self.run(SKAction.move(by: CGVector(dx: 0, dy: -2.0), duration: 0.0))
    }
}

class OneWayPlatformTopNode: OneWayBridgeNode {
    override var relativePosition: CGPoint {
        get {
            if let oneWayPlatform = self.parent as? OneWayPlatformNode {
                let selfY: CGFloat = self.position.y + oneWayPlatform.position.y
                let selfX: CGFloat = self.position.x + oneWayPlatform.position.x
                return CGPoint(x: selfX, y: selfY)
            } else {
                return self.position
            }
        }
    }
}

