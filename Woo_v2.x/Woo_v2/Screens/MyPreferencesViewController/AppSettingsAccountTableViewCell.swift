//
//  AppSettingsAccountTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AppSettingsAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var downArrowImageView: UIImageView!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var accountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewBasedOnAccountType(_ accountType:AppSettingsAccountType){
        if accountType == .Logout {
            self.accountView.backgroundColor = UIColor.white
            self.accountLabel.text = NSLocalizedString("Log out", comment: "")
//            self.accountLabel.textColor = UIColor(red: 114/255, green: 119/255, blue: 138/255, alpha: 1)
            self.downArrowImageView.isHidden = true
            
        }
        else{
            self.accountView.backgroundColor = UIColor.white
            self.accountLabel.text = NSLocalizedString("Disable", comment: "")
//            self.accountLabel.textColor = UIColor(red: 55/255, green: 58/255, blue: 67/255, alpha: 0.5)
            self.downArrowImageView.isHidden = false
        }
    }
}
