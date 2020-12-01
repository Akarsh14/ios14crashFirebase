//
//  ImageTextSidePanelCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 12/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

class ImageTextSidePanelCell: UITableViewCell {

    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var optionTextLabel: UILabel!
    
    @IBOutlet weak var optionLabelLeadingConstrain: NSLayoutConstraint!
    @IBOutlet weak var bottomLine:UIView!
    
    func setData(_ optionText: String, optionIcon: String?) {
        if optionIcon == nil || optionIcon?.count == 0{
            optionLabelLeadingConstrain.constant = 20.0
        }
        else{
            optionLabelLeadingConstrain.constant = 50.0
            optionImageView.image = UIImage(named: optionIcon!)
        }
        optionTextLabel.text = optionText
    }
    
    func showLine(_ shouldShow:Bool) {
        bottomLine.isHidden = !shouldShow
    }
}
