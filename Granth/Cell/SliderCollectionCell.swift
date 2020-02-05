//
//  SliderCollectionCell.swift
//  Granth
//
//  Created by Goldenmace-E41 on 30/09/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class SliderCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imgSlider: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgSlider.layer.cornerRadius = 10.0
        imgSlider.layer.masksToBounds = true
    }

}
