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

class MellowNode: SKSpriteNode {
    var leftjumpTextures = [SKTexture]()
    var rightjumpTextures = [SKTexture]()
    var direction: Orientation = .left
    
    func setup() {
        for var i = 1; i <= 4; i += 1 {
            rightjumpTextures.append(SKTexture(imageNamed: "rightjump\(i)"))
        }
        for var i = 4; i >= 1; i -= 1 {
            rightjumpTextures.append(SKTexture(imageNamed: "rightjump\(i)"))
        }
        
        for var i = 1; i <= 4; i += 1 {
            leftjumpTextures.append(SKTexture(imageNamed: "leftjump\(i)"))
        }
        for var i = 4; i >= 1; i -= 1 {
            leftjumpTextures.append(SKTexture(imageNamed: "leftjump\(i)"))
        }
        
        self.position = CGPoint(x: self.size.width / 2 , y: self.size.height / 2)
        let physicsBodySize = CGSize(width: self.texture!.size().width, height: self.texture!.size().height * 0.93)
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: physicsBodySize)
        self.physicsBody!.restitution = 0
        self.physicsBody!.mass = 1
        self.name = "mellow"
    }
    
    
    
}
