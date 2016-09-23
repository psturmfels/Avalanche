//
//  PauseNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class PauseNode: SKShapeNode {
 
    func setup(atPosition position: CGPoint) {
        self.fillColor = UIColor.gray
        self.strokeColor = UIColor.gray
        self.alpha = 0.5
        self.zPosition = 25
        
        self.position = position
        self.name = "grayScreen"
    }
}


