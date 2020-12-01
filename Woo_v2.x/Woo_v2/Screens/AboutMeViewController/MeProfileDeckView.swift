//
//  MeProfileDeckView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 05/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

enum PerformAction : String {
    case Pass              = "Pass"
    case Like              = "Like"
    case CrushSent         = "CrushSent"
    case None              = "None"
    case Answers           = "Answers"
    case AnswersDislike    = "AnswersDislike"
}

class MeProfileDeckView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeButtonOverlay: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var maleTimerImageView: UIImageView!
    @IBOutlet weak var lockedBlurrImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var overlayLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var maleExpiryView: UIView!
    
    @IBOutlet weak var nameAgeLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commonTagsNameLabel: UILabel!
    @IBOutlet weak var commonTagsImageView: UIImageView!
    @IBOutlet weak var expiryViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var maleTimeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var userDetails:AnyObject?
    @IBOutlet weak var likeButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameAgeLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButtonAllignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButtonHeightConstraint: NSLayoutConstraint!
    var dismissHandler:((PerformAction, AnyObject)->Void)!
    
    var purchaseHandler:(()->())!
    
    var currentAction:PerformAction = PerformAction.Pass
    
    let gradientBottom:CAGradientLayer = CAGradientLayer()

    var currentMeDataType:MeDataType = MeDataType.LikedMe
    
    var currentFrame:CGRect = CGRect()

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
    class func loadViewFromNib(frame:CGRect) -> MeProfileDeckView {
        let profileView: MeProfileDeckView =
            Bundle.main.loadNibNamed("MeProfileDeckView", owner: self, options: nil)!.first as! MeProfileDeckView
        profileView.frame = frame
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        profileView.likeButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit

        return profileView
    }
    
    func setDataForProfile(profileDetails:AnyObject, type:MeDataType, lockedState:Bool, showLock:Bool, noOfTotalProfiles:Int, isExpired:Bool, profileIndex:Int, usedInExpiryProfiles:Bool){
        
        userDetails = profileDetails
        var imageString = ""
        var firstName = ""
        var age = ""
        var timeStamp:Date = Date()
        var commonTagsDto:NSDictionary?
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        currentMeDataType = type
        if type == .LikedMe{
            imageString = (userDetails as! LikedByMe).userProfilePicURL  ?? ""
            firstName = (userDetails as! LikedByMe).userFirstName  ?? ""
            age = (userDetails as! LikedByMe).userAge  ?? ""
            timeStamp = (userDetails as! LikedByMe).userExpiryTime  ?? Date()
            if let common = (userDetails as! LikedByMe).commonTagDto{
                commonTagsDto = common as? NSDictionary
            }
        }
        else if type == .Visitors{
            imageString = (userDetails as! MeDashboard).visitorProfilePicURL  ?? ""
            firstName = (userDetails as! MeDashboard).visitorFirstName  ?? ""
            age = (userDetails as! MeDashboard).visitorAge  ?? ""
            timeStamp = (userDetails as! MeDashboard).visitorExpiryTime  ?? Date()
            if let common = (userDetails as! MeDashboard).commonTagDto{
                commonTagsDto = common as? NSDictionary
            }
        }
        else if type == .SkippedProfiles{
            imageString = (userDetails as! SkippedProfiles).userProfilePicURL ?? ""
            firstName = (userDetails as! SkippedProfiles).userFirstName  ?? ""
            age = (userDetails as! SkippedProfiles).userAge  ?? ""
            timeStamp = (userDetails as! SkippedProfiles).userExpiryTime  ?? Date()
            if let common = (userDetails as! SkippedProfiles).commonTagDto{
                commonTagsDto = common as? NSDictionary
            }
        }
        
        if lockedState {
            showExpiryLabel(timeStamp, imageUrl: imageString, locked: showLock, profileIndex: profileIndex, isPaid: !lockedState, isExpired: isExpired, usedInExpiryProfiles: usedInExpiryProfiles)
            dislikeButton.isHidden = true
            dislikeButtonOverlay.isHidden = true
            likeButton.isUserInteractionEnabled = false
            if showLock {
                bottomViewHeightConstraint.constant = 40
                containerViewHeightConstraint.constant = 24
                nameAgeLabelBottomConstraint.constant = 3.5
                nameAgeLabelHeightConstraint.constant = 0
                bottomView.isHidden = false
                dislikeButton.isHidden = true
                nameAgeLabel.isHidden = true
                lockedView.isHidden = false
                likeButton.isHidden = true
            }
            else{
                if isExpired{
                    bottomViewHeightConstraint.constant = 47
                    containerViewHeightConstraint.constant = 38
                    nameAgeLabelBottomConstraint.constant = 6
                    nameAgeLabelHeightConstraint.constant = 16
                }
                else{
                    bottomViewHeightConstraint.constant = 60
                    containerViewHeightConstraint.constant = 38
                    nameAgeLabelBottomConstraint.constant = 6
                    nameAgeLabelHeightConstraint.constant = 16
                }
                self.layoutIfNeeded()
                gradientBottom.removeFromSuperlayer()
                nowAddGradientToView()
                lockedView.isHidden = true
            }
        }
        else{
            if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
                showExpiryLabel(timeStamp, imageUrl: imageString, locked: showLock, profileIndex: profileIndex, isPaid: !lockedState, isExpired: isExpired, usedInExpiryProfiles: usedInExpiryProfiles)
                likeButton.isSelected = true
            }
            else{
                likeButton.isSelected = true
                maleExpiryView.isHidden = true
                expiryViewHeightConstraint.constant = 0
            }
            dislikeButton.isHidden = false
            dislikeButtonOverlay.isHidden = false
            likeButton.isUserInteractionEnabled = true
            nameAgeLabel.isHidden = false
            if isExpired{
                if usedInExpiryProfiles{
                    bottomViewHeightConstraint.constant = 60
                    containerViewHeightConstraint.constant = 38
                    nameAgeLabelBottomConstraint.constant = 6
                    nameAgeLabelHeightConstraint.constant = 16
                }
                else{
                bottomViewHeightConstraint.constant = 47
                    containerViewHeightConstraint.constant = 38
                    nameAgeLabelBottomConstraint.constant = 6
                    nameAgeLabelHeightConstraint.constant = 16
                }
            }
            else{
                bottomViewHeightConstraint.constant = 60
                containerViewHeightConstraint.constant = 38
                nameAgeLabelBottomConstraint.constant = 6
                nameAgeLabelHeightConstraint.constant = 16
            }
            bottomView.isHidden = false
            self.layoutIfNeeded()
            gradientBottom.removeFromSuperlayer()
            nowAddGradientToView()
            lockedView.isHidden = true
            
            var croppedPhoto = ""
        
            if imageString.hasPrefix(kImageCroppingServerURL) {
                //remove cropping url
                imageString = getOrignalUrlFromCropped(imageString)
            }
                let meWidth = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints: 150)
                let meHeight = meWidth * 3/2
                let aImageURL = "?url=" + imageString
                let aHeightOfURL = "&height=" + (NSString(format: "%d", meHeight) as String)
                let aWidthOfURL = "&width=" + (NSString(format: "%d", meWidth) as String)
                croppedPhoto = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
            profileImageView.sd_setImage(with: URL(string: croppedPhoto), placeholderImage: nil, options: SDWebImageOptions(), completed: nil)
        }
        
        if(currentMeDataType == .LikedMe){
            dislikeButtonOverlay.isHidden = true
            dislikeButton.isHidden = true
        }
        var nameAgeString = ""
        if firstName.count > 0{
            nameAgeString = firstName
            if age.count > 0{
                nameAgeString = nameAgeString + ", \(age)"
            }
        }
        nameAgeLabel.text = nameAgeString
        if commonTagsDto != nil{
            let commonsTagsIconImageUrlString = (AppLaunchModel.sharedInstance()?.tagsIconBaseURL ?? "") + imageIconFolderName + (commonTagsDto?.value(forKey: "url") as? String ?? "")
            commonTagsImageView.sd_setImage(with: URL(string: commonsTagsIconImageUrlString), completed: nil)
            commonTagsImageView.isHidden = false
            if commonTagsDto?.value(forKey: "tagsDtoType") as? String == "USER_QUESTIONS"{
                if let questionAskedString = commonTagsDto?.value(forKey: "questionAsked"){
                    commonTagsNameLabel.text = questionAskedString as? String
                }
                else{
                    commonTagsNameLabel.text = commonTagsDto?.value(forKey: "name") as? String
                }
            }
            else if commonTagsDto?.value(forKey: "tagsDtoType") as? String == "USER_DISTANCE"{
                if let locationString = commonTagsDto?.value(forKey: "commonLocation"){
                    commonTagsNameLabel.text = locationString as? String
                }
                else{
                    commonTagsNameLabel.text = commonTagsDto?.value(forKey: "name") as? String
                }
            }
            else{
                commonTagsNameLabel.text = commonTagsDto?.value(forKey: "name") as? String
            }
            
        }
        else{
            if lockedState{
                bottomView.isHidden = true
            }
            else{
                if nameAgeString.count > 0{
                    bottomViewHeightConstraint.constant = 40
                    containerViewHeightConstraint.constant = 15
                    nameAgeLabelBottomConstraint.constant = 6
                    nameAgeLabelHeightConstraint.constant = 16
                    self.layoutIfNeeded()
                    commonTagsImageView.isHidden = true
                    commonTagsNameLabel.text = ""
                    gradientBottom.removeFromSuperlayer()
                    nowAddGradientToView()
                }
            }
        }
    }
    
    func getOrignalUrlFromCropped(_ urlString:String) -> String
    {
        var imageUrlString = urlString.replacingOccurrences(of: kImageCroppingServerURL, with: "")
        imageUrlString = imageUrlString.components(separatedBy: "&").first!
        imageUrlString = imageUrlString.replacingOccurrences(of: "?url=", with: "")
        return imageUrlString
    }
    
    func showExpiryLabel(_ userTimeStamp:Date, imageUrl:String, locked:Bool, profileIndex:Int, isPaid:Bool, isExpired:Bool, usedInExpiryProfiles:Bool){
        var typeOfExpiry:ExpireType = .Expiry
        let expiryDays:Double = Double(AppLaunchModel.sharedInstance().meSectionProfileExpiryDays * 24 * 3600)
        DateFormatter().timeZone = TimeZone(secondsFromGMT: 0)
        let serverTime = userTimeStamp.timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        
        var daysOfExpiry:Double = 0
        if currentTime <= (serverTime + expiryDays){
        daysOfExpiry = (serverTime + expiryDays) - currentTime
        daysOfExpiry = Double(Int(daysOfExpiry/(24*3600))) + 1
        }
        
        /*
        likeButton.setImage(UIImage(named: "ic_me_like_visitors_normal_small"), for: UIControlState.normal)
        likeButton.setImage(UIImage(named: "ic_me_crush_visitors_small"), for: UIControlState.selected)
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
            likeButton.setImage(UIImage(named: "ic_me_like_visitors_normal_small_tapped"), for: UIControlState.highlighted)
        }
        else{
            likeButton.setImage(UIImage(named: "ic_me_crush_visitors_small_tapped"), for: UIControlState.highlighted)
        }
        */
        
        var showViewBasedOnSmallExpiry:Bool = false
        if locked || isExpired{
            if isPaid{
                if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
                    if isExpired{
                    maleExpiryView.isHidden = false
                    }
                    else{
                        maleExpiryView.isHidden = true
                        expiryViewHeightConstraint.constant = 0
                    }
                }
                else{
                    maleExpiryView.isHidden = true
                    expiryViewHeightConstraint.constant = 0
                }
            }
            else{
                maleExpiryView.isHidden = false
            }
            if usedInExpiryProfiles == false{
                if isExpired{
                    showViewBasedOnSmallExpiry = true
                }
            }
            
        }
        else{
            maleExpiryView.isHidden = true
            expiryViewHeightConstraint.constant = 0
        }
        
        if showViewBasedOnSmallExpiry{
            likeButtonWidthConstraint.constant = 45
            likeButtonHeightConstraint.constant = 45
            likeButtonTrailingConstraint.constant = 5
            dislikeButtonWidthConstraint.constant = 20
            dislikeButtonHeightConstraint.constant = 20
            dislikeButtonTrailingConstraint.constant = 10
            bottomViewHeightConstraint.constant = 47
            dislikeButtonTopConstraint.constant = 5
            likeButtonAllignmentConstraint.constant = -22
        }
        else{
            likeButtonWidthConstraint.constant = 60
            likeButtonHeightConstraint.constant = 60
            likeButtonTrailingConstraint.constant = 10
            dislikeButtonWidthConstraint.constant = 20
            dislikeButtonHeightConstraint.constant = 20
            dislikeButtonTrailingConstraint.constant = 10
            bottomViewHeightConstraint.constant = 60
            dislikeButtonTopConstraint.constant = 10
            likeButtonAllignmentConstraint.constant = -30
        }
        
        var daysText = ""
        if daysOfExpiry > 0 {
            if daysOfExpiry > 1{
                daysText = "days"
                if isExpired{
                maleExpiryView.backgroundColor = UIColorHelper.color(fromRGB: "#FF8A56", withAlpha: 1.0)
                }
                else{
                    maleExpiryView.backgroundColor = UIColorHelper.color(fromRGB: "#41B0D0", withAlpha: 1.0)
                }
            }
            else{
                if daysOfExpiry == 1 {
                    daysText = "hours"
                    var hoursOfExpiry:Double = Double(Int(((serverTime + expiryDays) - currentTime)/3600))
                    if hoursOfExpiry == 0{
                        hoursOfExpiry = 1
                    }
                    if hoursOfExpiry >= 24{
                        hoursOfExpiry = 23
                    }
                    else if hoursOfExpiry == 1{
                        daysText = "hour"
                    }
                    daysOfExpiry = hoursOfExpiry
                    if isExpired{
                    maleExpiryView.backgroundColor = UIColorHelper.color(fromRGB: "#FF8A56", withAlpha: 1.0)
                    }
                    else{
                        maleExpiryView.backgroundColor = UIColorHelper.color(fromRGB: "#41B0D0", withAlpha: 1.0)
                    }
                }
            }
            
            if daysText.count > 0 {
                maleTimeLabel.text = "\(Int(daysOfExpiry)) " + daysText + " left"
            }
            else{
                maleExpiryView.isHidden = true
                expiryViewHeightConstraint.constant = 0
            }
        }
        else{
            if daysOfExpiry == 0 {
                maleTimeLabel.text = "Expired"
                maleExpiryView.backgroundColor = UIColorHelper.color(fromRGB: "#FA4849", withAlpha: 1.0)
                maleTimerImageView.isHidden = true
                typeOfExpiry = .Expired
            }
        }
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE" && !isExpired{
            if daysText.count > 0 {
                maleTimeLabel.text = "Expiring in " + "\(Int(daysOfExpiry)) " + daysText
            }
        }
        var croppedPhoto = ""
        if imageUrl.hasPrefix(kImageCroppingServerURL) {
            croppedPhoto = imageUrl
        }
        else{
            let meWidth = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints: 150)
            let meHeight = meWidth * 3/2
            let aImageURL = "?url=" + imageUrl
            let aHeightOfURL = "&height=" + (NSString(format: "%d", meHeight) as String)
            let aWidthOfURL = "&width=" + (NSString(format: "%d", meWidth) as String)
            croppedPhoto = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
        }
        profileImageView.sd_setImage(with: URL(string: croppedPhoto), placeholderImage: nil, options: SDWebImageOptions(), completed: { (imageObj, error, cacheType, imageUrl) in
            if (imageObj != nil){
                if locked{
                    self.modifyExpiryView(imageObj!, type: typeOfExpiry)
                }
            }
        })
    }
    
    @IBAction func like(_ sender: Any) {
        
        if likeButton.isSelected == false{
        currentAction = PerformAction.Like
        overlayLabel.text = NSLocalizedString("LIKE", comment: "")
        overlayView.backgroundColor = UIColor(red: 117/255, green: 196/255, blue: 219/255, alpha: 0.6)
        
        if currentMeDataType == .LikedMe{
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MLM_Deck_LikedBack")
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView.alpha = 1.0
        }) { (true) in
            self.overlayView.alpha = 0.0
            self.performHandler()
        }
        }
        else{
            var sentCrushText = ""
            if currentMeDataType == .LikedMe{
                if (userDetails as! LikedByMe).crushMsgSendToUser != nil{
                    sentCrushText = (userDetails as! LikedByMe).crushMsgSendToUser!
                    (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MLM_Deck_CrushTap")
                }
            }
            else if currentMeDataType == .Visitors{
                if (userDetails as! MeDashboard).crushMsgSendToUser != nil {
                    sentCrushText = (userDetails as! MeDashboard).crushMsgSendToUser!
                }
            }
            else if currentMeDataType == .SkippedProfiles{
                if (userDetails as! SkippedProfiles).crushMsgSendToUser != nil{
                    sentCrushText = (userDetails as! SkippedProfiles).crushMsgSendToUser!
                }
            }
            if sentCrushText.count > 0 {
                self.like((Any).self)
                return
            }
            currentAction = PerformAction.CrushSent
            self.performHandler()
        }
    }
    
    @IBAction func sendCrush(_ sender: Any) {
        var sentCrushText = ""
        if currentMeDataType == .LikedMe{
            if (userDetails as! LikedByMe).crushMsgSendToUser != nil{
                sentCrushText = (userDetails as! LikedByMe).crushMsgSendToUser!
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MLM_Deck_CrushTap")
            }
        }
        else if currentMeDataType == .Visitors{
            if (userDetails as! MeDashboard).crushMsgSendToUser != nil {
                sentCrushText = (userDetails as! MeDashboard).crushMsgSendToUser!
            }
        }
        else if currentMeDataType == .SkippedProfiles{
            if (userDetails as! SkippedProfiles).crushMsgSendToUser != nil{
                sentCrushText = (userDetails as! SkippedProfiles).crushMsgSendToUser!
            }
        }
        if sentCrushText.count > 0 {
            self.like((Any).self)
            return
        }
        currentAction = PerformAction.CrushSent
        self.performHandler()
    }
    
    func showOverlayForCrushSent(){
        overlayLabel.text = NSLocalizedString("CRUSH SENT", comment: "")
        overlayView.backgroundColor = UIColor(red: 117/255, green: 196/255, blue: 219/255, alpha: 0.6)
        self.overlayView.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 1.0
        }) { (true) in
            self.overlayView.alpha = 0.0
        }
    }
    
    @IBAction func disLike(_ sender: Any) {
        currentAction = PerformAction.Pass
        overlayLabel.text = NSLocalizedString("SKIP", comment: "")
        overlayView.backgroundColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 0.6)
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView.alpha = 1.0
        }) { (true) in
            self.overlayView.alpha = 0.0
            self.performHandler()
        }
        
        if currentMeDataType == .LikedMe{
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MLM_Deck_Skip")
        }
    }
    
    func performHandler(){
        if dismissHandler != nil {
            dismissHandler(currentAction,userDetails!)
        }
    }
    
    func nowAddGradientToView(){
        if bottomView.isHidden == false{
        gradientBottom.colors = [kGradientColorClear, kGradientColorBlackTopForMeProfile]
        gradientBottom.frame = CGRect(x: 0, y: self.frame.size.height - bottomView.frame.size.height - 30,
                                   width: UIScreen.main.bounds.width,
                                   height: 30);
        self.profileImageView.layer.addSublayer(gradientBottom)
        }
    }
    
    func modifyExpiryView(_ imageForBlurr:UIImage, type:ExpireType){
        if type == .Expiry || type == .Expired{
        self.lockedBlurrImageView.image = UIImageEffects.imageByApplyingBlur(to: imageForBlurr, withRadius: CGFloat(AppLaunchModel.sharedInstance()?.opacityLevelLockedProfile ?? 16), tintColor: UIColor.clear, saturationDeltaFactor: 1.0, maskImage: nil)
        }
        
            /*
        else if type == .Expired{
            self.lockedBlurrImageView.image = UIImageEffects.imageByApplyingExtraLightEffect(to: imageForBlurr)
        }
        */
    }
    
    func modifyProfileDeckView(){
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 8.0
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.3
    }
}
