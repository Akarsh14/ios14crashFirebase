//
//  DiscoverSettingsGenderTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class DiscoverSettingsGenderTableViewCell: UITableViewCell {

    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var casualButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    var currentFavIntent:String = ""
    var currentGender:String = ""
    var selectedGender:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateGenderAndPreferencesView(){
        
        let interestedGender:String = DiscoverProfileCollection.sharedInstance.intentModelObject!.interestedGender
        currentGender = interestedGender
        if interestedGender == "FEMALE" {
            maleButton.isSelected = false
            femaleButton.isSelected = true
        }
        else{
            maleButton.isSelected = true
            femaleButton.isSelected = false
        }
        
        /*
        let favIntent:String = DiscoverProfileCollection.sharedInstance.intentModelObject!.favIntent
        currentFavIntent = favIntent
        switch favIntent{
        case "NONE":
            loveButton.isSelected = false
            casualButton.isSelected = false
            friendsButton.isSelected = false
            break
        case "LOVE":
            loveButton.isSelected = true
            casualButton.isSelected = false
            friendsButton.isSelected = false
            break
        case "FRIENDS":
            loveButton.isSelected = false
            casualButton.isSelected = false
            friendsButton.isSelected = true
            break
        case "CASUAL":
            loveButton.isSelected = false
            casualButton.isSelected = true
            friendsButton.isSelected = false
            break
        default:
            break
            
        }
        */
    }
    @IBAction func maleTapped(_ sender: AnyObject) {
        maleButton.isSelected = true
        femaleButton.isSelected = false
        selectedGender = "MALE"
        if currentGender != selectedGender {
            DiscoverProfileCollection.sharedInstance.intentModelObject!.interestedGender = "MALE"
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
        }
        else{
            DiscoverProfileCollection.sharedInstance.intentModelObject!.interestedGender = currentGender
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
        }
    }

    @IBAction func femaleTapped(_ sender: AnyObject) {
        maleButton.isSelected = false
        femaleButton.isSelected = true
        selectedGender = "FEMALE"
        if currentGender != selectedGender {
            DiscoverProfileCollection.sharedInstance.intentModelObject!.interestedGender = "FEMALE"
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
        }
        else{
            DiscoverProfileCollection.sharedInstance.intentModelObject!.interestedGender = currentGender
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
        }
    }
    
    @IBAction func loveTapped(_ sender: AnyObject) {
        self.updateContentForIntentBasedOnText("LOVE")
    }
    
    @IBAction func friendsTapped(_ sender: AnyObject) {
        self.updateContentForIntentBasedOnText("FRIENDS")
    }
    
    @IBAction func casualTapped(_ sender: AnyObject) {
        self.updateContentForIntentBasedOnText("CASUAL")
    }
    
    func updateContentForIntentBasedOnText(_ favIntentString:String){
        if favIntentString != currentFavIntent {
            DiscoverProfileCollection.sharedInstance.intentModelObject!.favIntent = favIntentString
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
        }
        else{
            DiscoverProfileCollection.sharedInstance.intentModelObject!.favIntent = currentFavIntent
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
        }
        switch favIntentString{
        case "NONE":
            loveButton.isSelected = false
            casualButton.isSelected = false
            friendsButton.isSelected = false
            break
        case "LOVE":
            loveButton.isSelected = true
            casualButton.isSelected = false
            friendsButton.isSelected = false
            break
        case "FRIENDS":
            loveButton.isSelected = false
            casualButton.isSelected = false
            friendsButton.isSelected = true
            break
        case "CASUAL":
            loveButton.isSelected = false
            casualButton.isSelected = true
            friendsButton.isSelected = false
            break
        default:
            break
         }
}
}
