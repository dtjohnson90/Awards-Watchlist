//
//  DetailViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/10/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import SystemConfiguration

class DetailViewController: UIViewController {
    
    var movieSelected = Items.movie(actors: [String](), cover: UIImage(), description: String(), idmb: String(), name: String(), nominatedFor: [String](), youtube: String())
    var nominationString = ""
    var movieCast = ""
    var imdbString = "http://www.imdb.com/title/"
    
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var haveWatched: UIButton!
    @IBOutlet var detailInfo: UIScrollView!
    @IBOutlet var wv: UIWebView!
    @IBOutlet var nominations: UILabel!
    @IBOutlet var movieCastLabel: UILabel! = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    @IBOutlet var detailDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    @IBAction func imdbButtonClick(_ sender: UIButton) {
        print(imdbString)
        guard let url = URL(string: imdbString) else {
            return //be safe
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBOutlet var imdbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailInfo.addSubview(detailDescriptionLabel)
        detailInfo.addSubview(movieCastLabel)
        
        
        let nomDis = DispatchGroup()
        for nomination in movieSelected.nominatedFor {
            nomDis.enter()
            nominationString.append(nomination + "\n")
            nomDis.leave()
        }
        nomDis.notify(queue: .main) {
            self.nominations.text = self.nominationString
        }
        
        
        let castDis = DispatchGroup()
        for actor in movieSelected.nominatedFor {
            castDis.enter()
            movieCast.append(actor + "\n")
            castDis.leave()
        }
        castDis.notify(queue: .main) {
            self.movieCastLabel.text = self.movieCast
        }
        
        detailDescriptionLabel.text = movieSelected.description
        detailImage.image = movieSelected.cover
        loadYoutube(videoID: movieSelected.youtube)
        imdbString.append(movieSelected.idmb)
        
        haveWatched.layer.cornerRadius = haveWatched.frame.height / 2
        imdbButton.layer.cornerRadius = imdbButton.frame.height / 2
        
        self.navigationController?.navigationBar.tintColor = UIColor.brown;
        
        if Items.sharedInstance.moviesSeenArray.contains(movieSelected) {
            haveWatched.setTitle("Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.green
        }
        else {
            haveWatched.setTitle("Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.red
        }
    }
    
    func loadYoutube(videoID:String) {
        guard
            let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)")
            else { return }
        wv.loadRequest( URLRequest(url: youtubeURL) )
    }
    
    @IBAction func haveWatchedClick(_ sender: UIButton) {
        if let buttonTitle = sender.title(for: .normal) {
            if buttonTitle == "Unseen" {
                haveWatched.setTitle("Seen", for: .normal)
                haveWatched.backgroundColor = UIColor.green
                Items.sharedInstance.moviesSeenArray.append(movieSelected)
            } else {
                haveWatched.setTitle("Unseen", for: .normal)
                haveWatched.backgroundColor = UIColor.red
                Items.sharedInstance.moviesSeenArray.remove(at: Items.sharedInstance.moviesSeenArray.index(of:movieSelected)!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
