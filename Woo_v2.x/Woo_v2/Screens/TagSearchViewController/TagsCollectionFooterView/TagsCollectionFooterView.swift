//
//  TagsCollectionFooterView.swift
//  Woo_v2
//
//  Created by Ankit Batra on 11/06/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class TagsCollectionFooterView: UICollectionReusableView {
    
    var  editMyTagsButtonTappedHandler:(()->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func editMyTagsButtonTapped(_ sender:UIButton)
    {
        editMyTagsButtonTappedHandler()
    }
}
