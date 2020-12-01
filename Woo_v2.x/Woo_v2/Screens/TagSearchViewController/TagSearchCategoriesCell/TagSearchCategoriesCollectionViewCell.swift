//
//  TagSearchCategoriesCollectionViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 04/06/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class TagSearchCategoriesCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var selectedViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func changeToSelected(_ value:Bool)
    {
        if(value == true)
        {
            self.categoryLabel.textColor = UIColorHelper.color(fromRGB: "#9275DB", withAlpha: 1.0)
            self.categoryLabel.font = UIFont(name: "Lato-Bold", size: 14.0)
            self.selectedView.isHidden = false
        }
        else
        {
            self.categoryLabel.textColor = UIColorHelper.color(fromRGB: "#979797", withAlpha: 1.0)
            self.categoryLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
            self.selectedView.isHidden = true
        }
    }
}
