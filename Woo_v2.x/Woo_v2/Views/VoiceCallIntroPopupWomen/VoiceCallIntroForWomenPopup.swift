//
//  VoiceCallIntroForWomenPopup.swift
//  Woo_v2
//
//  Created by Ankit Batra on 13/03/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class VoiceCallIntroForWomenPopup: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var tutorialSeenHandler:(()->Void)!
    var callButtonTappedHandler:(()->Void)!
    @IBAction func okButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.tutorialSeenHandler()
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
        if callButtonTappedHandler != nil{
            callButtonTappedHandler()
        }
       // self.tutorialSeenHandler()
        
    }
}
