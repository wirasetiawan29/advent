//
//  HomeBooksCollectionCell.swift
//  Granth
//
//  Created by Goldenmace-E41 on 28/09/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class HomeBooksCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblBookPrice: UILabel!
    
    @IBOutlet weak var vwBackground: UIView!
    
    @IBOutlet weak var imgBookCover: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwBackground.layer.cornerRadius = 5.0
        vwBackground.layer.masksToBounds = true
    }

}
