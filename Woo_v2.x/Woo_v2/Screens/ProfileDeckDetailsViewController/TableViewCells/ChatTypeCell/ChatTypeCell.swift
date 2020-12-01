//
//  ChatTypeCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 19/03/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ChatTypeCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellSubText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
        // Configure the view for the selected state
    }

}
