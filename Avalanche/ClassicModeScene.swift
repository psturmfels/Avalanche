//
//  ClassicModeScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 10/18/16.
//  Copyright (c) 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class ClassicModeScene: GameScene {
    //MARK: Initializing Methods
    
    override func didMove(to view: SKView) {
        //Create stuff
        createWorld()
        let mellowPoint: CGPoint = CGPoint(x: 30, y: self.size.height * 0.5 - 50.0)
        createMellow(atPoint: mellowPoint)
        createFloor()
        createLava()
        createLabels()
        createBackground()
        createControlButton()
        createPauseNode()
        createBackgroundNotifications()
        startMusic()
    }
}
