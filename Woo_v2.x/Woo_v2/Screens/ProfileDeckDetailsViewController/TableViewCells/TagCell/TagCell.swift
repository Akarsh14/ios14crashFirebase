//
//  TagCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 05/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {

    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagCollectionView: UICollectionView!
   
    @IBOutlet weak var tagView: UIView!
    var getTappedTagHandler:((TagModel)->Void)!
    
    @IBOutlet weak var separatorView: UIView!
    var isCollectionViewLoaded : Bool?
    fileprivate var _tagArray : [TagModel]?
    var tagArray : [TagModel]? {
        get{
            return _tagArray
        }
        set(newArray) {
            _tagArray = newArray
            tagCollectionView.reloadData()

            let indexPath : IndexPath = IndexPath(row: _tagArray!.count - 1, section: 0)
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isCollectionViewLoaded = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func sizeForView(_ text:String, font:UIFont, height:CGFloat, type:String) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text + "#"
        
        label.sizeToFit()
        if type != "FACEBOOK_LIKES" {
            return CGSize(width: label.frame.size.width + 36 , height: 32)
        }
        else{
            return CGSize(width: label.frame.size.width + 36 + 24, height: 32)
        }
    }
}

extension TagCell : UICollectionViewDataSource{
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if tagArray == nil {
            return 0
        }
        return (tagArray?.count)!
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cellIdentifier = "tagCollectionViewCell"
        
        let cell : TagCollectionCell? = (tagCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TagCollectionCell
            )
        cell!.layer.masksToBounds = false
        cell?.layer.cornerRadius = 16.0
        cell?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell?.layer.shadowColor = UIColor.gray.cgColor
        cell?.layer.shadowRadius = 2.0
        cell!.layer.shadowOpacity = 1.0
        cell?.clipsToBounds = true
        
        let tag : TagModel = tagArray![(indexPath as NSIndexPath).row] as TagModel
        cell?.tagLabel.text = "#" + tag.name!
        if tag.type != "FACEBOOK_LIKES" {
            cell?.facebookViewWidthConstrain.constant = 0
        }
        else{
            cell?.facebookViewWidthConstrain.constant = 34
        }
        
        if(tag.isCommon == true)
        {
            cell?.tagView.backgroundColor = UIColorHelper.color(fromRGB: "#9275DB", withAlpha: 1.0)
            cell?.tagLabel.textColor = .white
        }
        else
        {
            cell?.tagView.backgroundColor = UIColor.white
            cell?.tagLabel.textColor = UIColorHelper.color(fromRGB: "#9275DB", withAlpha: 1.0)
            cell?.layer.borderColor = UIColorHelper.color(fromRGB: "#9275DB", withAlpha: 1.0).cgColor
            cell?.layer.borderWidth = 1.0
        }

        cell?.layoutSubviews()
        
        return cell!
    }
}


extension TagCell : UICollectionViewDelegateFlowLayout{
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let tag : TagModel = tagArray![(indexPath as NSIndexPath).row] as TagModel
        
        return self.sizeForView(tag.name!, font: UIFont(name: "Lato-Regular", size: 16.0)!, height: 20.0, type: tag.type!)
    }
}

extension TagCell : UICollectionViewDelegate{
    internal func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        if !isCollectionViewLoaded! {
            isCollectionViewLoaded = true
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTagModel:TagModel = tagArray![(indexPath as NSIndexPath).row] as TagModel
        if getTappedTagHandler != nil {
            getTappedTagHandler(selectedTagModel)
        }
    }
}

class TagCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagView: UIView!
    
    @IBOutlet weak var facebookViewWidthConstrain: NSLayoutConstraint!
    
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementKind != "UICollectionElementKindSectionHeader"{
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
            }
        }
        
        return attributes
    }
}
