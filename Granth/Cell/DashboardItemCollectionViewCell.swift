//
//  DashboardItemCollectionViewCell.swift
//  Granth
//
//  Created by wira on 2/16/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import UIKit

class DashboardItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblBookName: UILabel!

    @IBOutlet weak var vwBackground: UIView!

    @IBOutlet weak var backgroundGradient: UIView!
    @IBOutlet weak var imgBookCover: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        vwBackground.layer.cornerRadius = 10.0
        vwBackground.layer.masksToBounds = true
    }
}
