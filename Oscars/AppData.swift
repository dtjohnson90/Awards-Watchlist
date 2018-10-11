//
//  userMovieList.swift
//  Oscars
//
//  Created by Dustin Johnson on 12/13/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import Foundation
import UIKit

class Items {
    static let sharedInstance = Items()
    
    struct movie: Equatable {
        let actors: [String]
        let cover: UIImage
        let description: String
        let idmb: String
        let name: String
        let nominatedFor: [String]
        let youtube: String
    }
    
    struct actors: Equatable {
        let name: String
        let image: UIImage
        let nominatedFor: String
        var movie: String
        var used: Bool
    }
    
    var movieArray = [movie]()
    var sortedMovieArray = [[movie]]()
    var moviesSeenArray = [movie]()
    var actorArray = [actors]()
    
    
    
    
    var userMovieList = [String]()
    var movieImageList = [[AnyObject]]()
    var actorList = [[String]]()
    var detailList = [[String]]()
    var youtubeList = [[String]]()
    var imdbList = [[String]]()
    var nominatedForList = [[String]]()
    var nominations = [String](repeating: "", count: 24)
    var testArray = [Bool](repeating: true, count: 24)
    var bpNominations = [Int](repeating: 0, count: 9), baNominations = [Int](repeating: 0, count: 5), basNominations = [Int](repeating: 0, count: 5), bsaNominations = [Int](repeating: 0, count: 5), bsasNominations = [Int](repeating: 0, count: 5), aNominations = [Int](repeating: 0, count: 5), cNominations = [Int](repeating: 0, count: 5),cdNominations = [Int](repeating: 0, count: 5), dNominations = [Int](repeating: 0, count: 5), dfNominations = [Int](repeating: 0, count: 5), dsNominations = [Int](repeating: 0, count: 5), feNominations = [Int](repeating: 0, count: 5), fNominations = [Int](repeating: 0, count: 5), mscNominations = [Int](repeating: 0, count: 5), msoNominations = [Int](repeating: 0, count: 5), pdNominations = [Int](repeating: 0, count: 5), saNominations = [Int](repeating: 0, count: 5), slNominations = [Int](repeating: 0, count: 5), seNominations = [Int](repeating: 0, count: 5), smNominations = [Int](repeating: 0, count: 5), veNominations = [Int](repeating: 0, count: 5), waNominations = [Int](repeating: 0, count: 5), woNominations = [Int](repeating: 0, count: 5), mNominations = [Int](repeating: 0, count: 3)
    var bestPicture = [String](), makeup = [String](), bestActor = [String](), bestActress = [String](), supportingActor = [String](), supportingActress = [String](), animated = [String](), cinematography = [String](), costumeDesign = [String](), directing = [String](), documentaryFeature = [String](), documentaryShort = [String](), filmEditing = [String](), foreignFilm = [String](), musicScore = [String](), musicSong = [String](), productionDesign = [String](), shortAnimated = [String](), shortLive = [String](), soundEditing = [String](), soundMixing = [String](), visualEffects = [String](), writingAdapted = [String](), writingOriginal = [String](), allMovieList = [String]()
    var allMovieDetails = [[String]]()
    var bpImage = [[Any]](), baImage = [[Any]](), basImage = [[Any]](), bsaImage = [[Any]](), bsasImage = [[Any]](), aImage = [[Any]](), cImage = [[Any]](), cdImage = [[Any]](), dImage = [[Any]](), dfImage = [[Any]](), dsImage = [[Any]](), feImage = [[Any]](), fImage = [[Any]](), mscImage = [[Any]](), msoImage = [[Any]](), pdImage = [[Any]](), shaImage = [[Any]](), shlImage = [[Any]](), seImage = [[Any]](), smImage = [[Any]](), veImage = [[Any]](), waImage = [[Any]](), woImage = [[Any]](), mImage = [[Any]]()
}
