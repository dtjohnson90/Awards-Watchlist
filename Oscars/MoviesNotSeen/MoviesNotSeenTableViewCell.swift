//
//  MoviesNotSeenTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/10/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class MoviesNotSeenTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieStarring: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
