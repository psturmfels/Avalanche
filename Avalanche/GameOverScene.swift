//
//  GameOverScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    var replayButton: ButtonLabelNode!
    var menuButton: ButtonLabelNode!
    var highScore: Int!
    var highScoreLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var gameType: GameType = GameType.Classic
    
    var coinLabel: LabelNode!
    var coinImage: SKSpriteNode!
    
    //MARK: Initializing Methods
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        replayButton = ButtonLabelNode()
        menuButton = ButtonLabelNode()
        
        let center: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let centerButtons: CGPoint = CGPoint(x: center.x, y: center.y - 75.0)
        
        replayButton.setup(withText: "Replay: ", withFontSize: 48.0, withButtonName: "Replay", normalTextureName: "replayNormal", highlightedTextureName: "replayHighlighted", atPosition: centerButtons)
        replayButton.position.y += replayButton.height * 0.5 + 10
        
        menuButton.setup(withText: "Menu: ", withFontSize: 48.0, withButtonName: "Menu", normalTextureName: "menuNormal", highlightedTextureName: "menuHighlighted", atPosition: centerButtons)
        menuButton.position.y -= menuButton.height * 0.5 + 10
        
        highScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        highScoreLabel.fontSize = 64.0
        highScoreLabel.text = "\(highScore!) ft"
        highScoreLabel.position = center
        highScoreLabel.position.y += replayButton.height + highScoreLabel.frame.height
        
        scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        scoreLabel.fontSize = 64.0
        scoreLabel.text = "Score:"
        scoreLabel.position = highScoreLabel.position
        scoreLabel.position.y += scoreLabel.frame.height + highScoreLabel.frame.height * 0.5
        
        let coinSize: CGFloat = 44.0
        coinImage = SKSpriteNode(imageNamed: "coin")
        coinImage.size.width = coinSize
        coinImage.size.height = coinSize
        let coinImageX: CGFloat = center.x + coinSize * 0.5 + 5.0
        let coinY: CGFloat = highScoreLabel.position.y - highScoreLabel.frame.height * 0.5 - 20.0
        coinImage.position = CGPoint(x: coinImageX, y: coinY)
        
        coinLabel = LabelNode()
        coinLabel.horizontalAlignmentMode = .right
        let coinLabelX: CGFloat = center.x - 5.0
        let numCoinsEarned: Int = 1 + highScore / 100
        StoreKitController.addCoins(numCoinsEarned)
        let coinLabelPos: CGPoint = CGPoint(x: coinLabelX, y: coinY)
        coinLabel.setup(withText: "+\(numCoinsEarned)", withFontSize: 48.0, atPosition: coinLabelPos)
        coinLabel.position.y -= coinLabel.frame.height * 0.5
        
        let leftCoinLabel: CGFloat = coinLabel.position.x - coinLabel.frame.width
        let rightCoinImage: CGFloat = coinImage.position.x + coinImage.frame.width * 0.5
        let centerCoin: CGFloat = 0.5 * leftCoinLabel + 0.5 * rightCoinImage
        let offsetFromTrueCenter: CGFloat = center.x - centerCoin
        coinLabel.position.x += offsetFromTrueCenter
        coinImage.position.x += offsetFromTrueCenter
        
        self.addChild(coinImage)
        self.addChild(coinLabel)
        self.addChild(replayButton)
        self.addChild(menuButton)
        self.addChild(highScoreLabel)
        self.addChild(scoreLabel)
        
        switch gameType {
        case GameType.Arcade:
            GameKitController.report(highScore, toLeaderboard: .arcade)
        case GameType.Classic:
            GameKitController.report(highScore, toLeaderboard: .classic)
        }
        
        reportScoreAchievements()
        GameKitController.madeProgressTowardsAchievement(achievementType: Achievement.Committed)
    }
    
    //MARK: Achievements
    func reportScoreAchievements() {
        if highScore == 777 {
            GameKitController.report(Achievement.Jackpot, withPercentComplete: 100.0)
        }
        
        guard gameType == .Classic else {
            return
        }
        
        if highScore <= 14 {
            GameKitController.report(Achievement.Clueless, withPercentComplete: 100.0)
        }
        if highScore >= 200 {
            GameKitController.report(Achievement.Beginner, withPercentComplete: 100.0)
        }
        if highScore >= 400 {
            GameKitController.report(Achievement.Moderate, withPercentComplete: 100.0)
        }
        if highScore >= 600 {
            GameKitController.report(Achievement.Advanced, withPercentComplete: 100.0)
        }
        if highScore >= 800 {
            GameKitController.report(Achievement.Pro, withPercentComplete: 100.0)
        }
        if highScore >= 1000 {
            GameKitController.report(Achievement.Legendary, withPercentComplete: 100.0)
        }
    }
    
    //MARK: Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Replay" {
                    replayButton.didPress()
                    break
                }
                else if object.name == "Menu" {
                    menuButton.didPress()
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if replayButton.isPressed {
            replayButton.didRelease(didActivate: true)
            transitionToReplay()
        }
        else if menuButton.isPressed {
            menuButton.didRelease(didActivate: true)
            transitionToMenu()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Replay" || object.name == "Menu" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            replayButton.didRelease()
            menuButton.didRelease()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        replayButton.didRelease()
        menuButton.didRelease()
    }
    
    //MARK: Transition Methods
    func transitionToMenu() {
        let menuScene: MenuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(menuScene, transition: transition)
    }
    
    func transitionToReplay() {
        switch gameType {
        case .Classic:
            let gameScene: ClassicModeScene = ClassicModeScene(fileNamed: "GameScene")!
            gameScene.size = self.size
            let transition = SKTransition.crossFade(withDuration: 0.5)
            gameScene.scaleMode = .resizeFill
            self.scene!.view!.presentScene(gameScene, transition: transition)
        case .Arcade:
            let gameScene: ArcadeModeScene = ArcadeModeScene(fileNamed: "GameScene")!
            gameScene.size = self.size
            let transition = SKTransition.crossFade(withDuration: 0.5)
            gameScene.scaleMode = .resizeFill
            self.scene!.view!.presentScene(gameScene, transition: transition)
        }
    }
}

