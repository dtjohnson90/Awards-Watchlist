//
//  MoviesNotSeenTableViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/11/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import CloudKit

class MoviesNotSeenTableViewController: UITableViewController {

    var moviesLeftList = [Items.movie]()
    
    @IBOutlet weak var moviesLeftLabel: UILabel!
    @IBAction func unwindToList2(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        moviesLeftList.removeAll()
        for movie in Items.sharedInstance.movieArray {
            if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                moviesLeftList.append(movie)
            }
        }
        moviesLeftList.sort { $0.name < $1.name }
        moviesLeftLabel.text = String(moviesLeftList.count) + " / " + String(Items.sharedInstance.movieArray.count) + " Movies Left"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = moviesLeftList[indexPath.row].name
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondScene = segue.destination as! DetailViewController
        
        if let inpath2 = self.tableView.indexPathForSelectedRow {
            let currentMovie = moviesLeftList[inpath2.row]
            secondScene.movieSelected = currentMovie
        }
    }
}
