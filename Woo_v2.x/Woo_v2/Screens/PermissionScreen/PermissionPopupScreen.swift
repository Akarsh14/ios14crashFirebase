//
//  PermissionPopupScreen.swift
//  Woo_v2
//
//  Created by Akhil Singh on 30/01/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PermissionPopupScreen: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var popupTextLabel: UILabel!
    
    class func loadViewFromNib(frame: CGRect) -> PermissionPopupScreen {
        let nib = UINib(nibName: "PermissionPopupScreen", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        return view as! PermissionPopupScreen
    }
    
    public func setTextForPopupLabel(textString:String){
        popupTextLabel.text = textString
    }
}
