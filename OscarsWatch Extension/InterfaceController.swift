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
        var moviesLeftList = allMovieList
        var userMovieList = [String]()
        for item in allMovieDetails {
            if item[4] == "Seen" {
                userMovieList.append(item[0])
            }
        }
        moviesLeftList = moviesLeftList.filter { !userMovieList.contains($0) }
        moviesLeftList = moviesLeftList.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        pushController(withName: "UnseenController", context: moviesLeftList)
    }
    
    var bestPicture = [String](), makeup = [String](), bestActor = [String](), bestActress = [String](), supportingActor = [String](), supportingActress = [String](), animated = [String](), cinematography = [String](), costumeDesign = [String](), directing = [String](), documentaryFeature = [String](), documentaryShort = [String](), filmEditing = [String](), foreignFilm = [String](), musicScore = [String](), musicSong = [String](), productionDesign = [String](), shortAnimated = [String](), shortLive = [String](), soundEditing = [String](), soundMixing = [String](), visualEffects = [String](), writingAdapted = [String](), writingOriginal = [String](), allMovieList = [String]()
    var bestActor2 = ["Timothée Chalamet","Gary Oldman","Daniel Kaluuya","Daniel Day-Lewis","Denzel Washington"]
    var bestActress2 = ["Margot Robbie","Saoirse Ronan","Meryl Streep","Sally Hawkins","Frances McDormand"]
    var supportingActor2 = ["Christopher Plummer", "Willem Dafoe", "Richard Jenkins", "Woody Harrelson", "Sam Rockwell"]
    var supportingActress2 = ["Allison Janney", "Laurie Metcalf","Mary J. Blige","Lesley Manville","Octavia Spencer"]
    var directing2 = ["Christopher Nolan","Jordan Peele","Greta Gerwig","Paul Thomas Anderson","Guillermo del Toro"]
    var musicSong2 = ["Mystery of Love", "Remember Me","Stand Up For Something","Mighty River","This Is Me"]
    let session = WCSession.default
    var allMovieDetails = [[String]]()
    //@IBOutlet var nominationName: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.processApplicationContext()
            self.bpTable.setNumberOfRows(self.bestPicture.count, withRowType: "nominationRow")
            for index in 0..<self.bestPicture.count {
                guard let controller = self.bpTable.rowController(at: index) as? NominationsRowController else { continue }
                controller.bpName.setText(self.bestPicture[index])
                if index == 7 {
                    controller.bpName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.baTable.setNumberOfRows(self.bestActor.count, withRowType: "nominationRow")
            for index in 0..<self.bestActor.count {
                guard let controller = self.baTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.baName.setText(self.bestActor2[index])
                if index == 1 {
                    controller.baName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.basTable.setNumberOfRows(self.bestActress.count, withRowType: "nominationRow")
            for index in 0..<self.bestActress.count {
                guard let controller = self.basTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.basName.setText(self.bestActress2[index])
                if index == 4 {
                    controller.basName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.bsaTable.setNumberOfRows(self.supportingActor.count, withRowType: "nominationRow")
            for index in 0..<self.supportingActor.count {
                guard let controller = self.bsaTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.saName.setText(self.supportingActor2[index])
                if index == 4 {
                    controller.saName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.bsasTable.setNumberOfRows(self.supportingActress.count, withRowType: "nominationRow")
            for index in 0..<self.supportingActress.count {
                guard let controller = self.bsasTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.sasName.setText(self.supportingActress2[index])
                if index == 0 {
                    controller.sasName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.aTable.setNumberOfRows(self.animated.count, withRowType: "nominationRow")
            for index in 0..<self.animated.count {
                guard let controller = self.aTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.aName.setText(self.animated[index])
                if index == 0 {
                    controller.aName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.cTable.setNumberOfRows(self.cinematography.count, withRowType: "nominationRow")
            for index in 0..<self.cinematography.count {
                guard let controller = self.cTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.cName.setText(self.cinematography[index])
                if index == 0 {
                    controller.cName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.cdTable.setNumberOfRows(self.costumeDesign.count, withRowType: "nominationRow")
            for index in 0..<self.costumeDesign.count {
                guard let controller = self.cdTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.cdName.setText(self.costumeDesign[index])
                if index == 2 {
                    controller.cdName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.dTable.setNumberOfRows(self.directing.count, withRowType: "nominationRow")
            for index in 0..<self.directing.count {
                guard let controller = self.dTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.dName.setText(self.directing2[index])
                if index == 4 {
                    controller.dName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.dfTable.setNumberOfRows(self.documentaryFeature.count, withRowType: "nominationRow")
            for index in 0..<self.documentaryFeature.count {
                guard let controller = self.dfTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.dfName.setText(self.documentaryFeature[index])
                if index == 2 {
                    controller.dfName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.dsTable.setNumberOfRows(self.documentaryShort.count, withRowType: "nominationRow")
            for index in 0..<self.documentaryShort.count {
                guard let controller = self.dsTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.dshName.setText(self.documentaryShort[index])
                if index == 1 {
                    controller.dshName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.feTable.setNumberOfRows(self.filmEditing.count, withRowType: "nominationRow")
            for index in 0..<self.filmEditing.count {
                guard let controller = self.feTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.feName.setText(self.filmEditing[index])
                if index == 1 {
                    controller.feName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.fTable.setNumberOfRows(self.foreignFilm.count, withRowType: "nominationRow")
            for index in 0..<self.foreignFilm.count {
                guard let controller = self.fTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.fName.setText(self.foreignFilm[index])
                if index == 0 {
                    controller.fName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.mTable.setNumberOfRows(self.makeup.count, withRowType: "nominationRow")
            for index in 0..<self.makeup.count {
                guard let controller = self.mTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.mName.setText(self.makeup[index])
                if index == 0 {
                    controller.mName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.oscTable.setNumberOfRows(self.musicScore.count, withRowType: "nominationRow")
            for index in 0..<self.musicScore.count {
                guard let controller = self.oscTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.mscName.setText(self.musicScore[index])
                if index == 3 {
                    controller.mscName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.osoTable.setNumberOfRows(self.musicSong.count, withRowType: "nominationRow")
            for index in 0..<self.musicSong.count {
                guard let controller = self.osoTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.msoName.setText(self.musicSong2[index])
                if index == 1 {
                    controller.msoName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.pdTable.setNumberOfRows(self.productionDesign.count, withRowType: "nominationRow")
            for index in 0..<self.productionDesign.count {
                guard let controller = self.pdTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.pdName.setText(self.productionDesign[index])
                if index == 4 {
                    controller.pdName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.shaTable.setNumberOfRows(self.shortAnimated.count, withRowType: "nominationRow")
            for index in 0..<self.shortAnimated.count {
                guard let controller = self.shaTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.shaName.setText(self.shortAnimated[index])
                if index == 0 {
                    controller.shaName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.shlTable.setNumberOfRows(self.shortLive.count, withRowType: "nominationRow")
            for index in 0..<self.shortLive.count {
                guard let controller = self.shlTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.shlName.setText(self.shortLive[index])
                if index == 3 {
                    controller.shlName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.seTable.setNumberOfRows(self.soundEditing.count, withRowType: "nominationRow")
            for index in 0..<self.soundEditing.count {
                guard let controller = self.seTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.seName.setText(self.soundEditing[index])
                if index == 2 {
                    controller.seName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.smTable.setNumberOfRows(self.soundMixing.count, withRowType: "nominationRow")
            for index in 0..<self.soundMixing.count {
                guard let controller = self.smTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.smName.setText(self.soundMixing[index])
                if index == 2 {
                    controller.smName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.veTable.setNumberOfRows(self.visualEffects.count, withRowType: "nominationRow")
            for index in 0..<self.visualEffects.count {
                guard let controller = self.veTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.veName.setText(self.visualEffects[index])
                if index == 0 {
                    controller.veName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.waTable.setNumberOfRows(self.writingAdapted.count, withRowType: "nominationRow")
            for index in 0..<self.writingAdapted.count {
                guard let controller = self.waTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.waName.setText(self.writingAdapted[index])
                if index == 0 {
                    controller.waName.setTextColor(UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0))
                }
            }
            self.woTable.setNumberOfRows(self.writingOriginal.count, withRowType: "nominationRow")
            for index in 0..<self.writingOriginal.count {
                guard let controller = self.woTable.rowController(at: index ) as? NominationsRowController else { continue }
                controller.woName.setText(self.writingOriginal[index])
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
        if let iPhoneContext = session.receivedApplicationContext as? [String : [[String]]] {
            let nominationArray = iPhoneContext["Nominations"]
            bestPicture = nominationArray![0]
            bestActor = nominationArray![1]
            bestActress = nominationArray![2]
            supportingActor = nominationArray![3]
            supportingActress = nominationArray![4]
            animated = nominationArray![5]
            cinematography = nominationArray![6]
            costumeDesign = nominationArray![7]
            directing = nominationArray![8]
            documentaryFeature = nominationArray![9]
            documentaryShort = nominationArray![10]
            filmEditing = nominationArray![11]
            foreignFilm = nominationArray![12]
            makeup = nominationArray![13]
            musicScore = nominationArray![14]
            musicSong = nominationArray![15]
            productionDesign = nominationArray![16]
            shortAnimated = nominationArray![17]
            shortLive = nominationArray![18]
            soundEditing = nominationArray![19]
            soundMixing = nominationArray![20]
            visualEffects = nominationArray![21]
            writingAdapted = nominationArray![22]
            writingOriginal = nominationArray![23]
            allMovieList = nominationArray![24]
            let movieDetailsArray = iPhoneContext["Details"]
            allMovieDetails = movieDetailsArray!
            Items2.sharedInstance.allMovieDetails = movieDetailsArray!
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    private func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var movie = [String]()
        if table == bpTable {
            for item in allMovieDetails {
                if item[0] == bestPicture[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == baTable {
            for item in allMovieDetails {
                if item[0] == bestActor[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == bsaTable {
            for item in allMovieDetails {
                if item[0] == supportingActor[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        }else if table == basTable {
            for item in allMovieDetails {
                if item[0] == bestActress[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == bsasTable {
            for item in allMovieDetails {
                if item[0] == supportingActress[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == aTable {
            for item in allMovieDetails {
                if item[0] == animated[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == cTable {
            for item in allMovieDetails {
                if item[0] == cinematography[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == cdTable {
            for item in allMovieDetails {
                if item[0] == costumeDesign[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == dTable {
            for item in allMovieDetails {
                if item[0] == directing[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == dfTable {
            for item in allMovieDetails {
                if item[0] == documentaryFeature[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == dsTable {
            for item in allMovieDetails {
                if item[0] == documentaryShort[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == feTable {
            for item in allMovieDetails {
                if item[0] == filmEditing[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == fTable {
            for item in allMovieDetails {
                if item[0] == foreignFilm[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == mTable {
            for item in allMovieDetails {
                if item[0] == makeup[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        }
        else if table == oscTable {
            for item in allMovieDetails {
                if item[0] == musicScore[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        }
        else if table == osoTable {
            for item in allMovieDetails {
                if item[0] == musicSong[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == pdTable {
            for item in allMovieDetails {
                if item[0] == productionDesign[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == shaTable {
            for item in allMovieDetails {
                if item[0] == shortAnimated[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == shlTable {
            for item in allMovieDetails {
                if item[0] == shortLive[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == seTable {
            for item in allMovieDetails {
                if item[0] == soundEditing[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == smTable {
            for item in allMovieDetails {
                if item[0] == soundMixing[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == veTable {
            for item in allMovieDetails {
                if item[0] == visualEffects[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == waTable {
            for item in allMovieDetails {
                if item[0] == writingAdapted[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        } else if table == woTable {
            for item in allMovieDetails {
                if item[0] == writingOriginal[rowIndex] {
                    movie = item
                    break
                }
            }
            presentController(withName: "DetailController", context: movie)
        }
    }
}
