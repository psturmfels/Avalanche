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
        /* Setup your scene here */
        
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
