//
//  FriendsSeenTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/17/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class FriendsSeenTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var starring: UILabel!
    @IBOutlet weak var cover: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
