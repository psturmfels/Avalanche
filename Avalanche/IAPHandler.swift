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
        
        guard foundAdsProduct else {
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        let payment: SKPayment = SKPayment(product: removeAdsProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MARK: SKPaymentTransactionObserver
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
                StoreKitController.setPurchaseStatus(ofType: Purchase.RemoveAds, newStatus: true)
                print("Payment for transaction \(transaction.payment.productIdentifier) completed")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
                
            case SKPaymentTransactionState.purchasing:
                print("Payment for transaction \(transaction.payment.productIdentifier) is being purchased...")
                break
            
            case SKPaymentTransactionState.restored:
                print("Payment for transaction \(transaction.payment.productIdentifier) was restored")
                SKPaymentQueue.default().finishTransaction(transaction)
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
                }
            }
        }
        if !foundProduct {
            postNotification(withName: "purchaseStatusDidChange", andUserInfo: ["canMakePurchases": false])
        }
    }
}
