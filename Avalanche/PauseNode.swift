//
//  PauseNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class PauseNode: SKNode {
    
    var grayScreen: SKShapeNode!
    var audioLabel: LabelNode!
    var audioButton: ButtonNode!
    
    //MARK: Initialization methods
    func setup(withSize size: CGSize, atPosition position: CGPoint) {
        self.name = "pauseNode"
        self.position = position
        var center: CGPoint = CGPoint.zero
    
        grayScreen = SKShapeNode(rectOf: size)
        grayScreen.fillColor = UIColor.gray
        grayScreen.strokeColor = UIColor.gray
        grayScreen.alpha = 0.5
        grayScreen.zPosition = 35
        
        grayScreen.position = center
        grayScreen.name = "grayScreen"
        
        center.y += size.height * 0.3
        audioButton = ButtonNode(imageNamed: "audioButtonNormal")
        audioButton.setup(atPosition: center, withName: "Audio", normalTextureName: "audioButtonNormal", highlightedTextureName: "audioButtonOff")
        audioButton.position.x += audioButton.frame.width * 0.5 + 10
        
        audioLabel = LabelNode()
        audioLabel.setup(withText: "Audio: ", withFontSize: 48.0, atPosition: center)
        audioLabel.position.x -= audioLabel.frame.width * 0.5 + 10
        audioLabel.position.y -= audioLabel.frame.height * 0.5 - 5
        
        centerTwoNodesRelatively(audioLabel, nodeB: audioButton, desiredCenter: center.x)
        
        self.addChild(grayScreen)
        self.addChild(audioButton)
        self.addChild(audioLabel)
    }
    
    func toggleAudioButton() {
        if audioButton.isPressed {
            audioButton.alpha = 1.0
            audioButton.didRelease()
        } else {
            audioButton.alpha = 0.5
            audioButton.didPress()
        }
    }
    
    func centerTwoNodesRelatively(_ nodeA: SKNode, nodeB: SKNode, desiredCenter: CGFloat) {
        let centerX: CGFloat = (nodeA.position.x + nodeB.position.x) * 0.5
        let centerDifference: CGFloat = desiredCenter - centerX
        nodeA.position.x += centerDifference
        nodeB.position.x += centerDifference
    }
}
