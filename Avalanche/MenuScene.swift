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
    //MARK: Static Action Properties
    static let downShudder1: SKAction = SKAction.moveBy(x: 0.0, y: -20.0, duration: 0.08)
    static let downShudder2: SKAction = SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.08)
    static let downShudder3: SKAction = SKAction.moveBy(x: 0.0, y: -5.0, duration: 0.08)
    
    static let upShudder1: SKAction = SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.07)
    static let upShudder2: SKAction = SKAction.moveBy(x: 0.0, y: 10.0, duration: 0.07)
    static let upShudder3: SKAction = SKAction.moveBy(x: 0.0, y: 5.0, duration: 0.07)
    
    static let leftShudder1: SKAction = SKAction.moveBy(x: -20.0, y: 0.0, duration: 0.07)
    static let leftShudder2: SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.07)
    static let leftShudder3: SKAction = SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.07)
    
    static let rightShudder1: SKAction = SKAction.moveBy(x: 20.0, y: 0.0, duration: 0.07)
    static let rightShudder2: SKAction = SKAction.moveBy(x: 10.0, y: 0.0, duration: 0.07)
    static let rightShudder3: SKAction = SKAction.moveBy(x: 5.0, y: 0.0, duration: 0.07)
    
    static let waitPointFour: SKAction = SKAction.wait(forDuration: 0.4)
    
    //MARK: Buttons and Labels
    var settingsNode: SKNode!
    var menuNode: SKNode!
    var bottomMenuNode: SKNode!
    var scoreNode: SKNode!
    
    var playButton: ButtonLabelNode!
    var scoresButton: ButtonLabelNode!
    var arcadeButton: ButtonLabelNode!
    var tutorialButton: ButtonNode!
    var settingsButton: ButtonNode!
    
    var storeButton: ButtonNode?
    
    var restorePurchasesLabel: ButtonLabelNode!
    var audioButtonLabel: ButtonLabelNode!
    var soundEffectsButtonLabel: ButtonLabelNode!
    var menuButton: ButtonNode!
    
    var classicLeaderboardButton: ButtonNode!
    var arcadeLeaderboardButton: ButtonNode!
    var leaderboardButton: ButtonNode!
    var achievementButton: ButtonNode!
    var leaderboardTable: UITableView!
    var achievementTable: UITableView!
    var bestDisplayNode: SKShapeNode!
    var bestLabelNode: LabelNode!
    var bestDateNode: LabelNode!
    weak var achievementTableHandler: AchievementTableViewHandler!
    weak var leaderboardTableHandler: LeaderboardTableViewHandler!
    
    var titleLabel: LabelNode!
    var settingsLabel: LabelNode!
    
    var gameCenterIsAuthenticated: Bool = false {
        didSet {
            if gameCenterIsAuthenticated {
                scoresButton.alpha = 1.0
            } else {
                scoresButton.alpha = 0.5
            }
        }
    }
    
    var currentState: MenuStates = MenuStates.menu
    
    //MARK: Button Methods
    func menuButtonPressed() {
        switch currentState {
        case MenuStates.settings:
            returnFromSettings()
        case MenuStates.scores:
            returnFromScore()
        default:
            break
        }
        currentState = MenuStates.menu
    }
    
    func dismissMenu() {
        let upSweep: SKAction = SKAction.moveBy(x: 0.0, y: self.frame.height, duration: 0.2)
        
        let moveUpSequence: SKAction = SKAction.sequence([MenuScene.downShudder1, MenuScene.downShudder2, MenuScene.downShudder3, upSweep])
        
        playButton.buttonNode.name = ""
        arcadeButton.buttonNode.name = ""
        scoresButton.buttonNode.name = ""
        
        menuNode.run(moveUpSequence)
        
        let rightSweep: SKAction = SKAction.moveBy(x: self.frame.width, y: 0.0, duration: 0.2)
        let moveRightSequence: SKAction = SKAction.sequence([MenuScene.leftShudder1, MenuScene.leftShudder2, MenuScene.leftShudder3, rightSweep])
        
        tutorialButton.name = ""
        settingsButton.name = ""
        if let storeButton = storeButton {
            storeButton.name = ""
        }
        
        bottomMenuNode.run(moveRightSequence)
    }
    
    func returnMenu() {
        let downSweep: SKAction = SKAction.moveBy(x: 0.0, y: -self.frame.height, duration: 0.2)
        
        let moveDownSequence: SKAction = SKAction.sequence([MenuScene.waitPointFour, downSweep, MenuScene.upShudder1, MenuScene.upShudder2, MenuScene.upShudder3])
        menuNode.run(moveDownSequence) { [unowned self] in
            self.playButton.buttonNode.name = "Play"
            self.arcadeButton.buttonNode.name = "Arcade"
            self.scoresButton.buttonNode.name = "Scores"
        }
        
        let leftSweep: SKAction = SKAction.moveBy(x: -self.frame.width, y: 0.0, duration: 0.2)
        let moveLeftSequence: SKAction = SKAction.sequence([MenuScene.waitPointFour, leftSweep, MenuScene.rightShudder1, MenuScene.rightShudder2, MenuScene.rightShudder3])
        
        bottomMenuNode.run(moveLeftSequence) { [unowned self] in
            self.tutorialButton.name = "Tutorial"
            self.settingsButton.name = "Settings"
            if let storeButton = self.storeButton {
                storeButton.name = "Store"
            }
        }
    }
    
    func displayBackToMenu() {
        let extraRightSweep: SKAction = SKAction.moveBy(x: self.frame.width + 35, y: 0.0, duration: 0.2)
        let reverseRightSequence: SKAction = SKAction.sequence([MenuScene.waitPointFour, extraRightSweep, MenuScene.leftShudder1, MenuScene.leftShudder2, MenuScene.leftShudder3])
        menuButton.run(reverseRightSequence) { [unowned self] in
            self.menuButton.name = "Menu"
        }
    }
    
    func dismissBackToMenu() {
        menuButton.name = ""
        let extraLeftSweep: SKAction = SKAction.moveBy(x: -self.frame.width - 35.0, y: 0.0, duration: 0.2)
        let reverseLeftSequence: SKAction = SKAction.sequence([MenuScene.rightShudder1, MenuScene.rightShudder2, MenuScene.rightShudder3, extraLeftSweep])
        menuButton.run(reverseLeftSequence)
    }
    
    func displayReverseBackToMenu() {
        let rightX: CGFloat = 2.0 * self.frame.width - menuButton.frame.width * 0.5 - 20.0
        menuButton.position.x = rightX
        let extraLeftSweep: SKAction = SKAction.moveBy(x: -self.frame.width - 35.0, y: 0.0, duration: 0.2)
        let reverseLeftSequence: SKAction = SKAction.sequence([MenuScene.waitPointFour, extraLeftSweep, MenuScene.rightShudder1, MenuScene.rightShudder2, MenuScene.rightShudder3, ])
        menuButton.run(reverseLeftSequence) { [unowned self] in
            self.menuButton.name = "Menu"
        }
    }
    
    func dismissReverseBackToMenu() {
        menuButton.name = ""
        let extraRightSweep: SKAction = SKAction.moveBy(x: self.frame.width + 35, y: 0.0, duration: 0.2)
        let reverseRightSequence: SKAction = SKAction.sequence([MenuScene.leftShudder1, MenuScene.leftShudder2, MenuScene.leftShudder3, extraRightSweep])
        let leftX: CGFloat = 20.0 + menuButton.frame.width * 0.5 - self.frame.width
        menuButton.run(reverseRightSequence) { [unowned self] in
            self.menuButton.position.x = leftX
        }
    }
    
    func displayScores() {
        currentState = MenuStates.scores
        dismissMenu()
        displayBackToMenu()
        
        let extraRightSweep: SKAction = SKAction.moveBy(x: self.frame.width + 35, y: 0.0, duration: 0.2)
        let reverseRightSequence: SKAction = SKAction.sequence([MenuScene.waitPointFour, extraRightSweep, MenuScene.leftShudder1, MenuScene.leftShudder2, MenuScene.leftShudder3])
        
        scoreNode.run(reverseRightSequence) { [unowned self] in
            self.achievementButton.name = "Achievement"
            self.leaderboardButton.name = "Leaderboard"
            self.arcadeLeaderboardButton.name = "ArcadeLeaderboard"
            self.classicLeaderboardButton.name = "ClassicLeaderboard"
        }
        
        animateRight(table: leaderboardTable)
        animateRight(table: achievementTable)
        leaderboardTable.reloadData()
        achievementTable.reloadData()
    }
    
    func animateRight(table tableView: UITableView) {

        UITableView.animate(withDuration: 0.2, delay: 0.4, options: [], animations: {
            tableView.frame.origin.x += self.frame.width + 35
        }) { (_) in
            UITableView.animate(withDuration: 0.07, animations: {
                tableView.frame.origin.x -= 20
            }, completion: { (_) in
                UITableView.animate(withDuration: 0.07, animations: {
                    tableView.frame.origin.x -= 10
                }, completion: { (_) in
                    UITableView.animate(withDuration: 0.07, animations: {
                        tableView.frame.origin.x -= 5
                    })
                })
            })
        }
    }
    
    func animateLeft(table tableView: UITableView) {
        UITableView.animate(withDuration: 0.07, animations: {
            tableView.frame.origin.x += 20
        }) { (_) in
            UITableView.animate(withDuration: 0.07, animations: {
                tableView.frame.origin.x += 10
            }, completion: { (_) in
                UITableView.animate(withDuration: 0.07, animations: {
                    tableView.frame.origin.x += 5
                }, completion: { (_) in
                    UITableView.animate(withDuration: 0.2, animations: {
                        tableView.frame.origin.x -= self.frame.width + 35
                    }, completion: { (_) in
                        if tableView == self.achievementTable {
                            GameKitController.achievementTableHandler.expandedPath = nil
                            AchievementTableViewHandler.deselectAllAchievements(self.achievementTable, false)
                        } else if tableView == self.leaderboardTable {
                            GameKitController.leaderboardTableHandler.expandedPath = nil
                            LeaderboardTableViewHandler.deselectAllAScores(self.leaderboardTable, false)
                        }
                    })
                })
            })
        }
    }

    
    func returnFromScore() {
        achievementButton.name = ""
        leaderboardButton.name = ""
        arcadeLeaderboardButton.name = ""
        classicLeaderboardButton.name = ""
        let extraLeftSweep: SKAction = SKAction.moveBy(x: -self.frame.width - 35.0, y: 0.0, duration: 0.2)
        let reverseLeftSequence: SKAction = SKAction.sequence([MenuScene.rightShudder1, MenuScene.rightShudder2, MenuScene.rightShudder3, extraLeftSweep])
        scoreNode.run(reverseLeftSequence)
        
        animateLeft(table: leaderboardTable)
        animateLeft(table: achievementTable)
        
        dismissBackToMenu()
        returnMenu()
    }
    
    func displaySettings() {
        currentState = MenuStates.settings
        dismissMenu()
        displayBackToMenu()
        
        let leftSweep: SKAction = SKAction.moveBy(x: -self.frame.width - 35.0, y: 0.0, duration: 0.2)
        let moveLeftSequence: SKAction = SKAction.sequence([MenuScene.waitPointFour, leftSweep, MenuScene.rightShudder1, MenuScene.rightShudder2, MenuScene.rightShudder3])
        
        settingsNode.run(moveLeftSequence) { [unowned self] in
            self.audioButtonLabel.buttonNode.name = "AudioButton"
            self.soundEffectsButtonLabel.buttonNode.name = "SoundEffects"
            self.restorePurchasesLabel.buttonNode.name = "RestorePurchases"
        }
    }
    
    func returnFromSettings() {
        let rightSweep: SKAction = SKAction.moveBy(x: self.frame.width + 35.0, y: 0.0, duration: 0.2)
        let moveRightSequence: SKAction = SKAction.sequence([MenuScene.leftShudder1, MenuScene.leftShudder2, MenuScene.leftShudder3, rightSweep])
        audioButtonLabel.buttonNode.name = ""
        soundEffectsButtonLabel.buttonNode.name = ""
        restorePurchasesLabel.buttonNode.name = ""
        
        settingsNode.run(moveRightSequence)
        
        dismissBackToMenu()
        returnMenu()
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
    
    func transitionToArcade() {
        guard self.scene != nil && self.scene?.view != nil else {
            abort();
        }
        
        //Load the Game Scene
        let gameScene: ArcadeModeScene = ArcadeModeScene(fileNamed: "GameScene")!
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
        NotificationCenter.default.addObserver(self, selector: #selector(MenuScene.removePurchaseButton), name: NSNotification.Name(rawValue: "removePurchaseButton"), object: nil)
        
        GameKitController.authenticateLocalPlayer()
        StoreKitController.fetchAvailableProducts()
        
        createContainerNodes()
        createScoreButtons()
        createScoreTables()
        createSettingsButtons()
        createMenuButtons()
        createBackground()
        createTitleLabel()
        createSettingsLabel()
        initBlocks()
    }
    
    //MARK: GameKit Methods
    @objc func authenticationStatusDidChange(notification: Notification) {
        if let dictionary = notification.userInfo as? [String: Bool] {
            if let newAuthenticationStatus = dictionary["isAuthenticated"] {
                gameCenterIsAuthenticated = newAuthenticationStatus
            }
        }
    }
    
    @objc func removePurchaseButton() {
        if let storeButton = storeButton {
             storeButton.removeFromParent()
        }
        storeButton = nil
    }
    
    //MARK: Creation Methods
    func createContainerNodes() {
        settingsNode = SKNode()
        menuNode = SKNode()
        bottomMenuNode = SKNode()
        scoreNode = SKNode()
        
        settingsNode.position = CGPoint.zero
        menuNode.position = CGPoint.zero
        bottomMenuNode.position = CGPoint.zero
        scoreNode.position = CGPoint.zero
        
        self.addChild(settingsNode)
        self.addChild(menuNode)
        self.addChild(bottomMenuNode)
        self.addChild(scoreNode)
    }
    
    func createSettingsLabel() {
        let settingsPoint: CGPoint = CGPoint(x: 3 * self.frame.midX, y: self.frame.height * 0.7)
        settingsLabel = LabelNode()
        settingsLabel.setup(withText: "Settings", withFontSize: 48.0, atPosition: settingsPoint)
        self.settingsNode.addChild(settingsLabel)
    }
    
    func createTitleLabel() {
        let titlePoint: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.height * 0.7)
        titleLabel = LabelNode()
        titleLabel.setup(withText: "Avalanche", withFontSize: 48.0, atPosition: titlePoint)
        self.menuNode.addChild(titleLabel)
    }
    
    func createScoreTables() {
        let achievementHeight: CGFloat = self.frame.height - leaderboardButton.frame.height - 60
        let leaderboardHeight: CGFloat = self.frame.height - leaderboardButton.frame.height - arcadeLeaderboardButton.frame.height - 80
        let rightPoint: CGFloat = 20.0 - self.frame.width
            
        leaderboardTable = UITableView(frame: self.frame, style: UITableViewStyle.plain)
        leaderboardTable.frame.size.width = self.frame.width - 40
        leaderboardTable.frame.size.height = leaderboardHeight - 60
        leaderboardTable.frame.origin = CGPoint(x: rightPoint, y: leaderboardButton.frame.height + arcadeLeaderboardButton.frame.height + 120)
        leaderboardTable.isHidden = true
        leaderboardTable.separatorStyle = UITableViewCellSeparatorStyle.none
        leaderboardTable.backgroundColor = UIColor.clear
        
        achievementTable = UITableView(frame: self.frame, style: UITableViewStyle.plain)
        achievementTable.frame.size.width = self.frame.width - 40
        achievementTable.frame.size.height = achievementHeight
        achievementTable.frame.origin = CGPoint(x: rightPoint, y: leaderboardButton.frame.height + 40)
        achievementTable.separatorStyle = UITableViewCellSeparatorStyle.none
        achievementTable.backgroundColor = UIColor.clear
        
        self.view!.addSubview(leaderboardTable)
        self.view!.addSubview(achievementTable)
        
        achievementTableHandler = GameKitController.achievementTableHandler
        achievementTableHandler.setDelegateAndSource(forTable: achievementTable)
        achievementTable.register(AchievementTableViewCell.self, forCellReuseIdentifier: "AchievementTableViewCell")
        
        leaderboardTableHandler = GameKitController.leaderboardTableHandler
        leaderboardTableHandler.setDelegateAndSource(forTable: leaderboardTable)
        leaderboardTable.register(LeaderboardTableViewCell.self, forCellReuseIdentifier: "LeaderboardTableViewCell")
        
        GameKitController.currentLeaderboard = LeaderboardTypes.classic.rawValue
        leaderboardTable.reloadData()
    }
    
    func createScoreButtons() {
        leaderboardButton = ButtonNode(imageNamed: "leaderboardNormal")
        achievementButton = ButtonNode(imageNamed: "achievementNormal")
        
        let rightX: CGFloat = -20.0 - leaderboardButton.frame.width * 0.5
        let topY: CGFloat = self.frame.height - leaderboardButton.frame.height * 0.5 - 20
        
        leaderboardButton.setup(atPosition: CGPoint(x: rightX, y: topY), withName: "", normalTextureName: "leaderboardNormal", highlightedTextureName: "leaderboardNormal")
        achievementButton.setup(atPosition: CGPoint(x: rightX, y: topY), withName: "", normalTextureName: "achievementNormal", highlightedTextureName: "achievementNormal")
        
        achievementButton.position.x -= achievementButton.frame.width + 20
        
        leaderboardButton.alpha = 0.5
        leaderboardButton.didRelease()
        
        achievementButton.didPress()
        
        self.scoreNode.addChild(leaderboardButton)
        self.scoreNode.addChild(achievementButton)
        
        arcadeLeaderboardButton = ButtonNode(imageNamed: "arcadeLeaderboard")
        classicLeaderboardButton = ButtonNode(imageNamed: "classicLeaderboard")
        
        let midX: CGFloat = -self.frame.width * 0.5
        let newRightX: CGFloat = midX + arcadeLeaderboardButton.frame.width * 0.5 + 10
        let newLeftX: CGFloat = midX - classicLeaderboardButton.frame.width * 0.5 - 10
        let halfLeaderboardHeight: CGFloat = arcadeLeaderboardButton.frame.height * 0.5
        let halfButtonHeight: CGFloat = leaderboardButton.frame.height * 0.5
        let newTopY: CGFloat = topY - halfButtonHeight - halfLeaderboardHeight - 20
        
        let arcadeLeaderboardButtonPos: CGPoint = CGPoint(x: newRightX, y: newTopY)
        let classicLeaderboardButtonPos: CGPoint = CGPoint(x: newLeftX, y: newTopY)
        
        arcadeLeaderboardButton.setup(atPosition: arcadeLeaderboardButtonPos, withName: "", normalTextureName: "arcadeLeaderboard", highlightedTextureName: "arcadeLeaderboard")
        classicLeaderboardButton.setup(atPosition: classicLeaderboardButtonPos, withName: "", normalTextureName: "classicLeaderboard", highlightedTextureName: "classicLeaderboard")
        
        arcadeLeaderboardButton.alpha = 0.5
        arcadeLeaderboardButton.didRelease()
        
        classicLeaderboardButton.didPress()
        
        arcadeLeaderboardButton.isHidden = true
        classicLeaderboardButton.isHidden = true
        
        self.scoreNode.addChild(arcadeLeaderboardButton)
        self.scoreNode.addChild(classicLeaderboardButton)
        
        
        bestDisplayNode = SKShapeNode(rectOf: CGSize(width: self.frame.width - 40, height: 60), cornerRadius: 8.0)
        bestDisplayNode.fillColor = UIColor.white
        bestDisplayNode.strokeColor = UIColor.black
        bestDisplayNode.lineWidth = 1.75
        bestDisplayNode.isHidden = true
        bestDisplayNode.position = CGPoint(x: midX, y: newTopY - 72)
        
        bestLabelNode = LabelNode()
        let (bestScore, bestDate): (Int, Date) = GameKitController.getBestScoreAndDate(arcade: false)
        let labelText: String = "Your Best: \(bestScore) ft"
        let labelPoint: CGPoint = CGPoint(x: 0.0, y: -5.0)
        bestLabelNode.setup(withText: labelText, withFontSize: 24.0, atPosition: labelPoint)
        bestLabelNode.fontColor = UIColor.black
        bestLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.bottom
        bestLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        
        bestDateNode = LabelNode()
        let datePoint: CGPoint = CGPoint(x: 0.0, y: -10.0)
        let dateText: String = DateFormatter.localizedString(from: bestDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
        bestDateNode.setup(withText: dateText, withFontSize: 14.0, atPosition: datePoint)
        bestDateNode.fontColor = UIColor.lightGray
        bestDateNode.fontName = "AmericanTypewriter"
        bestDateNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        bestDateNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        
        self.bestDisplayNode.addChild(bestLabelNode)
        self.bestDisplayNode.addChild(bestDateNode)
        self.scoreNode.addChild(bestDisplayNode)
    }
    
    func createSettingsButtons() {
        let center: CGPoint = CGPoint(x: 3 * self.frame.midX, y: self.frame.midY)
        audioButtonLabel = ButtonLabelNode()
        audioButtonLabel.setup(withText: "Music: ", withFontSize: 48.0, withButtonName: "", normalTextureName: "audioNormal", highlightedTextureName: "audioOff", atPosition: center)
        audioButtonLabel.position.y += audioButtonLabel.height * 0.5 + 10
        self.settingsNode.addChild(audioButtonLabel)
        
        soundEffectsButtonLabel = ButtonLabelNode()
        soundEffectsButtonLabel.setup(withText: "Sound: ", withFontSize: 48.0, withButtonName: "", normalTextureName: "audioNormal", highlightedTextureName: "audioOff", atPosition: center)
        soundEffectsButtonLabel.position.y -= soundEffectsButtonLabel.height * 0.5 + 10
        self.settingsNode.addChild(soundEffectsButtonLabel)
        
        restorePurchasesLabel = ButtonLabelNode()
        restorePurchasesLabel.setup(withText: "Restore:", withFontSize: 48.0, withButtonName: "", normalTextureName: "storeNormal", highlightedTextureName: "storeHighlighted", atPosition: center)
        let offset: CGFloat = soundEffectsButtonLabel.height + 20
        restorePurchasesLabel.position.y = soundEffectsButtonLabel.position.y - offset
        self.settingsNode.addChild(restorePurchasesLabel)
        
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
        
        arcadeButton = ButtonLabelNode()
        arcadeButton.setup(withText: "Arcade: ", withFontSize: 48.0, withButtonName: "Arcade", normalTextureName: "playMenuNormal", highlightedTextureName: "playMenuHighlighted", atPosition: center)
        arcadeButton.position.y -= arcadeButton.height * 0.5 + 10
        
        scoresButton = ButtonLabelNode()
        scoresButton.setup(withText: "Scores: ", withFontSize: 48.0, withButtonName: "Scores", normalTextureName: "scoresNormal", highlightedTextureName: "scoresHighlighted", atPosition: center)
        scoresButton.position.y -= 3.0 * (scoresButton.height * 0.5 + 10)
        scoresButton.alpha = 0.5
        
        tutorialButton = ButtonNode(imageNamed: "tutorialNormal")
        let rightX: CGFloat = self.frame.width - tutorialButton.frame.width * 0.5 - 20
        let botY: CGFloat = tutorialButton.frame.height * 0.5 + 20
        let botRightCorner: CGPoint = CGPoint(x: rightX, y: botY)
        tutorialButton.setup(atPosition: botRightCorner, withName: "Tutorial", normalTextureName: "tutorialNormal", highlightedTextureName: "tutorialHighlighted")
        
        settingsButton = ButtonNode(imageNamed: "settingsNormal")
        settingsButton.setup(atPosition: botRightCorner, withName: "Settings", normalTextureName: "settingsNormal", highlightedTextureName: "settingsHighlighted")
        settingsButton.position.x -= settingsButton.frame.width + 20
        
        if !StoreKitController.getPurchaseStatus(ofType: Purchase.RemoveAds) {
            storeButton = ButtonNode(imageNamed: "noAdsNormal")
            storeButton!.setup(atPosition: botRightCorner, withName: "Store", normalTextureName: "noAdsNormal", highlightedTextureName: "noAdsHighlighted")
            storeButton!.position.x -= settingsButton.frame.width + 20
            storeButton!.position.x -= storeButton!.frame.width + 20
            self.bottomMenuNode.addChild(storeButton!)
        }
        
        self.menuNode.addChild(playButton)
        self.menuNode.addChild(arcadeButton)
        self.menuNode.addChild(scoresButton)
        self.bottomMenuNode.addChild(tutorialButton)
        self.bottomMenuNode.addChild(settingsButton)
        
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
                } else if object.name == "Arcade" {
                    arcadeButton.didPress()
                } else if object.name == "Tutorial" {
                    tutorialButton.didPress()
                } else if object.name == "Settings" {
                    settingsButton.didPress()
                } else if object.name == "Menu" {
                    menuButton.didPress()
                } else if object.name == "Scores" && gameCenterIsAuthenticated {
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
                } else if object.name == "RestorePurchases" {
                    restorePurchasesLabel.didPress()
                    break
                } else if object.name == "Achievement" {
                    achievementButton.didPress()
                    achievementButton.alpha = 1.0
                    achievementTable.reloadData()
                    achievementTable.isHidden = false
                    
                    leaderboardButton.didRelease()
                    leaderboardButton.alpha = 0.5
                    leaderboardTable.isHidden = true
                    leaderboardTableHandler.expandedPath = nil
                    
                    arcadeLeaderboardButton.isHidden = true
                    classicLeaderboardButton.isHidden = true
                    bestDisplayNode.isHidden = true
                } else if object.name == "Leaderboard" {
                    achievementButton.didRelease()
                    achievementButton.alpha = 0.5
                    achievementTable.isHidden = true
                    achievementTableHandler.expandedPath = nil
                    
                    leaderboardButton.didPress()
                    leaderboardButton.alpha = 1.0
                    leaderboardTable.reloadData()
                    leaderboardTable.isHidden = false
                    
                    arcadeLeaderboardButton.isHidden = false
                    classicLeaderboardButton.isHidden = false
                    bestDisplayNode.isHidden = false
                } else if object.name == "ArcadeLeaderboard" {
                    classicLeaderboardButton.didRelease()
                    classicLeaderboardButton.alpha = 0.5
                    
                    arcadeLeaderboardButton.didPress()
                    arcadeLeaderboardButton.alpha = 1.0
                    
                    GameKitController.currentLeaderboard = LeaderboardTypes.arcade.rawValue
                    leaderboardTableHandler.expandedPath = nil
                    leaderboardTable.reloadData()
                    
                    let (bestScore, bestDate): (Int, Date) = GameKitController.getBestScoreAndDate(arcade: true)
                    let labelText: String = "Your Best: \(bestScore) ft"
                    bestLabelNode.text = labelText
                    let dateText: String = DateFormatter.localizedString(from: bestDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
                    bestDateNode.text = dateText
                } else if object.name == "ClassicLeaderboard" {
                    classicLeaderboardButton.didPress()
                    classicLeaderboardButton.alpha = 1.0
                    
                    arcadeLeaderboardButton.didRelease()
                    arcadeLeaderboardButton.alpha = 0.5
                    
                    GameKitController.currentLeaderboard = LeaderboardTypes.classic.rawValue
                    leaderboardTableHandler.expandedPath = nil
                    leaderboardTable.reloadData()
                    
                    let (bestScore, bestDate): (Int, Date) = GameKitController.getBestScoreAndDate(arcade: false)
                    let labelText: String = "Your Best: \(bestScore) ft"
                    bestLabelNode.text = labelText
                    let dateText: String = DateFormatter.localizedString(from: bestDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
                    bestDateNode.text = dateText
                } else if object.name == "Store" {
                    if let storeButton = storeButton {
                        storeButton.didPress()
                    }
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
                if object.name == "Play" || object.name == "Arcade" || object.name == "Scores" || object.name == "Tutorial" || object.name == "Settings" || object.name == "Menu" || object.name == "Store" || object.name == "RestorePurchases" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            playButton.didRelease()
            arcadeButton.didRelease()
            scoresButton.didRelease()
            tutorialButton.didRelease()
            settingsButton.didRelease()
            menuButton.didRelease()
            restorePurchasesLabel.didRelease()
            if let storeButton = storeButton {
                storeButton.didRelease()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playButton.isPressed {
            playButton.didRelease(didActivate: true)
            transitionToGame()
        } else if arcadeButton.isPressed {
            arcadeButton.didRelease(didActivate: true)
            transitionToArcade()
        } else if scoresButton.isPressed {
            scoresButton.didRelease(didActivate: true)
            if gameCenterIsAuthenticated {
                //postNotification(withName: "presentScores")
                displayScores()
            }
        } else if tutorialButton.isPressed {
            tutorialButton.didRelease(didActivate: true)
            transitionToTutorial()
        } else if settingsButton.isPressed {
            settingsButton.didRelease(didActivate: true)
            displaySettings()
        } else if menuButton.isPressed {
            menuButton.didRelease(didActivate: true)
            menuButtonPressed()
        } else if restorePurchasesLabel.isPressed {
            restorePurchasesLabel.didRelease(didActivate: true)
            StoreKitController.restoreInAppPurchases()
        } else if let storeButton = storeButton {
            if storeButton.isPressed {
                storeButton.didRelease(didActivate: true)
                StoreKitController.buyRemoveAds()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        playButton.didRelease()
        arcadeButton.didRelease()
        scoresButton.didRelease()
        tutorialButton.didRelease()
        settingsButton.didRelease()
        menuButton.didRelease()
        restorePurchasesLabel.didRelease()
        if let storeButton = storeButton {
            storeButton.didRelease()
        }
    }
}
