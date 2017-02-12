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
    static let titleFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 32.0)!
    static let descriptionFont: UIFont = UIFont(name: "AmericanTypewriter", size: 24.0)!
    
    
    var achievementImage: UIImageView!
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
        achievementImage = UIImageView()
        
        achievementTitleLabel = UILabel()
        achievementTitleLabel.font = AchievementTableViewCell.titleFont
        achievementTitleLabel.textColor = UIColor.black
        achievementTitleLabel.text = "Hello!"
        
        achievementDescriptionLabel = UILabel()
        achievementDescriptionLabel.font = AchievementTableViewCell.descriptionFont
        achievementDescriptionLabel.textColor = UIColor.gray
        
        achievementImage.frame.origin = CGPoint.zero
        achievementTitleLabel.frame.origin = self.frame.origin
        achievementDescriptionLabel.frame.origin = CGPoint.zero
        
        self.contentView.addSubview(achievementImage)
        self.contentView.addSubview(achievementTitleLabel)
        self.contentView.addSubview(achievementDescriptionLabel)
    }
    
    func updateCellUI() {
        guard let achievement = self.achievement else {
            return
        }
        
        achievementTitleLabel.text = achievement.title!
        achievementTitleLabel.sizeToFit()
        
        if achievementProgress == 100.0 {
            achievementDescriptionLabel.text = achievement.achievedDescription!
        } else {
            achievementDescriptionLabel.text = achievement.unachievedDescription!
        }
        achievementDescriptionLabel.sizeToFit()
    }
}
