//
//  ProViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 11/1/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import StoreKit

class ProViewController: UIViewController, SKPaymentTransactionObserver {

    @IBAction func purchaseSelected(_ sender: Any) {
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                print("Purchased")
                Items.sharedInstance.purchased = true
                UserDefaults.standard.set(true, forKey: "Purchased")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchased"), object: nil)
                self!.performSegue(withIdentifier: "unwindSettingsSegue", sender: self)
            }
        }
        
        label1.adjustsFontSizeToFitWidth = true
        label2.adjustsFontSizeToFitWidth = true
        label3.adjustsFontSizeToFitWidth = true
        
        SKPaymentQueue.default().add(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                print("Purchased purchase/restored")
                SKPaymentQueue.default().finishTransaction(transaction as SKPaymentTransaction)
                Items.sharedInstance.purchased = true
                UserDefaults.standard.set(true, forKey: "Purchased")
                
                let alertController = UIAlertController(title: "Restore Completed", message: "Your purchase of Awards Watchlist Pro has been restored", preferredStyle: UIAlertControllerStyle.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchased"), object: nil)
                    self.performSegue(withIdentifier: "unwindSettingsSegue", sender: self)
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
                break
            case .failed:
                print("Purchased Failed")
                SKPaymentQueue.default().finishTransaction(transaction as SKPaymentTransaction)
                break
            default:
                print("default")
                break
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
