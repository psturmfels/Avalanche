//
//  ButtonLabelNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 10/9/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class ButtonLabelNode: SKNode {
    var labelNode: LabelNode!
    var buttonNode: ButtonNode!
    
    func setup(withText text: String, withFontSize fontSize: CGFloat, withButtonName name: String, normalTextureName: String, highlightedTextureName: String, atPosition nodePosition: CGPoint) {
        self.position = nodePosition
        
        labelNode = LabelNode()
        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center

        labelNode.setup(withText: text, withFontSize: fontSize, atPosition: CGPoint.zero)
        labelNode.position.x -= labelNode.frame.width * 0.5 + 10
        
        buttonNode = ButtonNode(imageNamed: normalTextureName)
        buttonNode.setup(atPosition: CGPoint.zero, withName: name, normalTextureName: normalTextureName, highlightedTextureName: highlightedTextureName)
        buttonNode.position.x += buttonNode.frame.width * 0.5 + 10
        
        centerLabelButtonNodes(labelNode, buttonNode: buttonNode, desiredCenter: CGPoint.zero.x)
        
        self.addChild(labelNode)
        self.addChild(buttonNode)
    }
    
    func centerLabelButtonNodes(_ labelNode: LabelNode, buttonNode: ButtonNode, desiredCenter: CGFloat) {
        let centerX: CGFloat = (labelNode.position.x + buttonNode.position.x) * 0.5
        let centerDifference: CGFloat = desiredCenter - centerX
        labelNode.position.x += centerDifference
        buttonNode.position.x += centerDifference
    }
}
