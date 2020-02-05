//
//  AuthorBooksCollectionCell.swift
//  Granth
//
//  Created by Goldenmace-E41 on 02/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class AuthorBooksCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imgBookCover: UIImageView!
    
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblBookPrice: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var vwBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwBackground.layer.cornerRadius = 10.0
        vwBackground.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 1.0
        self.layer.shadowOffset = CGSize(width: 0.0 , height: 1.0)
        self.layer.masksToBounds = false
    }

}
