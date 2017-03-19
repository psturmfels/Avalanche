//
//  ArcadeModeScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/19/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class ArcadeModeScene: GameScene {
    //MARK: Initializing Methods
    
    override func didMove(to view: SKView) {
        //Create stuff
        createWorld()
        createMellow()
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
