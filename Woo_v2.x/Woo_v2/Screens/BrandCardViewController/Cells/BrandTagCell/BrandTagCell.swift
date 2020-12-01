//
//  BrandTagCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 05/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

let kTagGreyColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 0.5).cgColor
let kTagGreyColorDeep = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0).cgColor

class BrandTagCell: UITableViewCell {

    @IBOutlet weak var tagCollectionView: UICollectionView!
    var tapHandler : (() -> ())?

    fileprivate var _tagArray : [BrandCardTagModel]?
    var tagArray : [BrandCardTagModel]? {
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func sizeForView(_ text:String, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 30 , height: height)
    }
}

extension BrandTagCell : UICollectionViewDataSource{
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if tagArray == nil {
            return 0
        }
        return (tagArray?.count)!
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cellIdentifier = "BrandTagCollectionCell"
        
        let cell : BrandTagCollectionCell? = (tagCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BrandTagCollectionCell
            )
        cell!.layer.masksToBounds = false
        cell?.layer.cornerRadius = 2.0
        cell?.layer.borderColor = kTagGreyColor
        cell?.layer.borderWidth = 1.0
        cell?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell?.layer.shadowColor = kTagGreyColor
        cell?.layer.shadowRadius = 2.0
        cell!.layer.shadowOpacity = 1.0
        cell?.clipsToBounds = false
        
        let tag : BrandCardTagModel = tagArray![(indexPath as NSIndexPath).row] as BrandCardTagModel
        cell?.tagLabel.text = "#" + tag.name!
        return cell!
    }
}

extension BrandTagCell : UICollectionViewDelegateFlowLayout{
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let tag : BrandCardTagModel = tagArray![(indexPath as NSIndexPath).row] as BrandCardTagModel
        
        return self.sizeForView(tag.name!, font: UIFont(name: "Lato-Regular", size: 14.0)!, height: 32.0)
    }
}

extension BrandTagCell : UICollectionViewDelegate{
    internal func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.tapHandler != nil {
            self.tapHandler!()
        }
    }
}

class BrandTagCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!

}

class MiddleAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}
