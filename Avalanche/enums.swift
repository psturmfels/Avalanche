//
//  enums.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/25/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

enum Achievement: String {
    case whatDoesThisDo = "whatDoesThisDo"
    case Beginner = "Beginner"
    case Moderate = "Moderate"
    case Advanced = "Advanced"
    case Pro = "Pro"
    case Legendary = "Legendary"
    case Clueless = "Clueless"
}

enum LeaderboardTypes: String {
    case classic = "classicModeLeaderboard"
    case arcade  = "arcadeModeLeaderboard"
}

enum GameType {
    case Classic
    case Arcade
}

enum MenuStates: Int {
    case menu = 1
    case settings = 2
    case scores = 3
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

enum PowerUpTypes: String {
    case timeSlow = "timeSlow"
    case jetPack = "jetPack"
    
    static var allTypes = [PowerUpTypes.timeSlow, PowerUpTypes.jetPack]
    static func returnRandomType() -> PowerUpTypes {
        let randomIndex: Int = RandomInt(min: 0, max: PowerUpTypes.allTypes.count - 1)
        return PowerUpTypes.allTypes[randomIndex]
    }
    
    static func duration(ofType type: PowerUpTypes) -> TimeInterval {
        switch type {
        case .timeSlow:
            return 7.0
        case .jetPack:
            return 4.0
        }
    }
}

enum DeathTypes {
    case lava
    case crushed
    case selfDestruct
}

enum CollisionTypes: UInt32 {
    case mellow = 1
    case background = 2
    case fallingBlock = 4
    case lava = 8
    case powerUp = 16
}

enum Orientation {
    case left
    case right
}
