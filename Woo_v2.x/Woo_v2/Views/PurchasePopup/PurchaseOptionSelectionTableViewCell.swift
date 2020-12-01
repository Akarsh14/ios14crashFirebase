//
//  PurchaseOptionSelectionTableViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 20/07/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PurchaseOptionSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var paybutton: UIButton!
    var payButtonTappedHandler:(()->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        paybutton.layer.borderWidth = 1.0
        paybutton.layer.borderColor = UIColorHelper.color(fromRGB: "#4EC362", withAlpha: 1.0).cgColor
        paybutton.layer.cornerRadius = 2.0
        paybutton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
        payButtonTappedHandler()
    }
}
