//
//  ProViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 11/1/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class ProViewController: UIViewController {

    @IBAction func purchaseSelected(_ sender: Any) {
        //AwardsWatchlistProducts.store.buyProduct(products[0])
        SwiftyStoreKit.purchaseProduct("AWPRO", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        //AwardsWatchlistProducts.store.restorePurchases()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    var products: [SKProduct] = []
    
    //@available(iOS 11.0, *)
    //optional public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(ProViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name:NSNotification.Name(rawValue: "purchaseFailed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreSuccesfull), name:NSNotification.Name(rawValue: "restoreSuccesfull"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreFailed), name:NSNotification.Name(rawValue: "restoreFailed"), object: nil)
        
        AwardsWatchlistProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
            } else {
                print("No Products Found")
            }
        }
        
        SwiftyStoreKit.retrieveProductsInfo(["AWPRO"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            // return true if the content can be delivered by your app
            // return false otherwise
            print("This is a payment handler")
            return true
        }
        
        label1.adjustsFontSizeToFitWidth = true
        label2.adjustsFontSizeToFitWidth = true
        label3.adjustsFontSizeToFitWidth = true
        
        //SKPaymentQueue.default().add(self)
    }
    
    /*
    @available(iOS 11.0, *)
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            // return true if the content can be delivered by your app
            // return false otherwise
            return true
        }
    }*/
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        Items.sharedInstance.purchased = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchased"), object: nil)
        self.performSegue(withIdentifier: "unwindSettingsSegue", sender: self)
    }
    
    @objc func purchaseFailed() {
        let alertController = UIAlertController(title: "Error", message: "There was a problem with this purchase. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
        
        
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func restoreSuccesfull() {
        let alertController = UIAlertController(title: "Restore Completed", message: "Your purchase of Awards Watchlist Pro has been restored", preferredStyle: UIAlertController.Style.alert)
        
        
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            Items.sharedInstance.purchased = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchased"), object: nil)
            //self.performSegue(withIdentifier: "unwindSettingsSegue", sender: self)
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func restoreFailed() {
        let alertController = UIAlertController(title: "Error", message: "You have not purchased this product. Unable to Restore.", preferredStyle: UIAlertController.Style.alert)
        
        
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logError(logString: String, logError: String = "") {
        if logError == "" {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                try logError.appendLine(to: url as URL)
                //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
        }
    }
}
