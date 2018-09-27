//
//  TutorialLoadViewController.swift
//  
//
//  Created by Dustin Johnson on 1/24/18.
//

import UIKit

class TutorialLoadViewController: UIViewController {
    
    var checkTimer2: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Test 1")
        checkTimer2 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TutorialLoadViewController.repeatCheck),userInfo: nil, repeats: true)
        print("Test 2")
    }
    override func viewDidAppear(_ animated: Bool) {
        print("TEst3")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func repeatCheck() {
        print("Test")
        for item in Items.sharedInstance.testArray {
            print(item)
            if item == true {
                return
            }
        }
        performSegue(withIdentifier: "loadingDoneSegue", sender: self)
        checkTimer2.invalidate()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
