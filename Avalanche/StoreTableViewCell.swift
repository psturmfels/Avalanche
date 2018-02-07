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
    static let defaultImageSize: CGSize = CGSize(width: 214.0, height: 221.0)
    static let defaultHeight: CGFloat = 260.0
    static var defaultWidth: CGFloat = 240.0
    static let excessHeight: CGFloat = 40.0
    
    var whiteBackdrop: UIView!
    var itemImage: UIImageView!
    var purchaseButton: UIButton!
    var purchaseType: Purchase? {
        didSet {
            if let _ = purchaseType {
                updateCellUI()
            }
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
        
        createPurchaseButton()
        createItemImage()
    }
    
    //MARK: Rotation Method
    private func rotate(_ view: UIView, byAngle angle: CGFloat = -CGFloat.pi * 0.5) {
        let oldFrame: CGRect = view.frame
        view.transform = CGAffineTransform(rotationAngle: angle)
        view.frame = oldFrame
    }
    
    //MARK: Creation Methods
    func createItemImage() {
        itemImage = UIImageView()
        itemImage.clipsToBounds = true
        itemImage.frame.size = StoreTableViewCell.defaultImageSize
        itemImage.frame.origin = CGPoint(x: 20.0, y: 20.0)
        rotate(itemImage)
        
        self.contentView.addSubview(itemImage)
    }
    
    func updateItemImage() {
        guard let purchaseType = purchaseType else {
            return
        }
        let image: UIImage = Purchase.getImage(ofPurchase: purchaseType)
        itemImage.image = image
    }
    
    func updatePurchaseImage() {
        guard let purchaseType = purchaseType else {
            return
        }
        let wasPurchased: Bool = StoreKitController.getPurchaseStatus(ofType: purchaseType)
        if wasPurchased {
            guard let purchasedNormalImage: UIImage = UIImage(named: "purchasedNormal") else {
                return
            }
            purchaseButton.setImage(purchasedNormalImage, for: UIControlState.normal)
            purchaseButton.setImage(purchasedNormalImage, for: UIControlState.highlighted)
            purchaseButton.alpha = 0.5
        } else {
            guard let purchaseNormalImage: UIImage = UIImage(named: "purchaseNormal") else {
                return
            }
            guard let purchaseHighlightedImage: UIImage = UIImage(named: "purchaseHighlighted") else {
                return
            }
            
            purchaseButton.setImage(purchaseNormalImage, for: UIControlState.normal)
            purchaseButton.setImage(purchaseHighlightedImage, for: UIControlState.highlighted)
            
            switch purchaseType {
            case .JetPack, .Teleport, .Shrink, .DayTime, .DoubleRandom, .Rewind, .PowerBeGone:
                let arcadeWasPurchased: Bool = StoreKitController.getPurchaseStatus(ofType: Purchase.ArcadeMode)
                if !arcadeWasPurchased {
                    purchaseButton.alpha = 0.5
                } else {
                    purchaseButton.alpha = 1.0
                }
            default:
                purchaseButton.alpha = 1.0
            }
        }
    }
    
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
        purchaseButton.frame.origin = CGPoint(x: 245.0, y: 22.0)
        purchaseButton.frame.size = StoreTableViewCell.defaultPurchaseButtonSize
        purchaseButton.addTarget(self, action: #selector(StoreTableViewCell.purchaseButtonPressed), for: UIControlEvents.touchUpInside)
        rotate(purchaseButton)
        
        self.contentView.addSubview(purchaseButton)
    }
    
    //MARK: Button Methods
    @objc func purchaseButtonPressed() {
        if let type = purchaseType {
            let hasBeenPurchased: Bool = StoreKitController.getPurchaseStatus(ofType: type)
            guard !hasBeenPurchased else {
                return
            }
            
            switch type {
            case .JetPack, .Teleport, .Shrink, .DayTime, .DoubleRandom, .Rewind, .PowerBeGone:
                let arcadeWasPurchased: Bool = StoreKitController.getPurchaseStatus(ofType: Purchase.ArcadeMode)
                if !arcadeWasPurchased {
                    let title: String = "Need Arcade Mode"
                    let message: String = "You need to unlock Arcade Mode before buying any power-ups. Unlocked power-ups will appear in Arcade Mode!"
                    displayDismissAlert(withTitle: title, andMessage: message)
                    return
                }
            default:
                break
            }
            
            switch type {
            case .JetPack, .Teleport, .Shrink, .DayTime, .DoubleRandom, .Rewind, .PowerBeGone, .ArcadeMode:
                let numCoins: Int = StoreKitController.getNumCoins()
                if numCoins < StoreKitController.defaultCoinCost {
                    let title: String = "Insufficient Funds"
                    let message: String = "You need at least 2500 coins to unlock this option. Get more coins by playing the game, unlocking achievements, or buying some here in the store."
                    displayDismissAlert(withTitle: title, andMessage: message)
                    return
                }
                
                displayBuyCancelAlert(withtitle: "Confirm Purchase", andMessage: "Do you want to purchase '\(Purchase.readableName(ofPurchase: type))' for 2500 coins?", andType: type)
                updatePurchaseImage()
                
            case .StashOCoins, .PileOCoins, .TreasureChest, .RemoveAds, .SupportTheDev:
                break
            }
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
        
        updateItemImage()
        updatePurchaseImage()
    }
}

