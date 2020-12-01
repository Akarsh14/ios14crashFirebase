//
//  LabeledTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 23/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class LabeledTableViewCell: UITableViewCell {

    @IBOutlet weak var cellTextLabel: MDHTMLLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
