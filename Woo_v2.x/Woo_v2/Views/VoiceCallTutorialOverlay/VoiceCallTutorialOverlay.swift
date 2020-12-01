//
//  VoiceCallTutorialOverlay.swift
//  Woo_v2
//
//  Created by Ankit Batra on 04/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class VoiceCallTutorialOverlay: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var tutorialSeenHandler:(()->Void)!
    var callButtonTappedHandler:(()->Void)!

    @IBOutlet weak var tutorialText: UILabel!

    @IBAction func okButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.tutorialSeenHandler()
    }
    @IBOutlet weak var overlayCallButton: UIButton!
    @IBAction func callButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
        if callButtonTappedHandler != nil{
            callButtonTappedHandler()
        }
        self.tutorialSeenHandler()

    }
}
