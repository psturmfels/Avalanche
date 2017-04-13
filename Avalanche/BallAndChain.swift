//
//  BallAndChain.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 4/11/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class BallAndChain: SKNode {
    var ball: SKSpriteNode!
    var links: [SKSpriteNode] = []
    
    func setup(attachedToNode node: SKNode, atPoint point: CGPoint, toParentScene parentScene: SKScene) {
        // Calculate distance & angle
        ball = SKSpriteNode(imageNamed: "ball")
        ball.position = point
        ball.size.height = 40.0
        ball.size.width = 40.0
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
        
        ball.physicsBody!.mass = 50
        ball.physicsBody!.restitution = 0
        ball.physicsBody!.categoryBitMask = CollisionTypes.powerUpObject.rawValue
        ball.physicsBody!.collisionBitMask = CollisionTypes.background.rawValue
        ball.physicsBody!.contactTestBitMask = 0
        parentScene.addChild(ball)
        
        let deltaX: CGFloat = node.position.x - point.x
        let deltaY: CGFloat = node.position.y - point.y - ball.frame.height * 0.5
        let total: CGFloat = deltaX * deltaX + deltaY * deltaY
        let distance: CGFloat = sqrt(total)
        let height: CGFloat = 8.0
        let numLinks = Int(distance / height) - 1
        
        let vX = CGFloat(deltaX) / CGFloat(numLinks)
        let vY = CGFloat(deltaY) / CGFloat(numLinks)
        
        var previousNode: SKSpriteNode?
        let angle: Float = atan2f(Float(deltaY), Float(deltaX))
        
        let ballAnchorPoint: CGPoint = CGPoint(x: self.ball.frame.midX, y: self.ball.frame.maxY)
        let ropeJoint: SKPhysicsJointLimit = SKPhysicsJointLimit.joint(withBodyA: node.physicsBody!, bodyB: ball.physicsBody!, anchorA: node.position, anchorB: ballAnchorPoint)
        ropeJoint.maxLength = ropeJoint.maxLength + 2.0 * CGFloat(numLinks)
        parentScene.physicsWorld.add(ropeJoint)
        
        for i in 0...numLinks {
            var x: CGFloat = ball.position.x
            var y: CGFloat = ball.position.y + ball.frame.height * 0.5
            
            y += vY * CGFloat(i)
            x += vX * CGFloat(i)
            
            let ropeLink:SKSpriteNode = SKSpriteNode(imageNamed: "ropeLink")
            links.append(ropeLink)
            ropeLink.name = "ropeLink"
            ropeLink.size = CGSize(width: 9.0, height: 19.0)
            ropeLink.position = CGPoint(x: x, y: y)
            ropeLink.zRotation = CGFloat(angle + 1.57)
            ropeLink.zPosition = -CGFloat(i)
            
            ropeLink.physicsBody = SKPhysicsBody(rectangleOf: ropeLink.size)
            
            ropeLink.physicsBody!.collisionBitMask = 0
            ropeLink.physicsBody!.categoryBitMask = 0
            ropeLink.physicsBody!.contactTestBitMask = 0
            
            parentScene.addChild(ropeLink)
            
            if let pNode = previousNode {
                let anchorPoint: CGPoint = CGPoint(x: 0.5 * (pNode.position.x + ropeLink.position.x), y: 0.5 * (pNode.position.y + ropeLink.position.y))
//                let anchorPoint: CGPoint = CGPoint(x: ropeLink.frame.midX, y: ropeLink.frame.midY)
                let pin = SKPhysicsJointPin.joint(withBodyA: pNode.physicsBody!, bodyB: ropeLink.physicsBody!, anchor: anchorPoint)
            
                parentScene.physicsWorld.add(pin)
            } else {
                if i == 0 {
                    ropeLink.zRotation = 0.0
                    let pin = SKPhysicsJointPin.joint(withBodyA: self.ball.physicsBody!, bodyB: ropeLink.physicsBody!, anchor: ballAnchorPoint)
                    pin.lowerAngleLimit = 0.0
                    pin.upperAngleLimit = 0.0
                    pin.shouldEnableLimits = true
                    parentScene.physicsWorld.add(pin)
                }
            }
            
            previousNode = ropeLink
        }
        if let pNode = previousNode {
            let anchorPoint: CGPoint = CGPoint(x: pNode.frame.midX, y: pNode.frame.midY)
            let pin: SKPhysicsJointPin = SKPhysicsJointPin.joint(withBodyA: node.physicsBody!, bodyB: pNode.physicsBody!, anchor: anchorPoint)
            parentScene.physicsWorld.add(pin)
        }
    }
    
}
