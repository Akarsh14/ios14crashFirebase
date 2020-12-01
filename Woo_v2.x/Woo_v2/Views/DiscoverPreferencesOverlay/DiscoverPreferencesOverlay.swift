//
//  DiscoverPreferencesOverlay.swift
//  Woo_v2
//
//  Created by Ankit Batra on 30/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class DiscoverPreferencesOverlay: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let defaultPopupTrailingConstraintConstant = 2.0
    let defaultbuttonSuperViewTrailingConstraintConstant = 5.0
    var tutorialSeenHandler:(()->Void)!
    var settingsButtonTappedHandler:(()->Void)!
    var isTagSearchIntroOverlay = false
    
    @IBOutlet weak var overlayTextLabel: UILabel!
    @IBOutlet weak var popupSuperViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonSuperViewTrailingConstraint: NSLayoutConstraint!
    
    func setupUI(_ forTags:Bool) {
        if(forTags)
        {
            overlayTextLabel.text = "Find people of your interest with Woo Tag Search"
            popupSuperViewTrailingConstraint.constant = CGFloat(defaultPopupTrailingConstraintConstant + 35.0)
            buttonSuperViewTrailingConstraint.constant = CGFloat(defaultbuttonSuperViewTrailingConstraintConstant + 35.0)

        }
        else
        {
            overlayTextLabel.text = "Set your preferences for the profiles you want to see"
            popupSuperViewTrailingConstraint.constant = CGFloat(defaultPopupTrailingConstraintConstant)
            buttonSuperViewTrailingConstraint.constant = CGFloat(defaultbuttonSuperViewTrailingConstraintConstant)
        }
    }
    @IBAction func okButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.tutorialSeenHandler()
    }
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        self.removeFromSuperview()
        settingsButtonTappedHandler()
    }
}
