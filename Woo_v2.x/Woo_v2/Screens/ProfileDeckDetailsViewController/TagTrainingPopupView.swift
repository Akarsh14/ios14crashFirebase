//
//  TagTrainingPopupView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 11/01/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class TagTrainingPopupView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    class func loadViewFromNib(frame: CGRect) -> TagTrainingPopupView {
        let nib = UINib(nibName: "TagTrainingPopupView", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        return view as! TagTrainingPopupView
    }

}
