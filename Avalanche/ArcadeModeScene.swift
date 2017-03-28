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
    
    override func switchedToInProgress() {
        self.controlButton.updateTextureSet(withNormalTextureName: "pauseNormal", highlightedTextureName: "pauseHighlighted")
        
        UserDefaults.standard.set(audioIsOn, forKey: "Audio")
        UserDefaults.standard.set(soundEffectsAreOn, forKey: "Audio")
        if audioIsOn {
            if let musicStart = self.action(forKey: "musicStart") {
                musicStart.speed = 1.0
            } else {
                self.backgroundMusic.run(SKAction.play())
            }
        }
        
        self.physicsWorld.speed = 1.0
        if let action = self.action(forKey: "genBlocks") {
            action.speed = 1.0
        }
        if let action = self.action(forKey: "genPowerUps") {
            action.speed = 1.0
        }
        if let action = self.action(forKey: "powerUpTimeSlow") {
            action.speed = 1.0
        }
        
        self.removePauseNode()
        
        self.motionManager.startAccelerometerUpdates()
    }
    
    override func switchedToOver() {
        self.controlButton.didRelease()
        
        //Stop generating blocks/powerups
        self.removeAllActions()
        self.motionManager.stopAccelerometerUpdates()
        
        //Run the game over functions after a specified duration
        let gameOverAction = SKAction.wait(forDuration: 2.0)
        self.run(gameOverAction, completion: {
            self.transitionToGameOverScene()
        })
    }
    
    override func switchedToPause() {
        if let musicStart = self.action(forKey: "musicStart") {
            musicStart.speed = 0.0
        } else {
            self.backgroundMusic.run(SKAction.pause())
        }
        
        self.controlButton.updateTextureSet(withNormalTextureName: "playNormal", highlightedTextureName: "playHighlighted")
        
        self.motionManager.stopAccelerometerUpdates()
        
        self.physicsWorld.speed = 0.0
        if let action = self.action(forKey: "genBlocks") {
            action.speed = 0.0
        }
        if let action = self.action(forKey: "genPowerUps") {
            action.speed = 0.0
        }
        if let action = self.action(forKey: "powerUpTimeSlow") {
            action.speed = 0.0
        }
        
        self.displayPauseNode()
    }
    
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
        initPowerUps(6, withRange: 3)
    }
    
    //MARK: Overriden Update Methods
    override func updateCurrentDifficulty() {
        guard self.action(forKey: "powerUpTimeSlow") == nil else {
            return
        }
        
        self.removeAction(forKey: "genBlocks")
        self.minFallSpeed = -200.0  - 15.0 * Float(self.currentDifficulty)
        self.maxFallSpeed = self.minFallSpeed + 60.0
        let timeDuration: TimeInterval = 0.9 - 0.05 * Double(self.currentDifficulty)
        let timeRange: TimeInterval = 0.4 - 0.02 * Double(self.currentDifficulty)
        self.initBlocks(timeDuration, withRange: timeRange)
        self.lavaMaxSpeed = 40.0 + 3.0 * CGFloat(self.currentDifficulty)
    }
    
    //MARK: Overriden Return Methods
    override func transitionToGameOverScene() {
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.gameType = GameType.Arcade
        gameOverScene.scaleMode = .resizeFill
        gameOverScene.highScore = bestSoFar
        let transition = SKTransition.crossFade(withDuration: 1.0)
        self.scene!.view!.presentScene(gameOverScene, transition: transition)
    }
    
    //MARK: PowerUp Methods
    func generateRandomPowerUp() {
        let randomXVal: CGFloat = RandomCGFloat(min: 40.0, max: Float(self.size.width) - 40.0)
        let yVal: CGFloat = 100.0 + self.size.height - worldNode.position.y
        let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
        
        let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomType()
        
        let powerUp: PowerUp = PowerUp(imageNamed: "")
        
        powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
        
        worldNode.addChild(powerUp)
    }
    
    func initPowerUps(_ durationBetween: TimeInterval, withRange durationRange: TimeInterval) {
        let createPowerUp: SKAction = SKAction.run { [unowned self] in
            self.generateRandomPowerUp()
        }
        
        let wait: SKAction = SKAction.wait(forDuration: durationBetween, withRange: durationRange)
        let sequence: SKAction = SKAction.sequence([createPowerUp, wait])
        let repeatForever: SKAction = SKAction.repeatForever(sequence)
        
        self.run(repeatForever, withKey: "genPowerUps")
    }
    
    override func didBeginRemainingContact(withBody firstBody: SKPhysicsBody, andBody secondbody: SKPhysicsBody, atPoint contactPoint: CGPoint) {
        if firstBody.categoryBitMask == CollisionTypes.mellow.rawValue && secondbody.categoryBitMask == CollisionTypes.powerUp.rawValue {
            if let powerUpNode = secondbody.node as? PowerUp {
                runPowerUp(type: powerUpNode.type!)
                powerUpNode.removeFromParent()
            }
        }
    }
    
    func runPowerUp(type: PowerUpTypes) {
        switch type {
        case .timeSlow:
            powerUpTimeSlow()
        }
    }
    
    func powerUpTimeSlow() {
        if self.action(forKey: "powerUpTimeSlow") != nil {
            self.removeAction(forKey: "powerUpTimeSlow")
        } else {
            self.mellow.speed = 0.5
            self.removeAction(forKey: "genBlocks")
            self.lavaMaxSpeed = self.lavaMaxSpeed * 0.5
            self.minFallSpeed = self.minFallSpeed * 0.5
            self.maxFallSpeed = self.maxFallSpeed * 0.5
            self.initBlocks(1.5 * (0.9 - Double(self.currentDifficulty) * 0.05), withRange: 0.5)
            
            for node in self.worldNode.children {
                if node.name == "fallingBlock" {
                    if let fallingBlock = node as? RoundedBlockNode {
                        fallingBlock.fallSpeed = fallingBlock.fallSpeed * 0.5
                    }
                }
            }
        }
        let wait: SKAction = SKAction.wait(forDuration: 6.0)
        let removeSlow = SKAction.run { [unowned self] in
            self.removeTimeSlow()
        }
        let sequence: SKAction = SKAction.sequence([wait, removeSlow])
        self.run(sequence, withKey: "powerUpTimeSlow")
    }
    
    func removeTimeSlow() {
        self.mellow.speed = 1.0
        for node in self.worldNode.children {
            if node.name == "fallingBlock" {
                if let fallingBlock = node as? RoundedBlockNode {
                    fallingBlock.fallSpeed = fallingBlock.fallSpeed * 2.0
                }
            }
        }
        self.removeAction(forKey: "genBlocks")
        self.minFallSpeed = -200.0  - 15.0 * Float(self.currentDifficulty)
        self.maxFallSpeed = self.minFallSpeed + 60.0
        let timeDuration: TimeInterval = 0.9 - 0.05 * Double(self.currentDifficulty)
        let timeRange: TimeInterval = 0.4 - 0.02 * Double(self.currentDifficulty)
        self.initBlocks(timeDuration, withRange: timeRange)
        self.lavaMaxSpeed = 40.0 + 3.0 * CGFloat(self.currentDifficulty)
    }
}
