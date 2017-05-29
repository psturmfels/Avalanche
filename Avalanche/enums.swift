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
    case shrink = "shrink"
    case teleport = "teleport"
    case day = "day"
    case mellowSlow = "mellowSlow"
    case ballAndChain = "ballAndChain"
    case night = "night"
    case grow = "grow"
    case flip = "flip"
    
    static let positiveTypes: [PowerUpTypes] = [PowerUpTypes.timeSlow, PowerUpTypes.jetPack, PowerUpTypes.shrink, PowerUpTypes.teleport, PowerUpTypes.day]
    static let negativeTypes: [PowerUpTypes] = [PowerUpTypes.mellowSlow, PowerUpTypes.ballAndChain, PowerUpTypes.night, PowerUpTypes.grow, PowerUpTypes.flip]
    static let allTypes: [PowerUpTypes] = [PowerUpTypes.timeSlow, PowerUpTypes.jetPack, PowerUpTypes.shrink, PowerUpTypes.teleport, PowerUpTypes.day, PowerUpTypes.mellowSlow, PowerUpTypes.ballAndChain, PowerUpTypes.night, PowerUpTypes.grow, PowerUpTypes.flip]
    
    static func returnRandomPositive() -> PowerUpTypes {
        let randomIndex: Int = RandomInt(min: 0, max: PowerUpTypes.positiveTypes.count - 1)
        return PowerUpTypes.positiveTypes[randomIndex]
    }
    
    static func returnRandomNegative() -> PowerUpTypes {
        let randomIndex: Int = RandomInt(min: 0, max: PowerUpTypes.negativeTypes.count - 1)
        return PowerUpTypes.negativeTypes[randomIndex]
    }
    
    static func returnRandomType() -> PowerUpTypes {
        let randomIndex: Int = RandomInt(min: 0, max: PowerUpTypes.allTypes.count - 1)
        return PowerUpTypes.allTypes[randomIndex]
    }
    
    static func duration(ofType type: PowerUpTypes) -> TimeInterval {
        switch type {
        case .timeSlow:
            return 7.0
        case .jetPack:
            return 5.0
        case .shrink:
            return 7.0
        case .teleport:
            return 7.0
        case .day:
            return 6.0
        case .mellowSlow:
            return 5.0
        case .ballAndChain:
            return 4.0
        case .night:
            return 6.0
        case .grow:
            return 6.0
        case .flip:
            return 5.0
        }
    }
}

enum PowerUpPattern: Double {
    case normalPositive = 0.4
    case normalNegative = 0.6
    case waveNegative = 0.8
    case waveRandom = 1.0
    
    static func returnRandomPattern() -> PowerUpPattern {
        let randomIndex: Double = RandomDouble(min: 0.0, max: 1.0)
        if randomIndex <= PowerUpPattern.normalPositive.rawValue {
            return PowerUpPattern.normalPositive
        } else if randomIndex <= PowerUpPattern.normalNegative.rawValue {
            return PowerUpPattern.normalNegative
        } else if randomIndex <= PowerUpPattern.waveNegative.rawValue {
            return PowerUpPattern.waveNegative
        } else {
            return PowerUpPattern.waveRandom
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
    case powerUpObject = 32
    case edgeBody = 64
    case screenBoundary = 128
}

enum Orientation {
    case left
    case right
}
