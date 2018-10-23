//
//  InvitationTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/16/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class InvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
