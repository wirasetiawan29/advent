//
//  TransactionCollectionViewCell.swift
//  Granth
//
//  Created by Goldenmace-ios on 03/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class TransactionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lbltransactionStatus: UILabel!
    @IBOutlet weak var lblPayId: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblBookPrice: UILabel!
    
    @IBOutlet weak var vwMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
