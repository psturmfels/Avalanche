//
//  MellowNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/1/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import UIKit
import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class MellowNode: SKSpriteNode {
    var leftJumpTextures: [SKTexture] = [SKTexture]()
    var rightJumpTextures: [SKTexture] = [SKTexture]()
    var leftWallJumpTextures: [SKTexture] = [SKTexture]()
    var rightWallJumpTextures: [SKTexture] = [SKTexture]()
    let standingTexture: SKTexture = SKTexture(imageNamed: "standing")
    
    var direction: Orientation = .left
    var bottomSideInContact: Int = 0
    var leftSideInContact: Int = 0
    var rightSideInContact: Int = 0
    var physicsSize: CGSize {
        get {
            return CGSize(width: self.size.width * 0.93, height: self.size.height * 0.93)
        }
    }
    
    var upJumpForce: CGFloat  {
        get {
            return 70000.0
        }
    }
    var sideJumpForce: CGFloat {
        get {
            return 60000.0
        }
    }
    
    var trailingNum: Int = 0
    
    var isMoving: Bool = false
    
    //Mark: Creation Method
    func setup(_ position: CGPoint) {
        var i = 1
        while i <= 4 {
            rightJumpTextures.append(SKTexture(imageNamed: "rightjump\(i)"))
            leftJumpTextures.append(SKTexture(imageNamed: "leftjump\(i)"))
            leftWallJumpTextures.append(SKTexture(imageNamed: "leftwalljump\(i)"))
            rightWallJumpTextures.append(SKTexture(imageNamed: "rightwalljump\(i)"))
            i += 1
        }
        while i > 1 {
            i -= 1
            rightJumpTextures.append(SKTexture(imageNamed: "rightjump\(i)"))
            leftJumpTextures.append(SKTexture(imageNamed: "leftjump\(i)"))
            leftWallJumpTextures.append(SKTexture(imageNamed: "leftwalljump\(i)"))
            rightWallJumpTextures.append(SKTexture(imageNamed: "rightwalljump\(i)"))
        }
        
        self.position = position
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.physicsSize)
        
        //The mellow should not bounce
        self.physicsBody!.restitution = 0.0
        
        //Mass is arbitrarily set
        self.physicsBody!.mass = 1
        
        //Make sure the mellow only collides with background and falling blocks
        setBitMasks()
        self.physicsBody!.friction = 0.2
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.name = "mellow"
        self.run(SKAction.rotate(toAngle: 0.0, duration: 0.01), completion: {
            self.physicsBody!.angularVelocity = 0
            self.physicsBody!.allowsRotation = false
        })
        /*I can't figure out why the above line is necessary,
         but for some reason, when I put the mellow code in
         a separate class, it ended up being horizontal!
         The line above rotates it to the right orientation.
         */
    }
    
    func setBitMasks() {
        guard self.physicsBody != nil else {
            return
        }
        
        self.physicsBody!.categoryBitMask = CollisionTypes.mellow.rawValue
        self.physicsBody!.collisionBitMask = CollisionTypes.background.rawValue | CollisionTypes.fallingBlock.rawValue | CollisionTypes.screenBoundary.rawValue | CollisionTypes.oneWayEnabled.rawValue
        self.physicsBody!.contactTestBitMask = CollisionTypes.background.rawValue | CollisionTypes.fallingBlock.rawValue | CollisionTypes.oneWayEnabled.rawValue | CollisionTypes.oneWayDetector.rawValue
    }
    
    //MARK: Motion Methods
    func jump() {
        guard self.physicsBody != nil else {
            return
        }
        
        if bottomSideInContact > 0 && self.physicsBody!.velocity.dy < 10 {
            //Jump upwards, using the correct animations depending on
            //which direction the mellow is facing
            bottomSideInContact = 0
            let forceAction: SKAction = SKAction.applyForce(CGVector(dx: 0, dy: upJumpForce), duration: 0.01)
            var jumpAction: SKAction
            if direction == .right {
                jumpAction = SKAction.animate(with: rightJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
            }
            else {
                jumpAction = SKAction.animate(with: leftJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
            }
            
            let actionSequence = SKAction.sequence([jumpAction, forceAction])
            self.run(actionSequence, withKey: "isJumping")
        }
        else if leftSideInContact > 0 && abs(self.physicsBody!.velocity.dx) < 10 {
            //Wall jump right if the mellow is clinging on to a wall the left side
            leftSideInContact = 0
            bottomSideInContact = 0
            self.physicsBody!.velocity.dy = 0
            let jumpAction = SKAction.animate(with: leftWallJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
            let forceAction = SKAction.applyForce(CGVector(dx: sideJumpForce, dy: upJumpForce), duration: 0.01)
            let actionSequence = SKAction.sequence([jumpAction, forceAction])
            self.run(actionSequence, withKey: "isJumping")
        }
        else if rightSideInContact > 0 && abs(self.physicsBody!.velocity.dx) < 10 {
            //Wall jump left if the mellow is clining to a wall on the right side
            rightSideInContact = 0
            bottomSideInContact = 0
            self.physicsBody!.velocity.dy = 0
            let jumpAction = SKAction.animate(with: rightWallJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
            let forceAction = SKAction.applyForce(CGVector(dx: -sideJumpForce, dy: upJumpForce), duration: 0.01)
            let actionSequence = SKAction.sequence([jumpAction, forceAction])
            self.run(actionSequence, withKey: "isJumping")
        }
    }
    
    func setdx(withAcceleration accel: Double) {
        if fabs(accel) > 0.1 {
            if !isMoving {
                isMoving = true
                GameKitController.lastMoveDate = Date()
            }
            
            var trailingNum: Int = Int(fabs(accel) * 5.0 + 1.0)
            if trailingNum > 3 {
                trailingNum = 3
            }
            self.trailingNum = trailingNum

            //Set proper animations depending on how tilted the screen is
            if accel < 0 {
                if self.action(forKey: "isJumping") == nil {
                    self.texture = SKTexture(imageNamed: "leftRun\(trailingNum)")
                }
                direction = .left
            }
            else {
                if self.action(forKey: "isJumping") == nil {
                    self.texture = SKTexture(imageNamed: "rightrun\(trailingNum)")
                }
                direction = .right
            }
            
            //Set proper horizontal velocity depending on how tilted the screen is
            //by linear growth per frame tilted up to a cutoff
            if self.physicsBody?.velocity.dx < CGFloat(accel) * 1000.0 {
                self.physicsBody!.velocity.dx += 80
                if leftSideInContact > 0 {
                    leftSideInContact = 0
                }
            }
            else if self.physicsBody?.velocity.dx > CGFloat(accel) * 1000.0 {
                self.physicsBody!.velocity.dx -= 80
                if rightSideInContact > 0 {
                    rightSideInContact = 0
                }
            }
            
            //self.physicsBody!.velocity.dx = CGFloat(accel) * 800.0 - 80
        }
        else {
            if isMoving {
                isMoving = false
            }
            self.physicsBody?.velocity.dx = 0
            self.trailingNum = 0
            if self.action(forKey: "isJumping") == nil
            {
                self.texture = self.standingTexture
            }
        }
    }
}
