//
//  SeeNewProfilesPopupView.swift
//  Woo_v2
//
//  Created by Ankit Batra on 19/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class SeeNewProfilesPopupView: UIView {

    var seeProfilesButtonHandler : (() -> (Void))?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func seeNewProfilesButtonTapped(_ sender: UIButton) {
        seeProfilesButtonHandler!()
    }
}
