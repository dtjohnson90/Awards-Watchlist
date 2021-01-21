//
//  MoviesNotSeenTableViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/11/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MoviesNotSeenTableViewController: UITableViewController {

    var moviesLeftList = [Items.movie]()
    
    @IBAction func unwindToList2(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logError(logString: "Inside MoviesNotSeen VC")
        moviesLeftList.removeAll()
        for movie in Items.sharedInstance.movieArray {
            if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                moviesLeftList.append(movie)
            }
        }
        moviesLeftList.sort { $0.name < $1.name }
        self.navigationItem.title = String(moviesLeftList.count) + " / " + String(Items.sharedInstance.movieArray.count) + " Movies To Watch"
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesLeftList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MoviesNotSeenTableViewCell
        let currentMovie = moviesLeftList[indexPath.row]
        
        cell.movieImage.image = currentMovie.cover
        cell.movieTitle.text = currentMovie.name
        if currentMovie.actors.isEmpty {
            cell.movieStarring.text = "No Billable Cast"
        } else {
            cell.movieStarring.text = "Starring: " + currentMovie.actors[0].name
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondScene = segue.destination as! DetailViewController
        
        if let inpath2 = self.tableView.indexPathForSelectedRow {
            let currentMovie = moviesLeftList[inpath2.row]
            self.logError(logString: "Movies Not Seen VC - Selected Movie \(currentMovie.name)")
            secondScene.movieSelected = currentMovie
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Movies Left"
        navigationItem.backBarButtonItem = backItem
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
