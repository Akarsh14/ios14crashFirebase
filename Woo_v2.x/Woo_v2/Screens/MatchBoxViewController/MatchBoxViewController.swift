//
//  MatchBoxViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage
//import LayerKit

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

private let likesTopValue: CGFloat = 82.0
private let likesTopHeightValue: CGFloat = 20.0
private let likesTopLabelTopBottomValue: CGFloat = 10.0
private let likesArrowTopValue: CGFloat = 4.0
private let likesArrowHeightValue: CGFloat = 41.0
private let likesArrowBottomValue: CGFloat = 25.0
private let unlockButtonHeightValue: CGFloat = 40.0


class MatchBoxViewController: BaseClassViewController {
    @IBOutlet weak var emptyMatchBoxImageView: UIImageView!
     @IBOutlet weak var chatBlockingView: ChatBlock!
    
    @IBOutlet weak var chtbtnTop: NSLayoutConstraint!
    @IBOutlet weak var chatBotttomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewChatConstraint: NSLayoutConstraint!
    @IBOutlet weak var noMatchesNoLikesEmptyViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var BlurImageView: UIImageView!
    @IBOutlet weak var matchTableView: UITableView!
    @IBOutlet weak var matchesTableViewConstraintToTop: NSLayoutConstraint!
   
    var kOrignalMatchesTableViewConstraintToTop =  44.0
    let kHeightOfEmptyLikesView = 144.0
    
    @IBOutlet weak var noMatchesNoLikesEmptyView: UIView!
    @IBOutlet weak var placeholderCellView: UIView!
    @IBOutlet weak var noMatchesNoLikesArrowImageView: UIImageView!
    @IBOutlet weak var noMatchesNoLikesDefaultText: UILabel!
    @IBOutlet weak var boostMeNowButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var placeholderCellBoostImageView: UIImageView!
    @IBOutlet weak var likedEmptyViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyView: UIView!
    @IBOutlet weak var likesEmptyContainerView: UIView!
    @IBOutlet weak var noMatchesLabel: UILabel!
    @IBOutlet weak var noMatchesNoLikesSeperatorView: UIView!
    @IBOutlet weak var likesEmptyBgImageView: UIImageView!
    @IBOutlet weak var likesTopLabel: UILabel!
    @IBOutlet weak var likesCollectionView: UICollectionView!
    @IBOutlet weak var likesEmptyArrowImageView: UIImageView!
    @IBOutlet weak var unlockNowButton: UIButton!
    @IBOutlet weak var closeLikesButton: UIButton!
    @IBOutlet weak var containerToEmptyViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likesEmptyToMainViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyViewTopLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyviewTopLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyviewTopLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyviewArrowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyviewArrowTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likesEmptyviewArrowBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockNowButtonHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var likesCollectionViewContainerView: UIView!
   
    @IBOutlet weak var likesEmptyContainerViewYConstraint: NSLayoutConstraint!
    var matchesFromDB : NSMutableArray?
    var selectedMatchObject:MyMatches?
    var likesFromDB : [Any]?
    private var openKeyBoardForChat = false

     var myMathcesArray : NSMutableArray?
     {
        didSet {
            // Code you want to execute after a new value is set
            WooScreenManager.sharedInstance.oHomeViewController?.checkAndShowUnreadBadgeOnMatchIcon()

        }
    }
    
    var allUnreadRooms : NSMutableArray?
    
    var customLoader:WooLoader?
    
    var indexPathSelectedForDeletion : IndexPath?

    @objc func moveToChatRoom(_ notificationobj: Notification) -> Void {
        
        if WooScreenManager.sharedInstance.isDrawerOpen {
            WooScreenManager.sharedInstance.openDrawerSlider()
        }
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        
        
        if (Utilities().isChatRoomPresent(in: self.navigationController) == false) {
             WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
            //restricting the user to stay only in Matchbox because of the chat blocking
            if(!AppLaunchModel.sharedInstance().isChatEnabled){
                return
            }
            if let matchIdStr = notificationobj.object {
                let selectedMatch = MyMatches.getMatchDetail(forMatchID: matchIdStr as! NSString as String)
                if selectedMatch != nil {
                   
                    self.performSegue(withIdentifier: kPushToChatFromMatchbox, sender: selectedMatch)
                }
            }
        }
        else{
            if let matchIdStr = notificationobj.object {
                if(AppLaunchModel.sharedInstance()!.isChatEnabled){
                    return
                }
                if (Utilities().getCurrentlyActiveChatRoomId() == (matchIdStr as! String)) {
                    NSLog("chat room hai", "");
                    if let chatVcObj = Utilities().getCurrentlyActiveChatRoomObj(self.navigationController) {
                        let _ = self.navigationController?.popToViewController(chatVcObj, animated: true)
                    }
                }
                else{
                    let _ = self.navigationController?.popToRootViewController(animated: false)
                    let selectedMatch = MyMatches.getMatchDetail(forMatchID: matchIdStr as! String)
                    if selectedMatch != nil {
                        self.performSegue(withIdentifier: kPushToChatFromMatchbox, sender: selectedMatch)
                    }
                }
            }
        }
    }
    
    @objc func reloadTableData() {
        if WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 2{
            if self.myMathcesArray != nil && self.myMathcesArray?.count > 0 {
                self.myMathcesArray!.removeAllObjects()
            }
            
            if MyMatches.getAllMatches() != nil {
                if (self.myMathcesArray == nil) {
                    self.myMathcesArray = NSMutableArray(array: MyMatches.getAllMatches())
                }
                else {
                    self.myMathcesArray = NSMutableArray(array: MyMatches.getAllMatches())
                }
            }

            self.reloadDataAndShowEmptyScreenIfRequired()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.matchBox, animated: false)
        self.navBar?.setTitleText(NSLocalizedString("Matchbox", comment: "MatchBox") )
        self.navigationController?.isNavigationBarHidden = true
        
        WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.didChange.addHandler(self, handler: MatchBoxViewController.didTabViewChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(moveToChatRoom(_:)), name: NSNotification.Name(rawValue: "moveToChatRoom"), object: nil)
        
        //adding observers here
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name(rawValue: "matchDataUpdatedInDPV"), object: nil)
        
        //Reload specific row and move to top
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name(rawValue: "CHAT_ROOM_CHAT_SNIPPET_UPDATE"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name(rawValue: kMatchStatusSetToDeleted), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name(rawValue: "matchDeletedByNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name(rawValue: "matchSavedInDB"), object: nil)
        
        if LoginModel.sharedInstance()?.gender == "MALE"{
            emptyMatchBoxImageView.image = UIImage(named: "empty_match_female")
        }
        else{
            emptyMatchBoxImageView.image = UIImage(named: "empty_match_male")
        }
        
      
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get()) ?? 0] as? UINavigationController
        if currentNavigation?.viewControllers.count < 2{
            if currentNavigation?.viewControllers.first is MatchBoxViewController{
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 2{
             colorTheStatusBar(withColor: NavBarStyle.matchBox.color())
        }
        
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                noMatchesNoLikesEmptyViewConstraint.constant = 44.0
            }
        }
        
        if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 2 )
        {
            let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get()) ?? 0] as? UINavigationController
            if(currentNavigation?.viewControllers.count > 1 ||  DiscoverProfileCollection.sharedInstance.collectionMode == .my_PROFILE)
            {
                WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
            }
            else
            {
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
        }
        else
        {
            _ =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get()) ?? 0] as? UINavigationController
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
        }
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MatchboxLanding", withEventName: "3-Matchbox.MatchboxLanding.MB_MB_Landing")

        if WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 2 {
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
            if(UserDefaults.standard.bool(forKey: "showVoiceCallingIntroductionPopupWhenVisitsMatchbox") == true)
            {
                UserDefaults.standard.set(false, forKey: "showVoiceCallingIntroductionPopupWhenVisitsMatchbox")
                UserDefaults.standard.synchronize()
                (Utilities.sharedUtility() as! Utilities).showVoiceCallIntroductionPopup()
            }
        }
        
      
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        /*
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "matchDataUpdatedInDPV"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kMatchStatusSetToDeleted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "matchDeletedByNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CHAT_ROOM_CHAT_SNIPPET_UPDATE"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "matchSavedInDB"), object: nil)
        */
        super.viewWillDisappear(animated)

    }
    
    func reloadDataAndShowEmptyScreenIfRequired() -> Void {
        
        matchTableView.register(UINib(nibName:"MatchTableCell", bundle: nil), forCellReuseIdentifier: "MatchTableCell")
        matchTableView.rowHeight = UITableView.automaticDimension
        matchTableView.estimatedRowHeight = 120.0
        
        //if User has matches
        if self.myMathcesArray?.count > 0 {
            hideWooLoader()
            noMatchesNoLikesEmptyView.isHidden = true
            likesEmptyView.isHidden = false

            // If user has likes
            if (likesFromDB?.count > 0 && WooPlusModel.sharedInstance().availableInRegion && WooPlusModel.sharedInstance().isExpired && UserDefaults.standard.bool(forKey: KHasSeenWooPlusSellingViewLikes) != true )
            {
                //if user has not purchased woo plus
                //Show header view to purchase Woo plus in locked state
                //Move TableView Down
                if #available(iOS 11.0, *) {
                    matchesTableViewConstraintToTop.constant = CGFloat(64.0)  + CGFloat(kHeightOfEmptyLikesView) - topLayoutGuide.length
                    
                }
                else{
                    matchesTableViewConstraintToTop.constant = CGFloat(44.0)  + CGFloat(kHeightOfEmptyLikesView) - topLayoutGuide.length
                }
                
                //Show Woo Plus purchase View with Collectionview of likes
                //Move all necessary constraints to bring Collectionview up
                showOrHideLikesEmptyView(false)
            }
            else
            {
                // If user doesnot have likes or already has woo plus.
                //Move header view back to center and matches tableview to origin
                
                if(topLayoutGuide.length != 0)
                {
                    if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11.0"){
                    matchesTableViewConstraintToTop.constant = CGFloat(24.0) + topLayoutGuide.length
                    }
                    else{
                    matchesTableViewConstraintToTop.constant = CGFloat(24.0)
                    }
                }
                else{
                        matchesTableViewConstraintToTop.constant = CGFloat(44.0)
                        if #available(iOS 11.0, *) {
                        if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                            matchesTableViewConstraintToTop.constant = CGFloat(64.0)
                        }
                    }
                }
                
                likesEmptyView.isHidden = true
            }
            if self.matchTableView  != nil{
                self.matchTableView.isHidden = false
            }
        }
        else{
            //Server is fetching matches from Server
            if Utilities().checkIfNeedToShowLoaderInMatchbox()
            {
                showWooLoader()
                noMatchesNoLikesEmptyView.isHidden = true
                likesEmptyView.isHidden = true

                if self.matchTableView  != nil{
                    self.matchTableView.isHidden = false
                }
            }
            else
            {
                //Server isn't fetching matches from Server
                //User doesnot have matches
                hideWooLoader()
                if self.matchTableView  != nil{
                    self.matchTableView.isHidden = true
                }
                // if user has likes
                likesFromDB =  LikedMe.getAllLikedMeProfiles()
                if (likesFromDB?.count > 0)
                {
                   // if user has likes but has not purchased woo plus
                    noMatchesNoLikesEmptyView.isHidden = true
                    if (WooPlusModel.sharedInstance().availableInRegion && WooPlusModel.sharedInstance().isExpired)
                   {
                    //Show Woo Plus purchase View with Collectionview of likes
                    //Move all necessary constraints to bring Collectionview back to the middle
                    showOrHideLikesEmptyView(true)

                    }
                    else
                   {
                        //User does not have boost...need to be purchased
                        showBoostViewBasedOnState()
                    }
                }
                else
                {
                    //User does not have boost...need to be purchased
                    showBoostViewBasedOnState()
                }
            }
        }
        
        if (topLayoutGuide.length != 0){
            likedEmptyViewToTopConstraint.constant = 44.0 // -20
        }
        else{
            likedEmptyViewToTopConstraint.constant = 64.0
        }
        
        self.view.setNeedsLayout()
        
        self.matchTableView.reloadData()
    }
    
    private func showOrHideLikesEmptyView(_ showLikesEmptyView:Bool){
        if showLikesEmptyView{
            likesEmptyContainerViewTopConstraint.constant = likesTopValue
            
            likesEmptyViewTopLabelHeightConstraint.constant = likesTopHeightValue
            likesEmptyviewTopLabelTopConstraint.constant = likesTopLabelTopBottomValue
            likesEmptyviewTopLabelBottomConstraint.constant = likesTopLabelTopBottomValue
            
            likesEmptyviewArrowTopConstraint.constant = likesArrowTopValue
            likesEmptyviewArrowHeightConstraint.constant = likesArrowHeightValue
            likesEmptyviewArrowBottomConstraint.constant = likesArrowBottomValue
            
            unlockNowButtonHeightConstaint.constant = unlockButtonHeightValue
            
            likesEmptyBgImageView.image = nil
            likesEmptyBgImageView.backgroundColor = UIColor.clear
            closeLikesButton.isHidden = true
            likesTopLabel.textColor = UIColor(red: 55.0/255.0, green: 58.0/255.0, blue: 67.0/255.0, alpha: 1.0)
            likesEmptyToMainViewConstraint.isActive = true
            containerToEmptyViewConstraint.constant = likesTopValue
            likesEmptyArrowImageView.isHidden = true
            likesEmptyView.isHidden = false
        }
        else{
            likesEmptyContainerViewTopConstraint.constant = 0.0 //default value 82
            
            likesEmptyViewTopLabelHeightConstraint.constant = 0.0 //default value 20
            likesEmptyviewTopLabelTopConstraint.constant = 0.0 //default value 10
            likesEmptyviewTopLabelBottomConstraint.constant = 0.0 //default value 10
            
            likesEmptyviewArrowTopConstraint.constant = 0.0 //default value 4
            likesEmptyviewArrowHeightConstraint.constant = 0.0 //default value 41
            likesEmptyviewArrowBottomConstraint.constant = 0.0 //default value 25
            
            unlockNowButtonHeightConstaint.constant = 0.0 //default value 40
            
            closeLikesButton.isHidden = false
            likesEmptyBgImageView.backgroundColor = UIColor.black
            likesEmptyBgImageView.image = UIImage(named:"ic_chat_blurred_bg")
            likesEmptyView.isHidden = false
            likesTopLabel.textColor = UIColor.white
            likesEmptyArrowImageView.isHidden = true
            likesEmptyToMainViewConstraint.isActive = false
            containerToEmptyViewConstraint.constant = 0.0     // default 82
        }
        
        likesTopLabel.text = "Unlock who liked you to find \(likesFromDB!.count) more connection(s)"
        likesCollectionView.reloadData()
    }
    
    private func showBoostViewBasedOnState(){
        if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE")
        {
            if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase())
            {
                showEmptyScreenBasedOnScreenType(.BoostNow, isMale: true)
                
            }
                //else if user has boost but not activated
            else if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase() == false && !BoostModel.sharedInstance().currentlyActive)
            {
                showEmptyScreenBasedOnScreenType(.ActivateBoost, isMale: true)
            }
            else
            {
                showEmptyScreenBasedOnScreenType(.None, isMale: true)
            }
        }
        else
        {
            showEmptyScreenBasedOnScreenType(.None, isMale: false)
        }
    }
    
   private func showEmptyScreenBasedOnScreenType(_ boostType:BoostMatchBoxType, isMale:Bool){
        if BlurImageView.image == nil
        {
            let screenShot = takeScreenShotOfView(view: placeholderCellView)
            BlurImageView.image = UIImageEffects.imageByApplyingBlur(to: screenShot, withRadius: 6.0, tintColor: UIColor(red: 241.0/255.0, green: 255.0/255.0, blue: 243.0/255.0, alpha: 0.75), saturationDeltaFactor: 1.0, maskImage: nil)
            
            placeholderCellView.bringSubviewToFront(BlurImageView)
            placeholderCellView.bringSubviewToFront(noMatchesNoLikesSeperatorView)
        }
    
        noMatchesNoLikesEmptyView.isHidden = false
        likesEmptyView.isHidden = true
    
        if isMale{
            
            noMatchesNoLikesDefaultText.text = "Conversations start with Crushes, Likes and Answers. Get started now to increase your chances of a connection."
            
            switch boostType {
            case .BoostNow:
                //Show boost selling point
                boostMeNowButton.setTitle("BOOST ME NOW", for: .normal)
                boostMeNowButton.isHidden = false
                placeholderCellBoostImageView.image = UIImage(named:"ic_matchbox_boost")
                placeholderCellView.bringSubviewToFront(placeholderCellBoostImageView)
                break
                
            case . ActivateBoost:
                //Show boost activation button
                boostMeNowButton.setTitle("ACTIVATE A BOOST", for: .normal)
                boostMeNowButton.isHidden = false
                noMatchesNoLikesDefaultText.text = "Activate your boost to get seen by more people to start conversations"
                boostMeNowButton.isHidden = false
                placeholderCellBoostImageView.image = UIImage(named:"ic_matchbox_boost")
                placeholderCellView.bringSubviewToFront(placeholderCellBoostImageView)
                break
                
            case .None:
                //hide boost selling point
                boostMeNowButton.isHidden = true
                placeholderCellBoostImageView.image = nil
                placeholderCellView.bringSubviewToFront(BlurImageView)
                break
            }
        }
        else{
            noMatchesNoLikesDefaultText.text = "Go ahead and like profiles, send crushes and ask questions to get matches. Chat unlocks when both of you like each other."
            //hide boost selling point
            if (likesFromDB?.count > 0){
                boostMeNowButton.setTitle("SEE WHO LIKED ME", for: .normal)
            }
            else{
                boostMeNowButton.setTitle("DISCOVER PROFILES", for: .normal)
            }
            boostMeNowButton.isHidden = false
            placeholderCellBoostImageView.image = nil
            placeholderCellView.bringSubviewToFront(BlurImageView)
        }
    }
    
    @IBAction func btnWooPlusPurchase(_ sender: Any) {
        let window:UIWindow = UIApplication.shared.keyWindow!
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
        purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
            if wooGlobePurchased == true {
                AppLaunchModel.sharedInstance()?.isChatEnabled = true
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
        }
        
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
               
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
            
        }
    }
    func takeScreenShotOfView(view:UIView) -> UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Save it to the camera roll
        return image!
    }
    
    @IBAction func boostMeNowButtonTapped(_ sender: UIButton)
    {
        //Sell Boost
        if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE")
        {
            if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase())
            {
                let window:UIWindow = UIApplication.shared.keyWindow!
                let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                purchaseObj.initiatedView = "Matchbox_boost"
                purchaseObj.purchaseDismissedHandler = {
                    (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                    let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                    dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                        
                    }
                    dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                    
                }
                
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Matchbox_boost")
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
            }
        else
            {
                //Activate a boost
                    if BoostModel.sharedInstance().currentlyActive == false {
                        if BoostModel.sharedInstance().availableBoost > 0 && BoostModel.sharedInstance().currentlyActive == false {
                            BoostProductsAPICalss.activateBoost(forWooID: (UserDefaults.standard.object(forKey: kWooUserId) as?String), withCompletionBlock: { (successFlag, responseObj, statusCode) in
                                
                                if  successFlag{
                                    // lets do something here for handling boosted stuff
                                    self.noMatchesNoLikesDefaultText.text = "Conversations start with Crushes, Likes and Answers. Get started now to increase your chances of a connection."
                                    self.boostMeNowButton.isHidden = true
                                    WooScreenManager.sharedInstance.oHomeViewController?.checkIfBoostActive()
                                }
                                else{
                                    //Handle error
                                }
                            })
                        }
                    }
                }
          
        }
        else
        {
            if (likesFromDB?.count > 0)
            {
                // Take the use the Liked me Section
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                WooScreenManager.sharedInstance.openDeepLinkedScreen("wooapp://likedMe")
            }
            else
            {
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            }
        }
        
    }
    
    @IBAction func unlockWooPlusButtonTapped(_ sender: UIButton)
    {
        //Sell Woo Plus
        let window:UIWindow = UIApplication.shared.keyWindow!
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.initiatedView = "Matchbox_WP"
        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Matchbox_WP")
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
            
        }

        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)

    }
    @IBAction func closeLikesButtonTapped(_ sender: UIButton)
    {
        // hide likes empty containerview
        UserDefaults.standard.set(true, forKey: KHasSeenWooPlusSellingViewLikes)
        likesEmptyView.isHidden = true
        //Move tableview back into position

        if (topLayoutGuide.length != 0)
        {
            if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11.0"){
                matchesTableViewConstraintToTop.constant = CGFloat(24.0) + topLayoutGuide.length
            }
            else{
                matchesTableViewConstraintToTop.constant = CGFloat(24.0)
            }
        }
        else{
            matchesTableViewConstraintToTop.constant = CGFloat(44.0)

            if #available(iOS 11.0, *) {
                if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                    matchesTableViewConstraintToTop.constant = CGFloat(64.0)
                }
            }
        }
        if (topLayoutGuide.length != 0){
            likedEmptyViewToTopConstraint.constant = 44.0 // -20
        }
        else{
            likedEmptyViewToTopConstraint.constant = 64.0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showWooLoader(){
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        customLoader?.shouldShowWooLoader = false
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 2.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
        }, completion: { (true) in
            (Utilities.sharedUtility() as AnyObject).hideLoaderView
            self.customLoader?.stopAnimation()
        })
        
    }
    
    func showUnmatchOptionstoUserForButtonTapped()
    {
        let reportView: ReportUserView = ReportUserView(frame: self.view.frame)
        reportView.textView.placeholder = NSLocalizedString("Additional information", comment: "Additional information")
        reportView.reportViewType = reasonsForUnmatch
        reportView.setHeaderForReport(reasonsForUnmatch)
        reportView.reportedViewController = self
        reportView.delegate = self
        reportView.reasonsDelegate = self
        if UIDevice.current.systemVersion.compare("9.0",
                                                  options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending {
            self.view!.addSubview(reportView)
        }
        else {
            UIApplication.shared.delegate!.window!!.addSubview(reportView)
        }
    
    }

    //MARK: Show popup for match deletion feature
    func deleteChatRoomObject(_ indexPath: IndexPath) {
        indexPathSelectedForDeletion = indexPath;
        showUnmatchOptionstoUserForButtonTapped()
    }
    
    //MARK: HomeTab bar changed handler
    func didTabViewChanged(_ tupleValue:(oldValue: Int, newValue: Int)) {
        if tupleValue.newValue == 2 {
            print("I am in MatchBoxViewController")
            viewWillAppear(true)
            self.reloadTableData()
            if (AppLaunchModel.sharedInstance()?.isChatEnabled ?? true){
                self.chatBlockingView.isHidden = true
            }else{
                self.chatBlockingView.isHidden = false
                if (isNotchPhone()){
                    self.topViewChatConstraint.constant = 240
                    self.chatBotttomConstraint.constant = 102
                    self.chtbtnTop.constant = 60
                }
                if(self.view.frame.size.height > 735){
                    self.topViewChatConstraint.constant = 200
                    self.chatBotttomConstraint.constant = 85
                    self.chtbtnTop.constant = 40
                }else{
                    self.topViewChatConstraint.constant = 75
                }
            }
            }
    }
    
    
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kPushToChatFromMatchbox {
            
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Chatbox", withEventName: "3-Matchbox.Chatbox.MB_ChatBox_Landing")

            let chatViewControllerObj: NewChatViewController = segue.destination as! NewChatViewController
            let model = sender as! MyMatches
            chatViewControllerObj.myMatchesData = model
            chatViewControllerObj.delegateFromMatch = self
            chatViewControllerObj.viewPushed = true
            chatViewControllerObj.openKeyboardForTyping = openKeyBoardForChat
            chatViewControllerObj.parentView = .matchboxView
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
            self.openKeyBoardForChat = false
        }
        else if (segue.identifier == "PushToProfileViewFromMatchbox"){
            let model = sender as! ProfileCardModel
            let profileVC = segue.destination as! ProfileDeckDetailViewController
            profileVC.profileData = model
            profileVC.myMatchesData = selectedMatchObject
            profileVC.isViewPushed = true
            profileVC.isProfileAlreadyLoaded = false
            profileVC.detailProfileParentTypeOfView = DetailProfileViewParent.matchboxView
            profileVC.showActionButtonContainerView(false)
            profileVC.isActionButtonHidden = true
            profileVC.didCameFromChat = true
            profileVC.popToChatFromSendMessagebjC = {() in
                self.openKeyBoardForChat = true
                self.performSegue(withIdentifier: kPushToChatFromMatchbox, sender: self.selectedMatchObject)
            }
        }
        else if(segue.identifier == "matchsegue"){
            
            let feedbackObj:WriteAnswerViewController = (segue.destination as! WriteAnswerViewController)
            feedbackObj.screenType = .feedback
            feedbackObj.isOpenedFromSettings = false
        }
    }
    
    @IBAction func moreInfoButtonTapped(_ sender: UIButton) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }

        
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
        
        if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase()){
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MatchboxLanding", withEventName: "3-Matchbox.MatchboxLanding.ML_BoostNow_Tap")
            purchaseObj.initiatedView = "Matchbox_boost"
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Matchbox_boost")
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                    
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
            

            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
            
        }else if (CrushModel.sharedInstance().checkIfUserNeedsToPurchase()){
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
        }
        
    }
    
    func makeLike(userId wooId: NSString) -> Void {
        DiscoverAPIClass.makeLikeCall(withParams: wooId as String?, andSelectedTag: nil,withTagId:nil ,andTagDTOType: nil) { (Success, response, statusCode) in
            if Success{
                if statusCode == 202{
                    //ye galat ho raha hai
                    MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_RETRY.rawValue), forChatRoomId: wooId as String?, withUpdationCompletionHandler: nil)
                }
                else if statusCode == 200{
                    let matchDataDict = (response as? NSDictionary)!.object(forKey: "matchEventDto") as? NSDictionary
                    let mutableMatchDataDict = NSMutableDictionary(dictionary: matchDataDict ?? NSMutableDictionary())
                    if matchDataDict?.object(forKey: "chatId") == nil || (matchDataDict?.object(forKey: "chatId") as? String)?.count ?? 0 <= 0{
                        mutableMatchDataDict.setValue("ApplozicChatId", forKey: "chatId")
                    }
                    if (mutableMatchDataDict.object(forKey: "chatId") != nil) {
                        MyMatches.insertDataInMyMatches(from: NSArray(objects: mutableMatchDataDict) as [AnyObject], withChatInsertionSuccess: { (success) in
                            MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue), forChatRoomId: mutableMatchDataDict.object(forKey: "matchId") as? String, withUpdationCompletionHandler: {
                                (completion)
                                in
                                DispatchQueue.main.async {
                                    let matchedUserData = MyMatches.getMatchDetail(forMatchedUSerID: wooId as String?, isApplozic: false)
                                    
                                    if (Utilities().isChatRoomPresent(in: self.navigationController) == false) {
                                        self.performSegue(withIdentifier: kPushToChatFromMatchbox, sender: matchedUserData)
                                    }
                                }
                            })
                        })

                    }
                    else{
                        BoostProductsAPICalss.makeMatchFailureEventCallToServer(withTargetId: wooId as String?)
                        MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_RETRY.rawValue), forChatRoomId: wooId as String?, withUpdationCompletionHandler: nil)
                    }
                }
            }
            else
            {
                MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_RETRY.rawValue), forChatRoomId: wooId as String?, withUpdationCompletionHandler: nil)
            }
            self.reloadTableData()
        }
    }
    
}

extension MatchBoxViewController: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if myMathcesArray != nil {
            return self.myMathcesArray!.count
        }
        return  0
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            let cellIdentifier = "MatchTableCell"
        var cell : MatchTableCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MatchTableCell)!
            
            if cell == nil {
                cell = MatchTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
            }
        
        cell?.getMatchObjectHandler = {(matchesObject:MyMatches?) in
            if let match = matchesObject{
                self.selectedMatchObject = match
                var fetchedProfile = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(match.matchedUserId)
                if fetchedProfile.wooId == nil{
                    fetchedProfile = ProfileCardModel(matchObject: match)
                    if fetchedProfile.wooId == nil{
                        self.showWooLoader()
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(match.matchedUserId)!, withCompletionBlock: { (response, success, statusCode) in
                            self.hideWooLoader()
                            fetchedProfile = MyProfileModel(userInfoDto: response as! NSDictionary)
                            self.performSegue(withIdentifier: "PushToProfileViewFromMatchbox", sender: fetchedProfile)
                        })
                    }
                    else{
                       self.performSegue(withIdentifier: "PushToProfileViewFromMatchbox", sender: fetchedProfile)
                    }
                }
                else{
                    self.performSegue(withIdentifier: "PushToProfileViewFromMatchbox", sender: fetchedProfile)
                }
            }
        }
            
            cell!.setDataOnCellFromObj(myMatchesData: self.myMathcesArray!.object(at: (indexPath as NSIndexPath).row) as? MyMatches)
            return cell!
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                self.deleteChatRoomObject(indexPath)
        }
    }
    
    
    
    
}
extension MatchBoxViewController: UITableViewDelegate{
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMatch: MyMatches = self.myMathcesArray!.object(at: (indexPath as NSIndexPath).row) as! MyMatches
        if((selectedMatch.isDel != nil) && selectedMatch.isDel.boolValue == true)
        {
            //deleteMatchForMatchedUserId
            self.myMathcesArray!.remove(selectedMatch)
            self.matchTableView.deleteRows(at: [indexPath], with: .automatic)
            MyMatches.deleteMatch(forMatchedUserId: selectedMatch.matchedUserId!, withDeletionCompletionHandler:{(success) in
                if(success)
                {
                    DispatchQueue.main.async {
                        if ((self.myMathcesArray?.count) ?? 0 == 0){
                            self.reloadDataAndShowEmptyScreenIfRequired()
                        }
                }
                    
                }
            })
        }
            //FIXREQUIRED: <<<< Null check should be on match object
        else if((selectedMatch.isTargetFlagged != nil) && selectedMatch.isTargetFlagged.boolValue == true)
        {
            //Dont push
        }
        else
        {
            if selectedMatch.matchedUserStatus.intValue == Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue) {
                
                if (Utilities().isChatRoomPresent(in: self.navigationController) == false) {
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
                    self.performSegue(withIdentifier: kPushToChatFromMatchbox, sender: selectedMatch)
                }
                else{
                    //either write code here to pop to root view controller of this and push to new view controller or write code in view will appear make the current chat room value to @"".
                    self.navigationController?.popToRootViewController(animated: false)
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
                    self.performSegue(withIdentifier: kPushToChatFromMatchbox, sender: selectedMatch)
                }
            }
            else{
                MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_ESTABLISHING_CONNECTION.rawValue), forChatRoomId: selectedMatch.matchId, withUpdationCompletionHandler: {
                    (completion) in
                    DispatchQueue.main.async {
                        self.reloadTableData()
                        self.makeLike(userId: selectedMatch.matchedUserId as NSString)
                    }
                })
            }
        }
    }
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}


extension MatchBoxViewController:UICollectionViewDataSource
{
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if (likesFromDB?.count) ?? 0 >= 4
        {
            return 4
        }
        else
        {
            return (likesFromDB?.count) ?? 0
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cellIdentifier = "LockedLikesCollectionViewCell"
        
        let cell : LockedLikesCollectionViewCell? = (likesCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! LockedLikesCollectionViewCell
        )
        cell!.layer.masksToBounds = true
        cell?.layer.cornerRadius = 27.5
        
        let likedUser = likesFromDB?[indexPath.row] as! LikedByMe
        let profilePicUrl = likedUser.userProfilePicURL
        if !(profilePicUrl ?? "").isEmpty{
            let imageCroppedStr = "\(kImageCroppingServerURL)?width=\(Utilities().getImageSize(forPoints: kCircularImageSize))&height=\(Utilities().getImageSize(forPoints: kCircularImageSize))&url=\((Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: likedUser.userProfilePicURL)!)"
            
            
            let imageCroppedUrl = URL(string: imageCroppedStr)
            cell?.profileImageview.sd_setImage(with: imageCroppedUrl, placeholderImage: UIImage(named: "ic_me_avatar_big"))
            
        }
        
        if indexPath.row == 3
        {
            cell?.lockImageView.image = UIImage(named: "")
            cell?.likesCount.text = "+\(((likesFromDB?.count) ?? 0) - 3)"
            cell?.likesCount.isHidden = false
        }
        else{
            cell?.lockImageView.image = UIImage(named: "ic_me_lock.png")
            cell?.likesCount.isHidden = true
        }

        return cell!
    }
}
extension MatchBoxViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Sell Woo Plus
        let window:UIWindow = UIApplication.shared.keyWindow!
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.initiatedView = "Matchbox_locked_WP"
        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Matchbox_locked_WP")
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
            
        }

        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        if (likesFromDB?.count) ?? 0 >= 4
        {
            return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        }
        else
        {
            //calculate space from left and right so that collection view cells are centered
            let countForCellsNotVisible = 4 - ((likesFromDB?.count) ?? 0)
            let space = (CGFloat(countForCellsNotVisible * 55) + CGFloat(countForCellsNotVisible  * 5))/2
            return UIEdgeInsets(top: 5.0, left: 5.0 + space, bottom: 5.0, right: 5.0 + space)
        }
    }


}

extension MatchBoxViewController : ReasonsDelegate
{
    func reasons(forUnmatchOrDelete comment: String!)
    {
        let matchedUserObj : MyMatches = (self.myMathcesArray?.object(at: indexPathSelectedForDeletion!.row))! as! MyMatches
        
        self.myMathcesArray!.remove(matchedUserObj)
        
        CrushAPIClass.deleteMatch(withMatchID: matchedUserObj, withCommentForUnmatch: comment, successBlock: {(success) in
            
        })
        //leave converation
        leaveConversation(forMatchId: matchedUserObj.matchId)
      //  CrushAPIClass.deleteMatch(withMatchID: matchedUserObj )
        MyMatches.deleteMatch(forMatchedUserId: matchedUserObj.matchedUserId, withDeletionCompletionHandler:{(success) in
            if ((self.myMathcesArray?.count) ?? 0 == 0){
                self.reloadDataAndShowEmptyScreenIfRequired()
                WooScreenManager.sharedInstance.oHomeViewController?.checkAndShowUnreadBadgeOnMatchIcon()
            }
        })
        self.matchTableView.deleteRows(at: [indexPathSelectedForDeletion!], with: .automatic)
    }
    
    func leaveConversation(forMatchId matchId:String)
    {
//        LayerManager.shared().getConversationObject(forLayerConversationId: MyMatches.getMatchDetail(forMatchID:matchId).layerChatID)
//        { (isSyncCompleted, conversation, error) in
//
//            if conversation != nil
//            {
//                var error : NSError? = nil;
//                let val = (conversation as! LYRConversation).leave(&error)
//                if(val == false && error != nil)
//                {
//                    print("Error leaving conversation \(error?.localizedDescription)")
//                }
//            }
//        }
    }
}


public extension UIView {
    func applyBlur(level: CGFloat) {
        let context = CIContext(options: nil)
        self.makeBlurredImage(with: level, context: context, completed: { processedImage in
            let imageView = UIImageView(image: processedImage)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: self.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                ])
        })
    }
    
    private func makeBlurredImage(with level: CGFloat, context: CIContext, completed: @escaping (UIImage) -> Void) {
        // screen shot
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let beginImage = CIImage(image: resultImage)
        
        // make blur
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(beginImage, forKey: kCIInputImageKey)
        blurFilter.setValue(level, forKey: kCIInputRadiusKey)
        
        // extend source image na apply blur to it
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter.outputImage
        var cgimg: CGImage?
        var extent: CGRect?
        
        let global = DispatchQueue.global(qos: .userInteractive)
        
        global.async {
            extent = output!.extent
            cgimg = context.createCGImage(output!, from: extent!)!
            let processedImage = UIImage(cgImage: cgimg!)
            
            DispatchQueue.main.async {
                completed(processedImage)
            }
        }
    }
}
