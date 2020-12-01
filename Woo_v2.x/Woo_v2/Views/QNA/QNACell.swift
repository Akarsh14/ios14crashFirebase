//
//  QNACell.swift
//  QNA
//
//  Created by Kuramsetty Harish on 08/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class QNACell: UICollectionViewCell {

    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var txtLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 6
        self.contentView.layer.borderWidth = 0.5
        
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.75
        self.layer.masksToBounds = false
       // self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
        // Initialization code
    }
    
    

}




