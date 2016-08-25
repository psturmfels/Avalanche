//
//  MellowNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/1/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import UIKit
import SpriteKit

class MellowNode: SKSpriteNode {
    var leftJumpTextures = [SKTexture]()
    var rightJumpTextures = [SKTexture]()
    var leftWallJumpTextures = [SKTexture]()
    var rightWallJumpTextures = [SKTexture]()
    
    var direction: Orientation = .left
    var bottomSideInContact: Int = 0
    var leftSideInContact: Int = 0
    var rightSideInContact: Int = 0
    var physicsSize: CGSize!
    
    //Mark: Creation Method
    func setup(position: CGPoint) {
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
        
        physicsSize = CGSize(width: self.texture!.size().width * 0.65, height: self.texture!.size().height * 0.92)
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        
        //The mellow should not bounce
        self.physicsBody!.restitution = 0.0
        
        //Mass is arbitrarily set
        self.physicsBody!.mass = 1
        
        //Make sure the mellow only collides with background and falling blocks
        self.physicsBody!.categoryBitMask = CollisionTypes.Mellow.rawValue
        self.physicsBody!.collisionBitMask = CollisionTypes.Background.rawValue | CollisionTypes.FallingBlock.rawValue
        self.physicsBody!.contactTestBitMask = CollisionTypes.Background.rawValue | CollisionTypes.FallingBlock.rawValue
        self.physicsBody!.friction = 0.2
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.name = "mellow"
        self.runAction(SKAction.rotateToAngle(0.0, duration: 0.01)) {
            self.physicsBody!.angularVelocity = 0
            self.physicsBody!.allowsRotation = false
        }
        /*I can't figure out why the above line is necessary,
         but for some reason, when I put the mellow code in
         a separate class, it ended up being horizontal!
         The line above rotates it to the right orientation.
         */
    }
    
    //MARK: Motion Methods
    func jump() {
        if self.physicsBody != nil {
            if bottomSideInContact > 0 && self.physicsBody!.velocity.dy < 10 {
                //Jump upwards, using the correct animations depending on
                //which direction the mellow is facing
                bottomSideInContact = 0
                let forceAction = SKAction.applyForce(CGVector(dx: 0, dy: 70000), duration: 0.01)
                var jumpAction: SKAction
                if direction == .right {
                    jumpAction = SKAction.animateWithTextures(rightJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
                }
                else {
                    jumpAction = SKAction.animateWithTextures(leftJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
                }
                
                let actionSequence = SKAction.sequence([jumpAction, forceAction])
                self.runAction(actionSequence)
            }
            else if leftSideInContact > 0 && abs(self.physicsBody!.velocity.dx) < 10 {
                //Wall jump right if the mellow is clinging on to a wall the left side
                leftSideInContact = 0
                bottomSideInContact = 0
                self.physicsBody!.velocity.dy = 0
                let jumpAction = SKAction.animateWithTextures(leftWallJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
                let forceAction = SKAction.applyForce(CGVector(dx: 60000, dy: 70000), duration: 0.01)
                let actionSequence = SKAction.sequence([jumpAction, forceAction])
                self.runAction(actionSequence)
            }
            else if rightSideInContact > 0 && abs(self.physicsBody!.velocity.dx) < 10 {
                //Wall jump left if the mellow is clining to a wall on the right side
                rightSideInContact = 0
                bottomSideInContact = 0
                self.physicsBody!.velocity.dy = 0
                let jumpAction = SKAction.animateWithTextures(rightWallJumpTextures, timePerFrame: 0.01, resize: true, restore: true)
                let forceAction = SKAction.applyForce(CGVector(dx: -60000, dy: 70000), duration: 0.01)
                let actionSequence = SKAction.sequence([jumpAction, forceAction])
                self.runAction(actionSequence)
            }
        }
    }
    
    func setdx(withAcceleration accel: Double) {
        if fabs(accel) > 0.1 {
            var trailingNum: Int = Int(fabs(accel) * 5.0 + 1.0)
            if trailingNum > 3 {
                trailingNum = 3
            }
            //NOTE: The "!self.hasActions()" is checked for before setting the animation
            //So that the animation is not reset while the mellow is jumping
            
            //Set proper animations depending on how tilted the screen is
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
            self.physicsBody?.velocity.dx = 0
            if (!self.hasActions())
            {
                    self.texture = SKTexture(imageNamed: "standing")
            }
        }
    }
}
