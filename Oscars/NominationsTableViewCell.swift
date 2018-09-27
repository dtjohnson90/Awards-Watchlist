//
//  NominationsTableViewCell.swift
//  Oscars
//
//  Created by Dustin Johnson on 2/28/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class NominationsTableViewCell: UITableViewCell {

    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

}
