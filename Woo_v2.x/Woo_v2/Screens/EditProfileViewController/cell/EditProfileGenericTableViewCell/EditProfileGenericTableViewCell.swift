//
//  EditProfileGenericTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 20/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class EditProfileGenericTableViewCell: UITableViewCell {

    @IBOutlet weak var moreRelationshipCountLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreRelationshipCountLabel: UILabel!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var cellValueLabel: UILabel!
    @IBOutlet weak var separatorViewForCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
