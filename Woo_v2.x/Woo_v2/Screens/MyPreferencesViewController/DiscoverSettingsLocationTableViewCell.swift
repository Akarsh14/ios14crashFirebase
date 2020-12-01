//
//  DiscoverSettingsLocationTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class DiscoverSettingsLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationIconObj: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateLocationLabel(){
        if let location = DiscoverProfileCollection.sharedInstance.myProfileData?.location {
            locationLabel.text = location as String
        }
        activityIndicator.isHidden = true
        locationIconObj.isHidden = false
    }
    func showActivityIndicatorObject() {
        activityIndicator.isHidden = false
        locationIconObj.isHidden = true
        activityIndicator.startAnimating()
    }
    func hideActivityIndictorObject() {
        activityIndicator.isHidden = true
        locationIconObj.isHidden = false
        activityIndicator.stopAnimating()
    }
}

