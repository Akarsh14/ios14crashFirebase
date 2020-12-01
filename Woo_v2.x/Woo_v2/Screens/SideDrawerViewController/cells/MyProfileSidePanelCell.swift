//
//  MyProfileSidePanelCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 12/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import SDWebImage

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MyProfileSidePanelCell: UITableViewCell {

    @IBOutlet weak var blurImageview: UIImageView!
    @IBOutlet weak var circularImageView: UIImageView!
    @IBOutlet weak var arcProgressView: ArcProgressbar!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tipslabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    
    //@IBOutlet weak var editButtonTrailingConstrain: NSLayoutConstraint!
    @IBOutlet weak var tipTextWidthConstrain: NSLayoutConstraint!
    
    var editButtonHandler : ((String) -> ())?
    
    var tipsButtonHandler : (() -> ())?
    
    var imageButtonHandler : (() -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func imageButtonPressed(_ sender: AnyObject) {
        if imageButtonHandler != nil {
            imageButtonHandler!()
        }
    }
    
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        if editButtonHandler != nil {
            editButtonHandler!((editProfileButton.titleLabel?.text)!)
        }
    }
    
    @IBAction func tipsPressed(_ sender: AnyObject) {
        if tipsButtonHandler != nil {
            tipsButtonHandler!()
        }
    }
    
    func setData() {
        let myProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        if myProfile != nil {
            if let number = NumberFormatter().number(from: (myProfile!.profileCompletenessScore)) {
                arcProgressView.progressValue = CGFloat(truncating: number)
                progressLabel.text = "\(number)%"
            }
        }
        
        if let name = myProfile?.myName(){
            nameLabel.text = name
        }
        
        if let wooProfilePicURLstr = Utilities().encode(fromPercentEscape: myProfile?.wooAlbum?.profilePicUrl()){
            
            blurImageview.image = self.blurImageOf(UIImage(named: "ic_me_avatar_small")!)
            
            let urlString = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\(wooProfilePicURLstr)"
            
            let croppedImageURL = URL(string: urlString as String)

            circularImageView.sd_setImage(with: croppedImageURL, placeholderImage: UIImage.init(named: "ic_me_avatar_small"), options: SDWebImageOptions(), completed: { (imageObj, error, cacheType, imageUrl) in
                if imageObj != nil {
                    self.blurImageview.image = self.blurImageOf(imageObj!)
                }
            })
        }
        else{
            circularImageView.image = UIImage(named: "ic_me_avatar_small")
            blurImageview.image = self.blurImageOf(circularImageView.image!)
        }
        
      //  editButtonTrailingConstrain.constant = 16 //+ UIScreen.mainScreen().bounds.width/5
        if SCREEN_WIDTH > 320 {

            tipslabel.font = UIFont(name: "Lato-Regular", size: 16.0)
        }
    }
    
    func setEditButtonImageBasedOnUrl( urlString:String){
        if let analyzeData = AppLaunchModel.sharedInstance().analyzeProfileDto{
        if urlString == (analyzeData as NSDictionary).object(forKey: "cta") as! String{
           editProfileButton.setTitle(urlString, for: .normal)
           editProfileButton.setImage(UIImage(), for: .normal)
        
        }
        else{
            editProfileButton.setImage(UIImage.init(named: "ic_left_menu_me_edit"), for: .normal)
            editProfileButton.setTitle("EDIT PROFILE", for: .normal)
        }
        }
        else{
            editProfileButton.setImage(UIImage.init(named: "ic_left_menu_me_edit"), for: .normal)
            editProfileButton.setTitle("EDIT PROFILE", for: .normal)
        }
        
        if urlString.contains("wooapp://") {
            let deepLinkKey = urlString.replacingOccurrences(of: "wooapp://", with: "")
            if deepLinkKey.count > 0 {
                let arr = deepLinkKey.components(separatedBy: "?")
                
                if arr.count >= 0 {
                    let optionValue = (arr[0] as String).replacingOccurrences(of: "/link", with: "")
                    if let option = DeepLinkingOptions(rawValue: optionValue) {
                        if option == .ethnicitySelectionScreen {
                            //show ethnicity flag
                           // editProfileButton.setImage(UIImage.init(named: "ic_edit_profile_ethnicity"), for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    func blurImageOf(_ image: UIImage) -> UIImage {
        return UIImageEffects.imageByApplyingBlur(to: image, withRadius: 10.0, tintColor: UIColor(red: 224.0, green: 224.0, blue: 224.0, alpha: 0.8), saturationDeltaFactor: 1.0, maskImage: nil)
    }
}
