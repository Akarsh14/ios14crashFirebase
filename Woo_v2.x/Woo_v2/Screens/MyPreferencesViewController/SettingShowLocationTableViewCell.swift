//
//  SettingShowLocationTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 20/07/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class SettingShowLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var showLocationSwitch: UISwitch!
    var currentShowLocationValue : Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currentShowLocationValue = DiscoverProfileCollection.sharedInstance.intentModelObject?.showLocation.boolValue
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func toggleShowLocation(_ sender: Any) {
        let toggleSwitch:UISwitch = sender as! UISwitch
        if(currentShowLocationValue  != toggleSwitch.isOn)
        {
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            DiscoverProfileCollection.sharedInstance.intentModelObject?.showLocation = NSNumber(value:toggleSwitch.isOn)

        }
        else
        {
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
            DiscoverProfileCollection.sharedInstance.intentModelObject?.showLocation = NSNumber(value:toggleSwitch.isOn)

        }


    }
}
