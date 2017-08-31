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
    let fractionPhyiscs: CGFloat = 0.75

    override func setFallSpeed() {
        super.setFallSpeed()
        topNode.setDownwardMotion(dy: fallSpeed)
    }
    
    //MARK: Creation Method
    override func setup(_ minFallSpeed: Float, maxFallSpeed: Float, andScale targetScale: CGFloat = -1.0) {
        physicsSize = CGSize(width: self.size.width * 0.98, height: self.size.height * fractionPhyiscs)
        
        let physicsY: CGFloat = -0.5 * (self.size.height - self.physicsSize.height)
        let physicsCenter: CGPoint = CGPoint(x: 0.0, y: physicsY)
        self.physicsBody = SKPhysicsBody(rectangleOf: physicsSize, center: physicsCenter)
        
        
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
        self.shadowCastBitMask = 0
        
        let topNodeHeight: CGFloat = (1.1 - fractionPhyiscs) * physicsSize.height
        let topNodeSize: CGSize = CGSize(width: physicsSize.width * 1.05, height: topNodeHeight)
        let topNodeX: CGFloat = 0.0
        let topNodeY: CGFloat = (fractionPhyiscs - 0.5) * self.physicsSize.height + 0.7 * topNodeHeight
        let topNodePos: CGPoint = CGPoint(x: topNodeX, y: topNodeY)
        
        topNode.size = topNodeSize
        topNode.setup(atPoint: topNodePos)
        topNode.allowMovement()
        topNode.name = "topNode"
        self.addChild(topNode)
        
        self.fallSpeed = RandomCGFloat(min: minFallSpeed, max: maxFallSpeed)
        self.originalFallSpeed = fallSpeed
        
        if targetScale < 0.0 {
            let scale: CGFloat = CGFloat(RandomFloat(min: 1.2, max: 1.6))
            self.setScale(scale)
        } else {
            self.setScale(targetScale)
        }
    }

    
    override func becomeBackground() {
        self.name = "backgroundBlock"
        topNode.stopMovement()
        self.physicsBody!.isDynamic = false
        
        let topNodeY: CGFloat = (fractionPhyiscs - 0.5) * self.physicsSize.height + 0.7 * topNode.size.height
        topNode.run(SKAction.moveTo(y: topNodeY, duration: 0.0))
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

