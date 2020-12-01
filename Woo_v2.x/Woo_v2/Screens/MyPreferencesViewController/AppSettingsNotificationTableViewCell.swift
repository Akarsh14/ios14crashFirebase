//
//  AppSettingsNotificationTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AppSettingsNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationTypeLabel: UILabel!
    
    var currentNotificationState = false
    var selectedNotificationState = false
    
    var selectedNotificationType:AppSettingsNotificationType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataForNotificationType(_ notificationType:AppSettingsNotificationType){
        
        selectedNotificationType = notificationType
        
        if notificationType == .MatchAndChat {
            notificationTypeLabel.text = NSLocalizedString("Match and chat", comment: "")
            currentNotificationState = AppLaunchModel.sharedInstance().matchNotification
            self.notificationSwitch.setOn(AppLaunchModel.sharedInstance().matchNotification, animated: false)
            
        }
        else if notificationType == .CrushRecieved{
            notificationTypeLabel.text = NSLocalizedString("Crush received", comment: "")
            currentNotificationState = AppLaunchModel.sharedInstance().crushNotification
            self.notificationSwitch.setOn(AppLaunchModel.sharedInstance().crushNotification, animated: false)

        }
        else if notificationType == .QuestionsAndAnswers{
            notificationTypeLabel.text = NSLocalizedString("Questions and Answers", comment: "")
            currentNotificationState = AppLaunchModel.sharedInstance().questionNotification
            self.notificationSwitch.setOn(AppLaunchModel.sharedInstance().questionNotification, animated: false)

        }
    }

    @IBAction func changeStatusOfNotification(_ sender: AnyObject) {
        selectedNotificationState = self.notificationSwitch.isOn
        if currentNotificationState != selectedNotificationState {
            if selectedNotificationType == .MatchAndChat {
                AppLaunchModel.sharedInstance().matchNotification = selectedNotificationState
            }
            else if selectedNotificationType == .CrushRecieved{
                AppLaunchModel.sharedInstance().crushNotification = selectedNotificationState
                
            }
            else if selectedNotificationType == .QuestionsAndAnswers{
                AppLaunchModel.sharedInstance().questionNotification = selectedNotificationState
            }
            AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall = true
        }
        else{
            if selectedNotificationType == .MatchAndChat {
                AppLaunchModel.sharedInstance().matchNotification = currentNotificationState
            }
            else if selectedNotificationType == .CrushRecieved{
                AppLaunchModel.sharedInstance().crushNotification = currentNotificationState
                
            }
            else if selectedNotificationType == .QuestionsAndAnswers{
                AppLaunchModel.sharedInstance().questionNotification = currentNotificationState
            }
            AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall = false
        }
        
    }
}
