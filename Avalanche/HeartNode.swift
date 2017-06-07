//
//  HeartNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 6/3/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit

class Heart: SKSpriteNode {
    func setup(atPoint point: CGPoint) {
        self.position = point
        self.size.width = 26.0
        self.size.height = 26.0
        self.name = "heart"
        self.zPosition = 20.0
    }
}
