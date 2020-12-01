//
//  ProfileInfoTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 03/01/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var profileInfoCollectionView: UICollectionView!
    
    @IBOutlet weak var separatorViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    fileprivate var _profileInfoArray : [ProfileInfoTagModel]?
    
    var profileInfoTagsArray : [ProfileInfoTagModel]? {
        get{
            return _profileInfoArray
        }
        set(newArray) {
            _profileInfoArray = newArray
            profileInfoCollectionView.reloadData()
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
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.size.width - 40)/2, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        return CGSize(width: (UIScreen.main.bounds.size.width - 40)/2, height: label.frame.size.height)
    }

}


extension ProfileInfoTableViewCell : UICollectionViewDataSource{
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if profileInfoTagsArray == nil {
            return 0
        }
        return (profileInfoTagsArray?.count)!
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cellIdentifier = "ProfileInfoCollectionCell"
        
        let cell : ProfileInfoCollectionCell? = (profileInfoCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileInfoCollectionCell
        )
        
        
        let profileInfo : ProfileInfoTagModel = profileInfoTagsArray![(indexPath as NSIndexPath).row] as ProfileInfoTagModel
        let sizeOfCell:CGSize = sizeForView(profileInfo.name!, font: UIFont(name: "Lato-Regular", size: 16.0)!, height: 20.0)
        cell?.tagNameLabelHeightConstraint.constant = sizeOfCell.height
        if indexPath.row % 2 == 0 {
            cell?.tagNameLabelLeadingConstraint.constant = 20
            cell?.tagTitleLabelLeadingConstraint.constant = 20
            cell?.tagTitleTrailingConstraint.constant = 0
            cell?.tagNameTrailingConstraint.constant = 0
        }
        else{
            cell?.tagNameLabelLeadingConstraint.constant = 10
            cell?.tagTitleLabelLeadingConstraint.constant = 10
            cell?.tagTitleTrailingConstraint.constant = 10
            cell?.tagNameTrailingConstraint.constant = 10
        }
        cell?.layoutIfNeeded()
        cell?.tagNameLabel.text = profileInfo.name
        cell?.tagTitleLabel.text = profileInfo.tagsTitle
        return cell!
    }
}


extension ProfileInfoTableViewCell : UICollectionViewDelegateFlowLayout{
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let profileInfo : ProfileInfoTagModel = profileInfoTagsArray![(indexPath as NSIndexPath).row] as ProfileInfoTagModel
        var secondProfileInfo:ProfileInfoTagModel?
        if indexPath.row % 2 == 0 {
            if indexPath.row < ((profileInfoTagsArray?.count)! - 1) {
            secondProfileInfo = profileInfoTagsArray![(indexPath as NSIndexPath).row + 1] as ProfileInfoTagModel
            }
            else{
                secondProfileInfo = nil
            }
        }
        else{
            secondProfileInfo = profileInfoTagsArray![(indexPath as NSIndexPath).row - 1] as ProfileInfoTagModel
        }
        
        let sizeOfCell:CGSize = self.sizeForView(profileInfo.name!, font: UIFont(name: "Lato-Regular", size: 16.0)!, height: 20.0)
        var extraHeight:CGFloat = 0.0
        var heightForSecondProfile:CGFloat = 0.0
        if let second = secondProfileInfo{
            let sizeOfCellForSecondProfile:CGSize = self.sizeForView(second.name ?? "", font: UIFont(name: "Lato-Regular", size: 16.0)!, height: 20.0)
            heightForSecondProfile = sizeOfCellForSecondProfile.height
        }
        if sizeOfCell.height > 20 || heightForSecondProfile > 20{
            extraHeight = 20.0
        }
        else{
            extraHeight = 0.0
        }
       
        return CGSize(width: UIScreen.main.bounds.size.width/2, height: 50 + extraHeight)

    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}

extension ProfileInfoTableViewCell : UICollectionViewDelegate{
    internal func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

class ProfileInfoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var tagTitleLabel: UILabel!
    @IBOutlet weak var tagNameLabel: UILabel!
    
    @IBOutlet weak var tagNameLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTitleLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagNameLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTitleTrailingConstraint: NSLayoutConstraint!
}

