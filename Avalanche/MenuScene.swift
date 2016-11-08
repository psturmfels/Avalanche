//
//  MenuScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/23/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import GameKit

class MenuScene: SKScene {
    var playButton: ButtonLabelNode!
    var scoresButton: ButtonLabelNode!
    var tutorialButton: ButtonNode!
    var settingsButton: ButtonNode!
    
    var audioButtonLabel: ButtonLabelNode!
    var soundEffectsButtonLabel: ButtonLabelNode!
    var menuButton: ButtonNode!
    
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if gameCenterIsAuthenticated {
                scoresButton.alpha = 1.0
            } else {
                scoresButton.alpha = 0.5
            }
        }
    }
    
    //MARK: Button Methods
    func displaySettings() {
        let downShudder1: SKAction = SKAction.moveBy(x: 0.0, y: -20.0, duration: 0.08)
        let downShudder2: SKAction = SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.08)
        let downShudder3: SKAction = SKAction.moveBy(x: 0.0, y: -5.0, duration: 0.08)
        let upSweep: SKAction = SKAction.moveBy(x: 0.0, y: self.frame.height, duration: 0.2)
        
        let moveUpSequence: SKAction = SKAction.sequence([downShudder1, downShudder2, downShudder3, upSweep])
        
        playButton.buttonNode.name = ""
        scoresButton.buttonNode.name = ""
        
        playButton.run(moveUpSequence)
        scoresButton.run(moveUpSequence)
        
        let leftShudder1: SKAction = SKAction.moveBy(x: -20.0, y: 0.0, duration: 0.07)
        let leftShudder2: SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.07)
        let leftShudder3: SKAction = SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.07)
        let rightSweep: SKAction = SKAction.moveBy(x: self.frame.width, y: 0.0, duration: 0.2)
        let moveRightSequence: SKAction = SKAction.sequence([leftShudder1, leftShudder2, leftShudder3, rightSweep])
        
        tutorialButton.name = ""
        settingsButton.name = ""
        
        tutorialButton.run(moveRightSequence)
        settingsButton.run(moveRightSequence)
        
        let waitAction: SKAction = SKAction.wait(forDuration: 0.4)
        let extraRightSweep: SKAction = SKAction.moveBy(x: self.frame.width + 35, y: 0.0, duration: 0.2)
        let reverseRightSequence: SKAction = SKAction.sequence([waitAction, extraRightSweep, leftShudder1, leftShudder2, leftShudder3])
        menuButton.run(reverseRightSequence) { [unowned self] in
            self.menuButton.name = "Menu"
        }
        
        let rightShudder1: SKAction = SKAction.moveBy(x: 20.0, y: 0.0, duration: 0.07)
        let rightShudder2: SKAction = SKAction.moveBy(x: 10.0, y: 0.0, duration: 0.07)
        let rightShudder3: SKAction = SKAction.moveBy(x: 5.0, y: 0.0, duration: 0.07)
        let leftSweep: SKAction = SKAction.moveBy(x: -self.frame.width - 35.0, y: 0.0, duration: 0.2)
        let moveLeftSequence: SKAction = SKAction.sequence([waitAction, leftSweep, rightShudder1, rightShudder2, rightShudder3])
        
        audioButtonLabel.run(moveLeftSequence) { [unowned self] in
            self.audioButtonLabel.buttonNode.name = "AudioButton"
        }
        soundEffectsButtonLabel.run(moveLeftSequence) { [unowned self] in
            self.soundEffectsButtonLabel.buttonNode.name = "SoundEffects"
        }
    }
    
    func returnFromSettings() {
        let leftShudder1: SKAction = SKAction.moveBy(x: -20.0, y: 0.0, duration: 0.07)
        let leftShudder2: SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.07)
        let leftShudder3: SKAction = SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.07)
        let rightSweep: SKAction = SKAction.moveBy(x: self.frame.width + 35.0, y: 0.0, duration: 0.2)
        let moveRightSequence: SKAction = SKAction.sequence([leftShudder1, leftShudder2, leftShudder3, rightSweep])
        audioButtonLabel.buttonNode.name = ""
        soundEffectsButtonLabel.buttonNode.name = ""
        audioButtonLabel.run(moveRightSequence)
        soundEffectsButtonLabel.run(moveRightSequence)
        
        let waitAction: SKAction = SKAction.wait(forDuration: 0.4)
        let upShudder1: SKAction = SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.07)
        let upShudder2: SKAction = SKAction.moveBy(x: 0.0, y: 10.0, duration: 0.07)
        let upShudder3: SKAction = SKAction.moveBy(x: 0.0, y: 5.0, duration: 0.07)
        let downSweep: SKAction = SKAction.moveBy(x: 0.0, y: -self.frame.height, duration: 0.2)
        
        let moveDownSequence: SKAction = SKAction.sequence([waitAction, downSweep, upShudder1, upShudder2, upShudder3])
        playButton.run(moveDownSequence) { [unowned self] in
            self.playButton.buttonNode.name = "Play"
        }
        scoresButton.run(moveDownSequence) { [unowned self] in
            self.scoresButton.buttonNode.name = "Scores"
        }
        
        let rightShudder1: SKAction = SKAction.moveBy(x: 20.0, y: 0.0, duration: 0.07)
        let rightShudder2: SKAction = SKAction.moveBy(x: 10.0, y: 0.0, duration: 0.07)
        let rightShudder3: SKAction = SKAction.moveBy(x: 5.0, y: 0.0, duration: 0.07)
        let leftSweep: SKAction = SKAction.moveBy(x: -self.frame.width, y: 0.0, duration: 0.2)
        let moveLeftSequence: SKAction = SKAction.sequence([waitAction, leftSweep, rightShudder1, rightShudder2, rightShudder3])
        
        tutorialButton.run(moveLeftSequence) { [unowned self] in
            self.tutorialButton.name = "Tutorial"
        }
        settingsButton.run(moveLeftSequence) { [unowned self] in
            self.settingsButton.name = "Settings"
        }
        
        menuButton.name = ""
        let extraLeftSweep: SKAction = SKAction.moveBy(x: -self.frame.width - 35.0, y: 0.0, duration: 0.2)
        let reverseLeftSequence: SKAction = SKAction.sequence([rightShudder1, rightShudder2, rightShudder3, extraLeftSweep])
        menuButton.run(reverseLeftSequence)
    }
    
    func transitionToGame() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Game Scene
        let gameScene: ClassicModeScene = ClassicModeScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        gameScene.scaleMode = .resizeFill
        
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
    
    func transitionToTutorial() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Tutorial Scene
        let tutorialScene: TutorialScene = TutorialScene(fileNamed: "GameScene")!
        tutorialScene.size = self.size
        tutorialScene.scaleMode = .resizeFill
        
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(tutorialScene, transition: transition)
    }
    
    //MARK: View Methods
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self, selector: #selector(MenuScene.authenticationStatusDidChange), name: NSNotification.Name(rawValue: "authenticationStatusChanged"), object: nil)
        GameKitController.authenticateLocalPlayer()
        
        createSettingsButtons()
        createMenuButtons()
        createBackground()
        initBlocks()
    }
    
    //MARK: GameKit Methods
    func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    //MARK: Creation Methods
    func createSettingsButtons() {
        let center: CGPoint = CGPoint(x: 3 * self.frame.midX, y: self.frame.midY)
        audioButtonLabel = ButtonLabelNode()
        audioButtonLabel.setup(withText: "Music: ", withFontSize: 48.0, withButtonName: "", normalTextureName: "audioNormal", highlightedTextureName: "audioOff", atPosition: center)
        audioButtonLabel.position.y += audioButtonLabel.height * 0.5 + 10
        self.addChild(audioButtonLabel)
        
        soundEffectsButtonLabel = ButtonLabelNode()
        soundEffectsButtonLabel.setup(withText: "Sound: ", withFontSize: 48.0, withButtonName: "", normalTextureName: "audioNormal", highlightedTextureName: "audioOff", atPosition: center)
        soundEffectsButtonLabel.position.y -= soundEffectsButtonLabel.height * 0.5 + 10
        self.addChild(soundEffectsButtonLabel)
        
        let audioIsOn: Bool = UserDefaults.standard.bool(forKey: "Audio")
        let soundEffectsAreOn: Bool = UserDefaults.standard.bool(forKey: "SoundEffects")
        if !audioIsOn {
            audioButtonLabel.didPress()
            audioButtonLabel.buttonNode.alpha = 0.5
        }
        if !soundEffectsAreOn {
            soundEffectsButtonLabel.didPress()
            soundEffectsButtonLabel.buttonNode.alpha = 0.5
        }
        
        menuButton = ButtonNode(imageNamed: "menuNormal")
        let leftX: CGFloat = 20.0 + menuButton.frame.width * 0.5 - self.frame.width
        let topY: CGFloat = self.frame.height - menuButton.frame.height * 0.5 - 20
        menuButton.setup(atPosition: CGPoint(x: leftX, y: topY), withName: "", normalTextureName: "menuNormal", highlightedTextureName: "menuHighlighted")
        self.addChild(menuButton)
    }
    
    func createMenuButtons() {
        let center: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        playButton = ButtonLabelNode()
        playButton.setup(withText: "Classic: ", withFontSize: 48.0, withButtonName: "Play", normalTextureName: "playMenuNormal", highlightedTextureName: "playMenuHighlighted", atPosition: center)
        playButton.position.y += playButton.height * 0.5 + 10
        
        scoresButton = ButtonLabelNode()
        scoresButton.setup(withText: "Scores: ", withFontSize: 48.0, withButtonName: "Scores", normalTextureName: "scoresNormal", highlightedTextureName: "scoresHighlighted", atPosition: center)
        scoresButton.position.y -= scoresButton.height * 0.5 + 10
        scoresButton.alpha = 0.5
        
        tutorialButton = ButtonNode(imageNamed: "tutorialNormal")
        let rightX: CGFloat = self.frame.width - tutorialButton.frame.width * 0.5 - 20
        let botY: CGFloat = tutorialButton.frame.height * 0.5 + 20
        tutorialButton.setup(atPosition: CGPoint(x: rightX, y: botY), withName: "Tutorial", normalTextureName: "tutorialNormal", highlightedTextureName: "tutorialHighlighted")
        
        settingsButton = ButtonNode(imageNamed: "settingsNormal")
        settingsButton.setup(atPosition: CGPoint(x: rightX, y: botY), withName: "Settings", normalTextureName: "settingsNormal", highlightedTextureName: "settingsHighlighted")
        settingsButton.position.x -= settingsButton.frame.width + 20
        
        self.addChild(playButton)
        self.addChild(scoresButton)
        self.addChild(tutorialButton)
        self.addChild(settingsButton)
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
        
        let backgroundGradient: SKSpriteNode = SKSpriteNode(texture: gradientTexture)
        backgroundGradient.zPosition = -100;
        backgroundGradient.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgroundGradient.color = UIColor.red
        backgroundGradient.colorBlendFactor = 0.0
        
        self.addChild(backgroundGradient)
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
        roundedBlock.position.y = 2.0 * self.size.height
        
        let waitAction: SKAction = SKAction.wait(forDuration: 8)
        let removeAction: SKAction = SKAction.removeFromParent()
        let sequenceAction: SKAction = SKAction.sequence([waitAction, removeAction])
        
        self.addChild(roundedBlock)
        roundedBlock.run(sequenceAction)
    }
    
    func initBlocks() {
        let minFallSpeed: Float = -280
        let maxFallSpeed: Float = -170
        let genAction: SKAction = SKAction.run { [unowned self] in
            self.generateRandomBlock(minFallSpeed, maxFallSpeed: maxFallSpeed)
        }
        let waitAction: SKAction = SKAction.wait(forDuration: 1.5, withRange: 0.5)
        let sequenceAction: SKAction = SKAction.sequence([genAction, waitAction])
        let repeatAction: SKAction = SKAction.repeatForever(sequenceAction)
        self.run(repeatAction)
    }
    
    
    //MARK: Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Play" {
                    playButton.didPress()
                    break
                }
                else if object.name == "Tutorial" {
                    tutorialButton.didPress()
                }
                else if object.name == "Settings" {
                    settingsButton.didPress()
                }
                else if object.name == "Menu" {
                    menuButton.didPress()
                }
                else if object.name == "Scores" && gameCenterIsAuthenticated {
                    scoresButton.didPress()
                    break
                } else if object.name == "AudioButton" {
                    if audioButtonLabel.isPressed {
                        audioButtonLabel.buttonNode.alpha = 1.0
                        audioButtonLabel.didRelease()
                    } else {
                        audioButtonLabel.buttonNode.alpha = 0.5
                        audioButtonLabel.didPress()
                    }
                    UserDefaults.standard.set(!audioButtonLabel.isPressed, forKey: "Audio")
                } else if object.name == "SoundEffects" {
                    if soundEffectsButtonLabel.isPressed {
                        soundEffectsButtonLabel.buttonNode.alpha = 1.0
                        soundEffectsButtonLabel.didRelease()
                    } else {
                        soundEffectsButtonLabel.buttonNode.alpha = 0.5
                        soundEffectsButtonLabel.didPress()
                    }
                    UserDefaults.standard.set(!soundEffectsButtonLabel.isPressed, forKey: "SoundEffects")
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Play" || object.name == "Scores" || object.name == "Tutorial" || object.name == "Settings" || object.name == "Menu" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            playButton.didRelease()
            scoresButton.didRelease()
            tutorialButton.didRelease()
            settingsButton.didRelease()
            menuButton.didRelease()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playButton.isPressed {
            playButton.didRelease()
            transitionToGame()
        } else if scoresButton.isPressed {
            scoresButton.didRelease()
            if gameCenterIsAuthenticated {
                postNotification(withName: "presentScores")
            }
        } else if tutorialButton.isPressed {
            tutorialButton.didRelease()
            transitionToTutorial()
        } else if settingsButton.isPressed {
            settingsButton.didRelease()
            displaySettings()
        } else if menuButton.isPressed {
            returnFromSettings()
            menuButton.didRelease()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        playButton.didRelease()
        scoresButton.didRelease()
        tutorialButton.didRelease()
        settingsButton.didRelease()
        menuButton.didRelease()
    }
}
