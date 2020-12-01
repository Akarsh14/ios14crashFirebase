//
//  PhotoCollectionViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblTopNumber: UILabel!
    @IBOutlet weak var ToplblNumConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftlblNumberConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var deletePhotoRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageDeleteHandler : (() -> ())?

    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var addImageView: UIImageView!
    
    @IBAction func deleteImage(_ sender: Any) {
        if imageDeleteHandler != nil{
            imageDeleteHandler!()
        }
    }
    
    let strokeTextAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.strokeWidth : -3.0,
        ]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblTopNumber.attributedText = NSAttributedString(string: lblTopNumber.text!, attributes: strokeTextAttributes)

    }
}

import UIKit

class UIOutlinedLabel: UILabel {
    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.white
    
    override func drawText(in rect: CGRect) {
        let attributes: [NSAttributedString.Key : Any] = [.strokeWidth: -3.0,
                                                         .strokeColor: UIColor.gray,
                                                         .foregroundColor: UIColor.white]
         self.attributedText = NSAttributedString(string: self.text ?? "", attributes: attributes)
        super.drawText(in: rect)
    }
}
