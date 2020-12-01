//
//  HomeViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 23/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
//import AccountKit

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


var chatPresentBlock : (NSDictionary, HomeViewController) -> () = { (matchData, home) in
    
    MyMatches.insertDataInMyMatches(from: NSArray(objects: matchData) as [AnyObject], withChatInsertionSuccess:
        {(succes) in     let matchedUserDataFromDb = MyMatches.getMatchDetail(forMatchID: matchData.object(forKey: "matchId") as? String)
            if matchedUserDataFromDb != nil {
                home.performSegue(withIdentifier: SegueIdentifier.HomeToChatSegue.rawValue, sender: matchedUserDataFromDb)
            }

    })
}

@objc class HomeViewController: UIViewController, UITabBarDelegate, UINavigationControllerDelegate {
// MARK: variables

    var counterThresholdReached : Bool = false
    var growthAnimationSeenForMe : Bool = false
    var growthAnimationSeenForMatchbox : Bool = false

    var counterTimer : Timer?
    
    @IBOutlet weak var overlayButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var matchboxContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var discoverContainerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var meContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutMeContainer: UIView!
    
    @IBOutlet weak var discoverContainer: UIView!
    
    @IBOutlet weak var matchBoxContainer: UIView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var overlayButton: UIButton!
    
    fileprivate var matchData :NSDictionary?
    
    fileprivate var matchButtonType : OverlayButtonType?
    
    var screenArray = NSMutableArray();
    
    var isTabBarHidden = false
    
    var isOpenedFromDiscoverEmpty = false
    
    var isOpenedFromSideMenu = false
    
    var crushFunnelMessage:String = ""

    public var currentTabBarIndex : Observable<Int> = Observable(0)
    
    @objc public var currentTabBarIndexObjc: NSNumber? {
        get {
            return currentTabBarIndex.get() as NSNumber?
        }
        set(newNumber) {
            currentTabBarIndex.set((newNumber?.intValue) ?? 0)
        }
    }
    
    var dismissHandler:((Bool)->Void)!
    
    var phoneVerifiedAccessTokenHandler:((String, Bool)->Void)!
    
    fileprivate var containerView:UIView?
    fileprivate var feedbackAlertViewObj:U2AlertView?
    fileprivate var feedbackTextviewObj:UITextView?
    fileprivate var placeholderLabel:UILabel?
    fileprivate var accountKit = AccountKit(responseType: .accessToken)

    var lastIndexBeforeOpeningDrawer = 0
// MARK: ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.showFreeTrail), name: NSNotification.Name(rawValue: "freeTrailPopUP"), object: nil)
        
        if(counterTimer == nil)
        {
            counterTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateCounterThresholdTime), userInfo: nil, repeats: false)
        }
        screenArray.add(aboutMeContainer)
        screenArray.add(discoverContainer)
        screenArray.add(matchBoxContainer)
        
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "10"){
            let attributes0 = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 117/255, green: 196/255, blue: 219/255, alpha: 1)]
            tabBar.items?[0].setTitleTextAttributes(attributes0, for: .selected)
            
            let attributes1 = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 146/255, green: 117/255, blue: 219/255, alpha: 1)]
            tabBar.items?[1].setTitleTextAttributes(attributes1, for: .selected)
            
            let attributes2 = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 117/255, green: 219/255, blue: 135/255, alpha: 1)]
            tabBar.items?[2].setTitleTextAttributes(attributes2, for: .selected)
            
            let attributes3 = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 0/255, green: 93/255, blue: 252/255, alpha: 1)]
            tabBar.items?[3].setTitleTextAttributes(attributes3, for: .selected)

            let more : UITabBarItem = (tabBar.items)![3]
            more.image = UIImage(named: "ic_discover_more")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            more.selectedImage = UIImage(named: "ic_discover_more")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        
        tabBar.selectedItem = (tabBar.items)![1]
        self.tabBar(tabBar, didSelect: (tabBar.items)![1])
        
        checkIfBoostActive()
        
        checkAndShowUnreadBadgeOnMatchIcon()
        checkAndshowUnreadBadgeOnAboutMeIcon()
        
        view.bringSubviewToFront(discoverContainer as UIView)
        view.bringSubviewToFront(tabBar as UIView)
        
        
        let isFemaleEventSent: Bool! = UserDefaults.standard.bool(forKey:"isFemaleEventSent")
        if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender != "MALE")
        {
            if(!isFemaleEventSent || isFemaleEventSent == nil){
                (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName:"FEMALE")
                FBAppEvents.logEvent("FEMALE")
                UserDefaults.standard.set(true, forKey: "isFemaleEventSent")
            }
        }
        
//        if(UserDefaults.standard.bool(forKey: "showPopUpforUpgradeApp")){
//            let upgradeAlert = UIAlertController(title: kUpgradepopupHeader, message: kUpgradepopupcontent, preferredStyle: UIAlertController.Style.alert)
//            
//            upgradeAlert.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { (action: UIAlertAction!) in
//                print("Handle Ok logic here")
//            }))
//            
//            if(!UserDefaults.standard.bool(forKey: "isForceUpdate")){
//              
//                upgradeAlert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: { (action: UIAlertAction!) in
//                    print("Handle Cancel Logic here")
//                }))
//                
//            }
//            present(upgradeAlert, animated: true, completion: nil)
//        }
        
//                let chatView = TopChatView.sharedInstance()
//                chatView?.setNotificationTypeFor(NotificationType.chatBoxLanding)
//                chatView?.showNewChatMessage(fromTop: "aaya yha pe")
    }
    

    @objc func showFreeTrail(){
        if UserDefaults.standard.value(forKey: "isFreetrailShown") == nil{
            provideFreeTrail()
           
        }else{
            if(UserDefaults.standard.value(forKey: "isFreetrailShown") as! Bool){
                provideFreeTrail()
            }
        }
    }
    
    func provideFreeTrail(){
        if(FreeTrailModel.sharedInstance().planId.count > 0){
            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:FreeTrailUnlock = Bundle.main.loadNibNamed("FreeTrailUnlock", owner: window.rootViewController, options: nil)?.first as! FreeTrailUnlock
            purchaseObj.initiatedView = "FreeTrail_getwooplus"
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "FreeTrail_getwooplus")
            
            purchaseObj.loadPopupOnWindowForFreeTrail()
            UserDefaults.standard.set(false, forKey: "isFreetrailShown")
            purchaseObj.purchasedHandlerFreeTrail = {(purchased:Bool) in
                if(purchased){
                    FreeTrailModel.sharedInstance().updateData(withOfferDtoDictionary: [:])
                    AppLaunchModel.sharedInstance()!.isChatEnabled = true
                }
            }
        }
    }
    
    @objc func updateCounterThresholdTime()
    {
        counterThresholdReached = true
        checkAndShowUnreadBadgeOnMatchIcon()
        checkAndshowUnreadBadgeOnAboutMeIcon()
        counterTimer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentTabBarIndex.set(currentTabBarIndex.get())
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.invalidateIntrinsicContentSize()
               if #available(iOS 11.0, *) {
                       if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                                meContainerViewTopConstraint.constant = 0.0
                                discoverContainerViewConstraint.constant = 0.0
                                  matchboxContainerViewTopConstraint.constant = 0.0
                        if (isIphoneX()){
                                    meContainerViewTopConstraint.constant = 20
                                        discoverContainerViewConstraint.constant = 20
                                        matchboxContainerViewTopConstraint.constant = 20
                    overlayButtonTopConstraint.constant = 0.0
                        }else if (isIphoneXSMAX() || isIphoneXR()){
                            meContainerViewTopConstraint.constant = 30
                            discoverContainerViewConstraint.constant = 30
                            matchboxContainerViewTopConstraint.constant = 30
                            overlayButtonTopConstraint.constant = 0.0
                        }
            }

    }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier ?? "")
        if (segue.identifier == SegueIdentifier.NewMtchSegue.rawValue) {
            let matchOverlayController = segue.destination as! NewMatchViewController
            matchOverlayController.matchData = self.matchData
            matchOverlayController.buttonType = self.matchButtonType!
        }
        else if segue.identifier == SegueIdentifier.HomeToChatSegue.rawValue {
            if sender != nil {
                let chatViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
                let chatViewControllerObj: NewChatViewController  = chatViewNavControllerObj.viewControllers.first as! NewChatViewController
                
                let model = sender as! MyMatches
                chatViewControllerObj.myMatchesData = model
                chatViewControllerObj.parentView = .homeView
                chatViewControllerObj.isAutomaticallyPushedFromChat = true
                chatViewControllerObj.delegateFromMatch = self
            }
        }
    }
    
    @IBAction func closeDrawer(_ sender: UIButton) {
        self.tabBar(tabBar, didSelect: (tabBar.items)![3])
    }
    
    func showMatchOverlay(_ matchData: NSDictionary, buttonType: OverlayButtonType) {
        self.matchData = matchData
        self.matchButtonType = buttonType
        self.performSegue(withIdentifier: SegueIdentifier.NewMtchSegue.rawValue, sender: self)
    }
    
    func hideTabBar(_ isAnimated: Bool) {
        if isTabBarHidden {
            return
        }

        if isAnimated {
            UIView.animate(withDuration: 0.25, animations: { 
                self.tabBar.transform = CGAffineTransform(translationX: 0, y: 60 + safeAreaBottom)
            })
        }
        else{
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 60 + safeAreaBottom)
        }
        isTabBarHidden = true
    }
    
    func showTabBar(_ isAnimated: Bool) {
        if !isTabBarHidden {
            return
        }
        
        if isAnimated {
            UIView.animate(withDuration: 0.25, animations: {
                self.tabBar.transform = CGAffineTransform.identity
            })
        }
        else{
            self.tabBar.transform = CGAffineTransform.identity
        }
        isTabBarHidden = false
    }
    
    @objc func moveToTab(_ tabIndex : Int) {
        tabBar.selectedItem = (tabBar.items)![tabIndex]
        self.tabBar(tabBar, didSelect: (tabBar.items)![tabIndex])
    }
  
    
    
    func checkRecursively<T>(_ view:UIView ,kindOfView viewType:T.Type)
    {
        if(view.subviews.count > 0)
        {
            for subview in view.subviews
            {
                NSLog("checkRecursively \(subview.description)")
                if(subview is T)
                {
                    subview.removeFromSuperview()
                }
                else
                {
                    checkRecursively(subview, kindOfView: viewType)
                }
            }
            
        }
    
    }
    
    
// MARK: UITabBarDelegate methods
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){

            if item.tag == 3 {
                
                if overlayButton.isHidden {
                    overlayButton.isHidden = false
                    lastIndexBeforeOpeningDrawer = currentTabBarIndex.get()
                    WooScreenManager.sharedInstance.openDrawerSlider()
                    //currentTabBarIndex.set(item.tag)
                }
                else{
                    overlayButton.isHidden = true
                    tabBar.selectedItem = (tabBar.items)![lastIndexBeforeOpeningDrawer]
                    self.tabBar(tabBar, didSelect: (tabBar.items)![lastIndexBeforeOpeningDrawer])
                    currentTabBarIndex.set(lastIndexBeforeOpeningDrawer)
                    WooScreenManager.sharedInstance.openDrawerSlider()
                }
            }
            else{
                if currentTabBarIndex.get() != item.tag {
                currentTabBarIndex.set(item.tag)
                overlayButton.isHidden = true
                let currentScreen = self.screenArray.object(at: self.currentTabBarIndex.get())
                let nextScreen = self.screenArray.object(at: item.tag)
                   
                //Fix for chat notifications trasnsition
                    let currentNavigation =  self.children[item.tag] as! UINavigationController
                    
                if(currentNavigation.viewControllers.count > 1)
                {
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
                }

                    UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                    (currentScreen as! UIView).alpha = 0.0
                    (currentScreen as! UIView).alpha = 1.0
                    }, completion: { (isAnimated) in
                })
                    
                    switch item.tag
                    {
                   
                    case 0:
                        discoverContainer.isHidden = true
                        matchBoxContainer.isHidden = true
                        aboutMeContainer.isHidden = false
                        break;
                    case 1:
                        discoverContainer.isHidden = false
                        matchBoxContainer.isHidden = true
                        aboutMeContainer.isHidden = true
                        break;
                    case 2:
                        discoverContainer.isHidden = true
                        matchBoxContainer.isHidden = false
                        aboutMeContainer.isHidden = true
                        break;
                    default:
                        break;
                    }
                
                    
                    
//                if(item.tag != 1)
//                {
//                   discoverContainer.isHidden = true
//                }
//                else
//                {
//                    discoverContainer.isHidden = false
//                }
                    self.view.bringSubviewToFront(nextScreen as! UIView)
                    self.view.bringSubviewToFront(overlayButton)
                    view.bringSubviewToFront(tabBar as UIView)
            }
                else{
                    if DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded == true {
                        currentTabBarIndex.set(item.tag)
                    }
                }
        }

    }
    
    func isModalPresent() -> Bool{
        if (self.presentingViewController != nil){
            return true
        }
        if (self.isBeingPresented) {
            return true
        }
        if self.tabBarController?.presentingViewController is UITabBarController{
            return true
        }
        return false;
    }

    func presentViewController(_ identifier : DeepLinkingOptions, parameter: String = "") {
        
        NSLog("HomeVc \(String(describing: presentViewController))")
        
        if(WooScreenManager.sharedInstance.isDrawerOpen)
        {
            WooScreenManager.sharedInstance.isDrawerOpen = false
            overlayButton.isHidden = true
            tabBar.selectedItem = (tabBar.items)![lastIndexBeforeOpeningDrawer]
//            currentTabBarIndex.set(lastIndexBeforeOpeningDrawer)
//            self.tabBar(tabBar, didSelect: (tabBar.items)![lastIndexBeforeOpeningDrawer])
            WooScreenManager.sharedInstance.drawerController?.closeDrawer(animated: true, completion: { (isAnimated) in
                WooScreenManager.sharedInstance.drawerController!.rightDrawerViewController = nil
            })
        }
        //if alertcontrollers are open
        let currentNavigation =   self.children[(self.currentTabBarIndex.get())] as! UINavigationController
        if(currentNavigation.viewControllers.last?.presentedViewController is UIAlertController)
        {
            currentNavigation.viewControllers.last?.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        
        let window:UIWindow = UIApplication.shared.keyWindow!
        
        //checkRecursively for OutOfLikes
         checkRecursively(window.subviews.last!, kindOfView: OutOfLikeView.self)
        
        //If any of these popups are visible
        if let subViews = window.subviews.last{
            if let subView = subViews.subviews.last{
        if (subView as UIView) is PurchasePopup ||  (subView as UIView) is DropOffPurchasePopup
            || (subView as UIView) is VoiceCallIntroductionPopup || (subView as UIView) is OutOfLikeView || (subView as UIView) is PostMatchTipsView || (subView as UIView) is NewMatchOverlayView || (subView as UIView) is PostFeedbackContactView
                {
                    NSLog("Removing open Views")
                    (subView as UIView).removeFromSuperview()
                }
            }
        }
        
        //Dismiss phone verification if open
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhoneVerify"), object: nil))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dismissPhotoSelection"), object: nil))

        switch identifier {
        case .Me :
            if(self.currentTabBarIndex.get() != 0)
            {
                self.moveToTab(0)
            }
            else
            {
                let currentNavigation =   self.children[(self.currentTabBarIndex.get())] as! UINavigationController
                currentNavigation.popToRootViewController(animated: true)
            }
            break
        case .FemaleTutorial:
            let femaleTutorialViewController:FemaleTutorialViewController = FemaleTutorialViewController(nibName: "FemaleTutorialViewController", bundle: Bundle.main)
            
            if UserDefaults.standard.bool(forKey: "tutorialNotShown"){
                femaleTutorialViewController.isPartOfOnBoarding = true
            }else{
                femaleTutorialViewController.isPartOfOnBoarding = false
            }
            
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        
            
//            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
////            currentNavigation.hidesBottomBarWhenPushed = true
//            currentNavigation.modalPresentationStyle = .fullScreen
//            currentNavigation.pushViewController(femaleTutorialViewController, animated: false)
            let navController = UINavigationController(rootViewController: femaleTutorialViewController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: false, completion: nil)
            
            break
        case .AnalyzeProfile :
            let performanceVC = PerformanceAnalysisViewController(nibName: "PerformanceAnalysisViewController", bundle: nil)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(performanceVC, animated: true)
            break
        case .Settings :
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myPreferencesViewController =
                storyboard.instantiateViewController(withIdentifier: kMyPreferencesController)
                    as? MyPreferencesViewController
            
            //let navController = UINavigationController(rootViewController: myPreferencesViewController!)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            print(currentNavigation.viewControllers.first!)

            if (currentNavigation.viewControllers.last! is MyPreferencesViewController) == false
            {
                myPreferencesViewController?.isComingFromMatchbox = currentNavigation.viewControllers.last! is MatchBoxViewController
                currentNavigation.pushViewController(myPreferencesViewController!, animated: true)
            }
            
            //(myPreferencesViewController!, animated: true, completion: nil)
            break
        case .Search :
            break
        case .PurchaseBoost :
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }

            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
            if isOpenedFromSideMenu{
            purchaseObj.initiatedView = "Bannerad_boost_tap"
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Bannerad_boost_tap")

            }
            else{
            purchaseObj.initiatedView = "Boost_brandcard"
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Boost_brandcard")
            }
            purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                if self.dismissHandler != nil {
                    self.dismissHandler(true)
                }
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                    DispatchQueue.main.async
                        {
                            if self.dismissHandler != nil {
                                self.dismissHandler(true)
                            }
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }

            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
            break
        case .PurchaseCrush:
            
            
            if let snackBar = UIApplication.shared.keyWindow!.subviews.last as? MDSnackbar {
                snackBar.dismiss()
                self.perform(#selector(openCrushPurchasePopup), with: nil, afterDelay: 0.5)
            }else{
                openCrushPurchasePopup()
            }
            
            
        case .PurchaseWooPlus :
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }

            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
            purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                if self.dismissHandler != nil {
                    self.dismissHandler(true)
                }
            }
            if isOpenedFromDiscoverEmpty == true {
                purchaseObj.scrollableIndex = 5
            }
            if isOpenedFromSideMenu{
                purchaseObj.initiatedView = "Bannerad_WP_tap"
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Bannerad_WP_tap")
            }
            else{
                purchaseObj.initiatedView = "WP_brandcard"
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "WP_brandcard")
            }

            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[lastIndexBeforeOpeningDrawer] as! UINavigationController
            
            purchaseObj.purchaseShownOnViewController = currentNavigation.viewControllers.last!
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                    DispatchQueue.main.async
                        {
                            if self.dismissHandler != nil {
                                self.dismissHandler(true)
                            }
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
            break
            
        case .PurchaseWooGlobe :
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
            purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                if self.dismissHandler != nil {
                    self.dismissHandler(true)
                }
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                    DispatchQueue.main.async
                        {
                            if self.dismissHandler != nil {
                                self.dismissHandler(true)
                            }
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
            break

        case .PhoneVerify :
            break
        case .EditProfile :
            let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
            if parameter.count > 0 {
                switch parameter {
                case "addPics":
                    controller.scrollToIndex = .Photo
                    break
                case "syncLinkedin":
                    controller.scrollToIndex = .LinkedIn
                    break
                case "addTags":
                    controller.scrollToIndex = .Tags
                    break
                case "addPersonalQuotes":
                    controller.scrollToIndex = .PersonalQuote
                    break
                case "addPhoneNumber":
                    controller.scrollToIndex = .Phone
                    break
                case "addHeight":
                    controller.scrollToIndex = .Height
                    break
                case "addWork":
                    controller.scrollToIndex = .Work
                    break
                case "addEducation":
                    controller.scrollToIndex = .Education
                    break
                default:
                    controller.scrollToIndex = .None
                }
            }
            controller.dismissHandler = { (needToShowMyProfile, toClose) in
                if needToShowMyProfile {
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let myProfileDPV =
                        storyboard.instantiateViewController(withIdentifier: "ProfileDeckDetailViewControllerID")
                            as? ProfileDeckDetailViewController
                    myProfileDPV?.profileData = DiscoverProfileCollection.sharedInstance.myProfileData! as ProfileCardModel
                    myProfileDPV?.isMyProfile = true
                    let currentNavigation =  self.children[self.currentTabBarIndex.get()] as! UINavigationController
                    if (currentNavigation.viewControllers.last! is EditProfileViewController) == false
                    {
                        currentNavigation.pushViewController(myProfileDPV!, animated: true)
                    }
                    else{
                        self.navigationController?.pushViewController(myProfileDPV!, animated: true)
                    }
                    
//                    if(self.currentTabBarIndex.get() != 1)
//                    {
//                    //DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
//                        //WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
//
//                    }
//                    else
//                    {
//                        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
//                        DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
//                        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
//                          WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
//                    }
                    
                }
            }
//            let navController = UINavigationController(rootViewController: controller)
//            self.present(navController, animated: true, completion: nil)
            
            let currentNavigation =   self.children[(self.currentTabBarIndex.get())] as! UINavigationController
            currentNavigation.popToRootViewController(animated: true)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
//            let currentNavigation =  self.childViewControllers[currentTabBarIndex.get()] as! UINavigationController
            if (currentNavigation.viewControllers.last! is EditProfileViewController) == false
            {
                currentNavigation.pushViewController(controller, animated: true)
            }
            break
        case .EnableNotification :
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            break
        case .FeedbackAppStore :
            (Utilities.sharedUtility() as AnyObject).openURL(forURLString: String(format: "itms-apps://itunes.apple.com/app/id885397079"))
            break
        case .Feedback :
//            feedBackButtonTapped()
            
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let feedbackObj =
                storyboard.instantiateViewController(withIdentifier: kMyFeedbackController)
                    as? WriteAnswerViewController
            feedbackObj!.screenType = .feedback
            feedbackObj!.isOpenedFromSettings = false
           // let navController = UINavigationController(rootViewController: feedbackObj!)
//            self.present(feedbackObj!, animated: true, completion: nil)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
           //To do - Check if Write Answer is open for feeback
            currentNavigation.pushViewController(feedbackObj!, animated: true)


            break
        case .likedMeSection :
//                let storyboard = UIStoryboard(name: "Home", bundle: nil)
//                let oLikedMeDashboardViewController =
//                    storyboard.instantiateViewController(withIdentifier: kLikedMeViewController)
//                        as? LikedMeViewController
////                let navController = UINavigationController(rootViewController: oLikedMeDashboardViewController!)
////                self.present(navController, animated: true, completion: nil)
//                let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
//                if (currentNavigation.viewControllers.last! is LikedMeViewController) == false
//                {
//                    currentNavigation.pushViewController(oLikedMeDashboardViewController!, animated: true)
//                }
//                else
//                {
//                    //reload
//                }
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                           let oVisitorDashboardViewController =
                               storyboard.instantiateViewController(withIdentifier: kVisitorsViewController)
                                   as? VisitorViewController
                           let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
                           NSLog("visitorsSection \(currentNavigation)")

                           if (currentNavigation.viewControllers.last! is VisitorViewController) == false
                           {
                               currentNavigation.pushViewController(oVisitorDashboardViewController!, animated: true)
                           }
                           else
                           {
                               //reload
                           }
            break
            
          
        case .skippedSection :
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let oSkippedDashboardViewController =
                storyboard.instantiateViewController(withIdentifier: kSkippedViewController)
                    as? SkippedProfileViewController
//            let navController = UINavigationController(rootViewController: oSkippedDashboardViewController!)
//            self.present(navController, animated: true, completion: nil)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            if (currentNavigation.viewControllers.last! is SkippedProfileViewController) == false
            {
                currentNavigation.pushViewController(oSkippedDashboardViewController!, animated: true)
            }
            else
            {
                //reload
            }
            break
        case .visitorsSection :
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let oVisitorDashboardViewController =
                    storyboard.instantiateViewController(withIdentifier: kVisitorsViewController)
                        as? VisitorViewController
                let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
                NSLog("visitorsSection \(currentNavigation)")

                if (currentNavigation.viewControllers.last! is VisitorViewController) == false
                {
                    currentNavigation.pushViewController(oVisitorDashboardViewController!, animated: true)
                }
                else
                {
                    //reload
                }


//                let navController = UINavigationController(rootViewController: oVisitorDashboardViewController!)
//                self.present(navController, animated: true, completion: nil)

            break
        case .crushSection :
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let oCrushDashboardViewController =
                storyboard.instantiateViewController(withIdentifier: kCrushesViewController)
                    as? CrushPanelViewController
//            let navController = UINavigationController(rootViewController: oCrushDashboardViewController!)
//            self.present(navController, animated: true, completion: nil)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            if (currentNavigation.viewControllers.last! is CrushPanelViewController) == false
            {
                currentNavigation.pushViewController(oCrushDashboardViewController!, animated: true)
            }
            else
            {
                //reload
            }

            
            break
        case .tagSelectionScreen :
            /*
            let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
            let oTagSelectionViewController =
                storyboard.instantiateViewController(withIdentifier: kTagSelectionViewController)
                    as? TagScreenViewController
            */
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            
            let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
            wizardTagsVC.isUsedOutOfWizard = true
            if (currentNavigation.viewControllers.last! is WizardTagsViewController) == false
            {
                currentNavigation.pushViewController(wizardTagsVC, animated: true)
            }
            
            break
        case .ReferFriend :
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myWebViewViewController =
                storyboard.instantiateViewController(withIdentifier: kInviteCampaignViewController)
                    as? InviteFriendsSwiftViewController
            //            myWebViewViewController?.navTitle = NSLocalizedString("FAQs", comment: "FAQ web view title")
            //            myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().faqUrl
//            let navController = UINavigationController(rootViewController: myWebViewViewController!)
//            self.present(navController, animated: true, completion: nil)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(myWebViewViewController!, animated: true)

            
            break
        case .MyPurchase :
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let oMyPurchaseViewController =
                storyboard.instantiateViewController(withIdentifier: kMyPurchaseViewController)
                    as? MyPurchaseViewController
//            let navController = UINavigationController(rootViewController: oMyPurchaseViewController!)
//            self.present(navController, animated: true, completion: nil)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            if (currentNavigation.viewControllers.last! is MyPurchaseViewController) == false
            {
                currentNavigation.pushViewController(oMyPurchaseViewController!, animated: true)
            }
            
            break
        case .MyWebViewFAQ :
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myWebViewViewController =
                storyboard.instantiateViewController(withIdentifier: kMyWebViewController)
                    as? WkWebViewController
            myWebViewViewController?.isNotComingThroughLogin = true
            myWebViewViewController?.navTitle = NSLocalizedString("FAQs", comment: "FAQ web view title")
            print(AppLaunchModel.sharedInstance().faqUrl ?? "na ho paayi faq url")
            print(type(of: AppLaunchModel.sharedInstance().faqUrl))
            myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().faqUrl
//            let navController = UINavigationController(rootViewController: myWebViewViewController!)
//            self.present(navController, animated: true, completion: nil)

            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(myWebViewViewController!, animated: true)

            break
            
        case .InviteCampaign :
         let storyboard = UIStoryboard(name: "Home", bundle: nil)
         let myWebViewViewController =
                storyboard.instantiateViewController(withIdentifier: kInviteCampaignViewController)
                    as? InviteFriendsSwiftViewController
//            myWebViewViewController?.navTitle = NSLocalizedString("FAQs", comment: "FAQ web view title")
//            myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().faqUrl
//            let navController = UINavigationController(rootViewController: myWebViewViewController!)
//            self.present(navController, animated: true, completion: nil)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
         let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(myWebViewViewController!, animated: true)

            break
            
        case .MyWebViewTC :
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myWebViewViewController =
                storyboard.instantiateViewController(withIdentifier: kMyWebViewController)
                    as? WkWebViewController
            myWebViewViewController?.isNotComingThroughLogin = true
            myWebViewViewController?.navTitle = NSLocalizedString("T&C", comment: "terms url")
            myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().termsUrl
//            let navController = UINavigationController(rootViewController: myWebViewViewController!)
//            self.present(navController, animated: true, completion: nil)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(myWebViewViewController!, animated: true)

            
            break
            
        case .Content_Guidelines :
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myWebViewViewController =
                storyboard.instantiateViewController(withIdentifier: kMyWebViewController)
                    as? WkWebViewController
            myWebViewViewController?.isNotComingThroughLogin = true
            myWebViewViewController?.navTitle = NSLocalizedString("Guidelines", comment: "GuideLines url")
            myWebViewViewController?.webViewUrl = NSURL(string: "http://www.getwooapp.com/contentguidelines.html")! as URL
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(myWebViewViewController!, animated: true)
            
            
            break
            
        case .Woo_TrueStory:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myWebViewViewController =
                storyboard.instantiateViewController(withIdentifier: kMyWebViewController)
                    as? WkWebViewController
            myWebViewViewController?.isNotComingThroughLogin = true
            myWebViewViewController?.navTitle = NSLocalizedString("Woo True Stories", comment: "Woo True Stories")
            myWebViewViewController?.webViewUrl = NSURL(string: wooTrueStoryUrl)! as URL
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            currentNavigation.pushViewController(myWebViewViewController!, animated: true)
            
            
        case .ethnicitySelectionScreen :
                openEthnicityScreen()
            break
        case .verifyPhoneNumber:
//            let storyboard = UIStoryboard(name: "Woo_3", bundle: nil)
//            let controller:UINavigationController = storyboard.instantiateViewController(withIdentifier: "VerifyNumberViewNavController") as! UINavigationController
//            let firstController:VerifyNumberViewController = controller.viewControllers.first as! VerifyNumberViewController
//            firstController.isOpenFromEditProfile = true
//            self.present(controller, animated: true, completion: nil)
//            firstController.verifyFlowdismissHandler = {() in
//                if self.dismissHandler != nil {
//                    self.dismissHandler(true)
//                }
//            }
            CommonPhoneNumberVerify.sharedInstance.controller = self
            CommonPhoneNumberVerify.sharedInstance.showLoaderAfterSucess = false
            CommonPhoneNumberVerify.sharedInstance.successHandler = {(isSuccess, statusCode) in
                self.phoneVerifiedAccessTokenHandler(String(statusCode), true)
            }
            
            if(!CommonPhoneNumberVerify.sharedInstance.canWeStartTrueCaller()){
              self.startFacebookPhoneVerifySteps()
            }
            
            break
        case .MyQuestions:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let myQuestionsController =
                storyboard.instantiateViewController(withIdentifier: kMyQuestionsController)
                    as? MyQuestionsController
            myQuestionsController?.isPresentedFromMyProfile = false
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
            if (currentNavigation.viewControllers.last! is MyQuestionsController) == false
            {
                currentNavigation.pushViewController(myQuestionsController!, animated: true)
            }
            break

        }
        
    }
    
    func openEthnicityScreen() {
        let optionScreen = EthnicitySelectionViewController.loadNib()
        optionScreen.mainDataSource = NSArray(contentsOfFile: Bundle.main.path(forResource: "Ethnicity", ofType:"plist")!)!
        optionScreen.maxmimumSelection = 2
        optionScreen.showSwitchButton = false
        let myProfileObj = DiscoverProfileCollection.sharedInstance.myProfileData
        //set selected ethinicity
        if myProfileObj?.ethnicity.count > 0 {
            optionScreen.selectedEthnicity = []
            for item in (myProfileObj?.ethnicity)! {
                let ethnicityName = item.name
                if((Int(item.tagId!)! > -1) && (item.isSelected == true)){
                    optionScreen.selectedEthnicity.append(ethnicityName!)
                }
            }
        }
        optionScreen.selectionHandler = { (selectedData) in
            let myProfileObj = ProfileCardModel()
            let selectedEhtnicityFromUser = (myProfileObj.professionModelArrayFromDto((selectedData as? [[String : AnyObject]])!))
            
            BrandCardAPI.updateSelectionCardPassStatus(onServer: "ETHNICITY", and: "0", andSelectedValues: selectedEhtnicityFromUser, withCompletionHandler: { (success, ethnicityResponse) in
                let selectedEhtnicity = (myProfileObj.professionModelArrayFromDto((ethnicityResponse as? [[String : AnyObject]])!))
//                self.profileData?.ethnicity = selectedEhtnicity
                myProfileObj.ethnicity = selectedEhtnicity
                
            })
        }
        optionScreen.viewControllerType = EthnicityClassType.TYPE_ETHNICITY
//        self.present(optionScreen, animated: true, completion: nil)
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
        if (currentNavigation.viewControllers.last! is EthnicitySelectionViewController) == false
        {
            currentNavigation.pushViewController(optionScreen, animated: true)
        }
    }
    
    
    func openMyPreference(showWooGlobePop showPopUp:Bool) {
        //open my preference
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let myPreferencesViewController =
            storyboard.instantiateViewController(withIdentifier: kMyPreferencesController)
                as? MyPreferencesViewController
        //let navController = UINavigationController(rootViewController: myPreferencesViewController!)
        
        if !UserDefaults.standard.bool(forKey: "isWooGlobePopUpShownToUser") {
            myPreferencesViewController?.showPostWooGlobePurchasePopUp = (true && showPopUp)
        }
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        let currentNavigation =  self.children[currentTabBarIndex.get()] as! UINavigationController
        if (currentNavigation.viewControllers.last! is MyPreferencesViewController) == false
        {
            currentNavigation.pushViewController(myPreferencesViewController!, animated: false)
        }
        //present(myPreferencesViewController!, animated: true, completion: nil)
    }
    
    @objc func openCrushPurchasePopup() {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }

        let window:UIWindow = UIApplication.shared.keyWindow!
        
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
        if crushFunnelMessage.count > 0{
        purchaseObj.initiatedView = crushFunnelMessage
        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: crushFunnelMessage)

        }
        else{
            if isOpenedFromSideMenu{
                purchaseObj.initiatedView = "Bannerad_crush_tap"
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Bannerad_crush_tap")
            }
            else{
                purchaseObj.initiatedView = "Crush_Brandcard"
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Crush_Brandcard")
            }
        }
        purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
            if self.dismissHandler != nil {
                self.dismissHandler(true)
            }
        }
        
        purchaseObj.popupDismissedHandler = {() in
            if self.dismissHandler != nil {
                self.dismissHandler(true)
            }
        }
        
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                DispatchQueue.main.async
                    {
                        if self.dismissHandler != nil {
                            self.dismissHandler(true)
                        }
                }
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)

        }
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
    }
    
    @objc func checkIfBoostActive() {
        if BoostModel.sharedInstance().currentlyActive{
            let Discover : UITabBarItem = (tabBar.items)![1]
            Discover.image = UIImage(named: "ic_discover_discover_inactive_boost")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            Discover.selectedImage = UIImage(named: "ic_discover_discover_active_boost")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        else{
            let Discover : UITabBarItem = (tabBar.items)![1]
            Discover.image = UIImage(named: "ic_discover_discover_inactive")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            Discover.selectedImage = UIImage(named: "ic_discover_discover_active")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
    }
    
    
    
    
    @objc func checkAndshowUnreadBadgeOnAboutMeIcon() -> Void {
        let aboutMeTabBarItem : UITabBarItem = (tabBar.items)![0]
        aboutMeTabBarItem.image = UIImage(named: "ic_discover_me")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        aboutMeTabBarItem.selectedImage = UIImage(named: "ic_discover_me_active")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshMeSection"), object: nil, userInfo: nil)
        /// if has been launched for greater than 2 secs
        if(counterThresholdReached)
        {
            if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE")
            {
                showBadgeCountforMeSection()
            }
            else
            {
                //set active inactive image with or without dot for unread count
                setTabbarIconforMeSection()
            }
        }
//        currentTabBarIndex.set(currentTabBarIndex.get())
    }
    
    func setTabbarIconforMeSection() -> Void
    {
        let aboutMeTabBarItem : UITabBarItem = (tabBar.items)![0]
        let count = Utilities().getTotalBadgeCount()
        if count > 0
        {
            aboutMeTabBarItem.image = UIImage(named: "ic_discover_me_inactive_reddot")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            aboutMeTabBarItem.selectedImage = UIImage(named: "ic_discover_me_reddot")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        else
        {
            aboutMeTabBarItem.image = UIImage(named: "ic_discover_me")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            aboutMeTabBarItem.selectedImage = UIImage(named: "ic_discover_me_active")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
    }
    
    func showBadgeCountforMeSection() -> Void
    {
        let aboutMeTabBarItem : UITabBarItem = (tabBar.items)![0]
        let count = Utilities().getTotalBadgeCount()
        if count > 0
        {
            if #available(iOS 10.0, *) {
                aboutMeTabBarItem.setBadgeTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont .systemFont(ofSize: 11.0)], for: .normal)
            } else {
                // Fallback on earlier versions
            }
            if count  <= 99
            {
                aboutMeTabBarItem.badgeValue = "\(count)"
            }
            else
            {
                aboutMeTabBarItem.badgeValue = "99+"
            }
            
            if(growthAnimationSeenForMe == false)
            {
                aboutMeTabBarItem.setCustomBadgeValue("\(count)", isFirstTimeForMe: true, andIsFirstTimeForMatchbox: false)
                growthAnimationSeenForMe = true
                //aboutMeTabBarItem.removeGrowthAnimation()
            }
            else
            {
                aboutMeTabBarItem.setCustomBadgeValue("\(count)", isFirstTimeForMe: false, andIsFirstTimeForMatchbox: false)
            }
            //            aboutMeTabBarItem.setCustomBadgeValue("\(count)")
        }
        else{
            aboutMeTabBarItem.badgeValue = nil
        }
    }
    
    
    @objc func checkAndShowUnreadBadgeOnMatchIcon() -> Void {
        let matchTabBarItem : UITabBarItem = (tabBar.items)![2]
            if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE")
            {
                matchTabBarItem.image = UIImage(named: "ic_discover_matchbox")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                matchTabBarItem.selectedImage = UIImage(named: "ic_discover_matchbox_active")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    if(counterThresholdReached)
                    {
                        showBadgeCountforMatchbox()
                    }

            }
            else
            {
                let matchCount = MyMatches.getAllUnreadMessage()
                if  matchCount != nil
                {

                    if matchCount?.count > 0 {
                        matchTabBarItem.image = UIImage(named: "ic_discover_matchbox_inactive_reddot")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                        matchTabBarItem.selectedImage = UIImage(named: "ic_discover_matchbox_reddot")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    }
                    else{
                        matchTabBarItem.image = UIImage(named: "ic_discover_matchbox")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                        matchTabBarItem.selectedImage = UIImage(named: "ic_discover_matchbox_active")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    }
                }
                else{
                    matchTabBarItem.image = UIImage(named: "ic_discover_matchbox")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    matchTabBarItem.selectedImage = UIImage(named: "ic_discover_matchbox_active")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                }
        }
       
    }
    
    func showBadgeCountforMatchbox()
    {
        let matchboxTabBarItem : UITabBarItem = (tabBar.items)![2]
        //To do
        let count = MyMatches.getAllUnreadMessage()?.count ?? 0
        if count > 0
        {
            if #available(iOS 10.0, *) {
                matchboxTabBarItem.setBadgeTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont .systemFont(ofSize: 11.0)], for: .normal)
            } else {
                // Fallback on earlier versions
            }
            if count  <= 99
            {
                matchboxTabBarItem.badgeValue = "\(count)"
            }
            else
            {
                matchboxTabBarItem.badgeValue = "99+"
            }
            
            if(growthAnimationSeenForMatchbox == false)
            {
                matchboxTabBarItem.setCustomBadgeValue("\(count)", isFirstTimeForMe: false, andIsFirstTimeForMatchbox: true)
                growthAnimationSeenForMatchbox = true
//                matchboxTabBarItem.removeGrowthAnimation()
            }
            else
            {
                matchboxTabBarItem.setCustomBadgeValue("\(count)", isFirstTimeForMe: false, andIsFirstTimeForMatchbox: false)
            }
        }
        else{
            matchboxTabBarItem.badgeValue = nil
        }
        
    }
    func openChatRoomForChatRoomId(_ chatRoomId: NSString) -> Void {
        print("chatRoomId ====== \(chatRoomId)")
        
//        NSNotificationCenter.defaultCenter().postNotificationName("moveToChatRoom", object: chatRoomId)
    }

    
    func postFeedBack(){
        if (feedbackTextviewObj?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))?.count < 1 {
            (Utilities.sharedUtility() as AnyObject).showToast(withText: "Please enter some text.")
            return
        }
        (Utilities.sharedUtility() as AnyObject).showToast(withText: NSLocalizedString("CMP00320", comment: ""))
        
        if feedbackTextviewObj?.text.count > 0 {
            
            AppSettingsApiClass.sendFeedback(toServer: feedbackTextviewObj?.text, andNumberOfStars: -1, andEmail: "", andPhoneNumber: "", withCompletionBlock: nil)
        }
        feedbackAlertViewObj?.removeFromSuperview()
    }
    
    //MARK: FacebookPhoneVerifyMethods and Delegate
    
    func startFacebookPhoneVerifySteps(){
        print("start facebook phone verify steps")
//        if let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil) as? AKFViewController {
//            prepareLoginViewController(viewController)
//            if let viewController = viewController as? UIViewController {
//                present(viewController, animated: true, completion: nil)
//            }
//        }
    }
    
    // MARK: - helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
//        loginViewController.delegate = self as AKFViewControllerDelegate
//        loginViewController.defaultCountryCode = "IN"
//        loginViewController.uiManager = MyUiManager(UIColor.white, isOpenedFromDiscover: true, isUsedInOnBoarding: false) as UIManager
    }

}

extension HomeViewController:UITextViewDelegate{
    internal func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            placeholderLabel?.isHidden = true
            feedbackAlertViewObj?.enableRightButton()
        }
        else{
            placeholderLabel?.isHidden = false
            feedbackAlertViewObj?.disableRightButton()
        }
    }
}


// MARK: - AKFViewControllerDelegate extension

//extension HomeViewController: AKFViewControllerDelegate {
//    func viewController(_ viewController: (UIViewController & AKFViewController), didCompleteLoginWith accessToken: AKAccessToken, state: String) {
//        phoneVerifiedAccessTokenHandler(accessToken.tokenString, false)
//    }
//
//    private func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
//        print("\(viewController ?? UIViewController()) did fail with error: \(String(describing: error))")
//    }
//}





