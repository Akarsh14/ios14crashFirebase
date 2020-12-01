//
//  PhotoTipsView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 17/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PhotoTipsView: UIView {
    
    var viewRemovedHandler:(()->Void)!
    
    @IBOutlet weak var childrenPhotoImageView: UIImageView!
    @IBOutlet weak var groupPhotoImageView: UIImageView!
    @IBOutlet weak var selfiePhotoImageView: UIImageView!
    @IBOutlet weak var yourPhotoImageView: UIImageView!
    //MARK: View Lifecycle method
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    class func showView(_ isMale:Bool) -> PhotoTipsView{
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let photoTipsView: PhotoTipsView =
            Bundle.main.loadNibNamed("PhotoTipsView", owner: nil, options: nil)!.first as! PhotoTipsView
        photoTipsView.frame = window.frame
        photoTipsView.alpha = 0.0
        photoTipsView.setupViewForMaleForFemale(isMale)
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView
            (window2.subviews.first! as UIView).addSubview(photoTipsView)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(photoTipsView)
            }
            else{
                (window.subviews.first! as UIView).addSubview(photoTipsView)
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            photoTipsView.alpha = 1.0
        })
        
        return photoTipsView
    }
    
    func setupViewForMaleForFemale(_ isMale:Bool){
        if isMale == false{
            yourPhotoImageView.image = UIImage(named: "ic_edit_photo_tips_yourself_female")
            selfiePhotoImageView.image = UIImage(named: "ic_edit_photo_tips_selfie_female")
            groupPhotoImageView.image = UIImage(named: "ic_edit_photo_tips_group_female")
            childrenPhotoImageView.image = UIImage(named: "ic_edit_photo_tips_children_female")
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0.0
        }) { (true) in
            self.removeFromSuperview()
        }
    }
    

}
