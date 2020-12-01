//
//  InviteTableTitleSubTitleCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 27/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class InviteTableTitleSubTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(withTitleText titleText: String, withSubtitleText subTitleText: String, andWithImageURL imageURL:  String) -> Void {
        titleLabel.text = titleText
        subTitleLabel.text = subTitleText
        print("\n imageURL \(imageURL), titleText \(titleText), subTitleText \(subTitleText)")
        imageIcon.sd_setImage(with: URL(string: imageURL))
//        imageIcon.backgroundColor = UIColor.clearsour
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
