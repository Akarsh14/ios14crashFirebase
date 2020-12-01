//
//  LikedMeHeaderView.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 08/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class LikedMeHeaderView: UICollectionReusableView {
    
    @IBOutlet var headerLbl: UILabel!
    @IBOutlet var boostedImageIcon: UIImageView!
    @IBOutlet var leftMargin_HeaderLbl: NSLayoutConstraint!
    
    func setHeaderTextForSection(isSectionForBoosted:Bool) -> Void {
        if isSectionForBoosted {
            headerLbl.text = NSLocalizedString("Liked you while you were boosted", comment: "While Boosted")
            boostedImageIcon.isHidden = false
            leftMargin_HeaderLbl.constant = 50
        }
        else{
            headerLbl.text = NSLocalizedString("Liked you, like back to chat", comment: "While Not Boosted")
            boostedImageIcon.isHidden = true
            leftMargin_HeaderLbl.constant = 20
        }
    }
    
}
