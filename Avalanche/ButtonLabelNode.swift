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
    
    var isPressed: Bool {
        get {
            return buttonNode.isPressed
        }
    }
    
    var height: CGFloat {
        get {
            return self.buttonNode.frame.height
        }
    }
    
    var width: CGFloat {
        get {
            let combinedHalfWidths: CGFloat = 0.5 * (self.buttonNode.frame.width + self.labelNode.frame.width)
            let centerDistance: CGFloat = self.buttonNode.position.x - self.labelNode.position.x
            return centerDistance + combinedHalfWidths
        }
    }
    
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
        
        centerLabelButtonNodes(CGPoint.zero.x)
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        extendLabelButtonNodes(byAmount: screenWidth * 0.35)
        
        self.addChild(labelNode)
        self.addChild(buttonNode)
    }
    
    func centerLabelButtonNodes(_ desiredCenter: CGFloat) {
        let centerX: CGFloat = (labelNode.position.x + buttonNode.position.x) * 0.5
        let centerDifference: CGFloat = desiredCenter - centerX
        labelNode.position.x += centerDifference
        buttonNode.position.x += centerDifference
    }
    
    func extendLabelButtonNodes(byAmount amount: CGFloat) {
        let currentExtend: CGFloat = buttonNode.position.x + buttonNode.frame.width * 0.5
        let extendDifference: CGFloat = amount - currentExtend
        labelNode.position.x += extendDifference
        buttonNode.position.x += extendDifference
    }
    
    func didPress() {
        self.buttonNode.didPress()
    }
    
    func didRelease(didActivate: Bool = false) {
        self.buttonNode.didRelease(didActivate: didActivate)
    }
}
