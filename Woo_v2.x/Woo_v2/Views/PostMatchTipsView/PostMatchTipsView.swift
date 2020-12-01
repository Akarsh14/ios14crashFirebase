//
//  PostMatchTipsView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 29/11/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PostMatchTipsView: UIView {
    
    @objc var viewRemovedHandler:(()->Void)!

    //MARK: View Lifecycle method
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    class func showView() -> PostMatchTipsView{
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let matchTipsView: PostMatchTipsView =
            Bundle.main.loadNibNamed("PostMatchTipsView", owner: nil, options: nil)!.first as! PostMatchTipsView
        matchTipsView.frame = window.frame
        matchTipsView.alpha = 0.0
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            //            if window2 is MDSnackbar {
            //                window2.removeFromSuperview()
            //            }
            // window2 = window.subviews.last! as UIView
            (window2.subviews.first! as UIView).addSubview(matchTipsView)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(matchTipsView)
            }
            else{
                (window.subviews.first! as UIView).addSubview(matchTipsView)
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            matchTipsView.alpha = 1.0
        })
        
        return matchTipsView
    }
    
    @IBAction func closeView(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0.0
        }) { (true) in
            self.viewRemovedHandler()
            self.removeFromSuperview()
        }
    }
    
    
}
