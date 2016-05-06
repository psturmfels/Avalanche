//
//  MellowNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/1/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import UIKit
import SpriteKit

enum Orientation {
    case left
    case right
}

enum CollisionTypes: UInt32 {
    case Mellow = 1
    case Background = 2
    case FallingBlock = 4
}

class MellowNode: SKSpriteNode {
    var leftjumpTextures = [SKTexture]()
    var rightjumpTextures = [SKTexture]()
    var direction: Orientation = .left
    var isTouchingGround = false
    
    func setup() {
        for var i = 1; i <= 4; i += 1 {
            rightjumpTextures.append(SKTexture(imageNamed: "rightjump\(i)"))
            leftjumpTextures.append(SKTexture(imageNamed: "leftjump\(i)"))
        }
        for var i = 4; i >= 1; i -= 1 {
            rightjumpTextures.append(SKTexture(imageNamed: "rightjump\(i)"))
            leftjumpTextures.append(SKTexture(imageNamed: "leftjump\(i)"))
        }
        
        self.position = CGPoint(x: 30 , y: self.size.height / 2)
        let physicsBodySize = CGSize(width: self.texture!.size().width, height: self.texture!.size().height * 0.92)
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsBodySize)
        self.physicsBody!.restitution = 0
        self.physicsBody!.mass = 1
        self.physicsBody!.categoryBitMask = CollisionTypes.Mellow.rawValue
        self.physicsBody!.contactTestBitMask = CollisionTypes.Background.rawValue | CollisionTypes.FallingBlock.rawValue
        self.name = "mellow"
        self.runAction(SKAction.rotateByAngle(CGFloat(M_PI_2) - 0.01, duration: 0.01)) {
            self.physicsBody!.allowsRotation = false
        }
        /*I can't figure out why the above line is necessary,
          but for some reason, when I put the mellow code in
          a separate class, it ended up being horizontal! 
          The line above rotates it to the right orientation.
        */
    }
    
    func jump() {
        let forceAction = SKAction.applyForce(CGVector(dx: 0, dy: 70000), duration: 0.01)
        var jumpAction: SKAction
        if direction == .right {
            jumpAction = SKAction.animateWithTextures(rightjumpTextures, timePerFrame: 0.015, resize: true, restore: true)
        }
        else {
            jumpAction = SKAction.animateWithTextures(leftjumpTextures, timePerFrame: 0.015, resize: true, restore: true)
        }
        
        let actionSequence = SKAction.sequence([jumpAction, forceAction])
        self.runAction(actionSequence)
    }
    
    func setdx(withAcceleration accel: Double) {
        if fabs(accel) > 0.1 {
            var trailingNum: Int = Int(fabs(accel) * 5.0 + 1.0)
            if trailingNum > 3 {
                trailingNum = 3
            }
            
            if accel < 0 {
                if !self.hasActions() {
                    self.texture = SKTexture(imageNamed: "leftRun\(trailingNum)")
                }
                direction = .left
            }
            else {
                if !self.hasActions() {
                    self.texture = SKTexture(imageNamed: "rightrun\(trailingNum)")
                }
                direction = .right
            }
            self.physicsBody!.velocity.dx = CGFloat(accel) * 800.0 - 80
        }
        else {
                self.physicsBody!.velocity.dx = 0
                if (!self.hasActions())
                {
                    self.texture = SKTexture(imageNamed: "standing")
                }
            }
    
    }
    
}
