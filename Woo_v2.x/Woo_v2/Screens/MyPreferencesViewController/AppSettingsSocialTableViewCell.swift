//
//  AppSettingsSocialTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AppSettingsSocialTableViewCell: UITableViewCell {

    @IBOutlet weak var socialImageView: UIImageView!
    @IBOutlet weak var socialLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataForSocialType(_ socialType:AppSettingsSocialType){
        if socialType == .ReviewOnAppstore {
            socialLabel.text = NSLocalizedString("Review us on appstore", comment: "")
            socialImageView.image = UIImage(named: "ic_my_preferences_appstore")
            
        }
        else if socialType == .LikeOnFacebook{
            socialLabel.text = NSLocalizedString("Like us on Facebook", comment: "")
            socialImageView.image = UIImage(named: "ic_my_preferences_facebook")
            
        }
        else if socialType == .FollowWoo{
            socialLabel.text = NSLocalizedString("Follow us on Twitter", comment: "")
            socialImageView.image = UIImage(named: "ic_my_preferences_twitter")
        }
    }
}
