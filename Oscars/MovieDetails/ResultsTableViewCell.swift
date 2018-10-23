//
//  ResultsTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/15/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePercent: UILabel!
    @IBOutlet weak var movieVotes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
