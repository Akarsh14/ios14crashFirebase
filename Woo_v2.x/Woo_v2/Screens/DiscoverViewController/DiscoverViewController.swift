//
//  DiscoverViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit
import SpriteKit
import IQKeyboardManager
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

@objc class DiscoverViewController: BaseClassViewController {
    
    @IBOutlet weak var actionButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var deckViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatBotImageView: UIImageView!
    @IBOutlet weak var deckView: KolodaView!
    @IBOutlet weak var likeButton: WooLikeMeterButton!
    @IBOutlet weak var crushButton: UIButton!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var actionButtonsContainerView: UIView!
    
    @IBOutlet weak var noInternetScreen: UIView!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var chatBotScreenForMyProfile: UIView!
    
    fileprivate var recommendationArray : DiscoverProfileCollection?
    
    fileprivate var isPaginated:Bool = false
    
    fileprivate var disableCardInteraction:Bool = false
    
    var currentUserData :AnyObject?
    
    var selectedCommonality:String?
    
    var crushToBeSent:NSString?
    
    var customLoader:WooLoader?
    
    @IBOutlet weak var tutorialNextButton: UIButton!
    
    @IBOutlet weak var tutorialPreviousButton: UIButton!
    
    var YConstraintForProfileDeck:CGFloat = 0
    
    var buttonActivity:PerformActionBasedOnActivity = PerformActionBasedOnActivity.DoNothing
    
    var swipeAllowedDirection:SwipeResultDirection?
    
    var sendCrushViewObject:SendCrushView?
    
    var callHasAlreadyMadeInDetail:Bool = false
    
    var snapShotImage:UIImage?
    
    var locationManager : LocationManager?
    
    var isLocationChangedAfterLaunch:Bool = false
    
    var areWeMovingUpOrLeftRight:String = ""
    
    fileprivate var matchData :NSDictionary?
    
    fileprivate var matchButtonType : OverlayButtonType?
    
    fileprivate var currentNewUserNoPicModel : NewUserNoPicCardModel?
    
    fileprivate var cardIsMovingUpwards:Bool = false
    
    fileprivate var needToOpenEditProfile = false
    
    fileprivate var discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = false
    
    var userHasChoosedToMoveMyProfileUp = false
    
    fileprivate var userHasChoosedToMoveBrandCardUp = false
    
    fileprivate var editProfileOpenedFromReviewPhotoCard = false
    
    fileprivate var shouldNotOpenProfileDetail = false
    
    var currentSelectedTab:Int = 1
    
    var currentShownTutorial:Int = 0
    
    var selectionCardSelectedValueArray : [ProfessionModel] = []
    
    let profileAction:ProfileActionManager = ProfileActionManager()
    
    var outOfLikePopup:OutOfLikeView?
    
    var showActionButton = false
    fileprivate var tokenGeneratorObj : TokenGenerator?
    
    var isDiscoverPreferencesPopupVisible = false
    
    var isNotAProfileCard = false
    
    var otherScreenIsPresentOnTop = false
    
    var remainingImagesForUploadingOnDiscover = [Data]()
    
    var photoForMatching : Int = 0
    
    
    var oneByoneAppendImageForUploadCheck = [Data]()
    
    let topMarginForDeckView:CGFloat = (isIphoneX() || isIphoneXSMAX() || isIphoneXR()) ? 70 : 84
    
    //MARK: ViewController lifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.discover, animated: false)
        self.view.sendSubviewToBack(self.navBar!)
        self.navBar?.setTitleText(NSLocalizedString("Discover", comment: "Discover") )
        //        self.navBar?.searchButton.isHidden = false
        
        
        
        self.navBar?.switchValueChanged = {(switchOn:Bool) in
            if WooGlobeModel.sharedInstance().isExpired == true {
                self.navBar?.customSwitch?.isOn = false
                self.showWooGlobePurchasePopUp()
            }
            else{
                self.navBar?.customSwitch?.isOn = switchOn
                WooGlobeModel.sharedInstance().wooGlobleOption = switchOn
                WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                if WooGlobeModel.sharedInstance().religionArray.count < 1 {
                    WooGlobeModel.sharedInstance().religionOption = false
                }
                if WooGlobeModel.sharedInstance().ethnicityArray.count < 1 {
                    WooGlobeModel.sharedInstance().ethnicityOption = false
                }
                self.showWooLoader(wooLoaderStyle: true)
                self.fetchDiscoverData(false)
                if WooGlobeModel.sharedInstance().wooGlobleOption {
                    self.showSnackBar(NSLocalizedString("Woo Globe enabled.", comment: "Woo Globe enabled."))
                }
                else{
                    self.showSnackBar(NSLocalizedString("Woo Globe disabled.", comment: "Woo Globe disabled."))
                }
            }
            
        }
        
        let defaults = UserDefaults.standard
        let gender = defaults.object(forKey: kWooUserGender) as! String?
        if (Utilities().isGenderMale(gender) == true ) {
            self.navBar?.searchButton.isHidden = false
            self.navBar?.addSearchButton()
        }
        else{
            self.navBar?.searchButton.isHidden = true
        }
        self.navBar?.settingsButtonHasBeenTapped = {
            
            self.openDiscoverSettingsScreen()
            
        }
        self.navBar?.searchButtonHasBeenTapped = {
            
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAP_DISCOVER_TAG_SEARCH_ICON")
            //open tag search screen
            let newTagSearchVc : NewTagSearchViewController = NewTagSearchViewController(nibName: "NewTagSearchViewController", bundle: Bundle.main)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
            self.navigationController?.pushViewController(newTagSearchVc, animated: true)
        }
        self.navBar?.customSwitch?.isOn = WooGlobeModel.sharedInstance().wooGlobleOption
        print("WooGlobeModel.sharedInstance().wooGlobleOption \(WooGlobeModel.sharedInstance().wooGlobleOption)")
        print("self.navBar?.customSwitch?.isOn \(self.navBar?.customSwitch?.isOn)")
        print("self.navBar?.customSwitch? \(self.navBar?.customSwitch)")
        likeButton.isExclusiveTouch = true
        passButton.isExclusiveTouch = true
        crushButton.isExclusiveTouch = true
        
        showOrHideActionButtonsContainerView(false)
        
        self.chatBotScreenForMyProfile.alpha = 0
        
        locationManager = LocationManager(parentViewController: self)
        print(UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown))
        if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown)
        {
            if !locationManager!.isLocationAvailable(){
                locationManager!.startGetLocationFlow()
            }
            else{
                locationManager?.moveToSearchLocationScreen()
            }
        }
        
        self.recommendationArray = DiscoverProfileCollection.sharedInstance
        
        if LoginModel.sharedInstance().showMyProfileScreen == false{
            UserDefaults.standard.set(true, forKey:kIsOnboardingMyProfileeShown)
            UserDefaults.standard.synchronize()
            self.recommendationArray?.cardCollection.didChange.removeAllHandlers()
        }
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            noInternetScreen.isHidden = false
            deckView.isHidden = true
        }
        else{
            
            if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown)
            {
                self.navBar?.switchHolderView.isHidden = true
                
                UserDefaults.standard.set(true, forKey:kLocationNeedsToBeUpdatedOnServer)
                
                chatBotScreenForMyProfile.alpha = 1
                self.navBar?.transform = CGAffineTransform(translationX: 0, y: -64.0)
                WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
                
                UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
                
                self.recommendationArray?.collectionMode = CollectionMode.my_PROFILE
                
                // Swrve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Onboard_MyProfile", withEventName: "3-Onboarding.Onboard_MyProfile.OMP_Landing")
                
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "OnBoarding_MyProfile_Landing")
                
                if self.recommendationArray?.count() > 0 {
                    self.perform(#selector(DiscoverViewController.reloadDeckView), with: nil, afterDelay: 0.2)
                }
                else{
                    self.showWooLoader(wooLoaderStyle: true)
                    self.recommendationArray?.cardCollection.didChange.addHandler(self, handler: DiscoverViewController.collectionDidChange)
                    
                    //                    let _ =  self.recommendationArray?.cardCollection.didChange.addHandler(self, handler: { (self) -> (values :(NSMutableArray,NSMutableArray)) -> () in
                    //
                    //                    })
                    //self.performSelector(#selector(DiscoverViewController.checkForInternet), withObject: nil, afterDelay: 5.0)
                }
            }
            else{
                self.navBar?.switchHolderView.isHidden = false
                // Swrve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_Landing")
                
                chatBotScreenForMyProfile.alpha = 0
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
                
                navBar?.setStyle(NavBarStyle.discover, animated: false)
                navBar!.backButton.isHidden = true
                navBar?.titleLabel.text = NSLocalizedString("Discover", comment: "Discover")
                navBar!.backButton.removeTarget(self,
                                                action: #selector(DiscoverViewController.myProfileBackButtonPressed(_:)),
                                                for: .touchUpInside)
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
                
                if locationManager!.isWooAllowedForLocation() && !LoginModel.sharedInstance().locationFound{
                    locationManager!.gettingUserCurrentLocationForDiscover()
                }
                if DiscoverProfileCollection.sharedInstance.intentModelObject?.interestedGender == "UNKNOWN"{
                    if let  id = UserDefaults.standard.object(forKey: "id") {
                        let wooid:NSString = id as! NSString
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue)) { (response, success, statusCode) in
                            self.fetchDiscoverData(false)
                        }
                    }
                }
                else{
                    self.fetchDiscoverData(false)
                }
                self.showWooLoader(wooLoaderStyle: true)
                
                
                /* Removed Tutorial
                 if !UserDefaults.standard.bool(forKey: kIsTutorialShown) {
                 currentShownTutorial = 1
                 setupTutorialScreen()
                 }
                 */
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnectionStatusChanged),
                                               name: NSNotification.Name(rawValue: kInternetConnectionStatusChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToUTMScreen),
                                               name: NSNotification.Name(rawValue:"redirectToUTMScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPopXOUserToDiscover),
                                               name: NSNotification.Name(rawValue:"addWooIdToDiscover"), object: nil)
        if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
            chatBotScreenForMyProfile.alpha = 0
        }
        else{
            self.navBar?.transform = CGAffineTransform(translationX: 0, y: -64.0)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        }
        Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(setWooGlobeNavValue), userInfo: nil, repeats: false)
//        Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(updateUserCurrentLocation), userInfo: nil, repeats: false)
        
    }
    
    
    
    func imageApiCall(){
        
        let image = UIImage(data: remainingImagesForUploadingOnDiscover[0])
        ImageAPIClass.uploadImage(toServer: image, andObjectId: "", withFakeCheck: true) { (response, success, stausCode) in
                    if(success){
                            
                        DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore = String((response as! NSDictionary).object(forKey: "profileCompletenessScore") as! Int)
                            let albumModel = WooAlbumModel()
                            albumModel.isMyprofile = true
                            albumModel.addObjectsFromArray((response as! NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
                            DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = albumModel
            
                            let lastElementArray : NSArray = (response as! NSDictionary).object(forKey: "wooAlbum") as! NSArray
            
                            let lastElementDetails :NSDictionary = lastElementArray[lastElementArray.count - 1] as! NSDictionary
            
                            var uploadImageSuccessfullDictionary = [[String:Any]]()
                            
                            uploadImageSuccessfullDictionary.append([
                                 "imageURL" : lastElementDetails["srcBig"]!,
                                 "status" : lastElementDetails["photoStatus"]!
                            ])
                            
                        print("remainingImagesForUploadingOnDiscover.count",self.remainingImagesForUploadingOnDiscover.count)
                            self.remainingImagesForUploadingOnDiscover.remove(at: 0)
            
                            UserDefaults.standard.set(self.remainingImagesForUploadingOnDiscover, forKey: "totalImagesForUploading")
                            UserDefaults.standard.synchronize()
            
                            self.photoForMatching += 1
                            UserDefaults.standard.set(uploadImageSuccessfullDictionary, forKey: "uploadedDictionary")
                            UserDefaults.standard.synchronize()
                            
                        print("remainingImagesForUploadingOnDiscover before ",self.remainingImagesForUploadingOnDiscover.count)
                        
                            if(self.remainingImagesForUploadingOnDiscover.count != 0){
                             print("remainingImagesForUploadingOnDiscover inner loop",self.remainingImagesForUploadingOnDiscover.count)
                                self.imageApiCall()
                            }else{
                                self.showLocalNotificationforSuccessfullImageUploading()
                            }
                    }
            }
    }
    
    
    func showActionTutorialForType(_ type:ActionTutorialType){
        
        var titleText = ""
        var messageText = ""
        var actionButtonTitle = ""
        var isMale = false
        
        let interestedGender:String = DiscoverProfileCollection.sharedInstance.intentModelObject!.interestedGender
        if interestedGender == "FEMALE" {
            isMale = false
        }
        else{
            isMale = true
        }
        
        switch type {
        case .Like:
            titleText = "Interested?"
            messageText = "Tapping on Tick or swipe right indicates you are interested."
            if isMale{
                actionButtonTitle = "Like Him"
            }
            else{
                actionButtonTitle = "Like Her"
            }
            break
        case .Dislike:
            titleText = "Not Interested?"
            messageText = "Tapping on X or swipe left indicates you are not interested."
            if isMale{
                actionButtonTitle = "Skip Him"
            }
            else{
                actionButtonTitle = "Skip Her"
            }
            break
        case .LikeDone:
            titleText = "Good Choice!"
            if isMale{
                messageText = "You can both chat when he also likes you back."
            }
            else{
                messageText = "You can both chat when she also likes you back."
            }
            actionButtonTitle = "Got It"
            break
        }
        
        let alertController = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: actionButtonTitle, style: .default, handler: {(alert: UIAlertAction!) in
            
            if type == .Like{
                if let userDetails =  self.recommendationArray?.objectAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileCardModel{
                    if userDetails.isProfileLiked == false{
                        if self.recommendationArray?.collectionMode == CollectionMode.discover{
                            
                            //TODO Bug
                            
                            
                            if self.checkIfUserWillSeeOutOfLikeAlert() {
                                self.showOutOfLikeAlert()
                                self.likeButton.isUserInteractionEnabled = true
                                return
                            }
                            
                            self.showActionTutorialForType(.LikeDone)
                        }
                    }
                }
                self.deckView.swipe(.Right)
                UserDefaults.standard.set(true, forKey: "firstTimeLiked")
            }
            else if type == .Dislike{
                self.deckView.swipe(.Left)
                UserDefaults.standard.set(true, forKey: "firstTimeDisliked")
            }
            UserDefaults.standard.synchronize()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(alert: UIAlertAction!) in
            
            if type == .Like{
                UserDefaults.standard.set(true, forKey: "firstTimeLiked")
            }
            else if type == .Dislike{
                UserDefaults.standard.set(true, forKey: "firstTimeDisliked")
            }
            UserDefaults.standard.synchronize()
        })
        
        if type != .LikeDone{
            alertController.addAction(cancelAction)
        }
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion:{})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("Discover didReceiveMemoryWarning")
        SDImageCache.shared().clearMemory()
    }
    
    
    func showDiscoverOverlayPopup(_ forTagSearch: Bool)
    {
        
        if(forTagSearch == false)
        {
            let window = UIApplication.shared.keyWindow
            let preferencesTutorialView = Bundle.main.loadNibNamed("DiscoverPreferencesOverlay", owner: window?.rootViewController, options: nil)?.first as! DiscoverPreferencesOverlay
            let safeAreaTop = (Utilities.sharedUtility() as! Utilities).getSafeArea(forTop: true, andBottom: false)
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11.0"))
            {
                preferencesTutorialView.frame = CGRect(x: 0, y: safeAreaTop, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            }
            else
            {
                preferencesTutorialView.frame = CGRect(x: 0, y: 20, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            }
            
            preferencesTutorialView.isTagSearchIntroOverlay = false
            preferencesTutorialView.setupUI(false)
            if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender ?? "" ==  "FEMALE" || LoginModel.sharedInstance().gender == "FEMALE")
            {
                preferencesTutorialView.tutorialSeenHandler = {
                    UserDefaults.standard.set(true, forKey: "hasSeenTutorialForPreferences")
                    UserDefaults.standard.synchronize()
                }
                preferencesTutorialView.settingsButtonTappedHandler = {
                    UserDefaults.standard.set(true, forKey: "hasSeenTutorialForPreferences")
                    UserDefaults.standard.synchronize()
                    //Push to My preferences
                    let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                    let myPreferencesVc:MyPreferencesViewController = (storyboard.instantiateViewController(withIdentifier: kMyPreferencesController) as? MyPreferencesViewController)!
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
                    self.navigationController?.pushViewController(myPreferencesVc, animated: true)
                }
                
                //                preferencesTutorialView.settingsButtonTappedHandler = {
                //                    //Push to
                //                    //open tag search screen
                //                    let newTagSearchVc : NewTagSearchViewController = NewTagSearchViewController(nibName: "NewTagSearchViewController", bundle: Bundle.main)
                //                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
                //                    self.navigationController?.pushViewController(newTagSearchVc, animated: true)
                //                }
                isDiscoverPreferencesPopupVisible = true
                self.view.addSubview(preferencesTutorialView)
            }
        }
        else
        {
            //preferencesTutorialView.isTagSearchIntroOverlay = true
            //preferencesTutorialView.setupUI(true)
            //            preferencesTutorialView.tutorialSeenHandler = {
            //                UserDefaults.standard.set(true, forKey: "hasSeenIntroductionForSearchTags")
            //                UserDefaults.standard.synchronize()
            //            }
            if !otherScreenIsPresentOnTop{
                showTagSearchPopup()
                isDiscoverPreferencesPopupVisible = true
            }
            //self.view.addSubview(preferencesTutorialView)
        }
    }
    
    @objc func updateUserCurrentLocation() -> Bool{
        var savedDate:Date
        
        if((UserDefaults.standard.value(forKey: kLastLocationUpdatedTime)) != nil){
            savedDate = UserDefaults.standard.value(forKey: kLastLocationUpdatedTime) as! Date
        }
        else{
            savedDate = Date()
        }
        
        let currentDate = Date()
        
        let interval:Int = Int(currentDate.timeIntervalSince(savedDate))
        var locationUpdated = false
        if interval >= kLocationThreshold{
            if ((UserDefaults.standard.object(forKey: kUserLastLocationKey) != nil || UserDefaults.standard.object(forKey: kLastLocationUpdatedTime) != nil) && (locationManager?.isWooAllowedForLocation())!) {
                locationUpdated = true
                locationManager?.getUserCurrentLocation({ (succes, locationObj) in
                    if succes == true{
                        UserDefaults.standard.set("GPS", forKey: "sourceOfLocation")
                        self.isLocationChangedAfterLaunch = true
                        UserDefaults.standard.set(true, forKey:kLocationNeedsToBeUpdatedOnServer)
                        UserDefaults.standard.synchronize()
                        
                        self.showWooLoader(wooLoaderStyle: true)
                        self.fetchDiscoverData(false)
                        self.locationManager?.makeLocationStringFromLatLongAndStartTheFlow(for: locationObj, withCompletion: { (success, cityString) in
                            if success == true{
                                DiscoverProfileCollection.sharedInstance.myProfileData?.location = cityString as NSString?
                            }
                        })
                    }
                }, withoutChangingBlock: true)
            }
        }
        
        return locationUpdated
    }
    
    
    func showWooGlobePurchasePopUp() {
        DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
        let window:UIWindow = UIApplication.shared.keyWindow!
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
        purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
            if wooGlobePurchased == true {
                UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                UserDefaults.standard.synchronize()
                WooGlobeModel.sharedInstance().wooGlobleOption = wooGlobePurchased
                WooGlobeModel.sharedInstance().isExpired = false
                WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                if WooGlobeModel.sharedInstance().religionArray.count < 1 {
                    WooGlobeModel.sharedInstance().religionOption = false
                }
                
                if WooGlobeModel.sharedInstance().ethnicityArray.count < 1 {
                    WooGlobeModel.sharedInstance().ethnicityOption = false
                }
                
            }
            self.navBar?.customSwitch?.isOn = WooGlobeModel.sharedInstance().wooGlobleOption
            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
            self.openDiscoverSettingsScreenPostWooGlobePurchase()
            //                    self.showWooLoader()
            //                    self.fetchDiscoverData(false)
            
        }
    }
    
    func showRatingPopup(){
        
        if Utilities().shouldWeShowRatingPopup() {
            
            UserDefaults.standard.set(Date(timeIntervalSinceReferenceDate: kCFAbsoluteTimeIntervalSince1970), forKey: "remindMePopupTimestampV3")
            UserDefaults.standard.synchronize()
            
            let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
            let ratingPopup:RatingLoader = Bundle.main.loadNibNamed("RatingLoader", owner: window.rootViewController, options: nil)!.first as! RatingLoader
            ratingPopup.frame = window.frame
            
            if window.subviews.count > 1 {// If Any view is presented
                let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.first! as UIView).addSubview(ratingPopup)
            }
            else{
                if NSStringFromClass((type(of: window.subviews.last) as! AnyClass)) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                    let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                    (window2.subviews.first! as UIView).addSubview(ratingPopup)
                }
                else{
                    (window.subviews.first! as UIView).addSubview(ratingPopup)
                }
            }
            
            ratingPopup.sendFeedbackHandler = {(selectedStars:Int) in
                self.performSegue(withIdentifier: "DiscoverToFeedbackSegue", sender: nil)
            }
        }
    }
    
    
    func addNotificationObserver(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kQuestionsLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openQuestionScreen), name: NSNotification.Name(rawValue: kQuestionsLandingNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kBoostPurchaseLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openBoostPurchaseScreen), name: NSNotification.Name(rawValue: kBoostPurchaseLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCrushPurchaseLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openCrushPurchaseSCreen), name: NSNotification.Name(rawValue: kCrushPurchaseLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kWooPlusPurchaseLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openWooPlusPurchaseScreen), name: NSNotification.Name(rawValue: kWooPlusPurchaseLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAppStoreLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openAppStore), name:NSNotification.Name(rawValue: kAppStoreLandingNotification) , object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kTagBubbleScreenLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openTagsScreen), name:NSNotification.Name(rawValue: kTagBubbleScreenLandingNotification) , object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kMeLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openMeSection), name: NSNotification.Name(rawValue: kMeLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kMatchboxLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openMatchbox), name: NSNotification.Name(rawValue: kMatchboxLandingNotification), object: nil)
        
        
        // Lokesh - Globe landing observer removed and notification added
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kWooGlobePurchaseLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openWooGlobePurchaseScreen), name: NSNotification.Name(rawValue: kWooGlobePurchaseLandingNotification), object: nil)
        
        // Lokesh - Invite landing observer removed and notification added
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kInviteScreenLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openInviteScreen), name: NSNotification.Name(rawValue: kInviteScreenLandingNotification), object: nil)
        
        print("observer Add karne gaya hai")
        NSLog("addNotificationObserver===== ", "")
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "openChatRooom"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openChatRoom(_:)), name:NSNotification.Name(rawValue: "openChatRooom"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkForLikeLimit), name:NSNotification.Name(rawValue: "AppLaunchReceived"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAppSettingsHasBeenFetchedFromServer), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(fetchDiscoverData(_:)), name: NSNotification.Name(rawValue: kAppSettingsHasBeenFetchedFromServer), object: nil)
        
        // Added New Notification
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kVisitorLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openVisitorSection), name: NSNotification.Name(rawValue: kVisitorLandingNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kVisitorContentGuidelinesLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openContentGuidelines), name: NSNotification.Name(rawValue: kVisitorContentGuidelinesLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kLikedMeLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openLikedMeSection), name: NSNotification.Name(rawValue: kLikedMeLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCrushLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openCrushDashboard), name: NSNotification.Name(rawValue: kCrushLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kSkippedProfileLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openSkippedProfile), name: NSNotification.Name(rawValue: kSkippedProfileLandingNotification), object: nil)
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPurchaseLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openMyPurchaseScreen), name: NSNotification.Name(rawValue: kPurchaseLandingNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kEditProfileLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openEditProfileScreen), name: NSNotification.Name(rawValue: kEditProfileLandingNotification), object: nil)
        
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDiscoverSettingsLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openDiscoverSettingsScreenFromNotification), name: NSNotification.Name(rawValue: kDiscoverSettingsLandingNotification), object: nil)
        
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAppSettingsLandingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openAppSettingsScreen), name: NSNotification.Name(rawValue: kAppSettingsLandingNotification), object: nil)
        
        
        
        // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kInAppBrowserNotification), object: nil)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(openInAppBrowserScreen), name: NSNotification.Name(rawValue: kInAppBrowserNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDiscoverLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openDiscoverScreen), name: NSNotification.Name(rawValue: kDiscoverLandingNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateWooGlobeExpiredValue"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setWooGlobeNavValue), name: NSNotification.Name(rawValue: "updateWooGlobeExpiredValue"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kFeedBackScreenLandingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openFeedBackScreen), name: NSNotification.Name(rawValue: kFeedBackScreenLandingNotification), object: nil)
        
    }
    
    @objc func openFeedBackScreen(){
        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.Feedback)
    }
    
    
    @objc func openDiscoverScreen()
    {
        if(WooScreenManager.sharedInstance.isDrawerOpen)
        {
            WooScreenManager.sharedInstance.isDrawerOpen = false
            WooScreenManager.sharedInstance.drawerController?.closeDrawer(animated: true, completion: { (isAnimated) in
                WooScreenManager.sharedInstance.drawerController!.rightDrawerViewController = nil
            })
        }
        //if alertcontrollers are open
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        if(currentNavigation.viewControllers.last?.presentedViewController is UIAlertController)
        {
            currentNavigation.viewControllers.last?.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        
        let window:UIWindow = UIApplication.shared.keyWindow!
        if (window.subviews.first!.subviews.first! as UIView) is PurchasePopup ||  (window.subviews.first!.subviews.first! as UIView) is DropOffPurchasePopup
            || (window.subviews.first!.subviews.first! as UIView) is VoiceCallIntroductionPopup || (window.subviews.first!.subviews.first! as UIView) is OutOfLikeView || (window.subviews.first!.subviews.first! as UIView) is PostMatchTipsView || (window.subviews.first!.subviews.first! as UIView) is NewMatchOverlayView || (window.subviews.first!.subviews.first! as UIView) is PostFeedbackContactView
        {
            (window.subviews.first!.subviews.first! as UIView).removeFromSuperview()
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhoneVerify"), object: nil))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhotoSelection"), object: nil))
        
        currentNavigation.popToRootViewController(animated: false)
        
        if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 1)
        {
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        else
        {
            navBar?.setStyle(NavBarStyle.discover, animated: false)
            navBar!.backButton.isHidden = true
            navBar?.titleLabel.text = NSLocalizedString("Discover", comment: "Discover")
            navBar!.backButton.removeTarget(self,
                                            action: #selector(DiscoverViewController.myProfileBackButtonPressed(_:)),
                                            for: UIControl.Event.touchUpInside)
            DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
            self.makeProfileDeckSmall()
            didTabViewChanged((0, newValue: 1))
        }
        
    }
    
    @objc func openTagsScreen(){
        /*
         let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
         let oTagScreenViewController =
         storyboard.instantiateViewController(withIdentifier: "TagScreenViewControllerID")
         as? TagScreenViewController
         if((DiscoverProfileCollection.sharedInstance.myProfileData?.tags) != nil)
         {
         oTagScreenViewController?.editProfileTagArray = NSMutableArray.init(array: (DiscoverProfileCollection.sharedInstance.myProfileData?.tags)!)
         }
         else
         {
         oTagScreenViewController?.editProfileTagArray = NSMutableArray()
         }
         
         oTagScreenViewController?.isPushedFromDiscover = true
         //                    oTagScreenViewController?.isPresentedForTagSelectionCard = true
         oTagScreenViewController?.removeBubbleViewsWhenViewDisappears = true
         oTagScreenViewController?.blockHandler = { (tagsArray) in
         
         
         }
         */
        
        self.otherScreenIsPresentOnTop = true
        let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
        wizardTagsVC.isUsedOutOfWizard = true
        wizardTagsVC.selectedTagsHandler = {(selectedTagsarray) in
            DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
            DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
            
            self.selectionCardSelectedValueArray = []
            NSLog("Discover tagsArray : \(selectedTagsarray)")
            
            for item in selectedTagsarray {
                let model : ProfessionModel = ProfessionModel()
                model.name = "\((item as! NSDictionary)["name"]!)"
                model.tagId = "\((item as! NSDictionary)["tagId"]!)"
                self.selectionCardSelectedValueArray.append(model)
            }
            NSLog("Discover selectionCardSelectedValueArray : \(self.selectionCardSelectedValueArray)")
            
            self.makeLikeSwipeNow()
        }
        
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        currentNavigation.pushViewController(wizardTagsVC, animated: true)
    }
    
    @objc func openAppStore(){
        (Utilities.sharedUtility() as AnyObject).openURL(forURLString: String(format: "itms-apps://itunes.apple.com/app/id885397079"))
    }
    
    @objc func openChatRoom(_ chatRoomId: NSString) -> Void {
        //        print("chatRoomId===== \(chatRoomId)")
        //        NSLog("chatRoomId===== ", "")
        //        WooScreenManager.sharedInstance().oHomeViewController
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        print("viewWillAppear")
        
        if WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 1{
            colorTheStatusBar(withColor: NavBarStyle.discover.color())
        }
        
        self.setWooGlobeNavValue()
        //SwipeBack
        
        if let nav = self.navigationController{
            nav.swipeBackEnabled = true
        }
        
        if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        }
        else
        {
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
        }
    }
    
    @objc func setWooGlobeNavValue() {
        self.navBar?.customSwitch?.isOn = (WooGlobeModel.sharedInstance().wooGlobleOption && !WooGlobeModel.sharedInstance().isExpired)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        self.navigationController?.delegate = self
        print("1view did load observer Add karne gaya hai \(self.navigationController)")
        NSLog("view did load >>>>>>", "")
        setupDeckView()
        self.addNotificationObserver()
        self.buttonActivity = .Like
        navigationController?.navigationBar.barStyle = .black
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        //        self.perform(#selector(self.showPurchaseScreen), with: nil, afterDelay: 2.0)
        
        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
        
        WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.didChange.addHandler(self, handler: DiscoverViewController.didTabViewChanged)
        
        areWeMovingUpOrLeftRight = ""
        
        let height = UIScreen.main.bounds.height
        deckViewHeightConstraint.constant = height - safeAreaBoth - topMarginForDeckView
        
        self.checkForLikeLimit()
        
        (Utilities.sharedUtility() as! Utilities).sendFCMPushTokenToServer()
        
        //        if !NSUserDefaults.standardUserDefaults().boolForKey(kIsOnboardingMyProfileeShown) {
        //            self.navBar?.transform = CGAffineTransformMakeTranslation(0, -64.0)
        //            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        //        }
        //        else{
        //            chatBotScreenForMyProfile.alpha = 0
        //            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
        //        }
        
        //        if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.MY_PROFILE {
        //            chatBotScreenForMyProfile.alpha = 0
        //            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
        //        }
        //        else{
        //            if !NSUserDefaults.standardUserDefaults().boolForKey(kIsOnboardingMyProfileeShown) {
        //                self.navBar?.transform = CGAffineTransformMakeTranslation(0, -64.0)
        //            }
        //            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        //        }
        
        
        
        //        let webViewObj : WebViewController = self.storyboard?.instantiateViewController(withIdentifier: kMyWebViewController) as! WebViewController
        //
        //        let urlString = "http://172.30.33.105:8080/nvite/fgrprnt.jsp"
        //        let url = NSURL(string: urlString)
        //
        //        webViewObj.webViewUrl = url as URL!
        //
        //        self.present(webViewObj, animated: true, completion: nil)
        
        
        //        let storyboard:UIStoryboard = UIStoryboard(name: "Woo_3", bundle: nil)
        //
        //        let myWebViewViewController:WebViewController = (storyboard.instantiateViewController(withIdentifier: kMyWebViewController) as? WebViewController)!
        //
        //        let urlString = "http://172.30.33.105:8080/nvite/svdbx"
        //        let url = NSURL(string: urlString)
        //
        //        myWebViewViewController.navTitle = "Test header"
        //        myWebViewViewController.webViewUrl = url as URL!
        //        WooScreenManager.sharedInstance.oHomeViewController!.present(myWebViewViewController, animated: true, completion: nil)
        
//        let chatView = TopChatView.sharedInstance()
//        chatView?.setNotificationTypeFor(NotificationType.chatBoxLanding)
//        chatView?.showNewChatMessage(fromTop: "aaya yha pe")
//
//        var appDelegate : UIApplicationDelegate?
//        if let localAppDelegate = UIApplication.shared.delegate {
//             appDelegate = localAppDelegate
//        }
        
        checkIfImagesAreRemainingForUploadation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        if((Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == -1)
        //        {
        //            (Utilities.sharedUtility() as! Utilities).showVoiceCallIntroductionPopup()
        //        }
        print("viewwillappear")
        
    }
    
    
    func checkIfImagesAreRemainingForUploadation(){
        
        let pendingImages = UserDefaults.standard.object(forKey: "totalImagesForUploading") as? NSArray
        
        if pendingImages?.count != 0 && pendingImages != nil {
            print("pendingImages", pendingImages!)
            remainingImagesForUploadingOnDiscover = pendingImages as! [Data]
            print(remainingImagesForUploadingOnDiscover.count)
            
//            self.imageApiCall()
        }
        
    }

    func showLocalNotificationforSuccessfullImageUploading(){
        
        print(UserDefaults.standard.object(forKey: "uploadedDictionary") ?? 0)
        
        let localNotificationForUploadedImages = UserDefaults.standard.object(forKey: "uploadedDictionary") as? NSArray
        
        var remainigLocalPushNotificationTodisplay = [[String:Any]]()
        
        if localNotificationForUploadedImages != nil && localNotificationForUploadedImages?.count != 0 {
            
            //This dictionary is for delete already displayed notification from main userdefaults
            remainigLocalPushNotificationTodisplay = localNotificationForUploadedImages as! [[String : Any]]
            print("localNotificationForUploadedImages",localNotificationForUploadedImages!.count)
            
            DispatchQueue.global(qos: .default).async {
                
                 for item in localNotificationForUploadedImages!{

                     DispatchQueue.main.async {
                         NotificationCenter.default.post(
                             name: NSNotification.Name(rawValue: "showAlertOnDiscover"),
                             object: self,
                             userInfo: item as? [String : Any]
                         )
                     }
                    
                    print("remainigLocalPushNotificationTodisplay",remainigLocalPushNotificationTodisplay.count)
                    
                    if(remainigLocalPushNotificationTodisplay.count != 0){
                      remainigLocalPushNotificationTodisplay.remove(at: 0)
                    }
                    
                    UserDefaults.standard.set(remainigLocalPushNotificationTodisplay, forKey: "uploadedDictionary")
                    UserDefaults.standard.synchronize()

                     sleep(7)
                 }
             }
         }
    }
    
    
    private func showTagSearchPopup(){
        let defaults = UserDefaults.standard
        let gender = defaults.object(forKey: kWooUserGender) as! String?
        if (Utilities().isGenderMale(gender) == true ) {
            _ = IntroducingTagSearchView.showView()
        }
    }
    
    @objc func redirectToUTMScreen()
    {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown)
            {
                if ((Utilities.sharedUtility() as! Utilities).validString(UserDefaults.standard.object(forKey: kWooUserId) as? String)).count > 0 && UserDefaults.standard.object(forKey: "redirectFromUTMParams") != nil
                {
                    let deepLink = UserDefaults.standard.object(forKey: "redirectFromUTMParams") as? String ?? ""
                    UserDefaults.standard.removeObject(forKey: "redirectFromUTMParams")
                    UserDefaults.standard.synchronize()
                    
                    self.otherScreenIsPresentOnTop = true
                    
                    WooScreenManager.sharedInstance.openDeepLinkedScreen(deepLink)
                }
            }
        }
    }
    
    @objc func addPopXOUserToDiscover(){
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        currentNavigation.popToRootViewController(animated: true)
        self.navBar?.switchHolderView.isHidden = false
        
        chatBotScreenForMyProfile.alpha = 0
        WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
        
        navBar?.setStyle(NavBarStyle.discover, animated: false)
        navBar!.backButton.isHidden = true
        navBar?.titleLabel.text = NSLocalizedString("Discover", comment: "Discover")
        DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        if DiscoverProfileCollection.sharedInstance.callInProgress == false{
            self.showWooLoader(wooLoaderStyle: true)
            self.fetchDiscoverData(false)
        }
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:"addWooIdToDiscover"), object: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "discoverToDetailSegue"){
            let detailViewControllerObject = segue.destination as! ProfileDeckDetailViewController
            if currentUserData != nil{
                detailViewControllerObject.profileData = (currentUserData as! ProfileCardModel)
            }
            detailViewControllerObject.discoverProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView
            
            detailViewControllerObject.moveToCellBasedOnCommonalitySelection = selectedCommonality!
            detailViewControllerObject.isComingFromDiscover = true
            detailViewControllerObject.detailProfileParentTypeOfView = DetailProfileViewParent.discover
            // detailViewControllerObject.isViewPushed = true
            detailViewControllerObject.needToOpenEditProfile = self.needToOpenEditProfile
            self.needToOpenEditProfile = false
            detailViewControllerObject.dismissHandler = {(currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString : String, userProfile: ProfileCardModel, onBoardingEditProfileDone:Bool, indexPath:IndexPath) in
                
                //SwipeBack
                
                if let nav = self.navigationController{
                    nav.swipeBackEnabled = true
                }
                
                
                if onBoardingEditProfileDone{
                    if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
                        self.checkIfMyProfileIsActive()
                        self.makeTheDeckSmall(shouldShowActionButton: false)
                    }
                }
                else{
                    self.makeTheDeckSmall(shouldShowActionButton: true)
                }
                print("DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = \(DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload)")
                self.crushToBeSent = crushString as NSString?
                
                if currentImageUrlString.count > 0{
                    if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
                        localProfileDeckViewObject.profileImageHasBeenChanged = true
                        localProfileDeckViewObject.setProfileImageForUser(URL(string: currentImageUrlString as String), userGender: localProfileDeckViewObject.profileDetails?.gender)
                    }
                }
                
                //                if self.currentSelectedTab != 1 {
                //                    return
                //                }
                self.checkForLikeLimit()
                self.buttonActivity = needToTakeAction
                
                if !(needToTakeAction == .DoNothing) {
                    if needToTakeAction == .Pass {
                        self.callHasAlreadyMadeInDetail = true
                    }
                    else{
                        self.callHasAlreadyMadeInDetail = false
                    }
                    self.disableCardInteraction = true
                    self.likeButton.isUserInteractionEnabled = false
                    self.passButton.isUserInteractionEnabled = false
                    self.crushButton.isUserInteractionEnabled = false
                }
                else{
                    self.disableCardInteraction = false
                }
                
                self.deckView.needToStopTranslationAndRotationForKoloda = false
                self.areWeMovingUpOrLeftRight = ""
                
                //
                //                DispatchQueue.main.async {
                //
                //                    //self.perform(#selector(self.makeTheDeckSmall), with:nil, afterDelay: 0.0)
                //                }
            }
        }
        else if(segue.identifier == "discoverToBrandSegue"){
            let brandViewControllerObject = segue.destination as! BrandCardViewController
            brandViewControllerObject.brandData = (currentUserData as! BrandCardModel)
            
            brandViewControllerObject.dismissHandler = {(currentImageUrlString:String, makeGetSwipe:Bool) in
                
                var imageUrlString = currentImageUrlString
                if currentImageUrlString.contains("wooapp://verifyPhoneNumber"){
                    WooScreenManager.sharedInstance.openDeepLinkedScreen(currentImageUrlString)
                    WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                        if crushPurchased{
                            self.showWooLoader(wooLoaderStyle: true)
                            self.fetchDiscoverData(false)
                        }
                    }
                    imageUrlString = ""
                }
                if makeGetSwipe == true {
                    if brandViewControllerObject.brandData?.subCardType == .WOOGLOBE {
                        
                        WooGlobeModel.sharedInstance().wooGlobleOption = true
                        WooGlobeModel.sharedInstance().isExpired = false
                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                        if WooGlobeModel.sharedInstance().religionArray.count < 1 {
                            WooGlobeModel.sharedInstance().religionOption = false
                        }
                        
                        if WooGlobeModel.sharedInstance().ethnicityArray.count < 1 {
                            WooGlobeModel.sharedInstance().ethnicityOption = false
                        }
                        
                        self.openDiscoverSettingsScreenPostWooGlobePurchase()
                    }
                    
                    self.perform(#selector(self.nowPerformBrandCardActions), with: nil, afterDelay: 0.3)
                }
                DispatchQueue.main.async {
                    if imageUrlString.count > 0{
                        if let localBrandDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? BrandCardDeck {
                            localBrandDeckViewObject.setBrandImageForUser(URL(string: currentImageUrlString as String))
                        }
                    }
                    self.perform(#selector(self.makeTheBrandDeckSmall), with:nil, afterDelay: 0.0)
                }
            }
        }
        else if (segue.identifier == SegueIdentifier.NewMtchSegue.rawValue) {
            let matchOverlayController = segue.destination as! NewMatchViewController
            matchOverlayController.matchData = self.matchData
            matchOverlayController.buttonType = OverlayButtonType.Keep_Swiping
        }
        else if segue.identifier == kPushToChatFromDiscover {
            if sender != nil {
                let chatViewControllerObj: NewChatViewController = segue.destination as! NewChatViewController
                //                let chatViewControllerObj: NewChatViewController  = chatViewNavControllerObj.viewControllers.first as! NewChatViewController
                let model = sender as! MyMatches
                chatViewControllerObj.myMatchesData = model
                chatViewControllerObj.parentView = .discover
                chatViewControllerObj.isAutomaticallyPushedFromChat = true
                chatViewControllerObj.delegateFromMatch = self
            }
        }else if(segue.identifier == "DiscoverToFeedbackSegue"){
            
            let feedbackObj:WriteAnswerViewController = (segue.destination as! WriteAnswerViewController)
            feedbackObj.screenType = .feedback
            feedbackObj.isOpenedFromSettings = false
            
        }else if (segue.identifier == "discoverToQuestionsSegue"){
            
            let questionCondtoller = segue.destination as! MyQuestionsController
            
            questionCondtoller.isPresentedFromMyProfile = false
            
        }else if (segue.identifier == "DiscoverToSettingsSegue"){
            
            let dict  = sender as! NSDictionary
            
            let _ : NSString = dict.object(forKey: "Screen") as! NSString
            
            let showPop : Bool = dict.object(forKey: "showPopUp") as! Bool
            
            let preference:MyPreferencesViewController = (segue.destination as! MyPreferencesViewController)
            
            preference.showPostWooGlobePurchasePopUp = showPop
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
            
            
        }
        else if (segue.identifier == "myProfileToVerifyNumber"){
            let controller:UINavigationController = (segue.destination as! UINavigationController)
            
            let firstController:VerifyNumberViewController = controller.viewControllers.first as! VerifyNumberViewController
            self.present(controller, animated: true, completion: nil)
            firstController.verifyFlowdismissHandler = {() in
                self.showWooLoader(wooLoaderStyle: true)
                self.fetchDiscoverData(false)
            }
            
        }
        
        
        
    }
    
    
    @objc func nowPerformButtonActions(showActionButton:Bool){
        self.disableCardInteraction = false
        if self.buttonActivity == .Like || self.buttonActivity == .CrushSent{
            self.like(UIButton())
        }
        else if self.buttonActivity == .Pass{
            self.disLike(UIButton())
            print("dislike should be called")
        }
        
        if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.discover {
            if showActionButton{
                self.showOrHideActionButtonsContainerView(true)
            }
        }
    }
    
    @objc fileprivate func nowPerformBrandCardActions(){
        self.like(UIButton())
    }
    
    //MARK: IBAction Methods
    
    @IBAction func closeTutorialFromButtonPress(_ sender: AnyObject) {
        currentShownTutorial = 0
    }
    @IBAction func closeTutorial(_ sender: AnyObject) {
        //        if currentShownTutorial == 1 {
        //            currentShownTutorial = 2
        //        }
        //        else if currentShownTutorial == 2{
        //            currentShownTutorial = 0
        //        }
        if currentShownTutorial == 1 {
            currentShownTutorial = 0
        }
    }
    
    @IBAction func showNextScreenOfTutorial(_ sender: AnyObject) {
        //        if currentShownTutorial == 1 {
        //            currentShownTutorial = 2
        //        }
        //        else if currentShownTutorial == 2{
        //            currentShownTutorial = 0
        //        }
        if currentShownTutorial == 1 {
            currentShownTutorial = 0
        }
    }
    @IBAction func showPreviousScreenOfTutorial(_ sender: AnyObject) {
        currentShownTutorial = 1
    }
    
    @IBAction func moveNext(_ sender: AnyObject) {
        if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "OnBoarding_MyProfile_NextTap")
            checkIfMyProfileIsActive()
        }
        //deckView.swipe(.Right)
        
    }
    @IBAction func disLike(_ sender: UIButton) {
        
        print("dislike button clicked")
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if UserDefaults.standard.bool(forKey: "firstTimeDisliked") == false{
            if self.recommendationArray?.collectionMode == CollectionMode.discover{
                self.showActionTutorialForType(.Dislike)
                return
            }
        }
        
        self.passButton.isUserInteractionEnabled = false
        
        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Left, isCrush: false, animationEnded: false)
        }
        self.perform(#selector(makePassSwipeNow), with: nil, afterDelay: 0.1)
    }
    
    @IBAction func like(_ sender: UIButton) {
        
        print("like button clicked")
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if UserDefaults.standard.bool(forKey: "firstTimeLiked") == false{
            if self.recommendationArray?.collectionMode == CollectionMode.discover{
                self.showActionTutorialForType(.Like)
                return
            }
        }
        
        self.likeButton.isUserInteractionEnabled = false
        
        if buttonActivity == .CrushSent {
            
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush: true, animationEnded: false)
            }
        }
        else{
            
            if checkIfUserWillSeeOutOfLikeAlert() {
                self.showOutOfLikeAlert()
                self.likeButton.isUserInteractionEnabled = true
                return
            }
            
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush: false, animationEnded: false)
            }
        }
        
        currentUserData = recommendationArray?.objectAtIndex(deckView.currentCardIndex) as? ProfileCardModel
        self.perform(#selector(makeLikeSwipeNow), with: nil, afterDelay: 0.1)
    }
    
    func checkIfUserWillSeeOutOfLikeAlert() -> Bool {
        var showOutOfLikeAlert = false
        if ((DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE") &&
            WooPlusModel.sharedInstance().isExpired &&
            (AppLaunchModel.sharedInstance().maxLikeToShowLikeMeter <= AppLaunchModel.sharedInstance().likeCount)) {
            showOutOfLikeAlert = true
        }
        return showOutOfLikeAlert
    }
    
    @IBAction func sendCrush(_ sender: UIButton) {
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_TapCrush")
        
        
        currentUserData = recommendationArray?.objectAtIndex(deckView.currentCardIndex) as? ProfileCardModel
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if currentUserData == nil {
            return
        }
                
        if (currentUserData as! ProfileCardModel).crushText.length > 0 {
            crushToBeSent = (currentUserData as! ProfileCardModel).crushText
            self.buttonActivity = .Like
            self.like(UIButton())
        }
        else{
            disableActionableButtons()
            performCrushSendingOperation()
        }
    }
    
    fileprivate func performCrushSendingOperation(){
        let crushPurchaseHandlerClass:CrushPurchaseFlowHandler = CrushPurchaseFlowHandler(with: self)
        crushPurchaseHandlerClass.showSendCrushView(false)
        crushPurchaseHandlerClass.purchaseFlowCompleteHandler = {(crushText, isSendButtonTapped, isTemplateTapped) in
            self.performWorkAfterCrushPurchased(isSendButtonTapped: isSendButtonTapped, isTemplateTapped: isTemplateTapped, crushText: crushText)
        }
    }
    
    fileprivate func disableActionableButtons(){
        self.passButton.isUserInteractionEnabled = false
        self.likeButton.isUserInteractionEnabled = false
        self.crushButton.isUserInteractionEnabled = false
    }
    
    fileprivate func performWorkAfterCrushPurchased(isSendButtonTapped:Bool, isTemplateTapped:Bool, crushText:String){
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_SendCrush")
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
        
        self.enableButtonsNow()
        if isSendButtonTapped == false && isTemplateTapped == false{
            return
        }
        
        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
        self.crushToBeSent = crushText as NSString?
        self.buttonActivity = .CrushSent
        self.like(UIButton())
        self.sendCrushViewObject = nil
        /*
        if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == true {
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                
                localProfileDeckViewObject.isHidden = true
                
            }
            
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                localProfileDeckViewObject.isHidden = true
            }
        }
        */
    }
    
    fileprivate func showPopularUserView(){
        let popularUserViewObject:PopularUserView = Bundle.main.loadNibNamed("PopularUserView", owner: nil, options: nil)![0] as! PopularUserView
        popularUserViewObject.frame = self.view.bounds
        popularUserViewObject.setPopularDataOnViewWithImage((currentUserData as! ProfileCardModel).wooAlbum?.objectAtIndex(0)?.url, withName: currentUserData!.firstName, andType: false, withGender:currentUserData!.gender) { (selectedIndex:NSInteger, typeOfView:Bool) in
            
            if typeOfView == false{
                if selectedIndex != 0{
                    //Purchase screen
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
                    WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseCrush)
                    WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.performCrushSendingOperation()
                            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                                
                                localProfileDeckViewObject.isHidden = true
                                
                            }
                            
                            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                                localProfileDeckViewObject.isHidden = true
                            }
                        }
                    }
                    
                    //popular user handling
                }
            }
        }
        let mainWindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
        mainWindow.rootViewController!.view.addSubview(popularUserViewObject)
    }
    
    fileprivate func showOutOfCrushesView(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfCrushPopup")
        
        
        let outOfCrushesViewObject:PopularUserView = Bundle.main.loadNibNamed("PopularUserView", owner: nil, options: nil)![0] as! PopularUserView
        outOfCrushesViewObject.frame = self.view.bounds
        outOfCrushesViewObject.setPopularDataOnViewWithImage((currentUserData as! ProfileCardModel).wooAlbum?.objectAtIndex(0)?.url, withName: currentUserData!.firstName, andType: true, withGender:currentUserData!.gender) { (selectedIndex:NSInteger, typeOfView:Bool) in
            //out of crushes handling
            if typeOfView == true{
                if selectedIndex != 0{
                    //Purchase screen
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DC_OutOfCrushPopup_GetCrushes")
                    
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
                    WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseCrush)
                    WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.performCrushSendingOperation()
                            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                                
                                localProfileDeckViewObject.isHidden = true
                                
                            }
                            
                            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                                localProfileDeckViewObject.isHidden = true
                            }
                        }
                    }
                }else{ // Cancel Button Clicked
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DC_OutOfCrushPopup_Cancel")
                    
                    
                }
            }
        }
        let mainWindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
        mainWindow.rootViewController!.view.addSubview(outOfCrushesViewObject)
    }
    
    @IBAction func retryDiscoveryButtonPressed(_ sender: AnyObject) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        else{
            if recommendationArray?.count() == 0 {
                if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                    showWooLoader(wooLoaderStyle: true)
                    DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                    self.recommendationArray?.cardCollection.get().removeAllObjects()
                    DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                    recommendationArray?.switchCollectionMode(CollectionMode.discover)
                    fetchDiscoverData(false)
                }
                else if (!UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) &&
                    (DiscoverProfileCollection.sharedInstance.myProfileData == nil || DiscoverProfileCollection.sharedInstance.myProfileData?.firstName == nil)){
                    if let  id = UserDefaults.standard.object(forKey: "id") {
                        let wooid:NSString = id as! NSString
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                        self.showWooLoader(wooLoaderStyle: false)
                        self.recommendationArray?.cardCollection.didChange.addHandler(self, handler: DiscoverViewController.collectionDidChange)
                    }
                }
            }
            else{
                
            self.deckView.isHidden = false
//            if(DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos() < 1){
//
//                    _ = AlertController.showAlert(withTitle: "Violate our Guidelines!", andMessage: "To encourage connections between real people, we ask that at least one of your photos has you clearly visible in it.", needHandler: false, withController: self)
//            }
                    
                    hideWooLoader()
            }
            noInternetScreen.isHidden = true
        }
    }
    
    @IBAction func openEditProfile(_ sender: AnyObject) {
        
        self.otherScreenIsPresentOnTop = true
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Onboard_MyProfile_TapEditProfile")
        }
        
        let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        controller.openedFromReviewPhotoCard = editProfileOpenedFromReviewPhotoCard
        controller.dismissHandler = { (isModified, toClose) in
            
            if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
                self.checkIfMyProfileIsActive()
            }
            else{
                if self.shouldNotOpenProfileDetail == false{
                    //DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
                    if isModified {
                        if let userDetails =  self.recommendationArray?.objectAtIndex(0) as? ProfileCardModel{
                            self.selectedCommonality = ""
                            self.currentUserData = userDetails
                            //self.reloadDeckView()
                            self.resettingKolodaViewTogetPerfectFrame()
                            /*
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                             self.makeTheProfileDeckBig()
                             }
                             */
                        }
                    }
                }
                
                self.shouldNotOpenProfileDetail = false
                self.editProfileOpenedFromReviewPhotoCard = false
            }
        }
        
        controller.isRefreshNeeded = true
        //        let navController = UINavigationController(rootViewController: controller)
        //        self.present(navController, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openEditProfileOnlyForWorkEducation(){
        self.otherScreenIsPresentOnTop = true
        /*
         let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
         controller.isTypeOfWorkEducation = true
         controller.openedFromReviewPhotoCard = true
         controller.dismissHandler = { (isModified, toClose) in
         
         }
         
         controller.isRefreshNeeded = true
         //        let navController = UINavigationController(rootViewController: controller)
         self.navigationController?.pushViewController(controller, animated: true)
         */
        WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://editProfile/link?syncLinkedin")
        //present(navController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    @objc fileprivate func makeLikeSwipeNow(){
        
        if let userDetails =  self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) as? ProfileCardModel{
            let imagesArray:NSArray = NSArray.init(array: (userDetails.wooAlbum?.allImagesUrl())!)
            (Utilities.sharedUtility() as AnyObject).deleteImagesFromCache(forProfile:imagesArray as! [Any])
        }
        
        if buttonActivity == .Like {
            deckView.crushIsBeingSent = false
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush:  false,animationEnded: true)
            }
        }
        else if buttonActivity == .CrushSent{
            deckView.crushIsBeingSent = true
        }
        deckView.swipe(SwipeResultDirection.Right)
    }
    
    @objc fileprivate func checkForInternet(){
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            noInternetScreen.isHidden = false
            deckView.isHidden = true
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        }
    }
    
    @objc fileprivate func internetConnectionStatusChanged(_ notif : Notification) {
        
        let notiValue: Int = (notif.object as! NSNumber).intValue
        if notiValue == AFNetworkReachabilityStatus.reachableViaWiFi.rawValue ||
            notiValue == AFNetworkReachabilityStatus.reachableViaWWAN.rawValue
        {
            return;
            
            if recommendationArray?.count() == 0 {
                if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                    self.showWooLoader(wooLoaderStyle: true)
                    DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                    self.recommendationArray?.cardCollection.get().removeAllObjects()
                    DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                    recommendationArray?.switchCollectionMode(CollectionMode.discover)
                    fetchDiscoverData(false)
                }
                else if (!UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) &&
                    (DiscoverProfileCollection.sharedInstance.myProfileData == nil || DiscoverProfileCollection.sharedInstance.myProfileData?.firstName == nil)){
                    if let  id = UserDefaults.standard.object(forKey: "id") {
                        let wooid:NSString = id as! NSString
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                        self.showWooLoader(wooLoaderStyle: false)
                        
                        self.recommendationArray?.cardCollection.didChange.addHandler(self, handler: DiscoverViewController.collectionDidChange)
                    }
                }
            }
            else{
                 self.deckView.isHidden = false
//            if(DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos() < 1){
//                        self.deckView.isHidden = true
//            }
                hideWooLoader()
            }
            noInternetScreen.isHidden = true
        }
        else{
            if recommendationArray?.count() == 0 && DiscoverEmptyManager.sharedInstance.count() == 0{
                noInternetScreen.isHidden = false
                self.deckView.isHidden = true
                hideWooLoader()
            }
        }
    }
    
    @objc fileprivate func appEnteredBackground(){
        
        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Left, isCrush: false,animationEnded: true)
        }
        
        deckView.resetPositionOfCurrentCard()
    }
    
    @objc func checkForLikeLimit() {
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE" &&
            WooPlusModel.sharedInstance().isExpired{
            likeButton.setProgressbarVisible(true)
            likeButton.progressValue = CGFloat(AppLaunchModel.sharedInstance().likeCount)/CGFloat(AppLaunchModel.sharedInstance().maxLikeToShowLikeMeter)*100.0
        }
        else{
            likeButton.setProgressbarVisible(false)
        }
    }
    
    func showOrHideActionButtonsContainerView(_ showOrHide:Bool) {
        if recommendationArray?.collectionMode != CollectionMode.my_PROFILE {
            
            if let localActionButtonContainerView = self.actionButtonsContainerView{
                
                localActionButtonContainerView.isHidden = false
                UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    if showOrHide == true {
                        localActionButtonContainerView.transform = CGAffineTransform.identity
                    }
                    else{
                        localActionButtonContainerView.transform = CGAffineTransform(translationX: 0, y: 160 + safeAreaBoth)
                    }
                }) { (true) in
                    
                }
            }
        }
        else{
            if let localActionButtonContainerView = self.actionButtonsContainerView{
                localActionButtonContainerView.isHidden = true
            }
        }
    }
    
    @objc func fetchDiscoverData(_ isPrefrenceExtended : Bool) {
        
        //  if self.isViewLoaded && (self.view.window != nil) {
        
        
        
        //        if DiscoverProfileCollection.sharedInstance.intentModelObject?.modelHasBeenUpdatedByServer.boolValue == false {
        //            return
        //        }
        if updateUserCurrentLocation(){
            return
        }
        
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            // showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            
            
            // added condition for hide woo loader & show no internet screen
            self.hideWooLoader()
            noInternetScreen.isHidden = false
            deckView.isHidden = true
            
            return
        }else{
            noInternetScreen.isHidden = true
        }
        
        var isLocationChanged:Bool = false
        
        if ((UserDefaults.standard.object(forKey: kUserLastLocationKey) == nil || UserDefaults.standard.object(forKey: kLastLocationUpdatedTime) == nil)) {
            isLocationChanged = true
            locationManager?.getUserCurrentLocation({ (success, locationObj) in
                
                self.fetchDiscoverData(false)
                
            })
            
            return
        }
        
        if self.recommendationArray?.count() > 0{
            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
            DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
            DiscoverProfileCollection.sharedInstance.paginationToken = ""
            DiscoverProfileCollection.sharedInstance.paginationIndex = ""
            
            self.actionButtonsContainerView.isHidden = true
        }
        
        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: isPrefrenceExtended, isTagSelected: false, andCompletionBlock: { (success, response, errorCode) in
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            if isLocationChanged ==  true{
                if let  id = UserDefaults.standard.object(forKey: "id") {
                    let wooid:NSString = id as! NSString
                    ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                    //                    self.showWooLoader()
                    //                    self.recommendationArray?.cardCollection.didChange.addHandler(self, handler: DiscoverViewController.collectionDidChange)
                }
            }
            
            if self.isLocationChangedAfterLaunch == true {
                isLocationChanged = self.isLocationChangedAfterLaunch
                self.isLocationChangedAfterLaunch = false
            }
            
            if success {
                
                if self.currentSelectedTab != 1{
                    DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                    DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
                }
                else{
                    DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = false
                }
                
                if isPrefrenceExtended == true{
                    (AppLaunchApiClass.sharedManager() as AnyObject).getNotificationConfigOptions(completionBlock: nil)
                }
                
                self.recommendationArray = DiscoverProfileCollection.sharedInstance
                if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                    if self.recommendationArray?.discoverModelCollection.count > 0{
                        self.recommendationArray?.switchCollectionMode(CollectionMode.discover)
                        self.reloadDeckView()
                    }
                    else{
                        if DiscoverEmptyManager.sharedInstance.count() > 0{
                            DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
                            self.recommendationArray?.switchCollectionMode(CollectionMode.discover_EMPTY)
                            self.reloadDeckView()
                        }
                    }
                }
                //                SDWebImagePrefetcher *prefetchedReference = [SDWebImagePrefetcher sharedImagePrefetcher];
                //                [prefetchedReference setMaxConcurrentDownloads:5];
                //                [prefetchedReference setOptions:SDWebImageLowPriority||SDWebImageContinueInBackground];
                //                [prefetchedReference prefetchURLs:profilePicsArray];
            }
            else{
                if errorCode == 401 {
                    WooScreenManager.sharedInstance.loadLoginView()
                    (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp(nil)
                }
                else if errorCode == 500{
                    self.showSnackBar("Server is not responding")
                }
                else if errorCode == 0{
                    //self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    self.noInternetScreen.isHidden = false
                    self.deckView.isHidden = true
                }
                self.hideWooLoader()
            }
            
            if(DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos() < 1){
                
                _ = AlertController.showAlert(withTitle: "Violate our Guidelines!", andMessage: "To encourage connections between real people, we ask that at least one of your photos has you clearly visible in it.", needHandler: false, withController: self)
            }
            
        })
        
    }
    
    func collectionDidChange(_ tupleValue:(oldValue: NSMutableArray, newValue: NSMutableArray)) {
        if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
            
            if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown)
            {
                UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.chatBotScreenForMyProfile.alpha = 1
                }, completion: nil)
            }
            
            chatBotImageView.sd_setImage(with: LoginModel.sharedInstance().botUrl)
            
        }
        if self.recommendationArray?.count() > 0 {
            self.deckView.isHidden = false
//        if(DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos() < 1){
//                    self.deckView.isHidden = true
//        }
            
            self.reloadDeckView()
        }
        else{
            hideWooLoader()
        }
        
        self.recommendationArray?.cardCollection.didChange.removeAllHandlers()
    }
    
    @objc fileprivate func showActionButtonsWithDelay(){
        self.showOrHideActionButtonsContainerView(true)
    }
    
    @objc func showWooLoader(wooLoaderStyle:Bool){
        if(customLoader != nil)
        {
            customLoader?.removeFromSuperview()
            customLoader = nil
        }
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        if wooLoaderStyle {
            customLoader?.shouldShowWooLoader = true
            self.deckView.alpha = 0
            self.actionButtonsContainerView.isHidden = true
        }
        else{
            customLoader?.shouldShowWooLoader = false
        }
        
        DispatchQueue.main.async {
            self.customLoader?.startAnimation(on: self.view, withBackGround: false)
        }
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.deckView.alpha = 1
        }, completion: { (true) in
            self.customLoader?.stopAnimation()
            self.customLoader?.removeFromSuperview()
        })
        
    }
    
    func performActionForType(_ actionType:PerformAction, profileObject:ProfileCardModel){
        
        profileAction.currentViewType = .Discover
        if (self.crushToBeSent != nil){
            profileAction.crushText = self.crushToBeSent! as String
        }
        
        profileAction.reloadHandler = {(indexPath:IndexPath) in
            //self.reloadViewAfterRemovingData()
            if(actionType == .Pass){
                SkippedProfiles.insertOrUpdateSkippedProfileData(fromDiscoverCard: [profileObject], withCompletionHandler:nil)
            }
            
        }
        profileAction.performSegueHandler = { (matchedUserDataFromDb:MyMatches) in
            if (Utilities().isChatRoomPresent(in: self.navigationController) == false){
                if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                }else{
                    self.performSegue(withIdentifier: kPushToChatFromDiscover, sender: matchedUserDataFromDb)
                }
            }
        }
        
        switch actionType {
        case .Like:
            profileAction.likeActionPerformed(.ProfileCardModel, userObject: profileObject as AnyObject)
            break
            
        case .Pass:
            profileAction.dislikeActionPerformed(.ProfileCardModel, userObject: profileObject as AnyObject)
            break
            
        case .CrushSent:
            profileAction.crushActionPerformed(.ProfileCardModel, userObject: profileObject as AnyObject)
            break
            
        default:
            break
        }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    //MARK: Deck related Methods
    func setupDeckView() {
        deckView.dataSource = self
        deckView.delegate = self
    }
    
    @objc func reloadDeckView(){
        
        print("reload has been called now")
        if recommendationArray?.collectionMode != CollectionMode.my_PROFILE {
            //showWooLoader(wooLoaderStyle: true)
            if DiscoverEmptyManager.sharedInstance.count()>0 {
                
            }
            else{
                DiscoverProfileCollection.sharedInstance.updateDiscoverModelCollectionBasedOnReadStatus()
            }
            
        }
        else if recommendationArray?.collectionMode == CollectionMode.my_PROFILE{
            showWooLoader(wooLoaderStyle: false)
        }
        deckView.isHidden = true
        //If pagination then there will be no delay in unhiding deckview
        //nowShowDeckView()
        if DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent == true{
            DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = false
            self.perform(#selector(resettingKolodaViewTogetPerfectFrame), with: nil, afterDelay: 0.1)
            self.perform(#selector(nowShowDeckView), with: nil, afterDelay: 0.1)
        }
        else{
            self.perform(#selector(resettingKolodaViewTogetPerfectFrame), with: nil, afterDelay: 0.1)
            self.perform(#selector(nowShowDeckView), with: nil, afterDelay: 0.1)
            //resettingKolodaViewTogetPerfectFrame()
            //nowShowDeckView()
        }
        
        if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
            if (UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown))
            {
                redirectToUTMScreen()
            }
        }
    }
    
    func reloadDeckAnimated(){
        self.perform(#selector(resettingKolodaViewTogetPerfectFrame), with: nil, afterDelay: 0.1)
    }
    
    
    func addGrowthAnimationForSettingsButton()
    {
        let popup =  CABasicAnimation(keyPath: "transform.scale")
        popup.fromValue = NSNumber(value: 1.5)// : 1.5)
        popup.toValue = NSNumber(integerLiteral: 1)
        popup.duration = 0.5
        self.navBar?.settingsButton.layer.add(popup, forKey: "scaleAnimation")
    }
    
    
    @objc func resettingKolodaViewTogetPerfectFrame(){
        deckView.resetCurrentCardIndex()
        
    }
    
    @objc func nowShowDeckView(){
        
        deckView.isHidden = false
        self.likeButton.isHidden = false
        self.passButton.isHidden = false
        self.crushButton.isHidden = false
        
//    if(DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos() < 1){
//
//            _ = AlertController.showAlert(withTitle: "Violate our Guidelines!", andMessage: "To encourage connections between real people, we ask that at least one of your photos has you clearly visible in it.", needHandler: false, withController: self)
//
//        }else{
//            deckView.isHidden = false
//            self.likeButton.isHidden = false
//            self.passButton.isHidden = false
//            self.crushButton.isHidden = false
//        }
        
            hideWooLoader()
    }
    
    @objc func reloadDeckViewWithAppearAnimation(){
        deckView.resetCurrentCardIndex()
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.deckView.alpha = 1
        }) { (true) in
            
            if self.recommendationArray?.count()>0 {
                if let userDetails =  self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) as? ProfileCardModel{
                    if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.discover {
                        self.showOrHideActionButtonsContainerView(true)
                        if userDetails.crushText.length > 0 {
                            self.crushButton.isSelected = true
                        }
                        else{
                            self.crushButton.isSelected = false
                        }
                    }
                }
                else{
                    self.showOrHideActionButtonsContainerView(false)
                }
            }
            
            if (self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) is DiscoverEmptyModel) {
                let discoverEmptyModel = self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) as! DiscoverEmptyModel
                if discoverEmptyModel.subCardType == .DISCOVER_EMPTY_DEFAULT {
                    self.disableCardInteraction = true
                }
                else{
                    self.disableCardInteraction = false
                }
            }
            else{
                self.disableCardInteraction = false
            }
            
        }
    }
    
    @objc fileprivate func makePassSwipeNow(){
        if let userDetails =  self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) as? ProfileCardModel{
            
            let imagesArray:NSArray = NSArray.init(array: (userDetails.wooAlbum?.allImagesUrl())!)
            (Utilities.sharedUtility() as AnyObject).deleteImagesFromCache(forProfile:imagesArray as! [Any])
        }
        
        deckView.swipe(SwipeResultDirection.Left)
        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Left, isCrush: false,animationEnded: true)
        }
        
    }
    
    
    fileprivate func checkIfMyProfileIsActive() {
        if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
            if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Onboard_MyProfile", withEventName: "3-Onboarding.Onboard_MyProfile.OMP_CompletedOB")
                /* Removed Tutorial
                 if !UserDefaults.standard.bool(forKey: kIsTutorialShown) {
                 currentShownTutorial = 1
                 setupTutorialScreen()
                 }
                 */
            }
            UserDefaults.standard.set(true, forKey: kIsOnboardingMyProfileeShown)
            UserDefaults.standard.synchronize()
            
            navBar?.setStyle(NavBarStyle.discover, animated: false)
            navBar!.backButton.isHidden = true
            navBar?.titleLabel.text = NSLocalizedString("Discover", comment: "Discover")
            navBar!.backButton.removeTarget(self,
                                            action: #selector(DiscoverViewController.myProfileBackButtonPressed(_:)),
                                            for: UIControl.Event.touchUpInside)
            
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.chatBotScreenForMyProfile.transform = CGAffineTransform(translationX: 0, y: -124.0)
            }, completion: { (isCompleted) in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.navBar?.transform = CGAffineTransform.identity
                }, completion: nil)
                /* Removed Tutorial
                 if UserDefaults.standard.bool(forKey: kIsTutorialShown) {
                 WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                 }
                 */
            })
            
            self.navBar?.switchHolderView.isHidden = false
            
            self.recommendationArray?.switchCollectionMode(CollectionMode.discover)
            
            //            if DiscoverProfileCollection.sharedInstance.myProfileData != nil{
            //            if (DiscoverProfileCollection.sharedInstance.myProfileData?.isPhoneVerificationPartOfOnboarding == true) {
            //                let storyboard = UIStoryboard(name: "Woo_3", bundle: nil)
            //                let controller:UINavigationController = storyboard.instantiateViewController(withIdentifier: "VerifyNumberViewNavController") as! UINavigationController
            //                let firstController:VerifyNumberViewController = controller.viewControllers.first as! VerifyNumberViewController
            //                self.present(controller, animated: true, completion: nil)
            //                firstController.verifyFlowdismissHandler = {() in
            //                    self.showWooLoader()
            //                    self.fetchDiscoverData(false)
            //                }
            //                }
            //
            //                //self.performSegue(withIdentifier: "myProfileToVerifyNumber", sender: nil)
            //            }
            showWooLoader(wooLoaderStyle: true)
            fetchDiscoverData(false)
        }
    }
    
    fileprivate func handleRightSwipeForIndex(_ index : Int) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if callHasAlreadyMadeInDetail == true {
            // self.deckView.isHidden = true
            callHasAlreadyMadeInDetail = false
            if self.buttonActivity == .Like{
                AppLaunchModel.sharedInstance().likeCount += 1
                self.checkForLikeLimit()
            }
            else{
                self.buttonActivity = .Like
            }
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.5)
            
            if matchData != nil {
                MyMatches.insertDataInMyMatches(from: NSArray(objects: matchData!) as [AnyObject], withChatInsertionSuccess: { (success) in
                    if(success){
                        let matchedUserDataFromDb = MyMatches.getMatchDetail(forMatchID: self.matchData?.object(forKey: "matchId") as? String)
                        if matchedUserDataFromDb != nil {
                            if (Utilities().isChatRoomPresent(in: self.navigationController) == false) {
                                if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                                }else{
                                self.performSegue(withIdentifier: kPushToChatFromDiscover, sender: matchedUserDataFromDb)
                                }
                                self.matchData = nil
                            }
                        }
                    }
                })
                
            }
            
            if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == true {
                // self.performSelector(#selector(self.makeServerCallForGettingNewData), withObject: nil, afterDelay: 0.1)
                self.makeServerCallForGettingNewData()
            }
            
            return
        }
        //        else{
        //            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.2)
        //        }
        
        if self.recommendationArray?.count()>0 {
            if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
                if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                    //checkIfMyProfileIsActive()
                    return
                }
                
                if self.buttonActivity == .CrushSent {
                    self.buttonActivity = .Like
                    performActionForType(.CrushSent, profileObject: userDetails)
                }
                else{
                    self.checkForLikeLimit()
                    currentUserData = recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_LikeByTapOrSwipe")
                    print("Right Swipe is happening for user \(String(describing: userDetails.wooId))")
                    performActionForType(.Like, profileObject: userDetails)
                }
            }
            else if let reviewCardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ReviewPhotoCardModel {
                
                BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: reviewCardDetails.cardId)
                //DiscoverProfileCollection.sharedInstance.removeReviewPhotoCard()
                
            }
            else if let discoverEmptyDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? DiscoverEmptyModel {
                BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: discoverEmptyDetails.id)
                recommendationArray?.removeFirstDiscoverEmptyCard()
            }
            else if let selectionCardModel = self.recommendationArray?.objectAtIndex(Int(index)) as? SelectionCardModel {
                
                if selectionCardModel.subCardType == .RELIGION{
                    
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "ReligionBrandCard_Like")
                    
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "ReligionBrandCard", withEventName: "3-Discovery.ReligionBrandCard.RBC_SwipedLeftOrRight")
                    
                }else if selectionCardModel.subCardType == .ETHNICITY{
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EthnicityBrandCard_Like")
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "EthnicityBrandCard", withEventName: "3-Discovery.EthnicityBrandCard.EBC_SwipedLeftOrRight")
                    
                }else if selectionCardModel.subCardType == .TAGS{
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "TagsBrandCard", withEventName: "3-Discovery.TagsBrandCard.TBC_SwipedLeftOrRight")
                    
                }
                
                
                if selectionCardSelectedValueArray.count > 0 {
                    BrandCardAPI.updateSelectionCardPassStatus(onServer: selectionCardModel.subCardType.rawValue,
                                                               and: selectionCardModel.cardId,
                                                               andSelectedValues: selectionCardSelectedValueArray)
                    BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: selectionCardModel.cardId)
                }
                else{
                    BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: selectionCardModel.cardId)
                }
            }
            else if (self.recommendationArray?.objectAtIndex(Int(index)) as? NewUserNoPicCardModel) != nil {
                DispatchQueue.main.async{
                    self.showImageCropper()
                }
            }
        }
        
        if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == true {
            // self.performSelector(#selector(self.makeServerCallForGettingNewData), withObject: nil, afterDelay: 0.1)
            self.makeServerCallForGettingNewData()
        }
        
    }
    
    fileprivate func handleLeftForIndex(_ index : Int) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == true
        {
            self.makeServerCallForGettingNewData()
            // self.performSelector(#selector(self.makeServerCallForGettingNewData), withObject: nil, afterDelay: 0.1)
        }
        
        if callHasAlreadyMadeInDetail == true {
            //  self.deckView.isHidden = true
            callHasAlreadyMadeInDetail = false
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.5)
            return
        }
        //        else{
        //            //self.recommendationArray?.removeItemsFromTop(self.deckView.currentCardIndex)
        //            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.2)
        //
        //        }
        
        
        if  self.recommendationArray?.count()>0 {
            if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
                print("DiscoverProfileCollection.sharedInstance.collectionMode \(DiscoverProfileCollection.sharedInstance.collectionMode)")
                //  checkIfMyProfileIsActive()
                if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                    return
                }
                else{
                    //Umesh Mishra >> I have moved the code to else condition, as if the view is not my profile the else condition will execute and I have to make sure that delete profile method is called before adding the profile to SKipped profile.
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_SkipByTapOrSwipe")
                    
                    
                    // Removed this condition For Aditya's new requirement > do not remove user from me section if you are adding it in Skipped section : April 10, 2017
                    //                    Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: userDetails.wooId, shouldDeleteFromAnswer: false)
                    
                    performActionForType(.Pass, profileObject:userDetails)
                    
                }
                // Srwve Event
                
            }
            else if let brandDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? BrandCardModel {
                
                if let urlToOpen = brandDetails.actionUrl {
                    
                    let urlString = urlToOpen.absoluteString
                    
                    if urlString.contains("verifyPhoneNumber"){
                        (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "PhoneBrandCard_Skip")
                    }
                }
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_SkipByTapOrSwipe")
                
                
                BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: brandDetails.cardId)
                
            }
            else if let reviewCardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ReviewPhotoCardModel {
                
                BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: reviewCardDetails.cardId)
                
            }
            else if let discoverEmptyDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? DiscoverEmptyModel {
                BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: discoverEmptyDetails.id)
                recommendationArray?.removeFirstDiscoverEmptyCard()
            }
            else if let selectionCardModel = self.recommendationArray?.objectAtIndex(Int(index)) as? SelectionCardModel {
                if selectionCardModel.subCardType == .RELIGION{
                    
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "ReligionBrandCard_Skip")
                    
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "ReligionBrandCard", withEventName: "3-Discovery.ReligionBrandCard.RBC_SwipedLeftOrRight")
                    
                }else if selectionCardModel.subCardType == .ETHNICITY{
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EthnicityBrandCard_Skip")
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "EthnicityBrandCard", withEventName: "3-Discovery.EthnicityBrandCard.EBC_SwipedLeftOrRight")
                    
                }else if selectionCardModel.subCardType == .TAGS{
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "TagsBrandCard", withEventName: "3-Discovery.TagsBrandCard.TBC_SwipedLeftOrRight")
                    
                }
                
                if selectionCardSelectedValueArray.count > 0 {
                    BrandCardAPI.updateSelectionCardPassStatus(onServer: selectionCardModel.subCardType.rawValue,
                                                               and: selectionCardModel.cardId,
                                                               andSelectedValues: selectionCardSelectedValueArray)
                    BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: selectionCardModel.cardId)
                }
                else{
                    BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: selectionCardModel.cardId)
                }
            }
        }
    }
    
    func makeTheProfileDeckBig(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_ViewDPV")
        
        
        // self.view.backgroundColor = UIColor.white
        
        // self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                self.actionButtonsContainerView.transform = CGAffineTransform(translationX: 0,  y: UIScreen.main.bounds.size.height - (self.actionButtonsContainerView.frame.height + self.actionButtonsContainerView.frame.origin.y))
            }
            
            self.chatBotScreenForMyProfile.alpha = 0
            
            self.view.layoutIfNeeded()
            
            self.performSegue(withIdentifier: SegueIdentifier.DiscoverToDetailSegue.rawValue,
                              sender: nil)
            
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        }, completion: { (true) in
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.nowRemoveGradiant()
            }
        })
    }
    
    
    func makeTheBrandDeckBig(){
        self.view.layoutIfNeeded()
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_ViewDPV")
        
        if let localbrandDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? BrandCardDeck {
            localbrandDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
            localbrandDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
            localbrandDeckViewObject.updateBrandDeckMainContainerViewHeightRelatedConstraints()
            localbrandDeckViewObject.setupViewProperties()
            let height = UIScreen.main.bounds.height
            self.deckViewHeightConstraint.constant = height - safeAreaBoth
            
            if userHasChoosedToMoveBrandCardUp == true {
                //localbrandDeckViewObject.bottomLayerContainerViewBottomConstraint.constant = -105
            }
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex+1)) {
                
                localProfileDeckViewObject.isHidden = true
            }
            
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex+2)) {
                
                localProfileDeckViewObject.isHidden = true
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.deckView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                localbrandDeckViewObject.commonalityTagsView.alpha = 0
                WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
                localbrandDeckViewObject.nowRemoveGradiant()
                self.showOrHideActionButtonsContainerView(false)
            }, completion: { (true) in
                self.performSegue(withIdentifier: SegueIdentifier.DiscoverToBrandSegue.rawValue,
                                  sender: self)
            })
        }
    }
    
    @objc func makeTheDeckSmall(shouldShowActionButton:Bool){
        showActionButton = shouldShowActionButton
    }
    
    @objc func makeTheBrandDeckSmall(){
        
        areWeMovingUpOrLeftRight = ""
        
        //self.view.layoutIfNeeded()
        
        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? BrandCardDeck {
            localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 10.0
            localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 10.0
            localProfileDeckViewObject.setDataForCommonalityTagsAndBadges()
            localProfileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
        }
        
        let height = UIScreen.main.bounds.height
        deckViewHeightConstraint.constant = height - safeAreaBoth - topMarginForDeckView
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.deckView.layoutIfNeeded()
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            self.showOrHideActionButtonsContainerView(false)
            
        }, completion: { (true) in
            
            if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == false{
                
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                    localProfileDeckViewObject.isHidden = false
                }
                
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                    localProfileDeckViewObject.isHidden = false
                }
            }
        })
    }
    
    fileprivate func showOutOfLikeAlert(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup")
        
        
        if outOfLikePopup != nil {
            outOfLikePopup?.removeView()
            outOfLikePopup = nil
        }
        
        outOfLikePopup = OutOfLikeView.showView(parentViewController: WooScreenManager.sharedInstance.oHomeViewController!)
        outOfLikePopup?.buttonPressHandler = {
            //More Info
            
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup_MoreInfo")
            
            DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
            
            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
            purchaseObj.purchaseShownOnViewController = self
            purchaseObj.initiatedView = "Outoflikes_getwooplus"
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Outoflikes_getwooplus")
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
            purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                if WooPlusModel.sharedInstance().isExpired == false {
                    if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                        localProfileDeckViewObject.isHidden = true
                        
                    }
                    if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                        localProfileDeckViewObject.isHidden = true
                    }
                    
                }
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                    if WooPlusModel.sharedInstance().isExpired == false {
                        if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                            localProfileDeckViewObject.isHidden = true
                            
                        }
                        if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                            localProfileDeckViewObject.isHidden = true
                        }
                        
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
            
            
        }
        
    }
    
    fileprivate func showImageCropper(){
        
        let screenWidth:CGFloat = UIScreen.main.bounds.size.width * 0.7361
        let screenHeight:CGFloat = UIScreen.main.bounds.size.height
        
        let imageCropperViewController:VPImageCropperViewController = VPImageCropperViewController.init(image: UIImage.init(named:"crop_default"), cropFrame: CGRect(x: (UIScreen.main.bounds.size.width - screenWidth)/2, y: 0.122*screenHeight, width: screenWidth, height: 0.65*screenHeight), limitScaleRatio: 3)
        //        imageCropperViewController.isPresented = true
        imageCropperViewController.isImageAdded = true
        DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
        imageCropperViewController.wooAlbumisUpdatedNow {
            self.openEditProfileScreen()
            if (self.recommendationArray?.objectAtIndex(Int(self.deckView.currentCardIndex)) as? NewUserNoPicCardModel != nil){
                self.perform(#selector(self.removeNewUserNoPicFromDeck), with: nil, afterDelay: 0.2)
            }
        }
        self.navigationController?.pushViewController(imageCropperViewController, animated: true)
        //present(imageCropperViewController, animated: true, completion: nil)
    }
    
    @objc fileprivate func makeServerCallForGettingNewData(){
        
        areWeMovingUpOrLeftRight = ""
        
        showWooLoader(wooLoaderStyle: true)
        self.deckView.isHidden = true
        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
        self.perform(#selector(nowMakeDiscoverCallAsOtherCallsAreDone), with: nil, afterDelay: 0.5)
        
    }
    
    @objc fileprivate func nowMakeDiscoverCallAsOtherCallsAreDone(){
        self.actionButtonsContainerView.isHidden = true
        DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
        self.recommendationArray?.cardCollection.get().removeAllObjects()
        DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
        DiscoverProfileCollection.sharedInstance.paginationToken = ""
        DiscoverProfileCollection.sharedInstance.paginationIndex = ""
        self.fetchDiscoverData(false)
    }
    
    @objc fileprivate func removeNewUserNoPicFromDeck(){
        self.deckView.swipe(.Left)
    }
    
    func pb_takeSnapshot() -> UIImage? {
        if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(self.deckView.currentCardIndex) as? ProfileDeckView {
            let rect: CGRect = (localProfileDeckViewObject.profileDeckMainContainerView.bounds)
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
            let context: CGContext = UIGraphicsGetCurrentContext()!
            localProfileDeckViewObject.profileDeckMainContainerView.layer.render(in: context)
            let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return capturedImage
        }
        else{
            return nil
        }
    }
    
    @IBAction func myProfileBackButtonPressed(_ button: UIButton) {
        
        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
        WooScreenManager.sharedInstance.oHomeViewController?.showTabBar(false)
        
        navBar?.setStyle(NavBarStyle.discover, animated: false)
        navBar!.backButton.isHidden = true
        navBar?.titleLabel.text = NSLocalizedString("Discover", comment: "Discover")
        navBar!.backButton.removeTarget(self,
                                        action: #selector(DiscoverViewController.myProfileBackButtonPressed(_:)),
                                        for: UIControl.Event.touchUpInside)
        DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
    }
    
    
    @objc func enableButtonsNow()
    {
        self.disableCardInteraction = false
        self.passButton.isUserInteractionEnabled = true
        self.likeButton.isUserInteractionEnabled = true
        self.crushButton.isUserInteractionEnabled = true
        
        
    }
    
    // MARK: Open Visitor Section Notification Section
    @objc func openVisitorSection(){
        NSLog("openVisitorSection")
        
        self.otherScreenIsPresentOnTop = true
        
        //        self.performSegue(withIdentifier: "discoverToVisitorSegue", sender: nil)
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://visitors")
    }
    
    @objc func openLikedMeSection(){
        self.otherScreenIsPresentOnTop = true
        
        //        (AppSessionManager.sharedManager() as? AppSessionManager)?.getCrushFromServer()
        //        self.performSegue(withIdentifier: "discoverToLikedMeSegue", sender: nil)
        NSLog("openLikedMeSection")
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://likedMe")
    }
    
    @objc func openContentGuidelines()
    {
        self.otherScreenIsPresentOnTop = true
        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.Content_Guidelines)
    }
    
    @objc func openCrushDashboard(){
        
        self.otherScreenIsPresentOnTop = true
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        //self.performSegue(withIdentifier: "discoverToCrushDashboardSegue", sender: nil)
        WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://crush")
        
    }
    
    
    @objc func openSkippedProfile(){
        
        self.otherScreenIsPresentOnTop = true
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        // self.performSegue(withIdentifier: "discoverToSkippedProfileSegue", sender: nil)
        WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://skipped")
        
    }
    
    @objc func openMyPurchaseScreen(){
        self.otherScreenIsPresentOnTop = true
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        //self.performSegue(withIdentifier: "discoverToMyPurchaseSegue", sender: nil)
        WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://mypurchases")
        
        
    }
    
    
    @objc func openEditProfileScreen(){
        
        self.otherScreenIsPresentOnTop = true
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        
        let wooid:NSString = UserDefaults.standard.object(forKey: "id") as! NSString
        ProfileAPIClass.fetchDataForUser(withUserID:Int64(wooid.longLongValue))
        { (response, success, statusCode) in
            //let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
            //self.present(controller, animated: true, completion: nil)
            WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://editProfile")
        }
    }
    
    
    
    func openInAppBrowserScreen(notif : NSNotification){
        
        self.otherScreenIsPresentOnTop = true
        if let dict = notif.object as? NSDictionary{
            
            if (dict.object(forKey: "URL") != nil) {
                
                let webViewObj : WkWebViewController = self.storyboard?.instantiateViewController(withIdentifier: kMyWebViewController) as! WkWebViewController
                
                let urlString : String = dict.object(forKey: "URL") as! String
                let url = NSURL(string: urlString)
                
                webViewObj.webViewUrl = url as URL?
                
                self.navigationController?.pushViewController(webViewObj, animated: true)
                //(webViewObj, animated: true, completion: nil)
                
            }
        }
    }
    
    
    @objc func openQuestionScreen(){
        self.otherScreenIsPresentOnTop = true
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.MyQuestions)
    }
    
    @objc func openBoostPurchaseScreen(notif : NSNotification) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
            
        }
        if let dict = notif.object as? NSDictionary{
            
            if (dict.object(forKey: "purchasePlanId") != nil){
                purchaseObj.autoSelectPlan(forPlanId: dict.object(forKey: "purchasePlanId") as! String)
            }
            
        }
        
        
    }
    
    @objc func openWooPlusPurchaseScreen(notif : NSNotification){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.purchaseShownOnViewController = self
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
        purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
            
        }
        
        if let dict = notif.object as? NSDictionary{
            
            if (dict.object(forKey: "purchasePlanId") != nil){
                purchaseObj.autoSelectPlan(forPlanId: dict.object(forKey: "purchasePlanId") as! String)
            }
            
        }
        
    }
    
    @objc func openWooGlobePurchaseScreen(notif : NSNotification){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
        if let dict = notif.object as? NSDictionary{
            
            if (dict.object(forKey: "purchasePlanId") != nil){
                purchaseObj.autoSelectPlan(forPlanId: dict.object(forKey: "purchasePlanId") as! String)
            }
            
        }
        
    }
    
    @objc func openInviteScreen(){
        
        self.otherScreenIsPresentOnTop = true
        
        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.ReferFriend);
    }
    
    //    func openCrushPurchaseSCreen(){
    //
    //        if !(Utilities.sharedUtility() as AnyObject).reachable() {
    //            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
    //            return
    //        }
    //
    //        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
    //        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
    //        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
    //        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
    //        purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
    //            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
    //        }
    //
    //    }
    
    @objc func openCrushPurchaseSCreen(notif : NSNotification){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
        purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            }
        }
        if let dict = notif.object as? NSDictionary{
            
            if (dict.object(forKey: "purchasePlanId") != nil){
                purchaseObj.autoSelectPlan(forPlanId: dict.object(forKey: "purchasePlanId") as! String)
            }
            
        }
        
    }
    
    
    
    @objc func openMatchbox(){
        
        self.otherScreenIsPresentOnTop = true
        
        if(WooScreenManager.sharedInstance.isDrawerOpen)
        {
            WooScreenManager.sharedInstance.isDrawerOpen = false
            WooScreenManager.sharedInstance.drawerController?.closeDrawer(animated: true, completion: { (isAnimated) in
                WooScreenManager.sharedInstance.drawerController!.rightDrawerViewController = nil
            })
        }
        //if alertcontrollers are open
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        
        if(currentNavigation.viewControllers.last?.presentedViewController is UIAlertController)
        {
            currentNavigation.viewControllers.last?.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        
        let window:UIWindow = UIApplication.shared.keyWindow!
        if (window.subviews.first!.subviews.first! as UIView) is PurchasePopup ||  (window.subviews.first!.subviews.first! as UIView) is DropOffPurchasePopup
            || (window.subviews.first!.subviews.first! as UIView) is VoiceCallIntroductionPopup || (window.subviews.first!.subviews.first! as UIView) is OutOfLikeView || (window.subviews.first!.subviews.first! as UIView) is PostMatchTipsView || (window.subviews.first!.subviews.first! as UIView) is NewMatchOverlayView || (window.subviews.first!.subviews.first! as UIView) is PostFeedbackContactView
        {
            (window.subviews.first!.subviews.first! as UIView).removeFromSuperview()
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhoneVerify"), object: nil))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhotoSelection"), object: nil))
        
        if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 2)
        {
            let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
            currentNavigation.popToRootViewController(animated: true)
            
            if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 1)
            {
                self.myProfileBackButtonPressed(UIButton())
                
                //                //DISCOVER TAB
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                //
                makeProfileDeckSmall()
            }
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
        }
        else
        {
            let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
            currentNavigation.popToRootViewController(animated: true)
            
        }
        
    }
    
    @objc func makeProfileDeckSmall()
    {
        self.view.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        self.areWeMovingUpOrLeftRight = ""
        let height = UIScreen.main.bounds.height
        self.deckViewHeightConstraint.constant = height - safeAreaBoth - topMarginForDeckView
        if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 10.0
            localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 10.0
            localProfileDeckViewObject.myProfileBottomViewTrailingConstraint.constant = 20
            localProfileDeckViewObject.myProfileBottomViewLeadingConstraint.constant = 20
            print("frame of buttons coming back = \(self.actionButtonBottomConstraint.constant)")
            localProfileDeckViewObject.aboutMeLabelContainerViewYValue = SCREEN_HEIGHT - self.actionButtonBottomConstraint.constant
            localProfileDeckViewObject.aboutMeLabelContainerViewHeightValue = 45.0
            localProfileDeckViewObject.crushMessageContainerViewYValue = SCREEN_HEIGHT - self.actionButtonBottomConstraint.constant
            localProfileDeckViewObject.crushMessageContainerViewWidthValue = 0
            localProfileDeckViewObject.crushMessageContainerViewHeightValue = 0
            localProfileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            
            
            self.view.layoutIfNeeded()
            
            if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                self.actionButtonsContainerView.transform = CGAffineTransform.identity
            }
            
            if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE  &&
                !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
                self.chatBotScreenForMyProfile.alpha = 1
            }
            
            if (self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView) != nil {
                //localProfileDeckViewObject.updateCommonalityTagsViewBasedOnThereAvailability(localProfileDeckViewObject.profileDetails)
            }
            if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
            else{
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
                    localProfileDeckViewObject.myProfileBottomView.alpha = 1
                }
            }
            
        },
                       completion: { _ in
                        
                        if(self.showActionButton)
                        {
                            self.nowPerformButtonActions(showActionButton: true)
                        }
                        if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == false{
                            
                            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                                
                                localProfileDeckViewObject.isHidden = false
                                
                            }
                            
                            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                                localProfileDeckViewObject.isHidden = false
                            }
                        }
        })
    }
    
    @objc func openMeSection(){
        self.otherScreenIsPresentOnTop = true
        
        DispatchQueue.main.async {
            if(WooScreenManager.sharedInstance.isDrawerOpen)
            {
                WooScreenManager.sharedInstance.isDrawerOpen = false
                WooScreenManager.sharedInstance.drawerController?.closeDrawer(animated: true, completion: { (isAnimated) in
                    WooScreenManager.sharedInstance.drawerController!.rightDrawerViewController = nil
                })
            }
            //if alertcontrollers are open
            let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
            
            if(currentNavigation.viewControllers.last?.presentedViewController is UIAlertController)
            {
                currentNavigation.viewControllers.last?.presentedViewController?.dismiss(animated: false, completion: nil)
            }
            
            let window:UIWindow = UIApplication.shared.keyWindow!
            if (window.subviews.first!.subviews.first! as UIView) is PurchasePopup ||  (window.subviews.first!.subviews.first! as UIView) is DropOffPurchasePopup
                || (window.subviews.first!.subviews.first! as UIView) is VoiceCallIntroductionPopup || (window.subviews.first!.subviews.first! as UIView) is OutOfLikeView || (window.subviews.first!.subviews.first! as UIView) is PostMatchTipsView || (window.subviews.first!.subviews.first! as UIView) is NewMatchOverlayView || (window.subviews.first!.subviews.first! as UIView) is PostFeedbackContactView
            {
                (window.subviews.first!.subviews.first! as UIView).removeFromSuperview()
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhoneVerify"), object: nil))
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhotoSelection"), object: nil))
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
            if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 0)
            {
                let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
                NSLog("openMeSection popToRootViewController")
                currentNavigation.popToRootViewController(animated: true)
                
                if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 1)
                {
                    //DISCOVER TAB
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
                    //DISCOVER TAB
                    DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
                    DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                    self.makeProfileDeckSmall()
                    self.myProfileBackButtonPressed(UIButton())
                    
                }
                else
                {
                    NSLog("openMeSection moveToTab 0")
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                }
            }
            else
            {
                let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
                currentNavigation.popToRootViewController(animated: true)
            }
        }
    }
    
    @objc func openDiscoverSettingsScreen(){
        self.otherScreenIsPresentOnTop = true
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        
        self.performSegue(withIdentifier: "DiscoverToSettingsSegue", sender:["Screen" : "DiscoverSetting","showPopUp" : false])
        
    }
    @objc func openDiscoverSettingsScreenFromNotification(){
        self.otherScreenIsPresentOnTop = true
        
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        
        let dict  = ["Screen" : "DiscoverSetting","showPopUp" : false] as NSDictionary
        
        let _ : NSString = dict.object(forKey: "Screen") as! NSString
        
        let showPop : Bool = dict.object(forKey: "showPopUp") as! Bool
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
        let myPreferencesVc:MyPreferencesViewController = (storyboard.instantiateViewController(withIdentifier: kMyPreferencesController) as? MyPreferencesViewController)!
        
        myPreferencesVc.showPostWooGlobePurchasePopUp = showPop
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        if (currentNavigation.viewControllers.last! is MyPreferencesViewController) == false
        {
            currentNavigation.pushViewController(myPreferencesVc, animated: true)
        }
        
    }
    
    func openYourStoryScreen(){
        self.otherScreenIsPresentOnTop = true
        
        self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let aboutMeViewController = mainStoryboard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        self.navigationController?.pushViewController(aboutMeViewController, animated: true)
    }
    
    func startWizardFlow(){
        self.otherScreenIsPresentOnTop = true
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "BrandCard_AnalyzeProfile")
        
        self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.AnalyzeProfile)
    }
    
    func startLinkedInFlow(){
        self.otherScreenIsPresentOnTop = true
        self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
        if self.tokenGeneratorObj == nil {
            self.tokenGeneratorObj = TokenGenerator()
        }
        self.tokenGeneratorObj!.delegate = self
        self.tokenGeneratorObj!.successSelectorForTokenGenerated = #selector(self.tokenGeneratedSuccessfullyWithData)
        self.tokenGeneratorObj!.failureSelectorForTokenGenerated = #selector(self.tokenGenerationFailedWithData)
        
        //  let nav: UINavigationController = UINavigationController(rootViewController: self.tokenGeneratorObj!)
        self.navigationController?.pushViewController(self.tokenGeneratorObj!, animated: true)
        //present(nav, animated: true, completion: nil)
    }
    
    
    fileprivate func handleErrorForResponseCode(_ responseCode: Int) {
        switch responseCode {
        case 401:
            showSnackBar(NSLocalizedString("Something unexpected has happened. Please login again", comment: ""))
            FBSDKLogin.sharedManager().getReadPermissions(FBSDKLogin.sharedManager().fetchReadPermissions(), onParentViewController: self, with: { (fetchedNewPermissionTokedSuccessfully) in
                if (fetchedNewPermissionTokedSuccessfully == true){
                    //make sync call again
                }
                else{
                    
                    FBSession.active().clearJSONCache()
                    FBSession.active().close()
                    FBSession.active().closeAndClearTokenInformation()
                    FBSession.setActive(nil)
                    FBSDKLogin.sharedManager().logOutUserFromFacebook()
                    
                    UserDefaults.standard.removeObject(forKey: "FBAccessTokenInformationKey")
                    UserDefaults.standard.removeObject(forKey: kIsLoginProcessCompleted)
                    UserDefaults.standard.removeObject(forKey: kWooUserId)
                    UserDefaults.standard.synchronize()
                    self.otherScreenIsPresentOnTop = true
                    let storyboard = UIStoryboard(name: "onboarding", bundle: Bundle.main)
                    
                    let loginViewControllerObj = storyboard.instantiateViewController(withIdentifier: kLoginViewControllerID) as! LoginViewController
                    loginViewControllerObj.isAuthenticationFailed = true
                    loginViewControllerObj.authenticationController = self
                    self.present(loginViewControllerObj, animated: true, completion: {
                        WooScreenManager.sharedInstance.loadLoginView()
                    })
                }
            })
            break
        case 404, 408, 405, 500, 203, 400:      // Not Found,
            //Request Timeout,
            //Method Not Allowed,
            //Internal Server Error
            //Method Not Allowed
            //Method Not Allowed
            showSnackBar(NSLocalizedString("Woo is experiencing heavy traffic.", comment: ""))
            break;
        default:
            break
        }
    }
    
    //MARK: LinkedIn delegate functions
    @objc func tokenGeneratedSuccessfullyWithData(_ tokenData: AnyObject) {
        
        let data: Data = (tokenData as! String).data(using: String.Encoding.utf8)!
        let json: AnyObject = try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        var tokenDictionary: [AnyHashable: Any] = (json as! [AnyHashable: Any])
        let access: String? = (tokenDictionary["access_token"] as! String)
        print("token >>> \(access ?? "")")
        
        //        tokenGeneratorObj!.dismiss(animated: true, completion: {() -> Void in
        if access != nil {
            self.showWooLoader(wooLoaderStyle: false)
            FBLinkedInAPIClass.updateLinkInSyncData(withAccessToken: access, andCompletionBlock: { (success, _response, errorCode) in
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "EditProfileScreen", withEventName: "3-EditProfile.EditProfileScreen.EP_SyncLinkedIn")
                
                
                self.hideWooLoader()
                if success {
                    if let response : NSDictionary = _response as? NSDictionary{
                        DiscoverProfileCollection.sharedInstance.myProfileData?.updateData(response)
                        self.openEditProfileOnlyForWorkEducation()
                    }
                    else{
                        self.handleErrorForResponseCode(Int(errorCode))
                    }
                }
            })
        }
        // })
    }
    
    @objc func tokenGenerationFailedWithData(_ failureData: [AnyHashable: Any]) {
        print("Failure data \(failureData)")
        UserDefaults.standard.set(false, forKey: kIsLinkedInVerified)
        UserDefaults.standard.synchronize()
    }
    
    func openEthnicityScreen(){
        self.otherScreenIsPresentOnTop = true
        let optionScreen = EthnicitySelectionViewController.loadNib()
        optionScreen.viewControllerType = EthnicityClassType.TYPE_ETHNICITY
        let ethnicityArrayWithoutdoesntMatter = NSMutableArray.init(array: NSArray(contentsOfFile: Bundle.main.path(forResource: "Ethnicity", ofType:"plist")!)!)
        ethnicityArrayWithoutdoesntMatter.removeLastObject()
        optionScreen.mainDataSource = ethnicityArrayWithoutdoesntMatter as NSArray
        optionScreen.maxmimumSelection = 2
        optionScreen.selectionHandler = { (selectedData) in
            
            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EthnicityBrandCard_SelectTag")
            
            if selectedData.count > 0 {
                for item in selectedData {
                    let model : ProfessionModel = ProfessionModel()
                    model.name = "\(item["name"]!)"
                    model.tagId = "\(item["tagId"]!)"
                    self.selectionCardSelectedValueArray.append(model)
                }
                
            }
            self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
        }
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //(optionScreen, animated: true, completion: nil)
    }
    
    func openReligionScreen(){
        self.otherScreenIsPresentOnTop = true
        let optionScreen = OptionSelectionViewController.loadNib("Religion")
        optionScreen.dataSourceArr = (DiscoverProfileCollection.sharedInstance.myProfileData?.religion)!
        optionScreen.showSearchBar = false
        optionScreen.selectionHandler = { (tagId) in
            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "ReligionBrandCard_SelectTag")
            
            if !tagId .isEqual("") {
                for religion in (DiscoverProfileCollection.sharedInstance.myProfileData?.religion)! {
                    if tagId == religion.tagId {
                        self.selectionCardSelectedValueArray.append(religion)
                        break
                    }
                }
            }
            self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
        }
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //(optionScreen, animated: true, completion: nil)
    }
    
    func openEditTagsScreen(array:[ProfessionModel]){
        /*
         let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
         let oTagScreenViewController =
         storyboard.instantiateViewController(withIdentifier: "TagScreenViewControllerID")
         as? TagScreenViewController
         oTagScreenViewController?.editProfileTagArray = []
         for item in array {
         oTagScreenViewController?.editProfileTagArray.add(item.tagModel() as Any)
         }
         oTagScreenViewController?.isPushedFromDiscover = true
         //                    oTagScreenViewController?.isPresentedForTagSelectionCard = true
         oTagScreenViewController?.removeBubbleViewsWhenViewDisappears = true
         oTagScreenViewController?.blockHandler = { (tagsArray) in
         
         DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
         DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
         
         self.selectionCardSelectedValueArray = []
         for item in tagsArray! {
         let model : ProfessionModel = ProfessionModel()
         model.name = "\((item as! NSDictionary)["name"]!)"
         model.tagId = "\((item as! NSDictionary)["tagId"]!)"
         self.selectionCardSelectedValueArray.append(model)
         }
         self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
         }
         */
        
        self.otherScreenIsPresentOnTop = true
        
        let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
        wizardTagsVC.isUsedOutOfWizard = true
        wizardTagsVC.selectedTagsHandler = {(selectedTagsarray) in
            DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
            DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
            
            self.selectionCardSelectedValueArray = []
            for item in selectedTagsarray {
                let model : ProfessionModel = ProfessionModel()
                model.name = "\((item as! NSDictionary)["name"]!)"
                model.tagId = "\((item as! NSDictionary)["tagId"]!)"
                self.selectionCardSelectedValueArray.append(model)
            }
            self.handleRightSwipeForIndex(self.deckView.currentCardIndex - 1)
        }
        self.navigationController?.pushViewController(wizardTagsVC, animated: true)
    }
    
    func openDiscoverSettingsScreenPostWooGlobePurchase(){
        self.otherScreenIsPresentOnTop = true
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        
        let isModalPresent = WooScreenManager.sharedInstance.oHomeViewController?.isModalPresent()
        
        if (isModalPresent == true)
        {
            WooScreenManager.sharedInstance.oHomeViewController?.dismiss(animated: false, completion:
                {
                    self.performSegue(withIdentifier: "DiscoverToSettingsSegue", sender:["Screen" : "DiscoverSetting", "showPopUp" : true])
            })
        }
        else{
            self.performSegue(withIdentifier: "DiscoverToSettingsSegue", sender:["Screen" : "DiscoverSetting", "showPopUp" : true])
        }
    }
    
    
    @objc func openAppSettingsScreen(){
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
        
        let dict  = ["Screen" : "AppSetting","showPopUp" : false] as NSDictionary
        
        let _ : NSString = dict.object(forKey: "Screen") as! NSString
        
        let showPop : Bool = dict.object(forKey: "showPopUp") as! Bool
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
        let myPreferencesVc:MyPreferencesViewController = (storyboard.instantiateViewController(withIdentifier: kMyPreferencesController) as? MyPreferencesViewController)!
        
        myPreferencesVc.showPostWooGlobePurchasePopUp = showPop
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        if (currentNavigation.viewControllers.last! is MyPreferencesViewController) == false
        {
            currentNavigation.pushViewController(myPreferencesVc, animated: true)
        }
        
    }
    
    @objc func makePaginationCall(){
        
        print("currentIndexForPaginationCall = \(self.deckView.currentCardIndex)")
        if self.recommendationArray?.collectionMode != CollectionMode.my_PROFILE {
            
            let cardNumber:Int = self.deckView.currentCardIndex/10
            if self.deckView.currentCardIndex == 5 + 10*cardNumber{
                
                //                if self.isLocationChangedAfterLaunch {
                //                    self.isLocationChangedAfterLaunch = false;
                //                    showWooLoader(wooLoaderStyle: true)
                //                    nowMakeDiscoverCallAsOtherCallsAreDone()
                //                    return;
                //                }
                
                if DiscoverProfileCollection.sharedInstance.paginationIndex != "" && DiscoverProfileCollection.sharedInstance.paginationToken != "" {
                    print("pagination call made")
                    if UserDefaults.standard.bool(forKey: kLocationNeedsToBeUpdatedOnServer) {
                        
                        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: true, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                            
                            if success{
                                self.isPaginated = true
                                //DiscoverProfileCollection.sharedInstance.removeItemsFromTop(self.deckView.currentCardIndex)
                                if self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing == true{
                                    self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = false
                                    print("pagination through discover")
                                    self.reloadDeckView()
                                }
                                else{
                                    self.deckView.countOfCards = (self.recommendationArray?.count())!
                                }
                            }
                            else{
                                if statusCode == 401 {
                                    WooScreenManager.sharedInstance.loadLoginView()
                                    (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp(nil)
                                }
                                self.hideWooLoader()
                            }
                        })
                        
                        //                        DiscoverAPIClass.fetchDiscoverData(fromServer: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                        //                            if success{
                        //                                self.isPaginated = true
                        //                                if self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing == true{
                        //                                    self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = false
                        //                                    print("pagination through discover")
                        //                                    self.reloadDeckView()
                        //                                }
                        //                            }
                        //                            else{
                        //                                if statusCode == 401 {
                        //                                    WooScreenManager.sharedInstance.loadLoginView()
                        //                                    (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp()
                        //                                }
                        //                                self.hideWooLoader()
                        //                            }
                        //                        })
                    }
                    else{
                        
                        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: true, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                            if success{
                                self.isPaginated = true
                                //DiscoverProfileCollection.sharedInstance.removeItemsFromTop(self.deckView.currentCardIndex)
                                if self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing == true{
                                    self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = false
                                    print("pagination through discover")
                                    self.reloadDeckView()
                                }
                                else{
                                    self.deckView.countOfCards = (self.recommendationArray?.count())!
                                }
                            }
                        })
                        
                        
                        //                        DiscoverAPIClass.fetchDiscoverData(fromServer: true, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                        //                            if success{
                        //                                self.isPaginated = true
                        //                                if self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing == true{
                        //                                    self.discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = false
                        //                                    print("pagination through discover")
                        //                                    self.reloadDeckView()
                        //                                }
                        //                            }
                        //                        })
                    }
                }
            }
        }
        
    }
    
    
    
    @objc func showPurchaseScreen(){
        return
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let purchasePopupObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)!.first as! PurchasePopup
        
        purchasePopupObj.loadPopupOnWindowWith(productToBePurchased: .boost)
        
    }
    
    
    //MARK: HomeTab bar changed handler
    func didTabViewChanged(_ tupleValue:(oldValue: Int, newValue: Int)) {
        currentSelectedTab = tupleValue.newValue
        
        if (UserDefaults.standard.bool(forKey: kUserAlreadyRegistered) == false) {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kInternetConnectionStatusChanged), object: nil)
        }
        
        if tupleValue.newValue == 1 {
            otherScreenIsPresentOnTop = false
            colorTheStatusBar(withColor: NavBarStyle.discover.color())
            
            if(isDiscoverPreferencesPopupVisible)
            {
                let window:UIWindow = UIApplication.shared.keyWindow!
                
                //checkRecursively for OutOfLikes
                WooScreenManager.sharedInstance.oHomeViewController?.checkRecursively(window.subviews.last!, kindOfView: DiscoverPreferencesOverlay.self)
                
            }
            //            [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
            
            if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == false {
                self.passButton.isUserInteractionEnabled = true
                self.likeButton.isUserInteractionEnabled = true
                self.crushButton.isUserInteractionEnabled = true
            }
            else{
                DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                
                /*
                 if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                 
                 localProfileDeckViewObject.isHidden = true
                 }
                 
                 if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                 localProfileDeckViewObject.isHidden = true
                 }
                 */
            }
            
            //self.perform(#selector(showRatingPopup), with: nil, afterDelay: 1.5)
            self.perform(#selector(self.showPurchaseScreen), with: nil, afterDelay: 1.5)
            
            print("I am in DiscoverViewController")
            
            areWeMovingUpOrLeftRight = ""
            if recommendationArray?.collectionMode == .my_PROFILE {
                self.navBar?.switchHolderView.isHidden = true
                let height = UIScreen.main.bounds.height
                self.deckViewHeightConstraint.constant = height - safeAreaBoth - topMarginForDeckView
                // Srwve Event
                
                noInternetScreen.isHidden = true
                DiscoverProfileCollection.sharedInstance.removeProfileItemsFromTop(deckView.currentCardIndex)
                
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_MyProfile", withEventName: "3-MeSection.Me_MyProfile.MMP_Landing")
                
                navBar!.backButton.isHidden = false
                navBar?.titleLabel.text = NSLocalizedString("My Profile", comment: "")
                navBar?.backButton.addTarget(self,
                                             action: #selector(DiscoverViewController.myProfileBackButtonPressed(_:)),
                                             for: UIControl.Event.touchUpInside)
                
                
                navBar?.setStyle(NavBarStyle.me, animated: true)
                navBar?.isHidden = false
                WooScreenManager.sharedInstance.oHomeViewController?.hideTabBar(true)
            self.recommendationArray?.switchCollectionMode(CollectionMode.my_PROFILE)
                if let localActionButtonContainerView = self.actionButtonsContainerView{
                    localActionButtonContainerView.isHidden = true
                }
                
                showWooLoader(wooLoaderStyle: false)
                deckView.isHidden = true
                
                if self.recommendationArray?.count() > 0{
                    
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        self.reloadDeckView()
                    })
                }
            }
            else{
                
                self.navBar?.switchHolderView.isHidden = false
                self.setWooGlobeNavValue()
                
                navBar?.setStyle(NavBarStyle.discover, animated: false)
                navBar!.backButton.isHidden = true
                navBar?.titleLabel.text = NSLocalizedString("Discover", comment: "Discover")
                navBar!.backButton.removeTarget(self,
                                                action: #selector(DiscoverViewController.myProfileBackButtonPressed(_:)),
                                                for: UIControl.Event.touchUpInside)
                
                /* Removed Tutorial
                 if UserDefaults.standard.bool(forKey: kIsTutorialShown) {
                 WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                 }
                 */
                
                if DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded == true {
                    deckView.isHidden = true
                    DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = false
                    if self.recommendationArray?.count() > 0 || DiscoverEmptyManager.sharedInstance.count()>0 {
                        self.reloadDeckView()
                    }
                    else{
                        // self.perform(#selector(showWooLoader), with: nil, afterDelay: 0.5)
                        showWooLoader(wooLoaderStyle: true)
                        if let localActionButtonContainerView = self.actionButtonsContainerView{
                            localActionButtonContainerView.isHidden = true
                        }
                        
                        fetchDiscoverData(false)
                        
                    }
                }
                
            }
            showLocalNotificationforSuccessfullImageUploading()
            
        }
    }
}

//MARK: KolodaViewDelegate
extension DiscoverViewController: KolodaViewDelegate {
    
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            //            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return [.Up]
        }
        
        if (recommendationArray?.objectAtIndex(Int(index)) is DiscoverEmptyModel) {
            let discoverEmptyModel = recommendationArray?.objectAtIndex(Int(index)) as! DiscoverEmptyModel
            if discoverEmptyModel.subCardType == .DISCOVER_EMPTY_DEFAULT {
                return []
            }
            else{
                return [.Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
            }
        }
        else if (recommendationArray?.objectAtIndex(Int(index)) is NewUserNoPicCardModel){
            return [.Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
        }
        else if (recommendationArray?.objectAtIndex(Int(index)) is SelectionCardModel){
            return [.Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
        }
        else{
            
            if areWeMovingUpOrLeftRight == "UP" {
                return [.Up]
            }
            else if areWeMovingUpOrLeftRight == "LEFTRIGHT"{
                return [.Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
            }
            else{
                if DiscoverProfileCollection.sharedInstance.collectionMode == .my_PROFILE && UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
                    return [.Up]
                }
                else{
                    return [.Left, .Right, .Up, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
                }
            }
            
        }
    }
    
    func koloda(_ koloda: KolodaView, shouldDragCardAtIndex index: UInt ) -> Bool{
        
        if disableCardInteraction {
            return false
        }
        else{
            return true
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        self.showOrHideActionButtonsContainerView(false)
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            noInternetScreen.isHidden = false
            deckView.isHidden = true
        }
        else{
            if DiscoverProfileCollection.sharedInstance.isPaginationTokenExpired == true {
                deckView.isHidden = true
                showWooLoader(wooLoaderStyle: true)
                DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                self.recommendationArray?.cardCollection.get().removeAllObjects()
                DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                
                recommendationArray?.switchCollectionMode(CollectionMode.discover)
                fetchDiscoverData(false)
            }
            else{
                if DiscoverProfileCollection.sharedInstance.collectionMode != .my_PROFILE {
                    DiscoverProfileCollection.sharedInstance.removeItemsFromTop(koloda.currentCardIndex)
                    
                    if DiscoverProfileCollection.sharedInstance.collectionMode == .discover {
                        if recommendationArray?.count()>0 {
                            self.isPaginated = true
                            // self.deckView.isHidden = true
                            //self.reloadDeckView()
                            self.reloadDeckAnimated()
                        }
                        else{
                            if DiscoverEmptyManager.sharedInstance.count()>0 {
                                self.isPaginated = true
                                recommendationArray?.switchCollectionMode(CollectionMode.discover_EMPTY)
                                //self.reloadDeckView()
                                self.perform(#selector(resettingKolodaViewTogetPerfectFrame), with: nil, afterDelay: 0.0)
                                
                            }
                            else{
                                if DiscoverProfileCollection.sharedInstance.paginationIndex != "" && DiscoverProfileCollection.sharedInstance.paginationToken != "" {
                                    recommendationArray?.switchCollectionMode(CollectionMode.discover)
                                    showWooLoader(wooLoaderStyle: true)
                                    self.actionButtonsContainerView.isHidden = true
                                    print("discoverCardsAreEmptyNowAndPaginationCallIsOnGoing")
                                    discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = true
                                    
                                }
                            }
                        }
                    }
                    else{
                        if DiscoverEmptyManager.sharedInstance.count()>0 {
                            self.isPaginated = true
                            recommendationArray?.switchCollectionMode(CollectionMode.discover_EMPTY)
                            self.perform(#selector(resettingKolodaViewTogetPerfectFrame), with: nil, afterDelay: 0.0)
                            
                            //self.reloadDeckView()
                        }
                        else{
                            if DiscoverProfileCollection.sharedInstance.paginationIndex != "" && DiscoverProfileCollection.sharedInstance.paginationToken != "" {
                                recommendationArray?.switchCollectionMode(CollectionMode.discover)
                                showWooLoader(wooLoaderStyle: true)
                                self.actionButtonsContainerView.isHidden = true
                                print("discoverCardsAreEmptyNowAndPaginationCallIsOnGoing")
                                discoverCardsAreEmptyNowAndPaginationCallIsOnGoing = true
                                
                            }
                        }
                    }
                }
                else{
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "OnBoarding_MyProfile_RightSwipe")
                    checkIfMyProfileIsActive()
                    recommendationArray?.switchCollectionMode(CollectionMode.discover)
                }
            }
        }
    }
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool{
        return true
    }
    
    
    func koloda(_ koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        userHasChoosedToMoveMyProfileUp = true
        if self.recommendationArray?.collectionMode == .my_PROFILE {
            if (self.recommendationArray?.count())! <= 0 {
                self.recommendationArray?.switchCollectionMode(.my_PROFILE)
            }
        }
        if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
            selectedCommonality = ""
            currentUserData = userDetails
            makeTheProfileDeckBig()
        }
        else if  let cardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? BrandCardModel{
            selectedCommonality = ""
            currentUserData = cardDetails
            if let urlToOpen = cardDetails.actionUrl {
                let urlString = urlToOpen.absoluteString
                if urlString.contains("verifyPhoneNumber") {
                    return
                }
            }
            
            makeTheBrandDeckBig()
        }
        else if  (self.recommendationArray?.objectAtIndex(Int(index)) as? ReviewPhotoCardModel) != nil{
            //            editProfileOpenedFromReviewPhotoCard = true
            //            shouldNotOpenProfileDetail = true
            //            openEditProfile(UIButton())
            self.deckView.swipe(.Right)
        }
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        
        if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
            userDetails.isProfileSeen = true
        }
        else if  let cardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? BrandCardModel{
            cardDetails.isBrandCardSeen = true
        }
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(Int(index+1)) as? ProfileDeckView {
            
            localProfileDeckViewObject.updateAlphaForOverlayView(0)
            
        }
        else if let localBrandCardDeckObject = koloda.viewForCardAtIndex(Int(index+1)) as? BrandCardDeck{
            localBrandCardDeckObject.updateAlphaForOverlayView(0)
        }
        else if let localDiscoverEmptyDeckObject = koloda.viewForCardAtIndex(Int(index+1)) as? DiscoverEmptyDeck{
            localDiscoverEmptyDeckObject.updateAlphaForOverlayView(0)
        }
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(Int(index+2)) as? ProfileDeckView {
            
            localProfileDeckViewObject.updateAlphaForOverlayView(1)
            
        }
        else if let localBrandCardDeckObject = koloda.viewForCardAtIndex(Int(index+2)) as? BrandCardDeck{
            localBrandCardDeckObject.updateAlphaForOverlayView(0)
        }
        else if let localDiscoverEmptyDeckObject = koloda.viewForCardAtIndex(Int(index+3)) as? DiscoverEmptyDeck{
            localDiscoverEmptyDeckObject.updateAlphaForOverlayView(0)
        }
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(Int(index+3)) as? ProfileDeckView {
            
            localProfileDeckViewObject.updateAlphaForOverlayView(2)
            
        }
        else if let localBrandCardDeckObject = koloda.viewForCardAtIndex(Int(index+3)) as? BrandCardDeck{
            localBrandCardDeckObject.updateAlphaForOverlayView(0)
        }
        else if let localDiscoverEmptyDeckObject = koloda.viewForCardAtIndex(Int(index+3)) as? DiscoverEmptyDeck{
            localDiscoverEmptyDeckObject.updateAlphaForOverlayView(0)
        }
        
        if direction == .Right || direction == .BottomRight || direction == .TopRight {
            //Make Like Call
            if  (self.recommendationArray?.objectAtIndex(Int(index)) as? ReviewPhotoCardModel) != nil{
                editProfileOpenedFromReviewPhotoCard = true
                shouldNotOpenProfileDetail = true
                openEditProfile(UIButton())
            }
            
            if self.recommendationArray?.count()>0 {
                if let brandDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? BrandCardModel {
                    
                    if let urlToOpen = brandDetails.actionUrl {
                        
                        let urlString = urlToOpen.absoluteString
                        
                        if urlString.contains("verifyPhoneNumber"){
                            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "PhoneBrandCard_Like")
                        }
                    }
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_LikeByTapOrSwipe")
                    
                    
                    if brandDetails.subCardType == .GET_BOOSTED{
                        
                        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_BoostRightSwipe")
                        
                    }else if brandDetails.subCardType == .SEND_CRUSH{
                        
                        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_CrushRightSwipe")
                        
                    }else if brandDetails.subCardType == .WOOPLUS{
                        
                        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_WooPlusRightSwipe")
                        
                    }
                    
                    
                    
                    BrandCardAPI.updateBrandCardPassStatus(onServer: "CLICK", and: brandDetails.cardId)
                    if let urlToOpen = brandDetails.actionUrl {
                        
                        let urlString = urlToOpen.absoluteString
                        
                        if urlString.contains("wooapp://") {
                            
                            DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                            WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromSideMenu = false
                            WooScreenManager.sharedInstance.oHomeViewController?.phoneVerifiedAccessTokenHandler = {(response:String, isViaTrueCaller: Bool) in
                                
                                if (isViaTrueCaller){
                                    self.handlePhoneVerification(statusCode: NSInteger(response)!)
                                }
                                else{
                                    PhoneVerifyApiClass.verifyPhone(forAccessToken: response, request: false, trueCallerParameters: nil, withCompletionBlock: { (success, response, statusCode) in
                                        self.handlePhoneVerification(statusCode: NSInteger(statusCode))
                                    })
                                }
                                
                            }
                            WooScreenManager.sharedInstance.openDeepLinkedScreen(urlString)
                            WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                                if crushPurchased{
                                    if brandDetails.subCardType == .WOOGLOBE {
                                        if crushPurchased == true {
                                            WooGlobeModel.sharedInstance().wooGlobleOption = crushPurchased
                                            WooGlobeModel.sharedInstance().isExpired = false
                                            WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                            WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                            WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                            if WooGlobeModel.sharedInstance().religionArray.count < 1 {
                                                WooGlobeModel.sharedInstance().religionOption = false
                                            }
                                            
                                            if WooGlobeModel.sharedInstance().ethnicityArray.count < 1 {
                                                WooGlobeModel.sharedInstance().ethnicityOption = false
                                            }
                                            
                                        }
                                        self.openDiscoverSettingsScreenPostWooGlobePurchase()
                                    }
                                    else{
                                        self.showWooLoader(wooLoaderStyle: true)
                                        self.fetchDiscoverData(false)
                                    }
                                    
                                }
                            }
                            
                        }
                        else{
                            if UIApplication.shared.canOpenURL(urlToOpen) {
                                //                       UIApplication.sharedApplication().openURL(urlToOpen)
                                
                                
                                
                                // Open url in internal browser
                                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                                DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
                                let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                                
                                let myWebViewViewController:WkWebViewController = (storyboard.instantiateViewController(withIdentifier: kMyWebViewController) as? WkWebViewController)!
                                myWebViewViewController.isFrmBrandCardSwipe = true
                                myWebViewViewController.navTitle = "Woo Promotions"
                                myWebViewViewController.webViewUrl = urlToOpen
                                WooScreenManager.sharedInstance.oHomeViewController!.present(myWebViewViewController, animated: true, completion: nil)
                                
                            }
                        }
                    }
                    
                }
                else if let selectionCardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? SelectionCardModel{
                    switch selectionCardDetails.subCardType {
                    case .ETHNICITY:
                        //Open Ethnicity
                        if self.selectionCardSelectedValueArray.count != selectionCardDetails.maxSelection {
                            self.openEthnicityScreen()
                        }
                        else{
                            self.handleRightSwipeForIndex(Int(index))
                        }
                        break
                    case .RELIGION:
                        //Open Religion
                        if self.selectionCardSelectedValueArray.count != selectionCardDetails.maxSelection {
                            self.openReligionScreen()
                        }
                        else{
                            self.handleRightSwipeForIndex(Int(index))
                        }
                        break
                    case .TAGS:
                        let tagsArray:[ProfessionModel] = []
                        if self.selectionCardSelectedValueArray.count != selectionCardDetails.maxSelection {
                            self.openEditTagsScreen(array: tagsArray)
                        }
                        else{
                            self.handleRightSwipeForIndex(Int(index))
                        }
                        break
                    case .PERSONAL_QUOTE:
                        //Open your story
                        self.openYourStoryScreen()
                        break
                    case .WORK_EDUCATION:
                        //Open work and education
                        self.startLinkedInFlow()
                        break
                    case .ANALYZE_PROFILE:
                        //Start wizard flow
                        self.startWizardFlow()
                        break
                    default:
                        // Do Nothing
                        break
                    }
                }
                else{
                    self.handleRightSwipeForIndex(Int(index))
                }
            }
            
        }
        else if direction == .Left || direction == .BottomLeft || direction == .TopLeft{
            //Make Pass Call
            self.handleLeftForIndex(Int(index))
        }
        
        makePaginationCall()
    }
    
    func handlePhoneVerification(statusCode: NSInteger){
        if statusCode == 200{
            self.showSnackBar("Phone number verified")
        }
        else if statusCode == 404{
            _ = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: false, withController: self)
        }
        else if statusCode == 400{
            _ = AlertController.showAlert(withTitle: "", andMessage: "           We are facing some technical issue. Please retry after some time.", needHandler: false, withController: self)
            
        }
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, inDirection direction: SwipeResultDirection, withGesture gestureRecognizerState:UIPanGestureRecognizer) {
        
        if gestureRecognizerState.state == .began{
            if ((koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView) == nil){
                isNotAProfileCard = true
            }
            else{
                isNotAProfileCard = false
            }
        }
        
        if ((koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView) != nil) {
            if gestureRecognizerState.state == .ended{
                if isNotAProfileCard == false{
                    if direction == .Right || direction == .BottomRight || direction == .TopRight{
                        if UserDefaults.standard.bool(forKey: "firstTimeLiked") == false{
                            koloda.resetPositionOfCurrentCard()
                            if self.recommendationArray?.collectionMode == CollectionMode.discover{
                                self.showActionTutorialForType(.Like)
                                return
                            }
                        }
                    }
                    else if direction == .Left || direction == .BottomLeft || direction == .TopLeft{
                        if UserDefaults.standard.bool(forKey: "firstTimeDisliked") == false{
                            koloda.resetPositionOfCurrentCard()
                            if self.recommendationArray?.collectionMode == CollectionMode.discover{
                                self.showActionTutorialForType(.Dislike)
                                return
                            }
                        }
                    }
                }
            }
        }
        
        
        deckView.crushIsBeingSent = false
        
        if ((koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView) != nil) {
            if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
                if checkIfUserWillSeeOutOfLikeAlert() {
                    if gestureRecognizerState.state == .began || gestureRecognizerState.state == .ended {
                        if direction == .Right || direction == .BottomRight || direction == .TopRight{
                            self.showOutOfLikeAlert()
                            if let localProfileDeckViewObject = koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView {
                                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush:  false,animationEnded: true)
                            }
                            return
                            
                        }
                    }
                    //snack bar appearing
                }
            }
        }
        
        koloda.crushIsBeingSent = false
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView {
            
            if gestureRecognizerState.state == .began {
                print("began")
                print("Here \(direction) and \(finishPercentage)")
                if (direction == .Up) {
                    koloda.needToStopTranslationAndRotationForKoloda = true
                    areWeMovingUpOrLeftRight = "UP"
                }
                else{
                    koloda.needToStopTranslationAndRotationForKoloda = false
                    areWeMovingUpOrLeftRight = "LEFTRIGHT"
                }
            }
                
            else if gestureRecognizerState.state == .ended {
                areWeMovingUpOrLeftRight = ""
                cardIsMovingUpwards = false
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(direction, isCrush: false, animationEnded: true)
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                }
            }
            else{
                if direction == .Up {
                    if let userDetails =  self.recommendationArray?.objectAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileCardModel{
                        if cardIsMovingUpwards == false {
                            selectedCommonality = ""
                            currentUserData = userDetails
                            userHasChoosedToMoveMyProfileUp = true
                            makeTheProfileDeckBig()
                            cardIsMovingUpwards = true
                        }
                    }
                }
            }
            
        }
            
        else if let localProfileDeckViewObject = koloda.viewForCardAtIndex(koloda.currentCardIndex) as? BrandCardDeck {
            
            if gestureRecognizerState.state == .began {
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(direction, animationEnded: false)
                print("began")
                print("Here \(direction) and \(finishPercentage)")
                if direction == .Up {
                    koloda.needToStopTranslationAndRotationForKoloda = true
                    areWeMovingUpOrLeftRight = "UP"
                }
                else{
                    koloda.needToStopTranslationAndRotationForKoloda = false
                    areWeMovingUpOrLeftRight = "LEFTRIGHT"
                }
            }
                
            else if gestureRecognizerState.state == .ended {
                areWeMovingUpOrLeftRight = ""
                cardIsMovingUpwards = false
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(direction, animationEnded: true)
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                }
            }
            else{
                if direction == .Up {
                    if  let cardDetails =  self.recommendationArray?.objectAtIndex(Int(self.deckView.currentCardIndex)) as? BrandCardModel{
                        if cardIsMovingUpwards == false {
                            selectedCommonality = ""
                            currentUserData = cardDetails
                            userHasChoosedToMoveBrandCardUp = true
                            if let urlToOpen = cardDetails.actionUrl {
                                let urlString = urlToOpen.absoluteString
                                if urlString.contains("verifyPhoneNumber") {
                                    return
                                }
                            }
                            makeTheBrandDeckBig()
                            cardIsMovingUpwards = true
                        }
                    }
                }
            }
            
        }
        
    }
    
}

//MARK: KolodaViewDataSource
extension DiscoverViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> UInt {
        
        if DiscoverProfileCollection.sharedInstance.collectionMode == .my_PROFILE {
            return 1
        }
        else{
            if (self.recommendationArray != nil && self.recommendationArray?.count() > 0) {
                
                return UInt((self.recommendationArray?.count())!)
            }
            else{
                return 0
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAtIndex index: UInt){
        print("cureenssfffff =  \(self.deckView.currentCardIndex)")
        
        if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE
        {
            if self.deckView.currentCardIndex == 3
            {
                // show tutorial once
                if (UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) && UserDefaults.standard.bool(forKey: "hasSeenTutorialForPreferences") == false)
                {
                    addGrowthAnimationForSettingsButton()
                    showDiscoverOverlayPopup(false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        // remove animation after it has occured
                        self.navBar?.settingsButton.layer.removeAllAnimations()
                    }
                }
            }
            else if self.deckView.currentCardIndex == 10
            {
                // show tutorial once
                if (UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) && UserDefaults.standard.bool(forKey: "hasSeenIntroductionForSearchTags") == false)
                {
                    showDiscoverOverlayPopup(true)
                }
            }
        }
        checkForLikeLimit()
        
        if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == true {
            return
        }
        
        if self.recommendationArray?.count()>0 {
            if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
                if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.discover {
                    if self.isPaginated == true {
                        showOrHideActionButtonsContainerView(true)
                    }
                    else{
                        self.perform(#selector(showActionButtonsWithDelay), with: nil, afterDelay: 0.1)
                    }
                    
                    if userDetails.crushText.length > 0 {
                        crushButton.isSelected = true
                    }
                    else{
                        crushButton.isSelected = false
                    }
                }
            }
            else{
                showOrHideActionButtonsContainerView(false)
            }
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.2)
        }
        
        if (recommendationArray?.objectAtIndex(Int(index)) is DiscoverEmptyModel) {
            showOrHideActionButtonsContainerView(false)
            let discoverEmptyModel = recommendationArray?.objectAtIndex(koloda.currentCardIndex) as! DiscoverEmptyModel
            if discoverEmptyModel.subCardType == .DISCOVER_EMPTY_DEFAULT {
                disableCardInteraction = true
            }
            else{
                disableCardInteraction = false
            }
        }
        else{
            disableCardInteraction = false
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        
        print("my profile can come")
        if DiscoverProfileCollection.sharedInstance.collectionMode != CollectionMode.my_PROFILE {
            if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == false {
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                    
                    localProfileDeckViewObject.isHidden = false
                }
                
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                    localProfileDeckViewObject.isHidden = false
                }
            }
            else{
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                    
                    localProfileDeckViewObject.isHidden = true
                }
                
                if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                    localProfileDeckViewObject.isHidden = true
                }
            }
        }
        
        if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
            print("This is profile")
            let profileDeckViewObject : ProfileDeckView = ProfileDeckView.init(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
            profileDeckViewObject.delegate = self
            profileDeckViewObject.crushMessageContainerViewYValue = SCREEN_HEIGHT - actionButtonBottomConstraint.constant
            
            print("frame of buttons = \(actionButtonBottomConstraint.constant)")
            profileDeckViewObject.aboutMeLabelContainerViewYValue = SCREEN_HEIGHT - actionButtonBottomConstraint.constant
            
            profileDeckViewObject.animateViewComponent = true
            
            if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                profileDeckViewObject.profileDetails = DiscoverProfileCollection.sharedInstance.myProfileData
                profileDeckViewObject.setDataForProfileView(true)
                print("userdetails=\(userDetails.firstName)")
            }
            else{
                profileDeckViewObject.profileDetails = ProfileCardModel(cardModel: userDetails)
                profileDeckViewObject.setDataForProfileView(false)
            }
            
            profileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
            profileDeckViewObject.updateAlphaForOverlayView(index)
            
            if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                profileDeckViewObject.commonalityTagsView.isHidden = true
            }
            
            if self.isPaginated == true {
                if snapShotImage != nil {
                    if Int(index) == koloda.currentCardIndex {
                        //profileDeckViewObject.addADummyImageViewWithSnapShotToAvoidFlickerWhileReloadingDeck(localSnapImage)
                    }
                }
            }
            
            if recommendationArray?.collectionMode == .my_PROFILE {
                editProfileOpenedFromReviewPhotoCard = false
                shouldNotOpenProfileDetail = false
                profileDeckViewObject.editProfileButton.addTarget(self, action: #selector(DiscoverViewController.openEditProfile(_:)), for: UIControl.Event.touchUpInside)
            }
            else{
                DiscoverProfileCollection.sharedInstance.flpWooIDs.add(userDetails.wooId ?? "")
                DiscoverProfileCollection.sharedInstance.currentProfileWooID = userDetails.wooId!
            }
            
            return profileDeckViewObject
        }
        else if  let cardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? BrandCardModel{
            let brandDeckViewObject : BrandCardDeck = BrandCardDeck.init(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
            
            if let urlToOpen = cardDetails.actionUrl {
                
                let urlString = urlToOpen.absoluteString
                
                if urlString.contains("wooapp://") {
                    
                    if urlString.contains("verifyPhoneNumber"){
                        (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "PhoneBrandCard_Landing")
                    }
                }
            }
            
            brandDeckViewObject.brandDetails = cardDetails
            
            brandDeckViewObject.showPurchaseOptions = {() in
                
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverBrandCards", withEventName: "3-Discovery.DiscoverBrandCards.DBC_CTA_Tap")
                
                
                
                if let urlToOpen = cardDetails.actionUrl {
                    
                    let urlString = urlToOpen.absoluteString
                    
                    if urlString.contains("wooapp://") {
                        
                        if urlString.contains("verifyPhoneNumber"){
                            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "PhoneBrandCard_Add")
                            self.makeLikeSwipeNow()
                            return
                        }
                        DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                        
                        WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromSideMenu = false
                        WooScreenManager.sharedInstance.openDeepLinkedScreen(urlString)
                        WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                            if crushPurchased{
                                
                                if cardDetails.subCardType == .WOOGLOBE {
                                    if crushPurchased == true {
                                        WooGlobeModel.sharedInstance().wooGlobleOption = crushPurchased
                                        WooGlobeModel.sharedInstance().isExpired = false
                                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        if WooGlobeModel.sharedInstance().religionArray.count < 1 {
                                            WooGlobeModel.sharedInstance().religionOption = false
                                        }
                                        
                                        if WooGlobeModel.sharedInstance().ethnicityArray.count < 1 {
                                            WooGlobeModel.sharedInstance().ethnicityOption = false
                                        }
                                        
                                    }
                                    self.openDiscoverSettingsScreenPostWooGlobePurchase()
                                }
                                else{
                                    self.showWooLoader(wooLoaderStyle: true)
                                    self.fetchDiscoverData(false)
                                }
                            }
                        }
                        
                    }
                    else{
                        if UIApplication.shared.canOpenURL(urlToOpen) {
                            //                       UIApplication.sharedApplication().openURL(urlToOpen)
                            
                            
                            
                            // Open url in internal browser
                            if (self.recommendationArray?.count())!<=0 {
                                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                                DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
                            }
                            
                            let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                            
                            let myWebViewViewController:WkWebViewController = (storyboard.instantiateViewController(withIdentifier: kMyWebViewController) as? WkWebViewController)!
                            
                            // myWebViewViewController.navTitle = "Woo Promotions"
                            myWebViewViewController.webViewUrl = urlToOpen
                            WooScreenManager.sharedInstance.oHomeViewController!.present(myWebViewViewController, animated: true, completion: nil)
                            
                        }
                    }
                }
                
            }
            
            brandDeckViewObject.setDataForProfileView()
            
            brandDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
            
            if self.isPaginated == true {
                if snapShotImage != nil {
                    if Int(index) == koloda.currentCardIndex {
                        //brandDeckViewObject.addADummyImageViewWithSnapShotToAvoidFlickerWhileReloadingDeck(localSnapImage)
                    }
                }
            }
            
            return brandDeckViewObject
        }
        else if let newUserNoPicCardDetails = self.recommendationArray?.objectAtIndex(Int(index)) as? NewUserNoPicCardModel{
            currentNewUserNoPicModel = newUserNoPicCardDetails
            let newUserNoPicDeckViewObject : NewUserNoPicDeckView = NewUserNoPicDeckView(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
            
            newUserNoPicDeckViewObject.newUserNoPicDetails = newUserNoPicCardDetails
            
            newUserNoPicDeckViewObject.setDataForNewUserNoPicView((DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.checkIfAlbumHasAtleastOneInCompatiblePhoto())!)
            
            newUserNoPicDeckViewObject.ctaButtonTappedHandler = {(needToTakeAction:Bool) in
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverNoPhotoCard", withEventName: "3-Discovery.DiscoverNoPhotoCard.DNP_CTA_Tap")
                
                DispatchQueue.main.async{
                    if needToTakeAction == true{
                        self.showImageCropper()
                    }
                    else{
                        self.perform(#selector(self.removeNewUserNoPicFromDeck), with: nil, afterDelay: 0.1)
                    }
                }
            }
            
            return newUserNoPicDeckViewObject
        }
        else if let selectionCardDetails = self.recommendationArray?.objectAtIndex(Int(index)) as? SelectionCardModel{
            if selectionCardDetails.subCardType == .ETHNICITY{
                (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EthnicityBrandCard_Landing")
            }
            else if selectionCardDetails.subCardType == .RELIGION{
                (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "ReligionBrandCard_Landing")
                
            }
            let selectionDeckViewObject : SelectionCardDeck = SelectionCardDeck.loadViewFromNib(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
            
            selectionDeckViewObject.selectionDetails = selectionCardDetails
            selectionDeckViewObject.setDataForSelectionView()
            
            selectionDeckViewObject.actionButtonHandler = {() in
                self.makeLikeSwipeNow()
            }
            
            selectionDeckViewObject.selectionEndedHandler = {(selectionArray) in
                self.selectionCardSelectedValueArray = selectionArray
                if self.selectionCardSelectedValueArray.count == selectionCardDetails.maxSelection {
                    self.makeLikeSwipeNow()
                }
            }
            
            selectionDeckViewObject.otherButtonHandler = { (array) in
                self.makeLikeSwipeNow()
                //                switch selectionCardDetails.subCardType {
                //                case .ETHNICITY:
                //                    //Open Ethnicity
                //                    self.openEthnicityScreen()
                //                    break
                //                case .RELIGION:
                //                    //Open Religion
                //                    self.openReligionScreen()
                //                    break
                //                case .TAGS:
                //                    self.openEditTagsScreen(array: array)
                //                    break
                //                default:
                //                    // Do Nothing
                //                    break
                //                }
                
            }
            
            return selectionDeckViewObject
        }
        else if let discoverEmptyModel = self.recommendationArray?.objectAtIndex(Int(index)) as? DiscoverEmptyModel{
            if( discoverEmptyModel.subCardType != nil){
                swrveEventForEmptyCardShow(discoverEmptyModel.subCardType!)
            }// Call Swrve event method
            
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "DiscoverEmptyDeck", bundle: bundle)
            let discoverEmptyDeckViewObject = nib.instantiate(withOwner: self, options: nil)[0] as! DiscoverEmptyDeck
            discoverEmptyDeckViewObject.frame = CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height)
            discoverEmptyDeckViewObject.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            discoverEmptyDeckViewObject.setDataForView(discoverEmptyModel)
            
            discoverEmptyDeckViewObject.tapHandler = {(urlString) in
                
                BrandCardAPI.updateBrandCardPassStatus(onServer: "PASS", and: discoverEmptyModel.id)
                self.recommendationArray?.removeFirstDiscoverEmptyCard()
                
                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                DiscoverProfileCollection.sharedInstance.discoverDataHasArrivedButViewNotPresent = true
                
                if urlString.count > 0 {
                    // Srwve Event
                    if discoverEmptyModel.subCardType == .DISCOVER_EMPTY_PREFERENCES{
                        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_ExpandPref_TapManual")
                    }
                    
                    swrveEventForEmptyCardCTA(discoverEmptyModel.subCardType!) // Swrve Event CTA
                    WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromDiscoverEmpty = true
                    WooScreenManager.sharedInstance.openDeepLinkedScreen(urlString)
                    WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                        
                    }
                    
                    self.recommendationArray?.discoverModelCollection.removeAllObjects()
                    self.recommendationArray?.switchCollectionMode(CollectionMode.discover_EMPTY)
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        self.reloadDeckView()
                    })
                }
                else{
                    // Srwve Event
                    if discoverEmptyModel.subCardType == .DISCOVER_EMPTY_PREFERENCES {
                        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_ExpandPref_TapAuto")
                        self.showWooLoader(wooLoaderStyle: true)
                        self.fetchDiscoverData(true)
                    }
                        
                    else if discoverEmptyModel.subCardType == .DISCOVER_EMPTY_DIASPORA || discoverEmptyModel.subCardType == .DISCOVER_EMPTY_DIASPORA_OFF {
                        
                        WooGlobeModel.sharedInstance().wooGlobleOption = false
                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                        self.showWooLoader(wooLoaderStyle: true)
                        self.fetchDiscoverData(false)
                        self.setWooGlobeNavValue()
                    }
                    
                }
            }
            return discoverEmptyDeckViewObject
        }
        else if (self.recommendationArray?.objectAtIndex(Int(index)) as? ReviewPhotoCardModel) != nil{
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "ReviewPhotoCard", bundle: bundle)
            let reviewPhotoCardObject = nib.instantiate(withOwner: self, options: nil)[0] as! ReviewPhotoCard
            reviewPhotoCardObject.frame = CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height)
            reviewPhotoCardObject.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            reviewPhotoCardObject.reviewPhotoModel = self.recommendationArray?.objectAtIndex(Int(index)) as? ReviewPhotoCardModel
            reviewPhotoCardObject.setDataForReviewPhotoCard()
            return reviewPhotoCardObject
        }
        else{
            if self.recommendationArray?.collectionMode == CollectionMode.my_PROFILE{
                self.recommendationArray?.switchCollectionMode(.my_PROFILE)
                
                let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel
                let profileDeckViewObject : ProfileDeckView = ProfileDeckView.init(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
                profileDeckViewObject.delegate = self
                profileDeckViewObject.crushMessageContainerViewYValue = SCREEN_HEIGHT - actionButtonBottomConstraint.constant
                
                profileDeckViewObject.aboutMeLabelContainerViewYValue = SCREEN_HEIGHT - actionButtonBottomConstraint.constant
                
                profileDeckViewObject.profileDetails = userDetails
                profileDeckViewObject.animateViewComponent = true
                
                if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                    profileDeckViewObject.setDataForProfileView(true)
                    print("userdetails=\(userDetails?.firstName)")
                }
                else{
                    profileDeckViewObject.setDataForProfileView(false)
                }
                
                profileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
                
                profileDeckViewObject.updateAlphaForOverlayView(index)
                
                if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                    profileDeckViewObject.commonalityTagsView.isHidden = true
                }
                
                if self.isPaginated == true {
                    if snapShotImage != nil {
                        if Int(index) == koloda.currentCardIndex {
                            //profileDeckViewObject.addADummyImageViewWithSnapShotToAvoidFlickerWhileReloadingDeck(localSnapImage)
                        }
                    }
                }
                
                if recommendationArray?.collectionMode == .my_PROFILE {
                    editProfileOpenedFromReviewPhotoCard = false
                    shouldNotOpenProfileDetail = false
                    profileDeckViewObject.editProfileButton.addTarget(self, action: #selector(DiscoverViewController.openEditProfile(_:)), for: UIControl.Event.touchUpInside)
                }
                else{
                    DiscoverProfileCollection.sharedInstance.flpWooIDs.add(userDetails?.wooId ?? "")
                    DiscoverProfileCollection.sharedInstance.currentProfileWooID = (userDetails?.wooId!)!
                }
                
                return profileDeckViewObject
            }
            else{
                let dummyViewObject : UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
                
                return dummyViewObject
            }
            
            
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> UIView? {
        if DiscoverProfileCollection.sharedInstance.collectionMode != .my_PROFILE{
            if (self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel) != nil{
                return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
            }
            else{
                return nil
            }
        }
        else{
            return nil
        }
    }
}



//MARK: SWRVE events for Empty Card Show

func swrveEventForEmptyCardShow(_ subCardType : DiscoverEmptySubCardType?)  {
    
    if subCardType == nil{
        return
    }
    
    if subCardType == .DISCOVER_EMPTY_PREFERENCES {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_ExpandPref_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_PHOTO {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_PhotoUp_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_WORK {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoWorkInfo_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_EDUCATION {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoEduInfo_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_LINKEDIN_VERIFY {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoLinkedIn_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_HEIGHT {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoHeight_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_NOTIFICATION {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NotificationOff_Show")
        
    }else if subCardType == .DISCOVER_EMPTY_BOOST {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoBoost_Show")
        
    }
    
}


func swrveEventForEmptyCardCTA(_ subCardType : DiscoverEmptySubCardType)  {
    
    if subCardType == .DISCOVER_EMPTY_PHOTO {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_PhotoUp_TapCTA")
        
    }else if subCardType == .DISCOVER_EMPTY_WORK {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoWorkInfo_TapCTA")
        
    }else if subCardType == .DISCOVER_EMPTY_EDUCATION {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoEduInfo_TapCTA")
        
    }else if subCardType == .DISCOVER_EMPTY_LINKEDIN_VERIFY {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoLinkedIn_TapCTA")
        
    }else if subCardType == .DISCOVER_EMPTY_HEIGHT {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoHeight_TapCTA")
        
    }else if subCardType == .DISCOVER_EMPTY_NOTIFICATION {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NotificationOff_TapCTA")
        
    }else if subCardType == .DISCOVER_EMPTY_BOOST {
        
        // Srwve Event
        //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverEmpty", withEventName: "3-Discovery.DiscoverEmpty.DE_NoBoost_TapCTA")
        
    }
    
}

//MARK: ProfileDeckView Delegate
extension DiscoverViewController: ProfileDeckViewDelegate {
    func getTheSelectedCommonality(_ commonalitySelected:String){
        
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_TapCommonalityBadge")
        
        
        selectedCommonality = commonalitySelected
        currentUserData = recommendationArray?.objectAtIndex(Int(deckView.currentCardIndex)) as? ProfileCardModel
        makeTheProfileDeckBig()
    }
}

//MARK: BrandCardDeckView Delegate
extension DiscoverViewController: BrandCardDeckDelegate {
    func getTheSelectedCommonalityForBrandCard(_ commonalitySelected:String){
        selectedCommonality = commonalitySelected
        currentUserData = recommendationArray?.objectAtIndex(Int(deckView.currentCardIndex)) as? BrandCardModel
        self.actionButtonsContainerView.isHidden = true
        if let urlToOpen = (currentUserData as! BrandCardModel).actionUrl {
            let urlString = urlToOpen.absoluteString
            if urlString.contains("verifyPhoneNumber") {
                return
            }
        }
        makeTheBrandDeckBig()
    }
}


extension DiscoverViewController : UINavigationControllerDelegate
{
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if operation == UINavigationController.Operation.push && ((fromVC is DiscoverViewController) || (fromVC is TagSearchViewController)) && ((toVC is BrandCardViewController) || (toVC is ProfileDeckDetailViewController))
        {
            return ProfilePresentAnimator(originFrame:self.view.frame)
        }
        if operation == UINavigationController.Operation.pop && ((toVC is DiscoverViewController) || (toVC is TagSearchViewController)) && ((fromVC is BrandCardViewController) || (fromVC is ProfileDeckDetailViewController))
        {
            return ProfilePopAnimator(originFrame:self.view.frame)
        }
        return nil
    }
    
}
