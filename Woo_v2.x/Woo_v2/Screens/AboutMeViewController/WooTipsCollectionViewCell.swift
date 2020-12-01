//
//  WooTipsCollectionViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 03/06/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class WooTipsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tipsImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func showImageOnTipsImageView(_ tipsModel:WooTipsViewModel){
        tipsImageView.image = tipsModel.tipsImage
    }

}
