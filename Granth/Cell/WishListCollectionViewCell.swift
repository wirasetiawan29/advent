//
//  WishListCollectionViewCell.swift
//  Granth
//
//  Created by Goldenmace-ios on 02/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class WishListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var vwBackground: UIView!
    
    @IBOutlet weak var imgBook: UIImageView!
    
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblBookPrice: UILabel!
    
    @IBOutlet weak var btnMoveToCart: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        vwBackground.layer.cornerRadius = 5.0
        vwBackground.layer.masksToBounds = true
    }

}
