//
//  NominationsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/8/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class NominationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movieSelected = Items.movie(actors: [String](), cover: UIImage(), description: String(), idmb: String(), name: String(), nominatedFor: [String](), youtube: String())
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var viewSwitch: UISegmentedControl!
    @IBAction func indexChanged(_ sender: Any) {
        switch viewSwitch.selectedSegmentIndex {
        case 0:
            detailTableView.isHidden = false
            listTableView.isHidden = true
            detailTableView.reloadData()
        case 1:
            detailTableView.isHidden = true
            listTableView.isHidden = false
            listTableView.reloadData()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listTableView.isHidden = true
        detailTableView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listTableView.reloadData()
        detailTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if tableView == self.detailTableView {
            return 1
        } else {
            return 24
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.detailTableView {
            return 24
        } else {
            return Items.sharedInstance.sortedMovieArray[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.detailTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NominationsTableViewCell
            
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
            case 23 :
                cell.sectionLabel.text = "Writing (Original Screenplay)"
            default :
                print("There was an error")
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            
            cell.textLabel?.text = Items.sharedInstance.sortedMovieArray[indexPath.section][indexPath.row].name
            if Items.sharedInstance.moviesSeenArray.contains(Items.sharedInstance.sortedMovieArray[indexPath.section][indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == detailTableView {
            guard let tableViewCell = cell as? NominationsTableViewCell else { return }
        
            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == detailTableView {
            return 220;//Choose your custom row height
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if tableView == listTableView {
            if (section == 0){
                return "Best Picture"
            }
            if (section == 1){
                return "Actor in a Leading Role"
            }
            if (section == 2){
                return "Actress in a Leading Role"
            }
            if (section == 3){
                return "Actor in a Supporting Role"
            }
            if (section == 4){
                return "Actress in a Supporting Role"
            }
            if (section == 5){
                return "Animated Feature Film"
            }
            if (section == 6){
                return "Cinematography"
            }
            if (section == 7){
                return "Costume Design"
            }
            if (section == 8){
                return "Directing"
            }
            if (section == 9){
                return "Documentary (Feature)"
            }
            if (section == 10){
                return "Documentary (Short Subject)"
            }
            if (section == 11){
                return "Film Editing"
            }
            if (section == 12){
                return "Foreign Language Film"
            }
            if (section == 13){
                return "Makeup and Hairstyling"
            }
            if (section == 14){
                return "Music (Original Score)"
            }
            if (section == 15){
                return "Music (Original Song)"
            }
            if (section == 16){
                return "Production Design"
            }
            if (section == 17){
                return "Short Film (Animated)"
            }
            if (section == 18){
                return "Short Film (Live Action)"
            }
            if (section == 19){
                return "Sound Editing"
            }
            if (section == 20){
                return "Sound Mixing"
            }
            if (section == 21){
                return "Visual Effects"
            }
            if (section == 22){
                return "Writing (Adapted Screenplay)"
            }
            if (section == 23){
                return "Writing (Original Screenplay)"
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if tableView == listTableView {
            view.tintColor = UIColor.black
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.brown
            header.textLabel?.textAlignment = NSTextAlignment.center
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == listTableView {
            movieSelected = Items.sharedInstance.sortedMovieArray[indexPath.section][indexPath.row]
            performSegue(withIdentifier: "newDetail", sender: self)
        }
    }
}

extension NominationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return Items.sharedInstance.sortedMovieArray[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! NominationsCollectionViewCell
        
        let image = Items.sharedInstance.sortedMovieArray[collectionView.tag][indexPath.item].cover
        cell.movieImage.image = image
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieSelected = Items.sharedInstance.sortedMovieArray[collectionView.tag][indexPath.row]
        performSegue(withIdentifier: "newDetail", sender: self)
    }
    
    func isImageEqual (image1: UIImage, image2: UIImage) -> Bool {
        
        let imageData = UIImageJPEGRepresentation(image1 , 1.0)
        let imageData2 = UIImageJPEGRepresentation(image2 , 1.0)
        
        return imageData == imageData2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newDetail" {
            let secondScene = segue.destination as! DetailViewController
            secondScene.movieSelected = movieSelected
        }
    }
}
