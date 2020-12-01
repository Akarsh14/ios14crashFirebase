//
//  MyProfileCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 21/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import Foundation
import Contacts
import SDWebImage

class MyProfileCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setMyProfileCellDetail(cellDetail:NSDictionary) -> Void{
        profilePic.image = UIImage(named: cellDetail["image"] as! String)
        
        profilePic.backgroundColor = UIColor.clear
        let profilePicString = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl()
        
        
        let finalString = Utilities().validString(profilePicString)
        if (finalString?.count)! > 0 {
            
            if let wooProfilePicURLstr = Utilities().encode(fromPercentEscape: DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl())   {
                let urlString = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\(wooProfilePicURLstr)"
                
                let croppedImageURL = URL(string: urlString as String)
                
//                profilePic.sd_setImageWithURL(croppedImageURL)
//                profilePic.sd_setImageWithURL(croppedImageURL, completed: { (imageObj, error, cacheType, imageUrl) in
//                    self.profilePic.layer.cornerRadius = 32.0
//                    self.profilePic.layer.masksToBounds = true
//                })
                profilePic.sd_setImage(with: croppedImageURL, placeholderImage: UIImage.init(named: "ic_me_avatar_small"), options: SDWebImageOptions(), completed: { (imageObj, error, cacheType, imageUrl) in
                    self.profilePic.layer.cornerRadius = 32.0
                    self.profilePic.layer.masksToBounds = true
                })
            }
        }

        
        
        titleLabel.text = cellDetail["title"] as? String
    }
}
