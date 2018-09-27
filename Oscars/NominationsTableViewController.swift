//
//  NominationsTableViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 2/28/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class NominationsTableViewController: UITableViewController {
    
    let model = [Items.sharedInstance.bpImage,Items.sharedInstance.baImage,Items.sharedInstance.basImage,Items.sharedInstance.bsaImage,Items.sharedInstance.bsasImage,Items.sharedInstance.aImage,Items.sharedInstance.cImage,Items.sharedInstance.cdImage,Items.sharedInstance.dImage,Items.sharedInstance.dfImage,Items.sharedInstance.dsImage,Items.sharedInstance.feImage,Items.sharedInstance.fImage,Items.sharedInstance.mImage,Items.sharedInstance.mscImage,Items.sharedInstance.msoImage,Items.sharedInstance.pdImage,Items.sharedInstance.shaImage,Items.sharedInstance.shlImage,Items.sharedInstance.seImage,Items.sharedInstance.smImage,Items.sharedInstance.veImage,Items.sharedInstance.waImage,Items.sharedInstance.woImage]
    let model2 = [Items.sharedInstance.bpImage[1],Items.sharedInstance.baImage[1],Items.sharedInstance.basImage[1],Items.sharedInstance.bsaImage[1],Items.sharedInstance.bsasImage[1],Items.sharedInstance.aImage[1],Items.sharedInstance.cImage[1],Items.sharedInstance.cdImage[1],Items.sharedInstance.dImage[1],Items.sharedInstance.dfImage[1],Items.sharedInstance.dsImage[1],Items.sharedInstance.feImage[1],Items.sharedInstance.fImage[1],Items.sharedInstance.mImage[1],Items.sharedInstance.mscImage[1],Items.sharedInstance.msoImage[1],Items.sharedInstance.pdImage[1],Items.sharedInstance.shaImage[1],Items.sharedInstance.shlImage[1],Items.sharedInstance.seImage[1],Items.sharedInstance.smImage[1],Items.sharedInstance.veImage[1],Items.sharedInstance.waImage[1],Items.sharedInstance.woImage[1]]
    var movieTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        print(model)


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? NominationsTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 220;//Choose your custom row height
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NominationsTableViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        print(model)
        return model[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! NominationsCollectionViewCell
        
        let image = model[collectionView.tag][indexPath.item]
        cell.movieImage.image = image[0] as? UIImage
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tempTitle = model[collectionView.tag][indexPath.row]
        movieTitle = tempTitle[1] as! String
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
            secondScene.movieTitle = movieTitle
            secondScene.viewControllerTest = "A"
        }
    }
}
