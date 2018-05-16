//
//  IAPHandler.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 5/4/18.
//  Copyright © 2018 LooseFuzz. All rights reserved.
//

import StoreKit

class IAPHandler: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    
    let productID: String = "RemoveAds"
    var productRequest: SKProductsRequest = SKProductsRequest()
    var removeAdsProduct: SKProduct = SKProduct()
    var foundAdsProduct: Bool = false
    var purchaseUponFind: Bool = false
    
    func fetchAvailableProducts() {
        guard !foundAdsProduct else {
            return
        }
        
        let productIdentifiers = NSSet(objects: productID)
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func purchaseRemoveAds() {
        postNotification(withName: "displayActivityView")
        
        guard SKPaymentQueue.canMakePayments() else {
            postNotification(withName: "dismissActivityView")
            displayDismissAlert(withTitle: "Error", andMessage: "It appears your account is not authorized to make payments. Please use a different account to make store purchases.")
            return
        }
        
        guard foundAdsProduct else {
            purchaseUponFind = true
            fetchAvailableProducts()
            return
        }
        
        let payment: SKPayment = SKPayment(product: removeAdsProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        postNotification(withName: "displayActivityView")
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MARK: SKPaymentTransactionObserver
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        postNotification(withName: "dismissActivityView")
        if !StoreKitController.getPurchaseStatus(ofType: Purchase.RemoveAds) {
            displayDismissAlert(withTitle: "Error", andMessage: "No previous purchases found.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        postNotification(withName: "dismissActivityView")
        displayDismissAlert(withTitle: "Error", andMessage: "Unable to restore purchases. Please check your connection and try again.")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.deferred:
                print("Payment for \(transaction.payment.productIdentifier) deferred...")
                break
                
            case SKPaymentTransactionState.failed:
                if let error = transaction.error {
                    print("Payment for \(transaction.payment.productIdentifier) failed with error \(error)")
                } else {
                    print("Payment for \(transaction.payment.productIdentifier) failed with unspecified error")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            
            case SKPaymentTransactionState.purchased:
                postNotification(withName: "removePurchaseButton")
                StoreKitController.setPurchaseStatus(ofType: Purchase.RemoveAds, newStatus: true)
                print("Payment for transaction \(transaction.payment.productIdentifier) completed")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
                
            case SKPaymentTransactionState.purchasing:
                print("Payment for transaction \(transaction.payment.productIdentifier) is being purchased...")
                break
            
            case SKPaymentTransactionState.restored:
                StoreKitController.setPurchaseStatus(ofType: Purchase.RemoveAds, newStatus: true)
                print("Payment for transaction \(transaction.payment.productIdentifier) was restored")
                SKPaymentQueue.default().finishTransaction(transaction)
                postNotification(withName: "removePurchaseButton")
                postNotification(withName: "dismissActivityView")
                displayDismissAlert(withTitle: "Success", andMessage: "Your purchase removing advertisements has been restored.")
                break
            }
        }
    }
    
    //MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var foundProduct: Bool = false
        if response.products.count == 1 {
            if let prod = response.products.first {
                removeAdsProduct = prod
                foundAdsProduct = true
                if SKPaymentQueue.canMakePayments() {
                    postNotification(withName: "purchaseStatusDidChange", andUserInfo: ["canMakePurchases": true])
                    foundProduct = true
                    if purchaseUponFind {
                        purchaseUponFind = false
                        purchaseRemoveAds()
                    }
                }
            }
        }
        if !foundProduct {
            postNotification(withName: "purchaseStatusDidChange", andUserInfo: ["canMakePurchases": false])
        }
    }
}
