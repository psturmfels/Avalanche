//
//  StoreTableViewCell.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 8/14/17.
//  Copyright © 2017 LooseFuzz. All rights reserved.
//


import UIKit

class StoreTableViewCell: UITableViewCell {
    static let titleFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 30.0)!
    static let descriptionFont: UIFont = UIFont(name: "AmericanTypewriter", size: 16.0)!
    static let defaultImageSize: CGSize = CGSize(width: 56.0, height: 56.0)
    static let defaultHeight: CGFloat = 80.0
    static var defaultWidth: CGFloat = 240.0
    static let excessHeight: CGFloat = 40.0
    
    class func expandedHeightNecessary(forDescription description: String) -> CGFloat {
        return 100.0
    }
    
    var isDollarCost: Bool = true
    var coinsCost: Int = 3000
    var dollarCost: Double = 0.99
    var purchaseTitle: String = ""
    var purchaseDescription: String = ""
    
    var whiteBackdrop: UIView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var coinImage: UIImageView!
    var costLabel: UILabel!
    var buyButton: UIButton!
    
    
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
    }
    
    func updateCellUI() {
        self.frame.size.height = StoreTableViewCell.defaultHeight
        
        whiteBackdrop.frame = self.frame
        whiteBackdrop.frame.size.width -= 20
        whiteBackdrop.frame.size.height -= 20
        whiteBackdrop.frame.origin.x = 10
        whiteBackdrop.frame.origin.y = 10
        
        if StoreTableViewCell.defaultWidth != whiteBackdrop.frame.width - 40.0 {
            StoreTableViewCell.defaultWidth = whiteBackdrop.frame.width - 40.0
        }
    }
}

