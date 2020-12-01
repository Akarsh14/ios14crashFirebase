
//
//  LikedMeViewController.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 08/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
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


enum GoToScreenType_LikeMe : Int{
    case none = -1
    case woo_PLUS_PURCHASE = 0
    case boost_PURCHASE
    case crush_PURCHASE
    case boost_ACTIVATE
    case profile_COMPLETENESS_ADDPHOTOS
    case profile_COMPLETENESS_ADDTAGS
    case profile_COMPLETENESS_ADDPERSONALQUOTE
//    case profile_COMPLETENESS
    case boost_CRUSH_PURCHASED_WITH_PROFILE_COMPLETE_WITHOUT_WOO_PLUS
    case super_USER_WITH_ALL_POWERS
}

class LikedMeViewController: BaseClassViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var likedMeCollectionView: UICollectionView!
    // To do set these outlets
    var currentSkippedUserDetail:LikedByMe?

    @IBOutlet weak var loadingMoreDataView: UIView!
    @IBOutlet weak var loadingMoreViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topToCollectionViewConstraint: NSLayoutConstraint!
    
    var seeNewProfilesView:SeeNewProfilesPopupView?
    var viewSkippedProfilesIdArray: [String] = []

    var skippedProfileArray: NSMutableArray = NSMutableArray()
    var leftMargin: CGFloat = 20.0
    var spaceBetweenCells = 50.0
    var cellWidth: CGFloat = 100.0
    var cellHeight: CGFloat = 100.0
    var likedMeProfileData_Grouped: NSMutableDictionary = NSMutableDictionary()
    var totalSectionArray: NSMutableArray = NSMutableArray()
    var customLoader:WooLoader?
    
    var lastOffSetLocation: CGFloat = 0.0

    var comingFromProfile:Bool = false

    var boostYourProfileMessageVisible: Bool = false
    
    var sellingMsgEnum: GoToScreenType_LikeMe  = .none             //it should be 0> for subscription , 1> for boost , 2> for crush , 3> for profile completeness, -1> for nothing
    
    var isPaidUser: Bool = false
    var userImageView: MatchedUsersImageView?
    
    var changeSellingMessage: Bool = false
        
    var currentUserDetail:ProfileCardModel?
    
    var currentLikedMeUserDetail:LikedByMe?

    var crushText:String = ""
    
    var likedMeProfileIdArray: [String] = []
    
    var indexPathToDelete:IndexPath?
    
    var sendCrushViewObject:SendCrushView?
    
    var meSectionEmptyViewObj: MeSectionEmptyView? // = MeSectionEmptyView()
    
    var expiryView:MeExpiredView? = nil
    
    var profileCanExpireView:MeProfileCanExpireView?
    
    var actionPerformedFromExpire:Bool = false
    
    var needToOpenCrushSendViewInProfileDetail = false
    
    var currentProfileWooID:String = ""

    let utilities = Utilities.sharedUtility() as! Utilities
    
    let profileAction:ProfileActionManager = ProfileActionManager()
    
    var deleteGoingOn = false
    
    var numberOfLockedProfiles = 1

    var isNewLikedMeToBeAddedFromNotification = false
    
    var isUserAlreadyPresent = false
    
    var sellingMessage = ""
    
    var sellingMessageButtonText = ""
    
    var meSellingMessageView:MeSellingMessageView?
    
    var scrolledCollectionView: Int = 0
    
    var meContainerView:UIView?
     override func viewDidLoad() {
            super.viewDidLoad()
            
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_SkippedProfiles", withEventName: "3-MeSection.Me_SkippedProfiles.MSP_Landing")
            
           
            
            changeSellingMessage = true
            //called to dismiss this controller when trying to present another view
            NotificationCenter.default.addObserver(self, selector: #selector(backButton), name: NSNotification.Name(rawValue: kDismissPresentedViewController), object: nil)
            
            viewSkippedProfilesIdArray.removeAll()
            createEmptyView()

            //Adding a prefernce to remember if a woman has once visited her skipped section
            if (LoginModel.sharedInstance()?.gender == "FEMALE"){
                UserDefaults.standard.set(true, forKey: "hasVisitedLikedByMeSection")
                UserDefaults.standard.synchronize()
            }
        }
        
        @objc func dimissTheScreen()
        {
            self.navigationController?.dismiss(animated: false, completion: nil)
        }

        func createEmptyView() {
            if meSectionEmptyViewObj == nil{
                meSectionEmptyViewObj = MeSectionEmptyView.init(frame: self.view.bounds)
            }
            meSectionEmptyViewObj?.isHidden = true
            meSectionEmptyViewObj?.backgroundColor = UIColor.clear
            meSectionEmptyViewObj?.actionBtnTappedBlock = { (btnTapped: Bool) in
                let meSectionEmptyViewObjButton:UIButton = UIButton()
                meSectionEmptyViewObjButton.tag = 300
                self.moreInfoButtonTapped(meSectionEmptyViewObjButton)
                
            }
            self.view.addSubview(meSectionEmptyViewObj!)
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            NSLog("SkippedProfileVc didReceiveMemoryWarning")
            SDImageCache.shared().clearMemory()
        }
        
        override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
          
            //No Woo Plus
            print(WooPlusModel.sharedInstance().isExpired)
            if WooPlusModel.sharedInstance().isExpired {
                
                isPaidUser = false
                
            }
            else{
                isPaidUser = true
                self.purchasedWork()
                if (LoginModel.sharedInstance()?.gender == "MALE"){
                    self.removeExpiryView()
                }
            }
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)

            getSkippedProfileData()
            toggleSellingMessage()
            showOrRemoveSellingMessages()
            if meSellingMessageView != nil {
                createContainerView(sellingMessageView: meSellingMessageView)
            }
            if (LoginModel.sharedInstance()?.gender == "MALE"){
                showProfileCanExpireView(isMale: true)
            }
            else{
                showProfileCanExpireView(isMale: false)
            }
            
           if isPaidUser == true
           {
            if #available(iOS 11.0, *) {
                if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                    topToCollectionViewConstraint.constant = 44
                }
            }
                
                if(SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue() && skippedProfileArray.count > 0)
                {
                    //when fetching
                    loadingMoreViewHeightConstraint.constant = 55.0
                    topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant + loadingMoreViewHeightConstraint.constant

                }
                else
                {
                    loadingMoreViewHeightConstraint.constant = 55
                    topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant + loadingMoreViewHeightConstraint.constant

                }
            }
           else{
                loadingMoreViewHeightConstraint.constant = 55
                topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant + loadingMoreViewHeightConstraint.constant
            }
                    
            self.navigationController?.isNavigationBarHidden = true
            AppLaunchModel.sharedInstance().numberOfTimesLikedByMeProfileLaunched += 1
            if AppLaunchModel.sharedInstance().numberOfTimesLikedByMeProfileLaunched > 10 {
                AppLaunchModel.sharedInstance().numberOfTimesLikedByMeProfileLaunched = 1
            }
           if isPaidUser
            {
                AppLaunchModel.sharedInstance().isNewDataPresentInLikedByMeSection = false
                NotificationCenter.default.addObserver(self, selector: #selector(showLoadingForPagination), name: NSNotification.Name(rawValue: kPaginationCallStartedLikedByMeProfiles), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(showLoadingForPagination), name: NSNotification.Name(rawValue: kPaginationCallStoppedLikedByMeProfiles), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(reloadViewMaintainingScrollPosition), name: NSNotification.Name(rawValue: kNewLikedByMeAddedOnPagination), object: nil)

            }
            if (scrolledCollectionView > 0){
            likedMeCollectionView.setContentOffset(CGPoint(x: 0,y :scrolledCollectionView), animated: false)
            }
            
            if(!WooPlusModel.sharedInstance().isExpired && CrushModel.sharedInstance()?.availableCrush > 0){
                topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant - 44

            }
            
            else if(!WooPlusModel.sharedInstance().isExpired && CrushModel.sharedInstance()?.availableCrush == 0 && LikedByMe.getAllExpiringLikedByMe().count<1){
               let sellingMessageHeight:CGFloat = heightForView(sellingMessage, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: SCREEN_WIDTH - 50)+50
                print(sellingMessageHeight)
               topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant+sellingMessageHeight
            }else if(LikedByMe.getAllExpiringLikedByMe().count>0 && CrushModel.sharedInstance()?.availableCrush == 0){
                topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant - 44
            }
            }
        
        
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPaginationCallStartedLikedByMeProfiles), object: nil)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPaginationCallStoppedLikedByMeProfiles), object: nil)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNewLikedByMeAddedOnPagination), object: nil)
          }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDismissPresentedViewController), object: nil)

        }
        
        func addMeSellingView(){
            var additionalHeight:CGFloat = 0
            if sellingMessageButtonText.count > 0{
                additionalHeight = 87
            }
            else{
                additionalHeight = 50
            }
            let sellingMessageHeight:CGFloat = heightForView(sellingMessage, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: SCREEN_WIDTH - 50) + additionalHeight
            
            if meSellingMessageView == nil{
                meSellingMessageView = MeSellingMessageView.loadViewFromNib(frame: CGRect(x: 0.0, y: 0.0, width: SCREEN_WIDTH, height: sellingMessageHeight))
                meSellingMessageView?.updateDataAndUI(sellingMessage: sellingMessage, actionButtonText: sellingMessageButtonText)
                meSellingMessageView?.purchaseHandler = {() in
                    self.moreInfoButtonTapped(UIButton())
                }
            }
            
             topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
            
    //        if #available(iOS 11.0, *) {
    //            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
    //                topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
    //            }
    //            else{
    //                topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
    //            }
    //        }
    //        else{
    //            topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
    //        }
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
        
        func createContainerView(sellingMessageView:MeSellingMessageView?){
            var containerHeight:CGFloat = 0
            if sellingMessageView != nil {
                containerHeight = (sellingMessageView?.frame.size.height)!
            }
            
            if containerHeight > 0 && meContainerView == nil{
                meContainerView = UIView(frame: CGRect(x: 0.0, y: 64 + safeAreaTop, width: SCREEN_WIDTH, height: containerHeight))
                self.view.addSubview(meContainerView!)
                self.view.bringSubviewToFront(meContainerView!)
                meContainerView?.snp.makeConstraints { (make) in
                    make.top.equalTo(self.view).offset(64)
                    make.leading.equalTo(self.view).offset(0)
                    make.trailing.equalTo(self.view).offset(0)
                    make.height.equalTo(containerHeight)
                    make.width.equalTo(SCREEN_WIDTH)
                }
                if sellingMessageView != nil {
                    meContainerView?.addSubview(sellingMessageView!)
                }
            }
        }
        
        @objc func  showLoadingForPagination()
        {
            if meSectionEmptyViewObj != nil && meSectionEmptyViewObj?.isHidden == false {
                return
            }
            
            if WooPlusModel.sharedInstance().isExpired {
                isPaidUser = false
            }
            else{
                isPaidUser = true
                if(LikedByMeAPIClass.getIsfetchingLikedByMeDataFromServerValue())
                {
                    //when fetching
                    loadingMoreDataView.isHidden = false
                    if(loadingMoreViewHeightConstraint.constant != 55.0)
                    {
                        //when fetching
                        loadingMoreViewHeightConstraint.constant = 55.0
                        topToCollectionViewConstraint.constant = 44.0 + loadingMoreViewHeightConstraint.constant
                    }
                }
                else{
                        loadingMoreDataView.isHidden = true
                        loadingMoreViewHeightConstraint.constant = 0.0
                        topToCollectionViewConstraint.constant = 44.0  + loadingMoreViewHeightConstraint.constant
                        updateSkippedProfileData()
                        likedMeCollectionView.reloadData()
                        if likedMeCollectionView.contentOffset.y > 0
                        {
                                addAndShowNewProfilesView()
                        }
                    }
               }
            }
        
        
        @objc func reloadViewMaintainingScrollPosition(notification: NSNotification)
        {
            if LikedByMe.getAllLikedByMe().count <= 0
            {
                return
            }
            
            if (LoginModel.sharedInstance()?.gender == "FEMALE")
            {
                // Iterate through new users and add them
                let arrayOfAddedSkippedProfiles = notification.object as! [LikedByMe]
                
                //Divide data into expiry non expiry
                let expiryprofilesArray:[AnyObject] =  getExpiryProfilesFromArray(addedProfiles: arrayOfAddedSkippedProfiles)
                //expiry wale k data k liye sorted in order of first expiring to last expiring , add them to the expiring index
                let indexForInsertion = Int(LikedByMe.getExpiryIndexForInsertionForSkipped())
                
                var indexPathArrayForInsertion = [IndexPath]()
                var indexSetForInsertion : [Int] = []
                
                for i in 0..<expiryprofilesArray.count
                {
                    let indexPathForInsertion = IndexPath(item: (indexForInsertion + i), section: 0)
                    indexPathArrayForInsertion.append(indexPathForInsertion)
                    
                    indexSetForInsertion.append(indexForInsertion + i)
                }
                //Add within groups
                if expiryprofilesArray.count > 0{
                    if likedMeCollectionView.contentOffset.y <= 0{
                    addExpiredViewNow()
                    DispatchQueue.main.async {
                        CATransaction.begin()
                        CATransaction.disableActions()
                        self.expiryView?.expiredDataArray.insert(contentsOf: expiryprofilesArray, at: indexForInsertion)
                        self.expiryView?.expiredCollectionView.performBatchUpdates(
                            {
                                self.expiryView?.expiredCollectionView.insertItems(at:indexPathArrayForInsertion)
                                
                        },completion: {(completed) in
                            if (completed)
                            {
                                self.updateSkippedProfileData()
                                self.likedMeCollectionView.reloadData()
                                
                            }
                        })
                        
                        CATransaction.commit()
                        
                    }
                    }
                }
                if self.deleteGoingOn == false {
                    self.updateSkippedProfileData()
                    self.likedMeCollectionView.reloadData()
                }
            }
            else
            {
                //Add within groups
                updateSkippedProfileData()
                likedMeCollectionView.reloadData()
                
            }
        }
        
        func getExpiryProfilesFromArray(addedProfiles:[LikedByMe]) -> [LikedByMe]
        {
            let utilities = Utilities.sharedUtility() as! Utilities
            let thresholdDaysCount = AppLaunchModel.sharedInstance().meSectionProfileExpiryDaysThreshold
            let filteredArray = addedProfiles.filter()
                {
                    $0.userExpiryTime! <=  utilities.dateAfterSubtractingDays(inCurrentDate: Int32(thresholdDaysCount))
            }
            return filteredArray
            
        }
        
        
        
        func addAndShowNewProfilesView()
        {
            if seeNewProfilesView == nil
            {
                seeNewProfilesView = Bundle.main.loadNibNamed("SeeNewProfilesPopupView", owner:self, options: nil)?.first as? SeeNewProfilesPopupView
                seeNewProfilesView?.frame = CGRect(x: (view.bounds.size.width/2) - ((seeNewProfilesView?.bounds.size.width)!/2), y: -35.0, width: (seeNewProfilesView?.bounds.size.width)!, height: (seeNewProfilesView?.bounds.size.height)!)
                seeNewProfilesView?.layer.cornerRadius = 17.5
                seeNewProfilesView?.layer.masksToBounds = true
                
                view.addSubview(seeNewProfilesView!)
                UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations:
                    {
                        self.seeNewProfilesView?.frame = CGRect(x: (self.view.bounds.size.width/2) - ((self.seeNewProfilesView?.bounds.size.width)!/2), y: -35.0, width: (self.seeNewProfilesView?.bounds.size.width)!, height: (self.seeNewProfilesView?.bounds.size.height)!)
                        
                })
                {(true) in
                    self.seeNewProfilesView?.frame = CGRect(x: (self.view.bounds.size.width/2) - ((self.seeNewProfilesView?.bounds.size.width)!/2), y: 94.0, width: (self.seeNewProfilesView?.bounds.size.width)!, height: (self.seeNewProfilesView?.bounds.size.height)!)
                    self.perform(#selector(self.removeNewProfilesView), with: nil, afterDelay: 7.0)
                    
                }
                seeNewProfilesView?.seeProfilesButtonHandler =
                    {
                        self.likedMeCollectionView.setContentOffset(CGPoint(x: 0.0, y: -CGFloat((self.expiryView?.bounds.size.height) ?? 0)) , animated: true)
                        self.removeNewProfilesView()
                } as (() -> (Void))
            }
        }
        
        @objc func removeNewProfilesView()
        {
            if seeNewProfilesView != nil
            {
                UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations:
                    {
                        self.seeNewProfilesView?.frame = CGRect(x: (self.view.bounds.size.width/2) - ((self.seeNewProfilesView?.bounds.size.width)!/2), y: 30.0, width: (self.seeNewProfilesView?.bounds.size.width)!, height: (self.seeNewProfilesView?.bounds.size.height)!)
                })
                {(true) in
                    self.seeNewProfilesView?.frame = CGRect(x: (self.view.bounds.size.width/2) - ((self.seeNewProfilesView?.bounds.size.width)!/2), y: -35.0, width: (self.seeNewProfilesView?.bounds.size.width)!, height: (self.seeNewProfilesView?.bounds.size.height)!)
                    
                }
                seeNewProfilesView?.removeFromSuperview()
                seeNewProfilesView = nil
            }
        }
        

        @IBAction func backButton(){
            if isPaidUser == true{
            if(SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue()){
                AppLaunchModel.sharedInstance().isNewDataPresentInLikedByMeSection = true
            }
            else{
                AppLaunchModel.sharedInstance().isNewDataPresentInLikedByMeSection = false
            }
            }
            
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            }else{
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        override func viewDidLayoutSubviews() {
        }
        

        @IBAction func moreInfoButtonTapped(_ sender: UIButton){
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }

            print(self.expiryView?.expiredDataArray.count as Any)
            if WooPlusModel.sharedInstance().isExpired || CrushModel.sharedInstance()?.availableCrush == 0{
                if skippedProfileArray.count < 1 && !WooPlusModel.sharedInstance().isExpired {
                    // got to discover
                    self.navigationController?.popViewController(animated: true)
                        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                    
                }
                else{
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
                    purchaseObj.scrollableIndex = 4
                    
                    var funnelString = "LikedByMe_locked_WP"
                    
                    if sender.tag == 200 || sender.tag == 300{
                        funnelString = "LikedByMe_WP_cta"
                    }
                    purchaseObj.initiatedView = funnelString
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: funnelString)

                    purchaseObj.purchaseShownOnViewController = self
                    if(isPaidUser && CrushModel.sharedInstance()?.availableCrush == 0){
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                    }else{
                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)

                    }
                    purchaseObj.purchasedHandler = { (purchaseObj : Bool) in
                        DispatchQueue.main.async
                            {
                                self.afterPurchaseWork()
                                if (LoginModel.sharedInstance()?.gender == "MALE"){
                                    self.removeExpiryView()
                                }
                        }
                    }
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                            
                            DispatchQueue.main.async
                                {
                                  self.afterPurchaseWork()
                                    if (LoginModel.sharedInstance()?.gender == "MALE"){
                                        self.removeExpiryView()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }

                }
            }
            changeSellingMessage = true
        }
        
        func afterPurchaseWork(){
            self.meContainerView?.removeFromSuperview()
            self.meContainerView = nil
            self.meSellingMessageView = nil
            self.changeSellingMessage = true
            self.viewWillAppear(true)
            self.likedMeCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.likedMeCollectionView.contentOffset = CGPoint(x: 0, y: 0)
            self.topToCollectionViewConstraint.constant = 64.0
            if #available(iOS 11.0, *) {
                if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                    topToCollectionViewConstraint.constant = 64
                }
            }
        }
        
        private func purchasedWork(){
            
            if (self.meContainerView != nil){
                self.meContainerView?.removeFromSuperview()
            }
            self.meContainerView = nil
            self.meSellingMessageView = nil
            self.changeSellingMessage = true
            self.likedMeCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.likedMeCollectionView.contentOffset = CGPoint(x: 0, y: 0)
            self.topToCollectionViewConstraint.constant = 44.0
            if #available(iOS 11.0, *) {
                if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                    topToCollectionViewConstraint.constant = 64
                }
            }
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            self.navBar!.setStyle(NavBarStyle.me, animated: false)
            self.navBar?.setTitleText(NSLocalizedString("Liked Me", comment: "Skipped Profiles"))
            self.navigationController?.navigationBar.isHidden = true
            
            self.navBar?.customSwitch?.isHidden = true
            self.navBar!.backButton.isHidden = false
            self.navBar?.addBackButtonTarget(self, action: #selector(SkippedProfileViewController.backButton))
        }
        
        
        func updateSkippedProfileData(){
            if skippedProfileArray.count > 0 {
                skippedProfileArray.removeAllObjects()
            }
            
            if (LoginModel.sharedInstance()?.gender == "MALE"){
                //for males all data is shown in groups regardless of expiry non expiry
                if isPaidUser{
                    skippedProfileArray.addObjects(from: LikedByMe.getAllLikedByMe())
                }
                else{
                    if WooPlusModel.sharedInstance().showExpiryEnabledForSkippedProfiles {
                        skippedProfileArray.addObjects(from: LikedByMe.getAllNonExpiringLikedByMe())
                        if LikedByMe.getAllExpiringLikedByMe().count > 0 {
                                if expiryView == nil
                                {
                                    if likedMeCollectionView.contentOffset.y <= 0{
                                        addExpiredViewNow()
                                        expiryView?.expiredDataArray = updateExpiryArrayForExpiredData(LikedByMe.getAllExpiringLikedByMe() as NSArray, type: .LikedMe) as [AnyObject]

                                        expiryView?.expiredCollectionView.reloadData()
                                        
                                    }
                                }
                                else{
                                    self.likedMeCollectionView.contentInset = UIEdgeInsets(top: CGFloat((expiryView?.frame.size.height)!), left: 0, bottom: 0, right: 0)
                                    self.likedMeCollectionView.contentOffset = CGPoint(x: 0, y: -Int((expiryView?.frame.size.height)!))
                            }
                        }
                    }
                    else{
                        skippedProfileArray.addObjects(from: LikedByMe.getAllLikedByMe())
                    }
                }
            }
            else{
                //for females get grouped non expiry data
                skippedProfileArray.addObjects(from: LikedByMe.getAllNonExpiringLikedByMe())
                if LikedByMe.getAllExpiringLikedByMe().count > 0 {
                    if isPaidUser == true{
                        if expiryView == nil
                        {
                            if likedMeCollectionView.contentOffset.y <= 0{
                                addExpiredViewNow()
                                expiryView?.expiredDataArray = updateExpiryArrayForExpiredData(LikedByMe.getAllExpiringLikedByMe() as NSArray, type: .LikedMe) as [AnyObject]
                                expiryView?.expiredCollectionView.reloadData()
                            
                            }
                        }
                        else{
                            self.likedMeCollectionView.contentInset = UIEdgeInsets(top: CGFloat((expiryView?.frame.size.height)!), left: 0, bottom: 0, right: 0)
                            self.likedMeCollectionView.contentOffset = CGPoint(x: 0, y: -Int((expiryView?.frame.size.height)!))
                        }
                    }
                    else
                    {
                        skippedProfileArray.addObjects(from: LikedByMe.getAllLikedByMe())
                    }
                }
            }
        }
        
        func showProfileCanExpireView(isMale:Bool){
            
            var showExpiryPopUp = true
            
            if isMale{
                showExpiryPopUp = WooPlusModel.sharedInstance().showExpiryEnabledForSkippedProfiles
            }
            
            if LikedByMe.getAllLikedByMe().count > 0 {
                if showExpiryPopUp{
                    if UserDefaults.standard.bool(forKey: "ProfileCanExpireHasBeenShowed") == false {
                        self.likedMeCollectionView.isUserInteractionEnabled = false
                        if profileCanExpireView == nil {
                            profileCanExpireView = MeProfileCanExpireView.loadViewFromNib(frame: CGRect(x: 0, y: -210 - safeAreaTop, width: SCREEN_WIDTH, height: 210))
                            profileCanExpireView?.updateExpiryText()
                            profileCanExpireView?.dismissHandler = {
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.profileCanExpireView?.transform = CGAffineTransform.identity
                                }, completion: { (true) in
                                    self.profileCanExpireView?.removeFromSuperview()
                                    self.profileCanExpireView = nil
                                    self.likedMeCollectionView.isUserInteractionEnabled = true
                                    if self.meContainerView != nil{
    //                                    self.view.bringSubview(toFront: self.meContainerView!)
                                    }
                                    
                                })
                            }
                            self.view.addSubview(profileCanExpireView!)
    //                        if meContainerView != nil{
    //                            self.view.sendSubview(toBack: meContainerView!)
    //                        }
                            self.view.bringSubviewToFront(profileCanExpireView!)
                            
                            UIView.animate(withDuration: 0.3, delay: 0.3, options: UIView.AnimationOptions.curveEaseIn, animations: {
                                self.profileCanExpireView?.transform = CGAffineTransform(translationX: 0, y: 274 - safeAreaTop)
                            }, completion: nil)
                        }
                        UserDefaults.standard.set(true, forKey: "ProfileCanExpireHasBeenShowed")
                    }
                }
            }
        }
        
        func addExpiredViewNow(){
            let widthForCell = SCREEN_WIDTH - 18
            let expiryCellWidth = widthForCell/2.3
            let expiryCellHeight = expiryCellWidth * 1.7 + 62
            if expiryView == nil
            {
                    expiryView = MeExpiredView.loadViewFromNib(frame: CGRect(x: 0.0, y: -expiryCellHeight, width: SCREEN_WIDTH, height: expiryCellHeight))

                    expiryView?.paidUser = isPaidUser
                    expiryView?.needToShowLock = WooPlusModel.sharedInstance().maskingEnabledForSkippedProfiles
                    expiryView?.purchaseHandler = {() in
                        self.moreInfoButtonTapped(UIButton())
                    }
                self.likedMeCollectionView.contentInset = UIEdgeInsets(top: CGFloat(expiryCellHeight), left: 0, bottom: 0, right: 0)
                        self.likedMeCollectionView.contentOffset = CGPoint(x: 0, y: -expiryCellHeight)
                    self.likedMeCollectionView.addSubview(expiryView!)
                self.likedMeCollectionView.sendSubviewToBack(expiryView!)
                    
                    expiryView?.snp.makeConstraints { (make) in
                        make.top.equalTo(self.likedMeCollectionView).offset(-expiryCellHeight)
                        make.leading.equalTo(self.likedMeCollectionView).offset(0)
                        make.trailing.equalTo(self.likedMeCollectionView).offset(0)
                        make.height.equalTo(expiryCellHeight)
                        make.width.equalTo(SCREEN_WIDTH)
                    }
            }
            expiryView?.dataType = .LikedMe
            expiryView?.prepareExpiryData()
            expiryView?.openExpiryVcHandler = {(dataType:MeDataType) in
                let expiryCollectionVc = self.storyboard?.instantiateViewController(withIdentifier: "ExpiryProfilesViewController") as! ExpiryProfilesViewController
                expiryCollectionVc.isPaidUser = self.isPaidUser
                expiryCollectionVc.parentViewType = dataType
                expiryCollectionVc.dismissViewControllerHandler = { (expiryToBeReloaded:Bool) in
                    if(expiryToBeReloaded == true)
                    {
                        let expiryDataArray = updateExpiryArrayForExpiredData(LikedByMe.getAllExpiringLikedByMe() as NSArray, type: .LikedMe) as [AnyObject]

                        if(expiryDataArray.count > 0)
                        {
                            self.expiryView?.expiredDataArray = expiryDataArray
                            self.expiryView?.expiredCollectionView.reloadData()
                        }
                        else
                        {
                            self.removeExpiryView()
                        }
                    }
                    else
                    {
                        
                    }
                }
                self.navigationController?.pushViewController(expiryCollectionVc, animated: true)
                
            }
            expiryView?.openProfileDetailHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject, comingFromExpired:Bool, expiredIndexPath:IndexPath) in
                self.scrolledCollectionView = 0
                self.actionPerformedFromExpire = comingFromExpired
                self.comingFromProfile = false
                self.indexPathToDelete = expiredIndexPath
                self.currentSkippedUserDetail = userProfile as? LikedByMe
                self.needToOpenCrushSendViewInProfileDetail = false
                
                if needToTakeAction == PerformAction.Pass {
                    self.dislikeUser(expiredIndexPath)
                }
                else if needToTakeAction == PerformAction.CrushSent{
                    if (!(CrushModel.sharedInstance().checkIfUserNeedsToPurchase())){
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.needToOpenCrushSendViewInProfileDetail = true
                            self.pushtoDetailView(self.currentSkippedUserDetail!, indexPath: expiredIndexPath)
                        }
                    }
                    else{
                        //out of crushes view
                        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseCrush)
                        WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                            if CrushModel.sharedInstance().availableCrush > 0 {
                                self.needToOpenCrushSendViewInProfileDetail = true
                                self.pushtoDetailView(self.currentSkippedUserDetail!, indexPath: expiredIndexPath)
                            }
                        }
                    }
                }
                else if needToTakeAction == PerformAction.Like{
                    self.likeUser(expiredIndexPath)
                }
                else{
                        self.pushtoDetailView(self.currentSkippedUserDetail!, indexPath: expiredIndexPath)
                }
            }
            expiryView?.removeViewHandler = {
                self.removeExpiryView()
            }
        }

        func removeExpiryView()
        {
            self.expiryView?.removeFromSuperview()
            self.expiryView = nil
            self.likedMeCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.likedMeCollectionView.contentOffset = CGPoint(x: 0, y: 0)
            self.showOrRemoveSellingMessages()
        }
        
        func getSkippedProfileData() -> Void {
            updateSkippedProfileData()
            setMarginAccordingToData()
            likedMeCollectionView.reloadData()
        }
        
        func setMarginAccordingToData() -> Void {
            let widthForCell = SCREEN_WIDTH - 27
            cellWidth = widthForCell/2
            spaceBetweenCells = 20
            cellHeight = cellWidth * 1.7
            leftMargin = 9
        }
        
        func showOrRemoveSellingMessages() -> Void {
            
            var showSellingMessage = false
            if WooPlusModel.sharedInstance().isExpired && CrushModel.sharedInstance()?.availableCrush != 0{
                var totalCount = skippedProfileArray.count
                if WooPlusModel.sharedInstance().showExpiryEnabledForSkippedProfiles{
                    totalCount = totalCount + LikedByMe.getAllExpiringLikedByMe().count
                }
                if totalCount < 1 {
                    showSellingMessage = false
                    meSectionEmptyViewObj?.isHidden = false
                    likedMeCollectionView.isHidden = true
                    topToCollectionViewConstraint.constant = 44.0
                }
                else{
                    showSellingMessage = true
                    meSectionEmptyViewObj?.isHidden = true
                    likedMeCollectionView.isHidden = false
                    
                }
            }
            else{
                if skippedProfileArray.count + LikedByMe.getAllExpiringLikedByMe().count < 1 {
                    showSellingMessage = false
                    if SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue(){
                        meSectionEmptyViewObj?.isHidden = true
                        likedMeCollectionView.isHidden = false
                    }
                    else{
                        meSectionEmptyViewObj?.isHidden = false
                        likedMeCollectionView.isHidden = true
                    }
                    topToCollectionViewConstraint.constant = 44.0

                }
                else{
                    if(CrushModel.sharedInstance()?.availableCrush == 0 && LikedByMe.getAllExpiringLikedByMe().count==0 ){
                        //for 1
                        showSellingMessage = true
                        meSectionEmptyViewObj?.isHidden = true
                        likedMeCollectionView.isHidden = false
                        topToCollectionViewConstraint.constant = 64.0

                    }else{
                    showSellingMessage = false
                    meSectionEmptyViewObj?.isHidden = true
                    likedMeCollectionView.isHidden = false
                    topToCollectionViewConstraint.constant = 44.0
                }
            }
            }
            if showSellingMessage {
                addMeSellingView()
            }
            else{
                
            }
        }
        
        func toggleSellingMessage() -> Void {
            
            if !changeSellingMessage {
                return
            }
            
            //No Woo Plus
            
            if(CrushModel.sharedInstance()?.availableCrush == 0 && skippedProfileArray.count > 0){
                if(isPaidUser){
                sellingMessage = AppLaunchModel.sharedInstance()!.subscriptionLikedMeText
                sellingMessageButtonText = NSLocalizedString("Get CRUSHES", comment: "")
                }else{
                    sellingMessage = "Revisit the ones you have liked"
                    sellingMessageButtonText = NSLocalizedString("UNLOCK WITH WOOPLUS", comment: "")
                }
                meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who you liked will show here", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().discoverMoreProfileText, actionButtonTitle: NSLocalizedString("DISCOVER PEOPLE", comment: ""), showBoostIcon: false, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
                meSectionEmptyViewObj?.showActionButton(showActionButton: true)
            }
            else if WooPlusModel.sharedInstance().isExpired{
               
                if skippedProfileArray.count < 1 {
                    sellingMessage = AppLaunchModel.sharedInstance().discoverMoreProfileText
                    sellingMessageButtonText = NSLocalizedString("DISCOVER PEOPLE", comment: "")
                    
                    meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who you liked will show here", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().discoverMoreProfileText, actionButtonTitle: NSLocalizedString("DISCOVER PEOPLE", comment: ""), showBoostIcon: false, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
                    meSectionEmptyViewObj?.showActionButton(showActionButton: true)
                }
                else{
        
                    sellingMessage = AppLaunchModel.sharedInstance().subscriptionSkippedProfileText
                    sellingMessageButtonText = NSLocalizedString("UNLOCK WITH WOOPLUS", comment: "")
                    
                    meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("Skipped Profiles", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().subscriptionSkippedProfileText, actionButtonTitle: NSLocalizedString("UNLOCK WITH WOOPLUS", comment: ""), showBoostIcon: false, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
                    meSectionEmptyViewObj?.showActionButton(showActionButton: true)
                    
                }
               // likedMeCollectionView.isScrollEnabled = false
    //            likedMeCollectionView.isUserInteractionEnabled = false
                isPaidUser = false
            }
            else{
    //            if skippedProfileArray.count < 1 {
                
                meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("All profiles you liked will show here", comment: ""), sellingMessage: NSLocalizedString("Sometimes giving a second glance is important.\nGet started by reviewing more profiles.", comment: ""), actionButtonTitle: NSLocalizedString("DISCOVER PROFILES", comment: ""), showBoostIcon: false, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
                meSectionEmptyViewObj?.showActionButton(showActionButton: false)
                
    //            }
                likedMeCollectionView.isScrollEnabled = true
    //            likedMeCollectionView.isUserInteractionEnabled = true
                isPaidUser = true
            }
            likedMeCollectionView.isScrollEnabled = true
            changeSellingMessage = false
            
        }
        
        @objc func sendCrush(_ indexPath:IndexPath){
            performActionForType(.CrushSent, indexPath: indexPath)
        }
        
        func likeUser(_ indexPath:IndexPath){
            performActionForType(.Like, indexPath: indexPath)
        }
        
        func dislikeUser(_ indexPath:IndexPath){
            //new swrve/firebase events added
            utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MS_Deck_Skip")
            performActionForType(.Pass, indexPath: indexPath)

        }
        
        func performActionForType(_ actionType:PerformAction,indexPath:IndexPath){
            
            profileAction.currentViewType = .LikedMe
            profileAction.crushText = self.crushText
            profileAction.indexPathToBeDeleted = indexPath
            //self.likedMeCollectionView.isUserInteractionEnabled = false

            profileAction.reloadHandler = {(indexPath:IndexPath) in
                self.reloadViewAfterRemovingData(indexPath)
            }
            profileAction.performSegueHandler = { (matchedUserDataFromDb:MyMatches) in
                if (Utilities().isChatRoomPresent(in: self.navigationController) == false){
                    if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                    }else{
                    self.performSegue(withIdentifier: kPushToChatFromSkippedProfile, sender: matchedUserDataFromDb)
                    }
                }
            }

            switch actionType {
            case .Like:
                if  comingFromProfile == true{
                    profileAction.likeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
                }
                else{
                    profileAction.likeActionPerformed(.LikedMe, userObject: currentSkippedUserDetail! as AnyObject)
                }
                break
                
            case .Pass:
                if  comingFromProfile == true{
                    profileAction.dislikeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
                }
                else{
                    profileAction.dislikeActionPerformed(.LikedMe, userObject: currentSkippedUserDetail! as AnyObject)
                }
                break
                
            case .CrushSent:
                if  comingFromProfile == true{
                    profileAction.crushActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
                }
                else{
                    profileAction.crushActionPerformed(.LikedMe, userObject: currentSkippedUserDetail! as AnyObject)
                }
                break
                
            default:
                break
            }
        }

        
        func checkIfUserWillSeeOutOfLikeAlert() -> Bool {
            var showOutOfLikeAlert = false
            if ((LoginModel.sharedInstance()?.gender == "MALE") &&
                WooPlusModel.sharedInstance().isExpired &&
                (AppLaunchModel.sharedInstance().maxLikeToShowLikeMeter <= AppLaunchModel.sharedInstance().likeCount)) {
                showOutOfLikeAlert = true
            }
            return showOutOfLikeAlert
        }
        
        fileprivate func showSendCrushView(){
            if sendCrushViewObject == nil {
                let mainWindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
                sendCrushViewObject = SendCrushView.init(frame: mainWindow.rootViewController!.view.frame)
            }
            
            sendCrushViewObject?.presentView(on: self.view, withTemplateQuestions: CrushModel.sharedInstance().templateQuestionArray, userName: currentSkippedUserDetail?.userFirstName, withAnimationTime: 0.25, withCompletionBlock: { (true) in
                self.sendCrushViewObject?.viewDismissed({ (crushTextString, isSendButtonTapped, isTemplateTapped, selectedRow) in
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_SendCrush")
                    
                    
                    if isSendButtonTapped == false && isTemplateTapped == false{
                        return
                    }
                    
                    self.crushText = crushTextString!
                    self.sendCrush(self.indexPathToDelete ?? IndexPath(item: 0, section: 0))
                    self.sendCrushViewObject = nil
                })
            })
        }
        
        fileprivate func showOutOfLikeAlert(){
            
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup")
            
            let outOfLikePopup = OutOfLikeView.showView(parentViewController: WooScreenManager.sharedInstance.oHomeViewController!)
            outOfLikePopup.buttonPressHandler = {
                //More Info
                
                
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    return
                }
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup_MoreInfo")
                
                let window:UIWindow = UIApplication.shared.keyWindow!
                let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                purchaseObj.initiatedView = "Outoflikes_getwooplus"
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Outoflikes_getwooplus")
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                    DispatchQueue.main.async
                        {
                            self.afterPurchaseWork()
                            if (LoginModel.sharedInstance()?.gender == "MALE"){
                                self.removeExpiryView()
                            }
                    }
                }
                purchaseObj.purchaseDismissedHandler = {
                    (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                    let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                    dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                        DispatchQueue.main.async
                            {
                                self.afterPurchaseWork()
                                if (LoginModel.sharedInstance()?.gender == "MALE"){
                                    self.removeExpiryView()
                                }
                        }
                    }
                    dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                    
                }

            }
            
        }

        func reloadViewAfterRemovingData(_ indexPath:IndexPath) {
            if actionPerformedFromExpire == true {
                    if expiryView != nil {
                        expiryView?.reloadViewAfterRemovingData()
                    }
                return
            }
            
            if self.skippedProfileArray.count <= 0 {
                self.likedMeCollectionView.reloadData()
                return
            }
            //var isSectionToBeDeleted = false
            if self.skippedProfileArray.count > 0 && self.skippedProfileArray.count > indexPath.row{
                 self.skippedProfileArray.removeObject(at: (indexPath.row))
            }
          
            if (self.skippedProfileArray.count == 0){
                self.likedMeCollectionView.deleteSections(IndexSet(integer: indexPath.section))
            }
            else{
                if let _ = self.likedMeCollectionView.cellForItem(at: indexPath){
                    self.likedMeCollectionView.deleteItems(at: [indexPath])
                    
                }
            }
            self.toggleSellingMessage()
            self.showOrRemoveSellingMessages()
            self.deleteGoingOn = false
            self.perform(#selector(self.nowEnableCollectionView), with: nil, afterDelay: 0.2)

            /*
            self.likedMeCollectionView.performBatchUpdates({
                if (self.skippedProfileArray.count == 1)
                {
                    isSectionToBeDeleted = true
                }
                
                if self.skippedProfileArray.count > 0 && self.skippedProfileArray.count > indexPath.row{
                    self.skippedProfileArray.removeObject(at: (indexPath.row))
                }
                self.likedMeCollectionView.deleteItems(at: [indexPath])
                if(isSectionToBeDeleted == true)
                {
                    self.likedMeCollectionView.deleteSections(IndexSet(integer: indexPath.section))
                }
            }) { (completed) in
                if(completed)
                {
                    self.toggleSellingMessage()
                    self.showOrRemoveSellingMessages()
                    self.likedMeCollectionView.reloadData()
                    self.deleteGoingOn = false
                }

            }
        */
        }
        
        @objc func nowEnableCollectionView(){
            self.likedMeCollectionView.isUserInteractionEnabled = true
            self.likedMeCollectionView.reloadData()
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let tempView: UICollectionReusableView = UICollectionReusableView();
            switch kind {
            //2
            case UICollectionView.elementKindSectionHeader:
                //3
                    let headerView:MeHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MeHeaderView", for: indexPath) as! MeHeaderView
                    if LoginModel.sharedInstance()?.gender == "FEMALE" || !isPaidUser{
                        headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recently Liked Profiles (expiring soon)", comment: ""))
                    }
                    else{
                        headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recently Liked Profiles", comment: ""))
                    }
                    
                    return headerView
                
            default:
                //4
                assert(false, "Unexpected element kind")
            }
            return tempView
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.size.width, height: 40)
        }
        
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            if skippedProfileArray.count > 0 {
                return 1
            }
            return 0
        }

        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print("skippedProfileArray.count %d",skippedProfileArray.count)
            return skippedProfileArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: cellWidth, height: cellHeight)
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let identifier = "MeCollectionViewCell"
            let cell: MeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MeCollectionViewCell)!
            var skippedProfileDetailDetail:LikedByMe? = skippedProfileArray.object(at: (indexPath as NSIndexPath).row) as? LikedByMe
            if skippedProfileDetailDetail == nil{
                skippedProfileDetailDetail = LikedByMe()
            }
            cell.setUserDetail(userDetail: skippedProfileDetailDetail!, isBundledProfile: false, forType: .LikedMe, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForSkippedProfiles, noOfTotalProfiles: skippedProfileArray.count, isExpired: false, profileIndex: indexPath.row, usedInExpiryProfiles: false)
            
            cell.meProfileDeckView?.dismissHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject) in
                
                let touchPoint = CGPoint(x: cell.center.x, y: cell.center.y)
                
                let tappedIndexPath = collectionView.indexPathForItem(at: touchPoint)
                self.indexPathToDelete = tappedIndexPath
                self.comingFromProfile = false
                self.deleteGoingOn = true
                self.actionPerformedFromExpire = false
                self.needToOpenCrushSendViewInProfileDetail = false
                
                self.currentSkippedUserDetail = userProfile as? LikedByMe
                if needToTakeAction == PerformAction.Pass {
                    self.dislikeUser(tappedIndexPath ?? IndexPath(item: 0, section: 0))
                }
                else if needToTakeAction == PerformAction.CrushSent{
                    WooScreenManager.sharedInstance.oHomeViewController?.crushFunnelMessage = "LikedByme_profile_crush_tap"
                    self.needToOpenCrushSendViewInProfileDetail = true
                    self.pushtoDetailView(self.currentSkippedUserDetail!, indexPath: tappedIndexPath ?? IndexPath(item: 0, section: 0))
                }
                else if needToTakeAction == PerformAction.Like{
                    if self.checkIfUserWillSeeOutOfLikeAlert() {
                        self.showOutOfLikeAlert()
                    }
                    else{
                        self.likeUser(tappedIndexPath ?? IndexPath(item: 0, section: 0))
                    }
                }
            }
            if let uerWooidValue = skippedProfileDetailDetail?.userWooId {
                if viewSkippedProfilesIdArray.contains(uerWooidValue) == false{
                    viewSkippedProfilesIdArray.append(uerWooidValue)
                }
            }
            
            return cell
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            if isPaidUser == true{
                return UIEdgeInsets(top: 9, left: leftMargin, bottom: 20, right: leftMargin)
            }
            else{
                return UIEdgeInsets(top: 0, left: leftMargin, bottom: 20, right: leftMargin)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return leftMargin
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return leftMargin
        }

        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // Srwve Event
            if isPaidUser {
                if (likedMeCollectionView.indexPathsForSelectedItems?.first) != nil{
                    scrolledCollectionView = Int(likedMeCollectionView.contentOffset.y)
                }
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_SkippedProfiles", withEventName: "3-MeSection.Me_SkippedProfiles.MSP_UserProfile_Tap")
                actionPerformedFromExpire = false
                self.indexPathToDelete = indexPath
                self.needToOpenCrushSendViewInProfileDetail = false
                if Utilities().reachable() == true {
                    if let visitorDetail:LikedByMe = skippedProfileArray.object(at: indexPath.row) as? LikedByMe{
                        if visitorDetail.userWooId != nil  {
                            pushtoDetailView(visitorDetail, indexPath: indexPath)
                        }
                       
                    }
                }
                else{
                    Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle:"", withDuration: 3.0)
                }
            }
            else{
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_Visitors", withEventName: "3-MeSection.Me_SkippedProfiles.MSP_LockedProfileTap")
                self.moreInfoButtonTapped(UIButton())
            }
            
            
        }
        
        func pushtoDetailView(_ skippedProfile:LikedByMe, indexPath:IndexPath){
            
            self.isUserAlreadyPresent = false
            LikedByMe.updateHasUserProfileVisited(byAppUser: true, forUserWooId: skippedProfile.userWooId!, withCompletionHandler: {
                (completed) in
                if skippedProfile.userWooId == (UserDefaults.standard.object(forKey: kWooUserId) as! String) {
                    let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                    self.navigationController?.pushViewController(controller, animated: true)
                    
                }
                else{
                    
                    var model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(skippedProfile.userWooId!)
                    if model.wooId == nil{
                        model = ProfileCardModel.init(model: skippedProfile, profileType: .LikedMe)
                        let cell:MeCollectionViewCell?
                        if self.actionPerformedFromExpire{
                            cell = self.expiryView?.expiredCollectionView.cellForItem(at: indexPath) as? MeCollectionViewCell
                        }
                        else{
                            cell = self.likedMeCollectionView.cellForItem(at: indexPath) as? MeCollectionViewCell
                        }
                        if cell?.meProfileDeckView?.profileImageView.image != nil {
                            model.profileImage = cell?.meProfileDeckView?.profileImageView.image
                        }
                        else{
                            model.profileImage = nil
                        }
                    }
                    else{
                        self.isUserAlreadyPresent = true
                    }
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: kPushFromLikedMeToDetailProfileView, sender: model)
                    })
                }
            })
        }
        
        func showWooLoader(){
            if customLoader == nil {
                let loaderFrame:CGRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
                customLoader = WooLoader.init(frame: loaderFrame)
            }
            customLoader?.startAnimation(on: self.view, withBackGround: false)
        }
        
        func hideWooLoader(){
            UIView .animate(withDuration: 0.25, delay: 2.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                }, completion: { (true) in
                    (Utilities.sharedUtility() as AnyObject).hideLoaderView
                    self.customLoader?.stopAnimation()
            })
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == kPushFromLikedMeToDetailProfileView){
                let model = sender as! ProfileCardModel
                let profileVC = segue.destination as! ProfileDeckDetailViewController
                
                profileVC.profileData = model
                profileVC.isViewPushed = true
                profileVC.selectedIndexPath = self.indexPathToDelete ?? IndexPath(item: 0, section: 0)
                profileVC.isProfileAlreadyLoaded = self.isUserAlreadyPresent
                profileVC.openCrushView = needToOpenCrushSendViewInProfileDetail
                profileVC.detailProfileParentTypeOfView = DetailProfileViewParent.likedMe
                profileVC.dismissHandler = { (currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel, onBoardingEditProfileDone:Bool, selectedIndexPath:IndexPath) in
                    self.crushText = crushString
                    self.comingFromProfile = true
                    self.currentUserDetail = userProfile
                    if needToTakeAction == .Pass {
                        self.reloadViewAfterRemovingData(selectedIndexPath)
                    }
                    if needToTakeAction == .Like{
                        self.likeUser(selectedIndexPath)
                    }
                    else if needToTakeAction == .CrushSent{
                        if self.actionPerformedFromExpire == true{
         self.expiryView?.perform(#selector(self.expiryView?.showCrushOverlayAndUpdateView), with: nil, afterDelay: 0.4)
                        }
                        else{
                           // self.expiryView?.perform(#selector(self.showCrushOverlayAndUpdateView), with: nil, afterDelay: 0.4)
                            self.showCrushOverlayAndUpdateView()
                        }
                        self.sendCrush(selectedIndexPath)
                        //self.sendCrush()
                    }
                }
            }
            else if (segue.identifier == kPushToChatFromSkippedProfile) {
    //            let chatViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
                let chatViewControllerObj: NewChatViewController  = segue.destination as! NewChatViewController
                let model = sender as! MyMatches
                chatViewControllerObj.myMatchesData = model
                chatViewControllerObj.isAutomaticallyPushedFromChat = true
                chatViewControllerObj.parentView = .skippedProfile
            }
        }
        
        func showSnackBar(_ text:String){
            let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
            snackBarObj.multiline = true
            snackBarObj.show()
        }
        
       @objc func showCrushOverlayAndUpdateView(){
        if (indexPathToDelete != nil) {
            let cell: MeCollectionViewCell? = likedMeCollectionView.cellForItem(at: indexPathToDelete!) as? MeCollectionViewCell
            cell?.meProfileDeckView?.showOverlayForCrushSent()
            }
        }
    }






