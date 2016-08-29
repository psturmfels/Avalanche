//
//  enums.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/25/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

enum GameStates: Int {
    case GameInProgress = 1
    case GameOver = 2
    case GamePaused = 3
}

enum ButtonStates {
    case Empty
    case ReplayTapped
    case MenuTapped
    case ControlTapped
}

enum DeathTypes {
    case Lava
    case Crushed
}

enum CollisionTypes: UInt32 {
    case Mellow = 1
    case Background = 2
    case FallingBlock = 4
    case Lava = 8
}

enum Orientation {
    case left
    case right
}