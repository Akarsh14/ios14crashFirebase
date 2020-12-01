//
//  HideFromMutualFriendCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 27/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class HideFromMutualFriendCell: UITableViewCell {

    @IBOutlet weak var showToFriendSwitch: UISwitch!
    
    var valueChangedHandler : ((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchValueChanged(_ sender: AnyObject) {
        if valueChangedHandler != nil {
            valueChangedHandler!((sender as! UISwitch).isOn)
        }
    }
    
    
}
