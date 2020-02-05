//
//  SideBarTableViewCell.swift
//  Granth
//
//  Created by Goldenmace-ios on 28/09/19.
//  Copyright © 2019 Goldenmace-ios. All rights reserved.
//

import UIKit

class SideBarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
