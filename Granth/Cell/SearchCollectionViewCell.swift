//
//  SearchCollectionViewCell.swift
//  Granth
//
//  Created by Goldenmace-ios on 04/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBookimage: UIImageView!
    
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblBookType: UILabel!
    @IBOutlet weak var lblBookPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
