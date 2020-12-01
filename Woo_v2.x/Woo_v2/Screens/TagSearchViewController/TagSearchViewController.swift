        //
//  TagSearchViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 28/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import IQKeyboardManager
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
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


class TagSearchViewController: BaseClassViewController {

    @IBOutlet weak var searchEmptyViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: WooLikeMeterButton!
    @IBOutlet weak var crushButton: UIButton!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var actionButtonsContainerView: UIView!
    @IBOutlet weak var deckView: KolodaView!
    @IBOutlet weak var deckViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noInternetScreen: UIView!
        
    @IBOutlet weak var searchEmptyView: UIView!
    @IBOutlet weak var searchEmptyTitleLabel: UILabel!
    @IBOutlet weak var searchEmptyDescriptionLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    fileprivate var recommendationArray : DiscoverProfileCollection?
    
    fileprivate var isPaginated:Bool = false
    
    var currentUserData :AnyObject?
    
    var selectedCommonality:String?
    
    var crushToBeSent:NSString?
    
    var customLoader:WooLoader?
    
    var YConstraintForProfileDeck:CGFloat = 84
    
    var buttonActivity:PerformActionBasedOnActivity = PerformActionBasedOnActivity.DoNothing
    
    var swipeAllowedDirection:SwipeResultDirection?
    
    var sendCrushViewObject:SendCrushView?
    
    var callHasAlreadyMadeInDetail:Bool = false
    
    var snapShotImage:UIImage?
    
    var locationManager : LocationManager?
    
    var areWeMovingUpOrLeftRight:String = ""
    
    fileprivate var matchData :NSDictionary?
    
    fileprivate var matchButtonType : OverlayButtonType?
    
    fileprivate var currentNewUserNoPicModel : NewUserNoPicCardModel?
    
    fileprivate var searchEmptyModel : DiscoverEmptyModel?
    
    fileprivate var cardIsMovingUpwards:Bool = false

    fileprivate var dataComingFromServerSoNeedToShowLoader:Bool = false
    
    fileprivate var disableCardInteraction:Bool = false
    
    var tagSearchHasBeenPerformedFromDiscover = false
    
    var tagSearchHasbeenDismissed = false
    
    var actionHasBeenTakenOnProfile = false
    
    let profileAction:ProfileActionManager = ProfileActionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_Landing")
        
        setupDeckView()
        colorTheStatusBar(withColor: NavBarStyle.search.color())
        self.navBar!.setStyle(NavBarStyle.search, animated: false)
        let tagName = "#" + (DiscoverProfileCollection.sharedInstance.selectedTagData?.name)!
        
        self.navBar?.setTitleText(tagName)
        self.navigationController?.isNavigationBarHidden = true;
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(TagSearchViewController.backButton))
        
        self.buttonActivity = .Like
        
        areWeMovingUpOrLeftRight = ""
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
            YConstraintForProfileDeck = 84
            }
            else{
                YConstraintForProfileDeck = 64
            }
        }
        else{
            YConstraintForProfileDeck = 64
        }
        
        deckViewTopConstraint.constant = YConstraintForProfileDeck
        
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                searchEmptyViewTopConstraint.constant = 64.0
            }
        }
        
        self.checkForLikeLimit()
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }

//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground),
                                               name:UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnectionStatusChanged),
                                                         name: NSNotification.Name(rawValue: kInternetConnectionStatusChanged), object: nil)

                // Do any additional setup after loading the view.
        
        //moving code from viewdidappear to view didload 
        let expiryNumber = 4
        UserDefaults.standard.setValue(expiryNumber, forKey: "tagTrainingShowExpiry")
        UserDefaults.standard.synchronize()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //SwipeBack
        
        if let nav = self.navigationController{
            nav.swipeBackEnabled = false
        }
        
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
    }
    
    @objc func dimissTheScreen()
    {
        NSLog("dimissTheScreen MyPreferences");
        dismiss(animated: false, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
//        let expiryNumber = 4
//        UserDefaults.standard.setValue(expiryNumber, forKey: "tagTrainingShowExpiry")
//        UserDefaults.standard.synchronize()


    }

    
    override func awakeFromNib() {
        super.awakeFromNib()

        likeButton.isExclusiveTouch = true
        passButton.isExclusiveTouch = true
        crushButton.isExclusiveTouch = true

        self.showOrHideActionButtonsContainerView(false)
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            noInternetScreen.isHidden = false
            deckView.isHidden = true
        }
        else{
        self.deckView.isHidden = true
            self.showWooLoader()
            self.fetchDiscoverData(false)
        }

    }
    
    @objc func backButton(){
        DiscoverProfileCollection.sharedInstance.selectedUserTagWooID = nil
        self.tagSearchHasbeenDismissed = true
       
        if actionHasBeenTakenOnProfile{
            actionHasBeenTakenOnProfile = false
        if tagSearchHasBeenPerformedFromDiscover == true {
            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
        }
        else{
            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
            DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
            if (WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 1){
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            }
//            DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
//                if success{
//                }
//            })
        }
        }
        DiscoverEmptyManager.sharedInstance.removeObjectsForType(.SEARCH_EMPTY_NO_RESULT)
        DiscoverEmptyManager.sharedInstance.removeObjectsForType(.SEARCH_EMPTY_END)
        DiscoverProfileCollection.sharedInstance.tagSearchPaginationIndex = ""
        DiscoverProfileCollection.sharedInstance.tagSearchPaginationToken = ""
        DiscoverProfileCollection.sharedInstance.searchModelCollection.removeAllObjects()
        
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == SegueIdentifier.TagSearchToProfileDetailSegue.rawValue){
            let detailViewControllerObject = segue.destination as! ProfileDeckDetailViewController
            detailViewControllerObject.profileData = (currentUserData as! ProfileCardModel)
            detailViewControllerObject.discoverProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView
            detailViewControllerObject.moveToCellBasedOnCommonalitySelection = selectedCommonality!
            detailViewControllerObject.isComingFromDiscover = true
            detailViewControllerObject.detailProfileParentTypeOfView = DetailProfileViewParent.tagSearch
            //detailViewControllerObject.isViewPushed = true
            detailViewControllerObject.isMyProfile = false
            detailViewControllerObject.discoverSnapShot = snapShotImage
            
            detailViewControllerObject.dismissHandler = {(currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel, onBoardingEditProfileDone:Bool, indexPath:IndexPath) in
                
                self.crushToBeSent = crushString as NSString?

                if self.recommendationArray?.searchDataCount()<=0 {
                    self.deckView.isHidden = true
                    self.actionButtonsContainerView.isHidden = true
                    self.showWooLoader()
                    self.fetchDiscoverData(false)
                    let tagName = "#" + (DiscoverProfileCollection.sharedInstance.selectedTagData?.name)!
                    self.navBar?.setTitleText(tagName)
                }
                self.checkForLikeLimit()
                self.buttonActivity = needToTakeAction
                
                if !(needToTakeAction == .DoNothing) {
                    self.disableCardInteraction = true
                    self.callHasAlreadyMadeInDetail = false
                    //self.deckView.isUserInteractionEnabled = false
                    self.likeButton.isUserInteractionEnabled = false
                    self.passButton.isUserInteractionEnabled = false
                    self.crushButton.isUserInteractionEnabled = false

                }
                else{
                    self.disableCardInteraction = false
                }
                
                DispatchQueue.main.async {
                    
                    if currentImageUrlString.count > 0{
                        if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
                            localProfileDeckViewObject.profileImageHasBeenChanged = true
                            localProfileDeckViewObject.setProfileImageForUser(URL(string: currentImageUrlString as String), userGender: localProfileDeckViewObject.profileDetails?.gender)
                        }
                    }
                   
                }
                
                //self.perform(#selector(), with:nil, afterDelay: 0.0)
                self.makeTheDeckSmall()

            }
        }
        else if segue.identifier == kPushToChatFromDiscover {
            if sender != nil {
//                let chatViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
//                let chatViewControllerObj: NewChatViewController  = chatViewNavControllerObj.viewControllers.first as! NewChatViewController
                let chatViewControllerObj: NewChatViewController = segue.destination as! NewChatViewController
                let model = sender as! MyMatches
                chatViewControllerObj.myMatchesData = model
                chatViewControllerObj.parentView = .discover
                chatViewControllerObj.isAutomaticallyPushedFromChat = true
                chatViewControllerObj.delegateFromMatch = self
            }
        }
        else if (segue.identifier == SegueIdentifier.NewMtchSegue.rawValue) {
            let matchOverlayController = segue.destination as! NewMatchViewController
            matchOverlayController.matchData = self.matchData
            matchOverlayController.buttonType = OverlayButtonType.Keep_Swiping
        }
    }
    
    @objc fileprivate func nowPerformButtonActions(){
        if self.buttonActivity == .Like || self.buttonActivity == .CrushSent{
            self.like(UIButton())
        }
        else if self.buttonActivity == .Pass{
            self.pass(UIButton())
        }
        
        if self.recommendationArray?.searchDataCount() > 0 {
            self.showOrHideActionButtonsContainerView(true)
        }
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

    fileprivate func showSendCrushView(){
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        if sendCrushViewObject == nil {
            let mainWindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
            sendCrushViewObject = SendCrushView.init(frame: mainWindow.rootViewController!.view.frame)
        }
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        sendCrushViewObject?.presentView(on: self.view, withTemplateQuestions: CrushModel.sharedInstance().templateQuestionArray, userName: currentUserData?.firstName, withAnimationTime: 0.25, withCompletionBlock: { (true) in
            self.sendCrushViewObject?.viewDismissed({ (crushText, isSendButtonTapped, isTemplateTapped, selectedRow) in
                
             //   WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                
                if isSendButtonTapped == false && isTemplateTapped == false{
                    self.crushButton.isUserInteractionEnabled = true
                    return
                }
                self.crushToBeSent = crushText as NSString?
                self.buttonActivity = .CrushSent
                self.like(UIButton())
                self.sendCrushViewObject = nil
            })
        })
    }
    
    fileprivate func showPopularUserView(){
        let popularUserViewObject:PopularUserView = Bundle.main.loadNibNamed("PopularUserView", owner: nil, options: nil)![0] as! PopularUserView
        popularUserViewObject.frame = self.view.bounds
        popularUserViewObject.setPopularDataOnViewWithImage((currentUserData as! ProfileCardModel).wooAlbum?.objectAtIndex(0)?.url, withName: currentUserData!.firstName, andType: false, withGender:currentUserData!.gender) { (selectedIndex:NSInteger, typeOfView:Bool) in
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }

            
            if typeOfView == false{
                if selectedIndex != 0{
                    //Purchase screen
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                    purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.showSendCrushView()
                        }
                        
                    }
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if CrushModel.sharedInstance().availableCrush > 0 {
                                        self.showSendCrushView()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                    //popular user handling
                }
            }
        }
        self.view.addSubview(popularUserViewObject)
    }
    
    fileprivate func showOutOfCrushesView(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_OutOfCrushPopup")

        
        
        let outOfCrushesViewObject:PopularUserView = Bundle.main.loadNibNamed("PopularUserView", owner: nil, options: nil)![0] as! PopularUserView
        outOfCrushesViewObject.frame = self.view.bounds
        outOfCrushesViewObject.setPopularDataOnViewWithImage((currentUserData as! ProfileCardModel).wooAlbum?.objectAtIndex(0)?.url, withName: currentUserData!.firstName, andType: true, withGender:currentUserData!.gender) { (selectedIndex:NSInteger, typeOfView:Bool) in
            //out of crushes handling
            if typeOfView == true{
                if selectedIndex != 0{
                    //Purchase screen
                    
                    if !(Utilities.sharedUtility() as AnyObject).reachable() {
                        self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                        return
                    }

                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_OutOfCrushPopup_GetCrushes")

                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                    purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.showSendCrushView()
                        }
                        
                    }
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                            DispatchQueue.main.async{
                                if CrushModel.sharedInstance().availableCrush > 0 {
                                    self.showSendCrushView()
                                }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                }else{ // Cancel button
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_OutOfCrushPopup_Cancel")

                    
                }
            }
        }
        self.view.addSubview(outOfCrushesViewObject)
    }
    
    @IBAction func retryDiscoveryButtonPressed(_ sender: AnyObject) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        else{
                if recommendationArray?.searchDataCount() == 0 || recommendationArray?.searchDataCount() == nil {
                        showWooLoader()
                        DiscoverProfileCollection.sharedInstance.searchModelCollection.removeAllObjects()
                        fetchDiscoverData(false)
                    }
                else{
                    self.deckView.isHidden = false
                    hideWooLoader()
                }
                noInternetScreen.isHidden = true
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
                        self.showActionTutorialForType(.LikeDone)
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
    
    //MARK: Private Methods
    @objc fileprivate func enableButtonsNow()
    {
        self.disableCardInteraction = false
        self.deckView.isUserInteractionEnabled = true
        self.passButton.isUserInteractionEnabled = true
        self.likeButton.isUserInteractionEnabled = true
        self.crushButton.isUserInteractionEnabled = true
        
//        if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
//            let rect: CGRect = localProfileDeckViewObject.bounds
//            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//            let context: CGContextRef = UIGraphicsGetCurrentContext()!
//            localProfileDeckViewObject.layer.renderInContext(context)
//            let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//            snapShotImage = capturedImage
//            UIGraphicsEndImageContext()
//        }
//        else if let localBrandDeckObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? BrandCardDeck {
//            let rect: CGRect = localBrandDeckObject.bounds
//            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//            let context: CGContextRef = UIGraphicsGetCurrentContext()!
//            localBrandDeckObject.layer.renderInContext(context)
//            let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//            snapShotImage = capturedImage
//            UIGraphicsEndImageContext()
//        }
//        else if let newUserNoPicDeckObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? NewUserNoPicDeckView{
//            let rect: CGRect = newUserNoPicDeckObject.bounds
//            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//            let context: CGContextRef = UIGraphicsGetCurrentContext()!
//            newUserNoPicDeckObject.layer.renderInContext(context)
//            let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//            snapShotImage = capturedImage
//            UIGraphicsEndImageContext()
//        }
    }

    @objc fileprivate func makeLikeSwipeNow(){
        if buttonActivity == .CrushSent {
            deckView.crushIsBeingSent = true
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush: true, animationEnded: true)
            }
        }
        else{
            deckView.crushIsBeingSent = false
            if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush:  false,animationEnded: true)
            }
        }
        
        deckView.isUsedInTagSearch = true
        deckView.swipe(SwipeResultDirection.Right)
        if let userDetails =  self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) as? ProfileCardModel{
            let imagesArray:NSArray = NSArray.init(array: (userDetails.wooAlbum?.allImagesUrl())!)
            (Utilities.sharedUtility() as AnyObject).deleteImagesFromCache(forProfile:imagesArray as! [Any])
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
                    if !noInternetScreen.isHidden {
                        showWooLoader()
                        fetchDiscoverData(false)
                    }
                }
            }
            else{
                //                reloadDeckView()
            }
            noInternetScreen.isHidden = true
        }
        else{
            if recommendationArray?.searchDataCount() == 0 || recommendationArray?.searchDataCount() == nil {
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

    func checkForLikeLimit() {
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
       
        if self.recommendationArray?.searchDataCount()>0 {

            if let localActionButtonContainerView = self.actionButtonsContainerView{
                
                localActionButtonContainerView.isHidden = false
                self.likeButton.isUserInteractionEnabled = true
                self.passButton.isUserInteractionEnabled = true
                self.crushButton.isUserInteractionEnabled = true

                UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    if showOrHide == true {
                        localActionButtonContainerView.transform = CGAffineTransform.identity
                    }
                    else{
                        localActionButtonContainerView.transform = CGAffineTransform(translationX: 0, y: 160 + safeAreaBoth)
                        localActionButtonContainerView.isHidden = true
                    }
                }) { (true) in
                    
                }
            }
        }
        else{
            self.actionButtonsContainerView.isHidden = true
        }
    }
    
    func fetchDiscoverData(_ isPrefrenceExtended : Bool) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: isPrefrenceExtended, isTagSelected: true, andCompletionBlock: { (success, response, errorCode) in
            
            if success {
                
                if self.tagSearchHasbeenDismissed == true{
                    self.tagSearchHasbeenDismissed = false
                    return
                }
                if ((response as! NSDictionary).object(forKey: "searchProfileCount") != nil){
                    let count = (response as! NSDictionary).object(forKey: "searchProfileCount") as! Int
                    if count > 1{
                        let searchCountString = NSLocalizedString("There are \(count) profiles in the deck.", comment: "")
                        self.showSnackBar(searchCountString)
                    }
                    
                }
                if ((DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl()) != nil){
                    self.myImageView.sd_setImage(with: URL(string: (DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl())!), placeholderImage: UIImage(named: "ic_me_avatar_big"))
                    
                }else{
                    
                    self.myImageView.image = UIImage(named: "ic_me_avatar_big")
                    
                }
                self.recommendationArray = DiscoverProfileCollection.sharedInstance
                
                if self.recommendationArray?.searchDataCount() > 0{
                    self.deckView.isHidden = false
                    self.reloadDeckView()
                    
                    self.searchEmptyModel = DiscoverEmptyManager.sharedInstance.getDiscoverEmptyModelForType(DiscoverEmptySubCardType.SEARCH_EMPTY_END)
                    if let localSearchEmptyModel = self.searchEmptyModel{
                        //                        self.searchEmptyView.hidden = false
                        self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
                        self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
                    }
                    else{
                        self.searchEmptyTitleLabel.text = ""
                        self.searchEmptyDescriptionLabel.text = ""
                    }
                }
                else{
                    self.hideWooLoader()
                    self.deckView.isHidden = true
                    self.actionButtonsContainerView.isHidden = true
                    self.searchEmptyModel = DiscoverEmptyManager.sharedInstance.getDiscoverEmptyModelForType(DiscoverEmptySubCardType.SEARCH_EMPTY_NO_RESULT)
                    if let localSearchEmptyModel = self.searchEmptyModel{
                        self.searchEmptyView.isHidden = false
                        self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
                        self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
                    }
                }
            }
            else{
                self.hideWooLoader()
                self.actionButtonsContainerView.isHidden = true
                
                if errorCode == 401 {
                    WooScreenManager.sharedInstance.loadLoginView()
                    (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp(nil)
                }
                else if errorCode == 500{
                    self.showSnackBar("Server is not responding")
                }
                else if errorCode == 0{
                    self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                }
            }
        })
        
//        DiscoverAPIClass.fetchDiscoverData(fromServer: false, andPrefrence: isPrefrenceExtended, isTagSelected: true) { (success, response, errorCode) in
//            
//            if success {
//                
//                if self.tagSearchHasbeenDismissed == true{
//                    self.tagSearchHasbeenDismissed = false
//                    return
//                }
//                if ((response as! NSDictionary).object(forKey: "searchProfileCount") != nil){
//                    let count = (response as! NSDictionary).object(forKey: "searchProfileCount") as! Int
//                    if count > 1{
//                        let searchCountString = NSLocalizedString("There are \(count) profiles in the deck.", comment: "")
//                        self.showSnackBar(searchCountString)
//                    }
//                    
//                }
//                if ((DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl()) != nil){
//                    self.myImageView.sd_setImage(with: URL(string: (DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl())!), placeholderImage: UIImage(named: "ic_me_avatar_big"))
//
//                }else{
//                    
//                    self.myImageView.image = UIImage(named: "ic_me_avatar_big")
//                    
//                }
//                self.recommendationArray = DiscoverProfileCollection.sharedInstance
//                
//                if self.recommendationArray?.searchDataCount() > 0{
//                    self.deckView.isHidden = false
//                    self.reloadDeckView()
//                    
//                    self.searchEmptyModel = DiscoverEmptyManager.sharedInstance.getDiscoverEmptyModelForType(DiscoverEmptySubCardType.SEARCH_EMPTY_END)
//                    if let localSearchEmptyModel = self.searchEmptyModel{
////                        self.searchEmptyView.hidden = false
//                        self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
//                        self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
//                    }
//                    else{
//                        self.searchEmptyTitleLabel.text = ""
//                        self.searchEmptyDescriptionLabel.text = ""
//                    }
//                }
//                else{
//                    self.hideWooLoader()
//                    self.deckView.isHidden = true
//                    self.actionButtonsContainerView.isHidden = true
//                    self.searchEmptyModel = DiscoverEmptyManager.sharedInstance.getDiscoverEmptyModelForType(DiscoverEmptySubCardType.SEARCH_EMPTY_NO_RESULT)
//                    if let localSearchEmptyModel = self.searchEmptyModel{
//                            self.searchEmptyView.isHidden = false
//                            self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
//                            self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
//                    }
//                }
//            }
//            else{
//                self.hideWooLoader()
//                self.actionButtonsContainerView.isHidden = true
//
//                if errorCode == 401 {
//                    WooScreenManager.sharedInstance.loadLoginView()
//                    (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp()
//                }
//                else if errorCode == 500{
//                    self.showSnackBar("Server is not responding")
//                }
//                else if errorCode == 0{
//                    self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
//                }
//            }
//        }
    }
    
    func showWooLoader(){
        self.deckView.isHidden = true
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        customLoader?.shouldShowWooLoader = true
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 2.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            }, completion: { (true) in
                (Utilities.sharedUtility() as AnyObject).hideLoaderView
                self.customLoader?.stopAnimation()
        })
        
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
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
//            [DiscoverProfileCollection sharedInstance].selectedTagData.tagId,[DiscoverProfileCollection sharedInstance].selectedTagData.tagsDtoType
            profileAction.likeActionPerformed(.ProfileCardModel, userObject: profileObject as AnyObject, withTagId: DiscoverProfileCollection.sharedInstance.selectedTagData!.tagId!, andTagType: DiscoverProfileCollection.sharedInstance.selectedTagData!.tagsDtoType!)
            break
            
        case .Pass:
            profileAction.dislikeActionPerformed(.ProfileCardModel, userObject: profileObject as AnyObject, withTagId: DiscoverProfileCollection.sharedInstance.selectedTagData!.tagId!, andTagType: DiscoverProfileCollection.sharedInstance.selectedTagData!.tagsDtoType!)
            break
            
        case .CrushSent:
            profileAction.crushActionPerformed(.ProfileCardModel, userObject: profileObject as AnyObject, withTagId: DiscoverProfileCollection.sharedInstance.selectedTagData!.tagId!, andTagType: DiscoverProfileCollection.sharedInstance.selectedTagData!.tagsDtoType!)
            break
            
        default:
            break
        }
    }

    @objc fileprivate func showActionButtonsWithDelay(){
        self.showOrHideActionButtonsContainerView(true)
    }
    
    //MARK: Deck related Methods
    func setupDeckView() {
        deckView.dataSource = self
        deckView.delegate = self
    }
    
    func reloadDeckView(){
        
        self.recommendationArray?.updateSearchModelCollectionBasedOnReadStatus()
        
        //deckView.resetCurrentCardIndex()
        
        //If pagination then there will be no delay in unhiding deckview
//        if self.isPaginated == true {
//            deckView.hidden = false
//            hideWooLoader()
//        }
//        else{
//            UIView.animateWithDuration(0.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//                
//                }, completion: { (true) in
//                    self.deckView.hidden = false
//                    self.hideWooLoader()
//            })
//        }
        showWooLoader()
        self.perform(#selector(resettingKolodaViewTogetPerfectFrame), with: nil, afterDelay: 0.1)
        self.perform(#selector(nowShowDeckView), with: nil, afterDelay: 0.1)
    }
    
    @objc func resettingKolodaViewTogetPerfectFrame(){
        deckView.resetCurrentCardIndex()
    }
    
    @objc func nowShowDeckView(){
        deckView.isHidden = false
        hideWooLoader()
    }
    
    @objc fileprivate func makePassSwipeNow(){
        deckView.isUsedInTagSearch = true
        deckView.swipe(SwipeResultDirection.Left)
        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Left, isCrush: false,animationEnded: true)
        }
        if let userDetails =  self.recommendationArray?.objectAtIndex(self.deckView.currentCardIndex) as? ProfileCardModel{
            let imagesArray:NSArray = NSArray.init(array: (userDetails.wooAlbum?.allImagesUrl())!)
            (Utilities.sharedUtility() as AnyObject).deleteImagesFromCache(forProfile:imagesArray as! [Any])
        }
        
    }
    
    fileprivate func handleRightSwipeForIndex(_ index : Int) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if callHasAlreadyMadeInDetail == true {
            callHasAlreadyMadeInDetail = false
            self.disableCardInteraction = false
            if self.buttonActivity == .Like {
                AppLaunchModel.sharedInstance().likeCount += 1
                self.checkForLikeLimit()
            }
            else{
                self.buttonActivity = .Like
                deckView.crushIsBeingSent = false
            }
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.1)
            
            
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

            return
        }
        else{
            
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.1)
        }
        
        if self.recommendationArray?.searchDataCount()>0 {
            if let userDetails =  self.recommendationArray?.searchObjectAtIndex(Int(index)) as? ProfileCardModel{
                
                if self.buttonActivity == .CrushSent {
                    self.buttonActivity = .Like
                    deckView.crushIsBeingSent = false
                    
                    performActionForType(.CrushSent, profileObject: userDetails)
                }
                else{
                    self.checkForLikeLimit()
                    currentUserData = recommendationArray?.searchObjectAtIndex(Int(index)) as? ProfileCardModel
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_LikeByTapOrSwipe")
                    performActionForType(.Like, profileObject: userDetails)
                }
            }
        }
    }
    
    fileprivate func handleLeftForIndex(_ index : Int) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if callHasAlreadyMadeInDetail == true {
            callHasAlreadyMadeInDetail = false
            self.disableCardInteraction = false
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.1)
            return
        }
        else{
            self.perform(#selector(enableButtonsNow), with: nil, afterDelay: 0.1)
        }
        
       // DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
        
        if  self.recommendationArray?.searchDataCount()>0 {
            if let userDetails =  self.recommendationArray?.searchObjectAtIndex(Int(index)) as? ProfileCardModel{
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_SkipByTapOrSwipe")

                Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: userDetails.wooId, shouldDeleteFromAnswer: false, withCompletionHandler:nil)
                
                SkippedProfiles.insertOrUpdateSkippedProfileData(fromDiscoverCard: [userDetails], withCompletionHandler:nil)
                
                performActionForType(.Pass, profileObject: userDetails)
            }
        }
    }
    
    func makeTheProfileDeckBig(){
        
        //self.view.backgroundColor = UIColor.white
        //self.view.layoutIfNeeded()
        
//        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
//            localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
//            localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
//            localProfileDeckViewObject.myProfileBottomViewTrailingConstraint.constant = 0
//            localProfileDeckViewObject.myProfileBottomViewLeadingConstraint.constant = 0
//            if #available(iOS 11.0, *) {
//                if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
//                    self.deckViewTopConstraint.constant = 0.0
//                }
//                else{
//                    self.deckViewTopConstraint.constant = -20.0
//                }
//            }
//            else{
//            self.deckViewTopConstraint.constant = -20.0
//            }
//        }
//
//        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex+1)) {
//
//            localProfileDeckViewObject.isHidden = true
//        }
//
//        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex+2)) {
//
//            localProfileDeckViewObject.isHidden = true
//
//        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
                self.actionButtonsContainerView.transform = CGAffineTransform(translationX: 0,  y: UIScreen.main.bounds.size.height - (self.actionButtonsContainerView.frame.height + self.actionButtonsContainerView.frame.origin.y) + safeAreaBoth*2)
            
            self.view.layoutIfNeeded()
           
        }, completion: { (true) in
//            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView {
//                localProfileDeckViewObject.nowRemoveGradiant()
//                
//                let rect: CGRect = self.deckView.bounds
//                UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//                let context: CGContext = UIGraphicsGetCurrentContext()!
//                self.deckView.layer.render(in: context)
//                let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//                self.snapShotImage = capturedImage
//                UIGraphicsEndImageContext()
//            }
            
            self.performSegue(withIdentifier: SegueIdentifier.TagSearchToProfileDetailSegue.rawValue,
                                            sender: nil)
        }) 
    }

    @objc func makeTheDeckSmall(){
        //self.view.layoutIfNeeded()
        
        areWeMovingUpOrLeftRight = ""
        
        //self.perform(#selector(self.nowPerformButtonActions), with: nil, afterDelay: 0.1)
        nowPerformButtonActions()
        
        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.profileDeckMainContainerViewLeadingConstraint.constant = 10.0
            localProfileDeckViewObject.profileDeckMainContainerViewTrailingConstraint.constant = 10.0
            localProfileDeckViewObject.myProfileBottomViewTrailingConstraint.constant = 20
            localProfileDeckViewObject.myProfileBottomViewLeadingConstraint.constant = 20
            self.deckViewTopConstraint.constant = YConstraintForProfileDeck
            localProfileDeckViewObject.aboutMeLabelContainerViewYValue = actionButtonsContainerView.frame.origin.y - 210
            localProfileDeckViewObject.aboutMeLabelContainerViewHeightValue = 45.0
            localProfileDeckViewObject.crushMessageContainerViewYValue = actionButtonsContainerView.frame.origin.y - 110
            localProfileDeckViewObject.crushMessageContainerViewWidthValue = 0
            localProfileDeckViewObject.crushMessageContainerViewHeightValue = 0
            localProfileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
            //localProfileDeckViewObject.setupViewProperties()
            //localProfileDeckViewObject.aboutMeLabelContainerViewHeightConstraint.constant = localProfileDeckViewObject.bottomHolderView.frame.size.height
        }
        
        UIView.animate(withDuration: 0.3, animations: {
                self.actionButtonsContainerView.transform = CGAffineTransform.identity
            
            self.view.layoutIfNeeded()
            if (self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileDeckView) != nil {
                //localProfileDeckViewObject.updateCommonalityTagsViewBasedOnThereAvailability(localProfileDeckViewObject.profileDetails)
            }
        }, completion: { (true) in
            
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex)) {
                
                localProfileDeckViewObject.isHidden = false
                
            }
            
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                
                localProfileDeckViewObject.isHidden = false
                
            }
            
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                localProfileDeckViewObject.isHidden = false
            }
            
        }) 
    }
    
    fileprivate func showOutOfLikeAlert(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "SearchResultProfile", withEventName: "3-DiscoverTagSearchResults.SearchResultProfile.DTSP_OutOfLikesPopup")

        let outOfLikePopup = OutOfLikeView.showView(parentViewController: self)
        outOfLikePopup.buttonPressHandler = {
            //More Info
            
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup_MoreInfo")
            
            
            DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
            WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseWooPlus)
            WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                if WooPlusModel.sharedInstance().isExpired == false {
                    }
            }
            
        }
    }

    func pb_takeSnapshot() -> UIImage? {
        //let currentView:UIView = self.deckView.viewForCardAtIndex(self.deckView.currentCardIndex)!
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




    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func like(_ sender: AnyObject) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if UserDefaults.standard.bool(forKey: "firstTimeLiked") == false{
            self.showActionTutorialForType(.Like)
            return
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
        
        currentUserData = recommendationArray?.searchObjectAtIndex(deckView.currentCardIndex) as? ProfileCardModel
        //print(currentUserData!.wooId)
        
        self.perform(#selector(makeLikeSwipeNow), with: nil, afterDelay: 0.1)

    }
    @IBAction func sendCrush(_ sender: AnyObject) {
        currentUserData = recommendationArray?.searchObjectAtIndex(deckView.currentCardIndex) as? ProfileCardModel
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        self.crushButton.isUserInteractionEnabled = false

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
    
    fileprivate func disableActionableButtons(){
        self.passButton.isUserInteractionEnabled = false
        self.likeButton.isUserInteractionEnabled = false
        self.crushButton.isUserInteractionEnabled = false
    }
    
    fileprivate func performCrushSendingOperation(){
        let crushPurchaseHandlerClass:CrushPurchaseFlowHandler = CrushPurchaseFlowHandler(with: self)
        crushPurchaseHandlerClass.showSendCrushView(false)
        crushPurchaseHandlerClass.purchaseFlowCompleteHandler = {(crushText, isSendButtonTapped, isTemplateTapped) in
            self.performWorkAfterCrushPurchased(isSendButtonTapped: isSendButtonTapped, isTemplateTapped: isTemplateTapped, crushText: crushText)
        }
    }
    
    fileprivate func performWorkAfterCrushPurchased(isSendButtonTapped:Bool, isTemplateTapped:Bool, crushText:String){
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_SendCrush")
                
        self.enableButtonsNow()
        if isSendButtonTapped == false && isTemplateTapped == false{
            return
        }
        
        self.crushToBeSent = crushText as NSString?
        self.buttonActivity = .CrushSent
        self.like(UIButton())
        self.sendCrushViewObject = nil
        if DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload == true {
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+1)) {
                
                localProfileDeckViewObject.isHidden = true
                
            }
            
            if let localProfileDeckViewObject = self.deckView.viewForCardAtIndex(Int(self.deckView.currentCardIndex+2)) {
                localProfileDeckViewObject.isHidden = true
            }
        }
    }
    
    @IBAction func pass(_ sender: AnyObject) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if UserDefaults.standard.bool(forKey: "firstTimeDisliked") == false{
            self.showActionTutorialForType(.Dislike)
            return
        }
        
        self.passButton.isUserInteractionEnabled = false

        if let localProfileDeckViewObject = deckView.viewForCardAtIndex(Int(deckView.currentCardIndex)) as? ProfileDeckView {
            localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Left, isCrush: false, animationEnded: false)
        }
        self.perform(#selector(makePassSwipeNow), with: nil, afterDelay: 0.1)

    }
    
    @objc func makePaginationCall(){
        if self.deckView.currentCardIndex == 5 {
        
            if DiscoverProfileCollection.sharedInstance.tagSearchPaginationToken != "" && DiscoverProfileCollection.sharedInstance.tagSearchPaginationIndex != ""{
                
                DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: true, andPrefrence: false, isTagSelected: true, andCompletionBlock: { (success, response, statusCode) in
                    if success{
                        self.isPaginated = true
                        self.searchEmptyModel = DiscoverEmptyManager.sharedInstance.getDiscoverEmptyModelForType(DiscoverEmptySubCardType.SEARCH_EMPTY_END)
                        if let localSearchEmptyModel = self.searchEmptyModel{
                            //                        self.searchEmptyView.hidden = false
                            self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
                            self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
                        }
                        else{
                            self.searchEmptyTitleLabel.text = ""
                            self.searchEmptyDescriptionLabel.text = ""
                        }
                        if self.dataComingFromServerSoNeedToShowLoader == true{
                            self.dataComingFromServerSoNeedToShowLoader = false
                            self.reloadDeckView()
                        }
                    }
                })
                
//                DiscoverAPIClass.fetchDiscoverData(fromServer: true, andPrefrence: false, isTagSelected: true, andCompletionBlock: { (success, response, statusCode) in
//                    if success{
//                    self.isPaginated = true
//                        self.searchEmptyModel = DiscoverEmptyManager.sharedInstance.getDiscoverEmptyModelForType(DiscoverEmptySubCardType.SEARCH_EMPTY_END)
//                        if let localSearchEmptyModel = self.searchEmptyModel{
//                            //                        self.searchEmptyView.hidden = false
//                            self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
//                            self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
//                        }
//                        else{
//                            self.searchEmptyTitleLabel.text = ""
//                            self.searchEmptyDescriptionLabel.text = ""
//                        }
//                        if self.dataComingFromServerSoNeedToShowLoader == true{
//                        self.dataComingFromServerSoNeedToShowLoader = false
//                        self.reloadDeckView()
//                        }
//                    }
//                })
            }
        }
    }

}

//MARK: KolodaViewDelegate
extension TagSearchViewController: KolodaViewDelegate {
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            //            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return [.Up]
        }
        
            if areWeMovingUpOrLeftRight == "UP" {
                return [.Up]
            }
            else if areWeMovingUpOrLeftRight == "LEFTRIGHT"{
                return [.Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
            }
            else{
                    return [.Left, .Right, .Up, .TopLeft, .TopRight, .BottomLeft, .BottomRight]
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
        self.actionButtonsContainerView.isHidden = true
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            noInternetScreen.isHidden = false
            deckView.isHidden = true
            self.searchEmptyView.isHidden = true
        }
        else{
            if DiscoverProfileCollection.sharedInstance.istagSearchPaginationTokenExpired == true {
                self.deckView.isHidden = true
                showWooLoader()
                DiscoverProfileCollection.sharedInstance.searchModelCollection.removeAllObjects()
                fetchDiscoverData(false)
 
            }
            else{
                
                self.recommendationArray?.removeSearchItemsFromTop(koloda.currentCardIndex)
                
            }
            
            if self.recommendationArray?.searchDataCount() > 0 {
                self.deckView.isHidden = true
                self.reloadDeckView()
            }
            else{
                if DiscoverProfileCollection.sharedInstance.tagSearchPaginationToken == "" && DiscoverProfileCollection.sharedInstance.tagSearchPaginationIndex == "" {
                    self.deckView.isHidden = true
                    self.searchEmptyView.isHidden = false
                    self.actionButtonsContainerView.isHidden = true
                    if let localSearchEmptyModel = self.searchEmptyModel{
                        self.searchEmptyView.isHidden = false
                        self.searchEmptyTitleLabel.text = localSearchEmptyModel.title
                        self.searchEmptyDescriptionLabel.text = localSearchEmptyModel.modelDescription
                    }
                    else{
                        self.searchEmptyTitleLabel.text = ""
                        self.searchEmptyDescriptionLabel.text = ""
                    }
                }
                else{
                    self.dataComingFromServerSoNeedToShowLoader = true
                    showWooLoader()
                }
            }
        }
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool{
        return false
        if self.isPaginated {
            self.isPaginated = false
            return false
        }
        else{
            return true
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        if let userDetails =  self.recommendationArray?.searchObjectAtIndex(Int(index)) as? ProfileCardModel{
            selectedCommonality = ""
            currentUserData = userDetails
            makeTheProfileDeckBig()
        }
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        actionHasBeenTakenOnProfile = true
        
        if let userDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel{
            userDetails.isProfileSeen = true
        }
        else if  let cardDetails =  self.recommendationArray?.objectAtIndex(Int(index)) as? BrandCardModel{
            cardDetails.isBrandCardSeen = true
        }
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(Int(index+1)) as? ProfileDeckView {
            
            localProfileDeckViewObject.updateAlphaForOverlayView(0)
            
        }
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(Int(index+2)) as? ProfileDeckView {
            
            localProfileDeckViewObject.updateAlphaForOverlayView(1)
            
        }
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(Int(index+3)) as? ProfileDeckView {
            
            localProfileDeckViewObject.updateAlphaForOverlayView(2)
            
        }
        
        
        if (direction == .Right || direction == .TopRight || direction == .BottomRight) {
            //Make Like Call
            self.handleRightSwipeForIndex(Int(index))
        }
        else if (direction == .Left || direction == .TopLeft || direction == .BottomLeft){
            //Make Pass Call
            self.handleLeftForIndex(Int(index))
        }
        
        makePaginationCall()
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, inDirection direction: SwipeResultDirection, withGesture gestureRecognizerState:UIPanGestureRecognizer) {
        
        koloda.isUsedInTagSearch = true
        if ((koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView) != nil) {
            
            if gestureRecognizerState.state == .ended{
                if direction == .Right || direction == .BottomRight || direction == .TopRight{
                    if UserDefaults.standard.bool(forKey: "firstTimeLiked") == false{
                        koloda.resetPositionOfCurrentCard()
                        (koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView)?.updateBackgroundColorAndLabelTextOfOverlayView(.Right, isCrush: false, animationEnded: true)
                        self.showActionTutorialForType(.Like)
                        return
                    }
                }
                else if direction == .Left || direction == .BottomLeft || direction == .TopLeft{
                    if UserDefaults.standard.bool(forKey: "firstTimeDisliked") == false{
                        koloda.resetPositionOfCurrentCard()
                        (koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView)?.updateBackgroundColorAndLabelTextOfOverlayView(.Right, isCrush: false, animationEnded: true)
                        self.showActionTutorialForType(.Dislike)
                        return
                    }
                }
            }
        }
        
        if ((koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView) != nil) {
            if checkIfUserWillSeeOutOfLikeAlert() {
                if gestureRecognizerState.state == .began || gestureRecognizerState.state == .ended {
                    if (direction == .Right || direction == .TopRight || direction == .BottomRight){
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
        
        if let localProfileDeckViewObject = koloda.viewForCardAtIndex(koloda.currentCardIndex) as? ProfileDeckView {
            
            if direction == .Right || direction == .TopRight || direction == .BottomRight{
            localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Right, isCrush:  false,animationEnded: false)
            }
            else if direction == .Left || direction == .TopLeft || direction == .BottomLeft{
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(SwipeResultDirection.Left, isCrush:  false,animationEnded: false)
            }

            if gestureRecognizerState.state == .began {
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
                localProfileDeckViewObject.updateBackgroundColorAndLabelTextOfOverlayView(direction, isCrush: false, animationEnded: true)
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                }
            }
            else{
                if direction == .Up{
                    if let userDetails =  self.recommendationArray?.searchObjectAtIndex(Int(self.deckView.currentCardIndex)) as? ProfileCardModel{
                        if cardIsMovingUpwards == false {
                        selectedCommonality = ""
                        currentUserData = userDetails
                        makeTheProfileDeckBig()
                            cardIsMovingUpwards = true
                        }
                    }
                }
                
            }
            
        }
        
    }
    
}

//MARK: KolodaViewDataSource
extension TagSearchViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> UInt {
        if (self.recommendationArray != nil && self.recommendationArray?.searchDataCount() > 0) {
                        
            return UInt((self.recommendationArray?.searchDataCount())!)
        }
        
        return 0
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAtIndex index: UInt){
        print("cureenssfffff =  \(self.deckView.currentCardIndex)")
        
        checkForLikeLimit()
        
        if self.recommendationArray?.searchDataCount()>0 {
            if let userDetails =  self.recommendationArray?.searchObjectAtIndex(Int(index)) as? ProfileCardModel{
                if self.isPaginated == true {
                    showOrHideActionButtonsContainerView(true)
                }
                else{
                    self.perform(#selector(showActionButtonsWithDelay), with: nil, afterDelay: 0.5)
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
            self.actionButtonsContainerView.isHidden = true
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        koloda.isUsedInTagSearch = true
        if let userDetails =  self.recommendationArray?.searchObjectAtIndex(Int(index)) as? ProfileCardModel{
            
            let profileDeckViewObject : ProfileDeckView = ProfileDeckView.init(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
            profileDeckViewObject.delegate = self
            profileDeckViewObject.crushMessageContainerViewYValue = actionButtonsContainerView.frame.origin.y
            
            profileDeckViewObject.aboutMeLabelContainerViewYValue = actionButtonsContainerView.frame.origin.y
            
            profileDeckViewObject.profileDetails = userDetails
            
            profileDeckViewObject.animateViewComponent = true
            
            profileDeckViewObject.gettingUsedInTagSearch = true
        
            profileDeckViewObject.setDataForProfileView(false)
            
            profileDeckViewObject.needTobeShownOrHiddenAsBeingShownInDeck()
            
            profileDeckViewObject.updateAlphaForOverlayView(index)
            
            if self.isPaginated == true {
                self.isPaginated = false
                if snapShotImage != nil {
                    if Int(index) == koloda.currentCardIndex {
                        //profileDeckViewObject.addADummyImageViewWithSnapShotToAvoidFlickerWhileReloadingDeck(localSnapImage)
                    }
                }
            }
            
            return profileDeckViewObject
        }
        else{
            let dummyViewObject : UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: deckView.frame.size.width, height: deckView.frame.size.height))
            
            return dummyViewObject
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> UIView? {
//        if (self.recommendationArray?.objectAtIndex(Int(index)) as? ProfileCardModel) != nil{
//            return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
//        }
//        else{
            return nil
       // }
    }

}

//MARK: ProfileDeckView Delegate
extension TagSearchViewController: ProfileDeckViewDelegate {
    func getTheSelectedCommonality(_ commonalitySelected:String){
        selectedCommonality = commonalitySelected
        currentUserData = recommendationArray?.searchObjectAtIndex(Int(deckView.currentCardIndex)) as? ProfileCardModel
        makeTheProfileDeckBig()
    }
}
