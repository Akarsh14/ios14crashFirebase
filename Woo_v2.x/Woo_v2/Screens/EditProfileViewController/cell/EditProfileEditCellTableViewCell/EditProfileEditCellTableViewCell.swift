//
//  EditProfileEditCellTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 20/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class EditProfileEditCellTableViewCell: UITableViewCell {

    @IBOutlet weak var subHeaderLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var subHeaderLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    var subTypeString:String?
    var buttonTappedHandler:((String)->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func editOrAdd(_ sender: Any) {
        if buttonTappedHandler != nil{
            if let value = subTypeString{
            buttonTappedHandler(value)
            }
            else{
                buttonTappedHandler("")
            }
        }
    }
    
}
