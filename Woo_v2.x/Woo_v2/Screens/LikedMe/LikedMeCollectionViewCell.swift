//
//  LikedMeCollectionViewCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 08/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class LikedMeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userTagImage: UIImageView!
    
    @IBOutlet weak var profileLockImage: UIImageView!
    
    
    func setUserDetail(userDetail:LikedMe, andWidth widhtVal: CGFloat, isPaidUser: Bool) -> Void {
        let width: Int = Int(widhtVal*0.84) * 2
        
        let imageCroppedStr = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\((Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: userDetail.userProfilePicURL)!)"
        
        let imageCroppedUrl = URL(string: imageCroppedStr)
        
        profileLockImage.isHidden = isPaidUser
        
        
        userImage.sd_setImage(with: imageCroppedUrl, placeholderImage: UIImage(named: "ic_me_avatar_big"))
        
        if ((userDetail.badgeType == "NONE") || !isPaidUser){
            userTagImage.isHidden = true
        }
        else if(userDetail.badgeType == "NEW"){
            userTagImage.image = UIImage.init(named: "ic_me_new_2rows")
        }
        else if(userDetail.badgeType == "POPULAR"){
            userTagImage.image = UIImage.init(named: "ic_me_popular_2rows")
        }
        else if(userDetail.badgeType == "VIP"){
            userTagImage.image = UIImage.init(named: "ic_me_VIP_2rows")
        }
        else if(userDetail.badgeType == "DIASPORA"){
            userTagImage.image = UIImage.init(named: "ic_me_globe_2rows")
        }
        else{
            userTagImage.isHidden = true
        }
        
        
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = CGFloat(width)/4.0
        profileLockImage.layer.masksToBounds = true
        profileLockImage.layer.cornerRadius = CGFloat(width)/4.0
        
    }
    
}
