//
//  LoginTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/21/21.
//  Copyright © 2021 Dustin Johnson. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
