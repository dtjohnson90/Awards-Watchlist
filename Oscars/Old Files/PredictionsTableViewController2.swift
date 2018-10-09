//
//  PredictionsTableViewController2.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/15/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import CloudKit

class PredictionsTableViewController2: UITableViewController {

    var supportingActor = ["All the Money in the World","The Florida Project","The Shape of Water","Three Billboards Outside Ebbing, Missouri","Three Billboards Outside Ebbing, Missouri"]
    var bestActor2 = ["Timothée Chalamet","Gary Oldman","Daniel Kaluuya","Daniel Day-Lewis","Denzel Washington"]
    var bestActress2 = ["Margot Robbie","Saoirse Ronan","Meryl Streep","Sally Hawkins","Frances McDormand"]
    var supportingActor2 = ["Christopher Plummer", "Willem Dafoe", "Richard Jenkins", "Woody  Harrelson", "Sam Rockwell"]
    var supportingActress2 = ["Allison Janney", "Laurie Metcalf","Mary J. Blige","Lesley Manville","Octavia Spencer"]
    var directing2 = ["Christopher Nolan","Jordan Peele","Greta Gerwig","Paul Thomas Anderson","Guillermo del Toro"]
    var musicSong2 = ["Mystery of Love", "Remember Me","Stand Up For Something","Mighty River","This Is Me"]
    let container = CKContainer.default()
    @IBAction func unwindFromResults(segue: UIStoryboardSegue) {}
    
    @IBAction func resultsButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "resultsSegue", sender: self)
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieArray = [Items.sharedInstance.bestPicture,Items.sharedInstance.bestActor,Items.sharedInstance.bestActress,Items.sharedInstance.supportingActor,Items.sharedInstance.supportingActress,Items.sharedInstance.animated,Items.sharedInstance.cinematography,Items.sharedInstance.costumeDesign,Items.sharedInstance.directing,Items.sharedInstance.documentaryFeature,Items.sharedInstance.documentaryShort,Items.sharedInstance.filmEditing,Items.sharedInstance.foreignFilm,Items.sharedInstance.makeup,Items.sharedInstance.musicScore,Items.sharedInstance.musicSong,Items.sharedInstance.productionDesign,Items.sharedInstance.shortAnimated,Items.sharedInstance.shortLive,Items.sharedInstance.soundEditing,Items.sharedInstance.soundMixing,Items.sharedInstance.visualEffects,Items.sharedInstance.writingAdapted,Items.sharedInstance.writingOriginal]
        let currentMovie = movieArray[indexPath.section][indexPath.row]
        let privateDB = container.privateCloudDatabase
        var movieRecordID = CKRecordID(recordName: currentMovie)
        var movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
        
        if indexPath.section == 0 {
            if Items.sharedInstance.nominations[0] == "" {
                Items.sharedInstance.nominations[0] = currentMovie
                movieRecordID = CKRecordID(recordName: "BestPictureNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["BestPicture"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "BP" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "BestPictureNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["BestPicture"] = currentMovie as CKRecordValue
                        
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[0]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.bestPicture {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "BP" + String(indexPath.row + 1)
                let recordNameIndex2 = "BP" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[0] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 1) {
            if Items.sharedInstance.nominations[1] == "" {
                Items.sharedInstance.nominations[1] = currentMovie
                movieRecordID = CKRecordID(recordName: "BestActorNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["BestActor"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "BA" + String(indexPath.row + 1)
                print(recordNameIndex + ": " + currentMovie)
                changeNom2(recordNameIndex: recordNameIndex)
                
            }else {
                let recordID = CKRecordID(recordName: "BestActorNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["BestActor"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[1]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.bestActor {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "BA" + String(indexPath.row + 1)
                let recordNameIndex2 = "BA" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[1] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 2) {
            if Items.sharedInstance.nominations[2] == "" {
                Items.sharedInstance.nominations[2] = currentMovie
                movieRecordID = CKRecordID(recordName: "BestActressNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["BestActress"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "BAS" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "BestActressNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["BestActress"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[2]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.bestActress {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "BAS" + String(indexPath.row + 1)
                let recordNameIndex2 = "BAS" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[2] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 3) {
            if Items.sharedInstance.nominations[3] == "" {
                Items.sharedInstance.nominations[3] = currentMovie
                movieRecordID = CKRecordID(recordName: "SupportingActorNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["SupportingActor"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "BSA" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "SupportingActorNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["SupportingActor"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[3]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.supportingActor {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "BSA" + String(indexPath.row + 1)
                let recordNameIndex2 = "BSA" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[3] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 4) {
            if Items.sharedInstance.nominations[4] == "" {
                Items.sharedInstance.nominations[4] = currentMovie
                movieRecordID = CKRecordID(recordName: "SupportingActressNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["SupportingActress"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "BSAS" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "SupportingActressNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["SupportingActress"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[4]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.supportingActress {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "BSAS" + String(indexPath.row + 1)
                let recordNameIndex2 = "BSAS" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[4] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 5) {
            if Items.sharedInstance.nominations[5] == "" {
                Items.sharedInstance.nominations[5] = currentMovie
                movieRecordID = CKRecordID(recordName: "AnimatedNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["Animated"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "A" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "AnimatedNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["Animated"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[5]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.animated {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "A" + String(indexPath.row + 1)
                let recordNameIndex2 = "A" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[5] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 6) {
            if Items.sharedInstance.nominations[6] == "" {
                Items.sharedInstance.nominations[6] = currentMovie
                movieRecordID = CKRecordID(recordName: "CinematographyNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["Cinematography"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "C" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "CinematographyNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["Cinematography"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[6]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.cinematography {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "C" + String(indexPath.row + 1)
                let recordNameIndex2 = "C" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[6] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 7) {
            if Items.sharedInstance.nominations[7] == "" {
                Items.sharedInstance.nominations[7] = currentMovie
                movieRecordID = CKRecordID(recordName: "CostumeDesignNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["CostumeDesign"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "CD" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "CostumeDesignNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["CostumeDesign"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[7]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.costumeDesign {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "CD" + String(indexPath.row + 1)
                let recordNameIndex2 = "CD" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[7] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 8) {
            if Items.sharedInstance.nominations[8] == "" {
                Items.sharedInstance.nominations[8] = currentMovie
                movieRecordID = CKRecordID(recordName: "DirectingNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["Directing"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "D" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "DirectingNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["Directing"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[8]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.directing {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "D" + String(indexPath.row + 1)
                let recordNameIndex2 = "D" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[8] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 9) {
            if Items.sharedInstance.nominations[9] == "" {
                Items.sharedInstance.nominations[9] = currentMovie
                movieRecordID = CKRecordID(recordName: "DocumentaryFeatureNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["DocumentaryFeature"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "DF" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "DocumentaryFeatureNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["DocumentaryFeature"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[9]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.documentaryFeature {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "DF" + String(indexPath.row + 1)
                let recordNameIndex2 = "DF" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[9] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 10) {
            if Items.sharedInstance.nominations[10] == "" {
                Items.sharedInstance.nominations[10] = currentMovie
                movieRecordID = CKRecordID(recordName: "DocumentaryShortNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["DocumentaryShort"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "DS" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "DocumentaryShortNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["DocumentaryShort"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[10]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.documentaryShort {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "DS" + String(indexPath.row + 1)
                let recordNameIndex2 = "DS" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[10] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 11) {
            if Items.sharedInstance.nominations[11] == "" {
                movieRecordID = CKRecordID(recordName: "FilmEditingNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["FilmEditing"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "FE" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "FilmEditingNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["FilmEditing"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[11]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.filmEditing {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "FE" + String(indexPath.row + 1)
                let recordNameIndex2 = "FE" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[11] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 12) {
            if Items.sharedInstance.nominations[12] == "" {
                Items.sharedInstance.nominations[12] = currentMovie
                movieRecordID = CKRecordID(recordName: "ForeignNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["Foreign"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "F" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "ForeignNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["Foreign"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[12]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.foreignFilm {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "F" + String(indexPath.row + 1)
                let recordNameIndex2 = "F" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[12] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 13) {
            if Items.sharedInstance.nominations[13] == "" {
                Items.sharedInstance.nominations[13] = currentMovie
                movieRecordID = CKRecordID(recordName: "MakeupNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["Makeup"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "M" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "MakeupNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["Makeup"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[13]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.makeup {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "M" + String(indexPath.row + 1)
                let recordNameIndex2 = "M" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[13] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 14) {
            if Items.sharedInstance.nominations[14] == "" {
                Items.sharedInstance.nominations[14] = currentMovie
                movieRecordID = CKRecordID(recordName: "MusicOriginalScoreNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["MusicOriginalScore"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "MSC" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "MusicOriginalScoreNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["MusicOriginalScore"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[14]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.musicScore {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "MSC" + String(indexPath.row + 1)
                let recordNameIndex2 = "MSC" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[14] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 15) {
            if Items.sharedInstance.nominations[15] == "" {
                Items.sharedInstance.nominations[15] = currentMovie
                movieRecordID = CKRecordID(recordName: "MusicOriginalSongNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["MusicOriginalSong"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "MSO" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "MusicOriginalSongNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["MusicOriginalSong"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[15]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.musicSong {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "MSO" + String(indexPath.row + 1)
                let recordNameIndex2 = "MSO" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[15] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 16) {
            if Items.sharedInstance.nominations[16] == "" {
                Items.sharedInstance.nominations[16] = currentMovie
                movieRecordID = CKRecordID(recordName: "ProductionDesignNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["ProductionDesign"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "PD" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "ProductionDesignNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["ProductionDesign"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[16]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.productionDesign {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "PD" + String(indexPath.row + 1)
                let recordNameIndex2 = "PD" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[16] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 17) {
            if Items.sharedInstance.nominations[17] == "" {
                Items.sharedInstance.nominations[17] = currentMovie
                movieRecordID = CKRecordID(recordName: "ShortAnimatedNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["ShortAnimated"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "SA" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "ShortAnimatedNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["ShortAnimated"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[17]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.shortAnimated {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "SA" + String(indexPath.row + 1)
                let recordNameIndex2 = "SA" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[17] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 18) {
            if Items.sharedInstance.nominations[18] == "" {
                Items.sharedInstance.nominations[18] = currentMovie
                movieRecordID = CKRecordID(recordName: "ShortLiveNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["ShortLive"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "SL" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "ShortLiveNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["ShortLive"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[18]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.shortLive {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "SL" + String(indexPath.row + 1)
                let recordNameIndex2 = "SL" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[18] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 19) {
            if Items.sharedInstance.nominations[19] == "" {
                Items.sharedInstance.nominations[19] = currentMovie
                movieRecordID = CKRecordID(recordName: "SoundEditingNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["SoundEditing"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "SE" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "SoundEditingNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["SoundEditing"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[19]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.soundEditing {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "SE" + String(indexPath.row + 1)
                let recordNameIndex2 = "SE" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[19] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 20) {
            if Items.sharedInstance.nominations[20] == "" {
                Items.sharedInstance.nominations[20] = currentMovie
                movieRecordID = CKRecordID(recordName: "SoundMixingNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["SoundMixing"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "SM" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "SoundMixingNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["SoundMixing"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[20]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.soundMixing {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "SM" + String(indexPath.row + 1)
                let recordNameIndex2 = "SM" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[20] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 21) {
            if Items.sharedInstance.nominations[21] == "" {
                Items.sharedInstance.nominations[21] = currentMovie
                movieRecordID = CKRecordID(recordName: "VisualEffectsNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["VisualEffects"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "VE" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "VisualEffectsNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["VisualEffects"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: movieRecord)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[21]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.visualEffects {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "VE" + String(indexPath.row + 1)
                let recordNameIndex2 = "VE" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[21] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 22) {
            if Items.sharedInstance.nominations[22] == "" {
                Items.sharedInstance.nominations[22] = currentMovie
                movieRecordID = CKRecordID(recordName: "WritingAdaptedNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["WritingAdapted"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "WA" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "WritingAdaptedNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["WritingAdapted"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
                let previousMovie = Items.sharedInstance.nominations[22]
                var count = 0
                var movieIndex = 0
                for x in Items.sharedInstance.writingAdapted {
                    if x == previousMovie {
                        movieIndex = count
                    }
                    count += 1
                }
                let recordNameIndex = "WA" + String(indexPath.row + 1)
                let recordNameIndex2 = "WA" + String(movieIndex + 1)
                if previousMovie != currentMovie {
                    Items.sharedInstance.nominations[22] = currentMovie
                    changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
                }
            }
        } else if (indexPath.section == 23) {
            if Items.sharedInstance.nominations[23] == "" {
                Items.sharedInstance.nominations[23] = currentMovie
                movieRecordID = CKRecordID(recordName: "WritingOriginalNomination")
                movieRecord = CKRecord(recordType: "NominationsArray", recordID: movieRecordID)
                movieRecord["WritingOriginal"] = currentMovie as CKRecordValue
                databaseSave(movieRecord: movieRecord)
                let recordNameIndex = "WO" + String(indexPath.row + 1)
                changeNom2(recordNameIndex: recordNameIndex)
            }else {
                let recordID = CKRecordID(recordName: "WritingOriginalNomination")
                privateDB.fetch(withRecordID: recordID) { record, error in
                    if let record = record, error == nil {
                        record["WritingOriginal"] = currentMovie as CKRecordValue
                        self.databaseSave(movieRecord: record)
                    }
                }
            }
            let previousMovie = Items.sharedInstance.nominations[23]
            var count = 0
            var movieIndex = 0
            for x in Items.sharedInstance.writingOriginal {
                if x == previousMovie {
                    movieIndex = count
                }
                count += 1
            }
            let recordNameIndex = "WO" + String(indexPath.row + 1)
            let recordNameIndex2 = "WO" + String(movieIndex + 1)
            if previousMovie != currentMovie {
                Items.sharedInstance.nominations[23] = currentMovie
                changeNom(recordNameIndex: recordNameIndex, recordNameIndex2: recordNameIndex2, indexPath: indexPath.row)
            }
        }
        Items.sharedInstance.nominations[indexPath.section] = currentMovie
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return Items.sharedInstance.bestPicture.count
        } else if (section == 1) {
            return Items.sharedInstance.bestActor.count
        } else if (section == 2) {
            return Items.sharedInstance.bestActress.count
        } else if (section == 3) {
            return supportingActor.count
        } else if (section == 4) {
            return Items.sharedInstance.supportingActress.count
        } else if (section == 5) {
            return Items.sharedInstance.animated.count
        } else if (section == 6) {
            return Items.sharedInstance.cinematography.count
        } else if (section == 7) {
            return Items.sharedInstance.costumeDesign.count
        } else if (section == 8) {
            return Items.sharedInstance.directing.count
        } else if (section == 9) {
            return Items.sharedInstance.documentaryFeature.count
        } else if (section == 10) {
            return Items.sharedInstance.documentaryShort.count
        } else if (section == 11) {
            return Items.sharedInstance.filmEditing.count
        } else if (section == 12) {
            return Items.sharedInstance.foreignFilm.count
        } else if (section == 13) {
            return Items.sharedInstance.makeup.count
        } else if (section == 14) {
            return Items.sharedInstance.musicScore.count
        } else if (section == 15) {
            return Items.sharedInstance.musicSong.count
        } else if (section == 16) {
            return Items.sharedInstance.productionDesign.count
        } else if (section == 17) {
            return Items.sharedInstance.shortAnimated.count
        } else if (section == 18) {
            return Items.sharedInstance.shortLive.count
        } else if (section == 19) {
            return Items.sharedInstance.soundEditing.count
        } else if (section == 20) {
            return Items.sharedInstance.soundMixing.count
        } else if (section == 21) {
            return Items.sharedInstance.visualEffects.count
        } else if (section == 22) {
            return Items.sharedInstance.writingAdapted.count
        } else if (section == 23) {
            return Items.sharedInstance.writingOriginal.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if (indexPath.section == 0){
            let total = Double(Items.sharedInstance.bpNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.bpNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.bestPicture[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.bestPicture[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.bestPicture[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        } else if (indexPath.section == 1){
            let total = Double(Items.sharedInstance.baNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.baNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.bestActor[indexPath.row] + " (" + self.bestActor2[indexPath.row] + ")" + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.bestActor[indexPath.row] + " (" + self.bestActor2[indexPath.row] + ")" + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.bestActor[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        } else if (indexPath.section == 2){
            let total = Double(Items.sharedInstance.basNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.basNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.bestActress[indexPath.row] + " (" + self.bestActress2[indexPath.row] + ")" + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.bestActress[indexPath.row] + " (" + self.bestActress2[indexPath.row] + ")" + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.bestActress[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 3){
            let total = Double(Items.sharedInstance.bsaNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.bsaNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = supportingActor[indexPath.row] + " (" + self.supportingActor2[indexPath.row] + ")" + " -  0%"
            } else {
                cell.textLabel?.text = supportingActor[indexPath.row] + " (" + self.supportingActor2[indexPath.row] + ")" + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if supportingActor[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 4){
            let total = Double(Items.sharedInstance.bsasNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.bsasNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.supportingActress[indexPath.row] + " (" + self.supportingActress2[indexPath.row] + ")" + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.supportingActress[indexPath.row] + " (" + self.supportingActress2[indexPath.row] + ")" + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.supportingActress[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 5){
            let total = Double(Items.sharedInstance.aNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.aNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.animated[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.animated[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.animated[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 6){
            let total = Double(Items.sharedInstance.cNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.cNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.cinematography[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.cinematography[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.cinematography[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        } else if (indexPath.section == 7){
            let total = Double(Items.sharedInstance.cdNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.cdNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.costumeDesign[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.costumeDesign[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.costumeDesign[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 8){
            let total = Double(Items.sharedInstance.dNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.dNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.directing[indexPath.row] + " (" + self.directing2[indexPath.row] + ")" + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.directing[indexPath.row] + " (" + self.directing2[indexPath.row] + ")" + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.directing[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 9){
            let total = Double(Items.sharedInstance.dfNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.dfNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.documentaryFeature[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.documentaryFeature[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.documentaryFeature[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 10){
            let total = Double(Items.sharedInstance.dsNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.dsNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.documentaryShort[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.documentaryShort[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.documentaryShort[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 11){
            let total = Double(Items.sharedInstance.feNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.feNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.filmEditing[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.filmEditing[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.filmEditing[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 12){
            let total = Double(Items.sharedInstance.fNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.fNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.foreignFilm[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.foreignFilm[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.foreignFilm[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 13){
            let total = Double(Items.sharedInstance.mNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.mNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.makeup[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.makeup[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.makeup[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 14){
            let total = Double(Items.sharedInstance.mscNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.mscNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.musicScore[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.musicScore[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.musicScore[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 15){
            let total = Double(Items.sharedInstance.msoNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.msoNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.musicSong[indexPath.row] + " (" + self.musicSong2[indexPath.row] + ")" + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.musicSong[indexPath.row] + " (" + self.musicSong2[indexPath.row] + ")" + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.musicSong[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 16){
            let total = Double(Items.sharedInstance.pdNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.pdNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.productionDesign[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.productionDesign[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.productionDesign[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 17){
            let total = Double(Items.sharedInstance.saNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.saNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.shortAnimated[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.shortAnimated[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.shortAnimated[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 18){
            let total = Double(Items.sharedInstance.slNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.slNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.shortLive[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.shortLive[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.shortLive[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 19){
            let total = Double(Items.sharedInstance.seNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.seNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.soundEditing[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.soundEditing[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.soundEditing[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 20){
            let total = Double(Items.sharedInstance.smNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.smNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.soundMixing[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.soundMixing[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.soundMixing[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 21){
            let total = Double(Items.sharedInstance.veNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.veNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.visualEffects[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.visualEffects[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.visualEffects[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 22){
            let total = Double(Items.sharedInstance.waNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.waNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.writingAdapted[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.writingAdapted[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.writingAdapted[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
        }else if (indexPath.section == 23){
            let total = Double(Items.sharedInstance.woNominations.reduce(0, +))
            let temp = Double(Items.sharedInstance.woNominations[indexPath.row])
            let percent = temp / total * 100
            if percent.isNaN {
                cell.textLabel?.text = Items.sharedInstance.writingOriginal[indexPath.row] + " -  0%"
            } else {
                cell.textLabel?.text = Items.sharedInstance.writingOriginal[indexPath.row] + " - " + String(Int(percent)) + "%"
            }
            cell.textLabel?.textColor = UIColor.white
            if Items.sharedInstance.writingOriginal[indexPath.row] == Items.sharedInstance.nominations[indexPath.section]{
                cell.textLabel?.textColor = UIColor.green
            }
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
            return "Short Film (Animated)"
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
    
    func changeNom(recordNameIndex:String, recordNameIndex2:String, indexPath: Int){
        let publicDB = container.publicCloudDatabase
        
        let recordID2 = CKRecordID(recordName: recordNameIndex)
        let recordID3 = CKRecordID(recordName: recordNameIndex2)
        publicDB.fetch(withRecordID: recordID2) { record, error in
            if let record = record, error == nil {
                var count = record["Count"] as! Int
                count = count + 1
                record["Count"] = count as CKRecordValue
                
                publicDB.save(record) {
                    (record, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                        }
                        return
                    }
                }
            }
        }
        publicDB.fetch(withRecordID: recordID3) { record, error in
            if let record = record, error == nil {
                var count = record["Count"] as! Int
                count = count - 1
                record["Count"] = count as CKRecordValue
                
                publicDB.save(record) {
                    (record, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                        }
                        return
                    }
                }
            }
        }
    }
    
    func changeNom2(recordNameIndex: String) {
        let publicDB = container.publicCloudDatabase
        let recordID2 = CKRecordID(recordName: recordNameIndex)
        publicDB.fetch(withRecordID: recordID2) { record, error in
            if let record = record, error == nil {
                var count = record["Count"] as! Int
                count = count + 1
                record["Count"] = count as CKRecordValue
                
                publicDB.save(record) {
                    (record, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                        }
                        return
                    }
                }
            }
        }
    }
    
    func databaseSave(movieRecord: CKRecord){
        let privateDB = container.privateCloudDatabase
        privateDB.save(movieRecord) {
            (record, error) in
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                }
                return
            }
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
