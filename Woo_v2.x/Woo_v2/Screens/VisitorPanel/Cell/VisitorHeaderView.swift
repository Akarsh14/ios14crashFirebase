//
//  VisitorHeaderView.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 06/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class VisitorHeaderView: UICollectionReusableView {
    @IBOutlet var headerLbl: UILabel!
    @IBOutlet var boostedImageIcon: UIImageView!
    @IBOutlet var leftMargin_HeaderLbl: NSLayoutConstraint!
    
    func setHeaderTextForSection(isSectionForBoosted:Bool) -> Void {
        if isSectionForBoosted {
            headerLbl.text = NSLocalizedString("Visitors while you were boosted.", comment: "While Boosted")
            boostedImageIcon.isHidden = false
            leftMargin_HeaderLbl.constant = 50
        }
        else{
            headerLbl.text = NSLocalizedString("People who visited your profile.", comment: "While Not Boosted")
            boostedImageIcon.isHidden = true
            leftMargin_HeaderLbl.constant = 20
        }
    }
        
}
