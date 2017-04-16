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
    var nextPowerUp: Int = 30
    var currentPowerUps: [PowerUp] = []
    var isJetPacking: Bool = false {
        didSet {
            if isJetPacking {
                guard mellow.childNode(withName: "jetpackTrail") == nil else {
                    return
                }
                let jetpackTrail: SKEmitterNode = SKEmitterNode(fileNamed: "JetpackTrail")!
                jetpackTrail.name = "jetpackTrail"
                jetpackTrail.position.x = 0.0
                jetpackTrail.position.y = -mellow.size.height * 0.52
                jetpackTrail.zPosition = 0
                self.mellow.addChild(jetpackTrail)
            } else {
                if let jetpackTrail = mellow.childNode(withName: "jetpackTrail") {
                    jetpackTrail.removeFromParent()
                }
            }
        }
    }
    
    override func switchedToInProgress() {
        self.controlButton.updateTextureSet(withNormalTextureName: "pauseNormal", highlightedTextureName: "pauseHighlighted")
        
        UserDefaults.standard.set(audioIsOn, forKey: "Audio")
        UserDefaults.standard.set(soundEffectsAreOn, forKey: "SoundEffects")
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
        for powerUpType in PowerUpTypes.allTypes {
            if let action = self.action(forKey: powerUpType.rawValue) {
                action.speed = 1.0
            }
        }
        
        for activePowerUp in self.currentPowerUps {
            if let circleAction = activePowerUp.action(forKey: "PowerUpCountdown") {
                circleAction.speed = 1.0
            }
        }
        
        self.removePauseNode()
        
        self.motionManager.startAccelerometerUpdates()
    }
    
    override func switchedToOver() {
        self.controlButton.didRelease()
        
        //Stop generating blocks/powerups
        self.removeAllActions()
        self.motionManager.stopAccelerometerUpdates()
        self.isJetPacking = false
        
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
        self.isJetPacking = false
        
        self.physicsWorld.speed = 0.0
        if let action = self.action(forKey: "genBlocks") {
            action.speed = 0.0
        }
        
        for powerUpType in PowerUpTypes.allTypes {
            if let action = self.action(forKey: powerUpType.rawValue) {
                action.speed = 0.0
            }
        }
        
        for activePowerUp in self.currentPowerUps {
            if let circleAction = activePowerUp.action(forKey: "PowerUpCountdown") {
                circleAction.speed = 0.0
            }
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
    }
    
    //MARK: Overriden Touch Methods
    override func noButtonsTapped() {
        if self.action(forKey: PowerUpTypes.jetPack.rawValue) != nil {
            self.isJetPacking = true
        } else {
            mellow.jump()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.isJetPacking = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.isJetPacking = false
    }
    
    //MARK: Overriden Update Methods
    override func mellowAccel() {
        //Make the mellow move to the left or right depending on the tilt of the screen
        
        if let data = self.motionManager.accelerometerData {
            mellow.setdx(withAcceleration: data.acceleration.x)
        }
        
        if mellow.bottomSideInContact == 0 && !self.isJetPacking {
            //Add the wall-cling animations if the mellow is touching a wall and is off the ground
            if mellow.leftSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "leftwallcling")
            }
            else if mellow.rightSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "rightwallcling")
            }
        }
    }
    
    override func updateCurrentDifficulty() {
        guard self.action(forKey: PowerUpTypes.timeSlow.rawValue) == nil else {
            return
        }
        
        super.updateCurrentDifficulty()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if current > nextPowerUp {
            self.generateRandomPowerUp()
            nextPowerUp = current + RandomInt(min: 10, max: 20)
        }
        
        guard mellow != nil else {
            return
        }
        guard mellow.physicsBody != nil else {
            return
        }
        
        
        if isJetPacking {
            let forceAction: SKAction = SKAction.applyForce(CGVector(dx: 0, dy: 4500), duration: 0.01)
            self.mellow.run(forceAction)
            if self.mellow.physicsBody!.velocity.dy > 120 {
                self.mellow.physicsBody!.velocity.dy = 120
            }
            if let jetpackTrail = self.mellow.childNode(withName: "jetpackTrail") as? SKEmitterNode {
                let signModifier: CGFloat
                
                if mellow.direction == .left {
                    signModifier = 1.0
                } else {
                    signModifier = -1.0
                }
                
                jetpackTrail.emissionAngle = 1.5 * CGFloat.pi + signModifier * CGFloat(self.mellow.trailingNum) * 0.09
                jetpackTrail.zRotation = signModifier * CGFloat(self.mellow.trailingNum) * 0.09
                let newXPos: CGFloat = signModifier * CGFloat(self.mellow.trailingNum) * 2.5
                if abs(jetpackTrail.position.x - newXPos) > 1.0 {
                    let moveAction: SKAction = SKAction.moveTo(x: newXPos, duration: 0.1)
                    jetpackTrail.run(moveAction)
                }
            }
        }
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
    
    override func didBeginRemainingContact(withBody firstBody: SKPhysicsBody, andBody secondbody: SKPhysicsBody, atPoint contactPoint: CGPoint) {
        if firstBody.categoryBitMask == CollisionTypes.mellow.rawValue && secondbody.categoryBitMask == CollisionTypes.powerUp.rawValue {
            if let powerUpNode = secondbody.node as? PowerUp {
                runPowerUp(type: powerUpNode.type!)
                powerUpNode.removeFromParent()
            }
        }
    }
    
    func addPowerUpIcon(type: PowerUpTypes) {
        let searchIndex: Int? = currentPowerUps.index { (powerUp) -> Bool in
            return powerUp.type == type
        }
        
        if let indexOfType = searchIndex {
            currentPowerUps[indexOfType].updateCountDown()
            if indexOfType != currentPowerUps.count - 1 {
                swap(&currentPowerUps[indexOfType], &currentPowerUps[currentPowerUps.count - 1])
                swap(&currentPowerUps[indexOfType].position, &currentPowerUps[currentPowerUps.count - 1].position)
            }
        } else {
            let defaultPosition: CGPoint = CGPoint(x: -20.0, y: 40.0)
            
            let newIndicator: PowerUp = PowerUp()
            
            newIndicator.indicatorSetup(atPoint: defaultPosition, withType: type, asIndicator: true)
            newIndicator.beginCountdown()
            currentPowerUps.append(newIndicator)
            self.addChild(newIndicator)
            
            for indicator in currentPowerUps {
                indicator.position.x += 60.0
            }
        }
    }
    
    func removePowerUpIcon(type: PowerUpTypes) {
        let searchIndex: Int? = currentPowerUps.index { (powerUp) -> Bool in
            return powerUp.type == type
        }
        guard let indexOfType = searchIndex else {
            return
        }
        
        for i in 0..<indexOfType {
            currentPowerUps[i].position.x -= 60.0
        }
        
        currentPowerUps[indexOfType].removeFromParent()
        currentPowerUps.remove(at: indexOfType)
    }
    
    func runPowerUp(type: PowerUpTypes) {
        addPowerUpIcon(type: type)
        switch type {
        case .timeSlow:
            powerUpTimeSlow()
        case .jetPack:
            addJetPack()
        case .ballAndChain:
            addBallAndChain()
        }
    }
    
    func endPowerUp(type: PowerUpTypes) {
        removePowerUpIcon(type: type)
        switch type {
        case .timeSlow:
            removeTimeSlow()
        case .jetPack:
            removeJetPack()
        case .ballAndChain:
            removeBallAndChain()
        }
        
    }
    
    func addBallAndChain() {
        if self.action(forKey: PowerUpTypes.ballAndChain.rawValue) != nil  {
            self.removeAction(forKey: PowerUpTypes.ballAndChain.rawValue)
        } else {
            let ballAndChain: BallAndChain = BallAndChain()
            ballAndChain.name = "ballAndChain"
            let ballPos: CGPoint = CGPoint(x: mellow.position.x, y: mellow.position.y + 60.0)
            ballAndChain.setup(attachedToNode: mellow, atPoint: ballPos, toParentScene: self)
            self.addChild(ballAndChain)
        }
        
        let wait: SKAction = SKAction.wait(forDuration: PowerUpTypes.duration(ofType: .ballAndChain))
        let removeBallAndChain: SKAction = SKAction.run { [unowned self] in
            self.endPowerUp(type: .ballAndChain)
        }
        let sequence: SKAction = SKAction.sequence([wait, removeBallAndChain])
        self.run(sequence, withKey: PowerUpTypes.ballAndChain.rawValue)
    }
    
    func removeBallAndChain() {
        if let ballAndChain = self.childNode(withName: "ballAndChain") as? BallAndChain {
            ballAndChain.removeFrom(parentScene: self)
        }
    }
    
    func addJetPack() {
        self.removeAction(forKey: PowerUpTypes.jetPack.rawValue)
        let wait: SKAction = SKAction.wait(forDuration: PowerUpTypes.duration(ofType: .jetPack))
        let removeJetPack: SKAction = SKAction.run { [unowned self] in
            self.endPowerUp(type: .jetPack)
        }
        let sequence: SKAction = SKAction.sequence([wait, removeJetPack])
        self.run(sequence, withKey: PowerUpTypes.jetPack.rawValue)
    }
    
    func removeJetPack() {
        self.isJetPacking = false
    }
    
    func powerUpTimeSlow() {
        if self.action(forKey: PowerUpTypes.timeSlow.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.timeSlow.rawValue)
        } else {
            self.backgroundMusic.run(SKAction.changePlaybackRate(to: 0.5, duration: 0.0))
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
        let wait: SKAction = SKAction.wait(forDuration: PowerUpTypes.duration(ofType: .timeSlow))
        let removeSlow = SKAction.run { [unowned self] in
            self.endPowerUp(type: .timeSlow)
        }
        let sequence: SKAction = SKAction.sequence([wait, removeSlow])
        self.run(sequence, withKey: PowerUpTypes.timeSlow.rawValue)
    }
    
    func removeTimeSlow() {
        self.mellow.speed = 1.0
        self.backgroundMusic.run(SKAction.changePlaybackRate(to: 1.0, duration: 0.0))
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
