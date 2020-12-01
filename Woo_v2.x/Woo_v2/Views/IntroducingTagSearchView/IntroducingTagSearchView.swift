//
//  IntroducingTagSearchView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 26/07/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class IntroducingTagSearchView: UIView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
    //MARK: View Lifecycle method
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func showView() -> IntroducingTagSearchView{
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let tagSearchPopup: IntroducingTagSearchView =
            Bundle.main.loadNibNamed("IntroducingTagSearchView", owner: window.rootViewController, options: nil)!.first as! IntroducingTagSearchView
        tagSearchPopup.frame = window.frame
        tagSearchPopup.alpha = 0.0
        (window as UIView).addSubview(tagSearchPopup)
//        if window.subviews.count > 1 {// If Any view is presented
//            if let window2 = window.subviews.last{ // UIView cannot be added to UITransitionView. So add to its subview
//            //            if window2 is MDSnackbar {
//            //                window2.removeFromSuperview()
//            //            }
//            // window2 = window.subviews.last! as UIView
//             (window2 as UIView).addSubview(tagSearchPopup)
//            }
//        }
//        else{
//            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
//                if let window2 = window.subviews.last{ // UIView cannot be added to UITransitionView. So add to its subview
//                    (window2 as UIView).addSubview(tagSearchPopup)
//                }
//            }
//            else{
//                if let window1 = window.subviews.first{
//                (window1 as UIView).addSubview(tagSearchPopup)
//                }
//            }
//        }
        
        UIView.animate(withDuration: 0.4, animations: {
            tagSearchPopup.alpha = 1.0
        })
        
        if Int(SCREEN_HEIGHT) == HEIGHT_IPHONE_X{
            tagSearchPopup.backViewTopConstraint.constant = 0
            tagSearchPopup.searchTopConstraint.constant = 0
        }
        else if Int(SCREEN_HEIGHT) == HEIGHT_IPHONE_6P{
            tagSearchPopup.searchTopConstraint.constant = 15
        }
        
        return tagSearchPopup
    }
    @IBAction func dismissTagSearchView(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "hasSeenIntroductionForSearchTags")
        UserDefaults.standard.synchronize()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
}
