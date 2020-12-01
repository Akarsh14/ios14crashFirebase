//
//  BundledProfileDeckView.swift
//  Woo_v2
//
//  Created by Ankit Batra on 24/10/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

class BundledProfileDeckView: UIView {

    @IBOutlet weak var trailingConstraintContainerFromSuperView: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var extraNumberOfProfilesLabel: UILabel!
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var crushButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var expiryView: UIView!
    
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var lockedBlurrImageView: UIImageView!
    var currentMeDataType:MeDataType = MeDataType.LikedMe

    var dismissHandler:((PerformAction, AnyObject)->Void)!
    var userDetails:AnyObject?
    
    let kConstaintOrignalValue = 30.0
    let gradientTop:CAGradientLayer = CAGradientLayer()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        return self
    }
    
    /**
     This function loads the nib
     */
    class func loadViewFromNib(frame:CGRect) -> BundledProfileDeckView {
        let profileView: BundledProfileDeckView =
            Bundle.main.loadNibNamed("BundledProfileDeckView", owner: self, options: nil)!.first as! BundledProfileDeckView
        profileView.frame = frame
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
        return profileView
    }
    
    func setDataForProfile(profileDetails:AnyObject, type:MeDataType, lockedState:Bool, showLock:Bool, noOfTotalProfiles:Int, isExpired:Bool){
        
        let multiplier = SCREEN_WIDTH/320.0
        trailingConstraintContainerFromSuperView.constant = CGFloat(kConstaintOrignalValue) * multiplier

        userDetails = profileDetails
        var imageString = ""
        var firstName = ""
        var age = ""
        var timeStamp:Date = Date()
        
        currentMeDataType = type
        if type == .LikedMe{
            imageString = (userDetails as! LikedByMe).userProfilePicURL  ?? ""
            firstName = (userDetails as! LikedByMe).userFirstName  ?? ""
            age = (userDetails as! LikedByMe).userAge  ?? ""
            timeStamp = (userDetails as! LikedByMe).userExpiryTime  ?? Date()
            
        }
        else if type == .Visitors{
            imageString = (userDetails as! MeDashboard).visitorProfilePicURL  ?? ""
            firstName = (userDetails as! MeDashboard).visitorFirstName  ?? ""
            age = (userDetails as! MeDashboard).visitorAge  ?? ""
            timeStamp = (userDetails as! MeDashboard).visitorExpiryTime  ?? Date()
        }
        else if type == .SkippedProfiles{
            imageString = (userDetails as! SkippedProfiles).userProfilePicURL ?? ""
            firstName = (userDetails as! SkippedProfiles).userFirstName  ?? ""
            age = (userDetails as! SkippedProfiles).userAge  ?? ""
            timeStamp = (userDetails as! SkippedProfiles).userExpiryTime  ?? Date()
        }
        
        if lockedState {
            dislikeButton.isHidden = true
            likeButton.isUserInteractionEnabled = false
            crushButton.isUserInteractionEnabled = false
            crushButton.isSelected = true
            likeButton.isSelected = true
            
            if showLock {
                bottomViewHeightConstraint.constant = 0.0
                bottomView.isHidden = true
                nameAgeLabel.isHidden = true
                lockedBlurrImageView.isHidden = false
            }
            else{
                lockedBlurrImageView.isHidden = true
                bottomViewHeightConstraint.constant = self.frame.size.height * 0.23
                gradientTop.removeFromSuperlayer()
                nowAddGradientToView()
            }
        }else{
            dislikeButton.isHidden = true
            bottomViewHeightConstraint.constant = self.frame.size.height * 0.23
            crushButton.isSelected = false
            likeButton.isSelected = false
            lockedBlurrImageView.isHidden = true
            likeButton.isUserInteractionEnabled = true
            crushButton.isUserInteractionEnabled = true
            nameAgeLabel.isHidden = false
            bottomView.isHidden = false
            gradientTop.removeFromSuperlayer()
            nowAddGradientToView()
        }
        
        if isExpired == true{
            
            let expiryDays:Double = Double(AppLaunchModel.sharedInstance().meSectionProfileExpiryDays * 24 * 3600)
            DateFormatter().timeZone = TimeZone(secondsFromGMT: 0)
            let serverTime = timeStamp.timeIntervalSince1970
            let currentTime = Date().timeIntervalSince1970
            
            var daysOfExpiry = (serverTime + expiryDays) - currentTime
            daysOfExpiry = Double(Int(daysOfExpiry/(24*3600))) + 1
            crushButton.setImage(UIImage(named: "ic_me_crush_visitors_small"), for: UIControl.State.normal)
            crushButton.setImage(UIImage(named: "ic_me_reject_small_normal"), for: UIControl.State.selected)
            crushButton.setImage(UIImage(named: "ic_me_crush_visitors_small_tapped"), for: UIControl.State.highlighted)
            likeButton.setImage(UIImage(named: "ic_me_like_visitors_normal_small"), for: UIControl.State.normal)
            likeButton.setImage(UIImage(named: "ic_me_like_red_small_normal"), for: UIControl.State.selected)
            likeButton.setImage(UIImage(named: "ic_me_like_visitors_normal_small_tapped"), for: UIControl.State.highlighted)
            
           // expiryView.isHidden = false
            var daysText = ""
            if daysOfExpiry > 0 {
                if daysOfExpiry > 1{
                    daysText = "days"
                }
                else{
                    if daysOfExpiry == 1 {
                        daysText = "day"
                    }
                }
                
                if daysText.count > 0 {
                    expiryLabel.text = "\(Int(daysOfExpiry)) " + daysText + " left"
                }
                else{
                   // expiryView.isHidden = true
                }
            }
            else{
                if daysOfExpiry == 0 {
                    expiryLabel.text = "1 day left"
                }
            }
        }
        else{
            //expiryView.isHidden = true
        }
        
        
        var croppedPhoto = ""
        
        if imageString.hasPrefix(kImageCroppingServerURL) {
            croppedPhoto = imageString
        }
        else{
            let meWidth = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints: 150)
            let meHeight = meWidth * 3/2
            let aImageURL = "?url=" + imageString
            let aHeightOfURL = "&height=" + (NSString(format: "%d", meHeight) as String)
            let aWidthOfURL = "&width=" + (NSString(format: "%d", meWidth) as String)
            croppedPhoto = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
        }
        
        
        profileImageView.sd_setImage(with: URL(string: croppedPhoto), placeholderImage: nil, options: SDWebImageOptions(), completed: { (imageObj, error, cacheType, imageUrl) in
                if (imageObj != nil){
                    self.modifyExpiryView(imageForBlurr: imageObj!)
            }
        })
        
        var nameAgeString = ""
        if firstName.count > 0{
            nameAgeString = firstName
            if age.count > 0{
                nameAgeString = nameAgeString + ", \(age)"
            }
        }
        nameAgeLabel.text = nameAgeString
        
        nameAgeLabel.text = ""
        bottomView.isHidden = true
        
    }
    
    func nowAddGradientToView(){
        
        gradientTop.colors = [kGradientColorBlackTopForMeProfile, kGradientColorClear]
        gradientTop.frame = CGRect(x: 0, y: 0,
                                   width: UIScreen.main.bounds.width,
                                   height: self.profileImageView.bounds.size.height/5);
        self.profileImageView.layer.addSublayer(gradientTop)
    }
    
    func modifyExpiryView(imageForBlurr:UIImage){
        self.lockedBlurrImageView.image = UIImageEffects.imageByApplyingBlur(to: imageForBlurr, withRadius: 50.0, tintColor: UIColor.clear, saturationDeltaFactor: 1.0, maskImage: nil)
    }
    
    func modifyProfileDeckView(){
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 5.0
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.3
    }


}
