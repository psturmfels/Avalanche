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
                jetpackTrail.position.y = -mellow.size.height * 0.5
                if mellow.xScale > 1.0 {
                    jetpackTrail.position.y += 20.0
                }
                if mellow.xScale < 1.0 {
                    jetpackTrail.position.y -= 5.0
                }
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
        if self.action(forKey: PowerUpTypes.mellowSlow.rawValue) != nil {
            self.physicsWorld.speed = 0.5
        }
        
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
    
    //MARK: Overriden Contact Methods
    override func didBeginRemainingContact(withBody firstBody: SKPhysicsBody, andBody secondbody: SKPhysicsBody, atPoint contactPoint: CGPoint) {
        if firstBody.categoryBitMask == CollisionTypes.mellow.rawValue && secondbody.categoryBitMask == CollisionTypes.powerUp.rawValue {
            if let powerUpNode = secondbody.node as? PowerUp {
                runPowerUp(type: powerUpNode.type!)
                powerUpNode.removeFromParent()
            }
        }
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
        
        guard self.action(forKey: PowerUpTypes.mellowSlow.rawValue) == nil else {
            return
        }
        
        super.updateCurrentDifficulty()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if current > nextPowerUp {
            self.generateRandomPowerUpEvent()
            nextPowerUp = current + RandomInt(min: 40, max: 80)
        }
        
        guard mellow != nil else {
            return
        }
        guard mellow.physicsBody != nil else {
            return
        }
        
        
        if isJetPacking {
            let forceAction: SKAction = SKAction.applyForce(CGVector(dx: 0, dy: 5000), duration: 0.01)
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
    
    //MARK: Mellow Method
    func mellowTeleport() {
        guard mellow.physicsBody != nil else {
            return
        }
        
        let leftEdge: CGFloat = self.mellow.position.x - self.mellow.frame.width * 0.5
        let rightEdge: CGFloat = self.mellow.position.x + self.mellow.frame.width * 0.5
        
        let botEdge: CGFloat = self.mellow.position.y - self.mellow.frame.height * 0.5 + 150.0 - self.worldNode.position.y
        let topEdge: CGFloat = self.mellow.position.y + self.mellow.frame.height * 0.5 + 150.0 - self.worldNode.position.y
        
        var bottomLeft: CGPoint = CGPoint(x: leftEdge, y: botEdge)
        var bottomRight: CGPoint = CGPoint(x: rightEdge, y: botEdge)
        var topLeft: CGPoint = CGPoint(x: leftEdge, y: topEdge)
        var topRight: CGPoint = CGPoint(x: rightEdge, y: topEdge)
        
        while !self.worldNode.nodes(at: bottomLeft).isEmpty && !self.worldNode.nodes(at: bottomRight).isEmpty && !self.worldNode.nodes(at: topRight).isEmpty && !self.worldNode.nodes(at: topLeft).isEmpty {
            bottomLeft.y += 15.0
            bottomRight.y += 15.0
            topLeft.y += 15.0
            topRight.y += 15.0
        }
        
        let mellowX: CGFloat = bottomLeft.x + self.mellow.frame.width * 0.5
        let mellowY: CGFloat = bottomLeft.y + self.mellow.frame.height * 0.5 + self.worldNode.position.y
        let mellowDestination: CGPoint = CGPoint(x: mellowX, y: mellowY)
        mellow.position = mellowDestination
    }
    
    //MARK: PowerUp Methods
    func generateRandomPowerUpEvent() {
        switch PowerUpPattern.returnRandomPattern() {
        case .normalPositive:
            let randomXVal: CGFloat = RandomCGFloat(min: 40.0, max: Float(self.size.width) - 40.0)
            let yVal: CGFloat = 100.0 + self.size.height - worldNode.position.y
            let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
            
            let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomPositive()
            
            let powerUp: PowerUp = PowerUp(imageNamed: "")
            
            powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
            
            worldNode.addChild(powerUp)
            
        case .normalNegative:
            let randomXVal: CGFloat = RandomCGFloat(min: 40.0, max: Float(self.size.width) - 40.0)
            let yVal: CGFloat = 100.0 + self.size.height - worldNode.position.y
            let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
            
            let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomNegative()
            
            let powerUp: PowerUp = PowerUp(imageNamed: "")
            
            powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
            
            worldNode.addChild(powerUp)
            
        case .waveNegative:
            for i in 1...3 {
                let randomXVal: CGFloat = self.frame.width * 0.25 * CGFloat(i) + RandomCGFloat(min: -20.0, max: 20.0)
                let yVal: CGFloat = 100.0 + self.size.height - worldNode.position.y
                let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
                
                let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomNegative()
                
                let powerUp: PowerUp = PowerUp(imageNamed: "")
                
                powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
                
                worldNode.addChild(powerUp)
            }
            
        case .waveRandom:
            for i in 1...4 {
                let randomXVal: CGFloat = self.frame.width * 0.2 * CGFloat(i) + RandomCGFloat(min: -15.0, max: 15.0)
                let yVal: CGFloat = 100.0 + self.size.height - worldNode.position.y
                let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
                
                let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomType()
                
                let powerUp: PowerUp = PowerUp(imageNamed: "")
                
                powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
                
                worldNode.addChild(powerUp)
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
            addTimeSlow()
        case .jetPack:
            addJetPack()
        case .shrink:
            addShrink()
        case .mellowSlow:
            addMellowSlow()
        case .ballAndChain:
            addBallAndChain()
        case .night:
            addNight()
        case .grow:
            addGrow()
        }
    }
    
    func endPowerUp(type: PowerUpTypes) {
        removePowerUpIcon(type: type)
        switch type {
        case .timeSlow:
            removeTimeSlow()
        case .jetPack:
            removeJetPack()
        case .shrink:
            removeShrink()
        case .mellowSlow:
            removeMellowSlow()
        case .ballAndChain:
            removeBallAndChain()
        case .night:
            removeNight()
        case .grow:
            removeGrow()
        }
    }
    
    func addShrink() {
        if self.action(forKey: PowerUpTypes.shrink.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.shrink.rawValue)
        }
        else {
            if mellow.xScale == 1.0 {
                self.mellow.setScale(0.5)
            } else if mellow.xScale == 1.5 {
                self.mellow.setScale(1.0)
            }
        }
        
        self.run(waitSequence(withType: .shrink), withKey: PowerUpTypes.shrink.rawValue)
    }
    
    func removeShrink() {
        if mellow.xScale == 0.5 {
            self.mellow.setScale(1.0)
        } else if mellow.xScale == 1.0 {
            self.mellow.setScale(1.5)
        }
    }
    
    func addGrow() {
        if self.action(forKey: PowerUpTypes.grow.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.grow.rawValue)
        }
        else {
            if mellow.xScale == 1.0 {
                self.mellow.setScale(1.5)
            } else if mellow.xScale == 0.5 {
                self.mellow.setScale(1.0)
            }
            
        }
        
        self.run(waitSequence(withType: .grow), withKey: PowerUpTypes.grow.rawValue)
    }
    
    func removeGrow() {
        if mellow.xScale == 1.5 {
            self.mellow.setScale(1.0)
        } else if mellow.xScale == 1.0 {
            self.mellow.setScale(0.5)
        }
    }
    
    func addNight() {
        if self.action(forKey: PowerUpTypes.night.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.night.rawValue)
        } else {
            let lightNode: SKLightNode = SKLightNode()
            lightNode.name = "lightNode"
            lightNode.ambientColor = UIColor.black
            lightNode.falloff = 0.01
            
            let fadeInLight: SKAction = SKAction.customAction(withDuration: 1.0, actionBlock: { (node, elapsedTime) in
                if let lightNode = node as? SKLightNode {
                    if lightNode.falloff < 1.0 {
                        lightNode.falloff += 0.005
                        print(lightNode.falloff)
                    }
                }
            })
            
            lightNode.run(fadeInLight)
            
            mellow.addChild(lightNode)
        }
        
        self.run(waitSequence(withType: .night), withKey: PowerUpTypes.night.rawValue)
    }
    
    func removeNight() {
        if let lightNode = mellow.childNode(withName: "lightNode") {
            let fadeOutLight: SKAction = SKAction.customAction(withDuration: 1.0, actionBlock: { (node, elapsedTime) in
                if let lightNode = node as? SKLightNode {
                    if lightNode.falloff > 0.01 {
                        lightNode.falloff -= 0.005
                        print(lightNode.falloff)
                    }
                }
            })
            lightNode.run(fadeOutLight) {
                lightNode.removeFromParent()
            }
        }
    }
    
    func addMellowSlow() {
        if self.action(forKey: PowerUpTypes.mellowSlow.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.mellowSlow.rawValue)
        } else {
            self.removeAction(forKey: "genBlocks")
            self.physicsWorld.speed = 0.5
            self.lavaMaxSpeed = self.lavaMaxSpeed * 2.0
            self.minFallSpeed = self.minFallSpeed * 2.0
            self.maxFallSpeed = self.maxFallSpeed * 2.0
            
            let timeDuration: TimeInterval = 0.75 - 0.04 * Double(self.currentDifficulty)
            let timeRange: TimeInterval = 0.4 - 0.02 * Double(self.currentDifficulty)
            self.initBlocks(timeDuration, withRange: timeRange)
            
            for node in self.worldNode.children {
                if node.name == "fallingBlock" {
                    if let fallingBlock = node as? RoundedBlockNode {
                        fallingBlock.fallSpeed = fallingBlock.fallSpeed * 2.0
                    }
                }
            }
        }
        self.run(waitSequence(withType: .mellowSlow), withKey: PowerUpTypes.mellowSlow.rawValue)
    }
    
    func removeMellowSlow() {
        self.physicsWorld.speed = 1.0
        for node in self.worldNode.children {
            if node.name == "fallingBlock" {
                if let fallingBlock = node as? RoundedBlockNode {
                    fallingBlock.fallSpeed = fallingBlock.fallSpeed * 0.5
                }
            }
        }
        super.updateCurrentDifficulty()
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
            self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
            self.physicsBody!.categoryBitMask = CollisionTypes.screenBoundary.rawValue
            self.physicsBody!.collisionBitMask = CollisionTypes.mellow.rawValue | CollisionTypes.powerUpObject.rawValue
            self.physicsBody!.contactTestBitMask = 0
        }
        self.run(waitSequence(withType: .ballAndChain), withKey: PowerUpTypes.ballAndChain.rawValue)
    }
    
    func removeBallAndChain() {
        if let ballAndChain = self.childNode(withName: "ballAndChain") as? BallAndChain {
            ballAndChain.removeFrom(parentScene: self)
        }
        self.physicsBody = nil
    }
    
    func addJetPack() {
        self.removeAction(forKey: PowerUpTypes.jetPack.rawValue)
        self.run(waitSequence(withType: .jetPack), withKey: PowerUpTypes.jetPack.rawValue)
    }
    
    func removeJetPack() {
        self.isJetPacking = false
    }
    
    func addTimeSlow() {
        if self.action(forKey: PowerUpTypes.timeSlow.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.timeSlow.rawValue)
        } else {
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
        self.run(waitSequence(withType: .timeSlow), withKey: PowerUpTypes.timeSlow.rawValue)
    }
    
    func removeTimeSlow() {
        for node in self.worldNode.children {
            if node.name == "fallingBlock" {
                if let fallingBlock = node as? RoundedBlockNode {
                    fallingBlock.fallSpeed = fallingBlock.fallSpeed * 2.0
                }
            }
        }
        super.updateCurrentDifficulty()
    }
    
    func waitSequence(withType type: PowerUpTypes) -> SKAction {
        let wait: SKAction = SKAction.wait(forDuration: PowerUpTypes.duration(ofType: type))
        let removeType = SKAction.run { [unowned self] in
            self.endPowerUp(type: type)
        }
        let sequence: SKAction = SKAction.sequence([wait, removeType])
        return sequence
    }
}
