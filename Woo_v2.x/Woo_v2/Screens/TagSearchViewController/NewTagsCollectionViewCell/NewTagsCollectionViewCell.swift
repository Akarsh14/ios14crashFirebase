//
//  NewTagsCollectionViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 11/06/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class NewTagsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func isSelected(_ selected:Bool)
    {
        
        if(selected)
        {
            containerView.backgroundColor = UIColorHelper.color(withRGBA: "#9257DB")
            tagLabel.textColor = UIColor.white
            containerView.layer.borderColor = UIColor.white.cgColor
            containerView.layer.borderWidth = 1.0

        }
        else
        {
            containerView.layer.borderColor = UIColorHelper.color(withRGBA: "#9257DB").cgColor
            containerView.layer.borderWidth = 1.0
            containerView.backgroundColor = .white
            tagLabel.textColor = UIColorHelper.color(withRGBA: "#9257DB")
        }
    }

}
