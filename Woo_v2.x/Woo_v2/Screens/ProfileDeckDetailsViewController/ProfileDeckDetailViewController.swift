//
//  ProfileDeckDetailViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 03/06/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import SnapKit
import IQKeyboardManager
import SDWebImage
//import LayerKit
import PINRemoteImage

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



enum PerformActionBasedOnActivity : String {
    case DoNothing  = "DoNothing"
    case Pass       = "Pass"
    case Like       = "Like"
    case CrushSent  = "CrushSent"
}

enum CellType : String{
    case AboutHeaderCell            = "AboutHeaderCell"
    case FooterCell                 = "FooterCell"
    case LinkedInPhoneCell          = "LinkedInPhoneCell"
    case ActorQuestionTableViewCell = "ActorQuestionTableViewCell"
    case QuestionTableViewCell      = "QuestionTableViewCell"
    case RoundedImageCell           = "RoundedImageCell"
    case TagCell                    = "TagCell"
    case AboutMeCell                = "AboutMeCell"
    case PersonalQouteCell          = "QuotationCell"
    case MyQuestionCell             = "MyQuestionCell"
    case EthnicityCell              = "EthnicityCell"
    case ReportCell                 = "ReportCell"
    case ChatTypeCell               = "ChatTypeCell"
    case ProfileInfoTableViewCell        = "ProfileInfoTableViewCell"
    case QnADPVTableViewCell        = "QnADPVTableViewCell"
}

enum ProfileLabelDataType {
    case personalQoute
    case aboutMe
    case neither
}

class ProfileDeckDetailViewController: UIViewController,UINavigationControllerDelegate {
    /// Tableview for profile details
    @IBOutlet weak var profileSnapShotView: UIView!
    @IBOutlet weak var profileSnapShotImageView: UIImageView!
    @IBOutlet weak var sendCrushButton: UIButton!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var likeButton: WooLikeMeterButton!
    
    @IBOutlet weak var initialProfileDeckViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var initialProfileDeckView: UIView!
    @IBOutlet weak var dataLoaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataLoader: UIActivityIndicatorView!
    @IBOutlet weak var editProfileHeaderButton: UIButton!
    
    @IBOutlet weak var backOrCloseButton: UIButton!
    @IBOutlet weak var locationLabelCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var optionkOrSettingsButton: UIButton!
    
    @IBOutlet weak var profileDetailTableView: UITableView!
    
    @IBOutlet weak var profileDetailHeaderView: UIView!
    
    @IBOutlet weak var actionButtonContainerView: UIView!
    
    @IBOutlet weak var navBarImageView: UIImageView!
    
    @IBOutlet weak var NameAgeLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var heightLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nav_completenessView: UIView!
    @IBOutlet weak var nav_completenessProgressBar: ArcProgressbar!
    @IBOutlet weak var nav_completenessLabel: UILabel!
    
    @IBOutlet weak var navImageHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var navbarTopConstrain: NSLayoutConstraint!
    
    var myMatchesData:MyMatches?
    
    var detailProfileParentTypeOfView: DetailProfileViewParent!
    
    var profileDeckObject:ProfileDeckView?
    
    var initialProfileDeckObject:ProfileDeckView?

    var discoverProfileDeckViewObject:ProfileDeckView?
    
    var tagTrainingPopupOject:TagTrainingPopupView?
    
    var sendCrushViewObject:SendCrushView?
    
    var crushToBeSent:NSString = ""
    
    var dismissHandler:((String, PerformActionBasedOnActivity, String, ProfileCardModel, Bool, IndexPath)->Void)!
    
    var onBoardingEditProfileDone = false
    
    var currentImageHandler:((String)->Void)!
    
    @objc var dismissHandlerObjC:((String, String, ProfileCardModel)->Void)!
    
    @IBOutlet weak var profileDetailTableViewTopConstraint: NSLayoutConstraint!
    fileprivate var matchData :NSDictionary?
    
    var matchOverlayButtonType : OverlayButtonType = .Retun_To_Profile
    
    var needToMakeGallerySmall:Bool = false
    
    var currentShownImageUrl:String?
    
    var discoverSnapShot:UIImage?
    
    /// Profile data model for currently selected profile
    var profileData : ProfileCardModel?
    /// Array needed for creating profile tableview. Datasource for table view
    fileprivate var userdataArray : NSMutableArray = []
    
    var tagHeight : CGFloat = 100.0
    
    var commontagHeight: CGFloat = 100.0
    
    var lastOffSetLocation: CGFloat = 0.0
    
    var moveToCellBasedOnCommonalitySelection:String?
    
    var rowValue:Int = -1
    
    var tableViewWrapperView:UIView?
    
    var tempImageView:UIImageView?
    
    var YConstraintForProfileDeck:CGFloat = 0
    
    var backActivity = PerformActionBasedOnActivity.DoNothing
    
    var lastheightOfProfileDeckMainContainerView:CGFloat = 0
    
    var isViewPushed: Bool = false
    
    let gradientBottom:CAGradientLayer = CAGradientLayer()
    
    var needToOpenEditProfile = false
    
    var isComingFromDiscover: Bool = false
    
    var allowedToMakeProfileSmall: Bool = true
    
    var isMyProfile = false
    
    var currentQuestionData:TargetQuestionModel?
    
    var visitorData:MeDashboard?

    /// this variable flag is used check if user has already liked the profile or not , accordingly update the like-meter
    var isAlreadyLiked = false;
    /// this variable flag is used check if match overlay has been shown before or not
    var isActionButtonHidden = false
    
    var didCameFromChat = false
    
    var isUserReported: Bool = false
    
    var tagTrainingHasBeenShowed: Bool = false
    
    var openCrushView = false
    
    var isProfileAlreadyLoaded = false
    
    @objc var popToChatFromSendMessagebjC:(()->())?

//    var conversation : LYRConversation?
    
    var selectedIndexPath = IndexPath(item: 0, section: 0)
    
    //constants for Profile Deck View
    let qnaQuestionTextWidthConstant:CGFloat = SCREEN_WIDTH - 77.0
    let qnaAnswerTextWidthConstant:CGFloat = SCREEN_WIDTH - 40.0
    let qnaExtraSpacingDifferenceConstant:CGFloat = 55.0

    @IBAction func dismissTagTraningView(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.tagTrainingPopupOject?.alpha = 0
        },completion: {
            (true) in
            if self.tagTrainingPopupOject != nil{
                self.tagTrainingPopupOject?.removeFromSuperview()
                self.tagTrainingPopupOject = nil
            }
        })
        
        
    }
    
    //MARK: ViewController life-cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isMyProfile = DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE ? true : false
        
        if !isMyProfile {
            
            if didCameFromChat{
                optionkOrSettingsButton.setImage(UIImage(named: "ic_dpv_thick_more"), for: UIControl.State())
            }
            else{
                optionkOrSettingsButton.setImage(UIImage(named: "ic_dpv_white_block"), for: UIControl.State())
            }
        }
        
      
        
        if(self.detailProfileParentTypeOfView == DetailProfileViewParent.likedMe){
            self.likeButton.isUserInteractionEnabled = false
            self.likeButton.setImage(UIImage(named: "like3.0_disabled") , for: .normal)
            self.passButton.isUserInteractionEnabled = false
            self.passButton.setImage(UIImage(named: "dislike3.0_disabled"), for: .normal)
        }
        
        if (detailProfileParentTypeOfView == DetailProfileViewParent.skippedProfile) || (detailProfileParentTypeOfView == DetailProfileViewParent.likedMe) || (detailProfileParentTypeOfView == DetailProfileViewParent.visitor) || didCameFromChat == true {
            //self.perform(#selector(self.showDataLoader), with: nil, afterDelay: 0.5)
            if isProfileAlreadyLoaded{
                if(self.didCameFromChat == true)
                {
                    MyMatches.updateMatchedUserDetails(forMatchedUserID: self.profileData?.wooId ?? "", withName: self.profileData?.firstName ?? "", andProfilePic: self.profileData?.wooAlbum?.discoverProfilePicUrl() ?? "") { (success) in
                        if success{
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "matchDataUpdatedInDPV"), object: nil, userInfo: nil)
                        }
                    }
                }
                initialProfileDeckView.isHidden = true
                if profileDeckObject == nil{
                    self.addProfileNow()
                }
                dataLoader.isHidden = true
                prepareCellDataFromProfile()
                profileDetailTableView.reloadData()
                self.perform(#selector(scrollToAParticularPosition), with: nil, afterDelay: 0.5)
                self.perform(#selector(configureNavImage), with: nil, afterDelay: 0.8)
                if isMyProfile{
                    if let imageUrlString = profileData?.wooAlbum?.profilePicUrl() {
                        self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                    }
                }
                else{
                    if let imageUrlString = profileData?.wooAlbum?.discoverProfilePicUrl() {
                        self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                    }
                }
            }
            else{
                initialProfileDeckView.isHidden = false
                addInitialProfileNow()
                showDataLoader()
                getProfileData()
            }
        }
        else{
            initialProfileDeckView.isHidden = true
            if profileDeckObject == nil{
                self.addProfileNow()
            }
            dataLoader.isHidden = true
            prepareCellDataFromProfile()
            profileDetailTableView.reloadData()
            self.perform(#selector(scrollToAParticularPosition), with: nil, afterDelay: 0.5)
            self.perform(#selector(configureNavImage), with: nil, afterDelay: 0.8)
            if isMyProfile{
                if let imageUrlString = profileData?.wooAlbum?.profilePicUrl() {
                    
                self.navBarImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: nil, options: SDWebImageOptions(), completed: { (imageObj, error, cacheType, imageUrl) in

                    if(self.navBarImageView.image != nil){
                        
                        if let inputImage = CIImage(image: self.navBarImageView.image!){
                                               
                           let parameters = [
                               "inputContrast": NSNumber(value: 1.00)
                            ]
                            let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)

                            let context = CIContext(options: nil)
                            let img = context.createCGImage(outputImage, from: outputImage.extent)!

                           self.navBarImageView.image = UIImage(cgImage: img)
                       }
                    }
                         
                    })
                }
            }
            else{
                if let imageUrlString = profileData?.wooAlbum?.discoverProfilePicUrl() {
                    self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                }
            }
        }
        
    }
    
    func dismissScreen()
    {
       nowMoveBackToDiscover()
    }
    
    @objc func dismissView() {
        NSLog("\n\n\n>Umesh123<dismiss karne aaya hia Profile view ko\n\n\n", "");
        closeDetailViewController(backOrCloseButton)
    }
    func dismissViewAfterSomeTime(){
        self.perform(#selector(dismissView), with: nil, afterDelay: 0.3)
//        self.dismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkForLikeLimit()
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
    }
    
    func setParentvalueforCrush(){
        detailProfileParentTypeOfView = DetailProfileViewParent.crush
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                profileDetailTableViewTopConstraint.constant = 0
            }
        }
        else{
            if didCameFromChat {
                if SCREEN_WIDTH != 414 {
                    self.navbarTopConstrain.constant = 0.0
                    profileDetailHeaderView.layoutIfNeeded()
                }
            }
        }
        
        if self.detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch{
            isMyProfile = false
            //SwipeBack
            
            if let nav = self.navigationController{
                nav.swipeBackEnabled = false
            }
            
        }
        else if self.detailProfileParentTypeOfView == DetailProfileViewParent.discover{
            //SwipeBack
            
            if let nav = self.navigationController{
                if isMyProfile{
                    nav.swipeBackEnabled = true
                }
                else{
                    nav.swipeBackEnabled = false
                }
            }
            
        }
        else if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE{
            isMyProfile = true
        }
        else{
            //SwipeBack
            
            if let nav = self.navigationController{
                nav.swipeBackEnabled = true
            }
            
        }
        
        if UIScreen.main.bounds.size.height >= 736 {
            YConstraintForProfileDeck = 85
        }
        else{
            YConstraintForProfileDeck = 85
        }

//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dismissScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDismissPresentedViewController), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dismissViewAfterSomeTime), name: NSNotification.Name(rawValue: kDismissPresentedViewController), object: nil)
//
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRemoveViewWithKeyboard), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dismissViewAfterSomeTime), name: NSNotification.Name(rawValue: kRemoveViewWithKeyboard), object: nil)
        if isMyProfile == true {
            self.profileData = DiscoverProfileCollection.sharedInstance.myProfileData
        }

        if self.isViewPushed {
            self.view.backgroundColor = UIColor.white
        }

        self.profileDetailTableView.canCancelContentTouches = false
        
        self.backOrCloseButton.isSelected = false
        
        // preparing data before reloading table
        
        self.navigationController?.navigationBar.isHidden = true
        
        //tableViewWrapperView = profileDetailTableView.subviews[1]
        //tableViewWrapperView!.alpha = 0
        
        if needToOpenEditProfile {
            self.perform(#selector(openEditProfile), with: nil, afterDelay: 0.1)
            needToOpenEditProfile = false
        }
        
        
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            actionButtonContainerView.isHidden = false
        }
        else{
            if isMyProfile || isActionButtonHidden{
                actionButtonContainerView.isHidden = true
            }
            else{
                if rowValue>0 {
                    actionButtonContainerView.isHidden = true
                }
                else{
                    actionButtonContainerView.isHidden = false
                }
            }
        }
        
        if openCrushView == true{
            self.perform(#selector(sendCrush(_:)), with: nil, afterDelay: 0.2)
        }
        
        //UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        colorTheStatusBar(withColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismissTagTraningView(Any.self)
        
        /*
        if SYSTEM_VERSION_LESS_THAN(version: "9") || SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "10"){
            if detailProfileParentTypeOfView == DetailProfileViewParent.discover{
                if isMyProfile == false{
                profileDeckObject?.removeFromSuperview()
                profileDeckObject = nil
                }
            }
        }
        */
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)

        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if (segue.identifier == "ProfileDeckToWriteAnswerSegue") {
            let writeAnswerViewController = segue.destination as! WriteAnswerViewController
            writeAnswerViewController.screenType = .answer
            writeAnswerViewController.questionData = self.currentQuestionData
            writeAnswerViewController.dismissHandler = { (Success, response) in
                
                self.perforAfterLikeActivities()
                self.nowMoveBackToDiscover()
            }
        }
        else if (segue.identifier == "PushToChatFromDetailProfileView") {
            
//            let chatViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
            let chatViewControllerObj: NewChatViewController  = segue.destination as!  NewChatViewController
            if let model: MyMatches = sender as! MyMatches? {
                chatViewControllerObj.myMatchesData = model
                chatViewControllerObj.isAutomaticallyPushedFromChat = false
                chatViewControllerObj.parentView = .detailProfile
            }
//            let model = sender as! MyMatches
            
        }
        else if (segue.identifier == "MyProfileToMyQuestionSegue"){
       //     let myQuestionsViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
            
            let myquestionsViewController: MyQuestionsController  = segue.destination as! MyQuestionsController
            
            myquestionsViewController.isPresentedFromMyProfile = true
            
        }
    }
    
    @objc func showDataLoader(){
        dataLoaderTopConstraint.constant = (initialProfileDeckObject?.frame.size.height)! - 35
        if dataLoader.isAnimating == false {
            dataLoader.startAnimating()
        }
    }
    
    func getProfileData(){
        let myUserID = profileData?.wooId
        ProfileAPIClass.fetchDataForUser(withUserID: Int64(myUserID!)!) { (response, success, statusCode) in
            
            if statusCode == 500{
                Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("Woo is experiencing heavy traffic.", comment: "Woo is experiencing heavy traffic."), withActionTitle:"", withDuration: 3.0)
            }
            
            if statusCode == 401{
                //                self.handle
                //401 handling
            }
            if success{
                let responseDict: NSMutableDictionary = NSMutableDictionary.init(dictionary: (response as! NSDictionary))
                responseDict.setValue(myUserID, forKey: "wooId")
                //
                let oldProfileDataName = self.profileData?.firstName
                let oldProfileDataAge = self.profileData?.age
                
                self.profileData = ProfileCardModel.init(userInfoDto: responseDict)
                
                var responseDictionaryForUpdation = ["wooUserId": self.profileData?.wooId ?? ""]
                
                if self.profileData?.firstName.count == 0{
                    self.profileData?.firstName = oldProfileDataName ?? ""
                }
                
                if self.profileData?.age == "0"{
                    self.profileData?.age = oldProfileDataAge
                }
                
                responseDictionaryForUpdation["firstName"] = self.profileData?.firstName ?? ""
                
                responseDictionaryForUpdation["gender"] = self.profileData?.gender ?? ""
                
                responseDictionaryForUpdation["age"] = self.profileData?.age ?? ""
                if self.isMyProfile{
                responseDictionaryForUpdation["profilePicUrl"] = self.profileData?.wooAlbum?.profilePicUrl() ?? ""
                }
                else{
                    responseDictionaryForUpdation["profilePicUrl"] = self.profileData?.wooAlbum?.discoverProfilePicUrl() ?? ""
                }
                if(self.didCameFromChat == true)
                {
                    MyMatches.updateMatchedUserDetails(forMatchedUserID: self.profileData?.wooId ?? "", withName: self.profileData?.firstName ?? "", andProfilePic: self.profileData?.wooAlbum?.discoverProfilePicUrl() ?? "") { (success) in
                        if success{
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "matchDataUpdatedInDPV"), object: nil, userInfo: nil)
                        }
                    }
                }
                switch self.detailProfileParentTypeOfView ?? .visitor {
                case DetailProfileViewParent.visitor :
                    MeDashboard.updateBoostData(responseDictionaryForUpdation, forWooId: self.profileData?.wooId ?? "")
                    break
                case DetailProfileViewParent.likedMe :
                    LikedMe.updateData(responseDictionaryForUpdation, forWooId: self.profileData?.wooId ?? "")
                    break
                case DetailProfileViewParent.skippedProfile :
                    SkippedProfiles.updateSkippedData(responseDictionaryForUpdation)
                    break
                case DetailProfileViewParent.matchboxView :
                   
                    if self.isMyProfile{
                        MyMatches.updateMatchedUserDetails(forMatchedUserID: self.profileData?.wooId ?? "", withName: self.profileData?.firstName ?? "", andProfilePic: self.profileData?.wooAlbum?.discoverProfilePicUrl() ?? "") { (success) in
                            if success{
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "matchDataUpdatedInDPV"), object: nil, userInfo: nil)
                            }
                        }
                    }
                    else{
                        MyMatches.updateMatchedUserDetails(forMatchedUserID: self.profileData?.wooId ?? "", withName: self.profileData?.firstName ?? "", andProfilePic: self.profileData?.wooAlbum?.discoverProfilePicUrl() ?? "") { (success) in
                            if success{
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "matchDataUpdatedInDPV"), object: nil, userInfo: nil)
                            }
                        }

                    }
                    break
                case  DetailProfileViewParent.crush:
                    CrushesDashboard.updateCrushesData(responseDictionaryForUpdation, forWooId: self.profileData?.wooId ?? "")
                    break
                case DetailProfileViewParent.answers:
                    MyAnswers.updateAnswerData(responseDictionaryForUpdation, forWooId: self.profileData?.wooId ?? "")
                    break
                default:
                    break
                }
                
                
                DiscoverProfileCollection.sharedInstance.addProfileCard(self.profileData!)
                DispatchQueue.main.async(execute: {
                    self.addProfileNow()
                    self.perform(#selector(self.downloadFirstImageForProfile), with: nil, afterDelay: 0.0)
                    self.prepareCellDataFromProfile()
                    self.profileDetailTableView.reloadData()
                    self.perform(#selector(self.configureNavImage), with: nil, afterDelay: 0.8)
                    if self.isMyProfile{
                    if let imageUrlString = self.profileData?.wooAlbum?.profilePicUrl() {
                        self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                    }
                    }
                    else{
                        if let imageUrlString = self.profileData?.wooAlbum?.discoverProfilePicUrl() {
                            self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                        }
                    }
                })
            }
            else{
                DispatchQueue.main.async(execute: {
                    self.dataLoader.stopAnimating()
                    self.dataLoader.isHidden = true
                })
            }
        }
    }

    //MARK: IBAction methods
    @IBAction func disLike(_ sender: UIButton) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        //        if detailProfileParentTypeOfView == DetailProfileViewParent.TagSearch {
        //        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
        //        }
        
        if self.detailProfileParentTypeOfView == DetailProfileViewParent.visitor{
            MeDashboard.deleteBoostDataFromDB(withUserIDs: NSArray(objects: self.profileData!.wooId!) as [AnyObject], withCompletionHandler: nil)
            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "Me_Visitors_DPV_Skip")

        }
        else if self.detailProfileParentTypeOfView == DetailProfileViewParent.likedMe{
            LikedMe.deleteProfileDataFromDB(withUserIDs: NSArray(objects: self.profileData!.wooId!) as [AnyObject], withCompletionHandler: nil)
            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "Me_LikedMe_DPV_Skip")
        }
        else if self.detailProfileParentTypeOfView == DetailProfileViewParent.skippedProfile
        {
            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "Me_Skipped_DPV_Skip")
        }
        else
        {
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_SkipByTapOrSwipe")
        }

        if (self.detailProfileParentTypeOfView == DetailProfileViewParent.discover || self.detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch){
            if (DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE")
            {
                Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: self.profileData?.wooId, shouldDeleteFromAnswer: false, withCompletionHandler:{(completion) in
                    SkippedProfiles.insertOrUpdateSkippedProfileData(fromDiscoverCard: [self.profileData!], withCompletionHandler:{(completion) in
                        self.performDislikeOperationPostInsertionOrDeletion()
                    })
                })
              
            }
            else
            {
                SkippedProfiles.insertOrUpdateSkippedProfileData(fromDiscoverCard: [profileData!], withCompletionHandler:{(completion) in
                    self.performDislikeOperationPostInsertionOrDeletion()
                })
            }
        }
        else{
            Utilities().deleteMatchUser(fromAppExceptMatchBox: self.profileData!.wooId!, shouldDeleteFromAnswer: false, withCompletionHandler:{
                (iscompleted) in
                self.performDislikeOperationPostInsertionOrDeletion()
            })
        }

    }
    
    func performDislikeOperationPostInsertionOrDeletion(){
        
        
        if self.detailProfileParentTypeOfView == DetailProfileViewParent.answers {
            MyAnswers.deleteAllAnswersByUser(withUserID_Str: self.profileData!.wooId!, withCompletionHandler: {
                (completion) in
                DispatchQueue.main.async {
                    if(completion)
                    {
                        self.makeDislikeCallPostDeletion()
                    }
                }
            })
        }else{
            DispatchQueue.main.async {
                self.makeDislikeCallPostDeletion()
                
            }
        }
        
    }
    
    func makeDislikeCallPostDeletion(){
        
        var subStringValue = kDislikeSubSourcePassValue
        
        if ((self.detailProfileParentTypeOfView == DetailProfileViewParent.skippedProfile) || (self.detailProfileParentTypeOfView == DetailProfileViewParent.likedMe) || (self.detailProfileParentTypeOfView == DetailProfileViewParent.crush) || (self.detailProfileParentTypeOfView == DetailProfileViewParent.visitor)) {
            subStringValue = kDislikeSubSourceDislikeValue
        }
        
        DiscoverAPIClass.makePassCall(withParams: profileData!.wooId, withSubsource: subStringValue, withTagId: nil, andTagDTOType: nil, andCompletionBlock: { (success, response, statuscode) in
            if success{
                //Pass Done
            }
        })
        self.backActivity = PerformActionBasedOnActivity.Pass
        self.closeDetailViewController(backOrCloseButton)
    }
    
    @IBAction func like(_ sender: UIButton) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if isLikeLimitReached(){
            return
        }
        
        self.perforAfterLikeActivities()
        self.nowMoveBackToDiscover()
    }
    
    
    @IBAction func sendCrush(_ sender: UIButton) {
        
        rowValue = -1
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if profileData!.crushText.length > 0 {
            crushToBeSent = profileData!.crushText
            self.backActivity = PerformActionBasedOnActivity.Like
            self.like(UIButton())
            self.sendCrushButton.isUserInteractionEnabled = false
            self.sendCrushButton.setImage(UIImage(named: "crush3.0_disabled"), for: UIControl.State())
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
            if self.detailProfileParentTypeOfView == DetailProfileViewParent.discover{
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Discover_dpv_crush_tap")
            }
            else if self.detailProfileParentTypeOfView == DetailProfileViewParent.visitor{
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Visitor_profile_crush_tap")
            }
            else if self.detailProfileParentTypeOfView == DetailProfileViewParent.likedMe{
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "LikedByme_profile_crush_tap")
            }
            else if self.detailProfileParentTypeOfView == DetailProfileViewParent.skippedProfile{
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Skipped_profile_crush_tap")
            }
            self.performWorkAfterCrushPurchased(isSendButtonTapped: isSendButtonTapped, isTemplateTapped: isTemplateTapped, crushText: crushText)
        }
    }
    
    fileprivate func disableActionableButtons(){
        self.passButton.isUserInteractionEnabled = false
        self.likeButton.isUserInteractionEnabled = false
        self.sendCrushButton.isUserInteractionEnabled = false
    }
    
    fileprivate func performWorkAfterCrushPurchased(isSendButtonTapped:Bool, isTemplateTapped:Bool, crushText:String){
        
        self.enableButtonsNow()
        if isSendButtonTapped == false && isTemplateTapped == false{
            return
        }
        
        self.crushToBeSent = (crushText as NSString?)!
        self.backActivity = PerformActionBasedOnActivity.CrushSent
        self.likeButton.isUserInteractionEnabled = false;
        self.likeButton.setImage(UIImage(named: "like3.0_disabled"), for: UIControl.State())
        self.passButton.isUserInteractionEnabled = false;
        self.passButton.setImage(UIImage(named: "dislike3.0_disabled"), for: UIControl.State())
        self.sendCrushButton.isUserInteractionEnabled = false
        self.sendCrushButton.setImage(UIImage(named: "crush3.0_disabled"), for: UIControl.State())
        self.makeSendCrushCall()
        self.sendCrushViewObject = nil
    }
    
    @objc func enableButtonsNow()
    {
        if(self.detailProfileParentTypeOfView == DetailProfileViewParent.likedMe){
                   self.likeButton.isUserInteractionEnabled = false
                   self.passButton.isUserInteractionEnabled = false
            self.sendCrushButton.isUserInteractionEnabled = true

        }else{
            self.passButton.isUserInteractionEnabled = true
            self.likeButton.isUserInteractionEnabled = true
            self.sendCrushButton.isUserInteractionEnabled = true
        }
        
    }
    
    @objc @IBAction func openEditProfile() {
        
        if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
            
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Onboard_MyProfile", withEventName: "3-Onboarding.Onboard_MyProfile.OMP_TapEditProfile")
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName:"Onboard_MyProfile_TapEditProfile")
        }
        
        let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        controller.dismissHandler = { (needToOpenMyProfile, toClose) in
            
            if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
                self.onBoardingEditProfileDone = true
                self.nowMoveBackToDiscover()
            }
            
            self.profileData = DiscoverProfileCollection.sharedInstance.myProfileData
            self.profileDeckObject?.profileDetails = self.profileData
            self.profileDeckObject?.animateViewComponent = true
            self.profileDeckObject?.setDataForProfileView(true)
            self.profileDeckObject?.needToBeShownOrHiddenToBeCompatibleWithProfileDetailView()
            
            self.setHeightLocationText()
            self.setNameAgeText()
            
            DispatchQueue.main.async {
                
//                self.initialProfileDeckView.isHidden = false
                self.profileDeckObject?.removeFromSuperview()
                self.profileDeckObject = nil
//                self.addInitialProfileNow()
//                self.showDataLoader()
//                self.getProfileData()
                
                self.initialProfileDeckView.isHidden = true
                self.addProfileNow()
                self.dataLoader.isHidden = true
                self.prepareCellDataFromProfile()
                self.profileDetailTableView.reloadData()
                self.perform(#selector(self.scrollToAParticularPosition), with: nil, afterDelay: 0.5)
                self.perform(#selector(self.configureNavImage), with: nil, afterDelay: 0.8)
                if self.isMyProfile{
                    if let imageUrlString = self.profileData?.wooAlbum?.profilePicUrl() {
                        self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                    }
                }
                else{
                    if let imageUrlString = self.profileData?.wooAlbum?.discoverProfilePicUrl() {
                        self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                    }
                }
                
            }
        }
        
        
//        DiscoverProfileCollection.sharedInstance.addProfileCard(self.profileData!)
//        DispatchQueue.main.async(execute: {
//            self.addProfileNow()
//            self.perform(#selector(self.downloadFirstImageForProfile), with: nil, afterDelay: 0.0)
//            self.prepareCellDataFromProfile()
//            self.profileDetailTableView.reloadData()
//            self.perform(#selector(self.configureNavImage), with: nil, afterDelay: 0.8)
//            if self.isMyProfile{
//            if let imageUrlString = self.profileData?.wooAlbum?.profilePicUrl() {
//                self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
//            }
//            }
//            else{
//                if let imageUrlString = self.profileData?.wooAlbum?.discoverProfilePicUrl() {
//                    self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
//                }
//            }
//        })
        
        
      //  let navController = UINavigationController(rootViewController: controller)
        self.navigationController?.pushViewController(controller, animated: true)
        //(navController, animated: false, completion: nil)
    }
    
    @IBAction func closeDetailViewController(_ sender: UIButton) {
        
        profileDetailTableView.backgroundColor = UIColor.clear
        
        self.perform(#selector(nowMoveBackToDiscover), with: nil, afterDelay: 0.0)
    }
    
    @IBAction func optionButtonTapped(_ sender: UIButton) {
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            let reportAlertcontroller: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                NSLog("Cancel tapped")
            })
            if didCameFromChat{
                let unMatchAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Unmatch",comment: "Unmatch"), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.showUnMatchOptions()
                })
                reportAlertcontroller.addAction(unMatchAction)
            }
            let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Block & Report",comment: "Block & Report"), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.startReporting(false)
            })
            reportAlertcontroller.addAction(cancelAction)
            reportAlertcontroller.addAction(reportAction)
            reportAlertcontroller.view!.tintColor = UIColor(red: 22.0 / 255.0, green: 102.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
            self.present(reportAlertcontroller, animated: true, completion: {() -> Void in
                reportAlertcontroller.view!.tintColor = UIColor(red: 22.0 / 255.0, green: 102.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
            })
        }
        else{
            if isMyProfile {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let myPreferencesViewController =
                    storyboard.instantiateViewController(withIdentifier: kMyPreferencesController)
                        as? MyPreferencesViewController
                myPreferencesViewController?.isOpenedFromMyProfile = true
                self.navigationController?.pushViewController(myPreferencesViewController!, animated: true)
//                self.present(myPreferencesViewController!, animated: true, completion: nil)
            }
            else{
                let reportAlertcontroller: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                    NSLog("Cancel tapped")
                })
                if didCameFromChat{
                    let unMatchAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Unmatch",comment: "Unmatch"), style: .default, handler: {(action: UIAlertAction) -> Void in
                        self.showUnMatchOptions()
                    })
                    reportAlertcontroller.addAction(unMatchAction)
                }
                let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Block & Report",comment: "Block & Report"), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.startReporting(false)
                })
                reportAlertcontroller.addAction(cancelAction)
                reportAlertcontroller.addAction(reportAction)
                reportAlertcontroller.view!.tintColor = UIColor(red: 22.0 / 255.0, green: 102.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                self.present(reportAlertcontroller, animated: true, completion: {() -> Void in
                    reportAlertcontroller.view!.tintColor = UIColor(red: 22.0 / 255.0, green: 102.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                })
            }
        }
    }
    
    @objc func configureNavImage() {
                
        if profileDeckObject != nil && profileDeckObject?.profileImageView != nil{
        navImageHeightConstrain.constant = (profileDeckObject?.profileImageView?.frame.height)!
            
//            if profileDeckObject?.imageGalleryContainerView != nil {
//                let gradientBottom:CAGradientLayer = CAGradientLayer()
//                gradientBottom.colors = [kGradientColorClear, kGradientColorBlackBottomForDPV]
//                gradientBottom.frame = CGRect(x: 0, y: (profileDeckObject?.imageGalleryContainerView.bounds.size.height)!*2/3 - 49,
//                                              width: UIScreen.main.bounds.width,
//                                              height: (profileDeckObject?.imageGalleryContainerView.bounds.size.height)!/3 + 49);
//                navBarImageView.layer.addSublayer(gradientBottom)
//            }
        }
    }
    
    fileprivate func makeSendCrushCall(){
        
        self.nowMoveBackToDiscover()
    }
    
    @objc fileprivate func showSendCrushView(){
        if sendCrushViewObject == nil {
            let mainWindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
            sendCrushViewObject = SendCrushView.init(frame: mainWindow.rootViewController!.view.frame)
        }
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        sendCrushViewObject?.presentView(on: self.view, withTemplateQuestions: CrushModel.sharedInstance().templateQuestionArray, userName: profileData?.firstName, withAnimationTime: 0.25, withCompletionBlock: { (true) in
            self.sendCrushViewObject?.viewDismissed({ (crushText, isSendButtonTapped, isTemplateTapped, selectedRow) in
                
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_SendCrush")
                
                
                if isSendButtonTapped == false && isTemplateTapped == false{
                    return
                }
                self.crushToBeSent = (crushText as NSString?)!
                self.backActivity = PerformActionBasedOnActivity.CrushSent
                //                self.likeButton.enabled = false
                //                self.passButton.enabled = false
                self.likeButton.isUserInteractionEnabled = false;
                self.likeButton.setImage(UIImage(named: "like3.0_disabled"), for: UIControl.State())
                self.passButton.isUserInteractionEnabled = false;
                self.passButton.setImage(UIImage(named: "dislike3.0_disabled"), for: UIControl.State())
                //                self.sendCrushButton.enabled = false
                self.sendCrushButton.isUserInteractionEnabled = false
                self.sendCrushButton.setImage(UIImage(named: "crush3.0_disabled"), for: UIControl.State())
                self.makeSendCrushCall()
                self.sendCrushViewObject = nil
            })
        })
    }
    
    fileprivate func showPopularUserView(){
        let popularUserViewObject:PopularUserView = Bundle.main.loadNibNamed("PopularUserView", owner: nil, options: nil)![0] as! PopularUserView
        popularUserViewObject.frame = self.view.bounds
        popularUserViewObject.setPopularDataOnViewWithImage(profileData!.wooAlbum?.objectAtIndex(0)?.url, withName: profileData!.firstName, andType: false, withGender:profileData!.gender) { (selectedIndex:NSInteger, typeOfView:Bool) in
            //popular user handling
            
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
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if CrushModel.sharedInstance().availableCrush > 0 {
                                        self.showSendCrushView()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                    purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        if CrushModel.sharedInstance().availableCrush > 0 {
                            self.showSendCrushView()
                        }
                        
                    }
                }
                
            }
        }
        
        self.view.addSubview(popularUserViewObject)
    }
    
    fileprivate func showOutOfCrushesView(){
        
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfCrushPopup")
        
        
        let outOfCrushesViewObject:PopularUserView = Bundle.main.loadNibNamed("PopularUserView", owner: nil, options: nil)![0] as! PopularUserView
        outOfCrushesViewObject.frame = self.view.bounds
        outOfCrushesViewObject.setPopularDataOnViewWithImage(profileData!.wooAlbum?.objectAtIndex(0)?.url, withName: profileData!.firstName, andType: true, withGender:profileData!.gender) { (selectedIndex:NSInteger, typeOfView:Bool) in
            //out of crushes handling
            if typeOfView == true{
                if selectedIndex != 0{
                    //Purchase screen
                    
                    if !(Utilities.sharedUtility() as AnyObject).reachable() {
                        self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                        return
                    }
                    
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DC_OutOfCrushPopup_GetCrushes")
                    
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
                        dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if CrushModel.sharedInstance().availableCrush > 0 {
                                        self.showSendCrushView()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }

                }else{ // Cancel Button Clicked
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DC_OutOfCrushPopup_Cancel")
                    
                    
                }
            }
        }
        self.view.addSubview(outOfCrushesViewObject)
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    /**
     *
     */
    @objc fileprivate func scrollToAParticularPosition(){
        
        if userdataArray.count > 0 {
            if self.profileData != nil && rowValue>0{
                if rowValue != 0 {
                    let indexPath = IndexPath(row: rowValue, section: 0)
                    profileDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
            }
            else if (rowValue != -1){
                
                profileDetailTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: profileDetailTableView.frame.size.width, height: profileDetailTableView.frame.size.height), animated: true)
            }
        }
        moveToCellBasedOnCommonalitySelection = ""
    }
    
    /**
     * Prepares the data source for the table view reading from profile data model
     */
    fileprivate func prepareCellDataFromProfile() {
        
        userdataArray.removeAllObjects()
        
        if let profileData = self.profileData
        {
            if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
                
                if didCameFromChat{
                    optionkOrSettingsButton.setImage(UIImage(named: "ic_dpv_thick_more"), for: UIControl.State())
                }
                else{
                    optionkOrSettingsButton.setImage(UIImage(named: "ic_dpv_white_block"), for: UIControl.State())
                }
                
                if profileData.crushText.length > 0 {
                    
                    if profileData.personalQuote != nil && profileData.personalQuote?.count > 0 {
                        let personalQouteDictionary = NSDictionary(objects: [CellType.PersonalQouteCell.rawValue, profileData.personalQuote!],
                                                                   forKeys: ["type" as NSCopying,"text" as NSCopying])
                        
                        userdataArray.add(personalQouteDictionary as AnyObject)
                    }
                    
                    if ((profileData.about) != nil) && profileData.about?.count > 0 {
                        
                        //                            let aboutHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                        //                                                         "subtype": "normal",
                        //                                                         "text" : "About \(profileData.firstName)"]
                        
                        _ = ["type": CellType.AboutHeaderCell.rawValue,
                                                     "subtype": "normal",
                                                     "text" : NSString(format: NSLocalizedString("About %@", comment: "About %@") as NSString, profileData.firstName)] as [String : Any]
                        
                        _ = NSDictionary(objects: [CellType.AboutMeCell.rawValue, profileData.about!],
                                                           forKeys: ["type" as NSCopying,"text" as NSCopying])
                        
                        //userdataArray.add(aboutHeaderDictionary as AnyObject)
                        //userdataArray.add(aboutDictionary as AnyObject)
                    }
                }
                else{
                    if profileData.personalQuote != nil && profileData.personalQuote?.count > 0 {
                        
                        if ((profileData.about) != nil) &&
                            profileData.about?.count > 0 {
                            
                            //                                let aboutHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                            //                                                             "subtype": "normal",
                            //                                                             "text" : "About \(profileData.firstName)"]
                            
                            _ = ["type": CellType.AboutHeaderCell.rawValue,
                                                         "subtype": "normal",
                                                         "text" : NSString(format: NSLocalizedString("About %@", comment: "About %@") as NSString, profileData.firstName)] as [String : Any]
                            
                            let aboutDictionary = NSDictionary(objects: [CellType.AboutMeCell.rawValue, profileData.about!],
                                                               forKeys: ["type" as NSCopying,"text" as NSCopying])
                            
                            //userdataArray.add(aboutHeaderDictionary as AnyObject)
                            userdataArray.add(aboutDictionary as AnyObject)
                        }
                    }
                }
            }
            else{
                if !isMyProfile {
                    
                    if didCameFromChat{
                        optionkOrSettingsButton.setImage(UIImage(named: "ic_dpv_thick_more"), for: UIControl.State())
                    }
                    else{
                        optionkOrSettingsButton.setImage(UIImage(named: "ic_dpv_white_block"), for: UIControl.State())
                    }
                    
                    if(checkIfUserHasVisitedProfileFromChat())
                    {
                        //add cells for message, call, unmatch and report
                        let messageDictionary = NSDictionary(objects : [CellType.ChatTypeCell.rawValue,"message","Send a message","(Keep the conversation going)"], forKeys: ["type" as NSCopying,"subtype" as NSCopying,"text" as NSCopying,"subtext" as NSCopying])
                        userdataArray.add(messageDictionary as AnyObject)
                        if(AppLaunchModel.sharedInstance().isCallingEnabled == true)
                        {
                            let callDictionary = NSDictionary(objects : [CellType.ChatTypeCell.rawValue,"call", "Call \(profileData.firstName)","(Private and safe internet calling)"], forKeys: ["type" as NSCopying,"subtype" as NSCopying,"text" as NSCopying,"subtext" as NSCopying])
                            userdataArray.add(callDictionary as AnyObject)
                        }
                        let unmatchDictionary = NSDictionary(objects : [CellType.ChatTypeCell.rawValue,"unmatch","Unmatch \(profileData.firstName)","(You know when it's right or wrong)"], forKeys: ["type" as NSCopying,"subtype" as NSCopying,"text" as NSCopying,"subtext" as NSCopying])
                        userdataArray.add(unmatchDictionary as AnyObject)
                        
                        let reportAndBlockDictionary = NSDictionary(objects : [CellType.ChatTypeCell.rawValue,"report","Report and Block","(Help keep the community clean)"], forKeys: ["type" as NSCopying,"subtype" as NSCopying,"text" as NSCopying,"subtext" as NSCopying])
                        userdataArray.add(reportAndBlockDictionary as AnyObject)
                        
                        if profileData.personalQuote != nil && profileData.personalQuote?.count > 0 {
                            let personalQouteDictionary = NSDictionary(objects: [CellType.PersonalQouteCell.rawValue, profileData.personalQuote!],                                                                       forKeys: ["type" as NSCopying,"text" as NSCopying])
                            
                            userdataArray.add(personalQouteDictionary as AnyObject)
                        }
                    }
                    
                    if profileData.crushText.length > 0 {
                        
                        if !checkIfUserHasVisitedProfileFromChat() {
                        if profileData.personalQuote != nil && profileData.personalQuote?.count > 0 {
                            let personalQouteDictionary = NSDictionary(objects: [CellType.PersonalQouteCell.rawValue, profileData.personalQuote!],                                                                       forKeys: ["type" as NSCopying,"text" as NSCopying])
                            
                            userdataArray.add(personalQouteDictionary as AnyObject)
                        }
                        }
                        
                        if ((profileData.about) != nil) && profileData.about?.count > 0 {
                            
                            _ = ["type": CellType.AboutHeaderCell.rawValue,
                                                         "subtype": "normal",
                                                         "text" : "About \(profileData.firstName)"]
                            let aboutDictionary = NSDictionary(objects: [CellType.AboutMeCell.rawValue, profileData.about!],
                                                               forKeys: ["type" as NSCopying,"text" as NSCopying])
                            
                            //userdataArray.add(aboutHeaderDictionary as AnyObject)
                            userdataArray.add(aboutDictionary as AnyObject)
                        }
                    }
                    else{
                        if profileData.personalQuote != nil && profileData.personalQuote?.count > 0 {
                            
                            if ((profileData.about) != nil) &&
                                profileData.about?.count > 0 {
                                
                                _ = ["type": CellType.AboutHeaderCell.rawValue,
                                                             "subtype": "normal",
                                                             "text" : "About \(profileData.firstName)"]
                                let aboutDictionary = NSDictionary(objects: [CellType.AboutMeCell.rawValue, profileData.about!],
                                                                   forKeys: ["type" as NSCopying,"text" as NSCopying])
                                
                                //userdataArray.add(aboutHeaderDictionary as AnyObject)
                                userdataArray.add(aboutDictionary as AnyObject)
                            }
                        }
                    }
                }
                else{
                    /*
                    if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
                        
                        optionkOrSettingsButton.isHidden = true
                    }
                    else{
                        optionkOrSettingsButton.setImage(UIImage(named: "ic_left_menu_settings"), for: UIControlState())
                    }
                    */
                    optionkOrSettingsButton.isHidden = true
                    
                    if profileData.personalQuote != nil  && profileData.personalQuote?.count > 0 &&
                        profileData.about != nil && profileData.about?.count > 0 {
                        
                        _ = ["type": CellType.AboutHeaderCell.rawValue,
                                                     "subtype": "normal",
                                                     "text" : "About Me"]
                        let aboutDictionary = NSDictionary(objects: [CellType.AboutMeCell.rawValue, profileData.about!],
                                                           forKeys: ["type" as NSCopying,"text" as NSCopying])
                        
                        //userdataArray.add(aboutHeaderDictionary as AnyObject)
                        userdataArray.add(aboutDictionary as AnyObject)
                    }
                }
            }
            
            if profileData.profileInfoTags.count > 0{
                let profileInfoDictionary = NSDictionary(objects: [CellType.ProfileInfoTableViewCell.rawValue, profileData.profileInfoTags],
                                                   forKeys: ["type" as NSCopying,"data" as NSCopying])
                
                userdataArray.add(profileInfoDictionary as AnyObject)
            }
            
            if profileData.diasporaLocation.count > 0 {
                
                var loctionString = ""
                if let location = profileData.location{
                    loctionString = "Current location - \(location)"
                }
                _ = NSDictionary(objects: [CellType.AboutMeCell.rawValue, loctionString],
                                                   forKeys: ["type" as NSCopying,"text" as NSCopying])
                
                //userdataArray.add(aboutDictionary as AnyObject)
                
            }
            
            var phoneNumber = ""
            if profileData.phoneNumberDto != nil {
                if ((profileData.phoneNumberDto?.object(forKey: "phoneNumber")) != nil){
                    phoneNumber = profileData.phoneNumberDto?.object(forKey: "phoneNumber") as! String
                }
            }
            
            if phoneNumber.count > 0 || profileData.isPhoneVerified  {
                let linkedInPhoneDictionary = ["type": CellType.LinkedInPhoneCell.rawValue, "subType" : "Phone"]
                userdataArray.add(linkedInPhoneDictionary as AnyObject)
            }
            
            //first question
            if profileData.myQuestionsArray.count > 0 {
                let questionDictionary  = ["type": CellType.QnADPVTableViewCell.rawValue,"paddingRequired" : false, "data" : profileData.myQuestionsArray.first ?? TargetQuestionModel()] as [String : Any]
                    userdataArray.add(questionDictionary as AnyObject)
            }

            
        //    if profileData.ethnicity.count > 0 {
            /*
                var needToShowEthnicityCell = isMyProfile
            
                if isMyProfile == true {
                    for ethItem in profileData.ethnicity {
                        needToShowEthnicityCell = needToShowEthnicityCell || ethItem.isSelected
                    }
                }
                else
                {
                    needToShowEthnicityCell = true
                }
            
                var ethnicityArrayToShow = profileData.ethnicity
                
                if isMyProfile == true {
                    ethnicityArrayToShow = profileData.ethnicity
                }
                else{
                    ethnicityArrayToShow.removeAll()
                    if(profileData.ethnicityText.characters.count > 0)
                    {
                        needToShowEthnicityCell = true
                    }
                    else
                    {
                       needToShowEthnicityCell = false
                    }
//                    for ethItem in profileData.ethnicity {
//                        if ethItem.isSelected == true {
//                            ethnicityArrayToShow.append(ethItem)
//                        }
//                    }
                }
                
                if needToShowEthnicityCell {
                    let aboutHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                                                 "subtype": "normal",
                                                 "text" : NSLocalizedString("Community", comment: "")]
                    
                    let aboutDictionary = NSDictionary(objects: [CellType.EthnicityCell.rawValue, ethnicityArrayToShow],
                                                       forKeys: ["type" as NSCopying,"data" as NSCopying])
                    
                    //userdataArray.add(aboutHeaderDictionary as AnyObject)
                    //userdataArray.add(aboutDictionary as AnyObject)
                }
            */
                
                
           // }
            
//            if profileData.ethnicity.count > 0 {
//                let aboutHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
//                                             "subtype": "normal",
//                                             "text" : NSLocalizedString("Ethnicity & Community", comment: "")]
//                
//                let aboutDictionary = NSDictionary(objects: [CellType.EthnicityCell.rawValue, profileData.ethnicity],
//                                                   forKeys: ["type" as NSCopying,"data" as NSCopying])
//                
//                userdataArray.add(aboutHeaderDictionary as AnyObject)
//                userdataArray.add(aboutDictionary as AnyObject)
//            }
            
            //            if profileData.ethnicityText.characters.count>0 {
            //                let aboutHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
            //                                             "subtype": "normal",
            //                                             "text" : NSLocalizedString("Ethnicity & Community", comment: "")]
            //
            //                let aboutDictionary = NSDictionary(objects: [CellType.EthnicityCell.rawValue, profileData.ethnicity],
            //                                                   forKeys: ["type" as NSCopying,"data" as NSCopying])
            //
            //                userdataArray.add(aboutHeaderDictionary as AnyObject)
            //                userdataArray.add(aboutDictionary as AnyObject)
            //            }
            
            /*
            if profileData.religionText.characters.count>0 {
                let aboutHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                                             "subtype": "normal",
                                             "text" : NSLocalizedString("Religion", comment: "")]
                
                let aboutDictionary = NSDictionary(objects: [CellType.AboutMeCell.rawValue, profileData.religionText],
                                                   forKeys: ["type" as NSCopying,"text" as NSCopying])
                
                //userdataArray.add(aboutHeaderDictionary as AnyObject)
                //userdataArray.add(aboutDictionary as AnyObject)
            }
            */
            
            
            /*
            let commonTagsHeaderDictionary = ["type":CellType.AboutHeaderCell.rawValue,
                                              "subtype": "normal",
                                              "text" : NSLocalizedString("Tags in Common", comment: "Tags in Common")]
            let commonTagsDictionary  = ["type": CellType.TagCell.rawValue, "subtype": "ctag", "data" : profileData.commonTags] as [String : Any]
            if profileData.commonTags.count > 0 {
                
                userdataArray.add(commonTagsHeaderDictionary as AnyObject)
                userdataArray.add(commonTagsDictionary as AnyObject)
                
                print("commonTags ==> \(self.calculateTagCellHeight(profileData.commonTags))")
            }
            */
            
            if profileData.tags.count > 0 {
                var headerText = "\(profileData.firstName)'s Tags"
                if isMyProfile {
                    headerText = NSLocalizedString("My Tags", comment: "My Tags")
                }
                _ = ["type": CellType.AboutHeaderCell.rawValue,
                                             "subtype": "normal",
                                             "text" : headerText]
                let tagsDictionary  = ["type": "TagCell", "subtype": "tag", "data" : profileData.tags] as [String : Any]
                
                //userdataArray.add(aboutHeaderDictionary as AnyObject)
                userdataArray.add(tagsDictionary as AnyObject)
                
                print("tags ==> \(self.calculateTagCellHeight(profileData.tags))")
            }
            
            //second question
            if profileData.myQuestionsArray.count > 1 {
                let questionDictionary  = ["type": CellType.QnADPVTableViewCell.rawValue,"paddingRequired" : false, "data" : profileData.myQuestionsArray[1]] as [String : Any]
                userdataArray.add(questionDictionary as AnyObject)
            }
            
            let friendDictionary  = ["type": CellType.RoundedImageCell.rawValue, "data" : profileData.mutualFriends] as [String : Any]
            if profileData.mutualFriends.count > 0 {
                let mutualFriendsHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                                                     "subtype": "Friends",
                                                     "text" : "Friends in Common"]
                
                userdataArray.add(mutualFriendsHeaderDictionary as AnyObject)
                userdataArray.add(friendDictionary as AnyObject)
            }
            
            //third question
            if profileData.myQuestionsArray.count > 2 {
                var paddingRequired = false
                if userdataArray.contains(friendDictionary) == false{
                    paddingRequired = true
                }
                let questionDictionary  = ["type": CellType.QnADPVTableViewCell.rawValue,"paddingRequired" : paddingRequired, "data" : profileData.myQuestionsArray[2]] as [String : Any]
                userdataArray.add(questionDictionary as AnyObject)
            }
            
            /*
            let questionsHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                                             "subtype": "question",
                                             "text" : "\(profileData.firstName)'s Questions"]
            var lastQuestionDictionary = [String:Any]()
            if profileData.targetQuestions.count > 0 {
                userdataArray.add(questionsHeaderDictionary as AnyObject)
                for answer in profileData.targetQuestions {
                    let questionDictionary  = ["type": CellType.QuestionTableViewCell.rawValue, "data" : answer] as [String : Any]
                    lastQuestionDictionary = questionDictionary
                    userdataArray.add(questionDictionary as AnyObject)
                }
            }
            
            var hisOrHer = "She"
            if (Utilities.sharedUtility() as AnyObject).isGenderMale(profileData.gender) {
                hisOrHer = "He"
            }
            var lastAnsweredDictionary = [String:Any]()
            let targetQuestionsHeaderDictionary = ["type": CellType.AboutHeaderCell.rawValue,
                                                   "subtype": "question",
                                                   "text" : "\(hisOrHer) Answered"]
            if profileData.actorQuestionTargetAnswers.count > 0 {
                
                userdataArray.add(targetQuestionsHeaderDictionary as AnyObject)
                
                for answer in profileData.actorQuestionTargetAnswers {
                    let actorQuestionDictionary  = ["type": CellType.ActorQuestionTableViewCell.rawValue, "data" : answer] as [String : Any]
                    lastAnsweredDictionary = actorQuestionDictionary
                    userdataArray.add(actorQuestionDictionary as AnyObject)
                }
            }
            */
            
            /*
            if UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) &&
                isMyProfile {
                
                let myquestionDictionary  = ["type": CellType.MyQuestionCell.rawValue]
                userdataArray.add(myquestionDictionary as AnyObject)
            }
            */
            
//            if profileData.isPhoneVerified {
//                let phoneDictionary  = ["type": CellType.LinkedInPhoneCell.rawValue, "subType" : "Phone"]
//                userdataArray.add(phoneDictionary as AnyObject)
//            }
            
            if !isMyProfile && self.checkIfUserHasVisitedProfileFromChat() == false {
                let reportDictionary  = ["type": "ReportCell"]
                userdataArray.add(reportDictionary as AnyObject)
            }
            
            //if self.didCameFromChat == false {
            let footerDictionary  = ["type": "FooterCell"]
            userdataArray.add(footerDictionary as AnyObject)
            //}
           
            if let localObject = moveToCellBasedOnCommonalitySelection {
                switch localObject {
                    /*
                case "TAGSINCOMMON":
                    if userdataArray.contains(commonTagsDictionary){
                        var additionalValue = 1
                        if profileData.tags.count > 0 || profileData.mutualFriends.count > 0 || profileData.targetQuestions.count > 0 || profileData.actorQuestionTargetAnswers.count > 0{
                            additionalValue = 2
                        }
                        rowValue = userdataArray.index(of: commonTagsDictionary) + additionalValue
                    }
                    else{
                        rowValue = -1
                    }
                    break
                    */
                case "FRIENDSINCOMMON":
                    if userdataArray.contains(friendDictionary){
                        rowValue = userdataArray.index(of: friendDictionary) + 1
                    }
                    else{
                        rowValue = -1
                    }
                    break
                case "QUESTIONTAG":
                    rowValue = -1
                   
                    break
                case "ANSWERTAG":
                    rowValue = -1
                    break
                default:
                    rowValue = -1
                }
            }
            
            nav_completenessLabel.text = (profileData.profileCompletenessScore) + "%"
            if isMyProfile == true{
            if let number = NumberFormatter().number(from: (profileData.profileCompletenessScore)) {
                nav_completenessProgressBar.progressValue = CGFloat(truncating: number)
              }
            }
        }
    }
        
    @objc fileprivate func needToMakeProfileDeckBig(){
        
        self.view.layoutIfNeeded()
        
        let height:CGFloat = UIScreen.main.bounds.size.height
        
        UIView.animate(withDuration: 0.25, animations: {
            self.tempImageView?.frame.size.height = height
            
        }, completion: { (true) in
            UIView.animate(withDuration: 0.25, animations: {
                self.profileDetailTableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
                self.profileDetailTableView.contentOffset = CGPoint(x: 0, y: -height);
                self.profileDeckObject!.frame.size.height = height
                self.profileDeckObject?.frame.origin.y = -height
                self.profileDeckObject?.imageGalleryView?.frame.size.height = height
              self.profileDeckObject?.imageGalleryView?.imageGalleryCollectionView.frame.size.height = height
                
                self.profileDeckObject?.aboutmeLabelContainerView.alpha = 0
                self.profileDeckObject?.crushMessageLabelContainerView.alpha = 0
                self.profileDeckObject?.myProfileBottomView.alpha = 0
                self.profileDeckObject?.imageGalleryView?.imageGalleryCollectionView.performBatchUpdates({
                self.profileDeckObject?.imageGalleryView?.imageGalleryCollectionView.reloadSections(IndexSet(integer:0))
                }, completion: { (true) in
                    self.tempImageView!.removeFromSuperview()
                })
                
                self.lastheightOfProfileDeckMainContainerView = (self.profileDeckObject?.ProfileDeckMainContainerViewHeightConstraint.constant)!
                
                self.profileDeckObject!.ProfileDeckMainContainerViewHeightConstraint.constant = height
                
                self.perform(#selector(self.updatePageControlYNow), with: nil, afterDelay: 0.0)
                
                self.NameAgeLabel.alpha = 0
                self.heightLabel.alpha = 0
                self.locationLabel.alpha = 0
                self.profileDetailTableView.isScrollEnabled = false
                self.view.layoutIfNeeded()
                self.profileDeckObject?.imageGalleryView?.isAllowedToTapNow = true
            })
        })
        
    }
    
    @objc fileprivate func needToMakeProfileDeckBackToSameSize(){
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25, animations: {
            
            var height:CGFloat = 0
            
            if self.profileData?.crushText.length>0{
                height = UIScreen.main.bounds.size.height
            }
            else if self.profileData?.personalQuote != nil && self.profileData?.personalQuote?.count>0{
                height = UIScreen.main.bounds.size.height
            }
            else if self.profileData?.about != nil && self.profileData?.about?.count>0{
                height = UIScreen.main.bounds.size.height
            }
            else{
                height = UIScreen.main.bounds.size.height - self.YConstraintForProfileDeck
            }
            
            self.profileDetailTableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
            self.profileDetailTableView.contentOffset = CGPoint(x: 0, y: -height);
            self.profileDeckObject!.frame.size.height = height
            self.profileDeckObject?.frame.origin.y = -height
            self.profileDeckObject?.imageGalleryView?.frame.size.height = self.lastheightOfProfileDeckMainContainerView
            self.profileDeckObject?.imageGalleryView?.imageGalleryCollectionView.frame.size.height = self.lastheightOfProfileDeckMainContainerView
            self.tempImageView?.frame.size.height = self.lastheightOfProfileDeckMainContainerView
            
            self.profileDeckObject?.imageGalleryView?.imageGalleryCollectionView.performBatchUpdates({
                self.profileDeckObject?.imageGalleryView?.imageGalleryCollectionView.reloadSections(IndexSet(integer:0))
            }, completion: { (true) in
                self.tempImageView!.removeFromSuperview()
            })
            self.profileDeckObject!.ProfileDeckMainContainerViewHeightConstraint.constant = self.lastheightOfProfileDeckMainContainerView
            
            self.perform(#selector(self.updatePageControlYNow), with: nil, afterDelay: 0.0)
            
            self.NameAgeLabel.alpha = 1
            self.heightLabel.alpha = 1
            self.locationLabel.alpha = 1
            self.profileDeckObject?.aboutmeLabelContainerView.alpha = 1
            self.profileDeckObject?.crushMessageLabelContainerView.alpha = 1
            self.profileDeckObject?.myProfileBottomView.alpha = 1
            self.profileDetailTableView.isScrollEnabled = true
            self.needToMakeGallerySmall = false
            self.view.layoutIfNeeded()
            
        }, completion: { (true) in
            self.profileDeckObject?.imageGalleryView?.isAllowedToTapNow = true
        })
        
    }
    
    fileprivate func createATempImageViewToShowForRemovingFlickerWhileItIsBigOrSmall(_ isItBig:Bool){
        if isItBig == true {
            let height:CGFloat = UIScreen.main.bounds.size.height
            tempImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: (profileDeckObject?.imageGalleryView?.frame.size.width)!, height: height))
            tempImageView!.contentMode = UIView.ContentMode.scaleAspectFill
            tempImageView!.clipsToBounds = true
            tempImageView!.backgroundColor = UIColor.clear
            self.view.addSubview(tempImageView!)
        }
        else{
            var height:CGFloat = 0
            if lastheightOfProfileDeckMainContainerView > 0 {
                height = lastheightOfProfileDeckMainContainerView
            }
            else{
                height = (self.profileDeckObject?.ProfileDeckMainContainerViewHeightConstraint.constant)!
            }
            tempImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: (profileDeckObject?.imageGalleryView?.frame.size.width)!, height: height))
            tempImageView!.contentMode = UIView.ContentMode.scaleAspectFill
            tempImageView!.clipsToBounds = true
            tempImageView!.backgroundColor = UIColor.clear
            self.view.addSubview(tempImageView!)
        }
        if let localurl = self.profileDeckObject!.profileDetails?.wooAlbum?.objectAtIndex((self.profileDeckObject?.imageGalleryView?.getCurrentImageIndex())!)?.url {
            let urlStr : String = localurl as String
            if urlStr.count > 0 {
                var placeHolderImageStr:String = ""
                if (Utilities.sharedUtility() as AnyObject).isGenderMale(self.profileDeckObject?.profileDetails?.gender) {
                    placeHolderImageStr = "placeholder_male"
                }
                else{
                    placeHolderImageStr = "placeholder_female"
                }
                
                self.tempImageView!.sd_setImage(with: URL(string: urlStr as String), placeholderImage: UIImage.init(named: placeHolderImageStr))
            }
        }
        
    }
    
    fileprivate func addInitialProfileNow(){
        
        var height:CGFloat = 0
        
        var heightThreshold:CGFloat = 0
        
        heightThreshold = 188
        
        height = UIScreen.main.bounds.size.height - heightThreshold
        
        /*
        var extraWidth:CGFloat = 0.0
        if didCameFromChat{
            extraWidth = 4.0
        }
        */
        
        let width:CGFloat = UIScreen.main.bounds.size.width
        
        if initialProfileDeckObject == nil{
        initialProfileDeckObject = ProfileDeckView.init(frame: CGRect(x: 0, y: -20, width: width, height: height))
            initialProfileDeckView.addSubview(initialProfileDeckObject!)
        }
        
        initialProfileDeckViewHeightConstraint.constant = height
        profileDetailTableView.isHidden = true
        
        initialProfileDeckObject?.profileDetails = profileData

        initialProfileDeckObject?.hadAlreadyBeenShownInDiscover = true
        
        initialProfileDeckObject?.getTappedIndexForGallery =  {(val1: Int) in
            self.closeDetailViewController(self.backOrCloseButton)
        }
        
        initialProfileDeckObject?.closeDetailViewControllerHandler = {() in
            self.closeDetailViewController(self.backOrCloseButton)
            
        }
        initialProfileDeckObject?.closeTagPopupHandler = {() in
            self.dismissTagTraningView(Any.self)
        }
        if isComingFromDiscover == true {
            initialProfileDeckObject?.alpha = 0
            isComingFromDiscover = false
        }
        if detailProfileParentTypeOfView == DetailProfileViewParent.discover {
            initialProfileDeckObject?.isLoadedNotFromDiscover = false
        }
        else
        {
            initialProfileDeckObject?.isLoadedNotFromDiscover = true
        }
        
        initialProfileDeckObject!.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
        initialProfileDeckObject!.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
        initialProfileDeckObject!.myProfileBottomViewTrailingConstraint.constant = 0
        initialProfileDeckObject!.myProfileBottomViewLeadingConstraint.constant = 0
        
            initialProfileDeckObject?.cameFromChat = didCameFromChat
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            initialProfileDeckObject!.gettingUsedInTagSearch = true
            initialProfileDeckObject!.setDataForProfileView(false)
        }
        else{
            if isMyProfile {
                initialProfileDeckObject!.setDataForProfileView(true)
            }
            else{
                initialProfileDeckObject!.setDataForProfileView(false)
            }
        }
        
        profileDetailTableView.isScrollEnabled = false
        initialProfileDeckObject?.needToBeShownOrHiddenToBeCompatibleWithProfileDetailView()
        
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            if discoverSnapShot != nil {
                self.profileSnapShotImageView.image = discoverSnapShot
                self.profileSnapShotView.isHidden = false
                self.perform(#selector(clearSnapShot), with: nil, afterDelay: 0.5)
            }
            else{
                clearSnapShot()
            }
            //self.perform(#selector(nowHideProfileDeckViews), with: nil, afterDelay: 0.4)
            //profileDetailTableView.backgroundColor = UIColor.white
            //nowHideProfileDeckViews()
        }
        else{
            //self.perform(#selector(nowHideProfileDeckViews), with: nil, afterDelay: 0.4)
        }
        lastOffSetLocation = (0 - height);
        //Setting FirstName
        setNameAgeText()
        //Setting HeightLocation Text
        setHeightLocationText()
    }
    
    
    fileprivate func addProfileNow(){
        
        var height:CGFloat = 0
        
        var heightThreshold:CGFloat = 0
        
        var widthForFont:CGFloat = 0
        
        if SCREEN_WIDTH <= 320 {
            widthForFont = 260
        }
        else{
            widthForFont = 320
        }
        
        var aboutMeHeight:CGFloat = 0
        if profileData?.personalQuote != nil && profileData?.personalQuote?.count>0{
            aboutMeHeight = heightForView((profileData?.personalQuote)!, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: SCREEN_WIDTH - 40) + 50
        }
        else if profileData?.about != nil && profileData?.about?.count>0{
            aboutMeHeight = heightForView((profileData?.about)!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: SCREEN_WIDTH - 40) + 50
        }
        
        if(aboutMeHeight == 0.0 && Int(profileData?.profileCompletenessScore ?? "0")! < 100)
        {
            aboutMeHeight = 50.0
        }
        
        var crushHeight:CGFloat = 0
        
        if profileData?.crushText != nil{
            crushHeight = heightForView(profileData?.crushText as! String, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: widthForFont - 20) + 65
        }
        
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            heightThreshold = 138
        }
        else{
            heightThreshold = 188
        }
        
        let aboutMeHeightRoundOff:Int = Int(aboutMeHeight)
        let crushHeightRoundOff:Int = Int(crushHeight)
        
        let finalAboutMeHeightRoundOff:CGFloat = CGFloat(aboutMeHeightRoundOff)
        let finalCrushHeightRoundOff:CGFloat = CGFloat(crushHeightRoundOff)
        
        if !isMyProfile {
            
            if checkIfUserHasVisitedProfileFromChat(){
                if profileData?.crushText.length>0{
                    height = UIScreen.main.bounds.size.height + finalCrushHeightRoundOff - heightThreshold
                }else{
                    height = UIScreen.main.bounds.size.height - heightThreshold
                }
            }
            else{
            if profileData?.crushText.length>0{
                height = UIScreen.main.bounds.size.height + finalCrushHeightRoundOff - heightThreshold
            }
            else if profileData?.personalQuote != nil && profileData?.personalQuote?.count>0{
                height = UIScreen.main.bounds.size.height + finalAboutMeHeightRoundOff - heightThreshold
            }
            else if profileData?.about != nil && profileData?.about?.count>0{
                height = UIScreen.main.bounds.size.height + finalAboutMeHeightRoundOff - heightThreshold
            }
            else{
                height = (UIScreen.main.bounds.size.height - heightThreshold) + 20
            }
            }
            
        }
        else{
            height = UIScreen.main.bounds.size.height + finalAboutMeHeightRoundOff + 20 - heightThreshold
        }
        
        let width:CGFloat = UIScreen.main.bounds.size.width
        
        var extraPadding:CGFloat = 0
        if isViewPushed{
            extraPadding = 20
        }
        
        profileDetailTableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        
        profileDetailTableView.contentOffset = CGPoint(x: 0, y: -height);
        
        if profileDeckObject == nil{
            profileDeckObject = ProfileDeckView.init(frame: CGRect(x: 0, y: -height - extraPadding, width: width, height: height))
            profileDetailTableView.addSubview(profileDeckObject!)
            profileDetailTableView.sendSubviewToBack(profileDeckObject!)
        }
        else{
            self.profileDeckObject?.frame.origin.y = -height
            self.profileDeckObject?.frame.size.height = height
        }
        if checkIfUserHasVisitedProfileFromChat(){
            profileDeckObject?.isShownThroughChat = true
        }
        
        profileDeckObject?.profileDetails = profileData
        
        profileDeckObject?.hadAlreadyBeenShownInDiscover = true
        
        //        if detailProfileParentTypeOfView == DetailProfileViewParent.Discover {
        //            profileDeckObject?.animateViewComponent = true
        //        }
        
        if isMyProfile {
            profileDeckObject!.editProfileButton.addTarget(self, action: #selector(ProfileDeckDetailViewController.openEditProfile), for: UIControl.Event.touchUpInside)
            editProfileHeaderButton.addTarget(self, action: #selector(ProfileDeckDetailViewController.openEditProfile), for: UIControl.Event.touchUpInside)
        }
        
        
        if profileData?.crushText.length > 0 { // Marking profile as read in Crush Dashboard
            
            let crushObj : CrushesDashboard = CrushesDashboard.getDataCorCrush(withUserID: (profileData?.wooId)!)
            sendCrushButton.isSelected = true
            CrushesDashboard.markCrush(asRead: crushObj, withCompletionHandler: nil)
        }
        else{
            sendCrushButton.isSelected = false
        }
        profileDeckObject?.getTappedIndexForGallery =  {(val1: Int) in
            self.closeDetailViewController(self.backOrCloseButton)
        }
        
        profileDeckObject?.closeDetailViewControllerHandler = {() in
            self.closeDetailViewController(self.backOrCloseButton)
            
        }
        
        profileDeckObject?.closeTagPopupHandler = {() in
            self.dismissTagTraningView(Any.self)
        }
        if isComingFromDiscover == true || didCameFromChat {
            profileDeckObject?.alpha = 0
            isComingFromDiscover = false
        }
        if detailProfileParentTypeOfView == DetailProfileViewParent.discover {
            profileDeckObject?.isLoadedNotFromDiscover = false
        }
        else
        {
            profileDeckObject?.isLoadedNotFromDiscover = true
        }
        
        profileDeckObject!.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
        profileDeckObject!.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
        profileDeckObject!.myProfileBottomViewTrailingConstraint.constant = 0
        profileDeckObject!.myProfileBottomViewLeadingConstraint.constant = 0
            profileDeckObject?.cameFromChat = didCameFromChat

        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            profileDeckObject!.gettingUsedInTagSearch = true
            profileDeckObject!.setDataForProfileView(false)
        }
        else{
            if isMyProfile {
                profileDeckObject!.setDataForProfileView(true)
            }
            else{
                profileDeckObject!.setDataForProfileView(false)
            }
        }
        
        profileDetailTableView.isScrollEnabled = false
        profileDeckObject?.popularBadgeAlreadyMoved.toggle()
        profileDeckObject?.needToBeShownOrHiddenToBeCompatibleWithProfileDetailView()
        
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            if discoverSnapShot != nil {
                self.profileSnapShotImageView.image = discoverSnapShot
                self.profileSnapShotView.isHidden = false
                self.perform(#selector(clearSnapShot), with: nil, afterDelay: 0.5)
            }
            else{
                clearSnapShot()
            }
            //self.perform(#selector(nowHideProfileDeckViews), with: nil, afterDelay: 0.4)
            //profileDetailTableView.backgroundColor = UIColor.white
            //nowHideProfileDeckViews()
        }
        else{
            //self.perform(#selector(nowHideProfileDeckViews), with: nil, afterDelay: 0.4)
        }
        if detailProfileParentTypeOfView == DetailProfileViewParent.discover || detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch{
            self.perform(#selector(nowHideProfileDeckViews), with: nil, afterDelay: 0.2)
        }
        else{
            self.perform(#selector(nowHideProfileDeckViews), with: nil, afterDelay: 0.4)
        }
        
        lastOffSetLocation = (0 - height);
        //Setting FirstName
        setNameAgeText()
        //Setting HeightLocation Text
        setHeightLocationText()
    }
    
    func setNameAgeText()
    {
        //Setting FirstName
        var lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 16.0)! ]
        var firstName = ""
        if isMyProfile {
            if let nameAgeString = (profileData as? MyProfileModel)?.myName() {
                firstName = nameAgeString
            }
        }
        else{
            if let nameAgeString = profileData?.firstName {
                firstName = nameAgeString
            }
        }
        
        if firstName.count > 0 {
            let lString = NSMutableAttributedString(string: (firstName), attributes: lAttribute )
            if let ageString = profileData?.age {
                lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 16.0)! ]
                let attrString = NSAttributedString(string: ", " + String(ageString), attributes: lAttribute )
                lString.append(attrString)
            }
            self.NameAgeLabel.attributedText = lString
        }
        
    }
    @IBAction func tapPerformedForBottomViews(_ sender: Any) {
        
    }
    
    @objc func clearSnapShot(){
        self.profileSnapShotImageView.image = nil
        self.profileSnapShotView.isHidden = true
    }
    
    @objc func takeSnapShotOfProfileDeck(){
        let rect: CGRect = self.profileDeckObject!.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.profileDeckObject!.layer.render(in: context)
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        self.discoverSnapShot = capturedImage
        UIGraphicsEndImageContext()
    }
    
    func setHeightLocationText() {
        if (visitorData != nil) && ((visitorData?.commonTagDto?.value(forKey: "isFake")) != nil){
            profileData?.location = visitorData?.commonTagDto?.value(forKey: "name") as? NSString
        }
        var heightText = ""
        var locationText = ""
        if let height = profileData?.height {
            locationLabelCenterXConstraint.constant = 12
            if isMyProfile == true  && profileData!.showHeightType == HeightUnit.CM{
                if let cmValue  = (Utilities.sharedUtility() as AnyObject).getCentimeterFromFeetInches(height) {
                    heightLabelWidthConstraint.constant = 50
                    heightText = cmValue + " cm"
                }
                else{
                    heightLabelWidthConstraint.constant = 32
                    heightText = height
                }
            }
            else{
                heightLabelWidthConstraint.constant = 32
                heightText = height
            }
            self.view.layoutIfNeeded()
        }
        else{
            locationLabelCenterXConstraint.constant = 0
            heightLabelWidthConstraint.constant = 0
        }
        
        let textArray = heightText.components(separatedBy:  "\'")
        
        if textArray.count>1 {
            heightText = textArray[0] + "'" + textArray[1]
        }
        if let location = profileData?.location {
            if location.length > 0{
            if heightText.count > 0  {
                if ((WooGlobeModel.sharedInstance().isExpired == false) && (WooGlobeModel.sharedInstance().wooGlobleOption == true) && (WooGlobeModel.sharedInstance().locationOption == true)) {
                    heightText = heightText + ", "
                }
                else{
                    heightText = heightText + ","
                    
                }
            }
            let trimmedString = (location as String).trimmingCharacters(in: .whitespaces)
            locationText = " " + trimmedString + " "
            }
        }
        else{
            locationLabel.backgroundColor = UIColor.clear
        }
        
        if ((WooGlobeModel.sharedInstance().isExpired == false) && (WooGlobeModel.sharedInstance().wooGlobleOption == true) && (WooGlobeModel.sharedInstance().locationOption == true)) {
            if DiscoverProfileCollection.sharedInstance.collectionMode == CollectionMode.my_PROFILE {
                locationLabel.backgroundColor = UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
            else{
                locationLabel.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
            
            if isMyProfile == true{
                if DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation.count > 0 {
                    locationText = NSLocalizedString(" Swiping in ", comment: "") + (DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation)! + " "
                }
            }
            else{
                if profileData?.diasporaLocation.count > 0 {
                    locationText = NSLocalizedString(" Swiping in ", comment: "") + (profileData?.diasporaLocation)! + " "
                }
            }
        }
        else{
            locationLabel.backgroundColor = UIColor.clear
        }
        
        let locationTextTrunctated = locationText.replacingOccurrences(of: " ", with: "")
        if locationTextTrunctated.count > 0{
            locationLabel.text = locationText
        }
        else{
            locationLabel.text = ""
            locationLabel.backgroundColor = UIColor.clear
        }
        
        if isMyProfile == false{
            if profileData?.diasporaLocationNearYou == true {
                locationText = NSLocalizedString(" Swiping near you ", comment: "")
                locationLabel.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            }
        }
        
        heightLabel.alpha = 1
        locationLabel.alpha = 1
        heightLabel.text = heightText
        locationLabel.text = locationText
    }
    
    @objc fileprivate func updatePageControlYNow(){
        profileDeckObject?.imageGalleryView?.pageControlObj.removeFromSuperview()
        profileDeckObject?.imageGalleryView?.createAddPageControlNow(withFrame: (profileDeckObject?.ProfileDeckMainContainerViewHeightConstraint.constant)! - 45, with: (profileDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.profileDeckObject?.imageGalleryView?.pageControlObj.alpha = 1
        })
    }
    
    func showFullScreenGalleryView(_ makeItFull:Bool){
        
        if makeItFull == true {
            self.needToMakeGallerySmall = true
            profileDeckObject?.imageGalleryView?.isAllowedToTapNow = false
            self.backOrCloseButton.isSelected = true
            createATempImageViewToShowForRemovingFlickerWhileItIsBigOrSmall(false)
            self.actionButtonContainerView.isHidden = true
            self.perform(#selector(self.needToMakeProfileDeckBig), with: nil, afterDelay: 0.2)
            
            hideWithAnimation(view: (profileDeckObject?.badgeView)!, isHide: true, animatingTime: 0.4)
        }
        else{
            if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
                self.actionButtonContainerView.isHidden = false
            }
            else{
                if isMyProfile || isActionButtonHidden{
                    actionButtonContainerView.isHidden = true
                }
                else{
                    actionButtonContainerView.isHidden = false
                }
            }
            
            self.backOrCloseButton.isSelected = false
            profileDeckObject?.imageGalleryView?.isAllowedToTapNow = false
            createATempImageViewToShowForRemovingFlickerWhileItIsBigOrSmall(true)
            self.perform(#selector(needToMakeProfileDeckBackToSameSize), with: nil, afterDelay: 0.2)
            hideWithAnimation(view: (profileDeckObject?.badgeView)!, isHide: false, animatingTime: 0.4)
        }
    }
    
    @objc func nowMoveBackToDiscover(){
        
        
        
        if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
            
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName:"Onboard_MyProfile_BackToDC")
        }
        else{
            if DiscoverProfileCollection.sharedInstance.discoverModelCollection.count > 0{
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
            }
            else{
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover_EMPTY)
            }
        }
        
        if isViewPushed {
            let _ =  self.navigationController?.popViewController(animated: true)

            var photoCount = 0
            if isMyProfile{
                if let approvedCount = profileData?.wooAlbum?.countOfApprovedPhotos(){
                    photoCount = approvedCount
                }
            }
            else{
                if let totalCount = profileData?.wooAlbum?.count(){
                    photoCount = totalCount
                    /*
                if profileData?.wooAlbum != nil{
                    photoCount = (profileData?.wooAlbum?.countOfApprovedPhotos())!
                }
                */
            }
            else{
                if profileData?.wooAlbum != nil{
                    photoCount = (profileData?.wooAlbum?.count())!
                }
            }
            if photoCount > 0{
                if ((profileDeckObject?.imageGalleryView) != nil) {
                    //profileData?.wooAlbum?.moveItemToFront((profileDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                }
                if isMyProfile{
                currentShownImageUrl = profileData?.wooAlbum?.approvedObjectAtIndex(0)?.url
                }
                else{
                currentShownImageUrl = profileData?.wooAlbum?.objectAtIndex(0)?.url
                }
                if let localShownImageUrl = self.currentShownImageUrl{
                    
                    if self.dismissHandler != nil{
                        self.dismissHandler(localShownImageUrl, self.backActivity, self.crushToBeSent as String, self.profileData!, onBoardingEditProfileDone, selectedIndexPath)
                    }
                    else if (self.dismissHandlerObjC != nil) {
                        
                        self.dismissHandlerObjC(self.backActivity.rawValue, self.crushToBeSent as String, self.profileData!)
                        
                    }
                }
                else{
                    self.dismissHandler("",self.backActivity, self.crushToBeSent as String, self.profileData!, onBoardingEditProfileDone, selectedIndexPath)
                }
                
            }
            else{
                    if self.dismissHandlerObjC != nil{
                        self.dismissHandlerObjC(self.backActivity.rawValue, self.crushToBeSent as String, self.profileData!)
                    }
                    
                    if self.dismissHandler != nil{
                        self.dismissHandler("",self.backActivity, self.crushToBeSent as String, self.profileData!, onBoardingEditProfileDone, selectedIndexPath)
                    }
            }
            }
            
            

        }
        else{
            var photoCount = 0
            if isMyProfile{
                photoCount = (profileData?.wooAlbum?.countOfApprovedPhotos()) ?? 0
            }
            else{
                photoCount = (profileData?.wooAlbum?.count()) ?? 0
            }
            if photoCount > 0{
                if ((profileDeckObject?.imageGalleryView) != nil) {
                    profileData?.wooAlbum?.moveItemToFront((profileDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                }
                if isMyProfile{
                    currentShownImageUrl = profileData?.wooAlbum?.approvedObjectAtIndex(0)?.url
                }
                else{
                    currentShownImageUrl = profileData?.wooAlbum?.objectAtIndex(0)?.url
                }
                if discoverProfileDeckViewObject != nil {
                    discoverProfileDeckViewObject?.setProfileImageForUser(URL(string: currentShownImageUrl! as String), userGender: discoverProfileDeckViewObject?.profileDetails?.gender)
                }
                
                let _ =  self.navigationController?.popViewController(animated: true)

//                self.dismiss(animated: false, completion: {
                    if let localShownImageUrl = self.currentShownImageUrl{
                        if self.dismissHandler != nil{
                            self.dismissHandler(localShownImageUrl, self.backActivity, self.crushToBeSent as String, self.profileData!, self.onBoardingEditProfileDone, selectedIndexPath)
                            self.onBoardingEditProfileDone = false
                        }
                    }
                    else{
                        self.dismissHandler("",self.backActivity, self.crushToBeSent as String, self.profileData!, self.onBoardingEditProfileDone, selectedIndexPath)
                        self.onBoardingEditProfileDone = false
                    }
//                })
            }
            else{
                let _ =  self.navigationController?.popViewController(animated: true)

                    if self.dismissHandlerObjC != nil{
                        if let profile = self.profileData{
                        self.dismissHandlerObjC(self.backActivity.rawValue, self.crushToBeSent as String, profile)
                        }
                    }
                    
                    if self.dismissHandler != nil{
                        if let profile = self.profileData{
                        self.dismissHandler("",self.backActivity, self.crushToBeSent as String, profile, self.onBoardingEditProfileDone, selectedIndexPath)
                        }
                    }
            }
        }
    }
    
    @objc func nowHideProfileDeckViews(){
        profileDetailTableView.isScrollEnabled = true
        profileDeckObject?.alpha = 1
        profileDeckObject?.commonalityTagsView.isHidden = true
        
        profileDetailTableView.backgroundColor = UIColor.white
        
        //self.view.bringSubview(toFront: profileDetailHeaderView)

    }
    
    func nowHideInitalProfileDeckViews(){
        profileDetailTableView.isScrollEnabled = true
        profileDetailTableView.backgroundColor = UIColor.white
        profileDetailTableView.isHidden = false
        DispatchQueue.main.async(execute: {
            self.dataLoader.stopAnimating()
            self.dataLoader.isHidden = true
        })
        if didCameFromChat{
            self.perform(#selector(nowHideInitialProfileView), with: nil, afterDelay: 0.4)
        }
        else{
            nowHideInitialProfileView()
        }
    }
    
    @objc func downloadFirstImageForProfile(){
        var photoCount = 0
        if isMyProfile{
            photoCount = (profileData?.wooAlbum?.countOfApprovedPhotos())!
        }
        else{
            photoCount = (profileData?.wooAlbum?.count())!
        }
        if photoCount > 0{
            if isMyProfile{
                if let profileImage = profileData?.wooAlbum?.approvedObjectAtIndex(0){
                    let url:URL = URL(string: profileImage.url!)!
                    SDWebImageManager.shared().loadImage(with: url, options: .retryFailed, progress: { (receivedSize, expectedSize, url) in
                        
                    }, completed: { (image, data, error, cacheType, completed, url) in
                        self.nowHideInitalProfileDeckViews()

                    })
                    
                    
                    //Deprecated
//                    SDWebImageManager.shared().downloadImage(with: url, options: .retryFailed, progress: { (receivedSize, expectedSize) in
//
//                    }, completed: { (image, error, cacheType, finished, imageURL) in
//                        self.nowHideInitalProfileDeckViews()
//                    })
                }
            }
            else{
                if let profileImage = profileData?.wooAlbum?.objectAtIndex(0){
                    let url:URL = URL(string: profileImage.url!)!
                    SDWebImageManager.shared().loadImage(with: url, options: .retryFailed, progress: { (receivedSize, expectedSize, url) in
                        
                    }, completed: { (image, data, error, cacheType, completed, url) in
                        self.nowHideInitalProfileDeckViews()
                    })
//                    SDWebImageManager.shared().downloadImage(with: url, options: .retryFailed, progress: { (receivedSize, expectedSize) in
//
//                    }, completed: { (image, error, cacheType, finished, imageURL) in
//                        self.nowHideInitalProfileDeckViews()
//                    })
                }
            }
        }
        else{
            nowHideInitalProfileDeckViews()
        }
    }
    
    @objc func nowHideInitialProfileView(){
        initialProfileDeckView?.isHidden = true
        initialProfileDeckObject?.removeFromSuperview()
    }
    
    func showActionButtonContainerView(_ showNow:Bool){
        
        if detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
                if showNow == true {
                    if let localActionButtonContainerView = self.actionButtonContainerView{
                        localActionButtonContainerView.isHidden = false
                        localActionButtonContainerView.transform = CGAffineTransform.identity
                    }
                }
                else{
                    if let localActionButtonContainerView = self.actionButtonContainerView{
                        localActionButtonContainerView.transform = CGAffineTransform(translationX: 0, y: 120)
                        localActionButtonContainerView.isHidden = true
                    }
                }
            }) { (true) in
                
            }
        }
        else{
            
            if !isMyProfile && !isActionButtonHidden {
                
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    if showNow == true {
                        if let localActionButtonContainerView = self.actionButtonContainerView{
                            localActionButtonContainerView.isHidden = false
                            localActionButtonContainerView.transform = CGAffineTransform.identity
                        }
                    }
                    else{
                        if let localActionButtonContainerView = self.actionButtonContainerView{
                            localActionButtonContainerView.transform = CGAffineTransform(translationX: 0, y: 120)
                            localActionButtonContainerView.isHidden = true
                        }
                    }
                }) { (true) in
                    
                }
            }
            else{
                if let localActionButtonContainerView = self.actionButtonContainerView{
                    localActionButtonContainerView.isHidden = true
                }
            }
        }
    }
    
    /**
     * Show Report UserView with option and buttons
     */
    func startReporting(_ isQuestionReporting : Bool) {
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        let reportView: ReportUserView = ReportUserView(frame: self.view.frame)
        reportView.textView.placeholder = NSLocalizedString("Additional information", comment: "Additional information")
        reportView.reportViewType = reportUser
        reportView.reportedViewController = self
        reportView.setHeaderForReport(reportUser)
        reportView.delegate = self
        reportView.selectorForUserFlagged = #selector(ProfileDeckDetailViewController.showUserReportedAnimation)
        reportView.userToBeFlagged = "\((profileData?.wooId)!)"
        
        if isQuestionReporting {
            reportView.reportingUserFromAnswer = true
        }
        
        if MyMatches.getMatchDetail(forMatchedUSerID: "\((profileData?.wooId)!)", isApplozic: false) != nil {
            reportView.isAlreadMatched = true
        }
        else {
            reportView.isAlreadMatched = false
        }
        if UIDevice.current.systemVersion.compare("9.0",
                                                  options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending {
            self.view!.addSubview(reportView)
        }
        else {
            UIApplication.shared.delegate!.window!!.addSubview(reportView)
        }
    }
    
    /**
     * Shows the Animation for Report User
     */
    @objc fileprivate func showUserReportedAnimation(){
        
        backActivity = PerformActionBasedOnActivity.Pass
        
        if detailProfileParentTypeOfView == DetailProfileViewParent.discover {
            Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: self.profileData!.wooId!, shouldDeleteFromAnswer: true, withCompletionHandler:nil)
            self.reportUserDeletion()
        }
        else{
            Utilities().deleteMatchUser(fromAppExceptMatchBox: self.profileData!.wooId!, shouldDeleteFromAnswer: true, withCompletionHandler:{
                (iscompleted) in
                self.reportUserDeletion()
            })
        }
        
    }
    
    func reportUserDeletion(){
        MyMatches.deleteMatch(forMatchedUserId: self.profileData!.wooId!, withDeletionCompletionHandler:{(success) in
            DispatchQueue.main.async {
                self.needToMakeGallerySmall = false
                if(self.didCameFromChat)
                {
                  let _ =  self.navigationController?.popToRootViewController(animated: true)
                }
                else
                {
                    self.closeDetailViewController(UIButton())
                }
                self.isUserReported = true
                /*
                let snackBarObj: MDSnackbar = MDSnackbar(text:NSLocalizedString("User reported", comment: "User Reported!"), actionTitle: "", duration: 1.0)
                snackBarObj.multiline = true
                snackBarObj.show()
                */
            }
        })

    }
    
    fileprivate func showOutOfLikeAlert(){
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup")
        
        let outOfLikePopup = OutOfLikeView.showView(parentViewController: self)
        outOfLikePopup.buttonPressHandler = {
            //More Info
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            
            // Srwve Event
            DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_OutOfLikesPopup_MoreInfo")
            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
            purchaseObj.purchaseShownOnViewController = self
            purchaseObj.initiatedView = "Outoflikes_getwooplus"
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Outoflikes_getwooplus")
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
            purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                if WooPlusModel.sharedInstance().isExpired == false {
                    self.checkForLikeLimit()
                }
                
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                    DispatchQueue.main.async
                        {
                            if WooPlusModel.sharedInstance().isExpired == false {
                                self.checkForLikeLimit()
                            }
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }

        }
    }
    
    func perforAfterLikeActivities() {
        // set already liked flag true
        self.isAlreadyLiked = true
        // update like meter according to new today-like count
        self.checkForLikeLimit()
        //disable like button
        //        self.likeButton.enabled = false
        self.likeButton.isUserInteractionEnabled = false
        self.likeButton.setImage(UIImage(named: "like3.0_disabled"), for: UIControl.State())
        
        //dissable pass button
        //        self.passButton.enabled = false
        self.passButton.isUserInteractionEnabled = false
        self.passButton.setImage(UIImage(named: "dislike3.0_disabled"), for: UIControl.State())
        //set backActivity as liked so that after going back to Discover Screen, Card should swipe right to like
        if self.backActivity != PerformActionBasedOnActivity.CrushSent {
            self.backActivity = PerformActionBasedOnActivity.Like
        }
    }
    
    fileprivate func checkForLikeLimit() {
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE" &&
            WooPlusModel.sharedInstance().isExpired{
            likeButton.setProgressbarVisible(true)
            likeButton.progressValue = CGFloat(AppLaunchModel.sharedInstance().likeCount)/CGFloat(AppLaunchModel.sharedInstance().maxLikeToShowLikeMeter)*100.0
        }
        else{
            likeButton.setProgressbarVisible(false)
        }
    }
    
    fileprivate func isLikeLimitReached() -> Bool {
        if checkIfUserWillSeeOutOfLikeAlert() && !isAlreadyLiked {
            self.showOutOfLikeAlert()
            return true
        }
        return false
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
    
    func showUnMatchOptions(){
        let reportView:ReportUserView = ReportUserView(frame: self.view.bounds)
        reportView.setHeaderForReport(ReportViewType(rawValue: 1))
        reportView.reportViewType = ReportViewType(rawValue: 1)
        reportView.reportedViewController = self
        reportView.delegate = self
        reportView.reasonsDelegate = self
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        window.addSubview(reportView)
    }
    
    func informServerAboutDeletionOfMatch(_ comment:String){
        if let profileID = profileData?.wooId{
            if let myMatchesObject = MyMatches.getMatchDetail(forMatchedUSerID: profileID, isApplozic: false){
                CrushAPIClass.deleteMatch(withMatchID: myMatchesObject, withCommentForUnmatch: comment) { (success) in
                    
                }
                
                MyMatches.deleteMatch(forMatchedUserId: myMatchesObject.matchedUserId) { (success) in
                    ChatMessage.deleteMessages(forChatRoom: myMatchesObject.matchId)
                    let viewControllers = self.navigationController?.viewControllers
                    for viewController in viewControllers!{
                        if viewController is MatchBoxViewController{
                            self.navigationController?.popToViewController(viewController, animated: true)
                            break
                        }
                    }
                }
            }
        }
//        if let conversation = conversation
//        {
//            leaveConversation(conversation)
//        }
    }
    
    
//    func leaveConversation(_ conversation:LYRConversation)
//    {
//            var error : NSError?;
//            let val = (conversation as LYRConversation).leave(&error)
//            if(val == false && error != nil)
//            {
//                print("Error leaving conversation \(error?.localizedDescription)")
//            }
//
//    }
    
    //MARK: Utility Methods
    
    /**
     * Calculates the height of a lable for given text
     * - parameter text : Given text
     * - parameter font : Font for the given text
     * - parameter width : Width of the label
     * - returns: Height for the given text
     */
    fileprivate func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func sizeForView(_ text:String, font:UIFont, height:CGFloat, type:String) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        if type != "FACEBOOK_LIKES" {
            return CGSize(width: label.frame.size.width + 36 + 10, height: 32)
        }
        else{
            return CGSize(width: label.frame.size.width + 36 + 10 + 34, height: 32)
        }
    }
    
    func calculateTagCellHeight(_ array:[TagModel]) -> CGFloat {
        var height : CGFloat = 0.0
        let font = UIFont(name: "Lato-Regular", size: 16.0)!
        var rowWidth : CGFloat = 10.0
        var numberOfRows  : CGFloat = 1.0
        for model in array {
            let tagWidth = sizeForView(model.name!, font: font, height: 32.0, type: model.type!).width
            rowWidth = rowWidth + tagWidth + 10
            if rowWidth > (UIScreen.main.bounds.width - 54) {
                rowWidth = 10.0 + tagWidth
                numberOfRows += 1
            }
        }
        height = numberOfRows * 32.0 + 10.0 * (numberOfRows + 1)
        
        return height
    }
    
    
    func calculateActorTargetCellHeight(_ questionModel : TargetQuestionModel) -> CGFloat {
        let topPaddingHeight : CGFloat = 20.0
        let topContainerHeight : CGFloat = 36.0
        let questionHeight : CGFloat = 10.0 + heightForView(questionModel.question, font: UIFont(name: "Lato-Regular", size: 20.0)!, width: 320 - 64)
        let thinLineHeight : CGFloat = 16 + 1
        var answerContainerViewHeight : CGFloat = 0.0
        if questionModel.answer.count > 0 {
            answerContainerViewHeight += heightForView(questionModel.answer, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: 320 - 64 - 32)
        }
        let bottomContainerHeight : CGFloat = 16 + 40
        let bottomPadding : CGFloat = 20.0 + 10.0 + 10.0 + 5.0
        
        return (topPaddingHeight + topContainerHeight + questionHeight + thinLineHeight + answerContainerViewHeight + bottomContainerHeight + bottomPadding)
    }
    
    func calculateTargetCellHeight(_ questionModel : TargetQuestionModel) -> CGFloat {
       
        let topPaddingHeight : CGFloat = 16.0 + 0

        var questionHeight : CGFloat = heightForView(questionModel.question, font: UIFont(name: "Lato-Regular", size: 18.0)!, width: 320 - 64)
        if questionHeight < 20 {
            questionHeight = 20
        }
        let thinLineHeight : CGFloat = 16 + 1
        
        var answerContainerViewHeight : CGFloat = 48.0

        if self.didCameFromChat == true {
            answerContainerViewHeight = 0.0
        }
        if questionModel.answer.count > 0 {
            answerContainerViewHeight = 84.0
            answerContainerViewHeight += 10.0
            answerContainerViewHeight += heightForView(questionModel.answer, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: 320 - 64)
            answerContainerViewHeight += 20
        }
        let bottomPadding : CGFloat = 10.0 + 5.0
        
        return (topPaddingHeight + questionHeight + thinLineHeight + answerContainerViewHeight + bottomPadding)
    }
    
    func calculateHeightForEthnicityRow() -> CGFloat{
        var extraWidth:CGFloat = 40.0 //image's width
        var ethnicitStr = ""
        if isMyProfile == true
       {
             ethnicitStr = "I am "
            for ethItem in (self.profileData?.ethnicity)! {
                if ethItem.isSelected == true {
                    extraWidth += 14
                }
                ethnicitStr =  ethnicitStr + ethItem.name!
            }
        
            ethnicitStr = ethnicitStr + "and Proud"
        }
        else
        {
            ethnicitStr = self.profileData?.ethnicityText ?? ""
        }
    
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 48))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Lato-Regular", size: 18.0)!
        label.text = ethnicitStr
        
        label.sizeToFit()
        
        if (label.frame.size.width + extraWidth) > UIWindow().frame.size.width - 50 {
            return 75
        }
        return 85.0
    }
    
    //MARK: Cell Creating Methods
    func createAboutMeCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AboutMeCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutMeCell)!
        
        if cell == nil {
            cell = AboutMeCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.setAboutMeText(cellData["text"] as! String)
        return cell!
    }
    
    func createQuotationCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : QuotationCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? QuotationCell)!
        
        if cell == nil {
            cell = QuotationCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.setPersonalQouteText(cellData["text"] as! String)
        return cell!
    }
    
    func createAboutHeaderCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        let subType = cellData["subtype"] as! String
        var cell : AboutHeaderCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutHeaderCell)!
        
        var personalQouteText = ""
        if let personalQoute = profileData?.personalQuote{
            personalQouteText = personalQoute
        }
        else{
            if let aboutmeText = profileData?.about{
                personalQouteText = aboutmeText
            }
        }
        
        if cell == nil {
            cell = AboutHeaderCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        if subType == "Friends" {
            if profileData?.myQuestionsArray.count > 1{
                cell?.separatorView.isHidden = true
            }
        }
        cell?.contentView.backgroundColor = UIColor.white

        cell!.setHeaderText(cellData["text"] as! String)
        return cell!
    }
    
    func createLinkedInPhoneCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : LinkedInPhoneVerifyCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? LinkedInPhoneVerifyCell)!
        
        if cell == nil {
            cell = LinkedInPhoneVerifyCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        if (cellData["subType"] as! String) == "LinkedIn" {
            cell!.setType(LPCellType.linkedIn)
        }
        else if (cellData["subType"] as! String) == "Phone" {
            cell!.setType(LPCellType.phone)
        }
        else{
            cell?.setType(.both)
        }
        return cell!
    }
    
    func createRoundedImageCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : RoundedImageCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? RoundedImageCell)!
        
        if cell == nil {
            cell = RoundedImageCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.setDataOnCellWithImagesDictionary(cellData["data"] as! [AnyObject])
        return cell!
    }
    
    func createTagCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        _ = cellData["subtype"] as! String
        var cell : TagCell? = (tableView.dequeueReusableCell(withIdentifier: "TagCell") as? TagCell)!
        
        
        let myRect:CGRect = tableView.rectForRow(at: indexPath)
        
        if UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown){
        if tagTrainingHasBeenShowed == false{
            
            if (UserDefaults.standard.value(forKey: "tagTrainingShowExpiry") == nil) {
                let expiryNumber = 1
                UserDefaults.standard.setValue(expiryNumber, forKey: "tagTrainingShowExpiry")
                UserDefaults.standard.synchronize()
            }
            var expiryNumber:Int = UserDefaults.standard.value(forKey: "tagTrainingShowExpiry") as! Int
            
            if expiryNumber >= 1 && expiryNumber <= 3 {
                if tagTrainingPopupOject == nil {
                    expiryNumber += 1
                    UserDefaults.standard.setValue(expiryNumber, forKey: "tagTrainingShowExpiry")
                    UserDefaults.standard.synchronize()
                    tagTrainingHasBeenShowed = true
                    tagTrainingPopupOject = TagTrainingPopupView.loadViewFromNib(frame: CGRect(x: 10,y: myRect.origin.y - 100, width: 170, height: 110))
                    tableView.addSubview(tagTrainingPopupOject!)
                    tableView.bringSubviewToFront(tagTrainingPopupOject!)
                    tagTrainingPopupOject?.alpha = 0
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        self.tagTrainingPopupOject?.alpha = 1
                    })
                }
            }
        }
        }
        
        
        if cell == nil {
            cell = TagCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        if UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
            cell?.getTappedTagHandler = {
                (tagModel:TagModel) -> Void in
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    return
                }
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_TagSearch")
                
                
                
                
                if self.detailProfileParentTypeOfView == DetailProfileViewParent.tagSearch {
                    DiscoverProfileCollection.sharedInstance.selectedTagData = tagModel
                    if (DiscoverProfileCollection.sharedInstance.selectedUserTagWooID == nil || DiscoverProfileCollection.sharedInstance.selectedUserTagWooID?.count <= 0) {
                        if let wooId = self.profileData?.wooId {
                            DiscoverProfileCollection.sharedInstance.selectedUserTagWooID = wooId
                        }
                    }
                    else{
                        if let wooId = self.profileData?.wooId {
                            DiscoverProfileCollection.sharedInstance.selectedUserTagWooID = DiscoverProfileCollection.sharedInstance.selectedUserTagWooID! + "," + wooId
                        }
                    }
                    DiscoverProfileCollection.sharedInstance.searchModelCollection.removeAllObjects()
                    self.nowMoveBackToDiscover()
                }
                else{
                    DiscoverProfileCollection.sharedInstance.selectedTagData = tagModel
                    if (DiscoverProfileCollection.sharedInstance.selectedUserTagWooID == nil || DiscoverProfileCollection.sharedInstance.selectedUserTagWooID?.count <= 0) {
                        if let wooId = self.profileData?.wooId {
                            DiscoverProfileCollection.sharedInstance.selectedUserTagWooID = wooId
                        }
                    }
                    else{
                        if let wooId = self.profileData?.wooId {
                            DiscoverProfileCollection.sharedInstance.selectedUserTagWooID = DiscoverProfileCollection.sharedInstance.selectedUserTagWooID! + "," + wooId
                        }
                    }
                    
                    DiscoverProfileCollection.sharedInstance.searchModelCollection.removeAllObjects()
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let tagSearchViewController =
                        storyboard.instantiateViewController(withIdentifier: kTagsSearchViewController)
                            as? TagSearchViewController
                    if self.isMyProfile {
                        tagSearchViewController?.tagSearchHasBeenPerformedFromDiscover = false
                        DiscoverProfileCollection.sharedInstance.collectionMode = CollectionMode.discover
                    }
                    else{
                        tagSearchViewController?.tagSearchHasBeenPerformedFromDiscover = true
                    }
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
                    self.navigationController?.pushViewController(tagSearchViewController!, animated: true)
                    //present(tagSearchViewController!, animated: true, completion: nil)
                }
                
            }
        }
        /*
        if(cellSubType == "ctag" || isMyProfile == true)
        {
            cell?.isSubtypeCommonTag = true
        }
        else
        {
            cell?.isSubtypeCommonTag = false
        }
        */
        var personalQouteText = ""
        if let personalQoute = profileData?.personalQuote{
            personalQouteText = personalQoute
        }
        else{
            if let aboutmeText = profileData?.about{
                personalQouteText = aboutmeText
            }
        }
        
        if personalQouteText.count == 0 && (profileData?.profileInfoTags.count == 0 && !(profileData?.isLinkedInVerified)! && !(profileData?.isPhoneVerified)!){
            if profileData?.myQuestionsArray.count == 0{
                cell?.separatorViewTopConstraint.constant = 0
                cell?.separatorViewHeightConstraint.constant = 0
                cell?.separatorViewBottomConstraint.constant = 0
            }
            cell?.separatorView.isHidden = true
        }
        else{
            cell?.separatorView.isHidden = false
            cell?.separatorViewTopConstraint.constant = 9
            cell?.separatorViewHeightConstraint.constant = 1
            cell?.separatorViewBottomConstraint.constant = 20
        }
       
        if profileData?.myQuestionsArray.count > 0{
            cell?.separatorView.isHidden = true
        }
        cell?.tagArray = cellData["data"] as? [TagModel]
        return cell!
    }
    
    func createQuestionCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : QuestionTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? QuestionTableViewCell)!
        
        if cell == nil {
            cell = QuestionTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.answerButtonHandler = {(data: TargetQuestionModel) in
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            if self.isLikeLimitReached(){
                return
            }
            
            self.currentQuestionData = data
            //self.rowValue = (indexPath as NSIndexPath).row
            self.performSegue(withIdentifier: SegueIdentifier.ProfileDeckToWriteAnswerSegue.rawValue,
                              sender: self)
            IQKeyboardManager.shared().isEnabled = false
            IQKeyboardManager.shared().isEnableAutoToolbar = false
        }
        
        if self.didCameFromChat == true {
            cell?.needToHideAnswerButton = true
        }
        cell?.setUserData((cellData["data"] as? TargetQuestionModel)!)
        return cell!
    }
    
    func createProfileInfoTableViewCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : ProfileInfoTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ProfileInfoTableViewCell)!
        
        if cell == nil {
            cell = ProfileInfoTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        var personalQouteText = ""
        if let personalQoute = profileData?.personalQuote{
            personalQouteText = personalQoute
        }
        else{
            if let aboutmeText = profileData?.about{
                personalQouteText = aboutmeText
            }
        }
        
        if personalQouteText.count == 0{
            cell?.separatorView.isHidden = true
            cell?.separatorViewTopConstraint.constant = 0
            cell?.separatorViewHeightConstraint.constant = 0
            if didCameFromChat{
                cell?.separatorViewBottomConstraint.constant = 20
            }
            else{
            cell?.separatorViewBottomConstraint.constant = 0
            }
        }
        else{
            cell?.separatorView.isHidden = false
            cell?.separatorViewTopConstraint.constant = 9
            cell?.separatorViewHeightConstraint.constant = 1
            cell?.separatorViewBottomConstraint.constant = 20
        }
        cell?.profileInfoTagsArray = cellData["data"] as? [ProfileInfoTagModel]
        
        return cell!
    }
    
    func createActorQuestionCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : ActorQuestionTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ActorQuestionTableViewCell)!
        
        if cell == nil {
            cell = ActorQuestionTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.likeButtonHandler = {(data: TargetQuestionModel) in
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            if self.isLikeLimitReached(){
                return
            }
            
            self.perforAfterLikeActivities()
            self.nowMoveBackToDiscover()
            
            return

        }
        
        cell?.optionButtonHandler = {(data: TargetQuestionModel) in
            
            let reportAlertcontroller: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                NSLog("Cancel tapped")
            })
            let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Report as inappropriate",comment: "Report as inappropriate"), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.startReporting(true)
            })
            
            reportAlertcontroller.addAction(cancelAction)
            reportAlertcontroller.addAction(reportAction)
            
            reportAlertcontroller.view!.tintColor = UIColor(red: 22.0 / 255.0, green: 102.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
            self.present(reportAlertcontroller, animated: true, completion: {() -> Void in
                reportAlertcontroller.view!.tintColor = UIColor(red: 22.0 / 255.0, green: 102.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
            })
        }
        
        if isMyProfile{
        cell?.setUserData((cellData["data"] as? TargetQuestionModel)!, userName: (self.profileData?.firstName)!,
                          userAge: (self.profileData?.age)!,
                          imageUrl: (self.profileData?.wooAlbum?.profilePicUrl())!)
        }
        else{
            cell?.setUserData((cellData["data"] as? TargetQuestionModel)!, userName: (self.profileData?.firstName)!,
                              userAge: (self.profileData?.age)!,
                              imageUrl: (self.profileData?.wooAlbum?.discoverProfilePicUrl())!)

        }
        return cell!
    }
    
    func createMyQuestionCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : MyQuestionCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MyQuestionCell)!
        
        if cell == nil {
            cell = MyQuestionCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.mangeHandler = {
            //Open My Question
            self.performSegue(withIdentifier: "MyProfileToMyQuestionSegue", sender: self)
        }
        
        return cell!
    }
    
    func createFooterCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = QuestionTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.backgroundColor = UIColor.white
        return cell!
    }
    
    func createReportCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = ReportCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.backgroundColor = UIColor.white
        return cell!
    }
    
    func createQnaDPVCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : QnADPVTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? QnADPVTableViewCell

        if cell == nil {
            cell = QnADPVTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        if cellData["paddingRequired"] as? Bool == false{
            cell?.backgroundViewTopConstraint.constant = 0
            cell?.paddingViewHeightConstraint.constant = 0
        }
        else{
            cell?.backgroundViewTopConstraint.constant = 10
            cell?.paddingViewHeightConstraint.constant = 10
        }
        cell?.setDataForViewBasedOnModel(cellData["data"] as? TargetQuestionModel ?? TargetQuestionModel())
        
        return cell!
    }
    
    func createChatTypeCell(_ cellData:NSDictionary, tableView: UITableView,indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = cellData["type"] as! String
        let cellSubtype = cellData["subtype"] as! String

        var cell : ChatTypeCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ChatTypeCell
        if cell == nil {
            cell = ChatTypeCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.backgroundColor = UIColor.white
        cell?.cellText.text = cellData["text"] as? String
        cell?.cellSubText.text = cellData["subtext"] as? String
        switch cellSubtype {
        case "message":
            cell?.iconImage.image = UIImage(named: "ic_dpv_chat_gradient.png")
            break
        case "call":
            cell?.iconImage.image = UIImage(named: "ic_dpv_call_gradient.png")
            break
        case "unmatch":
            cell?.iconImage.image = UIImage(named: "ic_dpv_unmatch.png")
            break
        case "report":
            cell?.iconImage.image = UIImage(named: "ic_dpv_block.png")
            break
        default:
            break
        }
        return cell!

    }
    
    func performActionForChatTypeCell(withData cellDict:NSDictionary, indexPath: IndexPath)
    {
        _ = cellDict["type"] as! String
        let cellSubtype = cellDict["subtype"] as! String
        
        switch cellSubtype {
        case "message":
            //also inform the chatVc to show keyboard.
            let _ = self.navigationController?.popViewController(animated: true)
            if popToChatFromSendMessagebjC != nil{
                popToChatFromSendMessagebjC!()
            }
            break
        case "call":
            self.voiceCallingButtonTapped()
            break
        case "unmatch":
            self.showUnMatchOptions()
            break
        case "report":
            self.startReporting(false)
            break
        default:
            break
            
        }
    }
    
    func createEthnicityCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : EthnicityCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? EthnicityCell
        
        if cell == nil {
            cell = EthnicityCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        //        cell?.setEthnicityData(ethnicity: cellData["data"] as! NSArray)
        if(cellData["data"] as! NSArray).count > 0
        {
            cell?.setEthData(ethnicity: cellData["data"] as! NSArray)
            cell?.selectionHandler = { (selectedData, openSelectEhtnicityView) in
                if openSelectEhtnicityView == true {
                    //open ethnicity view
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Onboarding", withEventName: "3-Onboarding.Onboard_MyProfile.OMP_TapEthnicity_Other")
                    self.openEthnicityScreen()
                }
                else
                    {
                    
                    //make ethnicity call
                    //                BrandCardAPI.updateSelectionCardPassStatus(onServer: "Ethnicity", and: "0", andSelectedValues: selectedData)
                    //                BrandCardAPI.updateSelectionCardPassStatus(onServer: "ETHNICITY", and: "0", andSelectedValues: selectedData, withCompletionHandler: { (success) in
                    //                    self.profileDetailTableView.reloadData()
                    //                })
                    
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Onboarding", withEventName: "3-Onboarding.Onboard_MyProfile.OMP_TapEthnicity_Preset")
                    
                    BrandCardAPI.updateSelectionCardPassStatus(onServer: "ETHNICITY", and: "0", andSelectedValues: selectedData, withCompletionHandler: { (success, ethnicityResponse) in
                        let selectedEhtnicity = (self.profileData?.professionModelArrayFromDto((ethnicityResponse as? [[String : AnyObject]])!))!
                        self.profileData?.ethnicity = selectedEhtnicity
                        self.prepareCellDataFromProfile()
                        self.profileDetailTableView.reloadData()
                    })
                    //send selected ethinicity to server
                    //                for ethItem in selectedData {
                    //                    ethItem.isSelected = true
                    //                }
                    //                self.profileDetailTableView.reloadData()
                }
            }
        }
        else
        {
            //
            cell?.setEthString(ethnicity: profileData?.ethnicityText ?? "")
        }
        //        cell?.backgroundColor = UIColor.white
        return cell!
    }
    
    func openEthnicityScreen() {
        let optionScreen = EthnicitySelectionViewController.loadNib()
        optionScreen.mainDataSource = NSArray(contentsOfFile: Bundle.main.path(forResource: "Ethnicity", ofType:"plist")!)!
        optionScreen.maxmimumSelection = 2
        optionScreen.showSwitchButton = false
        if self.profileData?.ethnicity.count > 0 {
            optionScreen.selectedEthnicity = []
            
            for ethItem in (self.profileData?.ethnicity)! {
                if ethItem.isSelected == true {
                    let ethnicityName = ethItem.name
                    optionScreen.selectedEthnicity.append(ethnicityName!)
                }
            }
            
//            for item in (self.profileData?.ethnicity)! {
//                let ethnicityName = item.name
//                optionScreen.selectedEthnicity.append(ethnicityName!)
//            }
        }
        
        optionScreen.selectionHandler = { (selectedData) in
            
            //            for ethItem in selectedData {
            //                ethItem.isSelected = true
            //            }
            let selectedEhtnicity = (self.profileData?.professionModelArrayFromDto((selectedData as? [[String : AnyObject]])!))!
            var currentEthnicityArray = self.profileData?.ethnicity
            for ethItem in selectedEhtnicity {
                ethItem.isSelected = true
            }
            var index = 0
            while index < currentEthnicityArray?.count {
                if selectedEhtnicity.count > index {
                    currentEthnicityArray?[index] = selectedEhtnicity[index].copy()
                }
                index += 1
            }
            self.profileData?.ethnicity = currentEthnicityArray!
            self.prepareCellDataFromProfile()
            self.profileDetailTableView.reloadData()
            
            BrandCardAPI.updateSelectionCardPassStatus(onServer: "ETHNICITY", and: "0", andSelectedValues: selectedEhtnicity, withCompletionHandler: { (success, ethnicityResponse) in
                let selectedEhtnicity = (self.profileData?.professionModelArrayFromDto((ethnicityResponse as? [[String : AnyObject]])!))!
                self.profileData?.ethnicity = selectedEhtnicity
                self.prepareCellDataFromProfile()
                self.profileDetailTableView.reloadData()
            })
            
            //            WooGlobeModel.sharedInstance().ethnicityArray = selectedData
            //            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            
        }
        optionScreen.viewControllerType = EthnicityClassType.TYPE_ETHNICITY
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //present(optionScreen, animated: true, completion: nil)
    }
    
    func checkIfUserHasVisitedProfileFromChat() -> Bool
    {
        let stackCount = ((self.navigationController?.viewControllers.count) ?? 0) - 2
        if(stackCount>=0)
        {
           if(self.navigationController?.viewControllers[stackCount] is NewChatViewController || self.navigationController?.viewControllers[stackCount] is MatchBoxViewController)
           {
            return true;
            }
        }
        return false;
    }
    
    func voiceCallingButtonTapped()
    {
        //Calling button is now enabled for both
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Chatbox_TAPS_ON_ENABLED_CALL_BUTTON_DPV")
        if( (Utilities.sharedUtility() as! Utilities).reachable() == false)
        {
            (Utilities.sharedUtility() as! Utilities).addingNoInternetSnackBar(withText: "No internet connection", withActionTitle: "", withDuration: 3.0)
        }
       
        if(myMatchesData?.isTargetACelebrity == true)
        {
            let celebrityAlert = UIAlertController(title: "Woo", message: "You can only receive a call from a Celebrity match.", preferredStyle: UIAlertController.Style.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            celebrityAlert.addAction(cancelAction)
            self.present(celebrityAlert, animated: true, completion: nil)
            return
        }
        
        if(myMatchesData?.isTargetVoiceCallingEnabled == true)
        {
            if(myMatchesData?.agoraChannelKey != "")
            {
                if((Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == -1)
                {
                    AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                        // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                        if (granted) {
                           // self.informingServerAboutVoiceCallInitiation:kVoiceCallInitiationEvent
                            DispatchQueue.main.async {
                                self.presentVoiceCallVc()
                            }
                        }
                        else
                        {
                            
                        }
                        return
                    })
                }
                else if ((Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == 0)
                {
                    let microphoneAlert = UIAlertController(title: "Woo", message: "To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.", preferredStyle: UIAlertController.Style.alert)
                    
                    let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    microphoneAlert.addAction(cancelAction)
                    
                    let settingsAction:UIAlertAction = UIAlertAction(title: "Settings", style: .default, handler:{
                        (otherButtonAction) in
                        //
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    })
                    microphoneAlert.addAction(settingsAction)
                    self.present(microphoneAlert, animated: true, completion: nil)
                    return

                }
               // self.informingServerAboutVoiceCallInitiation()
                self.presentVoiceCallVc()
            }
            else
            {
                
                AgoraConnectionManager.shared().getChannelKey(forMatchId: self.myMatchesData!.matchId as String, andCompletionBlock: { (response, success) in
                    if(success && ((response as! [String:String])["agora_channel_key"] != nil))
                    {
                         // Update in MyMatches
                        MyMatches.updateMatchedUserDetails(forMatchedUserID: self.myMatchesData!.matchedUserId as String, withAgoraChannelKey: (response as! [String:String])["agora_channel_key"] as String?
                            , withChatUpdationSuccess: { (isUpdationCompleted) in
                                DispatchQueue.main.async {
                                    if((Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == -1)
                                    {
                                        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                                            // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                                            if (granted) {
                                                // self.informingServerAboutVoiceCallInitiation:kVoiceCallInitiationEvent
                                                DispatchQueue.main.async {
                                                    self.presentVoiceCallVc()
                                                }
                                            }
                                            else
                                            {
                                                
                                            }
                                            return
                                        })
                                    }
                                    else if ((Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == 0)
                                    {
                                        let microphoneAlert = UIAlertController(title: "Woo", message: "To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.", preferredStyle: UIAlertController.Style.alert)
                                        
                                        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                        microphoneAlert.addAction(cancelAction)
                                        
                                        let settingsAction:UIAlertAction = UIAlertAction(title: "Settings", style: .default, handler:{
                                            (otherButtonAction) in
                                            //
                                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                                        })
                                        microphoneAlert.addAction(settingsAction)
                                        self.present(microphoneAlert, animated: true, completion: nil)
                                        return
                                        
                                    }
                                    // self.informingServerAboutVoiceCallInitiation()
                                    self.presentVoiceCallVc()
                                }
                        })
                    }
                })
            }
        }
        else
        {
            showVersionUpdateView()
        }

    }
    
    func presentVoiceCallVc()
    {
        let voiceCallVc = self.storyboard?.instantiateViewController(withIdentifier: "VoiceCallingViewController") as! VoiceCallingViewController
        voiceCallVc.matchDetail = self.myMatchesData
        voiceCallVc.currentChannelKey = self.myMatchesData?.agoraChannelKey;
        voiceCallVc.currentChannelId = self.myMatchesData?.matchId;
        self.navigationController?.present(voiceCallVc, animated: true, completion: {
            //Join Channel
            AgoraConnectionManager.shared().joinChannel(withKey: self.myMatchesData?.agoraChannelKey, andMatchId: self.myMatchesData?.matchId)
            AgoraConnectionManager.shared().inviteUser(withAccount: self.myMatchesData?.matchedUserId, andChannelId: self.myMatchesData?.matchId, andHandle: self.myMatchesData?.matchUserName)
        })
    }
    
    func showVersionUpdateView()
    {
        let window  = UIApplication.shared.keyWindow
        let versionUpdateView = Bundle.main.loadNibNamed("VoiceCallingVersionUpdateOverlay", owner: window?.rootViewController, options: nil)?.first as! VoiceCallingVersionUpdateOverlay
        versionUpdateView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        let multiplier =  SCREEN_WIDTH/320.0
        let kConstraintOrignalValue : CGFloat = 14.0
        versionUpdateView.versionUpdateText.font = UIFont(name: "Lato-Regular", size: (multiplier*kConstraintOrignalValue))
        versionUpdateView.versionUpdateText.text = "Please ask \(self.myMatchesData?.matchUserName ?? "") to download the latest version of Woo to receive calls."
        window?.addSubview(versionUpdateView)
    }
    /*
    -(void)showVersionUpdateView
    {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //    NSLog(@"Window subviews %@",window.subviews);
    VoiceCallingVersionUpdateOverlay *versionUpdateView =  [[[NSBundle mainBundle] loadNibNamed:@"VoiceCallingVersionUpdateOverlay" owner:window.rootViewController options:nil] firstObject];
    versionUpdateView.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height);
    CGFloat multiplier = SCREEN_WIDTH/320.0;
    CGFloat kConstraintOrignalValue = 14.0;
    versionUpdateView.versionUpdateText.font = [UIFont fontWithName:kLatoRegular size:(multiplier*kConstraintOrignalValue)];
    versionUpdateView.versionUpdateText.text = [NSString stringWithFormat:NSLocalizedString(@"Please ask %@ to download the latest version of Woo to receive calls.", @"Please ask %@ to download the latest version of Woo to receive calls."),self.myMatchesData.matchUserName];
    [window addSubview:versionUpdateView];
    }
 */
}

//MARK: UITableViewDataSource
extension ProfileDeckDetailViewController: UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userdataArray.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let cell : UITableViewCell
        
        //self.tableViewWrapperView!.alpha = 1

//        UIView.animate(withDuration: 0.25, animations: {
//            self.tableViewWrapperView!.alpha = 1
//        })
        
        let type : CellType = CellType(rawValue: cellDictionary["type"] as! String)!
        
        switch  type{
        case CellType.ChatTypeCell:
            cell = self.createChatTypeCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.AboutHeaderCell:
            cell = self.createAboutHeaderCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.AboutMeCell:
            cell = self.createAboutMeCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.PersonalQouteCell:
            cell = self.createQuotationCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.LinkedInPhoneCell:
            cell = self.createLinkedInPhoneCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.RoundedImageCell:
            cell = self.createRoundedImageCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.TagCell :
            cell = self.createTagCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.QuestionTableViewCell :
            cell = self.createQuestionCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.ActorQuestionTableViewCell :
            cell = self.createActorQuestionCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.MyQuestionCell :
            cell = self.createMyQuestionCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.FooterCell :
            cell = self.createFooterCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.ReportCell :
            cell = self.createReportCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case CellType.EthnicityCell :
                cell = self.createEthnicityCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case .ProfileInfoTableViewCell:
            cell = self.createProfileInfoTableViewCell(cellDictionary, tableView: tableView, indexPath: indexPath)
        case .QnADPVTableViewCell:
            cell = self.createQnaDPVCell(cellDictionary, tableView: tableView, indexPath: indexPath)
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        return cell
    }
}

//MARK: UITableViewDelegate
extension ProfileDeckDetailViewController: UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissTagTraningView(Any.self)
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let type : CellType = CellType(rawValue: cellDictionary["type"] as! String)!
        if type == .ReportCell{
            self.startReporting(false)
        }
        if type == .ChatTypeCell{
            self.performActionForChatTypeCell(withData: cellDictionary, indexPath: indexPath)
        }
    }
    
    
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        var height : CGFloat = 44.0
        
        let type : CellType = CellType(rawValue: cellDictionary["type"] as! String)!
        
        var personalQouteText = ""
        if let personalQoute = profileData?.personalQuote{
            personalQouteText = personalQoute
        }
        else{
            if let aboutmeText = profileData?.about{
                personalQouteText = aboutmeText
            }
        }
        
        switch type {
        case CellType.ChatTypeCell:
            height = 60.0
            break
        case .AboutHeaderCell:
            height = 78.0
            break
        case .AboutMeCell:
            let text = cellDictionary["text"] as! String
            height = heightForView(text, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320.0) + 20.0
            break
        case .LinkedInPhoneCell:
            height = 48.0
            break
        case .RoundedImageCell :
            height = 70.0
            break
        case .TagCell :
            var extraHeight:CGFloat = 30.0
            if (profileData?.personalQuote == nil || profileData?.personalQuote?.count == 0) && (profileData?.profileInfoTags.count == 0 && !(profileData?.isLinkedInVerified)! && !(profileData?.isPhoneVerified)!) && profileData?.myQuestionsArray.count > 1{
                extraHeight = 0.0
            }
            height = self.calculateTagCellHeight((cellDictionary["data"] as? [TagModel])!) + extraHeight
            break
        case .QuestionTableViewCell :
            let questionModel = cellDictionary["data"] as! TargetQuestionModel
            height = calculateTargetCellHeight(questionModel)
            break
        case .ActorQuestionTableViewCell :
            let questionModel = cellDictionary["data"] as! TargetQuestionModel
            height = calculateActorTargetCellHeight(questionModel)
            break
        case .FooterCell :
            if isMyProfile == true {
                height = 40
            }
            else{
                height = self.actionButtonContainerView.frame.size.height
            }
            break
        case .PersonalQouteCell :
            let text = cellDictionary["text"] as! String
            var padding : CGFloat = 10
            if checkIfUserHasVisitedProfileFromChat(){
                padding = 30
            }
            height = heightForView(text, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: tableView.bounds.size.width - 40) + padding
            break
        case CellType.MyQuestionCell :
            height = 62.0
            break
        case .EthnicityCell:
            height = calculateHeightForEthnicityRow()
            break
        case .ReportCell:
            height = 85
            break
        case .ProfileInfoTableViewCell:
            //height = CGFloat(Int((profileData?.profileInfoTags.count)!/2 + 1) * 70)
            var heightOfProfileInfo = 0
            var isThereAnyTwoLinesText = false
            var profileCount = -1
            for profileInfo in (profileData?.profileInfoTags)!{
                profileCount += 1
                var extraHeight:CGFloat = 0.0
                let heightOfCell = heightForView(profileInfo.name!, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: (UIScreen.main.bounds.size.width - 40)/2)
                
                var secondProfileInfo:ProfileInfoTagModel?
                if profileCount % 2 == 0 {
                    if profileCount < ((profileData?.profileInfoTags.count)! - 1) {
                        secondProfileInfo = profileData?.profileInfoTags[profileCount + 1]
                    }
                    else{
                        secondProfileInfo = nil
                    }
                }
                else{
                    secondProfileInfo = profileData?.profileInfoTags[profileCount - 1]
                }
                
                var heightForSecondProfile:CGFloat = 0.0
                if let second = secondProfileInfo{
                    heightForSecondProfile = heightForView(second.name!, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: (UIScreen.main.bounds.size.width - 40)/2)
                }
                if heightOfCell > 20 || heightForSecondProfile > 20{
                    isThereAnyTwoLinesText = true
                    extraHeight = 20.0
                }
                else{
                    extraHeight = 0.0
                }
                heightOfProfileInfo = Int(50 + extraHeight) + heightOfProfileInfo
            }
            let countOfTags = profileData?.profileInfoTags.count
            var extraHeight = 0
//            if countOfTags <= 2{
//                extraHeight = 30
//            }
//            else{
//
//            }
            if countOfTags! % 2 != 0 {
                if isThereAnyTwoLinesText{
                    extraHeight = 20
                }
                else{
                    extraHeight = 10
                }
                if profileData?.personalQuote?.count != 0{
                    extraHeight = extraHeight + 40
                }
            }
            else{
                if isThereAnyTwoLinesText{
                    extraHeight = 20
                }
                else{
                    extraHeight = 10
                }
                if profileData?.personalQuote?.count != 0{
                    extraHeight = extraHeight + 35
                }
            }
            
            heightOfProfileInfo = (heightOfProfileInfo/2) + extraHeight
            height = CGFloat(heightOfProfileInfo)
            if didCameFromChat{
                if profileData?.personalQuote?.count == 0{
                    height = height + 20
                }
            }
            break
        case .QnADPVTableViewCell:
            let questionModel = cellDictionary["data"] as? TargetQuestionModel
            let heightOfQuestionLabel = heightForView(questionModel?.question ?? "", font: UIFont(name: "Lato-Bold", size: 18.0)!, width: qnaQuestionTextWidthConstant)
            let heightOfAnswerLabel = heightForView(questionModel?.answer ?? "", font: UIFont(name: "Lato-Bold", size: 18.0)!, width: qnaAnswerTextWidthConstant)
            var extraHeight:CGFloat = 0
            if cellDictionary["paddingRequired"] as? Bool == true{
                extraHeight = 10
            }
            height = qnaExtraSpacingDifferenceConstant + heightOfQuestionLabel + heightOfAnswerLabel + extraHeight

        }
        return height
    }
}

extension ProfileDeckDetailViewController : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        allowedToMakeProfileSmall = false
        
        if scrollView.contentOffset.y > lastOffSetLocation {
            //Downward
            self.showActionButtonContainerView(false)
        }
        else{
            self.showActionButtonContainerView(true)
        }
        
        print("contentOffsety=\(scrollView.contentOffset.y), profileDeckObject=\(profileDeckObject?.frame.size.height)")
        
        if self.profileDetailTableView.indexPathsForVisibleRows != nil {
            let visibleArrayOfcells:NSArray? = self.profileDetailTableView.indexPathsForVisibleRows! as NSArray?
            let arrayOfcells:NSArray? = self.profileDetailTableView.indexPathsForRows(in: CGRect(x: 0, y: 0, width: self.profileDetailTableView.frame.width, height: self.profileDetailTableView.contentSize.height)) as NSArray?
            if let localArrayOfCells = visibleArrayOfcells{
                let lastVisibleIndexPath:IndexPath? = localArrayOfCells.lastObject as? IndexPath
                let lastIndexPath:IndexPath? = arrayOfcells!.lastObject as? IndexPath
                
                if (lastVisibleIndexPath as NSIndexPath?)?.row == (lastIndexPath as NSIndexPath?)?.row {
                    self.showActionButtonContainerView(true)
                }
            }
            
        }
        var xtraheight : CGFloat = 0.0
        if profileDeckObject != nil && profileDeckObject?.profileImageView != nil{
        xtraheight = (profileDeckObject?.frame.size.height)! - ((profileDeckObject?.profileImageView.frame.size.height)! - 100.0)
        }
        print("y = \(scrollView.contentOffset.y) and xtra = \(xtraheight)")
        if scrollView.contentOffset.y >= -64.0 - xtraheight {
            navBarImageView.isHidden = false
        }
        else{
            gradientBottom.removeFromSuperlayer()
            gradientBottom.frame = CGRect(x: 0, y: self.navBarImageView.bounds.size.height*3/4,
                                          width: self.navBarImageView.bounds.size.width,
                                          height: self.navBarImageView.bounds.size.height/4);
            gradientBottom.colors = [kGradientColorClear, kGradientColorBlackBottomForDPV]
            self.navBarImageView.layer.addSublayer(gradientBottom)
            navBarImageView.isHidden = true
            if self.profileDeckObject != nil && self.profileDeckObject?.imageGalleryView != nil {
                if let photo = profileData?.wooAlbum?.objectAtIndex((self.profileDeckObject?.imageGalleryView?.getCurrentImageIndex())!) {
                    self.navBarImageView.sd_setImage(with: URL(string: photo.url!))
                }
            }
        }
        
        if detailProfileParentTypeOfView != DetailProfileViewParent.tagSearch {
            if isMyProfile {
                if scrollView.contentOffset.y >= -64.0 - xtraheight {
                    nav_completenessView.isHidden = false
                    profileDeckObject?.myProfileProgressContainerView.isHidden = true
                }
                else{
                    nav_completenessView.isHidden = true
                    profileDeckObject?.myProfileProgressContainerView.isHidden = false
                }
            }
            
        }
        
        if scrollView.contentOffset.y <= -64.0 && (UIScreen.main.bounds.size.height*0.8 - navBarImageView.frame.height < 0.5) {
            let heightUnit  = 1/(navBarImageView.frame.height - 64.0)
            let alpha = heightUnit*abs((0.0 - navBarImageView.frame.height) - scrollView.contentOffset.y)
            heightLabel.alpha = 1.0 - alpha
            locationLabel.alpha = 1.0 - alpha
        }
        lastOffSetLocation = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        allowedToMakeProfileSmall = true
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11"){
        if profileDetailTableView.contentInset.top == profileDeckObject?.frame.size.height {
            if detailProfileParentTypeOfView == DetailProfileViewParent.discover{
                profileDetailTableView.contentInset = UIEdgeInsets(top: profileDetailTableView.contentInset.top - 20, left: 0, bottom: 0, right: 0)
            }
            else if isMyProfile{
                profileDetailTableView.contentInset = UIEdgeInsets(top: profileDetailTableView.contentInset.top - 20, left: 0, bottom: 0, right: 0)
            }
          }
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("end contentOffsety=\(scrollView.contentOffset.y), profileDeckObject=\(profileDeckObject?.frame.size.height)")
        
        if allowedToMakeProfileSmall == true {
            if let heightValue = profileDeckObject?.frame.size.height {
                if scrollView.contentOffset.y == -heightValue {
                    self.closeDetailViewController(UIButton())
                }
            }
        }
    }
}

extension ProfileDeckDetailViewController:ReasonsDelegate{
    func reasons(forUnmatchOrDelete comment: String!) {
        informServerAboutDeletionOfMatch(comment)
    }
}
