//
//  TopReviewsTableCell.swift
//  Granth
//
//  Created by Goldenmace-E41 on 02/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit
import Cosmos

class TopReviewsTableCell: UITableViewCell {

    @IBOutlet weak var imgReviewer: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var vwRating: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
