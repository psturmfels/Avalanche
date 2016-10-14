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
    
    var audioButtonLabel: ButtonLabelNode!
    var soundEffectsButtonLabel: ButtonLabelNode!
    var selfDestructButtonLabel: ButtonLabelNode!
    
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
        self.addChild(grayScreen)
        
        soundEffectsButtonLabel = ButtonLabelNode()
        soundEffectsButtonLabel.setup(withText: "Sound: ", withFontSize: 48.0, withButtonName: "SoundEffects", normalTextureName: "audioNormal", highlightedTextureName: "audioOff", atPosition: center)
        self.addChild(soundEffectsButtonLabel)
        
        center.y += size.height * 0.12
        audioButtonLabel = ButtonLabelNode()
        audioButtonLabel.setup(withText: "Music: ", withFontSize: 48.0, withButtonName: "Audio", normalTextureName: "audioNormal", highlightedTextureName: "audioOff", atPosition: center)
        self.addChild(audioButtonLabel)
        
        center.y -= size.height * 0.55
        selfDestructButtonLabel = ButtonLabelNode()
        selfDestructButtonLabel.setup(withText: "Explode: ", withFontSize: 40.0, withButtonName: "SelfDestruct", normalTextureName: "selfDestructNormal", highlightedTextureName: "selfDestructHighlighted", atPosition: center)
        self.addChild(selfDestructButtonLabel)
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
}
