//
//  LeaderboardTableViewCell.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 2/26/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//

import GameKit
import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    static let scoreFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!
    static let userFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 24.0)!
    static let dateFont: UIFont = UIFont(name: "AmericanTypewriter", size: 14.0)!
    static let defaultHeight: CGFloat = 80.0
    static var defaultWidth: CGFloat = 240.0
    static let excessHeight: CGFloat = 100.0
    
    class func expandedHeightNecessary(forUser user: String) -> CGFloat {
        let userLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: LeaderboardTableViewCell.defaultWidth, height: CGFloat.greatestFiniteMagnitude))
        userLabel.numberOfLines = 0
        userLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        userLabel.font = LeaderboardTableViewCell.userFont
        userLabel.text = user
        userLabel.sizeToFit()
        
        return userLabel.frame.height + LeaderboardTableViewCell.excessHeight
    }
    
    var whiteBackdrop: UIView!
    var userLabel: UILabel!
    var dateLabel: UILabel!
    var rankLabel: UILabel!
    var scoreLabel: UILabel!
    var isExpanded: Bool = false
    
    var score: GKScore? {
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
        
        userLabel = UILabel()
        userLabel.font = LeaderboardTableViewCell.userFont
        userLabel.textColor = UIColor.black
        userLabel.numberOfLines = 1
        userLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        scoreLabel = UILabel()
        scoreLabel.font = LeaderboardTableViewCell.scoreFont
        scoreLabel.textColor = UIColor.black
        scoreLabel.numberOfLines = 1
        scoreLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        self.contentView.addSubview(userLabel)
        self.contentView.addSubview(scoreLabel)
    }
    
    func updateCellUI() {
        self.frame.size.height = LeaderboardTableViewCell.defaultHeight
        
        guard let score = self.score else {
            return
        }
        whiteBackdrop.frame = self.frame
        whiteBackdrop.frame.size.width -= 20
        whiteBackdrop.frame.size.height -= 20
        whiteBackdrop.frame.origin.x = 10
        whiteBackdrop.frame.origin.y = 10
        
        if LeaderboardTableViewCell.defaultWidth != whiteBackdrop.frame.width - 60.0 {
            LeaderboardTableViewCell.defaultWidth = whiteBackdrop.frame.width - 60.0
        }
        
        if let scoreText = score.formattedValue {
            scoreLabel.text = scoreText
        } else {
            scoreLabel.text = "\(score.value)"
        }
        
        if let userName = score.player?.alias {
            userLabel.text = userName
        } else {
            userLabel.text = "Anonymous"
        }
        
        scoreLabel.sizeToFit()
        userLabel.sizeToFit()
        
        scoreLabel.frame.origin.x = whiteBackdrop.frame.origin.x + 20
        scoreLabel.frame.origin.y = whiteBackdrop.frame.origin.y + whiteBackdrop.frame.height * 0.5 - scoreLabel.frame.height * 0.5
        userLabel.frame.origin.x = scoreLabel.frame.origin.x + scoreLabel.frame.width
        userLabel.frame.origin.y = whiteBackdrop.frame.origin.y + whiteBackdrop.frame.height * 0.5 - userLabel.frame.height * 0.5
        
        if isExpanded {
            self.wasSelected(animateWithDuration: 0.0)
        } else {
            self.wasDeselected(animateWithDuration: 0.0)
        }
    }
    
    func wasSelected(animateWithDuration duration: Float = 0.2) {
        let previousYPoint: CGFloat = self.userLabel.frame.origin.y
        self.userLabel.numberOfLines = 0
        self.userLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.userLabel.frame.size.width = LeaderboardTableViewCell.defaultWidth
        self.userLabel.frame.size.height = CGFloat.greatestFiniteMagnitude
        self.userLabel.sizeToFit()
        self.userLabel.frame.origin.y = previousYPoint
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.whiteBackdrop.frame.size.height = self.userLabel.frame.height + LeaderboardTableViewCell.excessHeight - 20
        }
    }
    
    func wasDeselected(animateWithDuration duration: Float = 0.2) {
        let previousYPoint: CGFloat = self.userLabel.frame.origin.y
        self.userLabel.numberOfLines = 1
        self.userLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.userLabel.sizeToFit()
        self.userLabel.frame.origin.y = previousYPoint
        
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.whiteBackdrop.frame.size.height = LeaderboardTableViewCell.defaultHeight - 20
        }
    }
}
