//
//  PaymentTableViewCell.swift
//  Granth
//
//  Created by Goldenmace-ios on 01/10/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelected: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSelected.setImage(UIImage(named: "icoRadioUnchecked"), for: .normal)
        btnSelected.setImage(UIImage(named: "icoRadioChecked"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
