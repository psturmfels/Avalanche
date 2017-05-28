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
    var teleportTextures: [SKTexture] = []
    var canTeleport: Bool = false
    var isFlipped: Bool = false
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
        let mellowPoint: CGPoint = CGPoint(x: 30, y: self.size.height * 0.5 - 50.0)
        createMellow(atPoint: mellowPoint)
        createFloor()
        createLava()
        createLabels()
        createBackground()
        createControlButton()
        createPauseNode()
        createBackgroundNotifications()
        startMusic()
        generateRandomPowerUpEvent(atPoint: self.frame.size.height * 0.7)
    }
    
    //MARK: Overriden Touch Methods
    override func noButtonsTapped() {
        if self.action(forKey: PowerUpTypes.jetPack.rawValue) != nil {
            if canTeleport {
                mellowTeleport()
            }
            self.isJetPacking = true
        } else if canTeleport {
            mellowTeleport()
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
            if isFlipped {
                mellow.setdx(withAcceleration: -data.acceleration.x)
            } else {
                mellow.setdx(withAcceleration: data.acceleration.x)
            }
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
            self.generateRandomPowerUpEvent(atPoint: 100.0 + self.size.height)
            nextPowerUp = current + RandomInt(min: 20, max: 60)
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
        
        let touchingGround: Bool = mellow.bottomSideInContact > 0 && mellow.physicsBody!.velocity.dy < 10
        let touchingLeft: Bool = mellow.leftSideInContact > 0 && abs(mellow.physicsBody!.velocity.dx) < 10
        let touchingRight: Bool = mellow.rightSideInContact > 0 && abs(mellow.physicsBody!.velocity.dx) < 10
        let shouldTeleport: Bool = touchingGround || touchingLeft || touchingRight

        guard shouldTeleport else {
            return
        }
        
        mellow.bottomSideInContact = 0
        mellow.rightSideInContact = 0
        mellow.leftSideInContact = 0
        
        mellow.physicsBody!.categoryBitMask = 0
        mellow.physicsBody!.collisionBitMask = 0
        mellow.physicsBody!.contactTestBitMask = 0
        let leftEdge: CGFloat = self.mellow.position.x - self.mellow.frame.width * 0.5
        let rightEdge: CGFloat = self.mellow.position.x + self.mellow.frame.width * 0.5
        
        let botEdge: CGFloat = self.mellow.position.y - self.mellow.frame.height * 0.5 + 175.0 - self.worldNode.position.y
        let topEdge: CGFloat = self.mellow.position.y + self.mellow.frame.height * 0.5 + 175.0 - self.worldNode.position.y
        
        var bottomLeft: CGPoint = CGPoint(x: leftEdge, y: botEdge)
        var bottomRight: CGPoint = CGPoint(x: rightEdge, y: botEdge)
        var topLeft: CGPoint = CGPoint(x: leftEdge, y: topEdge)
        var topRight: CGPoint = CGPoint(x: rightEdge, y: topEdge)
        
        while !self.worldNode.nodes(at: bottomLeft).isEmpty || !self.worldNode.nodes(at: bottomRight).isEmpty || !self.worldNode.nodes(at: topRight).isEmpty || !self.worldNode.nodes(at: topLeft).isEmpty {
            bottomLeft.y += 10.0
            bottomRight.y += 10.0
            topLeft.y += 10.0
            topRight.y += 10.0
            mellow.bottomSideInContact = 1
        }
        
        let targetX: CGFloat = bottomLeft.x + self.mellow.frame.width * 0.5 + 0.2 * self.mellow.physicsBody!.velocity.dx
        let mellowX: CGFloat = min(self.frame.width - 32.0, max(targetX, 32.0))
        let mellowY: CGFloat = bottomLeft.y + self.mellow.frame.height * 0.5 + self.worldNode.position.y
        let mellowDestination: CGPoint = CGPoint(x: mellowX, y: mellowY)
        
        let teleportUpAnimation: SKAction = SKAction.animate(with: teleportTextures, timePerFrame: 0.02, resize: true, restore: true)
        let restorePhysics: SKAction = SKAction.run { 
            self.mellow.physicsBody!.categoryBitMask = CollisionTypes.mellow.rawValue
            self.mellow.physicsBody!.collisionBitMask = CollisionTypes.background.rawValue | CollisionTypes.fallingBlock.rawValue | CollisionTypes.edgeBody.rawValue | CollisionTypes.screenBoundary.rawValue
            self.mellow.physicsBody!.contactTestBitMask = CollisionTypes.background.rawValue | CollisionTypes.fallingBlock.rawValue
        }
        let moveAnimation: SKAction = SKAction.move(to: mellowDestination, duration: 0.0)
        let teleportDownAnimation: SKAction = SKAction.animate(with: teleportTextures.reversed(), timePerFrame: 0.02, resize: true, restore: true)
        let restoreNormalTexture: SKAction = SKAction.setTexture(mellow.standingTexture, resize: true)
        let sequence: SKAction = SKAction.sequence([teleportUpAnimation, restorePhysics, moveAnimation, teleportDownAnimation, restoreNormalTexture])
        
        let adjustAmount: CGVector = CGVector(dx: 0.0, dy: 50.0)
        let mellowAdjust: SKAction = SKAction.move(by: adjustAmount, duration: 0.06)
        mellow.run(mellowAdjust, withKey: "teleportAdjust")
        mellow.run(sequence, withKey: "teleport")
    }
    
    //MARK: Destroy Methods
    func respawn() {
        let respawnY: CGFloat = self.currentHighestPoint.y + 100.0
        let respawnX: CGFloat = self.currentHighestPoint.x
        let respawnPoint: CGPoint = CGPoint(x: respawnX, y: respawnY)
        
        createMellow(atPoint: respawnPoint)
        createExplosion(atPoint: respawnPoint, withScale: 1.0, withName: "MellowCrushed")
    }
    
    //MARK: PowerUp Methods
    func generateRandomPowerUpEvent(atPoint generatePointY: CGFloat) {
        switch PowerUpPattern.returnRandomPattern() {
        case .normalPositive:
            let randomXVal: CGFloat = RandomCGFloat(min: 40.0, max: Float(self.size.width) - 40.0)
            let yVal: CGFloat = generatePointY - worldNode.position.y
            let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
            
            let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomPositive()
            
            let powerUp: PowerUp = PowerUp(imageNamed: "")
            
            powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
            
            worldNode.addChild(powerUp)
            
        case .normalNegative:
            let randomXVal: CGFloat = RandomCGFloat(min: 40.0, max: Float(self.size.width) - 40.0)
            let yVal: CGFloat = generatePointY - worldNode.position.y
            let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
            
            let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomNegative()
            
            let powerUp: PowerUp = PowerUp(imageNamed: "")
            
            powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
            
            worldNode.addChild(powerUp)
            
        case .waveNegative:
            for i in 1...3 {
                let randomXVal: CGFloat = self.frame.width * 0.25 * CGFloat(i) + RandomCGFloat(min: -20.0, max: 20.0)
                let yVal: CGFloat = generatePointY - worldNode.position.y + RandomCGFloat(min: -150.0, max: 150.0)
                let setupPoint: CGPoint = CGPoint(x: randomXVal, y: yVal)
                
                let randomPowerUpType: PowerUpTypes = PowerUpTypes.returnRandomNegative()
                
                let powerUp: PowerUp = PowerUp(imageNamed: "")
                
                powerUp.setup(atPoint: setupPoint, withType: randomPowerUpType)
                
                worldNode.addChild(powerUp)
            }
            
        case .waveRandom:
            for i in 1...4 {
                let randomXVal: CGFloat = self.frame.width * 0.2 * CGFloat(i) + RandomCGFloat(min: -15.0, max: 15.0)
                let yVal: CGFloat = generatePointY - worldNode.position.y + RandomCGFloat(min: -150.0, max: 150.0)
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
        case .teleport:
            addTeleport()
        case .mellowSlow:
            addMellowSlow()
        case .ballAndChain:
            addBallAndChain()
        case .night:
            addNight()
        case .grow:
            addGrow()
        case .flip:
            addFlip()
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
        case .teleport():
            removeTeleport()
        case .mellowSlow:
            removeMellowSlow()
        case .ballAndChain:
            removeBallAndChain()
        case .night:
            removeNight()
        case .grow:
            removeGrow()
        case .flip:
            removeFlip()
        }
    }
    
    func addFlip() {
        if self.action(forKey: PowerUpTypes.flip.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.flip.rawValue)
        } else {
            self.isFlipped = true
        }
        self.run(waitSequence(withType: .flip), withKey: PowerUpTypes.flip.rawValue)
    }
    
    func removeFlip() {
        self.isFlipped = false
    }
    
    func addTeleport() {
        if teleportTextures.isEmpty {
            for i in 1...6 {
                teleportTextures.append(SKTexture(imageNamed: "teleport\(i)"))
            }
        }
        
        if self.action(forKey: PowerUpTypes.teleport.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.teleport.rawValue)
        } else {
            self.canTeleport = true
        }
        self.run(waitSequence(withType: .teleport), withKey: PowerUpTypes.teleport.rawValue)
    }
    
    func removeTeleport() {
        self.canTeleport = false
    }
    
    func addShrink() {
        if self.action(forKey: PowerUpTypes.shrink.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.shrink.rawValue)
        }
        else {
            if mellow.xScale == 1.0 {
                self.mellow.run(SKAction.scale(to: 0.5, duration: 0.25))
            } else if mellow.xScale > 1.0 {
                self.mellow.run(SKAction.scale(to: 1.0, duration: 0.25))
            }
        }
        
        self.run(waitSequence(withType: .shrink), withKey: PowerUpTypes.shrink.rawValue)
    }
    
    func removeShrink() {
        if mellow.xScale < 1.0 {
            self.mellow.run(SKAction.scale(to: 1.0, duration: 0.25))
        } else if mellow.xScale == 1.0 {
            self.mellow.run(SKAction.scale(to: 1.5, duration: 0.25))
        }
    }
    
    func addGrow() {
        if self.action(forKey: PowerUpTypes.grow.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.grow.rawValue)
        }
        else {
            if mellow.xScale == 1.0 {
                self.mellow.run(SKAction.scale(to: 1.5, duration: 0.25))
            } else if mellow.xScale < 1.0 {
                self.mellow.run(SKAction.scale(to: 1.0, duration: 0.25))
            }
            
        }
        
        self.run(waitSequence(withType: .grow), withKey: PowerUpTypes.grow.rawValue)
    }
    
    func removeGrow() {
        if mellow.xScale > 1.0 {
            self.mellow.run(SKAction.scale(to: 1.0, duration: 0.25))
        } else if mellow.xScale == 1.0 {
            self.mellow.run(SKAction.scale(to: 0.5, duration: 0.25))
        }
    }
    
    func addNight() {
        if self.action(forKey: PowerUpTypes.night.rawValue) != nil {
            self.removeAction(forKey: PowerUpTypes.night.rawValue)
        } else {
            let lightNode: SKLightNode = SKLightNode()
            lightNode.name = "lightNode"
            lightNode.ambientColor = UIColor.white
            
            let fadeDuration: TimeInterval = 1.0
            
            let fadeInLight: SKAction = SKAction.customAction(withDuration: fadeDuration, actionBlock: { (node, elapsedTime) in
                if let lightNode = node as? SKLightNode {
                    let newGrayScale: CGFloat = 1 - elapsedTime / CGFloat(fadeDuration)
                    lightNode.ambientColor = UIColor(white: newGrayScale, alpha: 1.0)
                }
            })
            
            lightNode.run(fadeInLight)
            
            mellow.addChild(lightNode)
        }
        
        self.run(waitSequence(withType: .night), withKey: PowerUpTypes.night.rawValue)
    }
    
    func removeNight() {
        if let lightNode = mellow.childNode(withName: "lightNode") {
            lightNode.name = nil
            
            let fadeDuration: TimeInterval = 0.5
            
            let fadeOutLight: SKAction = SKAction.customAction(withDuration: fadeDuration, actionBlock: { (node, elapsedTime) in
                if let lightNode = node as? SKLightNode {
                    let newGrayScale: CGFloat = elapsedTime / CGFloat(fadeDuration)
                    lightNode.ambientColor = UIColor(white: newGrayScale, alpha: 1.0)
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
        self.run(SKAction.run { [unowned self] in
            self.physicsWorld.speed = 1.0
            for node in self.worldNode.children {
                if node.name == "fallingBlock" {
                    if let fallingBlock = node as? RoundedBlockNode {
                        fallingBlock.fallSpeed = fallingBlock.fallSpeed * 0.5
                    }
                }
            }
        }) { [unowned self] in
            self.superUpdateCurrentDifficulty()
        }
    }
    
    func superUpdateCurrentDifficulty() {
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
        self.run(SKAction.run { [unowned self] in
            for node in self.worldNode.children {
                if node.name == "fallingBlock" {
                    if let fallingBlock = node as? RoundedBlockNode {
                        fallingBlock.fallSpeed = fallingBlock.fallSpeed * 2.0
                    }
                }
            }
        }) { 
            [unowned self] in
            self.superUpdateCurrentDifficulty()
        }
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
