//
//  AboutMeCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 03/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AboutMeCell: UITableViewCell {

    @IBOutlet weak var aboutMeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setAboutMeText(_ text: String) {
        aboutMeLabel.text = text
    }
    
}
