//
//  LinkedInSyncTableViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 16/04/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class LinkedInSyncTableViewCell: UITableViewCell {

    var linkedInButtonHandler : (()->())?

    @IBOutlet weak var linkedInButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var syncLinkedInButton: UIButton!
    @IBOutlet weak var addLinkedInTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViewBasedOnSyncOption(_ isSynced:Bool, isUsedInWorkAndEducation:Bool){
        if isSynced{
            syncLinkedInButton.isSelected = true
            syncLinkedInButton.backgroundColor = UIColor.clear
            syncLinkedInButton.isUserInteractionEnabled = false
            linkedInButtonWidthConstraint.constant = self.frame.size.width
            addLinkedInTextLabel.isHidden = true
        }
        else{
            syncLinkedInButton.isSelected = false
            syncLinkedInButton.backgroundColor = UIColorHelper.color(withRGBA: "#0C62A6")
            addLinkedInTextLabel.isHidden = false
        }
        if !isUsedInWorkAndEducation{
            syncLinkedInButton.setImage(UIImage(named: ""), for: .selected)
            syncLinkedInButton.setTitleColor(UIColor.white, for: .selected)
        }
    }
    
    @IBAction func linkedInSyncResyncTapped(_ sender: UIButton) {
        if((linkedInButtonHandler) != nil)
        {
            linkedInButtonHandler!()
        }
    }
    
}
