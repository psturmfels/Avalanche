//
//  PauseNode.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class PauseNode: SKNode {
    
    var buttonsButton: ButtonNode!
    var tiltButton: ButtonNode!
    var grayScreen: SKShapeNode!
    var currentGameControls: ControlTypes = ControlTypes.tilt
    
    //MARK: Initialization methods
    func setup(withSize size: CGSize, atPosition position: CGPoint, withControls controls: ControlTypes) {
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
        
        currentGameControls = controls
        
        buttonsButton = ButtonNode(imageNamed: "buttonsButton")
        tiltButton = ButtonNode(imageNamed: "tiltButton")
        
        center.y += size.height * 0.3
        
        buttonsButton.setup(atPosition: center, withName: "Button", normalTextureName: "buttonsButton", highlightedTextureName: "buttonsButton")
        buttonsButton.position.x -= buttonsButton.size.width * 0.5 + 10
        
        tiltButton.setup(atPosition: center, withName: "Tilt", normalTextureName: "tiltButton", highlightedTextureName: "tiltButton")
        tiltButton.position.x += tiltButton.size.width * 0.5 + 10
        
        switch currentGameControls {
        case .tilt:
            buttonsButton.alpha = 0.3
        case .buttons:
            tiltButton.alpha = 0.3
            break
        }
        
        self.addChild(grayScreen)
        self.addChild(buttonsButton)
        self.addChild(tiltButton)
    }
}
