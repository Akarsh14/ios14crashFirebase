//
//  EthnicityTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 14/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class EthnicityTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var checkBox: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
