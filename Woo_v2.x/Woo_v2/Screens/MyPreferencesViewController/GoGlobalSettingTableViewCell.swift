//
//  GoGlobalSettingTableViewCell.swift
//  Woo_v2
//
//  Created by Akarsh Aggarwal on 12/11/20.
//  Copyright © 2020 Woo. All rights reserved.
//

import Foundation


class GoGlobalSettingTableViewCell : UITableViewCell {
    
    @IBOutlet weak var showGoGlobalLabel : UILabel!
    @IBOutlet weak var goGlobalToggleSwitch : UISwitch!
    var currentGoGlobalState : Bool?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func toggleShowLocation(_ sender: Any) {
        
        currentGoGlobalState = DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal.boolValue
        
        let toggleSwitch:UISwitch = sender as! UISwitch
        print("toggleSwitch",toggleSwitch.isOn)
        
        if(currentGoGlobalState  != toggleSwitch.isOn)
        {
            DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal = toggleSwitch.isOn as NSNumber
            
        }
        else
        {
            DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal = toggleSwitch.isOn as NSNumber
        }
        
        print(DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal ?? "asd")
    
        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true

    }
    
}
