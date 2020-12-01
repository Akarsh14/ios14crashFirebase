//
//  AboutHeaderCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 03/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit

class AboutHeaderCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var separatorViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var headerLabelWidthConstrain: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func sizeForView(_ text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.size.width
    }
    
    func setHeaderText(_ text : String) {
        headerLabel.text = text
        
        headerLabelWidthConstrain.constant = self.sizeForView(text, font: UIFont(name: "Lato-Bold", size: 16.0)!, height: 21.0) + 40
    }
}
