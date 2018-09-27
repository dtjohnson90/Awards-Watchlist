//
//  predictionsTableViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/8/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import CloudKit

class predictionsTableViewController: UITableViewController {

    var bestPicture = [String](), makeup = [String](), bestActor = [String](), bestActress = [String](), supportingActor = [String](), supportingActress = [String](), animated = [String](), cinematography = [String](), costumeDesign = [String](), directing = [String](), documentaryFeature = [String](), documentaryShort = [String](), filmEditing = [String](), foreignFilm = [String](), musicScore = [String](), musicSong = [String](), productionDesign = [String](), shortAnimated = [String](), shortLive = [String](), soundEditing = [String](), soundMixing = [String](), visualEffects = [String](), writingAdapted = [String](), writingOriginal = [String]()
    var bestActor2 = ["Viggo Mortensen","Denzel Washington","Andrew Garfield","Ryan Gosling","Casey Affleck"]
    var bestActress2 = ["Isabelle Huppert","Meryl Streep","Natalie Portman","Emily Stone","Ruth Negga"]
    var supportingActor2 = ["Jeff Bridges", "Dev Patel", "Lucas Hedges", "Mahershala Ali", "Michael Shannon"]
    var supportingActress2 = ["Viola Davis", "Octavia Spencer","Nicole Kidman","Michelle Williams","Naomi Harris"]
    var directing2 = ["Denis Velleneuve","Mel Gibson","Damien Chazelle","Kenneth Lonergan","Barry Jenkins"]
    var musicSong2 = ["The Empty Chair", "Audition","City of Stars","How Far I'll Go","Can't Stop the Feeling"]
    var allMovieList = [String]()
    @IBAction func unwindToList(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 24
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow // index path of selected cell
        
        let sectionIndex = indexPath!.section // index of selected section
        
        let cellIndex = indexPath!.row // index of selected cell
        //let cellName = tableView.cellForRow(at: indexPath!) //  instance of selected cell
        
        print("Slected Section: " + String(sectionIndex) + " and cell " + String(cellIndex))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return bestPicture.count
        } else if (section == 1) {
            return bestActor.count
        } else if (section == 2) {
            return bestActress.count
        } else if (section == 3) {
            return supportingActor.count
        } else if (section == 4) {
            return supportingActress.count
        } else if (section == 5) {
            return animated.count
        } else if (section == 6) {
            return cinematography.count
        } else if (section == 7) {
            return costumeDesign.count
        } else if (section == 8) {
            return directing.count
        } else if (section == 9) {
            return documentaryFeature.count
        } else if (section == 10) {
            return documentaryShort.count
        } else if (section == 11) {
            return filmEditing.count
        } else if (section == 12) {
            return foreignFilm.count
        } else if (section == 13) {
            return makeup.count
        } else if (section == 14) {
            return musicScore.count
        } else if (section == 15) {
            return musicSong.count
        } else if (section == 16) {
            return productionDesign.count
        } else if (section == 17) {
            return shortAnimated.count
        } else if (section == 18) {
            return shortLive.count
        } else if (section == 19) {
            return soundEditing.count
        } else if (section == 20) {
            return soundMixing.count
        } else if (section == 21) {
            return visualEffects.count
        } else if (section == 22) {
            return writingAdapted.count
        } else if (section == 23) {
            return writingOriginal.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath)
        if (indexPath.section == 0){
            cell.textLabel?.text = self.bestPicture[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 1){
            cell.textLabel?.text = self.bestActor[indexPath.row] + " (" + self.bestActor2[indexPath.row] + ")"
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 2){
            cell.textLabel?.text = self.bestActress[indexPath.row] + " (" + self.bestActress2[indexPath.row] + ")"
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 3){
            cell.textLabel?.text = self.supportingActor[indexPath.row] + " (" + self.supportingActor2[indexPath.row] + ")"
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 4){
            cell.textLabel?.text = self.supportingActress[indexPath.row] + " (" + self.supportingActress2[indexPath.row] + ")"
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 5){
            cell.textLabel?.text = self.animated[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 6){
            cell.textLabel?.text = self.cinematography[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 7){
            cell.textLabel?.text = self.costumeDesign[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 8){
            cell.textLabel?.text = self.directing[indexPath.row] + " (" + self.directing2[indexPath.row] + ")"
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 9){
            cell.textLabel?.text = self.documentaryFeature[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 10){
            cell.textLabel?.text = self.documentaryShort[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 11){
            cell.textLabel?.text = self.filmEditing[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 12){
            cell.textLabel?.text = self.foreignFilm[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 13){
            cell.textLabel?.text = self.makeup[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 14){
            cell.textLabel?.text = self.musicScore[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 15){
            cell.textLabel?.text = self.musicSong[indexPath.row] + " (" + self.musicSong2[indexPath.row] + ")"
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 16){
            cell.textLabel?.text = self.productionDesign[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 17){
            cell.textLabel?.text = self.shortAnimated[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 18){
            cell.textLabel?.text = self.shortLive[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 19){
            cell.textLabel?.text = self.soundEditing[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 20){
            cell.textLabel?.text = self.soundMixing[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 21){
            cell.textLabel?.text = self.visualEffects[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 22){
            cell.textLabel?.text = self.writingAdapted[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        if (indexPath.section == 23){
            cell.textLabel?.text = self.writingOriginal[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
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
            return "Short Filme (Animated)"
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
        return "Null"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.brown
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondScene = segue.destination as! DetailViewController
        let movieArray = [bestPicture,bestActor,bestActress,supportingActor,supportingActress,animated,cinematography,costumeDesign,directing,documentaryFeature,documentaryShort,filmEditing,foreignFilm,makeup,musicScore,musicSong,productionDesign,shortAnimated,shortLive,soundEditing,soundMixing,visualEffects,writingAdapted,writingOriginal]
        
        if segue.identifier == "movieSegueIdentifier" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let currentMovie = movieArray[indexPath.section][indexPath.row]
                secondScene.movieTitle = currentMovie
            }
            secondScene.viewControllerTest = "A"
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
