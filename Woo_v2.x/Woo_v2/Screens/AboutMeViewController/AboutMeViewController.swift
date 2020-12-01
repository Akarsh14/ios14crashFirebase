//
//  AboutMeViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import Foundation

enum MeSectionCellType : String{
    case MyProfileCell                  = "MyProfileCell"
    case BoostWooPlusCell               = "BoostWooPlusCell"
    case VisitorCell                    = "VisitorCell"
    case LikedMeCell                    = "LikedMeCell"
    case CrushReceivedCell              = "CrushReceivedCell"
    case SkippedProfilesCell            = "SkippedProfilesCell"
    case MyQuestionsCell                = "MyQuestionsCell"
    case AnalyzeProfileTableViewCell    = "AnalyzeProfileTableViewCell"
    case FindTagsTableViewCell          = "FindTagsTableViewCell"
}

enum ShowExpiringType : String{
    case Visitor                   = "VisitorCell"
    case LikedMe                   = "LikedMeCell"
    case SkippedProfiles           = "SkippedProfilesCell"
    case None                      = "None"
}


class AboutMeViewController: BaseClassViewController, UITableViewDelegate, UITableViewDataSource {
    
    let wooMessagesViewHeightConstraint:CGFloat = isIphoneSE() ? 300:200
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var topTableContraint: NSLayoutConstraint!
    var tipsMessageView:WooMessagesView?
    
    var menuModelArray: [NSDictionary] = [["title":NSLocalizedString("View my profile", comment: ""),
                                           "image":"ic_me_avatar_small.png", "cellType": MeSectionCellType.MyProfileCell.rawValue],
                                          ["title":"", "image":"ic_me_boost.png","cellType": MeSectionCellType.BoostWooPlusCell.rawValue],
                                          ["title":NSLocalizedString("Visitors", comment: ""), "image":"ic_me_liked_me.png", "count":String(MeDashboard.getTotalNumberOfUnvisitedVisitor()),"showThickDivider":false,"cellType": MeSectionCellType.VisitorCell.rawValue,"showLoader": BoostAPIClass.getIsfetchingVisitorDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection],
                                          
                                          ["title":NSLocalizedString("Crush Received", comment: ""), "image":"ic_me_crush.png", "count":String(CrushesDashboard.getTotalUnreadCrushes()),"showThickDivider":false,"cellType": MeSectionCellType.CrushReceivedCell.rawValue,"showLoader": CrushAPIClass.getIsfetchingCrushDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInCrushSection],["title":NSLocalizedString("Liked Me", comment: ""), "image":"ic_me_likedByMe.png", "count":String(LikedByMe.getTotalNumberOfUnvisitedLikedByMe()), "showThickDivider":false,"cellType": MeSectionCellType.LikedMeCell.rawValue,"showLoader": LikedByMeAPIClass.getIsfetchingLikedByMeDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance()?.isNewDataPresentInLikedByMeSection as Any],
                                          ["title":NSLocalizedString("Skipped Profiles", comment: ""), "image":"ic_me_skipped_profiles.png", "count":String(SkippedProfiles.getTotalNumberOfUnvisitedSkippedProfiles()),"showThickDivider":true,"cellType": MeSectionCellType.SkippedProfilesCell.rawValue,"showLoader": SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInSkippedSection]]
    
    
    
    var showBoostCell = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.me, animated: false)
        self.navBar?.setTitleText(NSLocalizedString("Me", comment: ""))
        self.navigationController?.isNavigationBarHidden = true;
        
        WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.didChange.addHandler(self, handler: AboutMeViewController.didTabViewChanged)
    }
    
    
    @objc func setDataOnMeSection() {
        print(BoostModel.sharedInstance().availableBoost)
        print(CrushesDashboard.getTotalUnreadCrushes())
        var visitorCountString = ""
        if MeDashboard.getTotalNumberOfUnvisitedVisitor() < 100 {
            visitorCountString = String(MeDashboard.getTotalNumberOfUnvisitedVisitor())
            
        }
        else{
            visitorCountString = "99+"
        }
        
        var likedMeCountString = ""
        if LikedByMe.getTotalNumberOfUnvisitedLikedByMe() < 100 {
            likedMeCountString = String(LikedByMe.getTotalNumberOfUnvisitedLikedByMe())
        }
        else{
            likedMeCountString = "99+"
        }
        
        var crushCountString = ""
        if CrushesDashboard.getTotalUnreadCrushes() < 100 {
            crushCountString = String(CrushesDashboard.getTotalUnreadCrushes())
        }
        else{
            crushCountString = "99+"
        }
        
        var questionCountString = ""
        if MyQuestions.getTotalUnreadAnswersCount() < 100 {
            questionCountString = String(MyQuestions.getTotalUnreadAnswersCount())
        }
        else{
            questionCountString = "99+"
        }
        
        var skippedProfileCountString = ""
        if  SkippedProfiles.getTotalNumberOfUnvisitedSkippedProfiles() < 100 {
            skippedProfileCountString = String(SkippedProfiles.getTotalNumberOfUnvisitedSkippedProfiles())
        }
        else{
            skippedProfileCountString = "99+"
        }
        
        if WooPlusModel.sharedInstance().isExpired == false && DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE"{
            if MeDashboard.getTotalNumberOfVisitors() < 100 {
                visitorCountString = String(MeDashboard.getTotalNumberOfVisitors())
                
            }
            else{
                visitorCountString = "99+"
            }
            
            if LikedByMe.getTotalNumberOfSkippedProfiled() < 100 {
                likedMeCountString = String(LikedByMe.getTotalNumberOfSkippedProfiled())
            }
            else{
                likedMeCountString = "99+"
            }
            
            if  SkippedProfiles.getTotalNumberOfSkippedProfiled() < 100 {
                skippedProfileCountString = String(SkippedProfiles.getTotalNumberOfSkippedProfiled())
            }
            else{
                skippedProfileCountString = "99+"
            }
        }

        
        let defaults = UserDefaults.standard
        let gender = defaults.object(forKey: kWooUserGender) as! String?
        
    
        if (Utilities().isGenderMale(gender) == true ) {
            // male user
            var completenessScore = 0
            if let score = DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore{
                completenessScore = Int(score)!
            }
            if  completenessScore > AppLaunchModel.sharedInstance().profileCompletenessScoreThreshold || WooPlusModel.sharedInstance().isExpired == true{
                
                var showExpiringType:ShowExpiringType = .None
                if LikedByMe.getAllExpiringLikedByMe().count > 0{
                    showExpiringType = .LikedMe
                }
                else if MeDashboard.getAllExpiringVisitors().count > 0{
                    showExpiringType = .Visitor
                }
                else if SkippedProfiles.getAllExpiringSKippedProfiles().count > 0{
                    showExpiringType = .SkippedProfiles
                }
                
                
                menuModelArray = [["title":NSLocalizedString("View my profile", comment: ""), "image":"ic_me_avatar_small.png","cellType": MeSectionCellType.MyProfileCell.rawValue],
                                  ["title":"", "image":"ic_me_boost.png","cellType": MeSectionCellType.BoostWooPlusCell.rawValue],
                                  ["title":NSLocalizedString("Visitors", comment: ""), "image":"ic_me_liked_me.png", "count":visitorCountString,"showThickDivider":false,"cellType": MeSectionCellType.VisitorCell.rawValue,"showLoader": BoostAPIClass.getIsfetchingVisitorDataFromServerValue(),"showCounterAsUnread": true, "showExpiring":showExpiringType],
                                  ["title":NSLocalizedString("Crush Received", comment: ""), "image":"ic_me_crush.png", "count":crushCountString,"showThickDivider":false,"cellType": MeSectionCellType.CrushReceivedCell.rawValue,"showLoader": CrushAPIClass.getIsfetchingCrushDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInCrushSection],
                                  ["title":NSLocalizedString("Liked Me", comment: ""), "image":"ic_me_likedByMe.png", "count":likedMeCountString,"showThickDivider":false,"cellType": MeSectionCellType.LikedMeCell.rawValue,"showLoader": LikedByMeAPIClass.getIsfetchingLikedByMeDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance()?.isNewDataPresentInLikedByMeSection],
                                  ["title":NSLocalizedString("Skipped Profiles", comment: ""), "image":"ic_me_skipped_profiles.png", "count":skippedProfileCountString,"showThickDivider":true,"cellType": MeSectionCellType.SkippedProfilesCell.rawValue,"showLoader": SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue(),"showCounterAsUnread": true, "showExpiring":showExpiringType]]
            }
            else{
                menuModelArray = [["title":NSLocalizedString("View my profile", comment: ""), "image":"ic_me_avatar_small.png","cellType": MeSectionCellType.MyProfileCell.rawValue],
                                  ["title":"", "image":"ic_me_boost.png","cellType": MeSectionCellType.BoostWooPlusCell.rawValue],["title":"", "image":"","cellType": MeSectionCellType.AnalyzeProfileTableViewCell.rawValue],
                                  ["title":NSLocalizedString("Visitors", comment: ""), "image":"ic_me_liked_me.png", "count":visitorCountString,"showThickDivider":false,"cellType": MeSectionCellType.VisitorCell.rawValue,"showLoader": BoostAPIClass.getIsfetchingVisitorDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection],
                                                                    ["title":NSLocalizedString("Crush Received", comment: ""), "image":"ic_me_crush.png", "count":crushCountString,"showThickDivider":false,"cellType": MeSectionCellType.CrushReceivedCell.rawValue,"showLoader": CrushAPIClass.getIsfetchingCrushDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInCrushSection],
                                                                    ["title":NSLocalizedString("Liked Me", comment: ""), "image":"ic_me_likedByMe.png", "count":likedMeCountString,"showThickDivider":false,"cellType": MeSectionCellType.LikedMeCell.rawValue,"showLoader": LikedByMeAPIClass .getIsfetchingLikedByMeDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInLikedByMeSection],

                                  ["title":NSLocalizedString("Skipped Profiles", comment: ""), "image":"ic_me_skipped_profiles.png", "count":skippedProfileCountString,"showThickDivider":true,"cellType": MeSectionCellType.SkippedProfilesCell.rawValue,"showLoader": SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInSkippedSection]]
            }
        }
        else
        {
            //female user
            var completenessScore = 0
            if let score = DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore{
                completenessScore = Int(score)!
            }
            if completenessScore > AppLaunchModel.sharedInstance().profileCompletenessScoreThreshold{
                menuModelArray = [["title":NSLocalizedString("View my profile", comment: ""), "image":"ic_me_avatar_small.png","cellType": MeSectionCellType.MyProfileCell.rawValue],["title":NSLocalizedString("Find with #Tags", comment: ""), "image":"findTagsImage.png","showThickDivider":false,"cellType": MeSectionCellType.FindTagsTableViewCell.rawValue],
                                                      ["title":NSLocalizedString("Visitors", comment: ""), "image":"ic_me_liked_me.png", "count":visitorCountString,"showThickDivider":true,"cellType": MeSectionCellType.VisitorCell.rawValue,"showLoader": BoostAPIClass.getIsfetchingVisitorDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection],
                                  ["title":NSLocalizedString("Crush Received", comment: ""), "image":"ic_me_crush.png", "count":crushCountString,"showThickDivider":false,"cellType": MeSectionCellType.CrushReceivedCell.rawValue,"showLoader": CrushAPIClass.getIsfetchingCrushDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInCrushSection],
                                  ["title":NSLocalizedString("Liked Me", comment: ""), "image":"ic_me_likedByMe.png", "count":likedMeCountString,"showThickDivider":false,"cellType": MeSectionCellType.LikedMeCell.rawValue,"showLoader": LikedByMeAPIClass.getIsfetchingLikedByMeDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInLikedByMeSection],

                                  ["title":NSLocalizedString("Skipped Profiles", comment: ""), "image":"ic_me_skipped_profiles.png", "count":skippedProfileCountString,"showThickDivider":false,"cellType": MeSectionCellType.SkippedProfilesCell.rawValue,"showLoader": SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInSkippedSection]
                ]
            }
            else{
                menuModelArray = [["title":NSLocalizedString("View my profile", comment: ""), "image":"ic_me_avatar_small.png","cellType": MeSectionCellType.MyProfileCell.rawValue],["title":"", "image":"","cellType": MeSectionCellType.AnalyzeProfileTableViewCell.rawValue],["title":NSLocalizedString("Find with #Tags", comment: ""), "image":"findTagsImage.png","showThickDivider":false,"cellType": MeSectionCellType.FindTagsTableViewCell.rawValue],
                                  
                                                      ["title":NSLocalizedString("Visitors", comment: ""), "image":"ic_me_liked_me.png", "count":visitorCountString,"showThickDivider":true,"cellType": MeSectionCellType.VisitorCell.rawValue,"showLoader": BoostAPIClass.getIsfetchingVisitorDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInVisitorSection],
                                  ["title":NSLocalizedString("Crush Received", comment: ""), "image":"ic_me_crush.png", "count":crushCountString,"showThickDivider":false,"cellType": MeSectionCellType.CrushReceivedCell.rawValue,"showLoader": CrushAPIClass.getIsfetchingCrushDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInCrushSection],
                                  ["title":NSLocalizedString("Liked Me", comment: ""), "image":"ic_me_likedByMe.png", "count":likedMeCountString,"showThickDivider":false,"cellType": MeSectionCellType.LikedMeCell.rawValue,"showLoader": LikedByMeAPIClass.getIsfetchingLikedByMeDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInLikedByMeSection],

                                  ["title":NSLocalizedString("Skipped Profiles", comment: ""), "image":"ic_me_skipped_profiles.png", "count":skippedProfileCountString,"showThickDivider":false,"cellType": MeSectionCellType.SkippedProfilesCell.rawValue,"showLoader": SkippedProfileAPIClass.getIsfetchingSkippedDataFromServerValue(),"showCounterAsUnread": AppLaunchModel.sharedInstance().isNewDataPresentInSkippedSection]
                ]
            }
        }
        
        
        
        DispatchQueue.main.async{
            self.menuTable.reloadData()
        }

        AppLaunchModel.sharedInstance().numberOfTimesAboutMeLaunched += 1
        if AppLaunchModel.sharedInstance().numberOfTimesAboutMeLaunched > 10 {
            AppLaunchModel.sharedInstance().numberOfTimesAboutMeLaunched = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tipsMessageView = WooMessagesView.loadViewFromNib(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: wooMessagesViewHeightConstraint))
        menuTable.tableFooterView = tipsMessageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 0{
            colorTheStatusBar(withColor: NavBarStyle.me.color())
            //WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
        }
        
        self.navigationController?.delegate = self
        //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MS_Landing")
        if let tipsView = tipsMessageView{
            tipsView.updateIndexOfTipsCollectionView(DiscoverProfileCollection.sharedInstance.wooTipsCurrenScreenIndex)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDataOnMeSection), name: NSNotification.Name(rawValue: "AnswersAddedNotification"), object: nil)

        self.navigationController?.isNavigationBarHidden = true;
        if WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 0{
            self.setDataOnMeSection()
        }
        
        if UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
            WooScreenManager.sharedInstance.oHomeViewController?.showTabBar(true)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(setDataOnMeSection), name: NSNotification.Name(rawValue: "refreshMeSection"), object: nil)
        WooScreenManager.sharedInstance.oHomeViewController?.checkAndshowUnreadBadgeOnAboutMeIcon()
        NSLog("AboutMeViewController viewWillAppear")

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get()) ?? 0] as? UINavigationController
        if (currentNavigation?.viewControllers.count)! < 2{
            if currentNavigation?.viewControllers.first is AboutMeViewController{
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshMeSection"), object: nil)

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row >= menuModelArray.count{
        let cell: UITableViewCell = UITableViewCell()
            return cell
        }
        let cellDictionary = menuModelArray[(indexPath as NSIndexPath).row]
        let selectedCellType : MeSectionCellType = MeSectionCellType(rawValue: cellDictionary["cellType"] as! String)!
        
        
        switch selectedCellType {
            
            case MeSectionCellType.MyProfileCell:
                let cellIdentifier = "MyProfileCell"
                let cellObj: MyProfileCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyProfileCell)!
                cellObj?.setMyProfileCellDetail(cellDetail: cellDictionary)
                return cellObj!
            
        case MeSectionCellType.AnalyzeProfileTableViewCell:
            let cellIdentifier = "AnalyzeProfileTableViewCell"
            let cellObj: AnalyzeProfileTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AnalyzeProfileTableViewCell)!
            return cellObj!
            
            case MeSectionCellType.BoostWooPlusCell:
                let cellIdentifier = "BoostCell"
                let cellObj: BoostCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BoostCell)!
                cellObj?.setBoostCellDetail(cellDetail: cellDictionary)
                cellObj?.getBoostHandler = {(sender: AnyObject, currentSellingViewValue: Int) in
                    
                    if !(Utilities.sharedUtility() as AnyObject).reachable() {
                        showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                        return
                    }
                    
                    if currentSellingViewValue == 0 {
                        let window:UIWindow = UIApplication.shared.keyWindow!
                        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                        purchaseObj.initiatedView = "Mesection_boostad"
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Mesection_boostad")
                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
                        purchaseObj.purchasedHandler = {(productPurchased:Bool) in
                            if (productPurchased)
                            {
                                DispatchQueue.main.async {

                                    tableView.reloadData()
                                }
                            }
                        }
                        purchaseObj.purchaseDismissedHandler = { (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: window.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                            dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                                DispatchQueue.main.async {
                                    if (purchased == true) {
                                        
                                        tableView.reloadData()
                                        
                                    }
                                }
                                
                            }
                            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                            
                        }
                        

                    }
                    else if currentSellingViewValue == 1{
                        let window:UIWindow = UIApplication.shared.keyWindow!
                        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                        
                        purchaseObj.purchaseDismissedHandler = { (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: window.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                            dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                                DispatchQueue.main.async {
                                    if (purchased == true) {
                                        tableView.reloadData()
                                        
                                    }
                                }
                            }
                            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                            
                        }

                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                    }
                    else if currentSellingViewValue == 4{
                        let window:UIWindow = UIApplication.shared.keyWindow!
                        let purchaseObj:FreeTrailNormalFlow = Bundle.main.loadNibNamed("FreeTrailNormalFlow", owner: window.rootViewController, options: nil)?.first as! FreeTrailNormalFlow
                        purchaseObj.initiatedView = "FreeTrail_getwooplus"
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "FreeTrail_getwooplus")
                        
                        purchaseObj.loadPopupOnWindowForFreeTrail()
                        
                        purchaseObj.purchasedHandlerFreeTrail = {(purchased:Bool) in
                            if(purchased){
                                AppLaunchModel.sharedInstance()!.isChatEnabled = true
                            FreeTrailModel.sharedInstance().resetModel()
                                DispatchQueue.main.async {
                                       tableView.reloadData()
                               }
                            }
                        }
                        
                    }
                    else{
                        let window:UIWindow = UIApplication.shared.keyWindow!
                        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                        
                        purchaseObj.purchaseShownOnViewController = self
                        purchaseObj.initiatedView = "Mesection_wpad_cta"
                        purchaseObj.purchaseDismissedHandler = { (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                            let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: window.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                            dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                                DispatchQueue.main.async {
                                    if (purchased == true) {
                                        tableView.reloadData()
                                        
                                    }
                                }
                            }
                            dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                            
                        }

                        purchaseObj.purchasedHandler = {(purchased:Bool) in
                            DispatchQueue.main.async {
                                
                                if (purchased == true) {
                                    tableView.reloadData()
                                    
                                }
                            }
                        }
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Mesection_wpad_cta")
                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                    }
                }
                return cellObj!
                
            default:
                let cellIdentifier = "MenuCell"
                let cellObj: MenuCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MenuCell)!
                cellObj?.setCellDetail(cellDetail: cellDictionary)
                return cellObj!
        }
        
//        if (indexPath as NSIndexPath).row == 0 {
//            //profile cell 
//            let cellIdentifier = "MyProfileCell"
//            let cellObj: MyProfileCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyProfileCell)!
//            cellObj?.setMyProfileCellDetail(cellDetail: cellDictionary)
//            return cellObj!
//            
//        }
//        else if (((indexPath as NSIndexPath).row == 1) && showBoostCell){
//                let cellIdentifier = "BoostCell"
//                let cellObj: BoostCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BoostCell)!
//                cellObj?.setBoostCellDetail(cellDetail: cellDictionary)
//                cellObj?.getBoostHandler = {(sender: AnyObject, currentSellingViewValue: Int) in
//                    
//                    if !(Utilities.sharedUtility() as AnyObject).reachable() {
//                        showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
//                        return
//                    }
//
//                    if currentSellingViewValue == 0 {
//                        let window:UIWindow = UIApplication.shared.keyWindow!
//                        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
//                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
//                    }
//                    else if currentSellingViewValue == 1{
//                        let window:UIWindow = UIApplication.shared.keyWindow!
//                        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
//                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
//                    }
//                    else{
//                        let window:UIWindow = UIApplication.shared.keyWindow!
//                        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
//                        purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
//                    }
//                }
//                return cellObj!
//        }
//        else{
//            let cellIdentifier = "MenuCell"
//            let cellObj: MenuCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MenuCell)!
//            cellObj?.setCellDetail(cellDetail: cellDictionary)
//            return cellObj!
//        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row >= menuModelArray.count{
            return 44.0
        }
        let selectedRowData = menuModelArray[indexPath.row]
        let selectedCellType : MeSectionCellType = MeSectionCellType(rawValue: selectedRowData["cellType"] as! String)!
        
        var heightOfCell: CGFloat = 0.0
        
        switch selectedCellType {
            case MeSectionCellType.MyProfileCell:
                heightOfCell =  106.0
                break
            case MeSectionCellType.BoostWooPlusCell:
                heightOfCell =  76.0 + 8.0
                break
        case MeSectionCellType.AnalyzeProfileTableViewCell:
            heightOfCell =  60.0
            break
            default:
                let cellDictionary = menuModelArray[(indexPath as NSIndexPath).row]
                if let showThickDivider = cellDictionary["showThickDivider"]{
                if (showThickDivider as! Bool) == true {
                    heightOfCell =  62.0
                }
                }
                heightOfCell =  56.0
        }
        
        return heightOfCell
        
//        if (indexPath as NSIndexPath).row == 0 {
//            return 106.0
//        }
//        else if (((indexPath as NSIndexPath).row == 1) && showBoostCell){
//                return 76.0 + 8.0
//        }
//        else{
//            let cellDictionary = menuModelArray[(indexPath as NSIndexPath).row]
//            let showThickDivider = cellDictionary["showThickDivider"] as! Bool
//            if showThickDivider {
//                return 62.0
//            }
//            return 56.0
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        let selectedRowData = menuModelArray[indexPath.row]
//        let selectedCellType = selectedRowData["cellType"]
        let selectedCellType : MeSectionCellType = MeSectionCellType(rawValue: selectedRowData["cellType"] as! String)!
        
        switch selectedCellType {
            case MeSectionCellType.MyProfileCell:
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
                //WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                self.performSegue(withIdentifier: "aboutMeToProfileDetail", sender: nil)
                break
            case MeSectionCellType.AnalyzeProfileTableViewCell:            WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.AnalyzeProfile)
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MeSection_Analyze_Tap")
                break
            case MeSectionCellType.BoostWooPlusCell:

                break
            case MeSectionCellType.VisitorCell:
                //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_Visitors_Tap")
                self.performSegue(withIdentifier: kPushToVisitorViewController, sender: nil)
                break
            case MeSectionCellType.LikedMeCell:
                //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_LikedMe_Tap")
                self.performSegue(withIdentifier: kPushToLikedMeViewController, sender: nil)
                break
            case MeSectionCellType.CrushReceivedCell:
                //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_Crush_Tap")
                self.performSegue(withIdentifier: kPushToCrushViewController, sender: nil)
                break
            case MeSectionCellType.SkippedProfilesCell:
                //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_SkippedProfiles_Tap")
                self.performSegue(withIdentifier: kPresentSkippedProfile, sender: nil)
                break
            case MeSectionCellType.MyQuestionsCell:
               self.performSegue(withIdentifier: kPushToMyQuestionsController, sender: nil)
                break
        case .FindTagsTableViewCell:
            let newTagSearchVc : NewTagSearchViewController = NewTagSearchViewController(nibName: "NewTagSearchViewController", bundle: Bundle.main)
            WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
            self.navigationController?.pushViewController(newTagSearchVc, animated: true)
            break
        }
        
        
        

//        if (indexPath as NSIndexPath).row == 0 {
//            //my profile
//            
//            DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
//            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
//        }
//        else if (((indexPath as NSIndexPath).row == 1) && showBoostCell){
//            //
//        }//
//        else{
//            if (indexPath as NSIndexPath).row == 2 {
//                
////                WooScreenManager.sharedInstance.drawerController?.performSegueWithIdentifier(kPushToVisitorViewController, sender: nil)
//                
//                // Srwve Event
//                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_Visitors_Tap")
//
//                
//                
//                self.performSegue(withIdentifier: kPushToVisitorViewController, sender: nil)
//            }
//            else if (indexPath as NSIndexPath).row == 3{
//                
//                
//                // Srwve Event
//                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_LikedMe_Tap")
//
//                
//                WooScreenManager.sharedInstance.drawerController?.performSegue(withIdentifier: kPushToLikedMeViewController, sender: nil)
//            }
//            else if (indexPath as NSIndexPath).row == 4{
//                
//                // Srwve Event
//                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_Crush_Tap")
//                
//                
//                WooScreenManager.sharedInstance.drawerController?.performSegue(withIdentifier: kPushToCrushViewController, sender: nil)
//            }
//            else if (indexPath as NSIndexPath).row == 5{
//                
//                // Srwve Event
//                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_SkippedProfiles_Tap")
//                
//                self.performSegue(withIdentifier: kPresentSkippedProfile, sender: nil)
////                WooScreenManager.sharedInstance.drawerController?.performSegueWithIdentifier(kPushToCrushViewController, sender: nil)
//            }
//            else if (indexPath as NSIndexPath).row == 6{
//                
//                WooScreenManager.sharedInstance.drawerController?.performSegue(withIdentifier: kPushToMyQuestionsController, sender: nil)
//            }
//        }
        
//        WooScreenManager
//        WooScreenManager.sharedInstance.oHomeViewController?.checkAndShowUnreadBadgeOnMatchIcon()
        WooScreenManager.sharedInstance.oHomeViewController?.checkAndshowUnreadBadgeOnAboutMeIcon()
        WooScreenManager.sharedInstance.oHomeViewController?.checkIfBoostActive()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if(segue.identifier == "aboutMeToProfileDetail"){
            let detailViewControllerObject = segue.destination as! ProfileDeckDetailViewController
            if DiscoverProfileCollection.sharedInstance.myProfileData != nil{
                detailViewControllerObject.profileData = DiscoverProfileCollection.sharedInstance.myProfileData
            }
            detailViewControllerObject.isMyProfile = true
            detailViewControllerObject.detailProfileParentTypeOfView = DetailProfileViewParent.discover
        }
    }
    
    //MARK: HomeTab bar changed handler
    func didTabViewChanged(_ tupleValue:(oldValue: Int, newValue: Int)) {
        if tupleValue.newValue == 0 {
            print("I am in AboutMeViewController")
            viewWillAppear(false)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AnswersAddedNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(setDataOnMeSection), name: NSNotification.Name(rawValue: "AnswersAddedNotification"), object: nil)
            
//            for ethItem in (DiscoverProfileCollection.sharedInstance.myProfileData?.ethnicity)! {
//                ethItem.isSelected = false
//            }
            
        }        
    }
}

extension AboutMeViewController : UINavigationControllerDelegate
{

    internal func navigationController(_ navigationController: UINavigationController,
                          animationControllerFor operation: UINavigationController.Operation,
                          from fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
{
    if operation == UINavigationController.Operation.push && (fromVC is TagSearchViewController) &&  (toVC is ProfileDeckDetailViewController)
        {
            return ProfilePresentAnimator(originFrame:self.view.frame)
        }
    if operation == UINavigationController.Operation.pop && (toVC is TagSearchViewController) && (fromVC is ProfileDeckDetailViewController)
        {
            return ProfilePopAnimator(originFrame:self.view.frame)
        }
        return nil
    }

}
