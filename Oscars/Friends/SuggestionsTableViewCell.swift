//
//  SuggestionsTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 11/6/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class SuggestionsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
