//
//  IAPHandler.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 2/25/18.
//  Copyright © 2018 LooseFuzz. All rights reserved.
//

import StoreKit
import UIKit

class IAPHandler: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    static let shared: IAPHandler = IAPHandler()
    var products: [SKProduct] = [SKProduct]()
    var productRequest: SKProductsRequest = SKProductsRequest()
    
    override init() {
        super.init()
        print("Initialized IAP Handler.")
        let productIdentifiers: NSSet = NSSet(objects: "RemoveAds")
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productRequest.delegate = self
        productRequest.start()
    }
    
    //MARK: SKPaymentTransactionObserver Methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: SKPaymentTransaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            case SKPaymentTransactionState.failed:
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            case SKPaymentTransactionState.restored:
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                break
            }
        }
        
    }
    
    //MARK: SKProductsRequestDelegate Methods
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        print("Received Product Request")
        for product in products {
            print(product.productIdentifier)
        }
    }
}
