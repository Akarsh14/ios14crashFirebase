//
//  TagSearchOverlayView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 27/07/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class TagSearchOverlayView: UIView {

    @IBOutlet weak var tagLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func showView(_ tagText:String, tagLabelCoordinates:CGRect) -> TagSearchOverlayView{
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let tagSearchPopup: TagSearchOverlayView =
            Bundle.main.loadNibNamed("TagSearchOverlayView", owner: window.rootViewController, options: nil)!.first as! TagSearchOverlayView
        tagSearchPopup.frame = window.frame
        tagSearchPopup.alpha = 0.0
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            //            if window2 is MDSnackbar {
            //                window2.removeFromSuperview()
            //            }
            // window2 = window.subviews.last! as UIView
            (window2.subviews.first! as UIView).addSubview(tagSearchPopup)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(tagSearchPopup)
            }
            else{
                (window.subviews.first! as UIView).addSubview(tagSearchPopup)
            }
        }
        
        tagSearchPopup.tagLabel.layer.cornerRadius = 15.0
        tagSearchPopup.tagLabel.layer.masksToBounds = true
        tagSearchPopup.tagLabel.layer.borderColor = UIColorHelper.color(fromRGB: "#9275DB", withAlpha: 1.0).cgColor
        tagSearchPopup.tagLabel.layer.borderWidth = 1.0
        
        UIView.animate(withDuration: 0.4, animations: {
            tagSearchPopup.alpha = 1.0
        })
        
        var padding:CGFloat = 0
        if Int(SCREEN_HEIGHT) == HEIGHT_IPHONE_XS_MAX{
            tagSearchPopup.blackViewTopConstraint.constant = 0
            padding = 15
        }
        else{
            padding = 10
        }
        
        tagSearchPopup.tagLabelTopConstraint.constant = tagLabelCoordinates.origin.y + padding
        tagSearchPopup.tagLabelLeadingConstraint.constant = tagLabelCoordinates.origin.x
        tagSearchPopup.tagLabel.text = tagText
        tagSearchPopup.tagLabelWidthConstraint.constant = tagLabelCoordinates.size.width
        
        return tagSearchPopup
    }
    
    @IBAction func dismissPopupView(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "tagOverlayShown")
        UserDefaults.standard.synchronize()
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0.0
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
}
