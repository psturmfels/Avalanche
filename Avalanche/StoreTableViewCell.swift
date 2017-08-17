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
    static let defaultPurchaseButtonSize: CGSize = CGSize(width: 64.0, height: 216.0)
    static let defaultHeight: CGFloat = 260.0
    static var defaultWidth: CGFloat = 240.0
    static let excessHeight: CGFloat = 40.0
    
    class func expandedHeightNecessary(forDescription description: String) -> CGFloat {
        return StoreTableViewCell.defaultHeight
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
    var purchaseButton: UIButton!
    var indexPath: IndexPath? = nil
    
    
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
        
        createPurchaseButton()
    }
    
    //MARK: Rotation Method
    private func rotate(_ view: UIView, byAngle angle: CGFloat = -CGFloat.pi * 0.5) {
        let oldFrame: CGRect = view.frame
        view.transform = CGAffineTransform(rotationAngle: angle)
        view.frame = oldFrame
    }
    
    //MARK: Creation Methods
    func createPurchaseButton() {
        purchaseButton = UIButton()
        guard let purchaseNormalImage: UIImage = UIImage(named: "purchaseNormal") else {
            return
        }
        guard let purchaseHighlightedImage: UIImage = UIImage(named: "purchaseHighlighted") else {
            return
        }
        
        purchaseButton.setImage(purchaseNormalImage, for: UIControlState.normal)
        purchaseButton.setImage(purchaseHighlightedImage, for: UIControlState.highlighted)
        purchaseButton.setImage(purchaseHighlightedImage, for: UIControlState.focused)
        purchaseButton.frame.origin = CGPoint(x: 315.0, y: 22.0)
        purchaseButton.frame.size = StoreTableViewCell.defaultPurchaseButtonSize
        purchaseButton.addTarget(self, action: #selector(StoreTableViewCell.purchaseButtonPressed), for: UIControlEvents.touchUpInside)
        rotate(purchaseButton)
        
        self.contentView.addSubview(purchaseButton)
    }
    
    //MARK: Button Methods
    func purchaseButtonPressed() {
        if let indexPath = self.indexPath {
            print("Button pressed at indexPath: \(indexPath)")
        }
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

