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
    static let excessHeight: CGFloat = 70.0
    static let scoreUserPadding: CGFloat = 10.0
    static let leftScoreMargin: CGFloat = 10.0
    static let rightUserPadding: CGFloat = 30.0
    static let scoreLabelWidth: CGFloat = 80.0
    
    class func expandedHeightNecessary(forUser user: String, andScore scoreString: String) -> CGFloat {
        let dummyScoreLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: LeaderboardTableViewCell.scoreLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        dummyScoreLabel.numberOfLines = 0
        dummyScoreLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        dummyScoreLabel.font = LeaderboardTableViewCell.scoreFont
        dummyScoreLabel.text = scoreString
        dummyScoreLabel.sizeToFit()
        
        let userLabelWidth: CGFloat = LeaderboardTableViewCell.defaultWidth - LeaderboardTableViewCell.leftScoreMargin - LeaderboardTableViewCell.scoreUserPadding - dummyScoreLabel.frame.width - LeaderboardTableViewCell.rightUserPadding
        let dummyUserLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: userLabelWidth , height: CGFloat.greatestFiniteMagnitude))
        dummyUserLabel.numberOfLines = 0
        dummyUserLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        dummyUserLabel.font = LeaderboardTableViewCell.userFont
        dummyUserLabel.text = user
        dummyUserLabel.sizeToFit()
        
        return max(dummyScoreLabel.frame.height + 40.0, dummyUserLabel.frame.height + LeaderboardTableViewCell.excessHeight)
    }
    
    var whiteBackdrop: UIView!
    var userLabel: UILabel!
    var dateLabel: UILabel!
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
        
        dateLabel = UILabel()
        dateLabel.font = LeaderboardTableViewCell.dateFont
        dateLabel.textColor = UIColor.gray
        dateLabel.numberOfLines = 1
        dateLabel.lineBreakMode = NSLineBreakMode.byClipping
        dateLabel.alpha = 0.0
        
        self.contentView.addSubview(userLabel)
        self.contentView.addSubview(scoreLabel)
        self.contentView.addSubview(dateLabel)
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
        
        if LeaderboardTableViewCell.defaultWidth != whiteBackdrop.frame.width {
            LeaderboardTableViewCell.defaultWidth = whiteBackdrop.frame.width
        }
        
        if let scoreText = score.formattedValue {
            scoreLabel.text = scoreText
        } else {
            scoreLabel.text = "\(score.value)"
        }
        
        if let userName = score.player?.alias {
            userLabel.text = userName
        } else {
            userLabel.text = "ThisIsAUserWithAnObnoxiouslyLongName"
        }
        
        dateLabel.text = DateFormatter.localizedString(from: score.date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
        
        scoreLabel.numberOfLines = 1
        userLabel.sizeToFit()
        scoreLabel.sizeToFit()
        dateLabel.sizeToFit()
        
        scoreLabel.frame.origin.x = whiteBackdrop.frame.origin.x + LeaderboardTableViewCell.leftScoreMargin
        scoreLabel.frame.origin.y = whiteBackdrop.frame.origin.y + whiteBackdrop.frame.height * 0.5 - scoreLabel.frame.height * 0.5
        userLabel.frame.origin.x = scoreLabel.frame.origin.x + LeaderboardTableViewCell.scoreLabelWidth + LeaderboardTableViewCell.scoreUserPadding
        userLabel.frame.origin.y = whiteBackdrop.frame.origin.y + whiteBackdrop.frame.height * 0.5 - userLabel.frame.height * 0.5
        dateLabel.frame.origin.x = userLabel.frame.origin.x
        dateLabel.frame.origin.y = userLabel.frame.origin.y + userLabel.frame.height + 10.0
        
        if isExpanded {
            self.wasSelected(animateWithDuration: 0.0)
        } else {
            self.wasDeselected(animateWithDuration: 0.0)
        }
    }
    
    func wasSelected(animateWithDuration duration: Float = 0.2) {
        let prevScoreY: CGFloat = self.whiteBackdrop.frame.origin.y + self.whiteBackdrop.frame.height * 0.5 - self.scoreLabel.frame.height * 0.5
        self.scoreLabel.numberOfLines = 0
        self.scoreLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.scoreLabel.frame.size.height = CGFloat.greatestFiniteMagnitude
        self.scoreLabel.frame.size.width = LeaderboardTableViewCell.scoreLabelWidth
        self.scoreLabel.sizeToFit()
        self.scoreLabel.frame.origin.y = prevScoreY
        
        let prevUserY: CGFloat = self.whiteBackdrop.frame.origin.y + self.whiteBackdrop.frame.height * 0.5 - self.userLabel.frame.height * 0.5
        self.userLabel.numberOfLines = 0
        self.userLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.userLabel.frame.size.height = CGFloat.greatestFiniteMagnitude
        let userLabelWidth: CGFloat = LeaderboardTableViewCell.defaultWidth - LeaderboardTableViewCell.leftScoreMargin - LeaderboardTableViewCell.scoreUserPadding - scoreLabel.frame.width - LeaderboardTableViewCell.rightUserPadding
        self.userLabel.frame.size.width = userLabelWidth
        self.userLabel.sizeToFit()
        self.userLabel.frame.origin.y = prevUserY
        
        guard let score = self.score else {
            return
        }
        
        var scoreString: String = "\(score.value)"
        if let unwrappedScoreFormatted = score.formattedValue {
            scoreString = unwrappedScoreFormatted
        }
        
        guard let alias = score.player?.alias else {
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.whiteBackdrop.frame.size.height = LeaderboardTableViewCell.expandedHeightNecessary(forUser: "ThisIsAUserWithAnObnoxiouslyLongName", andScore: scoreString) - 20
                self.dateLabel.frame.origin.y = self.userLabel.frame.origin.y + self.userLabel.frame.height + 10.0
                self.dateLabel.alpha = 1.0
            }
            return
        }
        
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.whiteBackdrop.frame.size.height = LeaderboardTableViewCell.expandedHeightNecessary(forUser: alias, andScore: scoreString) - 20
            self.dateLabel.frame.origin.y = self.userLabel.frame.origin.y + self.userLabel.frame.height + 10.0
            self.dateLabel.alpha = 1.0
        }
    }
    
    func wasDeselected(animateWithDuration duration: Float = 0.2) {
        self.scoreLabel.numberOfLines = 1
        self.scoreLabel.sizeToFit()
        self.scoreLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.scoreLabel.frame.size.width = LeaderboardTableViewCell.scoreLabelWidth
        
        self.userLabel.numberOfLines = 1
        self.userLabel.sizeToFit()
        self.userLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        let userLabelWidth: CGFloat = LeaderboardTableViewCell.defaultWidth - LeaderboardTableViewCell.leftScoreMargin - LeaderboardTableViewCell.scoreUserPadding - scoreLabel.frame.width - LeaderboardTableViewCell.rightUserPadding
        self.userLabel.frame.size.width = userLabelWidth
        
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.whiteBackdrop.frame.size.height = LeaderboardTableViewCell.defaultHeight - 20
            self.userLabel.frame.origin.y = self.whiteBackdrop.frame.origin.y + self.whiteBackdrop.frame.height * 0.5 - self.userLabel.frame.height * 0.5
            self.dateLabel.alpha = 0.0
        }
        
    }
}
