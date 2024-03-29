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
    case Stoic = "Stoic"
    case EarthBound = "EarthBound"
    case Smores = "Smores"
    case Singed = "Singed"
    case Pyromaniac = "Pyromaniac"
    case Squashed = "Squashed"
    case Flattened = "Flattened"
    case Pancaked = "Pancaked"
    case BlockHugger = "BlockHugger"
    case Ninja = "Ninja"
    case Jackpot = "Jackpot"
    case AFK = "AFK"
    case TestRun = "TestRun"
    case Interested = "Interested"
    case Dedicated  = "Dedicated"
    case Committed  = "Committed"
    case Student = "Student"
    case ThirtyLives = "30Lives"
    case Gifted = "Gifted"
    case Blessed = "Blessed"
    case Powered = "Powered"
    case Collector = "Collector"
    case Eclectic = "Eclectic"
    case Izanagi = "Izanagi"
    case AntMan = "AntMan"
    case DayBreak = "DayBreak"
    case Jumper = "Jumper"
    case Octane = "Octane"
    case TimeWarp = "TimeWarp"
}

enum Purchase: String {
    case RemoveAds = "RemoveAds"
    static func readableName(ofPurchase type: Purchase) -> String {
        switch type {
        case .RemoveAds:
            return "Remove Ads"
        }
    }
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
    case resetPowerUps = "resetPowerUps"
    case doubleRandom = "doubleRandom"
    case removeAll = "removeAll"
    
    case heart = "heart"
    
    static var positiveTypes: [PowerUpTypes] = [PowerUpTypes.timeSlow, PowerUpTypes.jetPack, PowerUpTypes.shrink, PowerUpTypes.teleport, PowerUpTypes.day]
    static var negativeTypes: [PowerUpTypes] = [PowerUpTypes.mellowSlow, PowerUpTypes.ballAndChain, PowerUpTypes.night, PowerUpTypes.grow, PowerUpTypes.flip]
    static var allTypes: [PowerUpTypes] = [PowerUpTypes.timeSlow, PowerUpTypes.jetPack, PowerUpTypes.shrink, PowerUpTypes.teleport, PowerUpTypes.day, PowerUpTypes.mellowSlow, PowerUpTypes.ballAndChain, PowerUpTypes.night, PowerUpTypes.grow, PowerUpTypes.flip]
    
    static func returnRandomFrom(array: [PowerUpTypes]) -> PowerUpTypes {
        let randomIndex: Int = RandomInt(min: 0, max: array.count - 1)
        return array[randomIndex]
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
            return 10.0
        case .mellowSlow:
            return 5.0
        case .ballAndChain:
            return 4.0
        case .night:
            return 5.0
        case .grow:
            return 7.0
        case .flip:
            return 4.0
        case .resetPowerUps:
            return 0.0
        case .doubleRandom:
            return 0.0
        case .removeAll:
            return 0.0
        case .heart:
            return 0.0
        }
    }
}

enum PowerUpPattern: Double {
    case positive = 0.2
    case heart = 0.22
    case normal = 1.0
    
    static func returnRandomPattern() -> PowerUpPattern {
        let randomIndex: Double = RandomDouble(min: 0.0, max: 1.0)
        if randomIndex <= PowerUpPattern.positive.rawValue {
            return .positive
        } else if randomIndex <= PowerUpPattern.heart.rawValue {
            return .heart
        } else if randomIndex <= PowerUpPattern.normal.rawValue {
            return .normal
        }
        
        return .normal
    }
}

enum DeathTypes {
    case lava
    case crushed
    case selfDestruct
}

enum CollisionTypes: UInt32 {
    case mellow         = 1
    case background     = 2
    case fallingBlock   = 4
    case lava           = 8
    case powerUp        = 16
    case powerUpObject  = 32
    case screenBoundary = 64
    case oneWayDetector = 128
    case oneWayEnabled  = 256
    case oneWayDisabled = 512
    case oneWayPlatformBottom = 1024
    case eventNotifier = 2048
}

enum Orientation {
    case left
    case right
}
