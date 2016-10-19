//
//  GameScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/21/16.
//  Copyright (c) 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: Game Nodes
    var worldNode: SKNode!
    let motionManager: CMMotionManager = CMMotionManager()
    
    var mellow: MellowNode!
    var floor: RoundedBlockNode!
    var risingLava: SKSpriteNode!
    
    var pauseScreen: PauseNode!
    var controlButton: ButtonNode!
    
    var bestLabel: SKLabelNode!
    var currentLabel: SKLabelNode!
    
    //MARK: Game Properties
    var bestSoFar: Int = 0 {
        didSet {
            bestLabel.text = "\(bestSoFar) ft"
        }
    }
    var current: Int = 0 {
        didSet {
            currentLabel.text = "\(current) ft"
        }
    }
    
    var shouldContinueSpawning: Bool = true
    var currentGameState: GameStates = GameStates.gameInProgress {
        didSet {
            switch currentGameState {
            case .gameInProgress:
                self.controlButton.updateTextureSet(withNormalTextureName: "pauseNormal", highlightedTextureName: "pauseHighlighted")
                
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
                self.removePauseNode()
                
                self.motionManager.startAccelerometerUpdates()
                
            case .gameOver:
                self.controlButton.didRelease()
                
                //Stop generating blocks
                self.removeAction(forKey: "genBlocks")
                self.motionManager.stopAccelerometerUpdates()
                
                //Run the game over functions after a specified duration
                let gameOverAction = SKAction.wait(forDuration: 4.0)
                self.run(gameOverAction, completion: {
                    self.transitionToGameOverScene()
                })
                
                
            case .gamePaused:
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
                
                self.displayPauseNode()
                
            case .tutorial:
                break
            }
        }
    }
    
    var currentDifficulty: Int = -1 {
        didSet {
            self.removeAction(forKey: "genBlocks")
            switch currentDifficulty {
            case 0:
                self.initBlocks(0.8, withRange: 0.4, minFallSpeed: -250, maxFallSpeed: -170)
                lavaMaxSpeed = 43.0
            case 1:
                self.initBlocks(0.7, withRange: 0.4, minFallSpeed: -260, maxFallSpeed: -180)
                lavaMaxSpeed = 47.0
            case 2:
                self.initBlocks(0.6, withRange: 0.4, minFallSpeed: -270, maxFallSpeed: -190)
                lavaMaxSpeed = 50.0
            case 3:
                self.initBlocks(0.5, withRange: 0.4, minFallSpeed: -280, maxFallSpeed: -210)
                lavaMaxSpeed = 53.0
            case 4:
                self.initBlocks(0.5, withRange: 0.4, minFallSpeed: -290, maxFallSpeed: -220)
                lavaMaxSpeed = 56.0
            case 5:
                self.initBlocks(0.4, withRange: 0.3, minFallSpeed: -310, maxFallSpeed: -240)
                lavaMaxSpeed = 59.0
            default:
                break;
            }
        }
    }
    
    var lavaMaxSpeed: CGFloat = 40.0
    
    var soundEffectsAreOn: Bool = !AVAudioSession.sharedInstance().isOtherAudioPlaying
    var audioIsOn: Bool = !AVAudioSession.sharedInstance().isOtherAudioPlaying
    var backgroundMusic: SKAudioNode!
    var backgroundGradient: SKSpriteNode!
    
    //MARK: Game Termination Methods, Pause Methods
    func transitionToGameOverScene() {
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.scaleMode = .resizeFill
        gameOverScene.highScore = bestSoFar
        let transition = SKTransition.crossFade(withDuration: 1.0)
        self.scene!.view!.presentScene(gameOverScene, transition: transition)
    }
    
    func gameWillEnterBackground() {
        if let musicStart = self.action(forKey: "musicStart") {
            musicStart.speed = 0.0
        } else {
            self.backgroundMusic.run(SKAction.pause())
        }
        if self.currentGameState == .gameInProgress {
            self.currentGameState = .gamePaused
        }
    }
    
    func gameDidEnterForeground() {
        //self.currentGameState = .gameInProgress
    }
    
    //MARK: Block Methods
    func turnToBackground(_ block: RoundedBlockNode) {
        block.becomeBackground()
    }
    
    func generateRandomBlock(_ minFallSpeed: Float, maxFallSpeed: Float) {
        //Choose random paramters for the block
        let randomXVal: CGFloat = CGFloat(RandomDouble(min: 0.0, max: Double(self.size.width)))
        let randomColor: Int = RandomInt(min: 1, max: 8)
        let roundedBlock: RoundedBlockNode = RoundedBlockNode(imageNamed: "RoundedBlock\(randomColor)")
        
        //Set the physics and scale of the block
        roundedBlock.setup(minFallSpeed, maxFallSpeed: maxFallSpeed)
        
        //Set the block's position
        roundedBlock.position.x = randomXVal
        roundedBlock.position.y = 2.0 * self.size.height - worldNode.position.y
        
        worldNode.addChild(roundedBlock)
    }
    
    func initBlocks(_ sec: TimeInterval, withRange durationRange: TimeInterval, minFallSpeed: Float, maxFallSpeed: Float) {
        let createBlock: SKAction = SKAction.run { [unowned self] in
            self.generateRandomBlock(minFallSpeed, maxFallSpeed: maxFallSpeed)
        }
        
        let wait: SKAction = SKAction.wait(forDuration: sec, withRange: durationRange)
        let sequence: SKAction = SKAction.sequence([createBlock, wait])
        let repeatForever: SKAction = SKAction.repeatForever(sequence)
        run(repeatForever, withKey: "genBlocks")
    }
    
    //MARK: Settings Methods
    func createPauseNode() {
        pauseScreen = PauseNode()
        pauseScreen.setup(withSize: self.size, atPosition: CGPoint(x: self.frame.midX, y: self.frame.midY))
    }
    
    func displayPauseNode() {
        self.addChild(pauseScreen)
    }
    
    func removePauseNode() {
        pauseScreen.removeFromParent()
    }
    
    //MARK: Audio Methods
    func playSoundEffectNamed(_ name: String, waitForCompletion wait: Bool) {
        if soundEffectsAreOn {
            self.run(SKAction.playSoundFileNamed(name, waitForCompletion: wait))
        }
    }
    
    
    //MARK: Update Methods
    override func update(_ currentTime: TimeInterval) {
        guard mellow != nil else {
            return
        }
        guard mellow.physicsBody != nil else {
            return
        }
        
        //I used to have a problem where the user could "double jump" occasionally.
        //Although I think I've fixed the problem elsewhere,
        //this ensures that double jumping is not really a possibility
        if mellow.physicsBody!.velocity.dy > 700 {
            mellow.physicsBody!.velocity.dy *= 0.9
        }
        
        mellowAccel()
        mellowContain()
        
        guard currentGameState != .tutorial else {
            return
        }
        
        updateDistance()
        
        guard risingLava != nil else {
            return
        }
        setLavaSpeed()
    }
    
    
    func updateDistance() {
        //Continually update the best and the current distance
        let mellowBot: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.5
        let distance: CGFloat = mellowBot - worldNode.position.y
        current = Int(distance / 10.0) - 11
        if current > bestSoFar {
            bestSoFar = current
            
            //Update the tint of the background
            var newBlendFactor: CGFloat = CGFloat(min(bestSoFar, 1250))
            newBlendFactor = newBlendFactor / 2500.0
            
            backgroundGradient.colorBlendFactor = newBlendFactor
            
            let nextDifficulty = min(bestSoFar / 200, 5)
            if nextDifficulty > currentDifficulty {
                currentDifficulty = nextDifficulty
            }
        }
    }
    
    func setLavaSpeed() {
        //The lava's rising speed is an arbitrary function of its distance to the mellow
        if risingLava.physicsBody != nil {
            let lavaYPos: CGFloat = worldNode.position.y + risingLava.position.y
            let lavaYTop: CGFloat = lavaYPos + risingLava.frame.height * 0.5
            let distanceToLava: CGFloat = mellow.position.y - lavaYTop
            let newLavaRisingSpeed: CGFloat = lavaMaxSpeed - (lavaMaxSpeed - 5) * pow(3.14159, -0.003 * distanceToLava)
            risingLava.physicsBody!.velocity.dy = newLavaRisingSpeed
        }
    }
    
    func mellowContain() {
        //Make the mellow "wrap-around" the screen
        //if it goes off the horizontal edges
        let mellowTwoThirds: CGFloat = (2.0 / 3.0) * mellow.frame.width
        let mellowTwiceHeight: CGFloat = 2 * mellow.frame.height
        let mellowThriceHeight: CGFloat = 3 * mellow.frame.height
        
        if mellow.position.x < -mellow.frame.width / 3 {
            mellow.position.x += self.size.width + mellowTwoThirds
        }
        else if mellow.position.x > self.size.width + mellow.frame.width / 3 {
            mellow.position.x -= self.size.width + mellowTwoThirds
        }
        
        //If the mellow gets too close to the top or bottom of the screen,
        //move the world as opposed to the mellow, ensuring that
        //the mellow always stays on the screen.
        if mellow.position.y > self.size.height - mellowThriceHeight {
            let difference: CGFloat = mellow.position.y - (self.size.height - mellowThriceHeight)
            mellow.position.y = self.size.height - mellowThriceHeight
            self.worldNode.position.y -= difference
        }
        else if mellow.position.y < mellowTwiceHeight {
            let difference: CGFloat = mellowTwiceHeight - mellow.position.y
            mellow.position.y = mellowTwiceHeight
            self.worldNode.position.y += difference
        }
    }
    
    func mellowAccel() {
        //Make the mellow move to the left or right depending on the tilt of the screen
        
        if let data = self.motionManager.accelerometerData {
            mellow.setdx(withAcceleration: data.acceleration.x)
        }
        
        if mellow.bottomSideInContact == 0 {
            //Add the wall-cling animations if the mellow is touching a wall and is off the ground
            if mellow.leftSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "leftwallcling")
            }
            else if mellow.rightSideInContact > 0 {
                mellow.texture = SKTexture(imageNamed: "rightwallcling")
            }
        }
    }
    
    //MARK: Initializing Methods
    override func didMove(to view: SKView) {
        /* Setup your scene here */
    }
    
    func createWorld() {
        //Allows the game to read the tilt of the phone and react accordingly
        motionManager.startAccelerometerUpdates()
        
        //Let this object receive contact notifications
        physicsWorld.contactDelegate = self
        
        //Create a "world node" that everything but the mellow belongs to.
        //Used to make it seem like the mellow is moving
        //when the mellow gets close to the top or bottom of the screen.
        worldNode = SKNode()
        worldNode.position = self.position
        self.addChild(worldNode)
    }
    
    func startMusic() {
        //Start the music!!!
        let waitAction: SKAction = SKAction.wait(forDuration: 0.5)
        let musicAction: SKAction = SKAction.run {
            let bgcopy = SKAudioNode(fileNamed: "DreamsOfAbove.mp3")
            self.addChild(bgcopy)
            self.backgroundMusic = bgcopy
        }
        let sequence: SKAction = SKAction.sequence([waitAction, musicAction])
        
        
        if !audioIsOn {
            sequence.speed = 0.0
            pauseScreen.toggleButton(pauseScreen.audioButtonLabel.buttonNode)
        }
        
        if !soundEffectsAreOn {
            pauseScreen.toggleButton(pauseScreen.soundEffectsButtonLabel.buttonNode)
        }
        
        self.run(sequence, withKey: "musicStart")
        scrollMusicLabel()
    }
    
    func scrollMusicLabel() {
        let musicLabel: SKSpriteNode = SKSpriteNode(imageNamed: "MusicTag")
        
        let xPos: CGFloat = -musicLabel.size.width * 0.5
        let yPos: CGFloat = self.frame.height * 0.09
        musicLabel.position = CGPoint(x: xPos, y: yPos)
        musicLabel.zPosition = 30
        
        self.addChild(musicLabel)
        
        let waitFirst: SKAction = SKAction.wait(forDuration: 0.5)
        let moveRightDist: CGFloat = musicLabel.size.width * 1.1
        let moveRightAction: SKAction = SKAction.move(by: CGVector(dx: moveRightDist, dy: 0), duration: 1)
        let waitAction: SKAction = SKAction.wait(forDuration: 2)
        let moveLeftAction: SKAction = SKAction.move(by: CGVector(dx: -moveRightDist, dy: 0), duration: 1)
        
        let actionSequence: SKAction = SKAction.sequence([waitFirst, moveRightAction, waitAction, moveLeftAction])
        
        musicLabel.run(actionSequence, completion: {
            musicLabel.removeFromParent()
        })
    }
    
    func createBackgroundNotifications() {
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.gameWillEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.gameDidEnterForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func createControlButton() {
        controlButton = ButtonNode(imageNamed: "pauseNormal")
        
        let xPos: CGFloat = controlButton.size.width * 0.5 + 20
        let yPos: CGFloat = self.frame.height - xPos
        let buttonPos: CGPoint = CGPoint(x: xPos, y: yPos)
        
        controlButton.setup(atPosition: buttonPos, withName: "Control", normalTextureName: "pauseNormal", highlightedTextureName: "pauseHighlighted")
        
        self.addChild(controlButton)
    }
    
    func createBackground() {
        let context: CIContext = CIContext(options: nil)
        let filter: CIFilter = CIFilter(name: "CILinearGradient")!
        let startVector: CIVector = CIVector(x: size.width * 0.5, y: 0)
        let endVector: CIVector = CIVector(x: size.width * 0.5, y: size.height)
        
        filter.setDefaults()
        
        filter.setValue(startVector, forKey: "inputPoint0")
        filter.setValue(endVector, forKey: "inputPoint1")
        filter.setValue(CIColor(color: UIColor.white), forKey: "inputColor0")
        filter.setValue(CIColor(color: UIColor.black), forKey: "inputColor1")
        
        let imageFrame: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let image: CGImage = context.createCGImage(filter.outputImage!, from: imageFrame)!
        
        let gradientTexture: SKTexture = SKTexture(cgImage: image)
        
        backgroundGradient = SKSpriteNode(texture: gradientTexture)
        backgroundGradient.zPosition = -100;
        backgroundGradient.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgroundGradient.color = UIColor.red
        backgroundGradient.colorBlendFactor = 0.0
        
        self.addChild(backgroundGradient)
    }
    
    func createMellow() {
        //Create the hero of the game!
        mellow = MellowNode(imageNamed: "standing")
        let mellowPos: CGPoint = CGPoint(x: 30, y: self.size.height * 0.5 - 50.0)
        //Most of the initialization of the mellow is done in setup()
        mellow.setup(mellowPos)
        self.addChild(mellow)
    }
    
    func createFloor() {
        //Create the initial floor that all other bodies rest on. It must span more than the width of the screen.
        let floorSize: CGSize = CGSize(width: 2 * self.size.width, height: self.size.height)
        floor = RoundedBlockNode(color: UIColor.black, size: floorSize)
        floor.position = CGPoint(x: self.size.width / 2, y: -floorSize.height / 3)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floorSize)
        floor.physicsBody!.isDynamic = false
        floor.physicsBody!.restitution = 0.0
        floor.physicsBody!.categoryBitMask = CollisionTypes.background.rawValue
        floor.physicsSize = floorSize
        
        //Make sure the floor collides with only falling blocks and mellows
        floor.physicsBody!.collisionBitMask = CollisionTypes.mellow.rawValue | CollisionTypes.fallingBlock.rawValue
        floor.physicsBody!.contactTestBitMask = CollisionTypes.mellow.rawValue | CollisionTypes.fallingBlock.rawValue
        floor.name = "floor"
        worldNode.addChild(floor)
    }
    
    func createLava() {
        //Create the lava – a red semi-transparent rectangle that rises at variable speed
        let lavaColor: UIColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.3)
        let lavaWidth: CGFloat = self.size.width + mellow.physicsSize.width * 2.0
        let lavaHeight: CGFloat = self.size.height + mellow.physicsSize.height
        let lavaSize: CGSize = CGSize(width: lavaWidth, height: lavaHeight)
        risingLava = SKSpriteNode(color: lavaColor, size: lavaSize)
        risingLava.position = CGPoint(x: lavaSize.width / 2.0, y: -lavaSize.height * 0.9)
        risingLava.physicsBody = SKPhysicsBody(rectangleOf: lavaSize)
        
        //Unfortunately necessary to give the lava velocity
        risingLava.physicsBody!.isDynamic = true
        risingLava.physicsBody!.affectedByGravity = false
        risingLava.physicsBody!.allowsRotation = false
        risingLava.physicsBody!.linearDamping = 0.0
        risingLava.physicsBody!.categoryBitMask = CollisionTypes.lava.rawValue
        
        //The lava shouldn't physically collide with anything
        risingLava.physicsBody!.collisionBitMask = 0x00000000
        
        //But I should be notified if the lava touhes stuff
        risingLava.physicsBody!.contactTestBitMask = CollisionTypes.mellow.rawValue | CollisionTypes.background.rawValue | CollisionTypes.fallingBlock.rawValue
        risingLava.name = "lava"
        worldNode.addChild(risingLava)
    }
    
    func createLabels() {
        //Displays highest height climbed so far
        bestLabel = SKLabelNode(fontNamed: "Arial")
        bestLabel.text = "0 ft"
        bestLabel.fontSize = 36.0
        bestLabel.position = CGPoint(x: self.frame.width * 0.94, y: self.frame.height * 0.93)
        bestLabel.zPosition = 30.0
        bestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        self.addChild(bestLabel)
        
        //Displays current height
        currentLabel = SKLabelNode(fontNamed: "Arial")
        currentLabel.text = "0 ft"
        currentLabel.fontSize = 30.0
        currentLabel.position = CGPoint(x: self.frame.width * 0.94, y: self.frame.height * 0.88)
        currentLabel.zPosition = 30.0
        currentLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        self.addChild(currentLabel)
    }
    
    //MARK: Contact Methods
    func didBegin(_ contact: SKPhysicsContact) {
        let contactPoint = contact.contactPoint
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //Now, the first body is guarenteed to have a smaller category bit mask
        
        //If the contact was between a mellow and the lava
        if firstBody.categoryBitMask == CollisionTypes.mellow.rawValue && secondBody.categoryBitMask == CollisionTypes.lava.rawValue {
            mellowDestroyed(.lava)
        }
            //If the contact was between a falling block and a piece of the background
        else if firstBody.categoryBitMask == CollisionTypes.background.rawValue && secondBody.categoryBitMask == CollisionTypes.fallingBlock.rawValue {
            if let block = secondBody.node as? RoundedBlockNode, let _ = firstBody.node as? RoundedBlockNode {
                //Make the falling block static and fade it to black
                turnToBackground(block)
            }
        }
            //If two falling blocks collide
        else if firstBody.categoryBitMask == CollisionTypes.fallingBlock.rawValue && secondBody.categoryBitMask == CollisionTypes.fallingBlock.rawValue {
            if let first = firstBody.node as? RoundedBlockNode, let second = secondBody.node as? RoundedBlockNode {
                if first.fallSpeed > second.fallSpeed {
                    first.fallSpeed = second.fallSpeed
                } else {
                    second.fallSpeed = first.fallSpeed
                }
            }
        }
            //If the first body was the mellow and the second body was the background or a falling block
        else if firstBody.categoryBitMask == CollisionTypes.mellow.rawValue && (secondBody.categoryBitMask == 2 || secondBody.categoryBitMask == 4) {
            
            guard mellow.physicsBody != nil else {
                return
            }
            
            //Calculate the various physical aspects of the second body
            let block: RoundedBlockNode = secondBody.node! as! RoundedBlockNode
            let blockYPos: CGFloat = block.position.y + worldNode.position.y
            let blockTopEdge: CGFloat = blockYPos + block.physicsSize.height * 0.35
            let blockLeftEdge: CGFloat = block.position.x - block.physicsSize.width * 0.35
            let blockRightEdge: CGFloat = block.position.x + block.physicsSize.width * 0.35
            let blockBotEdge: CGFloat = blockYPos - block.physicsSize.height * 0.35
            
            //Calculate the various physical aspects of the mellow
            let mellowBotEdge: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.35
            let mellowRightEdge: CGFloat = mellow.position.x + mellow.physicsSize.width * 0.35
            let mellowLeftEdge: CGFloat = mellow.position.x - mellow.physicsSize.width * 0.35
            let mellowTopEdge: CGFloat = mellow.position.y + mellow.physicsSize.height * 0.35
            
            //Calculate differences between physical aspects of the two bodies
            let blockTopLessMellowBot: Bool = blockTopEdge < mellowBotEdge
            let yPosDiff: CGFloat = abs(blockYPos - mellow.position.y)
            let xPosDiff: CGFloat = abs(block.position.x - mellow.position.x)
            let combinedHeights: CGFloat = block.physicsSize.height * 0.5 + mellow.physicsSize.height * 0.5
            let combinedWidths: CGFloat = block.physicsSize.width * 0.5 + mellow.physicsSize.width * 0.5
            
            //If mellow landed on a piece of scenery
            if blockTopLessMellowBot && xPosDiff < combinedWidths {
                mellow.bottomSideInContact += 1
            }
            else if blockRightEdge < mellowLeftEdge && yPosDiff < combinedHeights {
                //If the mellow's left edge touched a piece of scenery
                mellow.leftSideInContact += 1
            }
            else if mellowRightEdge < blockLeftEdge && yPosDiff < combinedHeights {
                //If the mellow's right edge touched a piece of scenery
                mellow.rightSideInContact += 1
            }
                
                //If the mellow got crushed by a block
            else if mellow.bottomSideInContact > 0 {
                if contactPoint.y > mellowTopEdge {
                    if let block = secondBody.node as? RoundedBlockNode , block.physicsBody!.categoryBitMask == CollisionTypes.fallingBlock.rawValue {
                        if contactPoint.y < blockBotEdge {
                            if abs(mellow.physicsBody!.velocity.dy) < 10 {
                                mellowDestroyed(.crushed)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func mellowDestroyed(_ by: DeathTypes) {
        //Remove the mellow's physicsBody so it doesn't slide
        mellow.physicsBody = nil
        //Animate through the crushed textures
        var crushedTextures: [SKTexture] = [SKTexture]()
        for i in 1...7 {
            crushedTextures.append(SKTexture(imageNamed: "crushed\(i)"))
        }
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 0.14)
        mellow.run(moveAction)
        let crushedAction = SKAction.animate(with: crushedTextures, timePerFrame: 0.02)
        self.risingLava.physicsBody!.velocity.dy = 0
        
        if by == .crushed {
            mellow.run(crushedAction, completion: {
                //Crushed sound effects
                
                if self.backgroundMusic != nil {
                    self.backgroundMusic.run(SKAction.stop())
                    self.backgroundMusic.removeFromParent()
                }
                
                self.playSoundEffectNamed("MellowCrushed.wav", waitForCompletion: false)
                
                //Add the explosion after the crush
                let mellowCrushedExplosion = SKEmitterNode(fileNamed: "MellowCrushed")!
                mellowCrushedExplosion.position = self.mellow.position
                mellowCrushedExplosion.zPosition = 20
                self.addChild(mellowCrushedExplosion)
                self.mellow.removeFromParent()
            })
        } else {
            self.playSoundEffectNamed("MellowBurned.wav", waitForCompletion: false)
            mellow.run(crushedAction, completion: {
                //Burned Sound Effects
                if self.backgroundMusic != nil {
                    self.backgroundMusic.run(SKAction.stop())
                    self.backgroundMusic.removeFromParent()
                }
                
                //Add the fire after getting crushed
                let mellowBurned = SKEmitterNode(fileNamed: "MellowBurned")!
                mellowBurned.zPosition = 20
                mellowBurned.position = self.mellow.position
                mellowBurned.position.y -= self.mellow.physicsSize.height * 0.3
                self.addChild(mellowBurned)
                self.mellow.removeFromParent()
            })
        }
        
        self.currentGameState = .gameOver
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //Same idea as beginContact
        
        
        //If the mellow was the first body and the second was a piece of scenery
        if firstBody.categoryBitMask == CollisionTypes.mellow.rawValue && (secondBody.categoryBitMask == 2 || secondBody.categoryBitMask == 4) {
            guard mellow.physicsBody != nil else {
                return
            }
            
            let block = secondBody.node! as! RoundedBlockNode
            let blockYPos: CGFloat = block.position.y + worldNode.position.y
            let blockTopEdge: CGFloat = blockYPos + block.physicsSize.height * 0.35
            let blockLeftEdge: CGFloat = block.position.x - block.physicsSize.width * 0.35
            let blockRightEdge: CGFloat = block.position.x + block.physicsSize.width * 0.35
            
            let mellowBotEdge: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.35
            let mellowRightEdge: CGFloat = mellow.position.x + mellow.physicsSize.width * 0.35
            let mellowLeftEdge: CGFloat = mellow.position.x - mellow.physicsSize.width * 0.35
            
            let blockTopLessMellowBot: Bool = blockTopEdge < mellowBotEdge
            let yPosDiff: CGFloat = abs(blockYPos - mellow.position.y)
            let xPosDiff: CGFloat = abs(block.position.x - mellow.position.x)
            let combinedHeights: CGFloat = block.physicsSize.height * 0.5 + mellow.physicsSize.height * 0.5
            let combinedWidths: CGFloat = block.physicsSize.width * 0.5 + mellow.physicsSize.width * 0.5
            
            
            //If the mellow and the ground lost a point of contact
            if  mellow.bottomSideInContact > 0 && blockTopLessMellowBot && xPosDiff < combinedWidths  {
                mellow.bottomSideInContact -= 1
            }
            else if mellow.leftSideInContact > 0 && blockRightEdge < mellowLeftEdge && yPosDiff < combinedHeights {
                //If the mellow and the left wall lost a point of contact
                mellow.leftSideInContact -= 1
            }
            else if mellow.rightSideInContact > 0 && mellowRightEdge < blockLeftEdge && yPosDiff < combinedHeights {
                //If the mellow and the right wall lost a point of contact
                mellow.rightSideInContact -= 1
            }
        }
            //If the rising lava and an object in the background lost contact, it means that that piece
            //of the background will never be seen and should be removed from the scene
        else if firstBody.categoryBitMask != CollisionTypes.mellow.rawValue && secondBody.categoryBitMask == CollisionTypes.lava.rawValue {
            if let removeBlock = firstBody.node as? RoundedBlockNode , removeBlock.parent != nil {
                removeBlock.removeFromParent()
            }
        }
    }
    
    
    //MARK: Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if currentGameState == .gameInProgress {
            var noButtonsTapped: Bool = true
            for touch in touches {
                let location = touch.location(in: self)
                let objects = nodes(at: location) as [SKNode]
                for object in objects {
                    if object.name == "Control" {
                        controlButton.didPress()
                        noButtonsTapped = false
                        break
                    }
                }
            }
            
            //Jump if no buttons were tapped
            if noButtonsTapped {
                mellow.jump()
            }
        }
        else if currentGameState == .gamePaused {
            for touch in touches {
                let location = touch.location(in: self)
                let objects = nodes(at: location) as [SKNode]
                for object in objects {
                    if object.name == "Control" {
                        controlButton.didPress()
                        break
                    }
                    else if object.name == "SelfDestruct" {
                        if let sdButton = object as? ButtonNode {
                            sdButton.didPress()
                        }
                    }
                    else if object.name == "Audio" {
                        pauseScreen.toggleButton(object as! ButtonNode)
                        audioIsOn = !audioIsOn
                        break
                    } else if object.name == "SoundEffects" {
                        pauseScreen.toggleButton(object as! ButtonNode)
                        soundEffectsAreOn = !soundEffectsAreOn
                        break
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard currentGameState != .tutorial else {
            return
        }
        
        //Generate "touch-up-inside" behavior for game-over buttons
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Control" || object.name == "SelfDestruct" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            pauseScreen.selfDestructButtonLabel.didRelease()
            controlButton.didRelease()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard currentGameState != .tutorial else {
            return
        }
        
        if controlButton.isPressed {
            controlButton.didRelease()
            if currentGameState == .gameInProgress {
                self.currentGameState = .gamePaused
                self.controlButton.updateTextureSet(withNormalTextureName: "playNormal", highlightedTextureName: "playHighlighted")
            }
            else if currentGameState == .gamePaused {
                self.currentGameState = .gameInProgress
                self.controlButton.updateTextureSet(withNormalTextureName: "pauseNormal", highlightedTextureName: "pauseHighlighted")
            }
        } else if pauseScreen.selfDestructButtonLabel.isPressed {
            pauseScreen.selfDestructButtonLabel.didRelease()
            self.currentGameState = .gameInProgress
            mellowDestroyed(.crushed)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard currentGameState != .tutorial else {
            return
        }
        
        controlButton.didRelease()
        pauseScreen.selfDestructButtonLabel.didRelease()
    }
}
