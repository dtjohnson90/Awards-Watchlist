//
//  DetailViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/10/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import SystemConfiguration
import CloudKit

class DetailViewController: UIViewController {
    
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var haveWatched: UIButton!
    @IBOutlet var detailInfo: UIScrollView!
    @IBOutlet var wv: UIWebView!
    @IBOutlet var nominations: UILabel!
    var movieTitle = ""
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
    var postPic: UIImage?
    var loadingBool = true
    let container = CKContainer.default()
    var viewControllerTest = ""
    var imdbString = "http://www.imdb.com/title/"
    var u = 0
    var v = 0
    var w = 0
    var x = 0
    var y = 0
    var z = 0
    
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

        for _ in Items.sharedInstance.nominatedForList {
            if Items.sharedInstance.nominatedForList[v][1] == movieTitle {
                self.nominations.text =  Items.sharedInstance.nominatedForList[v][0]
                break
            }
            v += 1
        }
        for _ in Items.sharedInstance.actorList {
            if Items.sharedInstance.actorList[w][1] == movieTitle {
                self.movieCastLabel.text =  Items.sharedInstance.actorList[w][0]
                break
            }
            w += 1
        }
        for _ in Items.sharedInstance.detailList {
            if Items.sharedInstance.detailList[x][1] == movieTitle {
                self.detailDescriptionLabel.text = Items.sharedInstance.detailList[x][0]
                break
            }
            x += 1
        }
        for _ in Items.sharedInstance.movieImageList {
            if Items.sharedInstance.movieImageList[y][1] as! String == movieTitle {
                self.detailImage.image = Items.sharedInstance.movieImageList[y][0] as? UIImage
                break
            }
            y += 1
        }
        for _ in Items.sharedInstance.youtubeList {
            if Items.sharedInstance.youtubeList[z][1] == movieTitle {
                self.loadYoutube(videoID: Items.sharedInstance.youtubeList[z][0])
                break
            }
            z += 1
        }
        for _ in Items.sharedInstance.imdbList {
            if Items.sharedInstance.imdbList[u][1] == movieTitle {
                self.imdbString.append(Items.sharedInstance.imdbList[u][0])
                break
            }
            u += 1
        }
        
        haveWatched.layer.cornerRadius = haveWatched.frame.height / 2
        imdbButton.layer.cornerRadius = imdbButton.frame.height / 2
        
        self.navigationController?.navigationBar.tintColor = UIColor.brown;
        
        if Items.sharedInstance.userMovieList.contains(movieTitle) {
            haveWatched.setTitle("Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.green
        }
        else {
            haveWatched.setTitle("Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.red
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //navigationController?.hidesBarsOnSwipe = true
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
                if Items.sharedInstance.userMovieList.contains(movieTitle) {
                }
                else {
                    let movieRecordID = CKRecordID(recordName: movieTitle)
                    let movieRecord = CKRecord(recordType: "userMovieArray", recordID: movieRecordID)
                    movieRecord["Name"] = movieTitle as CKRecordValue
                    let privateDB2 = container.privateCloudDatabase
                    
                    privateDB2.save(movieRecord) {
                        (record, error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                            }
                            return
                        }
                    }
                    Items.sharedInstance.userMovieList.append(movieTitle)
                }
            }
            if buttonTitle == "Seen" {
                if Items.sharedInstance.userMovieList.contains(movieTitle) {
                    let movieRecordID = CKRecordID(recordName: movieTitle)
                    let privateDB3 = container.privateCloudDatabase
                    privateDB3.delete(withRecordID: movieRecordID, completionHandler: {movieRecordID, error in NSLog("OK")})
                    if let index = Items.sharedInstance.userMovieList.index(of:movieTitle)
                    {
                        print("Removed: " + Items.sharedInstance.userMovieList[index])
                        Items.sharedInstance.userMovieList.remove(at: index)
                    }
                }
                haveWatched.setTitle("Unseen", for: .normal)
                haveWatched.backgroundColor = UIColor.red
            }
        }
        if viewControllerTest == "A" {
            //self.performSegue(withIdentifier: "backToList", sender: self)
        }
        if viewControllerTest == "B" {
            //self.performSegue(withIdentifier: "backSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
