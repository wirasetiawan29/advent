//
//  AddCartTableViewCell.swift
//  Granth
//
//  Created by Goldenmace-ios on 01/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class AddCartTableViewCell: UITableViewCell {

    @IBOutlet weak var imgBook: UIImageView!
    
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var lblBookPrice: UILabel!
    
    @IBOutlet weak var btnMoveToWishlist: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
