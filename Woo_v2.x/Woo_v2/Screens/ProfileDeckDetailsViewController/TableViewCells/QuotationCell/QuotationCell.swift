//
//  QuotationCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 09/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class QuotationCell: UITableViewCell {
    
    @IBOutlet weak var personalQouteLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPersonalQouteText(_ text: String) {
        personalQouteLabel.text = text
    }

}
