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

    //var allMovieList = [String]()
    //var userMovieList = [String]()
    var moviesLeftList = [String]()
    
    @IBOutlet weak var moviesLeftLabel: UILabel!
    @IBAction func unwindToList2(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //navigationController?.hidesBarsOnSwipe = false
        
        moviesLeftList = Items.sharedInstance.allMovieList
        moviesLeftList = moviesLeftList.filter { !Items.sharedInstance.userMovieList.contains($0) }
        moviesLeftList = moviesLeftList.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        moviesLeftLabel.text = String(moviesLeftList.count) + " / " + String(Items.sharedInstance.allMovieList.count) + " Movies Left"
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

        cell.textLabel?.text = moviesLeftList[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondScene = segue.destination as! DetailViewController
        
        if let inpath2 = self.tableView.indexPathForSelectedRow {
            let currentMovie = moviesLeftList[inpath2.row]
            secondScene.movieTitle = currentMovie
        }
        secondScene.viewControllerTest = "B"
    }

}
