//
//  ExpiryProfilesViewController.swift
//  Woo_v2
//
//  Created by Ankit Batra on 25/10/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ExpiryProfilesViewController: BaseClassViewController {

    @IBOutlet weak var expiryProfilesCollectionView: UICollectionView!
    var parentViewType : MeDataType = .Visitors
    var expiryProfilesArray = NSMutableArray()
    var viewExpiryProfilesArray: [String] = []

    var leftMargin: CGFloat = 20.0
    var spaceBetweenCells = 50.0
    var cellWidth: CGFloat = 100.0
    var cellHeight: CGFloat = 100.0
    var indexPathToDelete:IndexPath?
    var needToOpenCrushSendViewInProfileDetail = false
    var deleteGoingOn = false
    var isUserAlreadyPresent = false
    let profileAction:ProfileActionManager = ProfileActionManager()
    var crushText:String = ""
    var currentSectionUserDetail:AnyObject?
    var comingFromProfile:Bool = false
    var currentUserDetail:AnyObject?
    var isPaidUser = false
    var reloadExpiryViewInParent = false

    var dismissViewControllerHandler:((Bool)->Void)!

    
    var actionButtonType: ACTION_BUTTON_TAPPED_TYPE = .none
    var sellingMsgEnum: GoToScreenType_LikeMe  = .none
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar!.setStyle(NavBarStyle.me, animated: false)
        self.navigationController?.navigationBar.isHidden = true
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(ExpiryProfilesViewController.backButton))
        
        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set expiryProfilesArray
      
        
        switch parentViewType {
        case .Visitors:
            self.navBar?.setTitleText("Expiring Likes & Visits")
            expiryProfilesArray = updateExpiryArrayForExpiredData(MeDashboard.getAllExpiringVisitors() as NSArray, type: parentViewType)
            break
        case .LikedMe:
            self.navBar?.setTitleText("Expiring Liked Profiles")
            expiryProfilesArray = NSMutableArray(array:LikedByMe.getAllExpiringLikedByMe())
            expiryProfilesArray = updateExpiryArrayForExpiredData(LikedByMe.getAllExpiringLikedByMe() as NSArray, type: parentViewType)
            break
        case .SkippedProfiles:
            self.navBar?.setTitleText(NSLocalizedString("Expiring Skipped Profiles", comment: "Skipped Profiles"))
            expiryProfilesArray = updateExpiryArrayForExpiredData(SkippedProfiles.getAllExpiringSKippedProfiles() as NSArray, type: parentViewType)
            break
        }
        setMarginAccordingToData()
    }
    
    
    func setMarginAccordingToData() -> Void {
        let widthForCell = SCREEN_WIDTH - 27
        cellWidth = widthForCell/2
        spaceBetweenCells = 20
        cellHeight = cellWidth * 1.7
        leftMargin = 9
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func sendCrush(){
        performActionForType(.CrushSent)
    }
    
    func likeUser(){
        performActionForType(.Like)
    }
    
    func dislikeUser(){
        //new swrve/firebase events added
        performActionForType(.Pass)
        
    }
    
    func reloadViewAfterRemovingData(_ deletedIndexPath:IndexPath) {
        
        if self.expiryProfilesArray.count <= 0 {
            self.backButton()
            return
        }
        
        
        if self.expiryProfilesArray.count > 0 && self.expiryProfilesArray.count > deletedIndexPath.row{
            self.expiryProfilesArray.removeObject(at: deletedIndexPath.row)
        }
        
        if (self.expiryProfilesArray.count == 0){
            self.expiryProfilesCollectionView.deleteSections(IndexSet(integer: deletedIndexPath.section))
        }
        else{
            if let _ = self.expiryProfilesCollectionView.cellForItem(at: deletedIndexPath){
                self.expiryProfilesCollectionView.deleteItems(at: [deletedIndexPath])
                
            }
        }
        self.deleteGoingOn = false
        self.perform(#selector(self.nowEnableCollectionView), with: nil, afterDelay: 0.0)
    }
    
    @objc func nowEnableCollectionView(){
        self.expiryProfilesCollectionView.isUserInteractionEnabled = true
        self.expiryProfilesCollectionView.reloadData()
    }
    
    func performActionForType(_ actionType:PerformAction){
        
        switch parentViewType
        {
        case .Visitors:
            profileAction.currentViewType = .Visitor
            break
        case .LikedMe:
            profileAction.currentViewType = .LikedMe
            break
        case .SkippedProfiles:
            profileAction.currentViewType = .SkippedProfiles
            break
            
        }
        
        if(actionType != .None)
        {
            reloadExpiryViewInParent = true
        }
        
        profileAction.crushText = self.crushText
        //self.expiryProfilesCollectionView.isUserInteractionEnabled = false
        profileAction.indexPathToBeDeleted = self.indexPathToDelete
        
        profileAction.reloadHandler = {(indexPath:IndexPath) in
            self.reloadViewAfterRemovingData(indexPath)
        }
        profileAction.performSegueHandler = { (matchedUserDataFromDb:MyMatches) in
            if (Utilities().isChatRoomPresent(in: self.navigationController) == false){
                if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                }else{
                self.performSegue(withIdentifier: kPushToChatFromExpiryCollectionViewProfile, sender: matchedUserDataFromDb)
                }
            }
        }
        
        switch actionType {
        case .Like:
            if  comingFromProfile == true{
                profileAction.likeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            }
            else{
                switch parentViewType
                {
                case .Visitors:
                    profileAction.likeActionPerformed(.MeDashboard, userObject: currentSectionUserDetail! as AnyObject)
                    break
                case .LikedMe:
                    profileAction.likeActionPerformed(.LikedMe, userObject: currentSectionUserDetail! as AnyObject)
                    break
                case .SkippedProfiles:
                    profileAction.likeActionPerformed(.SkippedProfiles, userObject: currentSectionUserDetail! as AnyObject)
                    break
                }
            }
            break
            
        case .Pass:
            if  comingFromProfile == true{
                profileAction.dislikeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            }
            else{
                switch parentViewType
                {
                case .Visitors:
                    profileAction.dislikeActionPerformed(.MeDashboard, userObject: currentSectionUserDetail! as AnyObject)
                    break
                case .LikedMe:
                    profileAction.dislikeActionPerformed(.LikedMe, userObject: currentSectionUserDetail! as AnyObject)
                    break
                case .SkippedProfiles:
                    profileAction.dislikeActionPerformed(.SkippedProfiles, userObject: currentSectionUserDetail! as AnyObject)
                    break
                }
            }
            break
            
        case .CrushSent:
            if  comingFromProfile == true{
                profileAction.crushActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            }
            else{
                switch parentViewType
                {
                case .Visitors:
                    profileAction.crushActionPerformed(.MeDashboard, userObject: currentSectionUserDetail! as AnyObject)
                    break
                case .LikedMe:
                    profileAction.crushActionPerformed(.LikedMe, userObject: currentSectionUserDetail! as AnyObject)
                    break
                case .SkippedProfiles:
                    profileAction.crushActionPerformed(.SkippedProfiles, userObject: currentSectionUserDetail! as AnyObject)
                    break
                }
            }
            break
            
        default:
            break
        }

    }

    @objc func showCrushOverlayAndUpdateView(){
        if (indexPathToDelete != nil) {
            let cell: MeCollectionViewCell? = expiryProfilesCollectionView.cellForItem(at: indexPathToDelete!) as? MeCollectionViewCell
            cell?.meProfileDeckView?.showOverlayForCrushSent()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kPushFromBundledExpiryToDetailProfileView){
            let model = sender as! ProfileCardModel
            let profileVC = segue.destination as! ProfileDeckDetailViewController
            
            profileVC.profileData = model
            profileVC.isViewPushed = true
            profileVC.isProfileAlreadyLoaded = self.isUserAlreadyPresent
            profileVC.openCrushView = needToOpenCrushSendViewInProfileDetail
            profileVC.detailProfileParentTypeOfView = DetailProfileViewParent.skippedProfile
            profileVC.dismissHandler = { (currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel, onBoardingEditProfileDone:Bool, indexPath:IndexPath) in
                self.crushText = crushString
                self.currentUserDetail = userProfile
                self.comingFromProfile = true

                if needToTakeAction == .Pass {
                    self.reloadViewAfterRemovingData(indexPath)
                }
                if needToTakeAction == .Like{
                    self.likeUser()
                }
                else if needToTakeAction == .CrushSent{
                    self.showCrushOverlayAndUpdateView()
                    self.perform(#selector(self.sendCrush), with: nil, afterDelay: 0.4)
                }
            }
        }
        else if (segue.identifier == kPushToChatFromExpiryCollectionViewProfile) {
//            let chatViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
            let chatViewControllerObj: NewChatViewController  = segue.destination as! NewChatViewController
            let model = sender as! MyMatches
            chatViewControllerObj.myMatchesData = model
            chatViewControllerObj.isAutomaticallyPushedFromChat = true
            chatViewControllerObj.parentView = .skippedProfile
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
    
    fileprivate func showOutOfLikeAlert(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup")
        
        let outOfLikePopup = OutOfLikeView.showView(parentViewController: WooScreenManager.sharedInstance.oHomeViewController!)
        outOfLikePopup.buttonPressHandler = {
            
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
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
            
        }
        
    }
    
    func pushtoDetailView(_ skippedProfile:AnyObject, indexPath:IndexPath){

         self.isUserAlreadyPresent = false
         //Change to specific profile type acc to parent
        
        switch parentViewType
        {
        case .Visitors:
            self.indexPathToDelete = indexPath
            let visitorDetail = expiryProfilesArray.object(at: (indexPath as NSIndexPath).row) as! MeDashboard
          //  self.needToOpenCrushSendViewInProfileDetail = false
            pushtoVisitorDetailView(visitorDetail, indexPath:self.indexPathToDelete!)
            break
        case .LikedMe:
            self.indexPathToDelete = indexPath
            let visitorDetail = expiryProfilesArray.object(at: (indexPath as NSIndexPath).row) as! LikedByMe
           // needToOpenCrushSendViewInProfileDetail = false
            self.pushtoLikedMeDetailView(visitorDetail, indexPath: self.indexPathToDelete!, isMe: false)
            break
        case .SkippedProfiles:
   
            if let visitorDetail:SkippedProfiles = expiryProfilesArray.object(at: indexPath.row) as? SkippedProfiles{
                if visitorDetail.userWooId != nil  {
                    pushToSkippedProfile(visitorDetail, indexPath: indexPath)
                }
                
            }

            break
            
        }
    }
    
    func pushtoLikedMeDetailView(_ likedMe:LikedByMe?, indexPath:IndexPath?, isMe:Bool){
        self.isUserAlreadyPresent = false
       
        LikedMe.updateHasUserProfileVisited(byAppUser: true, forUserWooId: likedMe!.userWooId!, withCompletionHandler:
            {
                (completed) in
                var model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(likedMe!.userWooId!)
                if model.wooId == nil{
                    model = ProfileCardModel.init(model: likedMe!, profileType: .LikedMe)
                    let cell:MeCollectionViewCell?
                    
                        cell = self.expiryProfilesCollectionView.cellForItem(at: indexPath!) as? MeCollectionViewCell
                    
                    if cell?.meProfileDeckView?.profileImageView.image != nil
                    {
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
                    self.performSegue(withIdentifier: kPushFromBundledExpiryToDetailProfileView, sender: model)
                    
                })
                
        })
 
    }
    func pushtoVisitorDetailView(_ visitor:MeDashboard, indexPath:IndexPath){
        self.isUserAlreadyPresent = false
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_Visitors", withEventName: "3-MeSection.Me_Visitors.MV_UserProfile_Tap")
        
        var model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(visitor.visitorId!)
        
        if model.wooId == nil{
            
            model = ProfileCardModel.init(model: visitor, profileType: .MeDashboard)
            
            let cell:MeCollectionViewCell?
                cell = self.expiryProfilesCollectionView.cellForItem(at: indexPath) as? MeCollectionViewCell
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
            self.performSegue(withIdentifier: kPushFromBundledExpiryToDetailProfileView, sender: model)
        })
        
    }
    
    func pushToSkippedProfile(_ skippedProfile:SkippedProfiles, indexPath:IndexPath)
    {
        SkippedProfiles.updateHasUserProfileVisited(byAppUser: true, forUserWooId: skippedProfile.userWooId!, withCompletionHandler: {
        (completed) in
        if skippedProfile.userWooId == (UserDefaults.standard.object(forKey: kWooUserId) as! String) {
        let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true)
        
        }
        else{
        
        var model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(skippedProfile.userWooId!)
        
        if model.wooId == nil{
        model = ProfileCardModel.init(model: skippedProfile, profileType: .SkippedProfiles)
        
        let cell:MeCollectionViewCell?
        cell = self.expiryProfilesCollectionView.cellForItem(at: indexPath) as? MeCollectionViewCell
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
            self.performSegue(withIdentifier: kPushFromBundledExpiryToDetailProfileView, sender: model)
            })
            }
        })
    }
    
    func initiatePurchaseFlow(){
        let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! PurchasePopup
        purchaseObj.purchaseShownOnViewController = self
        purchaseObj.purchasedHandler = {
            (purchaseObj : Bool) in
            
            DispatchQueue.main.async
                {
                    self.isPaidUser = true
                    self.expiryProfilesCollectionView.reloadData()
            }
            
        }
        purchaseObj.purchaseDismissedHandler =
            {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                
                dropOffPurchaseObj.purchasedHandler = {
                    (purchased:Bool) in
                    
                    DispatchQueue.main.async
                        {
                            self.isPaidUser = true
                            self.expiryProfilesCollectionView.reloadData()
                    }
                    
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
        }
        switch parentViewType {
            
        case .Visitors:
            switch actionButtonType {
            case .boost_PURCHASE:
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
                break
                
            case .woo_PLUS_PURCHASE:
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                break
                
            default:
                break
            }
            break
            
        case .LikedMe:
            switch sellingMsgEnum {
                
            case .woo_PLUS_PURCHASE:
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                break
                
            case .boost_PURCHASE:
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
                break
                
            case .crush_PURCHASE:
                purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                break
            default:
                break
            }
            break
            
        case .SkippedProfiles:
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
            break
        }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    @IBAction func backButton()
    {//
        dismissViewControllerHandler(reloadExpiryViewInParent)
        self.navigationController?.popViewController(animated: true)
    }

}

extension ExpiryProfilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expiryProfilesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "MeCollectionViewCell"
        let cell: MeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MeCollectionViewCell)!
        
        var profileDetail = expiryProfilesArray.object(at: (indexPath as NSIndexPath).row) as AnyObject
        
        switch self.parentViewType {
        case .Visitors:
            cell.setUserDetail(userDetail: profileDetail, isBundledProfile:false , forType: parentViewType, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForVisitors, noOfTotalProfiles: expiryProfilesArray.count, isExpired: true, profileIndex: indexPath.row, usedInExpiryProfiles: true)
            break
        case .LikedMe:
            cell.setUserDetail(userDetail: profileDetail, isBundledProfile:false , forType: parentViewType, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForLikedMe, noOfTotalProfiles: expiryProfilesArray.count, isExpired: true, profileIndex: indexPath.row, usedInExpiryProfiles: true)
            break
        case .SkippedProfiles:
            cell.setUserDetail(userDetail: profileDetail, isBundledProfile:false , forType: parentViewType, isPaidUser: isPaidUser, showLock: WooPlusModel.sharedInstance().maskingEnabledForSkippedProfiles, noOfTotalProfiles: expiryProfilesArray.count, isExpired: true, profileIndex: indexPath.row, usedInExpiryProfiles: true)
            break
        }
            
        cell.meProfileDeckView?.dismissHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject) in
            
            let touchPoint = CGPoint(x: cell.center.x, y: cell.center.y)
            
            let tappedIndexPath = collectionView.indexPathForItem(at: touchPoint)
            self.indexPathToDelete = tappedIndexPath
            self.deleteGoingOn = true
            self.needToOpenCrushSendViewInProfileDetail = false
            
            switch self.parentViewType {
            case .Visitors:
                self.currentSectionUserDetail = userProfile as! MeDashboard
                break
            case .LikedMe:
                self.currentSectionUserDetail = userProfile as! LikedByMe
                break
            case .SkippedProfiles:
                self.currentSectionUserDetail = userProfile as! SkippedProfiles
                break
            }
            
            if needToTakeAction == PerformAction.Pass {
                self.dislikeUser()
            }
            else if needToTakeAction == PerformAction.CrushSent{
                WooScreenManager.sharedInstance.oHomeViewController?.crushFunnelMessage = "Expiry_profile_crush_tap"
                self.needToOpenCrushSendViewInProfileDetail = true
                self.pushtoDetailView(self.currentSectionUserDetail!, indexPath: self.indexPathToDelete!)
            }
            else if needToTakeAction == PerformAction.Like{
                if self.checkIfUserWillSeeOutOfLikeAlert() {
                    self.showOutOfLikeAlert()
                }
                else{
                    self.likeUser()
                }
            }
        }
        //Change to specific dashboard type
        switch parentViewType
        {
            case .Visitors:
                profileDetail  = profileDetail as! MeDashboard
                break
            case .LikedMe:
                profileDetail  = profileDetail as! LikedByMe
                break
        case .SkippedProfiles:
                profileDetail  = profileDetail as! SkippedProfiles
                break
            
        }
        if let userWooidValue = profileDetail.userWooId as? String {
            if viewExpiryProfilesArray.contains(userWooidValue) == false{
                viewExpiryProfilesArray.append(userWooidValue)
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 9, left: leftMargin, bottom: 20, right: leftMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return leftMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return leftMargin
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(isPaidUser)
        {
            self.indexPathToDelete = indexPath
            self.needToOpenCrushSendViewInProfileDetail = false
            if Utilities().reachable() == true
            {
                switch parentViewType
                {
                case .Visitors:
                    if let visitorDetail:MeDashboard = expiryProfilesArray.object(at: indexPath.row) as? MeDashboard{
                        if visitorDetail.visitorId != nil  {
                            pushtoDetailView(visitorDetail, indexPath: indexPath)
                        }
                        
                    }
                    break
                case .LikedMe:
                    if let visitorDetail:LikedByMe = expiryProfilesArray.object(at: indexPath.row) as? LikedByMe{
                        if visitorDetail.userWooId != nil  {
                            pushtoDetailView(visitorDetail, indexPath: indexPath)
                        }
                        
                    }
                    break
                    
                case .SkippedProfiles:
                    if let visitorDetail:SkippedProfiles = expiryProfilesArray.object(at: indexPath.row) as? SkippedProfiles{
                        if visitorDetail.userWooId != nil  {
                            pushtoDetailView(visitorDetail, indexPath: indexPath)
                        }
                        
                    }
                    
                    break
                }

            }
            else{
                Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle:"", withDuration: 3.0)
            }
        
        }
        else
        {
            var userTimeStamp = Date()
            let expiredUserDetail = self.expiryProfilesArray[((indexPath as NSIndexPath).row)]
            if self.parentViewType == .LikedMe {
                userTimeStamp = (expiredUserDetail as! LikedByMe).userExpiryTime  ?? Date()
            }
            else if self.parentViewType == .Visitors{
                userTimeStamp = (expiredUserDetail as! MeDashboard).visitorExpiryTime  ?? Date()
            }
            else if self.parentViewType == .SkippedProfiles{
                userTimeStamp = (expiredUserDetail as! SkippedProfiles).userExpiryTime  ?? Date()
            }
            if calculateDaysOfExpiry(userTimeStamp) == 0{
                let alert: UIAlertController = UIAlertController(title: NSLocalizedString("", comment: ""),
                                                                 message: NSLocalizedString("This profile is no longer available.\nGet WooPlus to save other profiles from expiring.", comment:""),
                                                                 preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Expire Profiles", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
                })
                
                let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Get WooPlus", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    
                    self.initiatePurchaseFlow()
                    
                })
                
                alert.addAction(cancelAction)
                alert.addAction(reportAction)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                initiatePurchaseFlow()
            }
                
        }
    }
}
