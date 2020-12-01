//
//  FBLinkedInCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 27/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class FBLinkedInCell: UITableViewCell {
    
    @IBOutlet weak var fbView: UIView!
    @IBOutlet weak var linkedInView: UIView!
    @IBOutlet weak var linkLabel: UILabel!
    
    
    var fbButtonHandler : (()->())?
    var linkedInButtonHandler : (()->())?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        fbView.layer.borderWidth = 1
        fbView.layer.borderColor = UIColor.white.cgColor
        linkedInView.layer.borderWidth = 1
        linkedInView.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func fbButtonPressed(_ sender: AnyObject) {
        if fbButtonHandler != nil {
            fbButtonHandler!()
        }
    }
    
    @IBAction func linkedInButtonPressed(_ sender: AnyObject) {
        if linkedInButtonHandler != nil {
            linkedInButtonHandler!()
        }
    }
    
    func isLinkedInVerified(_ isVerified : Bool){
        if isVerified {
            linkLabel.text = NSLocalizedString("Unlink", comment: "")
        }
        else{
            linkLabel.text = NSLocalizedString("Link", comment: "")
        }
    }
}
