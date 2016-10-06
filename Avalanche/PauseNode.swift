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
    
    var soundEffectsLabel: LabelNode!
    var soundEffectsButton: ButtonNode!
    
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
        
        center.y += size.height * 0.15
        soundEffectsButton = ButtonNode(imageNamed: "audioNormal")
        soundEffectsButton.setup(atPosition: center, withName: "SoundEffects", normalTextureName: "audioNormal", highlightedTextureName: "audioOff")
        soundEffectsButton.position.x += soundEffectsButton.frame.width * 0.5 + 10
        
        soundEffectsLabel = LabelNode()
        soundEffectsLabel.setup(withText: "Sound: ", withFontSize: 48.0, atPosition: center)
        soundEffectsLabel.position.x -= soundEffectsLabel.frame.width * 0.5 + 10
        soundEffectsLabel.position.y -= soundEffectsLabel.frame.height * 0.5 - 5
        
        center.y += size.height * 0.15
        audioButton = ButtonNode(imageNamed: "audioNormal")
        audioButton.setup(atPosition: center, withName: "Audio", normalTextureName: "audioNormal", highlightedTextureName: "audioOff")
        audioButton.position.x += audioButton.frame.width * 0.5 + 10
        
        audioLabel = LabelNode()
        audioLabel.setup(withText: "Music: ", withFontSize: 48.0, atPosition: center)
        audioLabel.position.x -= audioLabel.frame.width * 0.5 + 10
        audioLabel.position.y -= audioLabel.frame.height * 0.5 - 5
        
        centerTwoNodesRelatively(audioLabel, nodeB: audioButton, desiredCenter: center.x)
        centerTwoNodesRelatively(soundEffectsLabel, nodeB: soundEffectsButton, desiredCenter: center.x)
        
        self.addChild(grayScreen)
        self.addChild(audioButton)
        self.addChild(audioLabel)
        
        self.addChild(soundEffectsButton)
        self.addChild(soundEffectsLabel)
    }
    
    func toggleButton(_ button: ButtonNode) {
        if button.isPressed {
            button.alpha = 1.0
            button.didRelease()
        } else {
            button.alpha = 0.5
            button.didPress()
        }
    }
    
    func centerTwoNodesRelatively(_ nodeA: SKNode, nodeB: SKNode, desiredCenter: CGFloat) {
        let centerX: CGFloat = (nodeA.position.x + nodeB.position.x) * 0.5
        let centerDifference: CGFloat = desiredCenter - centerX
        nodeA.position.x += centerDifference
        nodeB.position.x += centerDifference
    }
}
