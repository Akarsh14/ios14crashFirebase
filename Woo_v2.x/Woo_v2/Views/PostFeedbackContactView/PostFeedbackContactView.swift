//
//  PostFeedbackContactView.swift
//  Woo_v2
//
//  Created by Vaibhav Gautam on 26/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import IQKeyboardManager

class PostFeedbackContactView: UIView, UITextFieldDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var feedBackText = ""
    
    
    var contactDetailsHandler:((Bool)->Void)!
    
    
    @IBAction func crossButtonTapped(_ sender: AnyObject) {
        
        AppSettingsApiClass.sendFeedback(toServer: feedBackText, andNumberOfStars: 0, andEmail: "", andPhoneNumber: "", withCompletionBlock: nil)
        
        if contactDetailsHandler != nil {
            contactDetailsHandler(false)
        }
        self.removeFromSuperview()
    }
    
    @IBAction func submitButtonTapped(_ sender: AnyObject) {
        
        AppSettingsApiClass.sendFeedback(toServer: feedBackText, andNumberOfStars: 0, andEmail: emailField.text, andPhoneNumber: mobileNumberField.text, withCompletionBlock: nil)
        
        
        submitButton.isEnabled = false
        crossButton.isEnabled = false
        
        if contactDetailsHandler != nil {
            contactDetailsHandler(false)
        }
        self.removeFromSuperview()
    }
    
    func loadContactScreen(){
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        
        submitButton.layer.shadowColor = UIColor.darkGray.cgColor
        submitButton.layer.shadowOpacity = 0.4
        submitButton.layer.shadowRadius = 3.0
        submitButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        
        self.frame = window.frame
        
        self.layoutIfNeeded()
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            (window2.subviews.first! as UIView).addSubview(self)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(self)
            }
            else{
                (window.subviews.first! as UIView).addSubview(self)
            }
        }
        
        emailField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
