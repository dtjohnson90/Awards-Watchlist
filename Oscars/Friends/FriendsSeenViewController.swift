//
//  FriendsSeenViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/17/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendsSeenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var seenTableView: UITableView!
    
    var friendChosen = String()
    var moviesSeen = [Items.movie]()
    var moviesNotSeen = [Items.movie]()
    var predictions = [String]()
    let categoryArray = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.title = "Seen Movies"
        seenTableView.dataSource = nil
        Firestore.firestore().collection("UserMovieList").document(friendChosen).getDocument { (document, error) in
            if let document = document, document.exists {
                let movieList = document.data()!["movies"] as! [String]
                
                for category in self.categoryArray {
                    self.predictions.append(document.data()![category] as! String)
                }
                
                let movieDownloading = DispatchGroup()
                for movie in movieList {
                    movieDownloading.enter()
                    for item in Items.sharedInstance.movieArray {
                        if movie == item.name {
                            self.moviesSeen.append(item)
                            movieDownloading.leave()
                            break
                        }
                    }
                }
                movieDownloading.notify(queue: .main) {
                    let movieSorting = DispatchGroup()
                    for movie in Items.sharedInstance.movieArray {
                        movieSorting.enter()
                        if !self.moviesSeen.contains(movie) {
                            self.moviesNotSeen.append(movie)
                        }
                        movieSorting.leave()
                    }
                    movieSorting.notify(queue: .main) {
                        self.navigationItem.title = String(self.moviesNotSeen.count) + " / " + String(Items.sharedInstance.movieArray.count) + " Movies To Watch"
                        self.seenTableView.dataSource = self
                        self.seenTableView.reloadData()
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return moviesSeen.count
        case 1:
            return moviesNotSeen.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsSeen", for: indexPath) as! FriendsSeenTableViewCell
        switch indexPath.section {
        case 0:
            cell.cover.image = moviesSeen[indexPath.row].cover
            cell.name.text = moviesSeen[indexPath.row].name
            cell.starring.text = "Starring: " + moviesSeen[indexPath.row].actors[0]
        case 1:
            cell.cover.image = moviesNotSeen[indexPath.row].cover
            cell.name.text = moviesNotSeen[indexPath.row].name
            cell.starring.text = "Starring: " + moviesNotSeen[indexPath.row].actors[0]
        default:
            print("There was an error")
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Movies Seen"
        case 1:
            return "Movies Not Seen"
        default:
            return nil
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColorFromRGB(rgbValue: 0x9B8742)
        
        let headerLabel = UILabel(frame: CGRect(x: 30, y: 0, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "Verdana", size: 20)
        headerLabel.textColor = UIColor.black
        if section == 0 {
            headerLabel.text = "Movies Seen"
        } else {
            headerLabel.text = "Movies Not Seen"
        }
        headerLabel.textAlignment = .center
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }*/
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
            view.tintColor = UIColorFromRGB(rgbValue: 0x9B8742)
            headerView.textLabel?.textColor = UIColor.black
        }
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
