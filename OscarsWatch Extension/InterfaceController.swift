//
//  InterfaceController.swift
//  OscarsWatch Extension
//
//  Created by Dustin Johnson on 1/30/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import WatchKit
import Foundation
import CloudKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var bpTable: WKInterfaceTable!
    @IBOutlet var baTable: WKInterfaceTable!
    @IBOutlet var basTable: WKInterfaceTable!
    @IBOutlet var bsaTable: WKInterfaceTable!
    @IBOutlet var bsasTable: WKInterfaceTable!
    @IBOutlet var aTable: WKInterfaceTable!
    @IBOutlet var cTable: WKInterfaceTable!
    @IBOutlet var cdTable: WKInterfaceTable!
    @IBOutlet var dTable: WKInterfaceTable!
    @IBOutlet var dfTable: WKInterfaceTable!
    @IBOutlet var dsTable: WKInterfaceTable!
    @IBOutlet var feTable: WKInterfaceTable!
    @IBOutlet var fTable: WKInterfaceTable!
    @IBOutlet var mTable: WKInterfaceTable!
    @IBOutlet var oscTable: WKInterfaceTable!
    @IBOutlet var osoTable: WKInterfaceTable!
    @IBOutlet var pdTable: WKInterfaceTable!
    @IBOutlet var shaTable: WKInterfaceTable!
    @IBOutlet var shlTable: WKInterfaceTable!
    @IBOutlet var seTable: WKInterfaceTable!
    @IBOutlet var smTable: WKInterfaceTable!
    @IBOutlet var veTable: WKInterfaceTable!
    @IBOutlet var waTable: WKInterfaceTable!
    @IBOutlet var woTable: WKInterfaceTable!
    @IBAction func unseenMenuItem() {
        var moviesLeftList = [Items2.movie]()
        for movie in Items2.sharedInstance.movieArray {
            if !Items2.sharedInstance.moviesSeenArray.contains(movie) {
                moviesLeftList.append(movie)
            }
        }
        moviesLeftList.sort { $0.name < $1.name }
        pushController(withName: "UnseenController", context: moviesLeftList)
    }
    
    let session = WCSession.default
    var bestActorArray = [Items2.actors]()
    var bestActressArray = [Items2.actors]()
    var supportingActorArray = [Items2.actors]()
    var supportingActressArray = [Items2.actors]()
    var directorArray = [Items2.actors]()

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.processApplicationContext()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            let movieArray = Items2.sharedInstance.sortedMovieArray
            self.bpTable.setNumberOfRows(movieArray[0].count, withRowType: "nominationRow")
            for index in 0..<movieArray[0].count {
                guard let controller = self.bpTable.rowController(at: index) as? NominationsRowController else { continue }
                controller.bpName.setText(movieArray[0][index].name)
                if index == 7 {
                    controller.bpName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.baTable.setNumberOfRows(movieArray[1].count, withRowType: "nominationRow")
            for index in 0..<self.bestActorArray.count {
                guard let controller = self.baTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.baName.setText(self.bestActorArray[index].name)
                if index == 1 {
                    controller.baName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.basTable.setNumberOfRows(movieArray[2].count, withRowType: "nominationRow")
            for index in 0..<self.bestActressArray.count {
                guard let controller = self.basTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.basName.setText(self.bestActressArray[index].name)
                if index == 4 {
                    controller.basName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.bsaTable.setNumberOfRows(self.supportingActorArray.count, withRowType: "nominationRow")
            for index in 0..<movieArray[3].count {
                guard let controller = self.bsaTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.saName.setText(self.supportingActorArray[index].name)
                if index == 4 {
                    controller.saName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.bsasTable.setNumberOfRows(self.supportingActressArray.count, withRowType: "nominationRow")
            for index in 0..<movieArray[4].count {
                guard let controller = self.bsasTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.sasName.setText(self.supportingActressArray[index].name)
                if index == 0 {
                    controller.sasName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.aTable.setNumberOfRows(movieArray[5].count, withRowType: "nominationRow")
            for index in 0..<movieArray[5].count {
                guard let controller = self.aTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.aName.setText(movieArray[5][index].name)
                if index == 0 {
                    controller.aName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.cTable.setNumberOfRows(movieArray[6].count, withRowType: "nominationRow")
            for index in 0..<movieArray[6].count {
                guard let controller = self.cTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.cName.setText(movieArray[6][index].name)
                if index == 0 {
                    controller.cName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.cdTable.setNumberOfRows(movieArray[7].count, withRowType: "nominationRow")
            for index in 0..<movieArray[7].count {
                guard let controller = self.cdTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.cdName.setText(movieArray[7][index].name)
                if index == 2 {
                    controller.cdName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.dTable.setNumberOfRows(self.directorArray.count, withRowType: "nominationRow")
            for index in 0..<movieArray[8].count {
                guard let controller = self.dTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.dName.setText(self.directorArray[index].name)
                if index == 4 {
                    controller.dName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.dfTable.setNumberOfRows(movieArray[9].count, withRowType: "nominationRow")
            for index in 0..<movieArray[9].count {
                guard let controller = self.dfTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.dfName.setText(movieArray[9][index].name)
                if index == 2 {
                    controller.dfName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.dsTable.setNumberOfRows(movieArray[10].count, withRowType: "nominationRow")
            for index in 0..<movieArray[10].count {
                guard let controller = self.dsTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.dshName.setText(movieArray[10][index].name)
                if index == 1 {
                    controller.dshName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.feTable.setNumberOfRows(movieArray[11].count, withRowType: "nominationRow")
            for index in 0..<movieArray[11].count {
                guard let controller = self.feTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.feName.setText(movieArray[11][index].name)
                if index == 1 {
                    controller.feName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.fTable.setNumberOfRows(movieArray[12].count, withRowType: "nominationRow")
            for index in 0..<movieArray[12].count {
                guard let controller = self.fTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.fName.setText(movieArray[12][index].name)
                if index == 0 {
                    controller.fName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.mTable.setNumberOfRows(movieArray[13].count, withRowType: "nominationRow")
            for index in 0..<movieArray[13].count {
                guard let controller = self.mTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.mName.setText(movieArray[13][index].name)
                if index == 0 {
                    controller.mName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.oscTable.setNumberOfRows(movieArray[14].count, withRowType: "nominationRow")
            for index in 0..<movieArray[14].count {
                guard let controller = self.oscTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.mscName.setText(movieArray[14][index].name)
                if index == 3 {
                    controller.mscName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.osoTable.setNumberOfRows(movieArray[15].count, withRowType: "nominationRow")
            for index in 0..<movieArray[15].count {
                guard let controller = self.osoTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.msoName.setText(movieArray[15][index].name)
                if index == 1 {
                    controller.msoName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.pdTable.setNumberOfRows(movieArray[16].count, withRowType: "nominationRow")
            for index in 0..<movieArray[16].count {
                guard let controller = self.pdTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.pdName.setText(movieArray[16][index].name)
                if index == 4 {
                    controller.pdName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.shaTable.setNumberOfRows(movieArray[17].count, withRowType: "nominationRow")
            for index in 0..<movieArray[17].count {
                guard let controller = self.shaTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.shaName.setText(movieArray[17][index].name)
                if index == 0 {
                    controller.shaName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.shlTable.setNumberOfRows(movieArray[18].count, withRowType: "nominationRow")
            for index in 0..<movieArray[18].count {
                guard let controller = self.shlTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.shlName.setText(movieArray[18][index].name)
                if index == 3 {
                    controller.shlName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.seTable.setNumberOfRows(movieArray[19].count, withRowType: "nominationRow")
            for index in 0..<movieArray[19].count {
                guard let controller = self.seTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.seName.setText(movieArray[19][index].name)
                if index == 2 {
                    controller.seName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.smTable.setNumberOfRows(movieArray[20].count, withRowType: "nominationRow")
            for index in 0..<movieArray[20].count {
                guard let controller = self.smTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.smName.setText(movieArray[20][index].name)
                if index == 2 {
                    controller.smName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.veTable.setNumberOfRows(movieArray[21].count, withRowType: "nominationRow")
            for index in 0..<movieArray[21].count {
                guard let controller = self.veTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.veName.setText(movieArray[21][index].name)
                if index == 0 {
                    controller.veName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.waTable.setNumberOfRows(movieArray[22].count, withRowType: "nominationRow")
            for index in 0..<movieArray[22].count {
                guard let controller = self.waTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.waName.setText(movieArray[22][index].name)
                if index == 0 {
                    controller.waName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.woTable.setNumberOfRows(movieArray[23].count, withRowType: "nominationRow")
            for index in 0..<movieArray[23].count {
                guard let controller = self.woTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.woName.setText(movieArray[23][index].name)
                if index == 0 {
                    controller.woName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        session.delegate = self
        session.activate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func processApplicationContext() {
        if let iPhoneContext = session.receivedApplicationContext as? [String : Any] {
            let movieArray = iPhoneContext["Details"] as! NSArray
            let moviesSeen = iPhoneContext["Seen"] as! NSArray
            let actors = iPhoneContext["Actors"] as! NSArray
            for _ in 0 ... 23 {
                Items2.sharedInstance.sortedMovieArray.append([Items2.movie]())
            }
            
            let movieDownloading = DispatchGroup()
            for movie2 in movieArray {
                movieDownloading.enter()
                let tempAll = movie2 as! NSDictionary
                Items2.sharedInstance.movieArray.append(Items2.movie(actors: tempAll.object(forKey: "Actors") as! [String], description: tempAll.object(forKey: "Description") as! String, name: tempAll.object(forKey: "Name") as! String, nominatedFor: tempAll.object(forKey: "NominatedFor") as! [String]))
                movieDownloading.leave()
            }
            movieDownloading.notify(queue: .main) {
                for movie in Items2.sharedInstance.movieArray {
                    for nomination in movie.nominatedFor {
                        switch nomination {
                        case "Best Picture":
                            Items2.sharedInstance.sortedMovieArray[0].append(movie)
                        case "Best Actor":
                            Items2.sharedInstance.sortedMovieArray[1].append(movie)
                        case "Best Actress":
                            Items2.sharedInstance.sortedMovieArray[2].append(movie)
                        case "Supporting Actor":
                            Items2.sharedInstance.sortedMovieArray[3].append(movie)
                        case "Supporting Actress":
                            Items2.sharedInstance.sortedMovieArray[4].append(movie)
                        case "Animated":
                            Items2.sharedInstance.sortedMovieArray[5].append(movie)
                        case "Cinematography":
                            Items2.sharedInstance.sortedMovieArray[6].append(movie)
                        case "Costume Design":
                            Items2.sharedInstance.sortedMovieArray[7].append(movie)
                        case "Directing":
                            Items2.sharedInstance.sortedMovieArray[8].append(movie)
                        case "Documentary Feature":
                            Items2.sharedInstance.sortedMovieArray[9].append(movie)
                        case "Documentary Short":
                            Items2.sharedInstance.sortedMovieArray[10].append(movie)
                        case "Film Editing":
                            Items2.sharedInstance.sortedMovieArray[11].append(movie)
                        case "Foreign Film":
                            Items2.sharedInstance.sortedMovieArray[12].append(movie)
                        case "Makeup":
                            Items2.sharedInstance.sortedMovieArray[13].append(movie)
                        case "Music Score":
                            Items2.sharedInstance.sortedMovieArray[14].append(movie)
                        case "Music Song":
                            Items2.sharedInstance.sortedMovieArray[15].append(movie)
                        case "Production Design":
                            Items2.sharedInstance.sortedMovieArray[16].append(movie)
                        case "Animated Short":
                            Items2.sharedInstance.sortedMovieArray[17].append(movie)
                        case "Live Action Short":
                            Items2.sharedInstance.sortedMovieArray[18].append(movie)
                        case "Sound Editing":
                            Items2.sharedInstance.sortedMovieArray[19].append(movie)
                        case "Sound Mixing":
                            Items2.sharedInstance.sortedMovieArray[20].append(movie)
                        case "Visual Effects":
                            Items2.sharedInstance.sortedMovieArray[21].append(movie)
                        case "Writing Adapted":
                            Items2.sharedInstance.sortedMovieArray[22].append(movie)
                        case "Writing Original":
                            Items2.sharedInstance.sortedMovieArray[23].append(movie)
                        default:
                            print("There was an error")
                        }
                    }
                }
            }
            
            for movie3 in moviesSeen {
                let seen = movie3 as! NSDictionary
                Items2.sharedInstance.moviesSeenArray.append(Items2.movie(actors: seen.object(forKey: "Actors") as! [String], description: seen.object(forKey: "Description") as! String, name: seen.object(forKey: "Name") as! String, nominatedFor: seen.object(forKey: "NominatedFor") as! [String]))
            }
            
            let actorDownloading = DispatchGroup()
            print(actors.count)
            for actor in actors {
                actorDownloading.enter()
                let tempActor = actor as! NSDictionary
                Items2.sharedInstance.actorArray.append(Items2.actors(name: tempActor.object(forKey: "Name") as! String, nominatedFor: tempActor.object(forKey: "NominatedFor") as! String, movie: tempActor.object(forKey: "Movie") as! String))
                actorDownloading.leave()
            }
            actorDownloading.notify(queue: .main) {
                for item in Items2.sharedInstance.actorArray {
                    switch item.nominatedFor {
                    case "Best Actor":
                        self.bestActorArray.append(item)
                    case "Supporting Actor":
                        self.supportingActorArray.append(item)
                    case "Best Actress":
                        self.bestActressArray.append(item)
                    case "Supporting Actress":
                        self.supportingActressArray.append(item)
                    case "Directing":
                        self.directorArray.append(item)
                    default:
                        return
                    }
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.processApplicationContext()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var movie: Items2.movie
        if table == bpTable {
            movie = Items2.sharedInstance.sortedMovieArray[0][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == baTable {
            let movieName = bestActorArray[rowIndex].movie
            for item in Items2.sharedInstance.movieArray {
                if movieName == item.name {
                    presentController(withName: "DetailController", context: item)
                    break
                }
            }
        } else if table == bsaTable {
            let movieName = supportingActorArray[rowIndex].movie
            for item in Items2.sharedInstance.movieArray {
                if movieName == item.name {
                    presentController(withName: "DetailController", context: item)
                    break
                }
            }
        }else if table == basTable {
            let movieName = bestActressArray[rowIndex].movie
            print(movieName)
            for item in Items2.sharedInstance.movieArray {
                if movieName == item.name {
                    print(item.name)
                    presentController(withName: "DetailController", context: item)
                    break
                }
            }
        } else if table == bsasTable {
            let movieName = supportingActressArray[rowIndex].movie
            for item in Items2.sharedInstance.movieArray {
                if movieName == item.name {
                    presentController(withName: "DetailController", context: item)
                    break
                }
            }
        } else if table == aTable {
            movie = Items2.sharedInstance.sortedMovieArray[5][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == cTable {
            movie = Items2.sharedInstance.sortedMovieArray[6][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == cdTable {
            movie = Items2.sharedInstance.sortedMovieArray[7][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == dTable {
            let movieName = directorArray[rowIndex].movie
            for item in Items2.sharedInstance.movieArray {
                if movieName == item.name {
                    presentController(withName: "DetailController", context: item)
                    break
                }
            }
        } else if table == dfTable {
            movie = Items2.sharedInstance.sortedMovieArray[9][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == dsTable {
            movie = Items2.sharedInstance.sortedMovieArray[10][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == feTable {
            movie = Items2.sharedInstance.sortedMovieArray[11][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == fTable {
            movie = Items2.sharedInstance.sortedMovieArray[12][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == mTable {
            movie = Items2.sharedInstance.sortedMovieArray[13][rowIndex]
            presentController(withName: "DetailController", context: movie)
        }
        else if table == oscTable {
            movie = Items2.sharedInstance.sortedMovieArray[14][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == osoTable {
            movie = Items2.sharedInstance.sortedMovieArray[15][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == pdTable {
            movie = Items2.sharedInstance.sortedMovieArray[16][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == shaTable {
            movie = Items2.sharedInstance.sortedMovieArray[17][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == shlTable {
            movie = Items2.sharedInstance.sortedMovieArray[18][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == seTable {
            movie = Items2.sharedInstance.sortedMovieArray[19][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == smTable {
            movie = Items2.sharedInstance.sortedMovieArray[20][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == veTable {
            movie = Items2.sharedInstance.sortedMovieArray[21][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == waTable {
            movie = Items2.sharedInstance.sortedMovieArray[22][rowIndex]
            presentController(withName: "DetailController", context: movie)
        } else if table == woTable {
            movie = Items2.sharedInstance.sortedMovieArray[23][rowIndex]
            presentController(withName: "DetailController", context: movie)
        }
    }
}
