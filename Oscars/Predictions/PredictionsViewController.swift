//
//  PredictionsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 11/1/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PredictionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bestActorArray = [Items.actors]()
    var bestActressArray = [Items.actors]()
    var supportingActorArray = [Items.actors]()
    var supportingActressArray = [Items.actors]()
    var directorArray = [Items.actors]()
    var rowSelected = Int()
    var storedOffsets = [Int: CGFloat]()
    var scrollViewTag = 0
    var stopScroll = false
    var stoppedDragging = CGPoint(x:0, y:0)
    var stoppedDecelerate = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var predictionsTable: UITableView!
    @IBAction func unwindFromResults(segue: UIStoryboardSegue) {}
    @IBAction func unwindFromLogin(segue: UIStoryboardSegue) {}
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for item in Items.sharedInstance.actorArray {
            switch item.nominatedFor {
            case "Best Actor":
                bestActorArray.append(item)
            case "Supporting Actor":
                supportingActorArray.append(item)
            case "Best Actress":
                bestActressArray.append(item)
            case "Supporting Actress":
                supportingActressArray.append(item)
            case "Directing":
                directorArray.append(item)
            default:
                return
            }
        }
        
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePurchased), name:NSNotification.Name(rawValue: "purchased"), object: nil)
    }
    
    @objc func updatePurchased(notification: NSNotification){
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logError(logString: "In Predictions VC")
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
        }
        
        if Items.sharedInstance.dataCleared {
            Items.sharedInstance.dataCleared = false
            predictionsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! PredictionsTableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0 :
            cell.sectionLabel.text = "Best Picture"
        case 1 :
            cell.sectionLabel.text = "Actor in a Leading Role"
        case 2 :
            cell.sectionLabel.text = "Actress in a Leading Role"
        case 3 :
            cell.sectionLabel.text = "Actor in a Supporting Role"
        case 4 :
            cell.sectionLabel.text = "Actress in a Supporting Role"
        case 5 :
            cell.sectionLabel.text = "Animated Feature Film"
        case 6 :
            cell.sectionLabel.text = "Cinematography"
        case 7 :
            cell.sectionLabel.text = "Costume Design"
        case 8 :
            cell.sectionLabel.text = "Directing"
        case 9 :
            cell.sectionLabel.text = "Documentary (Feature)"
        case 10 :
            cell.sectionLabel.text = "Documentary (Short Subject)"
        case 11 :
            cell.sectionLabel.text = "Film Editing"
        case 12 :
            cell.sectionLabel.text = "Foreign Language Film"
        case 13 :
            cell.sectionLabel.text = "Makeup and Hairstyling"
        case 14 :
            cell.sectionLabel.text = "Music (Original Score)"
        case 15 :
            cell.sectionLabel.text = "Music (Original Song)"
        case 16 :
            cell.sectionLabel.text = "Production Design"
        case 17 :
            cell.sectionLabel.text = "Short Film (Animated)"
        case 18 :
            cell.sectionLabel.text = "Short Film (Live Action)"
        case 19 :
            cell.sectionLabel.text = "Sound Editing"
        case 20 :
            cell.sectionLabel.text = "Sound Mixing"
        case 21 :
            cell.sectionLabel.text = "Visual Effects"
        case 22 :
            cell.sectionLabel.text = "Writing (Adapated Screenplay)"
        default :
            cell.sectionLabel.text = "Writing (Original Screenplay)"
        }
        
        cell.resultsButton.addTarget(self, action: #selector(self.connected(_:)), for: .touchUpInside)
        cell.resultsButton.tag = indexPath.row
        
        return cell
    }
    
    @objc func connected (_ sender: UIButton){
        rowSelected = sender.tag
        self.logError(logString: "Predictions VC - Going to results with row \(rowSelected)")
        performSegue(withIdentifier: "resultsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? PredictionsTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? PredictionsTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.brown
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 259
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 259
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultsSegue" {
            let secondScene = segue.destination as! ResultsViewController
            secondScene.resultsChosen = rowSelected
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Predictions"
        navigationItem.backBarButtonItem = backItem
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //caused by user
        print("SCROLL scrollViewDidEndDecelerating")
        scrollViewTag = scrollView.tag
        stopScroll = false
        stoppedDecelerate = scrollView.contentOffset
        print(stoppedDecelerate)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            //cause by user
            print("SCROLL scrollViewDidEndDragging")
            scrollViewTag = scrollView.tag
            stopScroll = true
            stoppedDragging = scrollView.contentOffset
            print(stoppedDragging)
        }
    }
}

extension PredictionsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Items.sharedInstance.sortedMovieArray[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PredictionsCollectionViewCell
        let movieSeen = Items.sharedInstance.sortedMovieArray[collectionView.tag][indexPath.item]
        
        if collectionView.tag == 1 {
            cell.movieImage.image = bestActorArray[indexPath.item].image
            cell.actorName.text = bestActorArray[indexPath.item].name
            cell.actorName.isHidden = false
            if Items.sharedInstance.predictions[collectionView.tag] == bestActorArray[indexPath.item].name {
                cell.hiddenView.setBorder(radius: 0, color: UIColorFromRGB(rgbValue: 0x9B8742))
            } else {
                cell.hiddenView.setBorder(radius: 0, color: UIColor.clear)
            }
        } else if collectionView.tag == 2 {
            cell.movieImage.image = bestActressArray[indexPath.item].image
            cell.actorName.text = bestActressArray[indexPath.item].name
            cell.actorName.isHidden = false
            if Items.sharedInstance.predictions[collectionView.tag] == bestActressArray[indexPath.item].name {
                cell.hiddenView.setBorder(radius: 0, color: UIColorFromRGB(rgbValue: 0x9B8742))
            } else {
                cell.hiddenView.setBorder(radius: 0, color: UIColor.clear)
            }
        } else if collectionView.tag == 3 {
            cell.movieImage.image = supportingActorArray[indexPath.item].image
            cell.actorName.text = supportingActorArray[indexPath.item].name
            cell.actorName.isHidden = false
            if Items.sharedInstance.predictions[collectionView.tag] == supportingActorArray[indexPath.item].name {
                cell.hiddenView.setBorder(radius: 0, color: UIColorFromRGB(rgbValue: 0x9B8742))
            } else {
                cell.hiddenView.setBorder(radius: 0, color: UIColor.clear)
            }
        } else if collectionView.tag == 4 {
            cell.movieImage.image = supportingActressArray[indexPath.item].image
            cell.actorName.text = supportingActressArray[indexPath.item].name
            cell.actorName.isHidden = false
            if Items.sharedInstance.predictions[collectionView.tag] == supportingActressArray[indexPath.item].name {
                cell.hiddenView.setBorder(radius: 0, color: UIColorFromRGB(rgbValue: 0x9B8742))
            } else {
                cell.hiddenView.setBorder(radius: 0, color: UIColor.clear)
            }
        } else if collectionView.tag == 8 {
            cell.movieImage.image = directorArray[indexPath.item].image
            cell.actorName.text = directorArray[indexPath.item].name
            cell.actorName.isHidden = false
            if Items.sharedInstance.predictions[collectionView.tag] == directorArray[indexPath.item].name {
                cell.hiddenView.setBorder(radius: 0, color: UIColorFromRGB(rgbValue: 0x9B8742))
            } else {
                cell.hiddenView.setBorder(radius: 0, color: UIColor.clear)
            }
        } else {
            cell.movieImage.image = movieSeen.cover
            cell.actorName.isHidden = true
            if Items.sharedInstance.predictions[collectionView.tag] == movieSeen.name {
                cell.hiddenView.setBorder(radius: 0, color: UIColorFromRGB(rgbValue: 0x9B8742))
            } else {
                cell.hiddenView.setBorder(radius: 0, color: UIColor.clear)
            }
        }
        
        return cell
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let movieSelected = Items.sharedInstance.sortedMovieArray[collectionView.tag][indexPath.row]
        let predictionsArray = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
        
        if collectionView.tag == 1 || collectionView.tag == 2 || collectionView.tag == 3 || collectionView.tag == 4 || collectionView.tag == 8 {
            switch collectionView.tag {
            case 1:
                if Items.sharedInstance.predictions[collectionView.tag] != bestActorArray[indexPath.row].name {
                    self.logError(logString: "Predictions VC - Predicting \(bestActorArray[indexPath.row].name) for \(predictionsArray[collectionView.tag])")
                    let userPredRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                    userPredRef.updateData([
                        predictionsArray[collectionView.tag]: bestActorArray[indexPath.row].name
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Predictions VC - Error Saving User Prediction", logError: err.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem saving your prediction. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    let predictionsRef = Firestore.firestore().collection("Predictions").document(predictionsArray[collectionView.tag])
                    predictionsRef.getDocument { (document, error) in
                        if let error = error {
                            self.logError(logString: "Predictions VC - Error Accessing Predictions Document \(predictionsArray[collectionView.tag])", logError: error.localizedDescription)
                        } else {
                            if let document = document, document.exists {
                                let newPredictionCount = document.data()![self.bestActorArray[indexPath.row].name] as! Int
                                if Items.sharedInstance.predictions[collectionView.tag] != "" {
                                    let oldMovie = Items.sharedInstance.predictions[collectionView.tag]
                                    Items.sharedInstance.predictions[collectionView.tag] = self.bestActorArray[indexPath.row].name
                                    let oldPredictionCount = document.data()![oldMovie] as! Int
                                    
                                    predictionsRef.updateData([
                                        self.bestActorArray[indexPath.row].name: newPredictionCount + 1,
                                        oldMovie: oldPredictionCount - 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Subtracing/Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            var indexP = [indexPath]
                                            for (index,item) in self.bestActorArray.enumerated() {
                                                if item.name == oldMovie {
                                                    indexP.append(IndexPath(row: index, section: 0))
                                                }
                                            }
                                            collectionView.reloadItems(at: indexP)
                                        }
                                    }
                                } else {
                                    Items.sharedInstance.predictions[collectionView.tag] = self.bestActorArray[indexPath.row].name
                                    predictionsRef.updateData([
                                        self.bestActorArray[indexPath.row].name: newPredictionCount + 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                }
                            } else {
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.logError(logString: "Predictions VC - \(predictionsArray[collectionView.tag]) Document Doesn't Exist")
                            }
                        }
                    }
                }
            case 2:
                if Items.sharedInstance.predictions[collectionView.tag] != bestActressArray[indexPath.row].name {
                    self.logError(logString: "Predictions VC - Predicting \(bestActressArray[indexPath.row].name) for \(predictionsArray[collectionView.tag])")
                    let userPredRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                    userPredRef.updateData([
                        predictionsArray[collectionView.tag]: bestActressArray[indexPath.row].name
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Predictions VC - Error Saving User Prediction", logError: err.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem saving your prediction. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    let predictionsRef = Firestore.firestore().collection("Predictions").document(predictionsArray[collectionView.tag])
                    predictionsRef.getDocument { (document, error) in
                        if let error = error {
                            self.logError(logString: "Predictions VC - Error Accessing Predictions Document \(predictionsArray[collectionView.tag])", logError: error.localizedDescription)
                        } else {
                            if let document = document, document.exists {
                                let newPredictionCount = document.data()![self.bestActressArray[indexPath.row].name] as! Int
                                if Items.sharedInstance.predictions[collectionView.tag] != "" {
                                    let oldMovie = Items.sharedInstance.predictions[collectionView.tag]
                                    Items.sharedInstance.predictions[collectionView.tag] = self.bestActressArray[indexPath.row].name
                                    let oldPredictionCount = document.data()![oldMovie] as! Int
                                    
                                    predictionsRef.updateData([
                                        self.bestActressArray[indexPath.row].name: newPredictionCount + 1,
                                        oldMovie: oldPredictionCount - 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Subtracing/Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            var indexP = [indexPath]
                                            for (index,item) in self.bestActressArray.enumerated() {
                                                if item.name == oldMovie {
                                                    indexP.append(IndexPath(row: index, section: 0))
                                                }
                                            }
                                            collectionView.reloadItems(at: indexP)
                                        }
                                    }
                                } else {
                                    Items.sharedInstance.predictions[collectionView.tag] = self.bestActressArray[indexPath.row].name
                                    predictionsRef.updateData([
                                        self.bestActressArray[indexPath.row].name: newPredictionCount + 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                }
                            } else {
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.logError(logString: "Predictions VC - \(predictionsArray[collectionView.tag]) Document Doesn't Exist")
                            }
                        }
                    }
                }
            case 3:
                if Items.sharedInstance.predictions[collectionView.tag] != supportingActorArray[indexPath.row].name {
                    self.logError(logString: "Predictions VC - Predicting \(supportingActorArray[indexPath.row].name) for \(predictionsArray[collectionView.tag])")
                    let userPredRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                    userPredRef.updateData([
                        predictionsArray[collectionView.tag]: supportingActorArray[indexPath.row].name
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Predictions VC - Error Saving User Prediction", logError: err.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem saving your prediction. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    let predictionsRef = Firestore.firestore().collection("Predictions").document(predictionsArray[collectionView.tag])
                    predictionsRef.getDocument { (document, error) in
                        if let error = error {
                            self.logError(logString: "Predictions VC - Error Accessing Predictions Document \(predictionsArray[collectionView.tag])", logError: error.localizedDescription)
                        } else {
                            if let document = document, document.exists {
                                let newPredictionCount = document.data()![self.supportingActorArray[indexPath.row].name] as! Int
                                if Items.sharedInstance.predictions[collectionView.tag] != "" {
                                    let oldMovie = Items.sharedInstance.predictions[collectionView.tag]
                                    Items.sharedInstance.predictions[collectionView.tag] = self.supportingActorArray[indexPath.row].name
                                    let oldPredictionCount = document.data()![oldMovie] as! Int
                                    
                                    predictionsRef.updateData([
                                        self.supportingActorArray[indexPath.row].name: newPredictionCount + 1,
                                        oldMovie: oldPredictionCount - 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Subtracing/Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            var indexP = [indexPath]
                                            for (index,item) in self.supportingActorArray.enumerated() {
                                                if item.name == oldMovie {
                                                    indexP.append(IndexPath(row: index, section: 0))
                                                }
                                            }
                                            collectionView.reloadItems(at: indexP)
                                        }
                                    }
                                } else {
                                    Items.sharedInstance.predictions[collectionView.tag] = self.supportingActorArray[indexPath.row].name
                                    predictionsRef.updateData([
                                        self.supportingActorArray[indexPath.row].name: newPredictionCount + 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                }
                            } else {
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.logError(logString: "Predictions VC - \(predictionsArray[collectionView.tag]) Document Doesn't Exist")
                            }
                        }
                    }
                }
            case 4:
                if Items.sharedInstance.predictions[collectionView.tag] != supportingActressArray[indexPath.row].name {
                    self.logError(logString: "Predictions VC - Predicting \(supportingActressArray[indexPath.row].name) for \(predictionsArray[collectionView.tag])")
                    let userPredRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                    userPredRef.updateData([
                        predictionsArray[collectionView.tag]: supportingActressArray[indexPath.row].name
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Predictions VC - Error Saving User Prediction", logError: err.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem saving your prediction. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    let predictionsRef = Firestore.firestore().collection("Predictions").document(predictionsArray[collectionView.tag])
                    predictionsRef.getDocument { (document, error) in
                        if let error = error {
                            self.logError(logString: "Predictions VC - Error Accessing Predictions Document \(predictionsArray[collectionView.tag])", logError: error.localizedDescription)
                        } else {
                            if let document = document, document.exists {
                                let newPredictionCount = document.data()![self.supportingActressArray[indexPath.row].name] as! Int
                                if Items.sharedInstance.predictions[collectionView.tag] != "" {
                                    let oldMovie = Items.sharedInstance.predictions[collectionView.tag]
                                    Items.sharedInstance.predictions[collectionView.tag] = self.supportingActressArray[indexPath.row].name
                                    let oldPredictionCount = document.data()![oldMovie] as! Int
                                    
                                    predictionsRef.updateData([
                                        self.supportingActressArray[indexPath.row].name: newPredictionCount + 1,
                                        oldMovie: oldPredictionCount - 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Subtracing/Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            var indexP = [indexPath]
                                            for (index,item) in self.supportingActressArray.enumerated() {
                                                if item.name == oldMovie {
                                                    indexP.append(IndexPath(row: index, section: 0))
                                                }
                                            }
                                            collectionView.reloadItems(at: indexP)
                                        }
                                    }
                                } else {
                                    Items.sharedInstance.predictions[collectionView.tag] = self.supportingActressArray[indexPath.row].name
                                    predictionsRef.updateData([
                                        self.supportingActressArray[indexPath.row].name: newPredictionCount + 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                }
                            } else {
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.logError(logString: "Predictions VC - \(predictionsArray[collectionView.tag]) Document Doesn't Exist")
                            }
                        }
                    }
                }
            case 8:
                if Items.sharedInstance.predictions[collectionView.tag] != directorArray[indexPath.row].name {
                    self.logError(logString: "Predictions VC - Predicting \(directorArray[indexPath.row].name) for \(predictionsArray[collectionView.tag])")
                    let userPredRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                    userPredRef.updateData([
                        predictionsArray[collectionView.tag]: directorArray[indexPath.row].name
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Predictions VC - Error Saving User Prediction", logError: err.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem saving your prediction. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    let predictionsRef = Firestore.firestore().collection("Predictions").document(predictionsArray[collectionView.tag])
                    predictionsRef.getDocument { (document, error) in
                        if let error = error {
                            self.logError(logString: "Predictions VC - Error Accessing Predictions Document \(predictionsArray[collectionView.tag])", logError: error.localizedDescription)
                        } else {
                            if let document = document, document.exists {
                                let newPredictionCount = document.data()![self.directorArray[indexPath.row].name] as! Int
                                if Items.sharedInstance.predictions[collectionView.tag] != "" {
                                    let oldMovie = Items.sharedInstance.predictions[collectionView.tag]
                                    Items.sharedInstance.predictions[collectionView.tag] = self.directorArray[indexPath.row].name
                                    let oldPredictionCount = document.data()![oldMovie] as! Int
                                    
                                    predictionsRef.updateData([
                                        self.directorArray[indexPath.row].name: newPredictionCount + 1,
                                        oldMovie: oldPredictionCount - 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Subtracing/Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            var indexP = [indexPath]
                                            for (index,item) in self.directorArray.enumerated() {
                                                if item.name == oldMovie {
                                                    indexP.append(IndexPath(row: index, section: 0))
                                                }
                                            }
                                            collectionView.reloadItems(at: indexP)
                                        }
                                    }
                                } else {
                                    Items.sharedInstance.predictions[collectionView.tag] = self.directorArray[indexPath.row].name
                                    predictionsRef.updateData([
                                        self.directorArray[indexPath.row].name: newPredictionCount + 1
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Predictions VC - Error Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            collectionView.reloadItems(at: [indexPath])
                                        }
                                    }
                                }
                            } else {
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.logError(logString: "Predictions VC - \(predictionsArray[collectionView.tag]) Document Doesn't Exist")
                            }
                        }
                    }
                }
            default:
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
        } else {
            if Items.sharedInstance.predictions[collectionView.tag] != movieSelected.name {
                self.logError(logString: "Predictions VC - Predicting \(movieSelected.name) for \(predictionsArray[collectionView.tag])")
                let userPredRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userPredRef.updateData([
                    predictionsArray[collectionView.tag]: movieSelected.name
                ]) { err in
                    if let err = err {
                        self.logError(logString: "Predictions VC - Error Saving User Prediction", logError: err.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "There was a problem saving your prediction. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
                let predictionsRef = Firestore.firestore().collection("Predictions").document(predictionsArray[collectionView.tag])
                predictionsRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Predictions VC - Error Accessing Predictions Document \(predictionsArray[collectionView.tag])", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            let newPredictionCount = document.data()![movieSelected.name] as! Int
                            if Items.sharedInstance.predictions[collectionView.tag] != "" {
                                let oldMovie = Items.sharedInstance.predictions[collectionView.tag]
                                Items.sharedInstance.predictions[collectionView.tag] = movieSelected.name
                                let oldPredictionCount = document.data()![oldMovie] as! Int
                                
                                predictionsRef.updateData([
                                    movieSelected.name: newPredictionCount + 1,
                                    oldMovie: oldPredictionCount - 1
                                ]) { err in
                                    if let err = err {
                                        self.logError(logString: "Predictions VC - Error Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                    } else {
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                        var indexP = [indexPath]
                                        for (index,item) in Items.sharedInstance.sortedMovieArray[collectionView.tag].enumerated() {
                                            if item.name == oldMovie {
                                                indexP.append(IndexPath(row: index, section: 0))
                                            }
                                        }
                                        collectionView.reloadItems(at: indexP)
                                    }
                                }
                            } else {
                                Items.sharedInstance.predictions[collectionView.tag] = movieSelected.name
                                predictionsRef.updateData([
                                    movieSelected.name: newPredictionCount + 1
                                ]) { err in
                                    if let err = err {
                                        self.logError(logString: "Predictions VC - Error Subtracing/Adding \(predictionsArray[collectionView.tag]) Count", logError: err.localizedDescription)
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                    } else {
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                        collectionView.reloadItems(at: [indexPath])
                                    }
                                }
                            }
                        } else {
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.logError(logString: "Predictions VC - \(predictionsArray[collectionView.tag]) Document Doesn't Exist")
                        }
                    }
                }
            }
        }
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

extension UIView{
    @discardableResult func setBorder(radius:CGFloat, color:UIColor = UIColor.clear) -> UIView{
        let roundView:UIView = self
        roundView.layer.cornerRadius = CGFloat(radius)
        roundView.layer.borderWidth = 5
        roundView.layer.borderColor = color.cgColor
        roundView.clipsToBounds = true
        return roundView
    }
}
