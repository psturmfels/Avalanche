//
//  PowerUp.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/19/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {
    static let diameter: CGFloat = 36.0
    
    var physicsSize: CGSize!
    var type: PowerUpTypes!
    
    func indicatorSetup(atPoint point: CGPoint, withType type: PowerUpTypes, asIndicator: Bool = false) {
        self.position = point
        self.type = type
        if asIndicator {
            self.size = CGSize(width: PowerUp.diameter + 4.0, height: PowerUp.diameter + 4.0)
        }
        else {
            self.size = CGSize(width: PowerUp.diameter, height: PowerUp.diameter)
        }
        
        if asIndicator {
            self.texture = SKTexture(imageNamed: "\(self.type.rawValue)Indicator")
        } else {
            self.texture = SKTexture(imageNamed: self.type.rawValue)
        }
        
        physicsSize = CGSize(width: self.frame.width, height: self.frame.height)
        
        self.zPosition = 20.0
    }
    
    func setup(atPoint point: CGPoint, withType type: PowerUpTypes) {
        self.indicatorSetup(atPoint: point, withType: type)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsSize)
        self.physicsBody!.isDynamic = false
        
        self.physicsBody!.categoryBitMask = CollisionTypes.powerUp.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = CollisionTypes.mellow.rawValue | CollisionTypes.lava.rawValue
        
        self.lightingBitMask = 1
        self.shadowedBitMask = 1
        
        let upVector: CGVector = CGVector(dx: 0.0, dy: 8.0)
        let downVector: CGVector = CGVector(dx: 0.0, dy: -8.0)
        let wobbleUp: SKAction = SKAction.move(by: upVector, duration: 0.6)
        let wobbleDown: SKAction = SKAction.move(by: downVector, duration: 0.6)
        let wait: SKAction = SKAction.wait(forDuration: 0.3)
        let sequence: SKAction = SKAction.sequence([wobbleUp, wait, wobbleDown, wait])
        let repeatForever: SKAction = SKAction.repeatForever(sequence)
        self.run(repeatForever)
    }
    
    func beginCountdown() {
        self.createCountdown(withDuration: PowerUpTypes.duration(ofType: self.type), andActionKey: "PowerUpCountdown")
    }
    
    func updateCountDown() {
        self.removeAction(forKey: "PowerUpCountdown")
        self.removeAllChildren()
        self.beginCountdown()
    }
    
    fileprivate func createCountdown(withDuration duration: TimeInterval, andActionKey key: String) {
        let circle: SKShapeNode = SKShapeNode(circleOfRadius: 26.0)
        circle.fillColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        circle.strokeColor = SKColor.clear
        circle.zRotation = CGFloat.pi / 2
        circle.position = CGPoint.zero
        circle.zPosition = -1.0
        self.addChild(circle)
        
        let steps: Int = 360
        
        guard let path = circle.path else {
            return
        }
        
        let radius: CGFloat = path.boundingBox.width/2
        let timeInterval: TimeInterval = duration/TimeInterval(steps)
        let incr: CGFloat = 1 / CGFloat(steps)
        var percent: CGFloat = CGFloat(1.0)
        
        let animate: SKAction = SKAction.run {
            percent -= incr
            circle.path = circlePath(radius: radius, percent: percent)
        }
        
        let wait: SKAction = SKAction.wait(forDuration: timeInterval)
        let action: SKAction = SKAction.sequence([wait, animate])
        let repeatAction: SKAction = SKAction.repeat(action, count: steps - 1)
        let removeCircle: SKAction = SKAction.run {
            circle.removeFromParent()
        }
        let sequence: SKAction = SKAction.sequence([repeatAction, removeCircle])
        
        self.run(sequence, withKey: key)
    }
    
    func remove() {
        self.removeFromParent()
    }
}


fileprivate func circlePath(radius:CGFloat, percent:CGFloat) -> CGPath {
    let start: CGFloat = 0
    let end: CGFloat = CGFloat.pi * 2 * percent
    let center: CGPoint = CGPoint.zero
    let bezierPath: UIBezierPath = UIBezierPath()
    bezierPath.move(to:center)
    bezierPath.addArc(withCenter:center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
    bezierPath.addLine(to:center)
    return bezierPath.cgPath
}
