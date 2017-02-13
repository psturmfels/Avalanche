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
    var achievementImage: UIImage = GKAchievementDescription.placeholderCompletedAchievementImage()
    
    var achievementTitleLabel: UILabel!
    var achievementDescriptionLabel: UILabel!
    
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
        
        self.contentView.addSubview(achievementImageView)
        self.contentView.addSubview(achievementTitleLabel)
        self.contentView.addSubview(achievementDescriptionLabel)
    }
    
    func updateCellUI() {
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
        
        achievementTitleLabel.text = achievement.title!
        achievementTitleLabel.sizeToFit()
        
        achievementDescriptionLabel.frame.size.width = whiteBackdrop.frame.width - 40.0
        achievementDescriptionLabel.frame.size.height = CGFloat.greatestFiniteMagnitude
        
        if achievementProgress == 100.0 {
            achievementDescriptionLabel.text = achievement.achievedDescription!
            achievementImageView.image = achievementImage
        } else {
            achievementDescriptionLabel.text = achievement.unachievedDescription!
            achievementImageView.image = GKAchievementDescription.incompleteAchievementImage()
        }
        
        achievementTitleLabel.frame.origin.x = achievementImageView.frame.origin.x + achievementImageView.frame.width + 20.0
        achievementTitleLabel.frame.origin.y = achievementImageView.frame.origin.y + achievementImageView.frame.height * 0.5 - achievementTitleLabel.frame.height * 0.5
        
        achievementDescriptionLabel.sizeToFit()
        achievementDescriptionLabel.frame.origin.y = achievementImageView.frame.height + 45.0
        achievementDescriptionLabel.frame.origin.x = 20.0
    }
    
    func wasSelected() {
        UIView.animate(withDuration: 0.3) {
            self.achievementImageView.frame.size = AchievementTableViewCell.expandedImageSize
            self.whiteBackdrop.frame.size.height += AchievementTableViewCell.expandedImageSize.height + self.achievementDescriptionLabel.frame.height + AchievementTableViewCell.excessHeight - AchievementTableViewCell.defaultHeight
            self.achievementDescriptionLabel.alpha = 1.0
            
            self.achievementTitleLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.achievementTitleLabel.frame.origin.x = self.achievementImageView.frame.origin.x + self.achievementImageView.frame.width + 20.0
            self.achievementTitleLabel.frame.origin.y = self.achievementImageView.frame.origin.y + self.achievementImageView.frame.height * 0.5 - self.achievementTitleLabel.frame.height * 0.5
        }
    }
    
    func wasDeselected() {
        UIView.animate(withDuration: 0.3) {
            self.achievementImageView.frame.size = AchievementTableViewCell.defaultImageSize
            self.whiteBackdrop.frame.size.height -= AchievementTableViewCell.expandedImageSize.height + self.achievementDescriptionLabel.frame.height + AchievementTableViewCell.excessHeight - AchievementTableViewCell.defaultHeight
            self.achievementDescriptionLabel.alpha = 0.0
            
            self.achievementTitleLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.achievementTitleLabel.frame.origin.x = self.achievementImageView.frame.origin.x + self.achievementImageView.frame.width + 20.0
            self.achievementTitleLabel.frame.origin.y = self.achievementImageView.frame.origin.y + self.achievementImageView.frame.height * 0.5 - self.achievementTitleLabel.frame.height * 0.5
        }
    }
}
