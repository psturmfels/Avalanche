//
//  ButtonNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class ButtonNode: SKSpriteNode {
    var isPressed: Bool = false
    var pressedTexture: SKTexture!
    var relaxedTexture: SKTexture!
    
    func setup(atPosition position: CGPoint, withName name: String, normalTextureName: String, highlightedTextureName: String) {
        self.texture = SKTexture(imageNamed: normalTextureName)
        
        self.position = position;
        self.zPosition = 40
        self.name = name
        
        self.pressedTexture = SKTexture(imageNamed: highlightedTextureName)
        self.relaxedTexture = SKTexture(imageNamed: normalTextureName)
    }
    
    func didPress() {
        if !isPressed {
            isPressed = true
            self.texture = pressedTexture
        }
    }
    
    func didRelease(didActivate: Bool = false) {
        if isPressed {
            isPressed = false
            self.texture = relaxedTexture
        }
        let soundEffectsAreOn: Bool = UserDefaults.standard.bool(forKey: "SoundEffects")
        if soundEffectsAreOn && didActivate {
            self.run(SKAction.playSoundFileNamed("ButtonClick.wav", waitForCompletion: false))
        }
    }
    
    func updateTextureSet(withNormalTextureName normalTextureName: String, highlightedTextureName: String) {
        if isPressed {
            self.texture = SKTexture(imageNamed: highlightedTextureName)
        } else {
            self.texture = SKTexture(imageNamed: normalTextureName)
        }
        
        self.pressedTexture = SKTexture(imageNamed: highlightedTextureName)
        self.relaxedTexture = SKTexture(imageNamed: normalTextureName)
    }
}
