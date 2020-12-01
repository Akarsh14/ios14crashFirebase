//
//  ProfileDeckView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 23/05/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import QuartzCore
import SnapKit
import PINRemoteImage

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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}



protocol ProfileDeckViewDelegate: class {
    func getTheSelectedCommonality(_ commonalitySelected:String)
}

@IBDesignable open class ProfileDeckView: UIView {
    
    @IBOutlet weak var myProfileBakcgroundView: UIView!
    @IBOutlet weak var myProfileTextLabel: UILabel!
    @IBOutlet weak var myProfileOnboardingBotView: UIView!
    @IBOutlet weak var myProfileBottomView: UIView!
    @IBOutlet weak var myProfileProgressView: ArcProgressbar!
    @IBOutlet weak var myProfileProgressContainerView: UIView!
    @IBOutlet weak var myProfileProfileCompleteLabel: UILabel!
    @IBOutlet weak var myProfileBottomViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var myProfileBottomViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var myProfileBottomViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var snapShotView: UIView!
    @IBOutlet weak var snapShotImageView: UIImageView!
    @IBOutlet weak var aboutMeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var crushMessageDescriptionLabel: UILabel!
    @IBOutlet weak var profileOfTheDayLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    var imageGalleryView: StrechableScrollView?
    @IBOutlet weak var imageGalleryContainerView: UIView!
    @IBOutlet weak var aboutMeLabelContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var crushMessageLabelContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var crushMessageLabelContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var crushMessageLabelContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var crushMessageLabelContainerView: UIView!
    @IBOutlet weak var profileOfTheDayLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileOfTheDayLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileDeckMainContainerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileDeckMainContainerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overLayContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var overLayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileDeckMainContainerView: UIView!
    @IBOutlet weak var ProfileDeckMainContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var friendsInCommonCountWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsInCommonCountLabelViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likedMeViewHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var tagsInCommonViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsInCommonViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagsInCommonImageContainerView: UIView!
    @IBOutlet weak var tagsInCommonCountLabelContainerView: UIView!
    
    @IBOutlet weak var tagsInCommonCountLabel: UILabel!
    @IBOutlet weak var friendsInCommonCountLabel: UILabel!
    
    @IBOutlet weak var commonalityTagsView: UIView!
    
    @IBOutlet weak var tagsContainerViewToBadgesViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayBackgroundColorView: UIView!
    @IBOutlet weak var overlayContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var aboutmeLabelContainerView: UIView!
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var NameAgeLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var heightLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var ethnicityCommonalityView: UIView!
    @IBOutlet weak var ethnicityCommanilityLabel: UILabel!
    @IBOutlet weak var ethnicityCommonalityViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var religionCommonalityViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var religionCommonalityImageView: UIImageView!
    @IBOutlet weak var religionCommonalityLabel: UILabel!
    @IBOutlet weak var religionCommonalityView: UIView!
    @IBOutlet weak var friendInCommonView: UIView!
    @IBOutlet weak var friendsInCommonImage: UIImageView!
    @IBOutlet weak var friendsInCommonLabel: UILabel!
    
    @IBOutlet weak var likedMeView: UIView!
    @IBOutlet weak var tagInCommonView: UIView!
    @IBOutlet weak var tagsInCommonLabel: UILabel!
        
    @IBOutlet weak var editProfileButton: UIButton!
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeIcon: UIImageView!
    @IBOutlet weak var badgeText: UILabel!
    
    @IBOutlet weak var crushMessageLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    var crushMessageContainerViewYValue:CGFloat = 0
    
    var crushMessageContainerViewHeightValue:CGFloat = -1.0
    
    var crushMessageContainerViewWidthValue:CGFloat = -1.0
    
    var aboutMeLabelContainerViewYValue:CGFloat = -1.0
    
    var aboutMeLabelContainerViewHeightValue:CGFloat = 45.0
    
    var myProfileBottomViewHeightValue:CGFloat = -1.0
    
    var myProfileBottomViewTopValue:CGFloat = -1.0
    
    var gradiantAlreadyAdded:Bool = false
    
    var cameFromChat = false
    
    @IBOutlet weak var myprofileBottomViewTopConstraint: NSLayoutConstraint!
    var profileDetails:ProfileCardModel?
    
    weak var delegate:ProfileDeckViewDelegate?
    
    var isThisMyProfile:Bool = false
    
    var isLoadedNotFromDiscover:Bool = false
    
    var getTappedIndexForGallery:((Int)->Void)?
    
    var closeDetailViewControllerHandler:(()->Void)?
    
    var closeTagPopupHandler:(()->Void)?
    
    let gradientTop:CAGradientLayer = CAGradientLayer()
    
    let gradientBottom:CAGradientLayer = CAGradientLayer()
    
    var animateViewComponent:Bool = false
    
    var gettingUsedInTagSearch:Bool = false
    
    var yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail:CGFloat = 0
    
    var yPositionOfMyProfileViewOrHeightThreshholdValueForMyProfile:CGFloat = 188
    
    var hadAlreadyBeenShownInDiscover:Bool = false
    
    var isProfileImageAlreadyThere:Bool = false
    
    var profileImageHasBeenChanged:Bool = false
    
    var isShownThroughChat:Bool = false
    
    var popularBadgeAlreadyMoved:Bool = false

    //added by Umesh to fix the issue of left and right margin
    @IBOutlet weak var leftMarginContraintOfPersonalQuote: NSLayoutConstraint!
    @IBOutlet weak var rightMarginContraintOfPersonalQuote: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
        let _:CGFloat = self.frame.size.height
        //ProfileDeckMainContainerViewHeightConstraint.constant = heightConstant
        //overLayViewHeightConstraint.constant = heightConstant
        //overLayContainerViewHeightConstraint.constant = heightConstant
        //self.performSelector(#selector(setupViewProperties), withObject: nil, afterDelay: 0.2)
    }
    
    /**
     @IBOutlet weak var commonalityTagsView: UIView!
     InitWithDecoder Method
     
     
     - parameter aDecoder: coder value
     
     - returns: returns Self
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        //loadViewFromNib()
        return self
    }
    
    /**
     This function loads the nib
     */
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProfileDeckView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func addADummyImageViewWithSnapShotToAvoidFlickerWhileReloadingDeck(_ snapImage:UIImage){
        snapShotImageView.image = snapImage
        snapShotView.isHidden = false
        //        UIView.animateWithDuration(0.25, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
        //            self.snapShotView.alpha = 0
        //            self.snapShotImageView.image = nil
        //            }, completion: nil)
        self.perform(#selector(nowRemoveDummyImageView), with: nil, afterDelay: 5.0)
    }
    
    @objc func nowRemoveDummyImageView(){
        snapShotView.isHidden = true
        self.snapShotImageView.image = nil
    }
    
    func setDataForProfileView(_ isThisMyProfileCard:Bool) {
        
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        isThisMyProfile = isThisMyProfileCard
        
        if profileDetails == nil {
            return
        }
        
        if isThisMyProfile == true {
            aboutMeLabel.textAlignment = .left
            self.backgroundColor = UIColor.white
            myProfileBottomView.alpha = 1
            myProfileProgressContainerView.isHidden = false
            if (Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!) < 100){
                myProfileOnboardingBotView.isHidden = false
            }
            else{
                myProfileOnboardingBotView.isHidden = true
            }
        }
        else{
            aboutMeLabel.textAlignment = .center
            myProfileBottomView.isHidden = true
            myProfileProgressContainerView.isHidden = true
        }
        //Profile of the day handling remaining
        
        profileOfTheDayLabelHeightConstraint.constant = 0.0
        profileOfTheDayLabelBottomConstraint.constant = 0.0
        
        if gettingUsedInTagSearch == true {
            yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail = 138
        }
        else{
            yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail = 188
        }
        
        //Setting Profile Photo
        if isThisMyProfileCard == true {
            //profileImageView.image = UIImage.init(named: "ic_onboarding_avatar_blue")
        }
        else{
            profileImageView.image = UIImage.init(named: "placeholder_male")
        }
        
       // imageGalleryContainerView.isHidden = true
        
        //Setting FirstName
        var lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 24.0)! ]
        if isThisMyProfile == false {
            if let nameAgeString = profileDetails?.firstName {
                let lString = NSMutableAttributedString(string: (nameAgeString), attributes: lAttribute )
                if let ageString = profileDetails?.age {
                    lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 24.0)! ]
                    let attrString = NSAttributedString(string: ", " + String(ageString), attributes: lAttribute )
                    lString.append(attrString)
                }
                self.NameAgeLabel.alpha = 1
                self.NameAgeLabel.attributedText = lString
            }
        }
        else{
            if let nameAgeString = (profileDetails as? MyProfileModel)?.myName() {
                let lString = NSMutableAttributedString(string: (nameAgeString), attributes: lAttribute )
                if let ageString = profileDetails?.age {
                    lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 24.0)! ]
                    let attrString = NSAttributedString(string: ", " + String(ageString), attributes: lAttribute )
                    lString.append(attrString)
                }
                self.NameAgeLabel.alpha = 1
                self.NameAgeLabel.attributedText = lString
            }
        }
        //Setting HeightLocation Text
        setHeightLocationText()
        
        //Setting AboutMe text
        setPersonalQuoteAndAboutMe()
        
        //Crush Message
        if isThisMyProfile == false {
            if profileDetails?.crushText.length > 0 {
                
                crushMessageDescriptionLabel.text = profileDetails?.crushText as! String
                let lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 14.0)!]
                let lString = NSMutableAttributedString(string: (profileDetails?.firstName)!, attributes: lAttribute)
                let attrString = NSAttributedString(string: NSLocalizedString(" sent you crush", comment: " sent you crush"))
                lString.append(attrString)
                
                crushMessageLabel.attributedText = lString
                UIView.animate(withDuration: 0.25, animations: {
                    self.crushMessageLabelContainerView.alpha = 1
                    self.crushMessageLabelContainerView.isHidden = false
                    self.crushMessageLabelContainerView.backgroundColor = UIColor(red: 146/255, green: 117/255, blue: 219/255, alpha: 1.0)
                    
                }, completion: { (true) in
                })
                aboutmeLabelContainerView.isHidden = true
            }
            else{
                if profileDetails?.personalQuote != nil {
                   // aboutmeLabelContainerView.isHidden = false
                }
                crushMessageLabelContainerView.isHidden = true
            }
            
        }
        else{
            aboutmeLabelContainerView.isHidden = true
            crushMessageLabelContainerView.isHidden = true
        }
        
        if isThisMyProfile == true{
            myProfileProgressView.progressValue = CGFloat(truncating: NumberFormatter().number(from: (profileDetails?.profileCompletenessScore)!)!)
        myProfileProfileCompleteLabel.text = "\(Int(myProfileProgressView.progressValue))%"
        }
    }
    
    func setPersonalQuoteAndAboutMe() {
        if cameFromChat{
            aboutmeLabelContainerView.isHidden = true
            return
        }
        if profileDetails?.personalQuote != nil && profileDetails?.personalQuote?.count>0 {
            if isThisMyProfile == true {
                myProfileTextLabel.text = profileDetails?.personalQuote
                myProfileTextLabel.font = UIFont(name: "Lato-Regular", size: 16.0)
            }
            else{
                aboutmeLabelContainerView.alpha = 0
                aboutmeLabelContainerView.isHidden = false

                aboutMeLabel.font = UIFont(name: "Lato-Regular", size: 16.0)
                aboutMeLabel.text = profileDetails?.personalQuote
            }
        }
        else if profileDetails?.about != nil && profileDetails?.about?.count > 0 {
            if isThisMyProfile == true {
                myProfileTextLabel.text = profileDetails?.about
                myProfileTextLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
            }
            else{
                aboutmeLabelContainerView.alpha = 0
                aboutmeLabelContainerView.isHidden = false
                aboutMeLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
                aboutMeLabel.text = profileDetails?.about
//                aboutmeLabelContainerView.alpha = 1
//                aboutmeLabelContainerView.isHidden = false
            }
        }
        else{
            aboutmeLabelContainerView.isHidden = true
        }
    }
    
    func setHeightLocationText(){
        
        var heightText = ""
        var locationText = ""
        print(profileDetails?.height ?? "none")
        if let height = profileDetails?.height {
            heightLabelWidthConstraint.constant = 50
            if isThisMyProfile == true  && profileDetails!.showHeightType == HeightUnit.CM{
                if let cmValue  = (Utilities.sharedUtility() as AnyObject).getCentimeterFromFeetInches(height) {
                    heightText = cmValue + " cm"
                }
                else{
                    heightText = height
                }
            }
            else{
                heightText = height
            }
        }
        else{
            heightLabelWidthConstraint.constant = 0
        }
        
        let textArray = heightText.components(separatedBy:  "\'")
        
        if textArray.count>1 {
            heightText = textArray[0] + "'" + textArray[1]
        }
        
        if let location = profileDetails?.location {
            if location.length > 0{
            if heightText.count > 0  {
                if ((WooGlobeModel.sharedInstance().isExpired == false) && (WooGlobeModel.sharedInstance().wooGlobleOption == true) && (WooGlobeModel.sharedInstance().locationOption == true)) {
                    heightText = heightText + ", "
                }
                else{
                    heightText = heightText + ","
                    
                }
            }
            let trimmedString = (location as String).trimmingCharacters(in: .whitespaces)
            locationText = " " + trimmedString + " "
            }
        }
        
        if ((WooGlobeModel.sharedInstance().isExpired == false) && (WooGlobeModel.sharedInstance().wooGlobleOption == true) && (WooGlobeModel.sharedInstance().locationOption == true)) {
            if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                locationLabel.backgroundColor = UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
            else{
                locationLabel.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
            
            if isThisMyProfile == true{
                if DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation.count > 0 {
                    locationText = NSLocalizedString(" Swiping in ", comment: "") + (DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation)! + " "
                }
            }
            else{
                if profileDetails?.diasporaLocation.count > 0 {
                    locationText = NSLocalizedString(" Swiping in ", comment: "") + (profileDetails?.diasporaLocation)! + " "
                }
            }
        }
        else{
            locationLabel.backgroundColor = UIColor.clear
        }
        
        let locationTextTrunctated = locationText.replacingOccurrences(of: " ", with: "")
        if locationTextTrunctated.count > 0{
            locationLabel.text = locationText
        }
        else{
            locationLabel.text = ""
            locationLabel.backgroundColor = UIColor.clear
        }
        
        if isThisMyProfile == false{
            if profileDetails?.diasporaLocationNearYou == true {
                locationText = NSLocalizedString(" Swiping near you ", comment: "")
                locationLabel.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
        }
        
        heightLabel.alpha = 1
        locationLabel.alpha = 1
        heightLabel.text = heightText
        locationLabel.text = locationText
    }
    
    @objc func setDataForCommonalityTagsAndBadges() {
        
        DispatchQueue.main.async {
            if self.isThisMyProfile == true {
                self.commonalityTagsView.isHidden = true
            }
            else{
                self.updateCommonalityTagsViewBasedOnThereAvailability(self.profileDetails)
            }
            
            //Ethnicity
            
            let ethnicityArray = self.profileDetails?.ethnicity
            
            var ethnicityName = ""
            
            if(ethnicityArray != nil && ethnicityArray?.count ?? 0 > 0)
            {
                for localEthnicity in ethnicityArray! {
                    if ethnicityName.count>0 {
                        ethnicityName = ethnicityName + "," + "\n" + localEthnicity.name!
                    }
                    else{
                        ethnicityName = localEthnicity.name!
                    }
                }
            }
            
            self.ethnicityCommanilityLabel.text = ethnicityName
            
            //Religion
            
            let religionArray = self.profileDetails?.religion
            
            var religionName = ""
            
            
            for localReligion in religionArray! {
                religionName = localReligion.name!
            }
            
            self.religionCommonalityLabel.text = religionName
            if(religionName != "")
            {
                let imageName = "http://u2-woostore.s3.amazonaws.com/ReligionImages/religions/iOS/@2x/\(religionName.lowercased()).png"
                self.religionCommonalityImageView.sd_setImage(with: URL(string: imageName), placeholderImage: UIImage(named: "ic_discover_commonality_religion"))
            }
            else
            {
                self.religionCommonalityImageView.image = UIImage(named: "ic_discover_commonality_religion")
            }
            
            //Friends In common
            if self.profileDetails?.mutualFriendCount() > 0 {
                self.friendsInCommonCountLabel.text = String(format: "%d", (self.profileDetails?.mutualFriendCount())!)
                let urlStr = self.profileDetails!.firstMutualFriendImageURL()
                if urlStr != nil {
                    self.friendsInCommonImage.sd_setImage(with: URL(string: urlStr!))
                }
                
                let numberString:NSString = self.friendsInCommonCountLabel.text! as NSString
                
                let numberSize:CGSize = numberString.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
                
                if numberSize.width > 20 {
                    self.friendsInCommonCountWidthConstraint.constant = numberSize.width + 10
                }
            }
            
            //Tags In common
            if self.profileDetails?.commonTagCount() > 0 {
                self.tagsInCommonCountLabel.text = String(format: "%d", (self.profileDetails?.commonTagCount())!)
                
                let numberString:NSString = self.tagsInCommonCountLabel.text! as NSString
                
                let numberSize:CGSize = numberString.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
                
                if numberSize.width > 20 {
                    self.tagsInCommonCountLabelViewWidthConstraint.constant = numberSize.width + 10
                }
            }
        }
    }
    
    /**
     Setting the profile image for user
     
     - parameter imageUrl:   url for image
     - parameter userGender: gender of user
     */
    func setProfileImageForUser(_ imageUrl:URL?, userGender:String?){
        
        if profileDetails?.profileImage != nil {
            isProfileImageAlreadyThere = true
        }
        if let profilePicUrl = imageUrl {
            
//            var placeHolderImageStr:String = ""
//            if (Utilities.sharedUtility() as AnyObject).isGenderMale(userGender) {
//                placeHolderImageStr = "placeholder_male"
//            }
//            else{
//                placeHolderImageStr = "placeholder_female"
//            }
            
//            if isProfileImageAlreadyThere {
////                let imageView:UIImageView = UIImageView()
////                imageView.sd_setImage(with: profilePicUrl, placeholderImage: nil, options: .highPriority, progress: nil, completed: { (image, error, cacheType, profilePicUrl) in
////                    self.profileImageView.image = image
////                })
//                profileImageView.sd_setImage(with: profilePicUrl)
//            }
//            else{
//              self.progressBar.startAnimating()
//              PINRemoteImageManager.shared().cache.removeAllObjects()
                PINRemoteImageManager.shared().setProgressiveRendersShouldBlur(true, completion: nil)
                profileImageView.pin_updateWithProgress = true
                profileImageView.pin_setImage(from: profilePicUrl) { (PINRemoteImageManagerResult) in

                     let imageData = self.profileImageView.image?.highestQualityJPEGNSData

                     self.profileImageView.image = UIImage(data: imageData! as Data)

                     let inputImage = CIImage(image: self.profileImageView.image!)!
                     let parameters = [
                        "inputContrast": NSNumber(value: 1.07)
                     ]
                     let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)

                     let context = CIContext(options: nil)
                     let img = context.createCGImage(outputImage, from: outputImage.extent)!
                    self.profileImageView.image = UIImage(cgImage: img)

                }
                
//            profileImageView.sd_setImage(with: profilePicUrl, placeholderImage: nil, options: .highPriority, progress: nil, completed: { (image, error, cacheType, profilePicUrl) in
////                 let inputImage = CIImage(image: self.profileImageView.image!)!
////                 let parameters = [
////                    "inputContrast": NSNumber(value: 1.14),
////                    "inputBrightness" : NSNumber(value: 0.05)
//////                        "inputSaturation" : NSNumber(value: 1.4)
////                 ]
////                 let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)
////
////                 let context = CIContext(options: nil)
////                 let img = context.createCGImage(outputImage, from: outputImage.extent)!
////                self.profileImageView.image = UIImage(cgImage: img)
////
//                let imageData = self.profileImageView.image?.highestQualityJPEGNSData
//                self.profileImageView.image = UIImage(data: imageData! as Data)
//
//             })
//            }
            
          }
    }
    
    @objc func setBadgeViewWithData(){
        //Badges Update
        if let profile = profileDetails {
            
            DispatchQueue.main.async {
                switch profile.badgeType {
                case Badges.VIP:
                    self.badgeIcon.image = UIImage(named: "badges_vip")
                    self.badgeText.text = NSLocalizedString("VIP", comment: "VIP")
                    self.badgeView.alpha = 1
                    break
                case Badges.New:
                    self.badgeIcon.image = UIImage(named: "badges_new")
                    self.badgeText.text = NSLocalizedString("New", comment: "New")
                    self.badgeView.alpha = 1
                    break
                case Badges.Popular:
                    self.badgeIcon.image = UIImage(named: "badges_popular")
                    self.badgeText.text = NSLocalizedString("Popular", comment: "Popular")
                    self.badgeView.alpha = 1
                    break
                default:
                    if self.badgesViewHeightConstraint != nil{
                        self.badgesViewHeightConstraint.constant = 0.0
                    }
                    if self.tagsContainerViewToBadgesViewTopConstraint != nil{
                        self.tagsContainerViewToBadgesViewTopConstraint.constant = 0.0
                    }
                    self.badgeView.isHidden = true
                }
            }
            
        }
    }
    
    /**
     This method will setup properties of view
     */
    @objc func setupViewProperties(){
        
        //self.layoutIfNeeded()
        
        if crushMessageContainerViewYValue > 0 {
            crushMessageLabelContainerViewTopConstraint.constant = crushMessageContainerViewYValue
            self.layoutIfNeeded()

            if crushMessageContainerViewWidthValue > 0 {
                crushMessageLabelContainerViewWidthConstraint.constant = crushMessageContainerViewWidthValue

            }
            else{
                crushMessageLabelContainerViewWidthConstraint.constant = 200.0
                crushMessageLabelContainerViewTopConstraint.constant = SCREEN_HEIGHT - yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail - 85 - safeAreaBoth
                self.layoutIfNeeded()
            }
            
            if crushMessageContainerViewHeightValue > 0 {
                crushMessageLabelContainerViewHeightConstraint.constant = crushMessageContainerViewHeightValue
            }
            else{
                crushMessageLabelContainerViewHeightConstraint.constant = 32.0
            }
        }
        
        if  aboutMeLabelContainerViewYValue > 0{
            
            aboutMeLabelTopConstraint.constant = aboutMeLabelContainerViewYValue
            self.layoutIfNeeded()

            if aboutMeLabelContainerViewHeightValue > 55 {
                
                if isShownThroughChat{
                    aboutMeLabelContainerViewHeightConstraint.constant = 0
                }
                else{
                aboutMeLabelContainerViewHeightConstraint.constant = aboutMeLabelContainerViewHeightValue
                aboutMeLabel.numberOfLines = 0
                self.perform(#selector(nowShowPersonalQoute), with: nil, afterDelay: 0.2)
                self.layoutIfNeeded()
                }
            }
            else{
                aboutMeLabel.numberOfLines = 2
                aboutMeLabelContainerViewHeightConstraint.constant = 55.0
                    aboutMeLabelTopConstraint.constant = SCREEN_HEIGHT - yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail - 85 - safeAreaBoth
                self.layoutIfNeeded()
                aboutmeLabelContainerView.alpha = 1

            }
        }
        
        if myProfileBottomViewHeightValue > 0 {
            myProfileBottomViewHeightConstraint.constant = myProfileBottomViewHeightValue

            myprofileBottomViewTopConstraint.constant = myProfileBottomViewTopValue - safeAreaBoth
        }
        
        if hadAlreadyBeenShownInDiscover == false {
        UIView.animate(withDuration: 0.2, animations: {
            
            self.layoutIfNeeded()

//            if self.animateViewComponent == true && self.isThisMyProfile == false {
//            }
            let gradientLayer:CAGradientLayer = CAGradientLayer()
            gradientLayer.frame = self.aboutmeLabelContainerView.bounds
            let gradientColors: [AnyObject] = [UIColor.white.cgColor, UIColor.clear.cgColor]
            gradientLayer.colors = gradientColors
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.2)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.2)
            self.aboutmeLabelContainerView.layer.mask = gradientLayer
            
            let myProfileGradientLayer:CAGradientLayer = CAGradientLayer()
            myProfileGradientLayer.frame = self.myProfileTextLabel.bounds
            let myProfileGradientColors: [AnyObject] = [UIColor.darkGray.cgColor, UIColor.clear.cgColor]
            myProfileGradientLayer.colors = myProfileGradientColors
            myProfileGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.2)
            myProfileGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.9)
            self.myProfileTextLabel.layer.mask = myProfileGradientLayer
        })
        }
        else{
            hadAlreadyBeenShownInDiscover = false
            UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
            })
        }
        
        //self.perform(#selector(nowAddGradientToView), with: nil, afterDelay: 2.0)
        nowAddGradientToView()
        gradiantAlreadyAdded = true
    }
    
    @objc func nowShowPersonalQoute(){
        if !isShownThroughChat{
        aboutmeLabelContainerView.alpha = 1
        }
    }
    
    func nowAddGradientToView(){
        
        if gradiantAlreadyAdded == true {
            return
        }
        
        if profileDetails?.wooAlbum?.count() > 0 && self.imageGalleryView != nil {
            gradientTop.colors = [kGradientColorBlackTop, kGradientColorClear]
            gradientBottom.colors = [kGradientColorClear, kGradientColorBlackBottomForDPV]
            gradientTop.frame = CGRect(x: 0, y: 0,
                                       width: UIScreen.main.bounds.width,
                                       height: self.imageGalleryContainerView.bounds.size.height/5);
            //self.imageGalleryView!.layer.addSublayer(gradientTop)
            
            gradientBottom.frame = CGRect(x: 0, y: self.imageGalleryContainerView.bounds.size.height*2/3 - 49,
                                          width: UIScreen.main.bounds.width,
                                          height: self.imageGalleryContainerView.bounds.size.height/3 + 60);
            self.imageGalleryView?.layer.insertSublayer(gradientBottom, below: self.imageGalleryView?.pageControlObj.layer)
            //self.imageGalleryView!.layer.addSublayer(gradientBottom)
            
        }
        else{
            gradientTop.colors = [kGradientColorBlackTop, kGradientColorClear]
            gradientBottom.colors = [kGradientColorClear, kGradientColorBlackBottom]
            gradientTop.frame = CGRect(x: 0, y: 0,
                                       width: UIScreen.main.bounds.width,
                                       height: self.profileImageView.bounds.size.height/5);
            //self.profileImageView.layer.addSublayer(gradientTop)
            
            gradientBottom.frame = CGRect(x: 0, y: self.profileImageView.bounds.size.height*1/2 - 60,
                                          width: UIScreen.main.bounds.width,
                                          height: self.profileImageView.bounds.size.height/2 + 60);
            self.profileImageView.layer.addSublayer(gradientBottom)
            
        }
    }
    
    func updateProfileDeckMainContainerViewHeightRelatedConstraints(){
        
        var heightToBeCalculated:CGFloat = 0
        
        var heightConstant:CGFloat? = 0
        
        var widthForFont:CGFloat = 0
        
        if SCREEN_WIDTH <= 320 {
            widthForFont = 260
        }
        else{
            widthForFont = 320
        }
        
        if isThisMyProfile == false {
            
            if profileDetails?.crushText.length>0 {
                let crushHeight:CGFloat = heightForView(crushMessageDescriptionLabel.text!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: widthForFont - 20) + 65
                heightToBeCalculated = crushHeight
                
                if heightToBeCalculated>85 {
                  //  heightConstant = UIScreen.main.bounds.size.height - heightToBeCalculated
                }
                else{
                 //   heightConstant = UIScreen.main.bounds.size.height - 85
                    heightToBeCalculated = 85
                }
 
                
                heightConstant = UIScreen.main.bounds.size.height - yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail
                
                crushMessageContainerViewYValue = heightConstant!
                crushMessageContainerViewHeightValue = heightToBeCalculated
                crushMessageContainerViewWidthValue = UIScreen.main.bounds.size.width + 40
            }
            else if aboutMeLabel.text != nil && aboutMeLabel.text!.count>0{
                let aboutMeHeight:CGFloat = heightForView(aboutMeLabel.text!, font: UIFont(name: "Lato-Regular", size: aboutMeLabel.font.pointSize)!, width: widthForFont - 20) + 32
                heightToBeCalculated = aboutMeHeight
                if heightToBeCalculated > 55 {
                    heightConstant = UIScreen.main.bounds.size.height - heightToBeCalculated
                    aboutMeLabelContainerViewHeightValue = heightToBeCalculated
                }
                else{
                    heightConstant = UIScreen.main.bounds.size.height - 56
                    aboutMeLabelContainerViewHeightValue = 56.0
                }
            }
            else{
                if self.frame.size.height == UIScreen.main.bounds.size.height - 85{
                    heightConstant = UIScreen.main.bounds.size.height - 85
                }
                else{
                    heightConstant = self.frame.size.height
                }
            }
            heightConstant = UIScreen.main.bounds.size.height - yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail
            aboutMeLabelContainerViewYValue = heightConstant!
            
            self.leftMarginContraintOfPersonalQuote.constant = 20
            self.rightMarginContraintOfPersonalQuote.constant = 20
        }
        else{
            
            let myprofileLabelHeight:CGFloat = heightForView(myProfileTextLabel.text!, font: UIFont(name: "Lato-Regular", size: myProfileTextLabel.font.pointSize)!, width: widthForFont - 20) + 52
            heightToBeCalculated = myprofileLabelHeight
            myProfileBottomViewHeightValue = heightToBeCalculated
            heightConstant = UIScreen.main.bounds.size.height - yPositionOfAboutMeLabelOrHeightThreshholdValueForProfileDetail
            aboutMeLabelContainerViewYValue = heightConstant!
            myProfileBottomViewTopValue = heightConstant! + safeAreaBoth
            
            self.leftMarginContraintOfPersonalQuote.constant = 20
            self.rightMarginContraintOfPersonalQuote.constant = 20

        }
        
        
        ProfileDeckMainContainerViewHeightConstraint.constant = heightConstant!
        overLayViewHeightConstraint.constant = heightConstant!
        overLayContainerViewHeightConstraint.constant = heightConstant!
        myProfileTextLabel.numberOfLines = 0
        if self.isLoadedNotFromDiscover == false {
            //self.performSelector(#selector(nowMoveBadgeViewDown), withObject: nil, afterDelay: 0.5)
        }
        self.perform(#selector(nowMoveBadgeViewDown), with: nil, afterDelay: 0.1)
    }
    
    @objc fileprivate func nowMoveBadgeViewDown(){
        if (popularBadgeAlreadyMoved){
            self.popularBadgeAlreadyMoved.toggle()
        UIView.animate(withDuration: 0.4, animations: {
            if self.isThisMyProfile == false{
                self.badgeView.transform =
                    CGAffineTransform(translationX: 0, y: (self.imageGalleryContainerView?.frame.height)! -
                        (self.badgeView.frame.size.height) - 40.0)
                //self.badgeView.alpha = 1
            }
            else{
                self.badgeView.transform =
                    CGAffineTransform(translationX: 0, y: (self.imageGalleryContainerView?.frame.height)! -
                        (self.badgeView.frame.size.height) - 60.0)
               // self.badgeView.alpha = 1
            }
        })
        }
    }
    
    
    @objc fileprivate func nowMoveBadgeViewBackToItsMainPosition(){
        UIView.animate(withDuration: 0.4, animations: {
            self.badgeView.transform =
                CGAffineTransform.identity
            self.badgeView.alpha = 1
        })
    }
    
    open func updateAlphaForOverlayView(_ viewIndex:UInt){
        
        var alphaProperty:CGFloat = 0.0
        
        let viewPercentIndex = viewIndex
        
        switch viewPercentIndex {
        case 0:
            alphaProperty = 0.0
        case 1:
            alphaProperty = 0.5
        case 2:
            alphaProperty = 0.8
        default:
            alphaProperty = 0.0
        }
       
        self.overLayView.alpha = alphaProperty
    }
    
    open func updateBackgroundColorAndLabelTextOfOverlayView(_ swipeDirection:SwipeResultDirection,isCrush:Bool, animationEnded:Bool){
                
        if isThisMyProfile == true {
            return
        }
        if animationEnded == true {
//            UIView.animate(withDuration: 0.1, animations: {
//            })
            self.overlayContainerView.alpha = 0.0
        }
        else{
            if swipeDirection == .Right {
                self.overlayBackgroundColorView.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
            else{
                self.overlayBackgroundColorView.backgroundColor = UIColor(red: 250.0/255.0, green: 72.0/255.0, blue: 73.0/255.0, alpha: 1.0)
            }
           // UIView.animate(withDuration: 0.1, animations: {
                if swipeDirection == .Right{
                    self.overlayContainerView.alpha = 1.0
                    if isCrush{
                        self.likeLabel.text = "CRUSH SENT"
                        if UIScreen.main.bounds.size.height <= 568{
                            self.likeLabel.font = UIFont(name: "Lato-Bold", size: 45.0)
                        }
                        else{
                            self.likeLabel.font = UIFont(name: "Lato-Bold", size: 50.0)
                        }
                    }
                    else{
                        self.likeLabel.text = "LIKE"
                    }
                    self.likeLabel.isHidden = false
                    self.passLabel.isHidden = true
                }
                else if swipeDirection == .Left{
                    self.overlayContainerView.alpha = 1.0
                    self.likeLabel.isHidden = true
                    self.passLabel.isHidden = false
                }
            //})
        }
    }
    
    func updateCommonalityTagsViewBasedOnThereAvailability(_ profileDetails:ProfileCardModel?) {
        var commonalityTagsViewHeight = 20
        var CommonalityTagsCount = 0
        
        
        NSLog("profileDetails?.ethnicity :%@", profileDetails?.ethnicity ?? "Null")
        
        
        if profileDetails?.ethnicity.count>0 {
            commonalityTagsViewHeight += 90
            CommonalityTagsCount += 1
            
            if ethnicityCommonalityViewHeightConstraint != nil {
            ethnicityCommonalityViewHeightConstraint.constant = 90
            }
            ethnicityCommonalityView.alpha = 1
        }
        else{
            if ethnicityCommonalityViewHeightConstraint != nil && ethnicityCommonalityViewHeightConstraint.constant > 0 {
            ethnicityCommonalityViewHeightConstraint.constant = 0.0
            }
            ethnicityCommonalityView.alpha = 0
        }
        NSLog("profileDetails?.religion :%@", profileDetails?.religion ?? "Null2")
        if profileDetails?.religion.count>0 {
            commonalityTagsViewHeight += 90
            CommonalityTagsCount += 1
            
            if religionCommonalityViewHeightConstraint != nil {
                religionCommonalityViewHeightConstraint.constant = 90
            }
            religionCommonalityView.alpha = 1
        }
        else{
            if religionCommonalityViewHeightConstraint != nil && religionCommonalityViewHeightConstraint.constant > 0 {
            religionCommonalityViewHeightConstraint.constant = 0
            }
            religionCommonalityView.alpha = 0
        }
        
        print("profileDetails?.isProfileLiked \(profileDetails?.isProfileLiked)")
        
        if ((profileDetails?.needToShowLikeBadge)! && !WooPlusModel.sharedInstance().isExpired) && CommonalityTagsCount < 3 {
            commonalityTagsViewHeight += 90
            CommonalityTagsCount += 1
            
            if likedMeViewHeightConstrain != nil{
            likedMeViewHeightConstrain.constant = 90.0
            }
            likedMeView.alpha = 1.0
        }
        else{
            if likedMeViewHeightConstrain != nil && likedMeViewHeightConstrain.constant > 0{
            likedMeViewHeightConstrain.constant = 0.0
            }
            likedMeView.alpha = 0.0
        }
        
        print("profileDetails?.commonTagCount() \(profileDetails?.commonTagCount())")
        if profileDetails?.commonTagCount() > 0 {
            commonalityTagsViewHeight += 90
            CommonalityTagsCount += 1
            
            if tagsInCommonViewHeightConstraint != nil{
            tagsInCommonViewHeightConstraint.constant = 90.0
            }
            tagInCommonView.alpha = 1.0
        }
        else{
            if tagsInCommonViewHeightConstraint != nil && tagsInCommonViewHeightConstraint.constant > 0{
            tagsInCommonViewHeightConstraint.constant = 0.0
            }
            tagInCommonView.alpha = 0.0
        }
       
        if profileDetails?.mutualFriendCount() > 0 && CommonalityTagsCount < 3 {
            commonalityTagsViewHeight += 90
            CommonalityTagsCount += 1
            
            if friendsInCommonViewHeightContraint != nil{
            friendsInCommonViewHeightContraint.constant = 90.0
            }
            friendInCommonView.alpha = 1.0
        }
        else{
            if friendsInCommonViewHeightContraint != nil && friendsInCommonViewHeightContraint.constant > 0{
            friendsInCommonViewHeightContraint.constant = 0.0
            }
            friendInCommonView.alpha = 0.0
        }
        
        if CommonalityTagsCount == 0{
            commonalityTagsView.alpha = 0
            commonalityTagsView.isHidden = true
        }
        else{
            self.perform(#selector(self.nowShowCommonalityTagsView), with: nil, afterDelay: 0.2)
        }
    }
    
    @objc fileprivate func nowShowCommonalityTagsView(){
        commonalityTagsView.alpha = 1
        if isLoadedNotFromDiscover == false{
            commonalityTagsView.isHidden = false
        }

    }
    
    @objc fileprivate func addImageGalleryView() {
        imageGalleryContainerView.isHidden = false
        if imageGalleryView == nil{
        imageGalleryView = StrechableScrollView.init(frame: CGRect(x: 0, y: 0, width: imageGalleryContainerView.frame.size.width, height: imageGalleryContainerView.frame.size.height))
            imageGalleryContainerView.addSubview(imageGalleryView!)
            
        }
        imageGalleryView?.isShownInProfile = true
        imageGalleryView?.isMyProfile = isThisMyProfile
        imageGalleryView?.getTappedImageIndex({ (currentIndex:Int) in
            self.getTappedIndexForGallery!(currentIndex)
        })
        imageGalleryView?.backgroundColor = UIColor.clear
        if imageGalleryView?.pageControlObj != nil {
            imageGalleryView?.pageControlObj.removeFromSuperview()
            imageGalleryView?.pageControlObj = nil
        }
        
        imageGalleryView?.firstImage = profileDetails?.profileImage
        imageGalleryView?.setWooAlbum(profileDetails?.wooAlbum, fromDiscover: !isLoadedNotFromDiscover)
        
        imageGalleryView?.createAddPageControlNow(withFrame: ((self.frame.size.height) -  (aboutmeLabelContainerView.frame.size.height)), with: 0)
//        UIView.animate(withDuration: 0.25, animations: {
            self.gradiantAlreadyAdded = false
            self.nowAddGradientToView()
//        })

    }
    
    func needToBeShownOrHiddenToBeCompatibleWithProfileDetailView()
    {
        //profileImageView.hidden = true
        var photoCount = 0
        aboutMeLabel.textAlignment = .left
        if isThisMyProfile{
            photoCount = (profileDetails?.wooAlbum?.countOfApprovedPhotos()) ?? 0
        }
        else{
            photoCount = (profileDetails?.wooAlbum?.count()) ?? 0
        }
        if profileDetails?.wooAlbum != nil && photoCount > 0 {
            if isThisMyProfile{
                if let localurl = profileDetails?.wooAlbum?.approvedProfilePicUrl() {
                    let urlStr : String = localurl as String
                    if urlStr.count > 0 {
                        self.setProfileImageForUser(URL(string: urlStr as String), userGender: profileDetails!.gender)
                        //Precache image
                        
                        // let imageCroppedStr = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\((Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: urlStr)!)"
                        Utilities().precacheDiscoverImages(withData: [localurl])
                    }
                }
            }
            else{
                if isThisMyProfile{
            if let localurl = profileDetails?.wooAlbum?.profilePicUrl() {
                let urlStr : String = localurl as String
                if urlStr.count > 0 {
                    self.setProfileImageForUser(URL(string: urlStr as String), userGender: profileDetails!.gender)
                    //Precache image
                    
                    // let imageCroppedStr = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\((Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: urlStr)!)"
                    Utilities().precacheDiscoverImages(withData: [localurl])
                }
                }
                }
                else{
                    if let localurl = profileDetails?.wooAlbum?.discoverProfilePicUrl() {
                        let urlStr : String = localurl as String
                        if urlStr.count > 0 {
                           let croppedUrl = DiscoverProfileCollection.sharedInstance.storeImagesToCroppedServer(imageString: urlStr)
                            self.setProfileImageForUser(URL(string: croppedUrl), userGender: profileDetails!.gender)
                            //Precache image
                            
                            // let imageCroppedStr = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\((Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: urlStr)!)"
                            Utilities().precacheDiscoverImages(withData: [croppedUrl])
                        }
                    }
                }
            }
        }
        else{
            self.progressBar.stopAnimating()
        }

        if isThisMyProfile{
            if profileDetails?.wooAlbum?.allApprovedImagesUrl().count > 0 {
                
                self.perform(#selector(addImageGalleryView), with: nil, afterDelay: 0.2)
                
            }
            else{
                imageGalleryContainerView.isHidden = true
            }
        }
        else{
            if profileDetails?.wooAlbum?.allImagesUrl().count > 0 {
                
                self.perform(#selector(addImageGalleryView), with: nil, afterDelay: 0.2)
                
            }
            else{
                imageGalleryContainerView.isHidden = true
            }
        }
        
        
        profileImageView.isUserInteractionEnabled = true
        
        if isThisMyProfile == false {
            topContainerView.alpha = 0
        }
        else{
            if profileDetails?.wooAlbum?.objectAtIndex(0)?.url != nil {
                topContainerView.alpha = 0
            }
            else{
                self.NameAgeLabel.alpha = 0
                self.heightLabel.alpha = 0
                self.locationLabel.alpha = 0
            }
        }
        self.leftMarginContraintOfPersonalQuote.constant = 20
        self.rightMarginContraintOfPersonalQuote.constant = 20
        commonalityTagsView.alpha = 0
        commonalityTagsView.isHidden = true
        self.perform(#selector(self.setBadgeViewWithData), with: nil, afterDelay: 0.2)
        myProfileBakcgroundView.backgroundColor = UIColor.white
        updateProfileDeckMainContainerViewHeightRelatedConstraints()
        //setupViewProperties()
//        gradientTop.removeFromSuperlayer()
//        gradientBottom.removeFromSuperlayer()
        //gradientTop.colors = [kGradientColorClear, kGradientColorClear]
        //gradientBottom.colors = [kGradientColorClear, kGradientColorClear]
        //self.perform(#selector(setupViewProperties), with: nil, afterDelay: 0.2)
        setupViewProperties()
        self.perform(#selector(nowRemoveGradiant), with: nil, afterDelay: 0.3)
        //nowRemoveGradiant()
        
    }
    
    @objc func nowRemoveGradiant(){
        self.aboutmeLabelContainerView.layer.mask = nil
        self.aboutMeLabel.textColor = UIColor.darkGray
        self.myProfileTextLabel.layer.mask = nil
    }
    
    func needTobeShownOrHiddenAsBeingShownInDeck()
    {
        if !isThisMyProfile{
            aboutMeLabel.textAlignment = .center
        }
        if profileImageHasBeenChanged{
            self.progressBar.stopAnimating()
        }
        else{
            var photoCount = 0
            if isThisMyProfile{
                photoCount = (profileDetails?.wooAlbum?.countOfApprovedPhotos())!
            }
            else{
                photoCount = (profileDetails?.wooAlbum?.count())!
            }
        if profileDetails?.wooAlbum != nil && photoCount > 0 {
            if isThisMyProfile{
                if let localurl = profileDetails?.wooAlbum?.approvedProfilePicUrl() {
                    let urlStr : String = localurl as String
                    if urlStr.count > 0 {
                        self.setProfileImageForUser(URL(string: urlStr as String), userGender: profileDetails!.gender)
                        Utilities().precacheDiscoverImages(withData: [localurl])
                    }
                }
            }
            else{
                if isThisMyProfile{
            if let localurl = profileDetails?.wooAlbum?.profilePicUrl() {
                let urlStr : String = localurl as String
                if urlStr.count > 0 {
                    self.setProfileImageForUser(URL(string: urlStr as String), userGender: profileDetails!.gender)
                    Utilities().precacheDiscoverImages(withData: [localurl])
                }
            }
                }
                else{
                    if let localurl = profileDetails?.wooAlbum?.discoverProfilePicUrl() {
                        let urlStr : String = localurl as String
                        if urlStr.count > 0 {
                            self.setProfileImageForUser(URL(string: urlStr as String), userGender: profileDetails!.gender)
                            Utilities().precacheDiscoverImages(withData: [localurl])
                        }
                    }
                }
            }
        }
        else{
            self.progressBar.stopAnimating()
        }
        }

        if isThisMyProfile == true {
            if (Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!) < 100){
                myProfileOnboardingBotView.isHidden = false
            }
            else{
                myProfileOnboardingBotView.isHidden = true
            }
            
            if profileDetails?.personalQuote != nil && profileDetails?.personalQuote?.count>0 {
                myProfileTextLabel.text = profileDetails?.personalQuote
            }
            
            if (DiscoverProfileCollection.sharedInstance.myProfileData != nil) {
                if DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore != nil {
                    if isThisMyProfile == true{
                        self.myProfileProgressView.progressValue = CGFloat(truncating: NumberFormatter().number(from: (DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)!)
                    self.myProfileProfileCompleteLabel.text = "\((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)%"
                    }
                }
            }
        }
        else if profileDetails?.about != nil && profileDetails?.about?.count > 0 {
            myProfileTextLabel.text = profileDetails?.about
        }
        
        
        self.perform(#selector(self.setDataForCommonalityTagsAndBadges), with: nil, afterDelay: 0.2)
        self.perform(#selector(self.setBadgeViewWithData), with: nil, afterDelay: 0.2)
        
        self.leftMarginContraintOfPersonalQuote.constant = 28//self.frame.size.width * 0.125
        self.rightMarginContraintOfPersonalQuote.constant = 28//self.frame.size.width * 0.125
        
        //updateCommonalityTagsViewBasedOnThereAvailability(self.profileDetails)
        
        imageGalleryContainerView.isHidden = true
        profileImageView.isUserInteractionEnabled = false
        self.NameAgeLabel.alpha = 1
        self.heightLabel.alpha = 1
        self.locationLabel.alpha = 1
        topContainerView.alpha = 1
        commonalityTagsView.alpha = 1
        myProfileTextLabel.numberOfLines = 3
        
        let safeArea = Utilities().getSafeArea(forTop: true, andBottom: true)
        let extraHeightConstant:CGFloat = (isIphoneX() || isIphoneXSMAX() || isIphoneXR()) ? 14 : 0
        ProfileDeckMainContainerViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 64 - safeArea + extraHeightConstant
        overLayViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 64 - safeArea + extraHeightConstant
        overLayContainerViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 64 - safeArea + extraHeightConstant
        myProfileBottomViewHeightValue = yPositionOfMyProfileViewOrHeightThreshholdValueForMyProfile
        myProfileBottomViewTopValue = SCREEN_HEIGHT - yPositionOfMyProfileViewOrHeightThreshholdValueForMyProfile
        myProfileBottomViewHeightConstraint.constant = myProfileBottomViewHeightValue
        myprofileBottomViewTopConstraint.constant = myProfileBottomViewTopValue - safeAreaBoth
        self.layoutIfNeeded()
//        gradientTop.removeFromSuperlayer()
//        gradientBottom.removeFromSuperlayer()
        //gradientTop.colors = [kGradientColorClear, kGradientColorClear]
        //gradientBottom.colors = [kGradientColorClear, kGradientColorClear]
        
            self.perform(#selector(setupViewProperties), with: nil, afterDelay: 0.2)
        //self.setupViewProperties()
        self.aboutMeLabel.textColor = UIColor.white
        myProfileBakcgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        self.perform(#selector(nowMoveBadgeViewBackToItsMainPosition), with: nil, afterDelay: 0.2)
    }
    
    @objc func updateHeightConstraintBasedOnPersonalQoute(){
        let height:CGFloat = heightForView(aboutMeLabel.text!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320) + 20
        aboutMeLabelContainerViewHeightConstraint.constant = height
    }
    //all IBactions
    
    @IBAction func tagsInCommonViewTapped(_ sender: AnyObject) {
        delegate?.getTheSelectedCommonality("TAGSINCOMMON")
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_CommonTapTags")
        
        
    }
    @IBAction func answerTagViewTapped(_ sender: AnyObject) {
        delegate?.getTheSelectedCommonality("ANSWERTAG")
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_CommonTap_QAnswered")
        
    }
    @IBAction func questionTagViewTapped(_ sender: AnyObject) {
        delegate?.getTheSelectedCommonality("QUESTIONTAG")
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_CommonTap_QAsked")
        
    }
    @IBAction func friendsInCommonViewTapped(_ sender: AnyObject) {
        delegate?.getTheSelectedCommonality("FRIENDSINCOMMON")
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_CommonTapFriends")
    }
    
    @IBAction func imageGalleryTapped(_ sender: AnyObject) {
        closeDetailViewControllerHandler!()
    }
    
    @IBAction func dismissTag(_ sender: Any) {
        if closeTagPopupHandler != nil{
            closeTagPopupHandler!()
        }
    }
    
}

