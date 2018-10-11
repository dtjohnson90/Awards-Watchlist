//
//  ListTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/10/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starringLabel: UILabel!
    @IBOutlet weak var hiddenView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
