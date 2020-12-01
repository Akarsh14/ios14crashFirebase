//
//  EditProfileTagCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 05/06/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import SnapKit

class EditProfileTagCell: UITableViewCell {
    
    @IBOutlet weak var addOtherTagsButton: UIButton!
    var collectionHolder : CollectionHolder?
    
    @IBOutlet weak var addTagsButtonHeightConstraint: NSLayoutConstraint!
    var addTagHandler : (()->())?
    
    var isUsedForRelationShipOrZodiac : Bool = false

    fileprivate var _tagArray : [TagModel]?
    
    var tagArray : [TagModel]? {
        get{
            return _tagArray
        }
        set(newArray) {
            _tagArray = newArray
            
            if collectionHolder != nil {
                collectionHolder?.tagArray = _tagArray
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        collectionHolder = CollectionHolder.loadView(CGRect(x: 0, y: 0,
                                                            width: UIScreen.main.bounds.width - 16, height: 100))
        self.contentView.addSubview(collectionHolder!)
    }
    
    func showOrHideAddButtonBasedOnData(){
        var bottomValue = 46.0
        if isUsedForRelationShipOrZodiac{
            addOtherTagsButton.setTitle("ADD", for: .normal)
            if (tagArray?.count)! > 0{
                addTagsButtonHeightConstraint.constant = 0
                bottomValue = 0.0
                addOtherTagsButton.isHidden = true
            }
            else{
                addOtherTagsButton.isHidden = false
            }
        }
        
        self.collectionHolder!.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0.0)
            make.right.equalToSuperview().offset(0.0)
            make.top.equalToSuperview().offset(10.0)
            make.bottom.equalToSuperview().offset(-bottomValue)
        }
    }

    @IBAction func addTagButtonPressed(_ sender: AnyObject) {
        if addTagHandler != nil {
            addTagHandler!()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
