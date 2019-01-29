//
//  FriendsTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/17/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var noInvitationsLabel: UILabel!
    @IBOutlet weak var noFriendsLabel: UILabel!
    @IBOutlet weak var noSuggestionsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var noFacebookLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
