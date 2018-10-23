//
//  FriendPredictionsTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/17/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class FriendPredictionsTableViewCell: UITableViewCell {

    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var starring: UILabel!
    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
