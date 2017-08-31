//
//  EventNotifierNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/27/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class EventNotifierNode: SKShapeNode {
    static let defaultHeight: CGFloat = 10.0
    
    func setup(atPoint point: CGPoint) {
        self.position = point
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody!.isDynamic = false
        self.physicsBody!.categoryBitMask = CollisionTypes.eventNotifier.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = CollisionTypes.mellow.rawValue
        
        self.strokeColor = UIColor.clear
        self.fillColor = UIColor.clear
        self.name = "eventNotifier"
    }
}
