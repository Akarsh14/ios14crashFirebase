//
//  VoiceCallingVersionUpdateOverlay.swift
//  Woo_v2
//
//  Created by Ankit Batra on 06/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class VoiceCallingVersionUpdateOverlay: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var versionUpdateText: UILabel!

    @IBAction func okButtonTapped(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
