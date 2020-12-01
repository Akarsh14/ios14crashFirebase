//
//  LinkedInPhoneVerifyCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 03/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum LPCellType {
    case linkedIn
    case phone
    case both
}

class LinkedInPhoneVerifyCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var spaceBetweenBothTheViewsConstant: NSLayoutConstraint!
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var linkedinView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mainViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneVerifyViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkedInViewWidthConstaint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setType(_ type : LPCellType) {
        if type == LPCellType.linkedIn{
            linkedInViewWidthConstaint.constant = SCREEN_WIDTH/2
            phoneVerifyViewConstraint.constant = 0
            spaceBetweenBothTheViewsConstant.constant = 0
            mainViewWidthConstraint.constant = SCREEN_WIDTH/2
            linkedinView.isHidden = false
            phoneView.isHidden = true
        }
        else if type == .phone{
            phoneVerifyViewConstraint.constant = SCREEN_WIDTH/2
            linkedInViewWidthConstaint.constant = 0
            spaceBetweenBothTheViewsConstant.constant = 0
            mainViewWidthConstraint.constant = SCREEN_WIDTH/2
            linkedinView.isHidden = true
            phoneView.isHidden = false
        }
        else if type == .both{
            linkedInViewWidthConstaint.constant = SCREEN_WIDTH/2
            phoneVerifyViewConstraint.constant = SCREEN_WIDTH/2
            spaceBetweenBothTheViewsConstant.constant = 10
            mainViewWidthConstraint.constant = SCREEN_WIDTH
            linkedinView.isHidden = false
            phoneView.isHidden = false
        }
    }
}
