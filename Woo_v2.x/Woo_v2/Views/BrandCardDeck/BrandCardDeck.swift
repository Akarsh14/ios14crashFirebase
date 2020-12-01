//
//  ProfileDeckView.swift
//  Woo_v2
//
//  Created by Suparno Bose on 23/05/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import QuartzCore
import SnapKit
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



protocol BrandCardDeckDelegate: class {
    func getTheSelectedCommonalityForBrandCard(_ commonalitySelected:String)
}

@IBDesignable open class BrandCardDeck: UIView {

    
    @IBOutlet weak var brandTitleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandIconImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandTitleLabel: UILabel!
    @IBOutlet weak var brandTitleButton: UIButton!
    @IBOutlet weak var bottomLayerContainerHolderView: UIView!
    @IBOutlet weak var brandIconImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayerContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayerContainerView: UIView!
    @IBOutlet weak var bottomLayerContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var snapShotView: UIView!
    @IBOutlet weak var snapShotImageView: UIImageView!
    
    @IBOutlet weak var friendsGotThisCountLabel: UILabel!
    @IBOutlet weak var friendsGotThisImageView: UIImageView!
    @IBOutlet weak var friendsGotThisView: UIView!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var imageGalleryContainerView: UIView!
    
    @IBOutlet weak var profileDeckMainContainerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileDeckMainContainerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overLayContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var overLayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileDeckMainContainerView: UIView!
    @IBOutlet weak var ProfileDeckMainContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsInCommonCountWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commonalityTagsView: UIView!
    @IBOutlet weak var friendsInCommonViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var tagsContainerViewToBadgesViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayBackgroundColorView: UIView!
    @IBOutlet weak var overlayContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var overLayView: UIView!
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeIcon: UIImageView!
    @IBOutlet weak var badgeText: UILabel!
    
    @IBOutlet weak var brandDescriptionLabel: MDHTMLLabel!
    @IBOutlet weak var brandIconImageView: UIImageView!
    @IBOutlet weak var equalizer: InstaAnimationBars!
    @IBOutlet weak var equilizerBottomConstraint: NSLayoutConstraint!
    
    var isOpenedFromBrandDetail:Bool = false
    
    var imageGalleryView: StrechableScrollView?

    var brandDetails:BrandCardModel?
    
    weak var delegate:BrandCardDeckDelegate?

    var getTappedIndexForGallery:((Int)->Void)?
    
    var showPurchaseOptions:(()->Void)?

    let gradientTop:CAGradientLayer = CAGradientLayer()
    
    let gradientBottom:CAGradientLayer = CAGradientLayer()
    
    var yPositionOfBottomLayerContainerViewOrHeight:CGFloat = 188
    
    @IBOutlet var closeTapGesture: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
        let heightConstant:CGFloat = self.frame.size.height
        ProfileDeckMainContainerViewHeightConstraint.constant = heightConstant
        overLayViewHeightConstraint.constant = heightConstant
        overLayContainerViewHeightConstraint.constant = heightConstant
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
        loadViewFromNib()
        return self
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    /**
     This function loads the nib
     */
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BrandCardDeck", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
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
        snapShotView.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0.5, options: UIView.AnimationOptions(), animations: {
            self.snapShotView.alpha = 0
            }, completion: nil)
    }
    
    func setDataForProfileView() {
        
        if brandDetails == nil {
            return
        }
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        closeTapGesture.isEnabled = isOpenedFromBrandDetail
        
        if brandDetails?.subCardType == .WOOGLOBE {
            if SCREEN_WIDTH == 320 {
                profileImageView.contentMode = .scaleToFill
            }
            else{
                profileImageView.contentMode = .scaleAspectFill
            }
        }
        else{
            profileImageView.contentMode = .scaleAspectFill
        }
        
//Setting Profile Photo
        if brandDetails?.mediaUrls != nil && brandDetails?.mediaUrls?.count() > 0 {
            if let localurl = brandDetails?.mediaUrls?.objectAtIndex(0)?.url {
                let url : String = localurl as String
                profileImageView.sd_setImage(with: URL(string: url), placeholderImage: nil)
            }
        }
        
        if brandDetails?.mediaType == .GIF {
            
           // var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)
            
           // var path: String = documentsDirectory.stringByAppendingPathComponent("equalizer.gif")

            var paths:String = Bundle.main.resourcePath!
            paths.append("/equilizer.gif")
            _  = URL(fileURLWithPath: paths)
            
//            gifEqualizerImageView.sd_setImageWithURL(pathUrl)
            equalizer.isHidden = false
        }
        else{
//            gifEqualizerImageView.image = nil
            equalizer.isHidden = true
        }
        
        if brandDetails?.subCardType == SubCardType.EXTERNAL {
            badgeView.isHidden = false
        }
        else{
            badgeView.isHidden = true
        }
        
        if brandDetails?.mediaUrls!.count() > 1 {
            self.perform(#selector(addImageGalleryView), with: nil, afterDelay: 0.2)
        }
        else{
            imageGalleryContainerView.isHidden = true
        }
        
        brandTitleButton.setTitle("          " + (brandDetails?.buttonName)! + "          ", for: UIControl.State())
        brandTitleLabel.text = brandDetails?.title
        brandDescriptionLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: brandDescriptionLabel.font.pointSize), NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue]
        brandDescriptionLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: brandDescriptionLabel.font.pointSize), NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue]

        brandDescriptionLabel.htmlText = brandDetails?.cardDescription
        brandDescriptionLabel.getTheTappedUrl { (url) in
            if url != nil{
                UIApplication.shared.openURL(url!)
            }
        }
        //brandDescriptionLabel.delegate = self
        if  (brandTitleButton.titleLabel?.text != nil && brandTitleButton.titleLabel!.text?.count>0) && (brandDescriptionLabel.htmlText != nil && brandDescriptionLabel.htmlText.count>0) {
            brandTitleButton.isHidden = false
            brandDescriptionLabel.isHidden = false
            bottomLayerContainerView.isHidden = false
        }
        else if (brandTitleButton.titleLabel!.text == nil || brandTitleButton.titleLabel!.text?.count<=0) && (brandDescriptionLabel.htmlText != nil && brandDescriptionLabel.htmlText.count>0) {
            brandTitleButton.isHidden = true
            brandDescriptionLabel.isHidden = false
            bottomLayerContainerView.isHidden = false
            
        }
        else if (brandDescriptionLabel?.htmlText == nil || brandDescriptionLabel.htmlText?.count<=0) && (brandTitleButton.titleLabel!.text != nil && brandTitleButton.titleLabel!.text?.count>0) {
            brandTitleButton.isHidden = false
            brandDescriptionLabel.isHidden = true
            bottomLayerContainerView.isHidden = false
        }
        else{
            brandTitleButton.isHidden = true
            brandDescriptionLabel.isHidden = true
            bottomLayerContainerView.isHidden = true
        }

        if let brandLogoUrl = brandDetails?.logoUrl {
            brandIconImageView.sd_setImage(with: brandLogoUrl as URL)
        }
        else{
            brandIconImageViewHeightConstraint.constant = 0
        }
        
        self.perform(#selector(self.setDataForCommonalityTagsAndBadges), with: nil, afterDelay: 0.2)

        setupViewProperties()
    }
    
    @objc func setDataForCommonalityTagsAndBadges() {
        //Friends got this
        if brandDetails?.mutualFriendCount > 0 {
            self.friendsGotThisCountLabel.text = String(format: "%d", (brandDetails?.mutualFriendCount)!)
            let urlStr = brandDetails!.mutualFriendFirstImageUrl
            if urlStr != nil {
                self.friendsGotThisImageView.sd_setImage(with: urlStr as URL?)
            }
            
            let numberString:NSString = friendsGotThisCountLabel.text! as NSString
            
            let numberSize:CGSize = numberString.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
            
            if numberSize.width > 20 {
                friendsInCommonCountWidthConstraint.constant = numberSize.width + 10
            }
            self.friendsGotThisView.alpha = 1
            self.commonalityTagsView.alpha = 1
        }
        else{
            self.commonalityTagsView.isHidden = true
        }
    }
    
    /**
     Setting the profile image for user
     
     - parameter imageUrl:   url for image
     - parameter userGender: gender of user
     */
    func setBrandImageForUser(_ imageUrl:URL?){
        
        if let profilePicUrl = imageUrl {
            
            _ = "placeholder_male"
            
//            profileImageView.sd_setImageWithURL(profilePicUrl, placeholderImage: UIImage.init(named: placeHolderImageStr))

            profileImageView.sd_setImage(with: profilePicUrl, placeholderImage: nil)

        }
    }
    
    /**
     This method will setup properties of view
     */
    @objc func setupViewProperties(){
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        }) 
        //self.performSelector(#selector(addGradientToProfileImageView), withObject: nil, afterDelay: 0.2)
    }
    
    @objc func addGradientToBrandDescription(){
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.brandDescriptionLabel.bounds
        let grayColor:UIColor = UIColor(red: 114/255, green: 119/255, blue: 148/255, alpha: 1.0)
        let gradientColors: [AnyObject] = [grayColor.cgColor, UIColor.clear.cgColor]
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.brandDescriptionLabel.layer.mask = gradientLayer
    }
    
    func addGradientToProfileImageView(){
        gradientTop.removeFromSuperlayer()
        gradientTop.frame = CGRect(x: 0, y: 0,
                                       width: UIScreen.main.bounds.size.width,
                                       height: self.profileImageView.bounds.size.height/4);
        gradientTop.colors = [kGradientColorBlackTop, kGradientColorClear]
        self.profileImageView.layer.addSublayer(gradientTop)
        
        gradientBottom.removeFromSuperlayer()
        gradientBottom.frame = CGRect(x: 0, y: self.profileImageView.bounds.size.height*3/4,
                                          width: UIScreen.main.bounds.size.width,
                                          height: self.profileImageView.bounds.size.height/4);
        gradientBottom.colors = [kGradientColorBlackBottom, kGradientColorClear]
        self.profileImageView.layer.addSublayer(gradientBottom)
    }

    func updateBrandDeckMainContainerViewHeightRelatedConstraints(){
        
        var heightToBeCalculated:CGFloat = 0
        
        var heightConstant:CGFloat = 0
        
        if  (brandTitleButton.titleLabel!.text != nil && brandTitleButton.titleLabel!.text?.count>0) && (brandDescriptionLabel.htmlText != nil && brandDescriptionLabel.htmlText?.count>0) {
            let descriptionHeight:CGFloat = heightForView(brandDescriptionLabel.htmlText!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320 - 20) + 20 + 65
            heightToBeCalculated = descriptionHeight
        }
        else if (brandTitleButton.titleLabel!.text == nil || brandTitleButton.titleLabel!.text?.count<=0) && (brandDescriptionLabel.htmlText != nil && brandDescriptionLabel.htmlText?.count>0){
            let descriptionHeight:CGFloat = heightForView(brandDescriptionLabel.htmlText!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320 - 20) + 15
            heightToBeCalculated = descriptionHeight
        }
        else if (brandDescriptionLabel?.htmlText == nil || brandDescriptionLabel.htmlText?.count<=0) && (brandTitleButton.titleLabel!.text != nil && brandTitleButton.titleLabel!.text?.count>0) {
            yPositionOfBottomLayerContainerViewOrHeight = 80
            heightToBeCalculated = 60
        }
        else{
            yPositionOfBottomLayerContainerViewOrHeight = 80
            heightToBeCalculated = 0
        }
        
//        if self.frame.size.height == UIScreen.main.bounds.size.height - 85{
//            heightConstant = UIScreen.main.bounds.size.height - 85 + 20
//        }
//        else{
//            if heightToBeCalculated > 85 {
//                heightConstant = UIScreen.main.bounds.size.height - heightToBeCalculated + 20
//            }
//            else{
//                heightConstant = UIScreen.main.bounds.size.height - 85 + 20
//                heightToBeCalculated = 85
//            }
//        }
        heightConstant = SCREEN_HEIGHT - yPositionOfBottomLayerContainerViewOrHeight
        
        brandIconImageViewBottomConstraint.constant =  10
        equilizerBottomConstraint.constant = 10
        
        bottomLayerContainerViewHeightConstraint.constant = heightToBeCalculated
        bottomLayerContainerViewTopConstraint.constant = heightConstant
        ProfileDeckMainContainerViewHeightConstraint.constant = heightConstant
        overLayViewHeightConstraint.constant = heightConstant
        overLayContainerViewHeightConstraint.constant = heightConstant
    }
    
    @objc fileprivate func nowMoveBadgeViewDown(){
        UIView.animate(withDuration: 0.4, animations: {
            if self.badgeView != nil{
                self.badgeView.transform =
                    CGAffineTransform(translationX: 0, y: (self.imageGalleryContainerView?.frame.height)! -
                        (self.badgeView.frame.size.height) - 40.0)
            }
        }) 
    }
    
    @objc fileprivate func nowMoveBadgeViewBackToItsMainPosition(){
        UIView.animate(withDuration: 0.4, animations: {
            if self.badgeView != nil{
            self.badgeView.transform =
            CGAffineTransform.identity
            }
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
        UIView.animate(withDuration: 0.2, animations: { 
            self.overLayView.alpha = alphaProperty
        }) 
    }
    
    open func updateBackgroundColorAndLabelTextOfOverlayView(_ swipeDirection:SwipeResultDirection, animationEnded:Bool){
        if animationEnded == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.overlayContainerView.alpha = 0.0
            })
        }
        else{
            UIView.animate(withDuration: 0.5, animations: {
                if swipeDirection == .Right{
                    self.overlayContainerView.alpha = 1.0
                    self.overlayBackgroundColorView.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
                    self.likeLabel.isHidden = false
                    self.passLabel.isHidden = true
                }
                else if swipeDirection == .Left{
                    self.overlayContainerView.alpha = 1.0
                    self.overlayBackgroundColorView.backgroundColor = UIColor(red: 250.0/255.0, green: 72.0/255.0, blue: 73.0/255.0, alpha: 1.0)
                    self.likeLabel.isHidden = true
                    self.passLabel.isHidden = false
                }
            }) 
        }
    }
    
    @objc fileprivate func addImageGalleryView() {
        imageGalleryView = StrechableScrollView.init(frame: CGRect(x: 0, y: 0, width: imageGalleryContainerView.frame.size.width, height: imageGalleryContainerView.frame.size.height))
        imageGalleryView?.isShownInProfile = false
        if brandDetails?.subCardType == .WOOGLOBE {
            if SCREEN_WIDTH == 320 {
            imageGalleryView?.isUsedInBrandCard = true
            }
        }
        imageGalleryView?.getTappedImageIndex({ (currentIndex:Int) in
            self.getTappedIndexForGallery!(currentIndex)
        })
        imageGalleryView?.backgroundColor = UIColor.clear
        imageGalleryContainerView.addSubview(imageGalleryView!)
        if imageGalleryView?.pageControlObj != nil {
            imageGalleryView?.pageControlObj.removeFromSuperview()
            imageGalleryView?.pageControlObj = nil
        }
        
        imageGalleryView?.createAddPageControlNow(withFrame: ((self.frame.size.height) -  (bottomLayerContainerView.frame.size.height)), with: 0)
        UIView.animate(withDuration: 0.25, animations: {
            self.imageGalleryView?.pageControlObj.alpha = 1
        }) 

        imageGalleryView?.setWooAlbum(brandDetails?.mediaUrls, fromDiscover: true)

        //imageGalleryView?.setWooAlbum(brandDetails?.mediaUrls)
//        imageGalleryView?.snp.makeConstraints(closure: { (make) in
//            make.top.equalTo(self.snp.top)
//            make.bottom.equalTo(self.snp.bottom)
//            make.left.equalTo(self.snp.left)
//            make.right.equalTo(self.snp.right)
//        })
    }
    
    func needToBeShownOrHiddenToBeCompatibleWithProfileDetailView()
    {
        commonalityTagsView.isHidden = true
        brandDescriptionLabel.numberOfLines = 0
        overLayView.isHidden = true
        overlayContainerView.isHidden = true
        bottomLayerContainerView.backgroundColor = UIColor.white
        bottomLayerContainerHolderView.backgroundColor = UIColor.white
        brandTitleBottomConstraint.constant = 70
        updateBrandDeckMainContainerViewHeightRelatedConstraints()
        self.perform(#selector(nowMoveBadgeViewDown), with: nil, afterDelay: 0.2)
        self.perform(#selector(setupViewProperties), with: nil, afterDelay: 0.2)
        nowRemoveGradiant()

    }
    
    @objc func nowRemoveGradiant(){
        self.brandDescriptionLabel.layer.mask = nil
    }
    
    func needTobeShownOrHiddenAsBeingShownInDeck()
    {
        overLayView.isHidden = false
        overlayContainerView.isHidden = false
        imageGalleryContainerView.isHidden = true
        if brandDetails?.mutualFriendCount > 0 {
            commonalityTagsView.isHidden = false
        }
        else{
            commonalityTagsView.isHidden = true
        }
        brandDescriptionLabel.numberOfLines = 2
        let brandDescriptionBackGroundColor:UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        bottomLayerContainerView.backgroundColor = UIColor.clear
        bottomLayerContainerHolderView.backgroundColor = brandDescriptionBackGroundColor
//        if brandDetails?.subCardType == .WOOGLOBE {
//            yPositionOfBottomLayerContainerViewOrHeight = 150
//        }
//        else{
//            yPositionOfBottomLayerContainerViewOrHeight = 170
//        }
        var topConstant = 230
        if isIphoneX() || isIphoneXR(){
            topConstant = 300
        }
        bottomLayerContainerViewHeightConstraint.constant = 230
        bottomLayerContainerViewTopConstraint.constant = SCREEN_HEIGHT - CGFloat(topConstant)

        if bottomLayerContainerView.isHidden == true {
            brandIconImageViewBottomConstraint.constant = 60
            equilizerBottomConstraint.constant = 60
        }
        else{
            brandIconImageViewBottomConstraint.constant = 190
            equilizerBottomConstraint.constant = 190
        }
        
        brandTitleBottomConstraint.constant = 20
        ProfileDeckMainContainerViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 64
        overLayViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 64
        overLayContainerViewHeightConstraint.constant = UIScreen.main.bounds.size.height - 64
        self.perform(#selector(addGradientToBrandDescription), with: nil, afterDelay: 0.2)
        self.perform(#selector(setupViewProperties), with: nil, afterDelay: 0.2)
        self.perform(#selector(nowMoveBadgeViewBackToItsMainPosition), with: nil, afterDelay: 0.2)
    }

    //all IBactions
    @IBAction func friendsGotThisTapped(_ sender: AnyObject) {
        delegate?.getTheSelectedCommonalityForBrandCard("FRIENDSGOTTHIS")
    }
    @IBAction func closeBrandDetail(_ sender: Any) {
        if self.getTappedIndexForGallery != nil{
        self.getTappedIndexForGallery!(0)
        }
    }
    
    @IBAction func showPurchaseOptions(_ sender: AnyObject) {
        showPurchaseOptions!()
    }
}



