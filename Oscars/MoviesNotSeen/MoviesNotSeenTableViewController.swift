//
//  MoviesNotSeenTableViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/11/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MoviesNotSeenTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var moviesLeftList = [Items.movie]()
    var searchController: UISearchController!
    var filteredMovies = [Items.movie]()
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering = false
    
    @IBAction func unwindToList2(segue: UIStoryboardSegue) {}
    
    @IBAction func searchButton(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        searchController.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"

        present(searchController, animated: true, completion: nil)
    }
    
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
        filteredMovies = moviesLeftList
        self.navigationItem.title = String(moviesLeftList.count) + " / " + String(Items.sharedInstance.movieArray.count) + " Movies To Watch"
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            isFiltering = false
        } else {
            if !isSearchBarEmpty {
                isFiltering = true
                self.view.frame.origin.y = (self.navigationController?.navigationBar.frame.height)! + 10
            }
        }
        filterMovies(for: searchController.searchBar.text ?? "")
    }
    
    private func filterMovies(for searchText: String) {
        filteredMovies = Items.sharedInstance.movieArray.filter { movie in return
            movie.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredMovies.count
        }
        return moviesLeftList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MoviesNotSeenTableViewCell
        
        let currentMovie: Items.movie
        if isFiltering {
            currentMovie = filteredMovies[indexPath.row]
        } else {
            currentMovie = moviesLeftList[indexPath.row]
        }
        
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
            var currentMovie: Items.movie
            if isFiltering {
                currentMovie = filteredMovies[inpath2.row]
            } else {
                currentMovie = moviesLeftList[inpath2.row]
            }
            self.logError(logString: "Movies Not Seen VC - Selected Movie \(currentMovie.name)")
            secondScene.movieSelected = currentMovie
        }
        
        if isFiltering{
            searchController.isActive = false
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
