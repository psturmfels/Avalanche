//
//  AchievementTableViewCell.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 2/12/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import GameKit
import UIKit

class AchievementTableViewCell: UITableViewCell {
    static let titleFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!
    static let descriptionFont: UIFont = UIFont(name: "AmericanTypewriter", size: 16.0)!
    static let defaultImageSize: CGSize = CGSize(width: 56.0, height: 56.0)
    static let expandedImageSize: CGSize = CGSize(width: 80.0, height: 80.0)
    static let defaultHeight: CGFloat = 80.0
    static var defaultWidth: CGFloat = 240.0
    static let excessHeight: CGFloat = 40.0
    static let coinSize: CGFloat = 15.0
    static let defaultAchievementImage: UIImage = UIImage(named: "placeholderAchievementImage")!
    
    class func expandedHeightNecessary(forDescription description: String) -> CGFloat {
        let descriptionLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: AchievementTableViewCell.defaultWidth, height: CGFloat.greatestFiniteMagnitude))
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionLabel.font = AchievementTableViewCell.descriptionFont
        descriptionLabel.text = description
        descriptionLabel.sizeToFit()
        
        return AchievementTableViewCell.expandedImageSize.height + descriptionLabel.frame.height + AchievementTableViewCell.excessHeight
    }
    
    var whiteBackdrop: UIView!
    var achievementImageView: UIImageView!
    var achievementImage: UIImage = AchievementTableViewCell.defaultAchievementImage
    
    var achievementTitleLabel: UILabel!
    var achievementDescriptionLabel: UILabel!
    var isExpanded: Bool = false
    
    var isNew: Bool = false
    var newLabel: UILabel!
    
    var coinImage: UIImageView!
    var coinLabel: UILabel!
    
    var achievementProgress: Double = 0.0
    
    var achievement: GKAchievementDescription? {
        didSet {
            updateCellUI()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createProperties()
    }
    
    func createProperties() {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        whiteBackdrop = UIView(frame: self.frame)
        whiteBackdrop.backgroundColor = UIColor.white
        whiteBackdrop.layer.cornerRadius = 10.0
        whiteBackdrop.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteBackdrop.layer.shadowOpacity = 0.2
        whiteBackdrop.layer.borderColor = UIColor.black.cgColor
        whiteBackdrop.layer.borderWidth = 2.0
        self.contentView.addSubview(whiteBackdrop)
        
        achievementImageView = UIImageView()
        
        achievementTitleLabel = UILabel()
        achievementTitleLabel.font = AchievementTableViewCell.titleFont
        achievementTitleLabel.textColor = UIColor.black
        achievementTitleLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        achievementTitleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        achievementTitleLabel.numberOfLines = 1
        
        achievementDescriptionLabel = UILabel()
        achievementDescriptionLabel.font = AchievementTableViewCell.descriptionFont
        achievementDescriptionLabel.textColor = UIColor.gray
        achievementDescriptionLabel.numberOfLines = 0
        achievementDescriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        achievementImageView.frame.origin = CGPoint(x: 12.0, y: 12.0)
        achievementImageView.layer.cornerRadius = 10.0
        achievementImageView.clipsToBounds = true
        achievementImageView.frame.size = AchievementTableViewCell.defaultImageSize
        
        achievementTitleLabel.frame.origin = CGPoint.zero
        achievementDescriptionLabel.frame.origin = CGPoint.zero
        achievementDescriptionLabel.alpha = 0.0
        
        coinLabel = UILabel()
        coinLabel.font = AchievementTableViewCell.descriptionFont
        coinLabel.textColor = UIColor.gray
        coinLabel.numberOfLines = 1
        coinLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        coinLabel.frame.origin = CGPoint.zero
        coinLabel.alpha = 0.0
        coinLabel.textAlignment = NSTextAlignment.right
        
        coinImage = UIImageView()
        coinImage.frame.origin = CGPoint.zero
        coinImage.frame.size.width = AchievementTableViewCell.coinSize
        coinImage.frame.size.height = AchievementTableViewCell.coinSize
        coinImage.image = UIImage(named: "coin")
        coinImage.clipsToBounds = true
        coinImage.alpha = 0.0
        
        newLabel = UILabel()
        newLabel.font = AchievementTableViewCell.descriptionFont
        newLabel.textColor = UIColor.red
        newLabel.numberOfLines = 1
        newLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        newLabel.alpha = 0.0
        newLabel.textAlignment = NSTextAlignment.right
        newLabel.text = "New!"
        newLabel.sizeToFit()
        newLabel.frame.origin = CGPoint.zero
        
        self.contentView.addSubview(achievementImageView)
        self.contentView.addSubview(achievementTitleLabel)
        self.contentView.addSubview(achievementDescriptionLabel)
        self.contentView.addSubview(coinLabel)
        self.contentView.addSubview(coinImage)
        self.contentView.addSubview(newLabel)
    }
    
    func updateCellUI() {
        self.frame.size.height = AchievementTableViewCell.defaultHeight
        
        guard let achievement = self.achievement else {
            return
        }
        
        whiteBackdrop.frame = self.frame
        whiteBackdrop.frame.size.width -= 20
        whiteBackdrop.frame.size.height -= 20
        whiteBackdrop.frame.origin.x = 10
        whiteBackdrop.frame.origin.y = 10
        
        if AchievementTableViewCell.defaultWidth != whiteBackdrop.frame.width - 40.0 {
            AchievementTableViewCell.defaultWidth = whiteBackdrop.frame.width - 40.0
        }
        
        if let title = achievement.title {
            if achievementProgress == 100.0 {
                achievementTitleLabel.text = title
            } else {
                achievementTitleLabel.text = "????????"
            }
        } else {
            achievementTitleLabel.text = "????????"
        }
        
        achievementTitleLabel.sizeToFit()
        
        achievementDescriptionLabel.frame.size.width = whiteBackdrop.frame.width - 40.0
        achievementDescriptionLabel.frame.size.height = CGFloat.greatestFiniteMagnitude
        
        if achievementProgress == 100.0 {
            if let achievedDescription = achievement.achievedDescription {
                achievementDescriptionLabel.text = achievedDescription
            } else {
                achievementDescriptionLabel.text = "This is a description for an achievement that has already been achieved by the local player."
            }
            achievementImageView.image = achievementImage
        } else {
            if let unachievedDescription = achievement.unachievedDescription {
                achievementDescriptionLabel.text = unachievedDescription
            } else {
                achievementDescriptionLabel.text = "This is a description for an achievement that has not yet been achieved by the local player."
            }
            achievementImageView.image = AchievementTableViewCell.defaultAchievementImage
        }
        
        achievementTitleLabel.frame.origin.x = achievementImageView.frame.origin.x + achievementImageView.frame.width + 20.0
        achievementTitleLabel.frame.origin.y = achievementImageView.frame.origin.y + achievementImageView.frame.height * 0.5 - achievementTitleLabel.frame.height * 0.5
        
        achievementDescriptionLabel.sizeToFit()
        achievementDescriptionLabel.frame.origin.y = AchievementTableViewCell.defaultImageSize.height + 45.0
        achievementDescriptionLabel.frame.origin.x = 20.0
        
        
        coinLabel.text = "+50"
        if let identifier = achievement.identifier {
            if let type = Achievement(rawValue: identifier) {
                let coinsEarned: Int = Achievement.getAchievementReward(type: type)
                coinLabel.text = "+\(coinsEarned)"
                
                isNew = GameKitController.achievementIsNew(achievementType: type)
            }
        }
        coinLabel.sizeToFit()
        
        coinImage.frame.origin.y = 18.0
        coinImage.frame.origin.x = whiteBackdrop.frame.size.width - coinImage.frame.size.width
        
        coinLabel.frame.origin.y = 17.0
        coinLabel.frame.origin.x = coinImage.frame.origin.x - coinLabel.frame.width - 3.0
        
        if achievementProgress == 100.0 {
            coinLabel.alpha = 1.0
            coinImage.alpha = 1.0
        } else {
            coinLabel.alpha = 0.0
            coinImage.alpha = 0.0
        }
        
        if isNew {
            applyNew()
        } else {
            removeNew(animateWithDuration: 0.0)
        }
        
        if isExpanded {
            self.wasSelected(animateWithDuration: 0.0)
        } else {
            self.wasDeselected(animateWithDuration: 0.0)
        }
    }
    
    func applyNew() {
        self.whiteBackdrop.layer.shadowColor = UIColor.orange.cgColor
        self.whiteBackdrop.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.whiteBackdrop.layer.shadowRadius = 5.0
        self.whiteBackdrop.layer.shadowOpacity = 1.0
        self.newLabel.alpha = 1.0
        self.newLabel.frame.origin.x = whiteBackdrop.frame.size.width - newLabel.frame.size.width + 2.0
        self.newLabel.frame.origin.y = 34.0
    }
    
    func removeNew(animateWithDuration duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration) { 
            self.whiteBackdrop.layer.shadowOpacity = 0.0
            self.newLabel.alpha = 0.0
        }
    }
    
    func wasSelected(animateWithDuration duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration) {
            if let text = self.achievementTitleLabel.text, text.characters.count > 10 {
                self.achievementTitleLabel.numberOfLines = 2
            } else {
                self.achievementTitleLabel.numberOfLines = 1
            }
            self.achievementTitleLabel.frame.size.width = self.whiteBackdrop.frame.width - AchievementTableViewCell.defaultImageSize.width - 120.0
            self.achievementTitleLabel.sizeToFit()
            
            self.achievementImageView.frame.size = AchievementTableViewCell.expandedImageSize
            self.whiteBackdrop.frame.size.height = AchievementTableViewCell.expandedImageSize.height + self.achievementDescriptionLabel.frame.height + AchievementTableViewCell.excessHeight - 20
            self.achievementDescriptionLabel.alpha = 1.0
            
            self.achievementTitleLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.achievementTitleLabel.frame.origin.x = self.achievementImageView.frame.origin.x + self.achievementImageView.frame.width + 20.0
            self.achievementTitleLabel.frame.origin.y = self.achievementImageView.frame.origin.y + self.achievementImageView.frame.height * 0.5 - self.achievementTitleLabel.frame.height * 0.5
        }
    }
    
    func wasDeselected(animateWithDuration duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration) {
            self.achievementTitleLabel.numberOfLines = 1
            self.achievementTitleLabel.frame.size.width = self.whiteBackdrop.frame.width - AchievementTableViewCell.defaultImageSize.width
            self.achievementTitleLabel.sizeToFit()
            
            self.achievementImageView.frame.size = AchievementTableViewCell.defaultImageSize
            self.whiteBackdrop.frame.size.height = AchievementTableViewCell.defaultHeight - 20
            self.achievementDescriptionLabel.alpha = 0.0
            
            self.achievementTitleLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.achievementTitleLabel.frame.origin.x = self.achievementImageView.frame.origin.x + self.achievementImageView.frame.width + 20.0
            self.achievementTitleLabel.frame.origin.y = self.achievementImageView.frame.origin.y + self.achievementImageView.frame.height * 0.5 - self.achievementTitleLabel.frame.height * 0.5
        }
    }
    
    
}
