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
    var bottomSideInContact: Int = 0 {
        didSet {
            self.removeAction(forKey: "DisableJump0")
            if bottomSideInContact > 0 {
                canJump = true
            }
            if oldValue == 0 && bottomSideInContact > 0 {
                consecutiveWallJumps = 0
            }
        }
    }
    var leftSideInContact: Int = 0 {
        didSet {
            self.removeAction(forKey: "DisableJump1")
            if leftSideInContact > 0 {
                canWallJumpRight = true
            }
        }
    }
    var rightSideInContact: Int = 0 {
        didSet {
            self.removeAction(forKey: "DisableJump2")
            if rightSideInContact > 0 {
                canWallJumpLeft = true
            }
        }
    }
    var physicsSize: CGSize {
        get {
            return CGSize(width: self.size.width * 0.93, height: self.size.height * 0.93)
        }
    }
    
    var upJumpForce: CGFloat = 70000.0
    var sideJumpForce: CGFloat = 60000.0
    var sideMoveModifier: CGFloat = 1000.0
    
    var trailingNum: Int = 0
    
    var isMoving: Bool = false
    var shouldJumpFromBuffer: Bool = false
    var canJump: Bool = false {
        didSet {
            if shouldJumpFromBuffer && canJump {
                jump()
            }
        }
    }
    var canWallJumpRight: Bool = false {
        didSet {
            if shouldJumpFromBuffer && canWallJumpRight {
                jump()
            }
        }
    }
    var canWallJumpLeft: Bool = false {
        didSet {
            if shouldJumpFromBuffer && canWallJumpLeft {
                jump()
            }
        }
    }
    var consecutiveWallJumps: Int = 0 {
        didSet {
            if consecutiveWallJumps == 5 {
                GameKitController.report(Achievement.BlockHugger, withPercentComplete: 100.0)
            }
            if consecutiveWallJumps == 10 {
                GameKitController.report(Achievement.Ninja, withPercentComplete: 100.0)
            }
        }
    }
    
    func disableJumpAfterTime(jumpType: Int) {
        self.removeAction(forKey: "DisableJump\(jumpType)")
        let waitAction: SKAction = SKAction.wait(forDuration: 0.1)
        let disableAction: SKAction = SKAction.run { [unowned self] in
            if jumpType == 0 {
                self.canJump = false
            }
            else if jumpType == 1 {
                self.canWallJumpRight = false
            }
            else if jumpType == 2 {
                self.canWallJumpLeft = false
            }
        }
        let actionSequence: SKAction = SKAction.sequence([waitAction, disableAction])
        self.run(actionSequence, withKey: "DisableJump\(jumpType)")
    }
    
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
        self.removeAction(forKey: "jumpBuffer")
        shouldJumpFromBuffer = false
        
        if canJump && self.physicsBody!.velocity.dy < 10 {
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
            
            let actionSequence: SKAction = SKAction.sequence([forceAction, jumpAction])
            self.run(actionSequence, withKey: "isJumping")
            canJump = false
            canWallJumpRight = false
            canWallJumpLeft = false
        }
        else if canWallJumpRight {
            consecutiveWallJumps += 1
            
            //Wall jump right if the mellow is clinging on to a wall the left side
            leftSideInContact = 0
            bottomSideInContact = 0
            self.physicsBody!.velocity.dy = 0
            let jumpAction: SKAction = SKAction.animate(with: leftWallJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
            let forceAction: SKAction = SKAction.applyForce(CGVector(dx: sideJumpForce, dy: upJumpForce), duration: 0.01)
            let actionSequence: SKAction = SKAction.sequence([forceAction, jumpAction])
            self.run(actionSequence, withKey: "isJumping")
            canJump = false
            canWallJumpRight = false
            canWallJumpLeft = false
        }
        else if canWallJumpLeft {
            consecutiveWallJumps += 1
            
            //Wall jump left if the mellow is clining to a wall on the right side
            rightSideInContact = 0
            bottomSideInContact = 0
            self.physicsBody!.velocity.dy = 0
            let jumpAction: SKAction = SKAction.animate(with: rightWallJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
            let forceAction: SKAction = SKAction.applyForce(CGVector(dx: -sideJumpForce, dy: upJumpForce), duration: 0.01)
            let actionSequence: SKAction = SKAction.sequence([forceAction, jumpAction])
            self.run(actionSequence, withKey: "isJumping")
            canJump = false
            canWallJumpRight = false
            canWallJumpLeft = false
        } else {
            shouldJumpFromBuffer = true
            let waitAction: SKAction = SKAction.wait(forDuration: 0.08)
            let disableBuffer: SKAction = SKAction.run({ [unowned self] in
                self.shouldJumpFromBuffer = false
            })
            let actionSequence: SKAction = SKAction.sequence([waitAction, disableBuffer])
            self.run(actionSequence, withKey: "jumpBuffer")
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
            if self.physicsBody?.velocity.dx < CGFloat(accel) * sideMoveModifier {
                self.physicsBody!.velocity.dx += 80
                if leftSideInContact > 0 {
                    leftSideInContact = 0
                }
            }
            else if self.physicsBody?.velocity.dx > CGFloat(accel) * sideMoveModifier {
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
