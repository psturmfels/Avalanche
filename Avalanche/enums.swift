//
//  enums.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/25/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

enum LeaderBoardTypes: Int {
    case classic = 1
}

enum GameStates: Int {
    case gameInProgress = 1
    case gameOver = 2
    case gamePaused = 3
    case tutorial = 4
}

enum ButtonStates {
    case empty
    case replayTapped
    case menuTapped
    case controlTapped
}

enum DeathTypes {
    case lava
    case crushed
}

enum CollisionTypes: UInt32 {
    case mellow = 1
    case background = 2
    case fallingBlock = 4
    case lava = 8
}

enum Orientation {
    case left
    case right
}
