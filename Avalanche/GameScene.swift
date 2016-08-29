//
//  GameScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 3/21/16.
//  Copyright (c) 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var worldNode: SKNode!
    let motionManager: CMMotionManager = CMMotionManager()
    
    var mellow: MellowNode!
    var floor: RoundedBlockNode!
    var risingLava: SKSpriteNode!
    
    var controlButton: SKSpriteNode!
    
    var bestLabel: SKLabelNode!
    var currentLabel: SKLabelNode!
    
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
    var currentGameState: GameStates = GameStates.GameInProgress
    var currentButtonState: ButtonStates = ButtonStates.Empty
    var currentDifficulty: Int = -1 {
        didSet {
            self.removeActionForKey("genBlocks")
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
    
    var backgroundMusic: SKAudioNode!
    var backgroundGradient: SKSpriteNode!
    
    //MARK: Game Termination Methods
    func gameOver() {
        currentGameState = .GameOver
        createReplayButton()
        createMenuButton()
    }
    
    func createReplayButton() {
        let screenCenter: CGPoint = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        
        let replayButton: SKLabelNode = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        replayButton.fontSize = 48.0
        replayButton.fontColor = UIColor.whiteColor()
        replayButton.text = "Replay"
        replayButton.position = CGPoint(x: screenCenter.x, y: screenCenter.y + replayButton.frame.height)
        replayButton.name = "Replay"
        replayButton.zPosition = 30
        
        self.addChild(replayButton)
    }
    
    func createMenuButton() {
        let screenCenter = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        
        let menuButton: SKLabelNode = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        menuButton.fontSize = 48.0
        menuButton.fontColor = UIColor.whiteColor()
        menuButton.text = "Menu"
        menuButton.position = CGPoint(x: screenCenter.x, y: screenCenter.y - menuButton.frame.height)
        menuButton.name = "Menu"
        menuButton.zPosition = 30
        
        self.addChild(menuButton)
    }
    
    
    //MARK: Block Methods
    func generateRandomBlock(minFallSpeed: Float, maxFallSpeed: Float) {
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
    
    func initBlocks(sec: NSTimeInterval, withRange durationRange: NSTimeInterval, minFallSpeed: Float, maxFallSpeed: Float) {
        let createBlock: SKAction = SKAction.runBlock { [unowned self] in
            self.generateRandomBlock(minFallSpeed, maxFallSpeed: maxFallSpeed)
        }
        
        let wait: SKAction = SKAction.waitForDuration(sec, withRange: durationRange)
        let sequence: SKAction = SKAction.sequence([createBlock, wait])
        let repeatForever: SKAction = SKAction.repeatActionForever(sequence)
        runAction(repeatForever, withKey: "genBlocks")
    }
    
    
    //MARK: Update Methods
    override func update(currentTime: CFTimeInterval) {
        print("\(currentButtonState) – \(currentGameState)")
        updateDistance()
        setLavaSpeed()
        
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
            let difference = mellow.position.y - (self.size.height - mellowThriceHeight)
            mellow.position.y = self.size.height - mellowThriceHeight
            self.worldNode.position.y -= difference
        }
        else if mellow.position.y < mellowTwiceHeight {
            let difference = mellowTwiceHeight - mellow.position.y
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
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Let this object receive contact notifications
        physicsWorld.contactDelegate = self
        
        //Create a "world node" that everything but the mellow belongs to.
        //Used to make it seem like the mellow is moving
        //when the mellow gets close to the top or bottom of the screen.
        worldNode = SKNode()
        worldNode.position = self.position
        self.addChild(worldNode)
        
        //Create stuff
        createMellow()
        createFloor()
        createLava()
        createLabels()
        createBackground()
        createControlButton()
        
        //Allows the game to read the tilt of the phone and react accordingly
        motionManager.startAccelerometerUpdates()
        
        //Start the music!!!
        runAction(SKAction.waitForDuration(0.5), completion: {
            let bgcopy = SKAudioNode(fileNamed: "DreamsOfAbove.mp3")
            self.addChild(bgcopy)
            self.backgroundMusic = bgcopy
        })
        scrollMusicLabel()
    }
    
    func scrollMusicLabel() {
        let musicLabel: SKSpriteNode = SKSpriteNode(imageNamed: "MusicTag")
        
        let xPos: CGFloat = -musicLabel.size.width * 0.5
        let yPos: CGFloat = self.frame.height * 0.09
        musicLabel.position = CGPoint(x: xPos, y: yPos)
        musicLabel.zPosition = 30
        
        self.addChild(musicLabel)
        
        let waitFirst: SKAction = SKAction.waitForDuration(0.5)
        let moveRightDist: CGFloat = musicLabel.size.width * 1.1
        let moveRightAction: SKAction = SKAction.moveBy(CGVector(dx: moveRightDist, dy: 0), duration: 1)
        let waitAction: SKAction = SKAction.waitForDuration(2)
        let moveLeftAction: SKAction = SKAction.moveBy(CGVector(dx: -moveRightDist, dy: 0), duration: 1)
        
        let actionSequence = SKAction.sequence([waitFirst, moveRightAction, waitAction, moveLeftAction])
        
        musicLabel.runAction(actionSequence) {
            musicLabel.removeFromParent()
        }
    }
    
    
    func createControlButton() {
        controlButton = SKSpriteNode(imageNamed: "pauseNormal")
        controlButton.name = "Control"
        
        let xPos: CGFloat = controlButton.size.width * 0.5 + 20
        let yPos: CGFloat = self.frame.height - xPos
        controlButton.position = CGPoint(x: xPos, y: yPos)
        
        controlButton.zPosition = 30
        
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
        filter.setValue(CIColor(color: UIColor.whiteColor()), forKey: "inputColor0")
        filter.setValue(CIColor(color: UIColor.blackColor()), forKey: "inputColor1")
        
        let imageFrame: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let image: CGImage = context.createCGImage(filter.outputImage!, fromRect: imageFrame)
        
        let gradientTexture: SKTexture = SKTexture(CGImage: image)
        
        backgroundGradient = SKSpriteNode(texture: gradientTexture)
        backgroundGradient.zPosition = -100;
        backgroundGradient.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgroundGradient.color = UIColor.redColor()
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
        floor = RoundedBlockNode(color: UIColor.blackColor(), size: floorSize)
        floor.position = CGPoint(x: self.size.width / 2, y: -floorSize.height / 3)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: floorSize)
        floor.physicsBody!.dynamic = false
        floor.physicsBody!.restitution = 0.0
        floor.physicsBody!.categoryBitMask = CollisionTypes.Background.rawValue
        floor.physicsSize = floorSize
        
        //Make sure the floor collides with only falling blocks and mellows
        floor.physicsBody!.collisionBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.FallingBlock.rawValue
        floor.physicsBody!.contactTestBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.FallingBlock.rawValue
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
        risingLava.physicsBody = SKPhysicsBody(rectangleOfSize: lavaSize)
        
        //Unfortunately necessary to give the lava velocity
        risingLava.physicsBody!.dynamic = true
        risingLava.physicsBody!.affectedByGravity = false
        risingLava.physicsBody!.allowsRotation = false
        risingLava.physicsBody!.linearDamping = 0.0
        risingLava.physicsBody!.categoryBitMask = CollisionTypes.Lava.rawValue
        
        //The lava shouldn't physically collide with anything
        risingLava.physicsBody!.collisionBitMask = 0x00000000
        
        //But I should be notified if the lava touhes stuff
        risingLava.physicsBody!.contactTestBitMask = CollisionTypes.Mellow.rawValue | CollisionTypes.Background.rawValue | CollisionTypes.FallingBlock.rawValue
        risingLava.physicsBody!.velocity.dy = 30
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
        bestLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(bestLabel)
        
        //Displays current height
        currentLabel = SKLabelNode(fontNamed: "Arial")
        currentLabel.text = "0 ft"
        currentLabel.fontSize = 30.0
        currentLabel.position = CGPoint(x: self.frame.width * 0.94, y: self.frame.height * 0.88)
        currentLabel.zPosition = 30.0
        currentLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.addChild(currentLabel)
    }
    
    //MARK: Contact Methods
    func didBeginContact(contact: SKPhysicsContact) {
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
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue && secondBody.categoryBitMask == CollisionTypes.Lava.rawValue {
            mellowDestroyed(.Lava)
        }
            //If the contact was between a falling block and a piece of the background
        else if firstBody.categoryBitMask == CollisionTypes.Background.rawValue && secondBody.categoryBitMask == CollisionTypes.FallingBlock.rawValue {
            if let block = secondBody.node as? RoundedBlockNode, _ = firstBody.node as? RoundedBlockNode {
                //Make the falling block static and fade it to black
                block.becomeBackground()
            }
        }
            //If two falling blocks collide
        else if firstBody.categoryBitMask == CollisionTypes.FallingBlock.rawValue && secondBody.categoryBitMask == CollisionTypes.FallingBlock.rawValue {
            if let first = firstBody.node as? RoundedBlockNode, second = secondBody.node as? RoundedBlockNode {
                if first.fallSpeed > second.fallSpeed {
                    first.fallSpeed = second.fallSpeed
                } else {
                    second.fallSpeed = first.fallSpeed
                }
            }
        }
            //If the first body was the mellow and the second body was the background or a falling block
        else if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue && (secondBody.categoryBitMask == 2 || secondBody.categoryBitMask == 4) {
            
            guard mellow.physicsBody != nil else {
                return
            }
            
            //Calculate the various physical aspects of the second body
            let block: RoundedBlockNode = secondBody.node! as! RoundedBlockNode
            let blockYPos: CGFloat = block.position.y + worldNode.position.y
            let blockTopEdge: CGFloat = blockYPos + block.physicsSize.height * 0.4
            let blockLeftEdge: CGFloat = block.position.x - block.physicsSize.width * 0.4
            let blockRightEdge: CGFloat = block.position.x + block.physicsSize.width * 0.4
            let blockBotEdge: CGFloat = blockYPos - block.physicsSize.height * 0.35
            
            //Calculate the various physical aspects of the mellow
            let mellowBotEdge: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.4
            let mellowRightEdge: CGFloat = mellow.position.x + mellow.physicsSize.width * 0.4
            let mellowLeftEdge: CGFloat = mellow.position.x - mellow.physicsSize.width * 0.4
            let mellowTopEdge: CGFloat = mellow.position.y + mellow.physicsSize.height * 0.35
            
            //Calculate differences between physical aspects of the two bodies
            let blockTopLessMellowBot: Bool = blockTopEdge < mellowBotEdge
            let yPosDiff: CGFloat = abs(blockYPos - mellow.position.y)
            let xPosDiff: CGFloat = abs(block.position.x - mellow.position.x)
            let combinedHeights: CGFloat = block.physicsSize.height * 0.5 + mellow.physicsSize.height * 0.4
            let combinedWidths: CGFloat = block.physicsSize.width * 0.5 + mellow.physicsSize.width * 0.5
            
            //If mellow landed on a piece of scenery
            if blockTopLessMellowBot && xPosDiff < combinedWidths {
                mellow.bottomSideInContact += 1
            }
            else if blockRightEdge < mellowLeftEdge && yPosDiff < combinedHeights {
                //If the mellow's left edge touched a piece of scenery
                mellow.leftSideInContact += 1
                mellow.physicsBody!.velocity.dx = 0
            }
            else if mellowRightEdge < blockLeftEdge && yPosDiff < combinedHeights {
                //If the mellow's right edge touched a piece of scenery
                mellow.rightSideInContact += 1
                mellow.physicsBody!.velocity.dx = 0
            }
                
                //If the mellow got crushed by a block
            else if mellow.bottomSideInContact > 0 {
                if contactPoint.y > mellowTopEdge {
                    if let block = secondBody.node as? RoundedBlockNode where block.physicsBody!.categoryBitMask == CollisionTypes.FallingBlock.rawValue {
                        if contactPoint.y < blockBotEdge {
                            if abs(mellow.physicsBody!.velocity.dy) < 10 {
                                mellowDestroyed(.Crushed)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func mellowDestroyed(by: DeathTypes) {
        //Remove the mellow's physicsBody so it doesn't slide
        mellow.physicsBody = nil
        //Animate through the crushed textures
        var crushedTextures: [SKTexture] = [SKTexture]()
        for i in 1...7 {
            crushedTextures.append(SKTexture(imageNamed: "crushed\(i)"))
        }
        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: -10), duration: 0.14)
        mellow.runAction(moveAction)
        let crushedAction = SKAction.animateWithTextures(crushedTextures, timePerFrame: 0.02)
        self.risingLava.physicsBody!.velocity.dy = 0
        
        if by == .Crushed {
            mellow.runAction(crushedAction, completion: {
                //Crushed sound effects
                self.backgroundMusic.runAction(SKAction.stop())
                self.backgroundMusic.removeFromParent()
                self.runAction(SKAction.playSoundFileNamed("MellowCrushed.wav", waitForCompletion: false))
                
                //Add the explosion after the crush
                let mellowCrushedExplosion = SKEmitterNode(fileNamed: "MellowCrushed")!
                mellowCrushedExplosion.position = self.mellow.position
                mellowCrushedExplosion.zPosition = 20
                self.addChild(mellowCrushedExplosion)
                self.mellow.removeFromParent()
            })
        } else {
            self.runAction(SKAction.playSoundFileNamed("MellowBurned.wav", waitForCompletion: false))
            mellow.runAction(crushedAction, completion: {
                //Burned Sound Effects
                self.backgroundMusic.runAction(SKAction.stop())
                self.backgroundMusic.removeFromParent()
                
                //Add the fire after getting crushed
                let mellowBurned = SKEmitterNode(fileNamed: "MellowBurned")!
                mellowBurned.zPosition = 20
                mellowBurned.position = self.mellow.position
                mellowBurned.position.y -= self.mellow.physicsSize.height * 0.3
                self.addChild(mellowBurned)
                self.mellow.removeFromParent()
            })
        }
        
        //Stop generating blocks
        self.removeActionForKey("genBlocks")
        
        //Run the game over function after a specified duration
        let gameOverAction = SKAction.waitForDuration(2.0)
        self.runAction(gameOverAction) {
            self.gameOver()
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
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
        if firstBody.categoryBitMask == CollisionTypes.Mellow.rawValue && (secondBody.categoryBitMask == 2 || secondBody.categoryBitMask == 4) {
            let block = secondBody.node! as! RoundedBlockNode
            let blockYPos: CGFloat = block.position.y + worldNode.position.y
            let blockTopEdge: CGFloat = blockYPos + block.physicsSize.height * 0.4
            let blockLeftEdge: CGFloat = block.position.x - block.physicsSize.width * 0.4
            let blockRightEdge: CGFloat = block.position.x + block.physicsSize.width * 0.4
            
            let mellowBotEdge: CGFloat = mellow.position.y - mellow.physicsSize.height * 0.4
            let mellowRightEdge: CGFloat = mellow.position.x + mellow.physicsSize.width * 0.4
            let mellowLeftEdge: CGFloat = mellow.position.x - mellow.physicsSize.width * 0.4
            
            let blockTopLessMellowBot: Bool = blockTopEdge < mellowBotEdge
            let yPosDiff: CGFloat = abs(blockYPos - mellow.position.y)
            let xPosDiff: CGFloat = abs(block.position.x - mellow.position.x)
            let combinedHeights: CGFloat = block.physicsSize.height * 0.6 + mellow.physicsSize.height * 0.5
            let combinedWidths: CGFloat = block.physicsSize.width * 0.6 + mellow.physicsSize.width * 0.5
            
            
            //If the mellow and the ground lost a point of contact
            if  mellow.bottomSideInContact > 0 && blockTopLessMellowBot && xPosDiff < combinedWidths  {
                mellow.bottomSideInContact -= 1
            }
            if mellow.leftSideInContact > 0 && blockRightEdge < mellowLeftEdge && yPosDiff < combinedHeights {
                //If the mellow and the left wall lost a point of contact
                mellow.leftSideInContact -= 1
            }
            if mellow.rightSideInContact > 0 && mellowRightEdge < blockLeftEdge && yPosDiff < combinedHeights {
                //If the mellow and the right wall lost a point of contact
                mellow.rightSideInContact -= 1
            }
        }
            //If the rising lava and an object in the background lost contact, it means that that piece
            //of the background will never be seen and should be removed from the scene
        else if firstBody.categoryBitMask != CollisionTypes.Mellow.rawValue && secondBody.categoryBitMask == CollisionTypes.Lava.rawValue {
            if let removeBlock = firstBody.node as? RoundedBlockNode where removeBlock.parent != nil {
                removeBlock.removeFromParent()
            }
        }
    }
    
    
    //MARK: Touch Metnm   hods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        currentButtonState = .Empty
        for touch in touches {
            let location = touch.locationInNode(self)
            let objects = nodesAtPoint(location) as [SKNode]
            for object in objects {
                if object.name == "Control" {
                    currentButtonState = .ControlTapped
                    if currentGameState == .GameInProgress {
                        controlButton.texture = SKTexture(imageNamed: "pauseHighlighted")
                    }
                    else if currentGameState == .GamePaused {
                        controlButton.texture = SKTexture(imageNamed: "playHighlighted")
                    }
                    break
                }
                else if object.name == "Replay" {
                    currentButtonState = .ReplayTapped
                    break
                }
                else if object.name == "Menu" {
                    currentButtonState = .MenuTapped
                    break
                }
            }
        }
        
        //Jump if no buttons were tapped
        if currentGameState == .GameInProgress {
            if currentButtonState == .Empty {
                mellow.jump()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Generate "touch-up-inside" behavior for game-over buttons
        let copy: ButtonStates = currentButtonState
        currentButtonState = .Empty
        if copy != .Empty {
            for touch in touches {
                let location = touch.locationInNode(self)
                let objects = nodesAtPoint(location) as [SKNode]
                for object in objects {
                    if object.name == "Control" {
                        currentButtonState = .ControlTapped
                        break
                    }
                    else if object.name == "Replay" {
                        currentButtonState = .ReplayTapped
                        break
                    }
                    else if object.name == "Menu" {
                        currentButtonState = .MenuTapped
                        break
                    }
                }
            }
            
            if copy == .ControlTapped && currentButtonState == .Empty {
                if currentGameState == .GameInProgress {
                    controlButton.texture = SKTexture(imageNamed: "pauseNormal")
                }
                else if currentGameState == .GamePaused {
                    controlButton.texture = SKTexture(imageNamed: "playNormal")
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch currentButtonState {
        case .ControlTapped:
            currentButtonState = .Empty
            
            if currentGameState == .GameInProgress {
                backgroundMusic.runAction(SKAction.pause())
                self.currentGameState = .GamePaused
                self.controlButton.texture = SKTexture(imageNamed: "playNormal")
                //SOMEHOW PAUSE THE GAME HERE
            }
            else if currentGameState == .GamePaused {
                self.currentGameState = .GameInProgress
                self.controlButton.texture = SKTexture(imageNamed: "pauseNormal")
                self.backgroundMusic.runAction(SKAction.play())
            }
        case .ReplayTapped:
            currentButtonState = .Empty
            
            self.removeFromParent()
            
            let gameScene = GameScene(fileNamed: "GameScene")!
            gameScene.size = self.size
            let transition = SKTransition.crossFadeWithDuration(0.5)
            gameScene.scaleMode = .ResizeFill
            self.scene!.view!.presentScene(gameScene, transition: transition)
        case .MenuTapped:
            currentButtonState = .Empty
            
            self.removeFromParent()
            
            let menuScene = MenuScene(size: self.size)
            menuScene.scaleMode = .ResizeFill
            let transition = SKTransition.crossFadeWithDuration(0.5)
            self.scene!.view!.presentScene(menuScene, transition: transition)
        default: break
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if currentGameState == .GameOver {
            currentButtonState = .Empty
        }
    }
}
