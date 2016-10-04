//
//  LabelNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 10/4/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class LabelNode: SKLabelNode {
    func setup(withText text: String, withFontSize fontSize: CGFloat, atPosition position: CGPoint) {
        self.fontName = "AmericanTypewriter-Bold"
        self.color = UIColor.white
        self.fontSize = fontSize
        self.text = text
        self.position = position
        self.zPosition = 40.0
    }
}
