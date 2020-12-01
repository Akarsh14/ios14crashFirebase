//
//  MeHeaderView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 06/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MeHeaderView: UICollectionReusableView{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var leftMargin_HeaderLbl: NSLayoutConstraint!
    @IBOutlet weak var boostImageView: UIImageView!
    
    func setHeaderTextForSection(isSectionForBoosted:Bool, textForHeader:String) -> Void {
        if isSectionForBoosted {
            headerLabel.text = textForHeader
            boostImageView.isHidden = false
            leftMargin_HeaderLbl.constant = 35
        }
        else{
            headerLabel.text = textForHeader
            boostImageView.isHidden = true
            leftMargin_HeaderLbl.constant = 6
        }
    }
}
