//
//  VisitorViewController.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 22/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit
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


enum ACTION_BUTTON_TAPPED_TYPE : Int{
    case none = -1
    case boost_PURCHASE
    case woo_PLUS_PURCHASE
    case boost_PROFILE
    case boost_PURCHASED_WITHOUT_WOO_PLUS
    case woo_PLUS_PURCHASED_WITHOUT_BOOST
    case boost_AND_WOO_PLUS_PURCHASED
    case boost_AND_WOO_PLUS_PURCHASED_AND_BOOST_ACTIVE
    case boost_PURCHASED_AND_ACTIVE
}

class VisitorViewController: BaseClassViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var visitorCollectionView: UICollectionView!
    @IBOutlet weak var loadingMoreDataView: UIView!
    
    @IBOutlet weak var topToCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingMoreViewHeightConstraint: NSLayoutConstraint!
    
    var lastOffSetLocation: CGFloat = 0.0
    
    var visitorProfileArray: NSMutableArray = NSMutableArray()
    var leftMargin: CGFloat = 20.0
    var spaceBetweenCells = 50.0
    var cellWidth: CGFloat = 100.0
    var cellHeight: CGFloat = 100.0
    var visitorProfileData_Grouped: NSMutableDictionary = NSMutableDictionary()
    var totalSectionArray: NSMutableArray = NSMutableArray()
    var showBoostPurchaseScreen: Bool = false
    var customLoader:WooLoader?
    var isPaidUser: Bool = false
    var userImageView: MatchedUsersImageView?
    var actionButtonType: ACTION_BUTTON_TAPPED_TYPE = .none
    
    var meSectionEmptyViewObj: MeSectionEmptyView? // = MeSectionEmptyView()
    
    var changeSellingMessage: Bool = false
    
    var currentUserDetail:ProfileCardModel?
    
    var currentVisitorDetail:MeDashboard?
      var currentLikedMeUserDetail:LikedMe?
    
    var currentProfileWooID:String = ""
    
    var comingFromProfile:Bool = false
    
    var profileExpiryViewIsVisible:Bool = false
    
    var actionPerformedFromExpire:Bool = false
    
    var crushText:String = ""
    
    var visitedProfilesIdArray: [String] = []
    var scrolledCollectionView: Int = 0
    var sendCrushViewObject:SendCrushView?
    
    var indexPathToDelete:IndexPath?
    
    var needToOpenCrushSendViewInProfileDetail = false
    
    var deleteGoingOn = false
    
    var seeNewProfilesView:SeeNewProfilesPopupView?
    
    var expiryView:MeExpiredView?
    
    var meSellingMessageView:MeSellingMessageView?
    
    var meContainerView:UIView?
    
    var profileCanExpireView:MeProfileCanExpireView?
    
    let utilities = Utilities.sharedUtility() as! Utilities
    
    let profileAction:ProfileActionManager = ProfileActionManager()
    
    var isNewVisitorToBeAddedFromNotification = false
    
    var isUserAlreadyPresent = false
    
    var sellingMessage = ""
    
    var sellingMessageButtonText = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Needed in did load as it add data from notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWhenANewUserAppearedFromNotification), name: NSNotification.Name(rawValue: kUpdateVisitorView_NewVisitorAdded), object: nil)
        
        isNewVisitorToBeAddedFromNotification = UserDefaults.standard.bool(forKey: "isNewVisitorToBeAddedFromNotification")
        
        createEmptyView()
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_Visitors", withEventName: "3-MeSection.Me_Visitors.MV_Landing")
        
        // Do any additional setup after loading the view.
        changeSellingMessage = true
        if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase() && WooPlusModel.sharedInstance().isExpired) {
            isPaidUser = false
        }
        else{
            isPaidUser = true
        }
        
        if (isNewVisitorToBeAddedFromNotification == true)
        {
            loadingMoreViewHeightConstraint.constant = 0.0
        }
        visitorCollectionView.backgroundColor = UIColor.clear
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("VisitorProfileVc didReceiveMemoryWarning")
        SDImageCache.shared().clearMemory()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog("Visitor view will appear")
        super.viewWillAppear(animated)
        
        if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase() && WooPlusModel.sharedInstance().isExpired) {
            isPaidUser = false
        }
        else{
            isPaidUser = true
            self.purchasedWork()
            if (LoginModel.sharedInstance()?.gender == "MALE"){
                self.removeExpiryView()
            }
        }
        
        if (isNewVisitorToBeAddedFromNotification == false)
        {
            getVistorData()
            toggleSellingMessage()
            showOrRemoveSellingMessages()
            if meSellingMessageView != nil{
                createContainerView(sellingMessageView: meSellingMessageView)
            }
            if (LoginModel.sharedInstance()?.gender == "MALE"){
                showProfileCanExpireView(isMale: true)
            }
            else{
                showProfileCanExpireView(isMale: false)
            }
        }
        else
        {
            loadingMoreViewHeightConstraint.constant = 0.0
        }
        
        automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.isNavigationBarHidden = true;
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        
        AppLaunchModel.sharedInstance().numberOfTimesVisitorLaunched += 1
        if AppLaunchModel.sharedInstance().numberOfTimesVisitorLaunched > 10 {
            AppLaunchModel.sharedInstance().numberOfTimesVisitorLaunched = 1
        }
        if(isPaidUser)
        {
            AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection = false
        }
        if (isNewVisitorToBeAddedFromNotification == false)
        {
            
            if(isPaidUser)
            {
                if #available(iOS 11.0, *) {
                    if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                        topToCollectionViewConstraint.constant = 44.0
                    }
                }
                
                if(BoostAPIClass.getIsfetchingVisitorDataFromServerValue() && visitorProfileData_Grouped.count > 0)
                {
                    //when fetching
                    loadingMoreViewHeightConstraint.constant = 55.0
                    topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant + loadingMoreViewHeightConstraint.constant
                    
                }
                else
                {
                    loadingMoreViewHeightConstraint.constant = 0.0
                    topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant + loadingMoreViewHeightConstraint.constant
                    
                }
            }
            else{
                loadingMoreViewHeightConstraint.constant = 0.0
                topToCollectionViewConstraint.constant = topToCollectionViewConstraint.constant + loadingMoreViewHeightConstraint.constant
                
            }
        }
        
        //if user is paid user and grouped data is not empty
        // && visitorProfileData_Grouped.count > 0
        //Aded observers only for paid users
        if isPaidUser
        {
            NotificationCenter.default.addObserver(self, selector: #selector(showLoadingForPagination), name: NSNotification.Name(rawValue: kPaginationCallStarted), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(showLoadingForPagination), name: NSNotification.Name(rawValue: kPaginationCallStopped), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(reloadViewMaintainingScrollPosition), name: NSNotification.Name(rawValue: kNewVisitorAddedOnPagination), object: nil)
            
        }
        if (scrolledCollectionView > 0){
            visitorCollectionView.setContentOffset(CGPoint(x: 0,y :scrolledCollectionView), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPaginationCallStarted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPaginationCallStopped), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNewVisitorAddedOnPagination), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateVisitorView_NewVisitorAdded), object: nil)
    }
    
    @objc func dimissTheScreen()
    {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    @objc func reloadDataWhenANewUserAppearedFromNotification(notification:Notification)
    {
        //NSLog("reloadDataWhenANewUserAppearedFromNotification called")
        UserDefaults.standard.set(false, forKey: "isNewVisitorToBeAddedFromNotification")
        UserDefaults.standard.synchronize()
        self.loadingMoreViewHeightConstraint.constant = 0.0
        self.isNewVisitorToBeAddedFromNotification = true
        self.visitorCollectionView.isHidden = true
        self.showWooLoader()
        
        ///Fetch from server
        BoostAPIClass.getVisitorsFromServer(withLimit: 100, withTime: nil, withPaginationToken: nil, withIndexValue: 0) { (response, isSuccess) in
            
            if response != nil{
                let responseDictionary = response as! [AnyHashable:Any]
                NSLog("responseDictionary \(responseDictionary)")
                let arrayOfProfiles = responseDictionary["profiles"]
                MeDashboard.insertOrUpdateBoostDashboardData(arrayOfProfiles as! [Any], for: VisitorMe) { (completed) in
                if completed
                    {
                        NSLog("InsertionCompleter")
                        DispatchQueue.main.async
                            {
                                self.isNewVisitorToBeAddedFromNotification = false
                                self.getVistorData()
                                self.toggleSellingMessage()
                                self.showOrRemoveSellingMessages()
                                //                    self.meSectionEmptyViewObj?.isHidden = false
                                self.hideWooLoader()
                                if self.meContainerView == nil{
                                    self.createContainerView(sellingMessageView: self.meSellingMessageView)
                                }
                                self.visitorCollectionView.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    @objc func  showLoadingForPagination()
    {
        if meSectionEmptyViewObj != nil && meSectionEmptyViewObj?.isHidden == false {
            return
        }
        if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase() && WooPlusModel.sharedInstance().isExpired) {
            isPaidUser = false
        }
        else{
            isPaidUser = true
            if(BoostAPIClass.getIsfetchingVisitorDataFromServerValue())
            {
                if(loadingMoreViewHeightConstraint.constant != 55.0)
                {
                    //when fetching
                    loadingMoreDataView.isHidden = false
                    loadingMoreViewHeightConstraint.constant = 55.0
                }
            }
            else
            {
                loadingMoreDataView.isHidden = true
                loadingMoreViewHeightConstraint.constant = 0.0
                
                updateVisitorData()
                visitorCollectionView.reloadData()
                if (visitorCollectionView.contentOffset.y > 0)
                {
                    addAndShowNewProfilesView()
                }
            }
            topToCollectionViewConstraint.constant = 44.0 + loadingMoreViewHeightConstraint.constant
        }
    }
    
    @objc func reloadViewMaintainingScrollPosition(notification: NSNotification)
    {
        if MeDashboard.getAllBoostProfiles().count <= 0
        {
            return
        }
        
        if (LoginModel.sharedInstance()?.gender == "FEMALE")
        {
            // Iterate through new users and add them
            let arrayOfAddedVisitors = notification.object as! [MeDashboard]
            
            //Divide data into expiry non expiry
            let expiryprofilesArray:[AnyObject] =  getExpiryProfilesFromArray(addedProfiles: arrayOfAddedVisitors)
            //expiry wale k data k liye sorted in order of first expiring to last expiring , add them to the expiring index
            
            let indexForInsertion = Int(MeDashboard.getExpiryIndexForInsertion())
            
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
                //                let currentOffset = visitorCollectionView.contentOffset
                if visitorCollectionView.contentOffset.y <= 0{
                    addExpiredViewNow()
                    DispatchQueue.main.async {
                        // CATransaction.begin()
                        // CATransaction.disableActions()
                        self.expiryView?.expiredDataArray.insert(contentsOf: expiryprofilesArray, at: indexForInsertion)
                        self.expiryView?.expiredCollectionView.performBatchUpdates(
                            {
                                self.expiryView?.expiredCollectionView.insertItems(at:indexPathArrayForInsertion)
                                
                        },completion: {(completed) in
                            if (completed)
                            {
                                // self.updateVisitorData()
                                //  self.visitorCollectionView.reloadData()
                            }
                        })
                        
                        //  CATransaction.commit()
                        
                    }
                }
                if self.deleteGoingOn == false {
                    self.updateVisitorData()
                    self.visitorCollectionView.reloadData()
                }
            }
        }
        else
        {
            //Add within groups
            updateVisitorData()
            visitorCollectionView.reloadData()
            
        }
        
        
    }
    
    func getExpiryProfilesFromArray(addedProfiles:[MeDashboard]) -> [MeDashboard]
    {
        let utilities = Utilities.sharedUtility() as! Utilities
        let thresholdDaysCount = AppLaunchModel.sharedInstance().meSectionProfileExpiryDaysThreshold
        let filteredArray = addedProfiles.filter()
        {
            $0.visitorExpiryTime! <=  utilities.dateAfterSubtractingDays(inCurrentDate: Int32(thresholdDaysCount))
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
                    self.visitorCollectionView.setContentOffset(CGPoint(x: 0.0, y: -CGFloat((self.expiryView?.bounds.size.height) ?? 0)) , animated: true)
                    
                    // ((self.expiryView!.bounds.size.height))
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
    
    func addRefreshControl()
    {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(reloadViewAfterRemovingData), for: .valueChanged)
        visitorCollectionView.addSubview(refreshControl)
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
                self.pushButtonTapped(UIButton())
            }
        }
        
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
            }
            else{
                topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
            }
        }
        else{
            topToCollectionViewConstraint.constant = 44.0 + sellingMessageHeight
        }
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
        
        if containerHeight > 0 && meContainerView == nil {
            meContainerView = UIView(frame: CGRect(x: 0.0, y: 64, width: SCREEN_WIDTH, height: containerHeight))
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
    
    func createEmptyView() {
        //        meSectionEmptyViewObj.frame = self.view.bounds
        if meSectionEmptyViewObj == nil{
            meSectionEmptyViewObj = MeSectionEmptyView.init(frame: self.view.bounds)
        }
        meSectionEmptyViewObj?.isHidden = true
        meSectionEmptyViewObj?.backgroundColor = UIColor.clear
        meSectionEmptyViewObj?.actionBtnTappedBlock = { (btnTapped: Bool) in
            let meSectionEmptyViewObjButton:UIButton = UIButton()
            meSectionEmptyViewObjButton.tag = 300
            self.pushButtonTapped(meSectionEmptyViewObjButton)
            
        }
        self.view.addSubview(meSectionEmptyViewObj!)
    }
    
    func addingShadowOnButton(_ btn : UIButton) -> UIButton {
        
        btn.layer.shadowColor = UIColor.darkGray.cgColor
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 3.0
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        return btn
        
    }
    
    func showOrRemoveSellingMessages() -> Void {
        
        if visitorProfileArray.count > 0 {
            visitorProfileArray.removeAllObjects()
        }
        visitorProfileArray.addObjects(from: MeDashboard.getAllBoostProfilesSortedByTimestamp())
        
        visitorCollectionView.isScrollEnabled = true
        
        
        var showSellingMsgView: Bool = false
        var showEmptyMsgView: Bool = false
        var showEmptyScreenButton: Bool = false
        let noVisitor = (visitorProfileArray.count < 1) ? true : false
        
        switch actionButtonType {
        case .none:
            showSellingMsgView = false
            showEmptyMsgView = false || noVisitor
            showEmptyScreenButton = false
            break
        case .boost_PURCHASE:
            showSellingMsgView = !isPaidUser && !noVisitor
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = showEmptyMsgView
            break
        case .woo_PLUS_PURCHASE:
            showSellingMsgView = !isPaidUser && !noVisitor
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = showEmptyMsgView
            break
        case .boost_PROFILE:
            showSellingMsgView = !isPaidUser && !noVisitor
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = noVisitor
            break
        case .boost_PURCHASED_WITHOUT_WOO_PLUS:
            showSellingMsgView = false
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = false
            break
        case .woo_PLUS_PURCHASED_WITHOUT_BOOST:
            showSellingMsgView = false
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = true
            break
        case .boost_AND_WOO_PLUS_PURCHASED:
            showSellingMsgView = false
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = false
            break
        case .boost_AND_WOO_PLUS_PURCHASED_AND_BOOST_ACTIVE:
            showSellingMsgView = false
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = false
            break
        case .boost_PURCHASED_AND_ACTIVE:
            showSellingMsgView = false
            showEmptyMsgView = noVisitor
            showEmptyScreenButton = false
            break
        }
        
        if showSellingMsgView{
            addMeSellingView()
        }
        if(BoostAPIClass.getIsfetchingVisitorDataFromServerValue()){
            meSectionEmptyViewObj?.isHidden = !showEmptyMsgView
            visitorCollectionView.isHidden = showEmptyMsgView
        }
        else{
            if visitorProfileArray.count > 0{
                meSectionEmptyViewObj?.isHidden = true
                visitorCollectionView.isHidden = false
            }
            else{
                meSectionEmptyViewObj?.isHidden = false
                visitorCollectionView.isHidden = true
            }
        }
        meSectionEmptyViewObj?.showActionButton(showActionButton: showEmptyScreenButton)
    }
    
    func toggleSellingMessage() -> Void {
        
        if !changeSellingMessage {
            return
        }
        
        //If non paid user
        if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase() && WooPlusModel.sharedInstance().isExpired) {
            if visitorProfileArray.count <= 2 {
                
                if (LoginModel.sharedInstance()?.gender == "MALE")
                {
                    if visitorProfileArray.count == 0 {
                        actionButtonType = .boost_PURCHASE
                    }
                    else{
                        actionButtonType = .woo_PLUS_PURCHASE
                    }
                }
                else
                {
                    actionButtonType = .woo_PLUS_PURCHASE
                }
                
            }
            else{
                //changed as Peush asked on 24 March, 2017. 
                //If visitor are greater than 2 show only Woo plus.
                actionButtonType = .woo_PLUS_PURCHASE
            }
        }
        else
        {
            //If paid user
            if(visitorProfileArray.count < 1)
            {
                if (!WooPlusModel.sharedInstance().isExpired && BoostModel.sharedInstance().checkIfUserNeedsToPurchase())
                {
                    if (LoginModel.sharedInstance()?.gender == "MALE")
                    {
                        actionButtonType = .woo_PLUS_PURCHASED_WITHOUT_BOOST
                    }
                    else
                    {
                        actionButtonType = .boost_AND_WOO_PLUS_PURCHASED_AND_BOOST_ACTIVE
                    }
                }
                else
                {
                    if (!BoostModel.sharedInstance().currentlyActive && (LoginModel.sharedInstance()?.gender == "MALE")){
                        actionButtonType = .boost_PROFILE
                    }
                    else{
                        actionButtonType = .boost_AND_WOO_PLUS_PURCHASED_AND_BOOST_ACTIVE
                    }
                    
                }
            }
        }
        
        
        changeSellingMessage = false
        
        switch actionButtonType {
        case .none:
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: NSLocalizedString("You’ll see the ones who visited you here", comment: ""), actionButtonTitle: NSLocalizedString("", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            break
        case .boost_PURCHASED_AND_ACTIVE:
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: NSLocalizedString("You’ll see the ones who visited you here", comment: ""), actionButtonTitle: NSLocalizedString("", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            break
        case .boost_AND_WOO_PLUS_PURCHASED_AND_BOOST_ACTIVE:
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: NSLocalizedString("In the meantime…\nDiscover more profiles", comment: ""), actionButtonTitle: NSLocalizedString("", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            break
        case .boost_PURCHASE:
            sellingMessage = AppLaunchModel.sharedInstance().boostVisitorsLockedText ?? NSLocalizedString("Get discovered by more people.", comment: "")
            sellingMessageButtonText = NSLocalizedString("BOOST ME NOW", comment: "")
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().boostVisitorText, actionButtonTitle: NSLocalizedString("BOOST ME NOW", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            break
        case .woo_PLUS_PURCHASED_WITHOUT_BOOST:
            sellingMessage = AppLaunchModel.sharedInstance().boostVisitorText ?? ""
            sellingMessageButtonText = NSLocalizedString("BOOST ME NOW", comment: "")
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().boostVisitorText, actionButtonTitle: NSLocalizedString("BOOST ME NOW", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            //                visitorCollectionView.userInteractionEnabled = false
            break
        case .woo_PLUS_PURCHASE:
            sellingMessage = AppLaunchModel.sharedInstance().subscriptionVisitorText
            sellingMessageButtonText = NSLocalizedString("UNLOCK WITH WOOPLUS", comment: "")
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().subscriptionVisitorText, actionButtonTitle: NSLocalizedString("UNLOCK WITH WOOPLUS", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            break
        case .boost_PROFILE:
            
            meSectionEmptyViewObj?.setEmptyScreenDetail(withTitle: NSLocalizedString("People who came across your profile will show here", comment: ""), sellingMessage: AppLaunchModel.sharedInstance().activateBoostText, actionButtonTitle: NSLocalizedString("ACTIVATE A BOOST", comment: ""), showBoostIcon: BoostModel.sharedInstance().currentlyActive, isUserMale: Utilities().isGenderMale(LoginModel.sharedInstance()?.gender))
            break
        default:
            print("hello")
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.me, animated: false)
        self.navBar?.setTitleText("Visitors")
        self.navigationController?.isNavigationBarHidden = true;
        
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(VisitorViewController.backButton))
    }
    
    func setMarginAccordingToData() -> Void {
        let widthForCell = SCREEN_WIDTH - 27
        cellWidth = widthForCell/2
        spaceBetweenCells = 20
        cellHeight = cellWidth * 1.7
        leftMargin = 9
    }
    
    func updateFirstAndFourthProfileWithFakeData(){
        let commonTagData:NSMutableDictionary = NSMutableDictionary()
        var visitorListArray = NSMutableArray()
        if visitorProfileData_Grouped.count > 0{
            let sectionKey = self.totalSectionArray.object(at: 0)
            visitorListArray = self.visitorProfileData_Grouped.object(forKey: sectionKey) as? NSMutableArray ?? NSMutableArray()
        }
        if visitorListArray.count > 0{
            if visitorListArray.count >= 4{
                let randomBool = Bool.random()
                var firstName = DiscoverProfileCollection.sharedInstance.myProfileData?.location ?? "" as NSString
                let randomNumber = Int.random(in: 1...5)
                var secondName = "\(randomNumber) kms away"
                var firstIndex = 3
                var secondIndex = 0
                var profileFaked1 = "firstProfileFaked"
                var profileFaked2 = "secondProfileFaked"
                if randomBool == false{
                    let tempIndex = firstIndex
                    firstIndex = secondIndex
                    secondIndex = tempIndex
                    
                    let tempName = firstName
                    firstName = secondName as NSString
                    secondName = tempName as String
                    profileFaked1 = "secondProfileFaked"
                    profileFaked2 = "firstProfileFaked"
                }
                
                if UserDefaults.standard.bool(forKey: profileFaked1) == false{
                    let firstBoostData = visitorListArray[firstIndex] as? MeDashboard
                    commonTagData.setValue(0, forKey: "tagId")
                    commonTagData.setValue(firstName, forKey: "name")
                    commonTagData.setValue("USER_DISTANCE", forKey: "tagsDtoType")
                    commonTagData.setValue(0, forKey: "order")
                    commonTagData.setValue("ic_location.png", forKey: "url")
                    commonTagData.setValue(true, forKey: "isFake")
                    MeDashboard.updateCommonTags(commonTagData as! [AnyHashable : Any], forBoostObject: firstBoostData ?? MeDashboard()) { (isCompleted) in
                        self.visitorCollectionView.reloadData()
                        UserDefaults.standard.set(true, forKey: profileFaked1)
                        UserDefaults.standard.synchronize()
                    }
                    
                }
                
                if UserDefaults.standard.bool(forKey: profileFaked2) == false{
                    let fourthBoostData = visitorListArray[secondIndex] as? MeDashboard
                    commonTagData.setValue(0, forKey: "tagId")
                    commonTagData.setValue(secondName, forKey: "name")
                    commonTagData.setValue("USER_DISTANCE", forKey: "tagsDtoType")
                    commonTagData.setValue(0, forKey: "order")
                    commonTagData.setValue("ic_location.png", forKey: "url")
                    commonTagData.setValue(true, forKey: "isFake")
                    MeDashboard.updateCommonTags(commonTagData as! [AnyHashable : Any], forBoostObject: fourthBoostData ?? MeDashboard()) { (isCompleted) in
                        self.visitorCollectionView.reloadData()
                        UserDefaults.standard.set(true, forKey: profileFaked2)
                        UserDefaults.standard.synchronize()
                    }
                }
            }
            else{
                if UserDefaults.standard.bool(forKey: "firstProfileFaked") == false{
                    let firstBoostData = visitorListArray[0] as? MeDashboard
                    commonTagData.setValue(0, forKey: "tagId")
                    commonTagData.setValue(DiscoverProfileCollection.sharedInstance.myProfileData?.location, forKey: "name")
                    commonTagData.setValue("USER_DISTANCE", forKey: "tagsDtoType")
                    commonTagData.setValue(0, forKey: "order")
                    commonTagData.setValue("ic_location.png", forKey: "url")
                    commonTagData.setValue(true, forKey: "isFake")
                    MeDashboard.updateCommonTags(commonTagData as! [AnyHashable : Any], forBoostObject: firstBoostData ?? MeDashboard()) { (isCompleted) in
                        self.visitorCollectionView.reloadData()
                        UserDefaults.standard.set(true, forKey: "firstProfileFaked")
                        UserDefaults.standard.synchronize()
                    }
                    
                }
            }
        }
    }
    
    func updateVisitorData(){
        if visitorProfileArray.count > 0 {
            visitorProfileArray.removeAllObjects()
        }
        if (LoginModel.sharedInstance()?.gender == "MALE"){
            //for males all data is shown in groups regardless of expiry non expiry
            if isPaidUser{
                visitorProfileData_Grouped = MeDashboard.getGroupedVisitorDataAccordingToTheGroups()
                
            }
            else{
            if WooPlusModel.sharedInstance().showExpiryEnabledForVisitors {
                visitorProfileData_Grouped = MeDashboard.getNonExpiredGroupedVisitorDataAccordingToTheGroups()

                if MeDashboard.getAllExpiringVisitors().count > 0 {
                    
                        if expiryView == nil
                        {
                            addExpiredViewNow()
                            expiryView?.expiredDataArray = updateExpiryArrayForExpiredData(MeDashboard.getAllExpiringVisitors() as NSArray, type: .Visitors) as [AnyObject]
                            expiryView?.expiredCollectionView.reloadData()
                        }
                        else{
                            self.visitorCollectionView.contentInset = UIEdgeInsets(top: CGFloat((expiryView?.frame.size.height)!), left: 0, bottom: 0, right: 0)
                            self.visitorCollectionView.contentOffset = CGPoint(x: 0, y: -Int((expiryView?.frame.size.height)!))
                    }
                }
            }
            else{
                visitorProfileData_Grouped = MeDashboard.getGroupedVisitorDataAccordingToTheGroups()
            }
            }
        }
        else{
            //for females get grouped non expiry data
            

            visitorProfileData_Grouped = MeDashboard.getNonExpiredGroupedVisitorDataAccordingToTheGroups()
            if MeDashboard.getAllExpiringVisitors().count > 0 {
            if isPaidUser == true
            {
                if expiryView == nil
                    {
                        if self.visitorCollectionView.contentOffset.y <= 0{
                            addExpiredViewNow()
                            expiryView?.expiredDataArray = updateExpiryArrayForExpiredData(MeDashboard.getAllExpiringVisitors() as NSArray, type: .Visitors) as [AnyObject]
                            expiryView?.expiredCollectionView.reloadData()
                        }
                    }
                    else{
                        self.visitorCollectionView.contentInset = UIEdgeInsets(top: CGFloat((expiryView?.frame.size.height)!), left: 0, bottom: 0, right: 0)
                        self.visitorCollectionView.contentOffset = CGPoint(x: 0, y: -Int((expiryView?.frame.size.height)!))
                    }
                }
            }
        }
        
        totalSectionArray =  NSMutableArray(array: visitorProfileData_Grouped.allKeys)
        
        totalSectionArray = NSMutableArray(array: totalSectionArray.sortedArray(comparator: { (firstObject, secondObj) -> ComparisonResult in
            if(Int(truncating: firstObject as! NSNumber) > Int(truncating: secondObj as! NSNumber)){
                return .orderedDescending
            }
            else if (Int(truncating: firstObject as! NSNumber) < Int(truncating: secondObj as! NSNumber) ){
                return .orderedAscending
            }
            return .orderedSame
        }))
        visitorProfileArray.addObjects(from: MeDashboard.getAllBoostProfilesSortedByTimestamp())
        if (isPaidUser == false){
        self.updateFirstAndFourthProfileWithFakeData()
        }

    }
    
    func showProfileCanExpireView(isMale:Bool){
        
        var showExpiryPopUp = true
        
        if isMale{
            showExpiryPopUp = WooPlusModel.sharedInstance().showExpiryEnabledForVisitors
        }
        
        if MeDashboard.getAllBoostProfilesSortedByTimestamp().count > 0 {
            if showExpiryPopUp{
                if UserDefaults.standard.bool(forKey: "ProfileCanExpireHasBeenShowed") == false {
                    if profileCanExpireView == nil {
                        profileExpiryViewIsVisible = true
                        profileCanExpireView = MeProfileCanExpireView.loadViewFromNib(frame: CGRect(x: 0, y: -210 - safeAreaTop, width: SCREEN_WIDTH, height: 210))
                        profileCanExpireView?.updateExpiryText()
                        profileCanExpireView?.dismissHandler = {
                            self.profileExpiryViewIsVisible = true
                            UIView.animate(withDuration: 0.2, animations: {
                                self.profileCanExpireView?.transform = CGAffineTransform.identity
                            }, completion: { (true) in
                                self.profileCanExpireView?.removeFromSuperview()
                                self.profileCanExpireView = nil
                            })
                        }
                        self.view.addSubview(profileCanExpireView!)
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
        if expiryView == nil{
            expiryView = MeExpiredView.loadViewFromNib(frame: CGRect(x: 0.0, y: -expiryCellHeight, width: SCREEN_WIDTH, height: expiryCellHeight))
            expiryView?.paidUser = isPaidUser
            expiryView?.needToShowLock = WooPlusModel.sharedInstance().maskingEnabledForVisitors
            expiryView?.purchaseHandler = {() in
                self.pushButtonTapped(UIButton())
            }
            self.visitorCollectionView.contentInset = UIEdgeInsets(top: CGFloat(expiryCellHeight), left: 0, bottom: 0, right: 0)
            self.visitorCollectionView.contentOffset = CGPoint(x: 0, y: -expiryCellHeight)
            self.visitorCollectionView.addSubview(expiryView!)
            self.visitorCollectionView.sendSubviewToBack(expiryView!)
            expiryView?.snp.makeConstraints { (make) in
                make.top.equalTo(self.visitorCollectionView).offset(-expiryCellHeight)
                make.leading.equalTo(self.visitorCollectionView).offset(0)
                make.trailing.equalTo(self.visitorCollectionView).offset(0)
                make.height.equalTo(expiryCellHeight)
                make.width.equalTo(SCREEN_WIDTH)
            }
            expiryView?.dataType = .Visitors
            expiryView?.prepareExpiryData()
        }
        
        expiryView?.openExpiryVcHandler = {(dataType:MeDataType) in
            let expiryCollectionVc = self.storyboard?.instantiateViewController(withIdentifier: "ExpiryProfilesViewController") as! ExpiryProfilesViewController
            expiryCollectionVc.parentViewType = dataType
            expiryCollectionVc.isPaidUser = self.isPaidUser
            expiryCollectionVc.actionButtonType = self.actionButtonType
            expiryCollectionVc.dismissViewControllerHandler = { (expiryToBeReloaded:Bool) in
                if(expiryToBeReloaded == true)
                {
                    let expiryDataArray = updateExpiryArrayForExpiredData(MeDashboard.getAllExpiringVisitors() as NSArray, type: .Visitors) as [AnyObject]
                    
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
            }
            self.navigationController?.pushViewController(expiryCollectionVc, animated: true)
            
        }
        
        expiryView?.openProfileDetailHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject, comingFromExpired:Bool, expiredIndexPath:IndexPath) in
            
            self.scrolledCollectionView = 0
            self.indexPathToDelete = expiredIndexPath
            self.actionPerformedFromExpire = comingFromExpired
            self.comingFromProfile = false
            self.currentVisitorDetail = userProfile as? MeDashboard
            self.needToOpenCrushSendViewInProfileDetail = false
            
            if needToTakeAction == PerformAction.Pass {
                self.dislikeUser(expiredIndexPath)
            }
            else if needToTakeAction == PerformAction.CrushSent{
                if (!(CrushModel.sharedInstance().checkIfUserNeedsToPurchase())){
                    if CrushModel.sharedInstance().availableCrush > 0 {
                        self.needToOpenCrushSendViewInProfileDetail = true
                        self.pushtoDetailView(self.currentVisitorDetail!, indexPath: expiredIndexPath)
                    }
                }
                else{
                    //out of crushes view
                    WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseCrush)
                    WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.needToOpenCrushSendViewInProfileDetail = true
                            self.pushtoDetailView(self.currentVisitorDetail!, indexPath: expiredIndexPath)
                        }
                    }
                }
            }
            else if needToTakeAction == PerformAction.Like{
                self.likeUser(expiredIndexPath)
            }
            else{
                self.pushtoDetailView(self.currentVisitorDetail!, indexPath: expiredIndexPath)
            }
        }
        
        expiryView?.removeViewHandler = {
            self.removeExpiryView()
        }
    }
    
    func removeExpiryView()
    {
        if self.expiryView != nil{
            self.expiryView?.removeFromSuperview()
            self.expiryView = nil
            self.visitorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.visitorCollectionView.contentOffset = CGPoint(x: 0, y: 0)
            DispatchQueue.main.async {
                self.showOrRemoveSellingMessages()
            }
        }
    }
    func getVistorData() -> Void {
        updateVisitorData()
        setMarginAccordingToData()
        visitorCollectionView.reloadData()
    }
    
    @IBAction func pushButtonTapped(_ sender: UIButton){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        
        let window:UIWindow = UIApplication.shared.keyWindow!
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
        
        switch actionButtonType {
        case .boost_PURCHASE:
            
            var funnelString = "Visitor_locked_boost"
            
            if sender.tag == 200 || sender.tag == 300{
                funnelString = "Visitor_boost_cta"
            }
            purchaseObj.initiatedView = funnelString
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: funnelString)
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
            //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_Visitors", withEventName: "3-MeSection.Me_Visitors.MV_GetBoost_Tap")
            
            break
        case .woo_PLUS_PURCHASE:
            
            var funnelString = "visitor_locked_WP"
            
            if sender.tag == 200 || sender.tag == 300{
                funnelString = "Visitor_WP_cta"
            }
            
            purchaseObj.scrollableIndex = 2
            purchaseObj.purchaseShownOnViewController = self
            purchaseObj.initiatedView = funnelString
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: funnelString)
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
            break
        case .boost_PROFILE:
            if BoostModel.sharedInstance().currentlyActive == false {
                if BoostModel.sharedInstance().availableBoost > 0 && BoostModel.sharedInstance().currentlyActive == false {
                    BoostProductsAPICalss.activateBoost(forWooID: (UserDefaults.standard.object(forKey: kWooUserId) as?String), withCompletionBlock: { (successFlag, responseObj, statusCode) in
                        
                        if  successFlag{
                            // lets do something here for handling boosted stuff
                            WooScreenManager.sharedInstance.oHomeViewController?.checkIfBoostActive()
                        }else{
                            
                        }
                        self.changeSellingMessage = true
                        self.getVistorData()
                        self.toggleSellingMessage()
                        DispatchQueue.main.async {
                            self.showOrRemoveSellingMessages()
                        }
                    })
                }
            }
            break
        default:
            NSLog("nothing to do", "")
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
        }
        purchaseObj.purchasedHandler = { (isPurchased:Bool) in
            
            self.ifPurchasedWork()
            if (LoginModel.sharedInstance()?.gender == "MALE"){
                self.removeExpiryView()
            }
        }
        purchaseObj.purchaseDismissedHandler = {
            (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
            dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                DispatchQueue.main.async
                    {
                        self.ifPurchasedWork()
                        if (LoginModel.sharedInstance()?.gender == "MALE"){
                            self.removeExpiryView()
                        }
                        
                }
            }
            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
            
        }
        
    }
    
    func ifPurchasedWork(){
        
        self.meContainerView?.removeFromSuperview()
        self.meContainerView = nil
        self.meSellingMessageView = nil
        self.changeSellingMessage = true
        self.viewWillAppear(true)
        self.visitorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.visitorCollectionView.contentOffset = CGPoint(x: 0, y: 0)
        self.topToCollectionViewConstraint.constant = 44.0
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                topToCollectionViewConstraint.constant = 44.0
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
        self.visitorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.visitorCollectionView.contentOffset = CGPoint(x: 0, y: 0)
        self.topToCollectionViewConstraint.constant = 44.0
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                topToCollectionViewConstraint.constant = 44.0
            }
        }
    }
    
    @objc func reloadViewAfterRemovingData(_ tapIndexPath:IndexPath) {
        if actionPerformedFromExpire == true {
            if expiryView != nil {
                expiryView?.reloadViewAfterRemovingData()
            }
            return
        }
        
        if self.totalSectionArray.count <= 0 {
            self.visitorCollectionView.reloadData()
            return
        }
        
        var isSectionToBeDeleted = false
        
        //self.visitorCollectionView.isUserInteractionEnabled = false
        
        let sectionKey = self.totalSectionArray.object(at: tapIndexPath.section)
        if (self.visitorProfileData_Grouped.object(forKey: sectionKey) as! NSMutableArray).count == 1 //&& self.indexPathToDelete!.section != 0
        {
            isSectionToBeDeleted = true
        }
        
        if isSectionToBeDeleted == true{
            self.visitorProfileData_Grouped.removeObject(forKey: sectionKey)
            self.totalSectionArray.remove(sectionKey)
        }
        else{
            if (self.visitorProfileData_Grouped.object(forKey: sectionKey) as! NSMutableArray).count > 0 && tapIndexPath.row < (self.visitorProfileData_Grouped.object(forKey: sectionKey) as! NSMutableArray).count {
                (self.visitorProfileData_Grouped.object(forKey: sectionKey) as! NSMutableArray).removeObject(at: (tapIndexPath.row))
            }
        }
        if (isSectionToBeDeleted == true){
            self.visitorCollectionView.deleteSections(IndexSet(integer: tapIndexPath.section))
        }
        else{
            if let _ = self.visitorCollectionView.cellForItem(at: tapIndexPath){
                self.visitorCollectionView.deleteItems(at: [tapIndexPath])
            }
        }
        
        self.toggleSellingMessage()
        self.showOrRemoveSellingMessages()
        self.deleteGoingOn = false
        self.perform(#selector(self.nowEnableCollectionView), with: nil, afterDelay: 0.2)
    }
    
    
    @objc func nowEnableCollectionView(){
        self.visitorCollectionView.isUserInteractionEnabled = true
        self.visitorCollectionView.reloadData()
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
    
    func pushtoDetailView(_ visitor:MeDashboard, indexPath:IndexPath){
        self.isUserAlreadyPresent = false
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_Visitors", withEventName: "3-MeSection.Me_Visitors.MV_UserProfile_Tap")
        
        guard visitor.visitorId != nil else {
            return
        }
        var model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(visitor.visitorId!)
        
        if model.wooId == nil{
            
            model = ProfileCardModel.init(model: visitor, profileType: .MeDashboard)
            
            let cell:MeCollectionViewCell?
            if self.actionPerformedFromExpire{
                cell = self.expiryView?.expiredCollectionView.cellForItem(at: indexPath) as? MeCollectionViewCell
            }
            else{
                cell = self.visitorCollectionView.cellForItem(at: indexPath) as? MeCollectionViewCell
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
            self.performSegue(withIdentifier: kPushFromVisitorToDetailProfileView, sender: model)
        })
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isPaidUser {
            //            let sectionInReverseOrder = self.totalSectionArray.count - ((indexPath as NSIndexPath).section + 1)
            if (visitorCollectionView.indexPathsForSelectedItems?.first) != nil{
                scrolledCollectionView = Int(visitorCollectionView.contentOffset.y)
            }
            startPurchaseFlow(indexPath)
        }
        else{
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_Visitors", withEventName: "3-MeSection.Me_Visitors.MV_LockedProfileTap")
            if profileExpiryViewIsVisible{
                UIView.animate(withDuration: 0.2, animations: {
                    self.profileCanExpireView?.transform = CGAffineTransform.identity
                }, completion: { (true) in
                    self.profileCanExpireView?.removeFromSuperview()
                    self.profileCanExpireView = nil
                    self.pushButtonTapped(UIButton())
                })
            }
            else{
                self.pushButtonTapped(UIButton())
            }
        }
        
    }
    
    private func startPurchaseFlow(_ indexPath:IndexPath){
        profileExpiryViewIsVisible = false
        actionPerformedFromExpire = false
        self.indexPathToDelete = indexPath
        let sectionKey = self.totalSectionArray.object(at: indexPath.section)
        let visitorListArray = self.visitorProfileData_Grouped.object(forKey: sectionKey) as! NSArray
        if let visitorDetail = visitorListArray.object(at: (indexPath as NSIndexPath).row) as? MeDashboard{
            self.needToOpenCrushSendViewInProfileDetail = false
            pushtoDetailView(visitorDetail, indexPath:self.indexPathToDelete!)
        }else{
            actionPerformedFromExpire = false
             let visitorDetail = visitorListArray.object(at: (indexPath as NSIndexPath).row) as! LikedMe
             needToOpenCrushSendViewInProfileDetail = false
             pushtoDetailLikeView(visitorDetail, indexPath: self.indexPathToDelete!, isMe: false)
        }
        
        // self.visitorCollectionView.isUserInteractionEnabled = false
    }
    
    
    func pushtoDetailLikeView(_ likedMe:LikedMe?, indexPath:IndexPath?, isMe:Bool){
        self.isUserAlreadyPresent = false
            if isMe {
                let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                controller.dismissHandler = { (needToOpenMyProfile, toClose) in
                    if needToOpenMyProfile {
                        let storyboard = UIStoryboard(name: "Home", bundle: nil)
                        let myProfileDPV =
                            storyboard.instantiateViewController(withIdentifier: "ProfileDeckDetailViewControllerID")
                                as? ProfileDeckDetailViewController
                        myProfileDPV?.profileData = DiscoverProfileCollection.sharedInstance.myProfileData! as ProfileCardModel
                        myProfileDPV?.isMyProfile = true
                        self.navigationController?.pushViewController(myProfileDPV!, animated: true)
                    }
                    
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                if let likedMeObject = likedMe{
                    if let userID = likedMeObject.userWooId{
                        LikedMe.updateHasUserProfileVisited(byAppUser: true, forUserWooId: userID, withCompletionHandler: {
                            
                            (completed) in
                            var model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(likedMe!.userWooId!)
                            
                            if model.wooId == nil{
                                model = ProfileCardModel.init(model: likedMe!, profileType: .LikedMe)
                                
                                let cell:MeCollectionViewCell?
                                if self.actionPerformedFromExpire{
                                    cell = self.expiryView?.expiredCollectionView.cellForItem(at: indexPath!) as? MeCollectionViewCell
                                }
                                else{
                                    
                                    cell = self.visitorCollectionView.cellForItem(at: self.indexPathToDelete!) as? MeCollectionViewCell
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
                            
                        })
                    }
                }
        }
            
     
    }
    
    
    @IBAction func addMoreData(_ sender: UIButton){
        visitorProfileArray.addObjects(from: MeDashboard.getAllBoostProfiles())
        setMarginAccordingToData()
        visitorCollectionView.reloadData()
        visitorCollectionView.needsUpdateConstraints()
        visitorCollectionView.layoutIfNeeded()
    }
    
    @IBAction func deleteData(_ sender: UIButton){
        for index in 1...3 {
            print(index)
            visitorProfileArray.removeLastObject()
        }
        setMarginAccordingToData()
        visitorCollectionView.reloadData()
        visitorCollectionView.needsUpdateConstraints()
        visitorCollectionView.layoutIfNeeded()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == kPushFromVisitorToDetailProfileView){
            let model = sender as! ProfileCardModel
            let profileVC = segue.destination as! ProfileDeckDetailViewController
            
            profileVC.profileData = model;
            profileVC.visitorData = visitorProfileArray.object(at: indexPathToDelete?.row ?? 0) as? MeDashboard
            profileVC.isViewPushed = true
            profileVC.isProfileAlreadyLoaded = self.isUserAlreadyPresent
            profileVC.openCrushView = needToOpenCrushSendViewInProfileDetail
            profileVC.detailProfileParentTypeOfView = DetailProfileViewParent.visitor
            profileVC.dismissHandler = { (currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel, onBoardingEditProfileDone:Bool, indexPath:IndexPath) in
                self.currentUserDetail = userProfile
                self.comingFromProfile = true
                self.crushText = crushString
                self.visitorCollectionView.isUserInteractionEnabled = true
                
                if needToTakeAction == . Pass {
                    self.reloadViewAfterRemovingData(self.indexPathToDelete!)
                }
                if needToTakeAction == .Like{
                    self.likeUser(self.indexPathToDelete!)
                }
                else if needToTakeAction == .CrushSent{
                    if self.actionPerformedFromExpire == true{
                        self.expiryView?.showCrushOverlayAndUpdateView()
                    }
                    else{
                        self.showCrushOverlayAndUpdateView()
                    }
                    self.sendCrush(self.indexPathToDelete!)
                }
            }
        }else  if (segue.identifier == kPushFromLikedMeToDetailProfileView){
                   let model = sender as! ProfileCardModel
                   let profileVC = segue.destination as! ProfileDeckDetailViewController
                   
                   profileVC.profileData = model;
                   profileVC.isViewPushed = true
                   profileVC.isProfileAlreadyLoaded = self.isUserAlreadyPresent
                   profileVC.openCrushView = needToOpenCrushSendViewInProfileDetail
                   profileVC.detailProfileParentTypeOfView = DetailProfileViewParent.likedMe
                   profileVC.dismissHandler = { (currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel, onBoardingEditProfileDone:Bool, indexPath:IndexPath) in
                       self.crushText = crushString
                       self.comingFromProfile = true
                       self.currentUserDetail = userProfile
                       
                       if needToTakeAction == .Pass {
                           self.reloadViewAfterRemovingData(self.indexPathToDelete!)
                       }
                       else if needToTakeAction == .Like{
                            self.likeUser(self.indexPathToDelete!)
                       }
                       else if needToTakeAction == .CrushSent{
                           if self.actionPerformedFromExpire == true{
                               self.expiryView?.showCrushOverlayAndUpdateView()
                           }
                           else{
                               self.showCrushOverlayAndUpdateView()
                           }
                           self.sendCrush(self.indexPathToDelete!)
                       }
                       
                   }
               }
        else if (segue.identifier == kPushToChatFromVisitor) {
            let chatViewControllerObj: NewChatViewController  = segue.destination as! NewChatViewController
            let model = sender as! MyMatches
            chatViewControllerObj.myMatchesData = model
            chatViewControllerObj.isAutomaticallyPushedFromChat = true
            chatViewControllerObj.parentView = .visitor
        }
    }
    
    func sendCrush(_ tapIndexPath:IndexPath){
        performActionForType(.CrushSent, tapIndexPath: tapIndexPath)
    }
    
    func likeUser(_ tapIndexPath:IndexPath)
    {
        performActionForType(.Like, tapIndexPath: tapIndexPath)
    }
    
    func dislikeUser(_ tapIndexPath:IndexPath){
        //new swrve/firebase events added
        utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_Skip")
        performActionForType(.Pass, tapIndexPath: tapIndexPath)
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
    
    fileprivate func showOutOfLikeAlert(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup")
        
        let outOfLikePopup = OutOfLikeView.showView(parentViewController: self)
        outOfLikePopup.dismissHandler = {
            self.visitorCollectionView.isUserInteractionEnabled = true
        }
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
                
                self.ifPurchasedWork()
                if (LoginModel.sharedInstance()?.gender == "MALE"){
                    self.removeExpiryView()
                }
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                    self.ifPurchasedWork()
                    if (LoginModel.sharedInstance()?.gender == "MALE"){
                        self.removeExpiryView()
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
        }
    }
    
    fileprivate func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    func showCrushOverlayAndUpdateView(){
        if (indexPathToDelete != nil) {
            let cell: MeCollectionViewCell? = visitorCollectionView.cellForItem(at: indexPathToDelete!) as? MeCollectionViewCell
            cell?.meProfileDeckView?.showOverlayForCrushSent()
        }
    }
    
    func performActionForType(_ actionType:PerformAction, tapIndexPath:IndexPath){
        
        profileAction.currentViewType = .Visitor
        profileAction.crushText = self.crushText
        profileAction.indexPathToBeDeleted = tapIndexPath
        //self.visitorCollectionView.isUserInteractionEnabled = false
        profileAction.reloadHandler = {(toDeleteIndexPath:IndexPath) in
            self.reloadViewAfterRemovingData(toDeleteIndexPath)
            //self.perform(#selector(self.nowEnableCollectionView), with: nil, afterDelay: 0.4)
            
        }
        profileAction.performSegueHandler = { (matchedUserDataFromDb:MyMatches) in
            if (Utilities().isChatRoomPresent(in: self.navigationController) == false){
                if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                }else{
                    self.performSegue(withIdentifier: kPushToChatFromVisitor, sender: matchedUserDataFromDb)
                }
            }
        }
        
        switch actionType {
        case .Like:
            if  comingFromProfile == true{
                profileAction.likeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            }
            else{
                 if(currentVisitorDetail != nil){
                profileAction.likeActionPerformed(.MeDashboard, userObject: currentVisitorDetail! as AnyObject)
                 }else{
                     profileAction.likeActionPerformed(.LikedMe, userObject: currentLikedMeUserDetail! as AnyObject)
                }
            }
            break
            
        case .Pass:
            if  comingFromProfile == true{
                profileAction.dislikeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            }
            else{
                if(currentVisitorDetail != nil){
                    profileAction.dislikeActionPerformed(.MeDashboard, userObject: currentVisitorDetail! as AnyObject)
                }else{
                     profileAction.dislikeActionPerformed(.LikedMe, userObject: currentLikedMeUserDetail! as AnyObject)
                }
                
            }
            break
            
        case .CrushSent:
            if  comingFromProfile == true{
                profileAction.crushActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            }
            else{
                  if(currentVisitorDetail != nil){
                profileAction.crushActionPerformed(.MeDashboard, userObject: currentVisitorDetail! as AnyObject)
                  }else{
                    profileAction.crushActionPerformed(.LikedMe, userObject: currentLikedMeUserDetail! as AnyObject)
                }
            }
            break
            
        default:
            break
        }
    }
    
    @IBAction func backButton(){
        NSLog("Visitor back button tapped")
        
        UserDefaults.standard.set(false, forKey: "isNewVisitorToBeAddedFromNotification")
        UserDefaults.standard.synchronize()
        
        if isPaidUser == true{
            if(BoostAPIClass.getIsfetchingVisitorDataFromServerValue()){
                AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection = true
            }
            else{
                AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection = false
            }
        }
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
        if expiryView != nil{
            if expiryView?.viewedProfilesIdArray.count > 0{
                self.visitedProfilesIdArray += expiryView!.viewedProfilesIdArray
            }
        }
        
        if visitedProfilesIdArray.count > 0 && isPaidUser == true {
            MeApiClass.syncProfileViews(visitedProfilesIdArray, withCompletionBlock: { (success, response) in
                //                NSLog("success value :%d", success)
                print("success\(success)")
                if self.visitedProfilesIdArray.count > 0{
                    self.visitedProfilesIdArray.removeAll()
                }
            })
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (self.visitorProfileData_Grouped.allKeys.count > 0)  {
            return self.totalSectionArray.count
        }
        
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.visitorProfileData_Grouped.allKeys.count > 0) {
            let sectionKey = self.totalSectionArray.object(at: section)
            return (self.visitorProfileData_Grouped.object(forKey: sectionKey)! as AnyObject).count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let tempView: UICollectionReusableView = UICollectionReusableView();
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView:MeHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MeHeaderView", for: indexPath) as! MeHeaderView
            let sectionKey = self.totalSectionArray.object(at: indexPath.section)
            
            if let firstObjectInSection = (self.visitorProfileData_Grouped.object(forKey: sectionKey)! as AnyObject).firstObject{
                
                if let coreDataObject = firstObjectInSection as? LikedMe{
                    if coreDataObject.isUserBoosted?.boolValue == true {
                        headerView.setHeaderTextForSection(isSectionForBoosted: true, textForHeader: NSLocalizedString("While boosted", comment: ""))
                    }
                    else{
                        if LoginModel.sharedInstance()?.gender == "FEMALE" || !isPaidUser{
                            headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recent Likes & Visits (expiring soon)", comment: ""))
                        }
                        else{
                            headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recent Likes & Visits", comment: ""))
                        }
                    }
                }else
                {
                    if (firstObjectInSection as! MeDashboard).isVisitorBoosted?.boolValue == true {
                        headerView.setHeaderTextForSection(isSectionForBoosted: true, textForHeader: NSLocalizedString("While boosted", comment: ""))
                    }
                    else{
                        if LoginModel.sharedInstance()?.gender == "FEMALE" || !isPaidUser{
                            headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recent Likes & Visits (expiring soon)", comment: ""))
                        }
                        else{
                            headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recent Likes & Visits", comment: ""))
                        }
                    }
                }
            }
            else{
                headerView.setHeaderTextForSection(isSectionForBoosted: false, textForHeader: NSLocalizedString("Recent Likes & Visits", comment: ""))
            }
            
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
        return tempView;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: visitorCollectionView.frame.size.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isPaidUser {
            let identifier = "MeCollectionViewCell"
            let cell: MeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MeCollectionViewCell)!
            let sectionKey = self.totalSectionArray.object(at: indexPath.section)
            let visitorListArray = self.visitorProfileData_Grouped.object(forKey: sectionKey) as! NSArray
            if let visitorDetail = visitorListArray.object(at: (indexPath as NSIndexPath).row) as? MeDashboard
            {
                if let visitorID = visitorDetail.visitorId{
                    MeDashboard.updateHasVisitorProfileVisited(byUser: true, forVisitorId: visitorID, withCompletionHandler: { (success) in
                        
                    })
                }
                cell.setUserDetail(userDetail: visitorDetail,isBundledProfile: false ,forType: .Visitors, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForVisitors, noOfTotalProfiles: visitorProfileArray.count, isExpired: false, profileIndex: indexPath.row, usedInExpiryProfiles: false)
                
                cell.meProfileDeckView?.dismissHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject) in
                    
                    let touchPoint = CGPoint(x: cell.center.x, y: cell.center.y)
                    
                    let tappedIndexPath = collectionView.indexPathForItem(at: touchPoint)
                    self.indexPathToDelete = tappedIndexPath
                    
                    // self.visitorCollectionView.isUserInteractionEnabled = false
                    self.comingFromProfile = false
                    self.deleteGoingOn = true
                    self.actionPerformedFromExpire = false
                    self.needToOpenCrushSendViewInProfileDetail = false
                    
                    self.currentVisitorDetail = userProfile as? MeDashboard
                    if needToTakeAction == PerformAction.Pass {
                        if let tappedIndex = tappedIndexPath{
                            self.dislikeUser(tappedIndex)
                        }
                        
                    }
                    else if needToTakeAction == PerformAction.CrushSent{
                        
                        WooScreenManager.sharedInstance.oHomeViewController?.crushFunnelMessage = "Visitor_profile_crush_tap"
                        self.needToOpenCrushSendViewInProfileDetail = true
                        self.pushtoDetailView(self.currentVisitorDetail!, indexPath: tappedIndexPath!)
                    }
                    else if needToTakeAction == PerformAction.Like{
                        if self.checkIfUserWillSeeOutOfLikeAlert() {
                            self.showOutOfLikeAlert()
                        }
                        else{
                            self.likeUser(tappedIndexPath!)
                        }
                    }
                }
                if let userWooidValue = visitorDetail.visitorId {
                    if visitedProfilesIdArray.contains(userWooidValue) == false{
                        visitedProfilesIdArray.append(userWooidValue)
                    }
                }
            }else{
                var visitorDetail:LikedMe? = visitorListArray.object(at: (indexPath as NSIndexPath).row) as? LikedMe
                          if visitorDetail == nil{
                              visitorDetail = LikedMe()
                          }
                
                if let visitorID = visitorDetail?.userWooId{
                                   LikedMe.updateHasUserProfileVisited(byAppUser: true, forUserWooId: visitorID, withCompletionHandler: { (success) in
                                       
                                   })
                               }
                          
                          cell.setUserDetail(userDetail: visitorDetail!, isBundledProfile:false , forType: .LikedMe, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForLikedMe, noOfTotalProfiles: visitorProfileArray.count, isExpired: false, profileIndex: indexPath.row, usedInExpiryProfiles: false)
                          
                          cell.meProfileDeckView?.dismissHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject) in
                              
                              let touchPoint = CGPoint(x: cell.center.x, y: cell.center.y)
                              
                              let tappedIndexPath = collectionView.indexPathForItem(at: touchPoint)
                              self.indexPathToDelete = tappedIndexPath
                              
                              self.comingFromProfile = false
                              self.deleteGoingOn = true
                              self.actionPerformedFromExpire = false
                              self.needToOpenCrushSendViewInProfileDetail = false

                              self.currentLikedMeUserDetail = userProfile as? LikedMe
                             if needToTakeAction == PerformAction.Pass {
                                self.dislikeUser(tappedIndexPath!)
                             }
                             else if needToTakeAction == PerformAction.CrushSent{
                                 WooScreenManager.sharedInstance.oHomeViewController?.crushFunnelMessage = "Likedme_profile_crush_tap"
                                 self.needToOpenCrushSendViewInProfileDetail = true
                                 self.pushtoDetailLikeView(self.currentLikedMeUserDetail!, indexPath: self.indexPathToDelete!, isMe: false)
                             }
                             else if needToTakeAction == PerformAction.Like{
                                 if self.checkIfUserWillSeeOutOfLikeAlert() {
                                     self.showOutOfLikeAlert()
                                 }
                                 else{
                                     self.likeUser(tappedIndexPath!)
                                 }
                             }
                          }
                          
                          if let userWooidValue = visitorDetail?.userWooId {
                              if visitedProfilesIdArray.contains(userWooidValue) == false{
                                  visitedProfilesIdArray.append(userWooidValue)
                              }
                          }
            }
            return cell
        }
        else{
            let identifier = "MeCollectionViewCell"
            let cell: MeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MeCollectionViewCell)!
            if let visitorDetail = self.visitorProfileArray.object(at: (indexPath as NSIndexPath).row) as? MeDashboard
            {
                
                
                cell.setUserDetail(userDetail: visitorDetail, isBundledProfile: false , forType: .Visitors, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForVisitors, noOfTotalProfiles: visitorProfileArray.count, isExpired: false, profileIndex: indexPath.row, usedInExpiryProfiles: false)
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if isPaidUser {
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
    
    
    
}

extension VisitorViewController : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView.contentOffset.y + 10 < lastOffSetLocation ) {
            //Upward
            print("removing new profiles for last offsetlocation = \(lastOffSetLocation)")
            removeNewProfilesView()
        }
        
        print("last offsetlocation = \(lastOffSetLocation) and scrollView.contentOffset.y = \(scrollView.contentOffset.y)")
        
        
        if scrollView.contentOffset.y <= 0{
            if (LoginModel.sharedInstance()?.gender == "FEMALE"){
                if MeDashboard.getAllExpiringVisitors().count > 0 {
                    if isPaidUser == true{
                        if expiryView == nil{
                            addExpiredViewNow()
                            expiryView?.expiredDataArray = updateExpiryArrayForExpiredData(MeDashboard.getAllExpiringVisitors() as NSArray, type: .Visitors) as [AnyObject]
                            expiryView?.expiredCollectionView.reloadData()
                        }
                    }
                }
                
            }
        }
        
        lastOffSetLocation = scrollView.contentOffset.y
    }
}

