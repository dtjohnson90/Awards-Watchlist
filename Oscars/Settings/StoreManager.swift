//
//  StoreManager.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/29/19.
//  Copyright © 2019 Dustin Johnson. All rights reserved.
//

import Foundation
import StoreKit


class StoreManager: NSObject{
    
    
    
    /**
     Initialize StoreManager and load subscriptions SKProducts from Store
     */
    static let shared = StoreManager()
    
    func Begin(){
        print("StoreManager initialized")
    }
    
    
    override init() {
        super.init()
        
        
        // Add pyament observer to payment qu
        SKPaymentQueue.default().add(self)
        
        
    }
    
    
    func requestProductWithID(identifers:Set<String>){
        
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                identifers)
            request.delegate = self
            request.start()
            
            
        } else {
            print("ERROR: Store Not Available")
        }
        
        
    }
    
    func buyProduct(product: SKProduct) {
        
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        
    }
    
    
    func restorePurchases(){
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    /*
     Instance variables
     
     */
    
}








// MARK:
// MARK: SKProductsRequestDelegate

//The delegate receives the product information that the request was interested in.
extension StoreManager:SKProductsRequestDelegate{
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var products = response.products as [SKProduct]
        
        
        var buys = [SKProduct]()
        
        if (products.count > 0) {
            
            for i in 0 ..< products.count
            {
                let product = products[i]
                
                
                print("Product Found: ",product.localizedTitle)
            }
            
            
        } else {
            print("No products found")
        }
        
        let productsInvalidIds = response.invalidProductIdentifiers
        
        for product in productsInvalidIds
        {
            print("Product not found: \(product)")
        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Something went wrong: \(error.localizedDescription)")
    }
}



// MARK:
// MARK: SKTransactions


extension StoreManager: SKPaymentTransactionObserver {
    
    
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction: transaction)
                break
            case .failed:
                failedTransaction(transaction: transaction)
                break
            case .restored:
                restoreTransaction(transaction: transaction)
                break
            case .deferred:
                // TODO show user that is waiting for approval
                
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        
        print("completeTransaction...")
        
        deliverPurchaseForIdentifier(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        
        
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restoreTransaction... \(productIdentifier)")
        
        
        deliverPurchaseForIdentifier(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        
        if let error = transaction.error as NSError? {
            if error.domain == SKErrorDomain {
                // handle all possible errors
                switch (error.code) {
                case SKError.unknown.rawValue:
                    print("Unknown error")
                    
                case SKError.clientInvalid.rawValue:
                    print("client is not allowed to issue the request")
                    
                    
                case SKError.paymentCancelled.rawValue:
                    print("user cancelled the request")
                    
                case SKError.paymentInvalid.rawValue:
                    print("purchase identifier was invalid")
                    
                case SKError.paymentNotAllowed.rawValue:
                    print("this device is not allowed to make the payment")
                    
                default:
                    break;
                }
            }
            
            
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseForIdentifier(identifier: String?) {
        
        guard let identifier = identifier else { return }
        
        
    }
}



//In-App Purchases App Store
extension StoreManager{
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
        
        //To hold
        //return false
        
        //And then to continue
        //SKPaymentQueue.default().add(savedPayment)
    }
    
}
