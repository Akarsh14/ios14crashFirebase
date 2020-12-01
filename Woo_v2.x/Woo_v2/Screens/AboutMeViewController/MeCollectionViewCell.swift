//
//  MeCollectionViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 06/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MeCollectionViewCell: UICollectionViewCell {
    
    var meProfileDeckView:MeProfileDeckView?
    var bundledProfileDeckView:BundledProfileDeckView?
    
    func setUserDetail(userDetail:AnyObject,isBundledProfile: Bool, forType:MeDataType, isPaidUser: Bool, showLock:Bool, noOfTotalProfiles:Int, isExpired:Bool, profileIndex:Int, usedInExpiryProfiles:Bool) -> Void {
        
        if(!isBundledProfile)
        {
            bundledProfileDeckView?.removeFromSuperview()
            bundledProfileDeckView = nil
            if meProfileDeckView == nil {
                meProfileDeckView = MeProfileDeckView.loadViewFromNib(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                meProfileDeckView?.modifyProfileDeckView()
                self.addSubview(meProfileDeckView ?? MeProfileDeckView())
            }
            meProfileDeckView?.currentFrame = self.frame
            meProfileDeckView?.setDataForProfile(profileDetails: userDetail, type: forType, lockedState: !isPaidUser, showLock: showLock, noOfTotalProfiles: noOfTotalProfiles, isExpired: isExpired, profileIndex: profileIndex, usedInExpiryProfiles: usedInExpiryProfiles)
        }
        else
        {
            meProfileDeckView?.removeFromSuperview()
            meProfileDeckView = nil
            if bundledProfileDeckView == nil {
                bundledProfileDeckView = BundledProfileDeckView.loadViewFromNib(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                bundledProfileDeckView?.modifyProfileDeckView()
                self.addSubview(bundledProfileDeckView ?? BundledProfileDeckView())
            }
            bundledProfileDeckView?.setDataForProfile(profileDetails: userDetail, type: forType, lockedState: !isPaidUser, showLock: showLock, noOfTotalProfiles: 0, isExpired: isExpired)
        }
            
    }

}
