//
//  AppSettingsSoundTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AppSettingsSoundTableViewCell: UITableViewCell {

    @IBOutlet weak var soundSwitch: UISwitch!
    
    var currentSoundState = false
    var selectedSoundState = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        currentSoundState = AppLaunchModel.sharedInstance().soundNotification
        self.soundSwitch.setOn(AppLaunchModel.sharedInstance().soundNotification, animated: false)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func soundValueChanged(_ sender: AnyObject) {
        
        selectedSoundState = self.soundSwitch.isOn
        if currentSoundState != selectedSoundState {
            AppLaunchModel.sharedInstance().soundNotification = selectedSoundState
            AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall = true
        }
        else{
            AppLaunchModel.sharedInstance().soundNotification = currentSoundState
            AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall = false
        }
    }

}
