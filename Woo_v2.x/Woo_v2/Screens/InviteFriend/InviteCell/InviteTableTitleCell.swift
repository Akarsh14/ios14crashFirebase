//
//  InviteTableTitleCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 27/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class InviteTableTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(withTitleText titleText: String, andWithImageURL imageURL:  String) -> Void {
        titleLabel.text = titleText
        imageIcon.sd_setImage(with: URL(string: imageURL))
//        imageIcon.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
