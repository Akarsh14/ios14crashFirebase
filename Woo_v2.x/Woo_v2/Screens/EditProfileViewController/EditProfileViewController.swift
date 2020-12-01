//
//  EditProfileViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 18/07/16.
//  Copyright © 2016 Woo. All rights reserved.

import UIKit
import IQKeyboardManager
//import AccountKit
import AssetsLibrary
import Photos
import AVFoundation
import Firebase
import FirebaseUI
import FirebaseAuth
import CropPickerController

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


enum EditCellType : String{
    case PhotoGalleryTableViewCell  = "PhotoGalleryTableViewCell"
    case EditProfileGenericTableViewCell = "EditProfileGenericTableViewCell"
    case EditProfileEditCellTableViewCell = "EditProfileEditCellTableViewCell"
    case LinkedInSyncTableViewCell = "LinkedInSyncTableViewCell"
    case EditQuoteTableCell = "EditQuoteTableCell"
    case EditProfileHeightTableCell = "EditProfileHeightTableCell"
    case EditProfileTagCell = "EditProfileTagCell"
    case FBLinkedInCell = "FBLinkedInCell"
    case HideFromMutualFriendCell = "HideFromMutualFriendCell"
    case PhoneCaptureTableViewCell = "PhoneCaptureTableViewCell"
    case QnATableViewCell = "QnATableViewCell"
    case TeamWooTableViewCell = "TeamWooTableViewCell"
}

enum GenericTableViewCellSubType : String{
    case Location    = "Location"
    case Ethnicity   = "Ethnicity"
    case Name        = "Name"
    case Phone       = "Phone"
    case College     = "College"
    case Degree      = "Degree"
    case Company     = "Company"
    case Designation = "Designation"
    case Religion    = "Religion"
    case Relationship    = "Relationship"
}

enum LinkedInSyncTableViewCellSubType : String{
    case Sync    = "Sync"
    case Resync   = "Resync"
}

enum OpenNextScreenType : String{
    case Work_place    = "work_place"
    case College       = "college"
    case None          = "none"
}

enum TagCellType : String{
    case RelationShip_Lifestyle    = "RelationShip"
    case Zodiac       = "Zodiac"
    case Tags          = "Tags"
}

enum ScrollingIndexType : String{
    case Photo              = "addPics"
    case LinkedIn           = "syncLinkedin"
    case Tags               = "addTags"
    case PersonalQuote      = "addPersonalQuote"
    case Phone              = "addPhoneNumber"
    case Height             = "addHeight"
    case Work               = "addWork"
    case Education          = "addEducation"
    case Religion           = "addReligion"
    case Ethnicity          = "addEthnicity"
    case None               = ""
    
    func cellIndex(_ gender : String, phoneVerify : Bool = false) -> Int {
        var index = -1
        if phoneVerify {
            switch self {
            case .Photo :              index = 0
            case .LinkedIn :           index = (gender != "MALE") ? 10 : 9
            case .Tags :               index = (gender != "MALE") ? 11 : 10
            case .PersonalQuote :      index = (gender != "MALE") ? 4 : 3
            case .Phone :              index = (gender != "MALE") ? 6 : 5
            case .Work :               index = (gender != "MALE") ? 4 : 3
            case .Education :          index = (gender != "MALE") ? 5 : 4
            case .Height :             index = (gender != "MALE") ? 14 : 13
            case .Religion :           index = (gender != "MALE") ? 10 : 9
            case .Ethnicity :          index = (gender != "MALE") ? 6 : 5
            case .None :               index = -1
            }
        }
        else{
            switch self {
            case .Photo :              index = 0
            case .LinkedIn :           index = (gender != "MALE") ? 3 : 2
            case .Tags :               index = (gender != "MALE") ? 11 : 10
            case .PersonalQuote :      index = 11
            case .Phone :              index = (gender != "MALE") ? 1 : 0
            case .Work :               index = (gender != "MALE") ? 4 : 3
            case .Education :          index = (gender != "MALE") ? 4 : 3
            case .Height :             index = (gender != "MALE") ? 14 : 13
            case .Religion :           index = (gender != "MALE") ? 10 : 9
            case .Ethnicity :          index = (gender != "MALE") ? 5 : 4
            case .None :               index = -1
            }
        }
        return index
    }
}
@objc(EditProfileViewController)
class EditProfileViewController: UIViewController, PhoneCaptureTableCellDelegate {
    
    @IBOutlet weak var editProfileSegmentedControl: UISegmentedControl!
    var pendingLoginViewController: AKFViewController?
    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var editProfileTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var editProfileTableViewbottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextOrDoneButtonForWizard: UIButton!
    @IBOutlet weak var viewCounterLabelForWizard: UILabel!
    @IBOutlet weak var backButtonForWizard: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var navBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarView: UIView!
    
    @IBOutlet weak var progressbar: EditProfileProgressbar!
    
    @IBOutlet weak var progressBarLabel: UILabel!
    
    @IBOutlet weak var editProfileTableView: UITableView!
    
    @IBOutlet weak var editProfileLabelWidthConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var editProfileNavBarTopConstraint: NSLayoutConstraint!
    var scrollToIndex : ScrollingIndexType = .None
    
    var openNextScreen : OpenNextScreenType = .None

    var isProfileModified = false
    
    var isWorkInfoModified = false

    var isCollegeDegreeModified = false

    var isTypeOfWorkEducation = false

    var isShownFromWizard = false

    var isRefreshNeeded = false
    
    var closeForWizardWork = false
    
    var imageToSendForCropper: UIImage?
    
    var imagePicker:UIImagePickerController?
    
    var fbPhotoObjetId:String?
    
    //MARK: Public Variables
    var dismissHandler : ((Bool, Bool) -> ())?
    
    //MARK: Private Variables
    fileprivate var customLoader :WooLoader?
    
    fileprivate var tokenGeneratorObj : TokenGenerator?
    
    @IBOutlet weak var wizardCounterLabel: UILabel!
    @IBOutlet weak var wizardBackButton: UIButton!
    @IBOutlet weak var wizardBottomView: UIView!
    fileprivate var myProfile :MyProfileModel?

    /// Array needed for creating profile tableview. Datasource for table view
    fileprivate var userdataArray : NSMutableArray = []
    
    fileprivate var lastEditedPhotoIndex = -1
    
    var scrollToPersonalQoute = false
    
    var openedFromReviewPhotoCard = false
    
    //fileprivate var accountKit = AccountKit(responseType: .accessToken)
    
    var photoTipsViewObject:PhotoTipsView?
    
    var scrollHappenedWhileChangingSegment = false
    
    var lastContentOffset: CGFloat = 0

    //constants For EditProfile
    let segmentPointOfQuestions:Int = 1
    let segmentPointOfOthers:Int = 3
    
    let extraDifferenceOfQnaDataCell:CGFloat = 63
    let aswerHeightOfAnswerQnaCell:CGFloat = 20
    let extraDifferenceOfQnaTableCell:CGFloat = 108
    let widthDifferenceForQuestionAnswerLabel:CGFloat = SCREEN_WIDTH - 65
    let plusButtonDifference:CGFloat = 45
    
    
    var uploadImageSuccessfullDictionary = [[String:Any]]()
    var remainingImagesForUploadingOnDiscover = [Data]()
    var photoForMatching : Int = 0
    
    //MARK: ViewController lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfileLanding")

        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "EditProfileScreen", withEventName: "3-EditProfile.EditProfileScreen.EP_Landing")
        
        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            closeTopConstraint.constant = 40
        }
//        if(!isRefreshNeeded){
            setupLayout()
//        }else{
//            refreshProfileData();
//        }
        
        
        if !isShownFromWizard{
            wizardBottomView.isHidden = true
            closeButton.isHidden = true
        }
        else{
            editProfileTableView.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.white
           
            if SYSTEM_VERSION_LESS_THAN(version: "11"){
                editProfileNavBarTopConstraint.constant = 40.0
            }
            setupBottomArea()
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser(not:)), name: NSNotification.Name(rawValue: kGetResultFromFirebaseAuthenticationObserver), object: nil)
       
        if( WooScreenManager.sharedInstance.uploadImageisStillProcessing == false){
            UserDefaults.standard.removeObject(forKey: "croppedImagesArrayForPhotoGalleryTableViewCell")
        }else{
            
            self.prepareCellDataFromProfile()
            self.editProfileTableView.reloadData()
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFromDictionaryWhichComesfromSingleCropper),
        name:NSNotification.Name(rawValue: "deleteFromDictionaryInWizardScreen"), object: nil)
    }
    
    
    
    @objc fileprivate func deleteFromDictionaryWhichComesfromSingleCropper(_ notif : Notification) {
        
        if let dict = notif.userInfo?["UIImage"] as? UIImage {
            deleteFromUploadDictionary(imageTobeDeleted: dict)
        }
         
    }
    
    func setBottomWizardViewItems(_ shouldWizardBackButton:Bool, nextOrDoneButtonText:String, wizardViewCounterText:String){
        if shouldWizardBackButton{
            backButtonForWizard.isHidden = false
        }
        else{
            backButtonForWizard.isHidden = true
        }
        nextOrDoneButtonForWizard.setTitle(nextOrDoneButtonText, for: .normal)
        viewCounterLabelForWizard.text = wizardViewCounterText
    }
    
    @objc func setupLayout(){
        
        if isTypeOfWorkEducation{
            navBarView.isHidden = true
        }
        
        if (isShownFromWizard){
            editProfileSegmentedControl.isHidden = true
        }
        
        navBarView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        navBarView.layer.shadowOpacity = 0.3
        navBarView.layer.shadowColor = UIColor.gray.cgColor
        
        NSLog("DiscoverProfileCollection.sharedInstance.myProfileData \(DiscoverProfileCollection.sharedInstance.myProfileData?.wooId)")
        if DiscoverProfileCollection.sharedInstance.myProfileData != nil {
            myProfile = DiscoverProfileCollection.sharedInstance.myProfileData?.copy()
            if (myProfile?.wooAlbum) != nil{
                myProfile!.wooAlbum!.moveProfilePicToFront()
            }
            prepareCellDataFromProfile()
            editProfileTableView.reloadData()
            self.progressbar.progressValue = CGFloat(truncating: NumberFormatter().number(from: (myProfile!.profileCompletenessScore))!)
            self.progressBarLabel.text = "\(myProfile!.profileCompletenessScore)%"
        }
        else{
            myProfile = nil
        }
    }
    
    func refreshProfileData(){
        
        if let wooId = UserDefaults.standard.object(forKey: "id"){
        
            isRefreshNeeded = false

            let userIdNum: CLongLong = Int64(wooId as! String)!

        //self.showWooLoader()

        ProfileAPIClass.fetchDataForUser(withUserID: userIdNum) { (response, success, statusCode) in
            //self.removeWooLoader()
            if statusCode == 401{
                //                self.handle
                //401 handling
            }
            if success{
                self.setupLayout()
            }
        }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         if !isShownFromWizard{
            colorTheStatusBar(withColor: UIColorHelper.color(fromRGB: "#75C4DB", withAlpha: 1.0))
         }
         else{
            colorTheStatusBar(withColor: UIColor .white)

        }
        
        if let nav = self.navigationController{
            nav.swipeBackEnabled = false
        }
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        self.navigationController?.navigationBar.isHidden = true
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissPhoneVerifyFlow),
                                               name: NSNotification.Name(rawValue: "dismissPhoneVerify"),
                                               object: nil)

        
       
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditProfileViewController.keyboardWasShown(_:)),
                                                         name: UIResponder.keyboardDidShowNotification,
                                                         object: nil)
        self.perform(#selector(EditProfileViewController.scrollToAParticularPosition), with: nil, afterDelay: 0.5)
        
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                editProfileNavBarTopConstraint.constant = 0.0
            }
        }
        else{
            editProfileNavBarTopConstraint.constant = 0.0
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(EditProfileViewController.keyboardWasShown(_:)),
                                               name:UIResponder.keyboardDidShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(EditProfileViewController.updateQuestionAnswerCell(_:)),
                                               name: NSNotification.Name(rawValue: kUpdateEditProfileBasedOnQuestionAnswerChanges),
                                               object: nil)
        
        
        
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(EditProfileViewController.updateGallery),
                                                name: NSNotification.Name(rawValue: "refreshView"),
                                                object: nil)
        
        //prepareCellDataFromProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let nav = self.navigationController{
            nav.swipeBackEnabled = true
        }
        NotificationCenter.default.removeObserver(self,
                                                  name:UIResponder.keyboardDidShowNotification,
                                                            object: nil)
        super.viewWillDisappear(animated)

        //IQKeyboardManager.shared().isEnabled = true
       // IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func dimissTheScreen()
    {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }

    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
    }
    //MARK: IBAction methods
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if isCollegeDegreeModified{
            isProfileModified = true
        }
        
        if isWorkInfoModified{
            isProfileModified = true
        }
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Close")
        if isProfileModified{
            sendWizardDataToServer(true)
        }
        else{
            if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                self.showWizardCompleteView(false, toClose: true)
            }
            else{
                if self.checkIfFlowIsComplete(){
                    self.showWizardCompleteView(true, toClose: true)
                }
                else{
                    self.checkIfToShowDiscoverOrMe()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }
    }
    
    @IBAction func wizardNextButtonPressed(_ sender: Any) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if isCollegeDegreeModified{
            isProfileModified = true
        }
        
        if isWorkInfoModified{
            isProfileModified = true
        }
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Next")
        if isProfileModified{
            self.isProfileModified = false
            if !self.checkIfFlowIsComplete(){
                WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
            }
            sendWizardDataToServer(false)
        }
        else{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true, toClose: false)
                    }
                    else{
                        WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                    }
        }
    }
    
    func checkIfToShowDiscoverOrMe(){
        if DiscoverProfileCollection.sharedInstance.discoverModelCollection.count > 0{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        else{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
        }
    }
    func showWizardCompleteView(_ isCompleted:Bool, toClose:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
            if isCompleted && self.isProfileModified{
                WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func checkIfFlowIsComplete() -> Bool{
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            return true
        }
        else{
            return false
        }
    }
    
    fileprivate func sendWizardDataToServer(_ toClose:Bool){
        closeForWizardWork = toClose
        showWooLoader()
        let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        
        if isCollegeDegreeModified{
        var _college : [NSMutableDictionary] = []
        _college.append((myProfile?.selectedCollege().dictionarify())!)
        myProfileDictionary["college"] = _college
        //degree - 4
        var _degree : [NSMutableDictionary] = []
        _degree.append((myProfile?.selectedDegree().dictionarify())!)
        myProfileDictionary["degree"] = _degree
        }
        if isWorkInfoModified{
        //company - 5
        var _company : [NSMutableDictionary] = []
        _company.append((myProfile?.selectedCompany().dictionarify())!)
        myProfileDictionary["company"] = _company
        //designation - 6
        var _designation : [NSMutableDictionary] = []
        _designation.append((myProfile?.selectedDesignation().dictionarify())!)
        myProfileDictionary["designation"] = _designation
        }
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary))!)
        
        
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
            self.removeWooLoader()
            let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is EditProfileViewController
            if !currenViewControllerIsSelf{
                self.isProfileModified = false
                WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                return
            }
            if toClose{
                if success{
                    if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                        self.isProfileModified = false
                        self.showWizardCompleteView(false, toClose: toClose)
                        WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                    }
                    else{
                        if self.checkIfFlowIsComplete(){
                            self.showWizardCompleteView(true, toClose: toClose)
                        }
                        else{
                            self.isProfileModified = false
                        self.checkIfToShowDiscoverOrMe()
                        self.navigationController?.popToRootViewController(animated: false)
                            WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()

                        }
                    }
                    
                    
                }
            }
            else{
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true, toClose: false)
                    }
                    else{
                        WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                        WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                    }
                }
            }
        }
    }
    
    @IBAction func wizardBackPressed(_ sender: Any) {
       
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        //closeKeyBoard()
        
        if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
            
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Onboard_EditProfile_Done")
        }
        
        if isPhotosChanged() || isShowInitials() || isPersonalQouteChanged() || isEthnicityChanged() || isReligionChanged() || isCollegeDegreeModified || isWorkInfoModified || isMyTagsChanged() || isRelationshipTagsChanged() || isZodiacTagsChanged() || isMutualFriendsShowChanged() || isHeightChanged(){
            isProfileModified = true
        }
        
        if isProfileModified {
            let alert: UIAlertController = UIAlertController(title: nil,
                                                             message: NSLocalizedString("Message_discard_changes", comment:""),
                                                             preferredStyle: .alert)
            let doAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("Yes", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                
                if self.navigationController != nil && self.navigationController?.viewControllers.first != self{
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    
                    self.dismiss(animated: true, completion: {

                    })
                }
            })
            
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("No", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
                
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    return
                }

                
                self.DoneButtonPressed(sender)
            })
            
            alert.addAction(cancelAction)
            alert.addAction(doAction)
            
            self.present(alert, animated: true, completion: {() -> Void in
            })
        }
        else{
            if self.navigationController != nil && self.navigationController?.viewControllers.first != self{
                self.navigationController?.popViewController(animated: true)
                if self.dismissHandler != nil {
                    self.dismissHandler!(false, false)
                }
            }
            else{
                
                self.dismiss(animated: true, completion: {
                    if self.dismissHandler != nil {
                        self.dismissHandler!(false, false)
                    }
                })
            }
        }
    }
    
    @IBAction func DoneButtonPressed(_ sender: AnyObject) {
        
       self.showWooLoader()
        
        if !UserDefaults.standard.bool(forKey: kIsOnboardingMyProfileeShown) {
            
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Onboard_EditProfile_Done")
        }
        
       if self.myProfile?.personalQuote?.trimmingCharacters(in: .whitespaces).count == 0
        {
            self.myProfile?.personalQuote = ""
        }
        
        var myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        var profilePicID:String? = nil
        if isPhotosChanged(){
            myProfileDictionary = (myProfile?.wooAlbum?.dictionaryfy())!
            profilePicID = myProfile?.wooAlbum?.profilePicData()?.objectId
            isProfileModified = true
        }
        
        if isShowInitials(){
            if myProfile?.showInitials != nil{
            myProfileDictionary["showInitials"] = NSNumber(value: myProfile?.showInitials as! Bool)
            }
            else{
                myProfileDictionary["showInitials"] = NSNumber(value: true)
            }
            isProfileModified = true
        }
        
        if isPersonalQouteChanged(){
            myProfileDictionary["personalQuote"] = (Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: myProfile?.personalQuote)
            isProfileModified = true
        }
        
        if isEthnicityChanged(){
            var _ethnicity : [NSMutableDictionary] = []
            if let ethinicity = myProfile?.ethnicity{
                for item in ethinicity{
                    _ethnicity.append((item.dictionarify()))
                }
            }
            
            myProfileDictionary["ethnicity"] = _ethnicity
            isProfileModified = true
        }
        
        if isReligionChanged(){
            var _religion : [NSMutableDictionary] = []
            
            let item = myProfile?.selectedReligion()
            
            if item?.name != "Select" && (item?.isSelected)! {
                _religion.append((item?.dictionarify())!)
                myProfileDictionary["religion"] = _religion
                isProfileModified = true
            }
        }
        
        if isCollegeDegreeModified{
            var _college : [NSMutableDictionary] = []
            _college.append((myProfile?.selectedCollege().dictionarify())!)
            myProfileDictionary["college"] = _college
            var _degree : [NSMutableDictionary] = []
            _degree.append((myProfile?.selectedDegree().dictionarify())!)
            myProfileDictionary["degree"] = _degree
            isProfileModified = true
        }
        
        if isWorkInfoModified{
            var _company : [NSMutableDictionary] = []
            _company.append((myProfile?.selectedCompany().dictionarify())!)
            myProfileDictionary["company"] = _company
            var _designation : [NSMutableDictionary] = []
            _designation.append((myProfile?.selectedDesignation().dictionarify())!)
            myProfileDictionary["designation"] = _designation
            isProfileModified = true
        }
        
        if isMyTagsChanged() || isRelationshipTagsChanged() || isZodiacTagsChanged(){
            var _tagsDtos : [NSMutableDictionary] = []
            for item in (myProfile?.tags)! {
                _tagsDtos.append(item.dictionarify())
            }
            myProfileDictionary["tagsDtos"] = _tagsDtos
            
            var _relationshipDtos : [NSMutableDictionary] = []
            for item in (myProfile?.relationshipLifestyleTags)! {
                _relationshipDtos.append(item.dictionarifyForSendingToServer())
            }
            myProfileDictionary["relationShipAndLifeStyle"] = _relationshipDtos
            
            if let zodiacData = myProfile!.zodiac{
                myProfileDictionary["zodiac"] = zodiacData.dictionarifyForSendingToServer()
            }
            
            isProfileModified = true
        }
        
        if isMutualFriendsShowChanged(){
            myProfileDictionary["isMutualFriendVisible"] = myProfile?.isMutualFriendVisible
            isProfileModified = true
        }
        if isHeightChanged(){
            myProfileDictionary["showHeightType"] = myProfile?.showHeightType.rawValue
            myProfileDictionary["height"] = myProfile?.height
            isProfileModified = true
        }
        
    
        if isProfileModified {
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            if isPersonalQouteChanged(){
            if (self.myProfile?.personalQuote?.count ?? 0) < LoginModel.sharedInstance().personalQuoteMinCharLength {
                showSnackBar(String(format:NSLocalizedString("Message_personal_quote_length_violation",comment: ""), LoginModel.sharedInstance().personalQuoteMinCharLength))
                return
            }
            }
            
            if isMyTagsChanged(){
            if UInt32((self.myProfile?.tags.count)!) <  UInt32(LoginModel.sharedInstance().minTagsAllowedCount) {
                self.showSnackBar(String(format: NSLocalizedString("Please select minimum %d tags", comment: ""),LoginModel.sharedInstance().minTagsAllowedCount))
                return
            }
            }
            
            showWooLoader()
            self.view.endEditing(true)
            let completionHandler : (Any?, Bool, Int32) -> () =
                {(response, success, statusCode) -> Void in
                    
                    if success {
                        DiscoverProfileCollection.sharedInstance.updateMyProfileData(response as! NSDictionary)
                        if self.openedFromReviewPhotoCard{
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
                        }
                        if DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged == true {
                            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                            DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
                            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
                            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                            DiscoverProfileCollection.sharedInstance.paginationToken = ""
                            DiscoverProfileCollection.sharedInstance.paginationIndex = ""
                            if DiscoverProfileCollection.sharedInstance.collectionMode != .my_PROFILE {
                                if !self.isTypeOfWorkEducation{
                                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                                }
                            }
                            
                            DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                                if success{
                                }
                            })
                        }
                        
                        (AppLaunchApiClass.sharedManager() as AnyObject).makeAppSyncCallForSidePanelTips()
                        
                        DiscoverProfileCollection.sharedInstance.myProfileData?.location = self.myProfile?.location
                        
                        self.myProfile?.updateData(response as! NSDictionary)
                        
                        self.copyEditedDataToMyProfile()
                        
                        
                        let currentMode = DiscoverProfileCollection.sharedInstance.collectionMode
                        
                        //DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
                        
                        if currentMode != .my_PROFILE {
                            DiscoverProfileCollection.sharedInstance.switchCollectionMode(currentMode)
                        }
                    }
                    else{
                        self.handleErrorForResponseCode(Int(statusCode))
                    }
                    

                    
            }
            
            ProfileAPIClass.updateMyProfileDataForUser(withPayload: myProfile?.jsonfyForDictionary(myProfileDictionary),
                                                                  andProfilePicID: profilePicID,
                                                                  andCompletionBlock:completionHandler)
            
//            let  _ = self.navigationController?.popViewController(animated: true)
            
            if self.navigationController != nil && self.navigationController?.viewControllers.first != self{

                let  _ = self.navigationController?.popViewController(animated: true)

                if self.dismissHandler != nil {
                    if (sender as! UIButton).tag == 200{
                        self.dismissHandler!(true, true)
                    }
                    else{
                        self.dismissHandler!(true, false)
                    }
                }
            }
            else{

                    self.dismiss(animated: false, completion: {
                        if self.dismissHandler != nil {
                            if (sender as! UIButton).tag == 200{
                                self.dismissHandler!(true, true)
                            }
                            else{
                                self.dismissHandler!(true, false)
                            }

                        }
                    })
            }
            
        }
        else{
            var needToShowProfileDetail = false
            DiscoverProfileCollection.sharedInstance.myProfileData = myProfile
            if DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged == true {
                needToShowProfileDetail = true
                DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
                DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                DiscoverProfileCollection.sharedInstance.paginationToken = ""
                DiscoverProfileCollection.sharedInstance.paginationIndex = ""
                if DiscoverProfileCollection.sharedInstance.collectionMode != .my_PROFILE {
                    if !self.isTypeOfWorkEducation{
                        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                    }
                }
                
                DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                    if success{
                    }
                })
                (AppLaunchApiClass.sharedManager() as AnyObject).makeAppSyncCallForSidePanelTips()
            }
            
            if self.navigationController != nil && self.navigationController?.viewControllers.first != self{
                self.navigationController?.popViewController(animated: true)

                if self.dismissHandler != nil {
                    self.dismissHandler!(needToShowProfileDetail, false)
                }
            }
            else{
                
                self.dismiss(animated: false, completion: {
                    if self.dismissHandler != nil {
                        if (sender as! UIButton).tag == 200{
                            self.dismissHandler!(self.isProfileModified, true)
                        }
                        else{
                            self.dismissHandler!(self.isProfileModified, false)
                        }
                    }
                })
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.removeWooLoader()
        }
    }
    
    func containSameElements(_ firstArray: [String],secondArray: [String]) -> Bool {
        var first = firstArray
        var second = secondArray
        if first.count != second.count {
            return false
        } else {
            first.sort()
            second.sort()
            return first == second
        }
    }
    
    func isPhotosChanged() -> Bool{
        
        if let album = myProfile?.wooAlbum?.photoArray{
            for photo in album{
            let photoFromAlbum = photo as! AlbumPhoto
            if photoFromAlbum.status == "REJECTED"{
                return true
            }
        }
        }
        return false
        /*
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        if myProfile?.wooAlbum?.count() != globalMyProfile?.wooAlbum?.count(){
            return true
        }
        else{
        let newPhotosArray = myProfile?.wooAlbum?.allImagesUrl()
        let oldPhotosArray = globalMyProfile?.wooAlbum?.allImagesUrl()
            if containSameElements(newPhotosArray!, secondArray: oldPhotosArray!){
                let photoCount:Int = (newPhotosArray?.count)!
                for var i in 0..<photoCount {
                    let newPhoto = newPhotosArray![i]
                    let oldPhoto = oldPhotosArray![i]
                    if newPhoto != oldPhoto{
                        return true
                    }
                }
                return false
            }
            else{
                return true
            }
        }
    */
    }
    
    func isShowInitials() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        if globalMyProfile?.showInitials != myProfile?.showInitials{
            return true
        }
        else{
            return false
        }
    }
    
    func isPersonalQouteChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        if myProfile?.personalQuote != nil{
            var personalQuote = ""
            if globalMyProfile?.personalQuote != nil{
                personalQuote = (globalMyProfile?.personalQuote)!
            }
        if personalQuote != myProfile?.personalQuote{
            return true
        }
        else{
            return false
        }
        }
        else{
            return false
        }
    }
    
    func isEthnicityChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData ?? MyProfileModel()
        let oldEthnicityArray = globalMyProfile.ethnicity
        var selectedOldEthnicityArray:[String] = []
            for ethnicity in oldEthnicityArray{
            if ethnicity.isSelected == true{
                selectedOldEthnicityArray.append(ethnicity.tagId!)
            }
        }
        
        let newEthnicityArray = myProfile?.ethnicity
        var selectedNewEthnicityArray:[String] = []
        if newEthnicityArray != nil{
        for ethnicity in newEthnicityArray!{
            if ethnicity.isSelected == true{
                selectedNewEthnicityArray.append(ethnicity.tagId!)
            }
        }
        }
        
        if selectedOldEthnicityArray.count != selectedNewEthnicityArray.count{
            return true
        }
        else{
            if containSameElements(selectedOldEthnicityArray, secondArray: selectedNewEthnicityArray){
                return false
            }
            else{
                return true
            }
        }
    }
    
    func isReligionChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        let oldReligion = globalMyProfile?.selectedReligion()
        let newReligion = myProfile?.selectedReligion()
        if oldReligion?.tagId != newReligion?.tagId{
            return true
        }
        else{
            return false
        }
    }
    
    func isWorkOrCollegeInfoChanged(_ tagId:String, oldTagID:String) -> Bool{
        if (oldTagID != tagId){
            return true
        }
        else{
            return false
        }
    }
    
    func isMyTagsChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        var selectedOldTagsArray:[String] = []
    
        if let oldTagsArray = globalMyProfile?.tags{
        for tag in oldTagsArray{
            if let tagid = tag.tagId{
            selectedOldTagsArray.append(tagid)
            }
        }
        }
        
        var selectedNewTagsArray:[String] = []
        if let newTagsArray = myProfile?.tags{
        for tag in newTagsArray{
            if let tagid = tag.tagId{
            selectedNewTagsArray.append(tagid)
            }
        }
        }
        
        if selectedOldTagsArray.count != selectedNewTagsArray.count{
            return true
        }
        else{
            if containSameElements(selectedOldTagsArray, secondArray: selectedNewTagsArray){
                return false
            }
            else{
                return true
            }
        }
    }
    
    func isRelationshipTagsChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        let oldRelationshipTagsArray = globalMyProfile?.relationshipLifestyleTags
        var selectedOldTagsArray:[String] = []
        
        if (oldRelationshipTagsArray != nil){
        for tag in oldRelationshipTagsArray!{
            selectedOldTagsArray.append(tag.tagId!)
        }
        }
        
        let newTagsArray = myProfile?.relationshipLifestyleTags
        var selectedNewTagsArray:[String] = []
        if let tagsList = newTagsArray{
            for tag in tagsList{
                if let id = tag.tagId{
                    selectedNewTagsArray.append(id)
                }
            }
        }
       
        
        if selectedOldTagsArray.count != selectedNewTagsArray.count{
            return true
        }
        else{
            if containSameElements(selectedOldTagsArray, secondArray: selectedNewTagsArray){
                return false
            }
            else{
                return true
            }
        }
    }
    
    
    func isZodiacTagsChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        var oldZodiacTagId = -1
        var selectedZodiacTagId = -1
        
        if let oldZodiacTag = globalMyProfile?.zodiac{
            oldZodiacTagId = Int(oldZodiacTag.tagId!)!
        }
        
        if let selectedZodiacTag = myProfile?.zodiac{
            selectedZodiacTagId = Int(selectedZodiacTag.tagId!)!
        }
        
        if oldZodiacTagId != selectedZodiacTagId{
            return true
        }
        else{
            return false
        }
    }
    
    func isMutualFriendsShowChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        if globalMyProfile?.isMutualFriendVisible != myProfile?.isMutualFriendVisible{
            return true
        }
        else{
            return false
        }
    }
    
    func isHeightChanged() -> Bool{
        let globalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        if myProfile?.height != nil{
            var height = ""
            if globalMyProfile?.height != nil{
                height = (globalMyProfile?.height)!
            }
            if height != myProfile?.height || globalMyProfile?.showHeightType != myProfile?.showHeightType{
                return true
            }
            else{
                return false
            }
        }
        else{
            return false
        }
    }
    
    func setupBottomArea(){
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            nextOrDoneButtonForWizard.setTitle("DONE", for: .normal)
        }
        else{
            nextOrDoneButtonForWizard.setTitle("NEXT", for: .normal)
        }
        
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            backButtonForWizard.isHidden = true
        }
        viewCounterLabelForWizard.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
    }
    
    //MARK: Private methods
    
    /**
     * Prepares the data source for the table view reading from profile data model
     */
    fileprivate func prepareCellDataFromProfile() {
        
        userdataArray.removeAllObjects()
        
        if let profileData = self.myProfile
        {
            // Index - 0
            
            let imageGalleryDictionary = ["type": EditCellType.PhotoGalleryTableViewCell.rawValue, "data" : (profileData.wooAlbum as AnyObject)] as [String : Any]
            
            if !isTypeOfWorkEducation{
            userdataArray.add(imageGalleryDictionary as AnyObject)
            }
            
            var location = ""
            if profileData.location == nil {
                location = "--"
            }
            else{
                location = "\(profileData.location!)"
            }
            
            
            // Index - 1
            let qnaHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,"subType" : "QNA",
                                  "text" : NSLocalizedString("label_qna", comment: "")]
            if !isTypeOfWorkEducation{
                userdataArray.add(qnaHeaderMap as AnyObject)
            }
            
            var questionAnswerArray:[TargetQuestionModel] = []
            if profileData.myQuestionsArray.count > 0{
                questionAnswerArray = profileData.myQuestionsArray
            }
            let qnaMap = ["type" : EditCellType.QnATableViewCell.rawValue,
                          "data" : questionAnswerArray] as [String : Any]
            if !isTypeOfWorkEducation{
                userdataArray.add(qnaMap as AnyObject)
            }
            
            let workAndEducationHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                                             "text" : "Work & Education"]
            if !isTypeOfWorkEducation{
                userdataArray.add(workAndEducationHeaderMap as AnyObject)
            }
            else{
                let workHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                                                 "text" : "Work profile"]
                userdataArray.add(workHeaderMap as AnyObject)
            }
            
            if profileData.company.count > 0 {
                var desig = NSLocalizedString("label_i_am", comment: "")
                if profileData.selectedDesignation().name != nil {
                    desig = "\(profileData.selectedDesignation().name!)"
                }
                
                let designationMap = ["type" : EditCellType.EditProfileGenericTableViewCell.rawValue,
                                      "subType" : GenericTableViewCellSubType.Designation.rawValue,
                                      "cellValueLabel" : desig, "data":profileData.selectedDesignation()] as [String : Any]
                userdataArray.add(designationMap as AnyObject)
            }
            
            if isTypeOfWorkEducation{
                let educationHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                                     "text" : "Degree in"]
                userdataArray.add(educationHeaderMap as AnyObject)
            }

                
                if profileData.college.count > 0 {
                    var degree = NSLocalizedString("Label_degree_in", comment: "")
                    if profileData.selectedDegree().name != nil {
                        degree = "\(profileData.selectedDegree().name!)"
                    }
                    
                    
                    let degreeMap = ["type" : EditCellType.EditProfileGenericTableViewCell.rawValue,
                                     "subType" : GenericTableViewCellSubType.Degree.rawValue,
                                     "cellValueLabel" : degree,"data":profileData.selectedDegree()] as [String : Any]
                    userdataArray.add(degreeMap as AnyObject)
            }
            
                    
                    let relationshipHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,"subType" : "RelationShip",
                                                 "text" : NSLocalizedString("Label_relationship_tags", comment: "")]
                    if !isTypeOfWorkEducation{
                        userdataArray.add(relationshipHeaderMap as AnyObject)
                    }
                    
                    let relationshipTagsArray = NSMutableArray()
                    if profileData.relationshipLifestyleTags.count > 0{
                        for relationshipTag in profileData.relationshipLifestyleTags{
                            let tag = TagModel(data: relationshipTag.dictionarify())
                            relationshipTagsArray.add(tag)
                        }
                    }
                    
                    let relationshipTagsDictionary  = ["type": EditCellType.EditProfileGenericTableViewCell.rawValue,"subType" : GenericTableViewCellSubType.Relationship.rawValue,"cellValueLabel" : NSLocalizedString("Label_relationship", comment: ""), "data" : relationshipTagsArray] as [String : Any]
                    if !isTypeOfWorkEducation{
                        userdataArray.add(relationshipTagsDictionary as AnyObject)
                    }
            
            let religionHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                                         "text" : NSLocalizedString("label_religion_ethnicity", comment: "")]
            if !isTypeOfWorkEducation{
                userdataArray.add(religionHeaderMap as AnyObject)
            }
            
            var religion = NSLocalizedString("select_religion", comment: "")
            if profileData.selectedReligion().name != nil && profileData.selectedReligion().name != "Select"{
                religion = "\(profileData.selectedReligion().name!)"
            }
            
            let religionMap = ["type" : EditCellType.EditProfileGenericTableViewCell.rawValue,
                               "subType" : GenericTableViewCellSubType.Religion.rawValue,
                               "outsideImageView" : "",
                               "cellValueLabel" : religion,
                               "data":profileData.selectedReligion()] as [String : Any]
            if !isTypeOfWorkEducation{
                userdataArray.add(religionMap as AnyObject)
            }
            
            
            var ethnicityText : String = NSLocalizedString("select_ethnicity", comment: "")
            if myProfile?.ethnicity.count > 0 {
                var counter = 0
                var selectedEthnicityText = ""
                //                ethnicityText = ""
                for item in (myProfile?.ethnicity)! {
                    
                    if ((Int(item.tagId!)! > -1) && item.isSelected == true) {
                        if selectedEthnicityText.count > 0 {
                            selectedEthnicityText += ", "
                        }
                        selectedEthnicityText += "\(item.name!)"
                    }
                    
                    
                    
                    counter += 1
                }
                if selectedEthnicityText.count > 0 {
                    ethnicityText = selectedEthnicityText
                }
            }
//            let ethnicityCellMap = ["type" : EditCellType.EditProfileGenericTableViewCell.rawValue,
//                                    "subType" : GenericTableViewCellSubType.Ethnicity.rawValue,
//                                    "cellValueLabel" : ethnicityText, "data":profileData.ethnicity] as [String : Any]
//            if !isTypeOfWorkEducation{
//                userdataArray.add(ethnicityCellMap as AnyObject)
//            }
            
            //Quote Header Cell Data
            let quoteHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                                  "text" : NSLocalizedString("label_personal_quote", comment: "")]
            if !isTypeOfWorkEducation{
                userdataArray.add(quoteHeaderMap as AnyObject)
            }
            // Index - 5
            //Quote Cell Data
            var quote = ""
            if profileData.personalQuote != nil {
                quote = profileData.personalQuote!
            }
            let quoteMap = ["type" : EditCellType.EditQuoteTableCell.rawValue,
                            "text" : quote]
            if !isTypeOfWorkEducation{
                userdataArray.add(quoteMap as AnyObject)
            }
            
            //Height Cell data
            var height = ""
            if profileData.height != nil {
                height = profileData.height!
            }
            else{
                height = "4'0''"
            }
            
            let heightMap = ["type" : EditCellType.EditProfileHeightTableCell.rawValue,
                             "data" : height]
            if !isTypeOfWorkEducation{
                userdataArray.add(heightMap as AnyObject)
            }
            
            //Personal Header Cell Data
            let personalMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                               "text" : NSLocalizedString("Label_personal_tags", comment: "")]
            if !isTypeOfWorkEducation{
                userdataArray.add(personalMap as AnyObject)
            }
            
            // Index -12
            //Tag Cells Data
            let tagsDictionary  = ["type": EditCellType.EditProfileTagCell.rawValue, "data" : profileData.tags] as [String : Any]
            if !isTypeOfWorkEducation{
                userdataArray.add(tagsDictionary as AnyObject)
            }
            
            if myProfile!.gender != "MALE" {
                
                let nameHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,"subText" : NSLocalizedString("Initials_by_default", comment: ""),
                                       "text" : NSLocalizedString("Label_show_name_as", comment: "")]
                if !isTypeOfWorkEducation{
                    userdataArray.add(nameHeaderMap as AnyObject)
                }
                
                var recommendedName = ""
                if let name = profileData.myName(){
                    recommendedName = name
                }
                
                let firstNameCellMap = ["type" : EditCellType.EditProfileGenericTableViewCell.rawValue,
                                        "subType" : GenericTableViewCellSubType.Name.rawValue,
                                        "cellValueLabel" : "\(String(recommendedName))"] as [String : Any]
                
                if !isTypeOfWorkEducation{
                    userdataArray.add(firstNameCellMap as AnyObject)
                }
            }

            let displayPhoneNumberVerifText = NSLocalizedString("Phone_number_default", comment: "")
            let phoneCaptureHeaderMap = ["type" : EditCellType.EditProfileEditCellTableViewCell.rawValue,
                                         "text" : NSLocalizedString("label_phone_number", comment: ""), "subText" : displayPhoneNumberVerifText]
            if !isTypeOfWorkEducation{
                userdataArray.add(phoneCaptureHeaderMap as AnyObject)
            }
            // Index - 5
            //PhoneCapture Cell Data
            var phoneNumber = ""
            if profileData.phoneNumberDto != nil {
                if ((profileData.phoneNumberDto?.object(forKey: "phoneNumber")) != nil){
                    phoneNumber = profileData.phoneNumberDto?.object(forKey: "phoneNumber") as! String
                }
            }
            let phoneNumberMap = ["type" : EditCellType.PhoneCaptureTableViewCell.rawValue,
                                  "text" : phoneNumber]
            if !isTypeOfWorkEducation{
                userdataArray.add(phoneNumberMap as AnyObject)
            }
            
            let teamWooMap = ["type" : EditCellType.TeamWooTableViewCell.rawValue]
            if !isTypeOfWorkEducation{
                userdataArray.add(teamWooMap as AnyObject)
            }
        }
    }
    
    @objc fileprivate func scrollToAParticularPosition(){
        if myProfile != nil && self.scrollToIndex != .None {
            let rowValue = self.scrollToIndex.cellIndex((myProfile?.gender)!, phoneVerify: true)
            let indexPath = IndexPath(row: rowValue, section: 0)
            if(self.scrollToIndex == .Height)
            {
                let bottomOffset = CGPoint(x: 0, y: editProfileTableView.contentSize.height - editProfileTableView.bounds.size.height)
                self.editProfileTableView.setContentOffset(bottomOffset, animated: true)
            }
            else
            {
                self.editProfileTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
            self.scrollToIndex = .None
        }
    }
    
    fileprivate func openSearchLocation(){
        let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let searchLocation:SearchLocationViewController = mainStoryBoard.instantiateViewController(withIdentifier: kSearchLocationViewControllerID) as! SearchLocationViewController
        searchLocation.isCancelButtonVisible = true
        searchLocation.comingFromSettings = true
        searchLocation.doneBlock = { (location) in
            //self.isProfileModified = true
            self.myProfile?.location = location as NSString?
            self.prepareCellDataFromProfile()
            self.editProfileTableView.reloadData()
        }
        self.navigationController?.pushViewController(searchLocation, animated: true)
        //present(searchLocation, animated: true, completion: nil)
    }
    
    func showPhoneVerifyView() {
        let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
        let submittViewController: SubmitNumberController = (storyboard.instantiateViewController(withIdentifier: "SubmitNumberControllerID") as? SubmitNumberController)!
        if let foneVerifyDto = myProfile?.foneVerifyAvailabilityDto {
            submittViewController.flagImageUrlString = foneVerifyDto.flagUrl
            submittViewController.countryCode = foneVerifyDto.countryCode
            submittViewController.countryCodeString = foneVerifyDto.isoCountryCode
            if foneVerifyDto.phoneDigitCount != 10 {
                submittViewController.phoneDigitCount = "\(foneVerifyDto.phoneDigitCount)"
            }
            else {
                submittViewController.phoneDigitCount = "10"
            }
        }
        else{
            submittViewController.phoneDigitCount = "10"
            submittViewController.countryCode = "+91"
        }
        submittViewController.isPhoneVerifySuccess { (success, phoneNumber) in
            if success{
                print("phoneNumber \(phoneNumber)")
                self.myProfile?.foneVerifyAvailabilityDto?.phoneNumber = phoneNumber
                
                self.prepareCellDataFromProfile()
                self.editProfileTableView.reloadData()
            }
            else{
                print("nothing happen")
            }
        }
        self.navigationController!.pushViewController(submittViewController, animated: true)
    }
    
    func updateMyProfile(_ response : NSDictionary) {
        DiscoverProfileCollection.sharedInstance.myProfileData?.updateData(response)
        
        if let firstName = response["firstName"] {
            self.myProfile!.firstName = (firstName as? String)!
            DiscoverProfileCollection.sharedInstance.myProfileData!.firstName = (firstName as? String)!
        }
        
        if let lastName = response["lastName"] {
            self.myProfile!.lastName = lastName as? String
            DiscoverProfileCollection.sharedInstance.myProfileData!.lastName = lastName as? String
        }
        
        if response.object(forKey: "college") != nil {
            self.myProfile!.college = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "college") as? [[String : AnyObject]])!)
            DiscoverProfileCollection.sharedInstance.myProfileData!.college = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "college") as? [[String : AnyObject]])!)
        }
        
        if response.object(forKey: "degree") != nil {
            self.myProfile!.degree = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "degree") as? [[String : AnyObject]])!)
            DiscoverProfileCollection.sharedInstance.myProfileData!.degree = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "degree") as? [[String : AnyObject]])!)
        }
        
        if response.object(forKey: "company") != nil {
            self.myProfile!.company = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "company") as? [[String : AnyObject]])!)
            DiscoverProfileCollection.sharedInstance.myProfileData!.company = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "company") as? [[String : AnyObject]])!)
        }
        
        if response.object(forKey: "designation") != nil {
            self.myProfile!.designation = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "designation") as? [[String : AnyObject]])!)
            DiscoverProfileCollection.sharedInstance.myProfileData!.designation = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "designation") as? [[String : AnyObject]])!)
        }
        
        if response.object(forKey: "religion") != nil {
            self.myProfile!.religion = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "religion") as? [[String : AnyObject]])!)
            DiscoverProfileCollection.sharedInstance.myProfileData!.religion = self.myProfile!.professionModelArrayFromDto((response.object(forKey: "religion") as? [[String : AnyObject]])!)
        }
        
        if let religionTextVal = response["religionText"] {
            self.myProfile!.religionText = (religionTextVal as? String)!
            DiscoverProfileCollection.sharedInstance.myProfileData!.religionText = (religionTextVal as? String)!
        }
        
        if let lIsLinkedInVerified  = response["isVerifiedOnLinkedin"]{
            self.myProfile!.isLinkedInVerified = lIsLinkedInVerified as! Bool
            DiscoverProfileCollection.sharedInstance.myProfileData!.isLinkedInVerified = lIsLinkedInVerified as! Bool
        }
        
        if let lProfileCompletenessScore  = response["profileCompletenessScore"]{
            self.myProfile!.profileCompletenessScore = "\(lProfileCompletenessScore as! NSNumber)"
            DiscoverProfileCollection.sharedInstance.myProfileData!.profileCompletenessScore = "\(lProfileCompletenessScore as! NSNumber)"
        }
        
        //DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
        
        self.prepareCellDataFromProfile()
        self.editProfileTableView.reloadData()
    }
    
    fileprivate func copyEditedDataToMyProfile(){
        let originalMyProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        originalMyProfile!.profileCompletenessScore = (self.myProfile?.profileCompletenessScore)!
        originalMyProfile!.gender = (self.myProfile?.gender)!
        originalMyProfile!.firstName = (self.myProfile?.firstName)!
        originalMyProfile!.lastName = self.myProfile?.lastName
//        originalMyProfile!.location = self.myProfile?.location
        originalMyProfile!.college = (self.myProfile?.college)!
        originalMyProfile!.degree = (self.myProfile?.degree)!
        originalMyProfile!.company = (self.myProfile?.company)!
        originalMyProfile!.designation = (self.myProfile?.designation)!
        originalMyProfile!.showHeightType = (self.myProfile?.showHeightType)!
        originalMyProfile!.showInitials = (self.myProfile?.showInitials)!
        originalMyProfile!.isMutualFriendVisible = (self.myProfile?.isMutualFriendVisible)!
        originalMyProfile!.isPhoneVerified = (self.myProfile?.isPhoneVerified)!
        if let about = self.myProfile?.about{
            originalMyProfile!.about = about
        }
        originalMyProfile?.relationshipLifestyleTags = (self.myProfile?.relationshipLifestyleTags)!
        if let zodiac = self.myProfile?.zodiac{
            originalMyProfile?.zodiac = zodiac
        }
        
        if self.myProfile?.religion != nil{
            originalMyProfile!.religion = (self.myProfile?.religion)!
            if originalMyProfile?.selectedReligion().name!.count > 0 &&
               originalMyProfile?.selectedReligion().name! != "Select" {
                DiscoverProfileCollection.sharedInstance.removeSelectionCard(subType: .RELIGION)
            }
        }
        else{
            originalMyProfile!.religionText = ""
        }
        
        if self.myProfile?.religionText.count > 0 {
            originalMyProfile!.religionText = (self.myProfile?.religionText)!
        }
        
        if self.myProfile?.ethnicity.count > 0 {
            originalMyProfile!.ethnicity = (self.myProfile?.ethnicity)!
            DiscoverProfileCollection.sharedInstance.removeSelectionCard(subType: .ETHNICITY)
        }
        else{
            originalMyProfile!.ethnicity.removeAll()
            originalMyProfile!.ethnicityText = ""
        }
        
        if self.myProfile?.ethnicityText.count > 0 {
            originalMyProfile!.ethnicityText = (self.myProfile?.ethnicityText)!
        }
        
        if originalMyProfile!.isPhoneVerified {
            DiscoverProfileCollection.sharedInstance.removeDiscoverEmptyCardForType(.DISCOVER_EMPTY_PHONE_VERIFY)
        }
        
        originalMyProfile!.isLinkedInVerified = (self.myProfile?.isLinkedInVerified)!
        if originalMyProfile!.isLinkedInVerified {
            DiscoverProfileCollection.sharedInstance.removeDiscoverEmptyCardForType(.DISCOVER_EMPTY_LINKEDIN_VERIFY)
        }
        
        originalMyProfile!.tags = (self.myProfile?.tags.clone())!
        if originalMyProfile!.tags.count >= 5
        {
            DiscoverProfileCollection.sharedInstance.removeDiscoverEmptyCardForType(.DISCOVER_EMPTY_TAGS)
        }
        
        originalMyProfile!.height = self.myProfile?.height
        if originalMyProfile!.height != nil {
            DiscoverProfileCollection.sharedInstance.removeDiscoverEmptyCardForType(.DISCOVER_EMPTY_HEIGHT)
        }
        
        originalMyProfile!.personalQuote = self.myProfile?.personalQuote
        if originalMyProfile!.personalQuote != nil &&
           originalMyProfile!.personalQuote?.count > 60{
            DiscoverProfileCollection.sharedInstance.removeDiscoverEmptyCardForType(.DISCOVER_EMPTY_PERSONAL_QUOTE)
        }
        
        originalMyProfile!.wooAlbum = self.myProfile?.wooAlbum?.copy() as? WooAlbumModel
        if originalMyProfile!.wooAlbum?.count() > 0 {
            DiscoverProfileCollection.sharedInstance.removeNewUserNoPicCard()
        }
        
        if originalMyProfile!.wooAlbum?.count() == 9 {
            DiscoverProfileCollection.sharedInstance.removeDiscoverEmptyCardForType(.DISCOVER_EMPTY_PHOTO)
        }
        
        DiscoverProfileCollection.sharedInstance.reloadPendingImageList()
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
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    @objc fileprivate func keyboardWasShown(_ notificationObject:Notification){
        if scrollToPersonalQoute{
        let rowValue = ScrollingIndexType.PersonalQuote.cellIndex((myProfile?.gender)!, phoneVerify: false)
        let indexPath = IndexPath(row: rowValue, section: 0)
        editProfileTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            scrollToPersonalQoute = false
        }
    }
    
    @objc fileprivate func updateQuestionAnswerCell(_ notificationObject:Notification){
        if let profile = notificationObject.userInfo?["myProfile"] as? MyProfileModel {
            self.myProfile = profile
        }
        prepareCellDataFromProfile()
        editProfileTableView.reloadData()
    }
    
    @objc fileprivate func updateGallery( _ notificationObject:Notification ){
        
        print("update on notification")
        
        let responseDictionary = notificationObject.userInfo?["myProfile"] as? [String: Any];
        
        DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore = String((responseDictionary! as NSDictionary).object(forKey: "profileCompletenessScore") as! Int)
        let albumModel = WooAlbumModel()
        albumModel.isMyprofile = true
        albumModel.addObjectsFromArray((responseDictionary! as NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
        self.myProfile?.wooAlbum = albumModel
        DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = albumModel
        
        prepareCellDataFromProfile()
        editProfileTableView.reloadData()
    }
    
    //MARK: Woo Loader
    func showWooLoader() {
        customLoader = WooLoader(frame: self.view.frame)
        customLoader!.startAnimation(on: self.view!, withBackGround: true)
    }
    
    func removeWooLoader() {
        if customLoader != nil {
            customLoader!.removeFromSuperview()
            customLoader = nil
        }
    }
    
    //MARK: LinkedIn delegate functions
    @objc func tokenGeneratedSuccessfullyWithData(_ tokenData: AnyObject) {
        
        let data: Data = (tokenData as! String).data(using: String.Encoding.utf8)!
        let json: AnyObject = try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        var tokenDictionary: [AnyHashable: Any] = (json as! [AnyHashable: Any])
        let access: String? = (tokenDictionary["access_token"] as! String)
        print("token >>> \(access)")
//        tokenGeneratorObj!.dismiss(animated: true, completion: {() -> Void in
            if access != nil {
                self.showWooLoader()
                FBLinkedInAPIClass.updateLinkInSyncData(withAccessToken: access, andCompletionBlock: { (success, _response, errorCode) in
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "EditProfileScreen", withEventName: "3-EditProfile.EditProfileScreen.EP_SyncLinkedIn")

                    
                    self.removeWooLoader()
                    if success {
                        if let response : NSDictionary = _response as? NSDictionary{
                            
                                self.myProfile!.isLinkedInVerified = true
                                DiscoverProfileCollection.sharedInstance.myProfileData!.isLinkedInVerified = true
                            
                            if let lProfileCompletenessScore  = response["profileCompletenessScore"]{
                                self.myProfile!.profileCompletenessScore = "\(lProfileCompletenessScore as! NSNumber)"
                                DiscoverProfileCollection.sharedInstance.myProfileData!.profileCompletenessScore = "\(lProfileCompletenessScore as! NSNumber)"
                            }
                                                        
                            self.prepareCellDataFromProfile()
                            self.editProfileTableView.reloadData()
                            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                            DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
                            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
                            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                            DiscoverProfileCollection.sharedInstance.paginationToken = ""
                            DiscoverProfileCollection.sharedInstance.paginationIndex = ""
/*
                            if self.openNextScreen == .Work_place{
                                if self.myProfile?.company.count > 1{
                                    let oldTagId = self.myProfile?.selectedDesignation().tagId
                                    self.openOptionScreenWithArrayAndType((self.myProfile?.designation)!, type: "Work profile", oldTagID: oldTagId!)
                                }
                            }
                            else if self.openNextScreen == .College{
                                if self.myProfile?.college.count > 1{
                                    let oldTagId = self.myProfile?.selectedCollege().tagId
                                    self.openOptionScreenWithArrayAndType((self.myProfile?.college)!, type: "College", oldTagID: oldTagId!)
                                }
                            }
                            self.openNextScreen = .None
 */
                            
                            DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                                if success{
                                }
                            })
                            
                        }
                        else{
                            self.handleErrorForResponseCode(Int(errorCode))
                        }
                    }
                })
            }
//        })
    }
    
    @objc func tokenGenerationFailedWithData(_ failureData: [AnyHashable: Any]) {
        print("Failure data \(failureData)")
        UserDefaults.standard.set(false, forKey: kIsLinkedInVerified)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: Utility functions
    
    func closeKeyBoard() {
        let rowValue = ScrollingIndexType.PersonalQuote.cellIndex((myProfile?.gender)!, phoneVerify: false)
        let indexPath = IndexPath(row: rowValue, section: 0)
        if let cell = self.editProfileTableView.cellForRow(at: indexPath) {
            (cell as! EditQuoteTableCell).closeKeyBoard()
        }
    }
    
    func sizeForView(_ text:String, font:UIFont, height:CGFloat, type:String) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
//        if type == "" {
//        }
//        else{
//            return CGSize(width: label.frame.size.width + 16 + 33, height: height)
//        }
        return CGSize(width: label.frame.size.width + 16 + 33, height: height)

    }
    
    fileprivate func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func calculateTagCellHeight(_ array:[TagModel], tagCellType:TagCellType) -> CGFloat {
        var height : CGFloat = 0.0
        let font = UIFont(name: "Lato-Medium", size: 14.0)!
        var rowWidth : CGFloat = 10.0
        var numberOfRows  : CGFloat = 1.0
        for model in array {
            let tagWidth = sizeForView(model.name!, font: font, height: 40.0, type: model.type!).width
            rowWidth = rowWidth + tagWidth + 10
            if rowWidth > (editProfileTableView.frame.width - 40) {
                rowWidth = 10.0 + tagWidth
                numberOfRows += 1
            }
        }
        var extraButtonWidth:CGFloat = 0.0
        switch tagCellType {
        case .Tags:
            extraButtonWidth = 46.0
            break
        case .RelationShip_Lifestyle:
            if myProfile?.relationshipLifestyleTags.count > 0{
                extraButtonWidth = 0.0
            }
            break
        case .Zodiac:
            if myProfile?.zodiac != nil{
                extraButtonWidth = 0.0
            }
            break
        }
        
        height = extraButtonWidth + numberOfRows * 40.0 + 10.0 * (numberOfRows + 1)
        
        return height
    }
    
    func calculateImageGalleryHeight(_ album : WooAlbumModel) -> CGFloat {
        let collectionViewWidth : CGFloat = UIScreen.main.bounds.width
        let leftInset : CGFloat = 5.0
        let rightInset : CGFloat = 5.0
        let itemSpacing : CGFloat = 5.0
        let smallCellSideLength : CGFloat = ((collectionViewWidth - (leftInset + rightInset)) - (2 * itemSpacing)) / 3;
        let largeCellSideLength : CGFloat = (collectionViewWidth - (leftInset + rightInset)) - smallCellSideLength - itemSpacing;
        
        let numberOfLines: Int = 3
        let lineHeight: CGFloat = largeCellSideLength + CGFloat(numberOfLines - 1) * (smallCellSideLength + itemSpacing)
        
        return lineHeight + 90
    }
    
    //MARK: Cell creator methods
    func createImageGalleryCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        print("cellData",cellData)
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : PhotoGalleryTableViewCell? = array?.first as? PhotoGalleryTableViewCell
        
        cell?.dataSource = cellData["data"] as? WooAlbumModel
        
        print("dataSource is", cellData["data"] as? WooAlbumModel)
        
        cell?.showPhotoTipsHandler = {() in
            if self.photoTipsViewObject != nil{
                self.photoTipsViewObject = nil
            }
            if self.myProfile?.gender == "FEMALE"{
            self.photoTipsViewObject = PhotoTipsView.showView(false)
            }
            else{
                self.photoTipsViewObject = PhotoTipsView.showView(true)
            }
        }
        
        cell?.imageEditHandler = { (index, image, toBeDeleted) in
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            
            if toBeDeleted {
                if index == 0{
                    let album = cell?.dataSource!.objectAtIndex(index)!
                    if album?.status == "REJECTED"{
                        
                        if self.myProfile?.wooAlbum?.countOfApprovedPhotos() > 1{
                            self.deleteInCompatiblePhoto(album!, imageTobeDeleted: image!)
                        }else{
                          let alert: UIAlertController = UIAlertController(title: NSLocalizedString("", comment: ""),
                                                                             message: NSLocalizedString("You need more than one approved photo to delete your main photo.", comment:""),
                                                                             preferredStyle: .alert)
                            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Later", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditMainPhoto_Later")
                                
                            })
                            
                            let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Add another", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditMainPhoto_Add")
                                self.showImagePickerOptions()
                            })
                            
                            alert.addAction(cancelAction)
                            alert.addAction(reportAction)
                            
                            self.present(alert, animated: true, completion: {() -> Void in
                                
                            })
                        }
                         
                    }
                    else{
                        if self.myProfile?.wooAlbum?.countOfApprovedPhotos() > 1{
                            self.showDeleteConfirmationPopupForImage(image!, albumData: album!)
                        }
                        else{
                            
                            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("", comment: ""),
                                                                             message: NSLocalizedString("You need more than one approved photo to delete your main photo.", comment:""),
                                                                             preferredStyle: .alert)
                            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Later", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditMainPhoto_Later")
                                
                            })
                            
                            let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Add another", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditMainPhoto_Add")
                                self.showImagePickerOptions()
                            })
                            
                            alert.addAction(cancelAction)
                            alert.addAction(reportAction)
                            
                            self.present(alert, animated: true, completion: {() -> Void in
                                
                            })
                        }
                    }
                }
                else{
                let album = cell?.dataSource!.objectAtIndex(index)!
                if album?.status == "REJECTED"{
                    self.deleteInCompatiblePhoto(album!, imageTobeDeleted: image!)
                }
                else{
                    self.showDeleteConfirmationPopupForImage(image!, albumData: album!)
                }
                }
            }
            else{
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    return
                }
                
                if index < cell?.dataSource?.count() {
                    if image == nil {
                        return
                    }
                    let width = SCREEN_WIDTH * 0.7361;
                    let rect = CGRect(x: (SCREEN_WIDTH - width) / 2, y: 0.122 * SCREEN_HEIGHT, width: width, height: 0.655 * SCREEN_HEIGHT)
                    
                    var imgCropperVC: VPImageCropperViewController?
                    let imageData = (cell?.dataSource?.objectAtIndex(index))! as AlbumPhoto
                    
                    imgCropperVC = VPImageCropperViewController(image: image,
                                                                cropFrame: rect,
                                                                limitScaleRatio: 3)
                    imgCropperVC!.isWooAlbumCallNotNeeded = true
                    imgCropperVC?.isOpenedFromWizard = true
                    imgCropperVC!.albumData = imageData.copy() as! AlbumPhoto
                    imgCropperVC?.wooAlbum = self.myProfile?.wooAlbum?.copy() as! WooAlbumModel
                    
                    (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditPhoto")

                    self.lastEditedPhotoIndex = index
                    
                    imgCropperVC?.imageBlock = { (imageData) in
                        if imageData != nil {
//                            if self.lastEditedPhotoIndex == -1 {
//                                self.myProfile?.wooAlbum?.addObject(imageData!)
//                                (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_AddPhoto")
//
//                            }
//                            else{
//                                self.myProfile?.wooAlbum?.replaceObject(imageData!, position: self.lastEditedPhotoIndex)
//                                self.lastEditedPhotoIndex = -1
//                                (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditPhoto")
//
//                            }
                            self.myProfile?.wooAlbum = imageData
                        }
                        else{
                            if self.lastEditedPhotoIndex != -1 {
                                self.isProfileModified = true
                                self.myProfile?.wooAlbum?.removeObjectAt(self.lastEditedPhotoIndex)
                            }
                        }
                        self.prepareCellDataFromProfile()
                        self.editProfileTableView.reloadData()
                    }
                    self.navigationController!.pushViewController(imgCropperVC!, animated: true)
                }
                else{
                    self.showImagePickerOptions()
                }
            }
        }
        cell?.albumModifiedHandler = { (album) in
            let myProfileDictionary = album.dictionaryfyHavingRejected()
            let profilePicID = self.myProfile?.wooAlbum?.profilePicData()?.objectId
            ProfileAPIClass.updateMyProfileDataForUser(withPayload: self.myProfile?.jsonfyForDictionary(myProfileDictionary), andProfilePicID: profilePicID, andCompletionBlock: { (response, success, statusCode) in
            DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore = "\((response as! NSDictionary).object(forKey: "profileCompletenessScore") ?? "0")"
                let albumModel = WooAlbumModel()
                albumModel.isMyprofile = true
                albumModel.addObjectsFromArray((response as! NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
                self.myProfile?.wooAlbum = albumModel
                self.prepareCellDataFromProfile()
                self.editProfileTableView.reloadData()
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            })
        }
        
        return cell!
    }

    func createEditGenericCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : EditProfileGenericTableViewCell? = array?.first as? EditProfileGenericTableViewCell
        
        cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#afb0b4")
        cell?.moreRelationshipCountLabelWidthConstraint.constant = 0.0
        cell?.moreRelationshipCountLabel.isHidden = true
        
        if isShownFromWizard{
            cell?.backgroundColor = UIColor.white
            cell?.contentView.backgroundColor = UIColor.white
            cell?.cellValueLabel.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#72778A", alpha: 1.0)
        }
        
        cell?.cellValueLabel.text = cellData["cellValueLabel"] as? String

        let subType = cellData["subType"] as! String
        if subType == GenericTableViewCellSubType.Designation.rawValue || subType == GenericTableViewCellSubType.Religion.rawValue{
            cell?.separatorViewForCell.isHidden = false
            if subType == GenericTableViewCellSubType.Designation.rawValue{
                let selectedDesignation = cellData["data"] as? ProfessionModel
                if selectedDesignation?.name != nil {
                    cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#373a43")
                }
            }
            
            if subType == GenericTableViewCellSubType.Religion.rawValue{
                let selectedReligion = cellData["data"] as? ProfessionModel
                if selectedReligion?.name != nil && selectedReligion?.name != "Select"{
                    cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#373a43")
                }
            }
        }
        else if subType == GenericTableViewCellSubType.Relationship.rawValue{
            let relationShipArray = cellData["data"] as? [TagModel]
            var relationShipText = ""
            if relationShipArray?.count > 0{
                cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#373a43")
                var relationshipCount = 0
                for relationship in relationShipArray ?? [TagModel()]{
                    if relationshipCount == 3{
                        break
                    }
                    if relationShipText.count > 0{
                        if let name = relationship.name{
                            relationShipText = relationShipText + ", " + name
                        }
                    }
                    else{
                        if let name = relationship.name{
                            relationShipText = name
                        }
                    }
                    relationshipCount += 1
                }
                cell?.cellValueLabel.text = relationShipText
                if relationShipArray?.count > 3{
                    cell?.moreRelationshipCountLabel.text = ", +" + "\((relationShipArray?.count ?? 4) - 3)"
                    cell?.moreRelationshipCountLabelWidthConstraint.constant = 25.0
                    cell?.moreRelationshipCountLabel.isHidden = false
                }
            }
        }
        else{
            cell?.separatorViewForCell.isHidden = true
            
            if subType == GenericTableViewCellSubType.Name.rawValue{
                cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#373a43")
            }
            if subType == GenericTableViewCellSubType.Degree.rawValue{
                let selectedCollege = cellData["data"] as? ProfessionModel
                if selectedCollege?.name != nil {
                    cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#373a43")
                }
            }
            
//            if subType == GenericTableViewCellSubType.Ethnicity.rawValue{
//                let ethnicities = cellData["data"] as? [ProfessionModel]
//                var isThereAnySelectedEthnicity = false
//                if ethnicities?.count > 0 {
//                    for item in ethnicities ?? [ProfessionModel()] {
//
//                        if ((Int(item.tagId ?? "-1") > -1) && item.isSelected == true) {
//                            isThereAnySelectedEthnicity = true
//                            break
//                        }
//                    }
//                }
//                if isThereAnySelectedEthnicity{
//                    cell?.cellValueLabel.textColor = UIColorHelper.color(withRGBA: "#373a43")
//                }
//            }
        }
        
        if isTypeOfWorkEducation{
            cell?.separatorViewForCell.isHidden = false
            cell?.topSeparatorView.isHidden = false
        }
        
        return cell!
    }
    
    func createHeaderCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : EditProfileEditCellTableViewCell? = array?.first as? EditProfileEditCellTableViewCell
        
        cell?.headerLabel.text = cellData["text"] as? String
        
        cell?.buttonTappedHandler = {(subTypeString:String) in
            if subTypeString == "RelationShip"{
                self.pushToRespectiveTagsScreenBasedOnSelection(TagCellType.RelationShip_Lifestyle)
            }
            else if subTypeString == "Zodiac"{
                self.pushToRespectiveTagsScreenBasedOnSelection(TagCellType.Zodiac)
            }
        }
        
        if let subText = cellData["subText"]{
           
            cell?.subHeaderLabel.text = subText as? String
            
        }
        else{
            cell?.subHeaderLabelHeightConstraint.constant = 0
            cell?.subHeaderLabelTopConstraint.constant = 0
        }
        if isShownFromWizard{
            cell?.backgroundColor = .white
            cell?.headerLabel.textColor = .darkGray
            cell?.subHeaderLabel.textColor = .darkGray
        }
        return cell!
    }
    
    func createQuoteCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : EditQuoteTableCell? = array?.first as? EditQuoteTableCell
        
        let qouteText = cellData["text"] as? String
        if qouteText?.count > 0{
            cell?.hintLabel.isHidden = true
        }
        else{
            cell?.hintLabel.isHidden = false
        }
        cell?.quoteTextView.text = qouteText
        cell?.quoteCounterLabel.text = "\(300 - (cell?.quoteTextView.text.utf16.count)!)"
        
        cell?.personalQouteTappedHandler = {() in
            self.scrollToPersonalQoute = true
        }
        cell?.textUpdateHandler = { (text) in
            
            self.myProfile?.personalQuote = text
            self.prepareCellDataFromProfile()
           // self.isProfileModified = true
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
        }
        
        return cell!
    }
    
    func createTagCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : EditProfileTagCell? = array?.first as? EditProfileTagCell

        var tagcelltype = TagCellType.Tags
        if let subType = cellData["subType"]{
            let subTypeString = subType as! String
            cell?.isUsedForRelationShipOrZodiac = true
            if subTypeString == "RelationShip"{
                tagcelltype = TagCellType.RelationShip_Lifestyle
            }
            else{
                tagcelltype = TagCellType.Zodiac
            }
        }
        else{
            cell?.isUsedForRelationShipOrZodiac = false
        }
        
        cell?.tagArray = cellData["data"] as? [TagModel]
        cell?.showOrHideAddButtonBasedOnData()
        cell?.collectionHolder!.tagArrayUpdateHandler = { (index) in
            switch tagcelltype {
            case .Tags:
                self.myProfile?.tags.remove(at: index)
                break
            case .RelationShip_Lifestyle:
                self.myProfile?.relationshipLifestyleTags.remove(at: index)
                //DiscoverProfileCollection.sharedInstance.myProfileData?.relationshipLifestyleTags.remove(at: index)
                break
            case .Zodiac:
                self.myProfile?.zodiac = nil
                //DiscoverProfileCollection.sharedInstance.myProfileData?.zodiac = nil
                break
            }
            self.prepareCellDataFromProfile()
           // self.editProfileTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.editProfileTableView.reloadData()
            //self.isProfileModified = true
        }
        
        cell?.addTagHandler = {
            self.pushToRespectiveTagsScreenBasedOnSelection(tagcelltype)
        }
        
        return cell!
    }
    
    func createHeightCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : EditProfileHeightTableCell? = array?.first as? EditProfileHeightTableCell
        
        cell?.heightType = (self.myProfile?.showHeightType)!

        cell?.setData((cellData["data"] as? String)!)
        
        
        cell?.heightUpdateHandler = { (height , heightUnit, heightChanged) in
            if self.myProfile?.height != height && heightChanged{
                self.myProfile?.height = height
            }
            
            if self.myProfile?.showHeightType != heightUnit && !heightChanged{
                self.myProfile?.showHeightType = heightUnit
            }
            
            self.prepareCellDataFromProfile()
        }
        
        return cell!
    }
    
    func createFBLinkedInCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : FBLinkedInCell? = array?.first as? FBLinkedInCell
        
        cell?.linkedInButtonHandler = {
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }

            
            if (self.myProfile != nil){
                if !(self.myProfile?.isLinkedInVerified)! {
                    if self.tokenGeneratorObj == nil {
                        self.tokenGeneratorObj = TokenGenerator()
                    }
                    self.tokenGeneratorObj!.delegate = self
                    self.tokenGeneratorObj!.successSelectorForTokenGenerated = #selector(self.tokenGeneratedSuccessfullyWithData)
                    self.tokenGeneratorObj!.failureSelectorForTokenGenerated = #selector(self.tokenGenerationFailedWithData)
                    
//                    let nav: UINavigationController = UINavigationController(rootViewController: self.tokenGeneratorObj!)
                    self.navigationController!.pushViewController(self.tokenGeneratorObj!, animated: true)
                    //ViewController (nav, animated: true, completion: nil)
                }
                else{
                    self.showWooLoader()
                    FBLinkedInAPIClass.logOutLinkIn(completionBlock: { (success, _response, errorCode) in
                        self.removeWooLoader()
                        if success {
                            if let response : NSDictionary = _response as? NSDictionary{
                                self.updateMyProfile(response)
                            }
                        }
                        else{
                            self.handleErrorForResponseCode(Int(errorCode))
                        }
                    })
                }
            }
            
        }
        
        cell?.fbButtonHandler = {
            
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }

            
            let fbSessionToken: String = "\(UserDefaults.standard.object(forKey: "fbSessionToken")!)"
            
            if fbSessionToken.count < 1 || fbSessionToken == "nil" {

                self.handleErrorForResponseCode(401)
                return
            }
            self.showWooLoader()
            FBLinkedInAPIClass.updateFBSyncData(withAccessToken: fbSessionToken, andCompletionBlock: { (success, _response, statusCode) in
                self.removeWooLoader()
                if success {
                    if statusCode == 200 {
                        if let response : NSDictionary = _response as? NSDictionary{
                            self.updateMyProfile(response)
                            UserDefaults.standard.set(Date(), forKey: kLastFbSyncDate)
                            UserDefaults.standard.synchronize()
                        }
                    }
                    else if statusCode == 201 {
                        // Fake Data includes Married OR other relationship status
                        print("FAKE DATA MARRIED OR other RELATIONSHIP status")
                        if let response : NSDictionary = _response as? NSDictionary{
                            if (response["fakeStatusCode"] as! NSNumber).int32Value == 9 {
                                // Relatioship Status = MARRIED
                            }
                            else {
                                // Relationship Status = Other Status
                            }
                        }
                    }
                }
                else{
                    self.handleErrorForResponseCode(Int(statusCode))
                }
            })
        }
        
        cell?.isLinkedInVerified((cellData["linkedInVerified"] as! NSNumber).boolValue)
        
        return cell!
    }
    
    func createHideFromMutualFriendCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : HideFromMutualFriendCell? = array?.first as? HideFromMutualFriendCell
        cell?.showToFriendSwitch.setOn((cellData["data"] as? NSNumber)!.boolValue, animated: false)
        cell?.valueChangedHandler = { (isOn) in
            //self.isProfileModified = true
            self.myProfile!.isMutualFriendVisible = isOn
        }
        return cell!
    }
    
    func createPhoneCaptureTableViewCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = cellData["type"] as! String
        let phoneNumber = cellData["text"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : PhoneCaptureTableViewCell? = array?.first as? PhoneCaptureTableViewCell
        cell?.delegate = self
        
        if phoneNumber.count > 0 {
            cell?.setStateForPhoneNumberLabelAndButton(true, phoneNumber: phoneNumber)
        }
        else{
            cell?.setStateForPhoneNumberLabelAndButton(false, phoneNumber: "")
        }
        
        cell?.selectionStyle = .none
        cell?.initiatePhoneVerifyFlowHandler = {() in
            
            let phoneNumber = cellData["text"] as! String
            if phoneNumber.count > 0 {
                let verifiedAlert = AlertController.showAlert(withTitle: "", andMessage: "Your account can be verified with just one number. Are you sure you want to change it", needHandler: true, withController: self)
                
                let noAction = UIAlertAction(title: "NO", style: .cancel, handler: { (alertAction:UIAlertAction) in
                    
                })
                verifiedAlert.addAction(noAction)
                
                let yesAction = UIAlertAction(title: "YES", style: .default, handler: { (alertAction:UIAlertAction) in
                    //self.moveToPhoneVerify()
                })
                verifiedAlert.addAction(yesAction)
                
                self.present(verifiedAlert, animated: true, completion: nil)
            }
            else{
               // self.moveToPhoneVerify()
            }
        }
        
        return cell!
    }
    
    
    func createQnATableViewCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        let questionAnswerArray = cellData["data"] as! [TargetQuestionModel]
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : QnATableViewCell? = array?.first as? QnATableViewCell
        cell?.updateViewBasedOnData(questionAnswerArray)
        cell?.indexHandler = {(index) in
            if index == -1{
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let QNAScreen : QuestionsViewController = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
                QNAScreen.myProfileModel = self.myProfile
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "QnA_EDIT_PROFILE_ADD_QUESTION_TAP")
                self.navigationController?.pushViewController(QNAScreen, animated: true)
            }
            else{
            self.userSelection(questionPosition: index)
            }
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func createTeamWooTableViewCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : TeamWooTableViewCell? = array?.first as? TeamWooTableViewCell
        cell?.selectionStyle = .none
        return cell!
    }
    
    func createLinkedInSyncTableViewCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        let subType = LinkedInSyncTableViewCellSubType(rawValue: cellData["subType"] as! String)
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : LinkedInSyncTableViewCell? = array?.first as? LinkedInSyncTableViewCell
        cell?.selectionStyle = .none
        var isSynced = false
        if(subType == LinkedInSyncTableViewCellSubType.Resync)
        {
            isSynced = true
        }
        
        cell?.updateViewBasedOnSyncOption(isSynced, isUsedInWorkAndEducation: isTypeOfWorkEducation)

        
        cell?.linkedInButtonHandler = {
            
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Edit_LinkedIn_Button")
            self.startLinkedInFlow()
                
            }
        return cell!
    }
    
    private func startLinkedInFlow(){
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        
        if (self.myProfile != nil){
            if self.tokenGeneratorObj == nil {
                self.tokenGeneratorObj = TokenGenerator()
            }
            self.tokenGeneratorObj!.delegate = self
            self.tokenGeneratorObj!.successSelectorForTokenGenerated = #selector(self.tokenGeneratedSuccessfullyWithData)
            self.tokenGeneratorObj!.failureSelectorForTokenGenerated = #selector(self.tokenGenerationFailedWithData)
            
            //                    let nav: UINavigationController = UINavigationController(rootViewController: self.tokenGeneratorObj!)
            self.navigationController!.pushViewController(self.tokenGeneratorObj!, animated: true)
            //ViewController (nav, animated: true, completion: nil)
        }
    }
    
    func moveToPhoneVerify(){
        
        
//        let storyboard = UIStoryboard(name: "Woo_3", bundle: nil)
//        let controller:UINavigationController = storyboard.instantiateViewController(withIdentifier: "VerifyNumberViewNavController") as! UINavigationController
//        let firstController:VerifyNumberViewController = controller.viewControllers.first as! VerifyNumberViewController
//        firstController.isOpenFromEditProfile = true
//        self.present(controller, animated: true, completion: nil)
//        firstController.verifyFlowdismissHandler = {() in
//            self.perform(#selector(self.showPhoneVerifiedPopUpNow), with: nil, afterDelay: 0.5)
//            self.myProfile = DiscoverProfileCollection.sharedInstance.myProfileData!.copy()
//            self.prepareCellDataFromProfile()
//            self.editProfileTableView.reloadData()
//        }
//        let facebookPhoneVerifyVC = FacebookPhoneVerifyViewController.init(nibName: "FacebookPhoneVerifyViewController", bundle: nil)
//        facebookPhoneVerifyVC.phoneVerifiedDelegate = self
//        self.present(facebookPhoneVerifyVC, animated: false, completion: nil)
        
//        CommonPhoneNumberVerify.sharedInstance.controller = self
//        CommonPhoneNumberVerify.sharedInstance.showLoaderAfterSucess = true
//        CommonPhoneNumberVerify.sharedInstance.successHandler =  {(success:Bool, statusCode: NSInteger) in
//            print("after server verification")
//            //self.afterServerVerification(statusCode: statusCode)
//        }
//        if (!CommonPhoneNumberVerify.sharedInstance.canWeStartTrueCaller()){
//        IQKeyboardManager.shared().isEnabled = true
//        IQKeyboardManager.shared().isEnableAutoToolbar = true
//
//        if let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil) as? AKFViewController {
////            prepareLoginViewController(viewController)
////            if let viewController = viewController as? UIViewController {
////                present(viewController, animated: true, completion: nil)
////            }
//        }
        //}
        
        //Phone authentication through firebase
        //Akarsh
        
//        let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
//
//        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
            
        //self.showWooLoader()
        
        let phoneVerifyfromWhichScreen:[String: String] = ["screen": "EditProfileViewController"]
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: kFirebasePhoneAuthenticationObserver),
            object: self,
            userInfo: phoneVerifyfromWhichScreen
        )
     }
    
    func fireBasePhoneAuth(){
        self.moveToPhoneVerify()
    }
    
    
    @objc func updateUser(not: Notification) {
        // userInfo is the payload send by sender of notification
        if let userInfo = not.userInfo {
           // Safely unwrap the name sent out by the notification sender
            if let statusCode = userInfo["statusCode"] as? Int {
                self.removeWooLoader()
                self.afterServerVerification(statusCode: NSInteger(statusCode))
            }
        }
    }
    
    
    
    func afterServerVerification(statusCode: NSInteger){
        if statusCode == 200{
            self.perform(#selector(self.showPhoneVerifiedPopUpNow), with: nil, afterDelay: 0.5)
            self.myProfile = DiscoverProfileCollection.sharedInstance.myProfileData!.copy()
            self.prepareCellDataFromProfile()
            self.editProfileTableView.reloadData()
           // refreshProfileData();
        }
        else if statusCode == 404{
            _ = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: false, withController: self)
        }
        else if statusCode == 400{
            _ = AlertController.showAlert(withTitle: "", andMessage: "We are facing some technical issue. Please retry after some time.", needHandler: false, withController: self)
        }
    }
    
//    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?) {
//        print("did sign In")
//    } 
    
    func checkPhotosPermissionCallBack() -> Bool{
        var permission = true
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted{
            permission = false
        }
        return permission
    }
    
    func checkCameraPermission(){
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            DispatchQueue.main.async {
                self.imagePickerOptions(true)
            }
            
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    self.imagePickerOptions(true)
                    
                } else {
                    //access denied
                    
                    DispatchQueue.main.async {
                        
                        let notAuthorizedAlert = UIAlertController(title: NSLocalizedString("Not Authorized", comment: ""), message: NSLocalizedString("Please enable photos for this app to use this feature.", comment: ""), preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "Cancel",
                                                         style: .cancel, handler:{ (alertAction:UIAlertAction) in
                                                            
                        })
                        
                        let otherAction = UIAlertAction(title: NSLocalizedString("CMP00356", comment: ""),
                                                        style: .default, handler:{ (alertAction:UIAlertAction) in
                                                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                                                            
                        })
                        notAuthorizedAlert.addAction(cancelAction)
                        notAuthorizedAlert.addAction(otherAction)
                        self.present(notAuthorizedAlert, animated: true, completion: nil)
                    }
                    
                }
            })
        }
    }
    
    func showImagePickerOptions(){
        let imagePickerOptions:UIAlertController = UIAlertController(title: "", message: "Where do you want to add your picture from?", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Gallery",
                                          style: .default, handler:{ (alertAction:UIAlertAction) in
                                            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_AddPhoto_gallery")
                                            self.imagePickerOptions(false)
        })
        let fbAction = UIAlertAction(title: "Facebook",
                                     style: .default, handler:{ (alertAction:UIAlertAction) in
                                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_AddPhoto_fb")
                                        self.getFacebookPhotos(authNeeded: false)
        })
             imagePickerOptions.addAction(fbAction)
        
        
        let cameraAction = UIAlertAction(title: "Camera",
                                         style: .default, handler:{ (alertAction:UIAlertAction) in
                                            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_AddPhoto_camera")
                                            DispatchQueue.main.async {
                                                self.checkCameraPermission()
                                            }
                                            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .destructive, handler:{ (alertAction:UIAlertAction) in
                                            
        })
        
        imagePickerOptions.addAction(libraryAction)
       
        imagePickerOptions.addAction(cameraAction)
        imagePickerOptions.addAction(cancelAction)
        
        self.present(imagePickerOptions, animated: true, completion: nil)
    }
    
    func imagePickerOptions(_ isCamera:Bool){
        if !self.checkPhotosPermissionCallBack(){
            let notAuthorizedAlert = UIAlertController(title: NSLocalizedString("Not Authorized", comment: ""), message: NSLocalizedString("Please enable photos for this app to use this feature.", comment: ""), preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel, handler:{ (alertAction:UIAlertAction) in
                                                
            })
            
            let otherAction = UIAlertAction(title: NSLocalizedString("CMP00356", comment: ""),
                                            style: .default, handler:{ (alertAction:UIAlertAction) in
                                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                                                
            })
            notAuthorizedAlert.addAction(cancelAction)
            notAuthorizedAlert.addAction(otherAction)
            self.present(notAuthorizedAlert, animated: true, completion: nil)
            return
        }
        
        if self.imagePicker != nil{
            self.imagePicker = nil
        }
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.imagePicker?.allowsEditing = false
        
//        if LoginModel.sharedInstance().isAlternateLogin {
                    
            if isCamera{
                
                self.imagePicker?.sourceType = .camera
                self.imagePicker?.cameraDevice = .front
                DispatchQueue.main.async {
                    self.present(self.imagePicker!, animated: true, completion: nil)
                }
                
                
            }else{
                
                print("albumCount",self.myProfile?.wooAlbum?.count())
                let cropPickerController = self.makeCropPickerController(.single, isCamera: false, maxAllowedImages: 9 - (self.myProfile?.wooAlbum?.count())!)
                
//                let navigationController = UINavigationController(rootViewController: cropPickerController)
//                navigationController.modalPresentationStyle = .fullScreen
//                self.present(cropPickerController.navigationController!, animated: true, completion: nil)
                self.navigationController?.pushViewController(cropPickerController, animated: true)
               
            }
            
//        }else{
////            if isCamera{
////                self.imagePicker?.sourceType = .camera
////                self.imagePicker?.cameraDevice = .front
////            }
////            else{
////                self.imagePicker?.sourceType = .photoLibrary
////            }
////            self.present(self.imagePicker!, animated: true, completion: nil)
//        }
    }
    
    func showLoginScreen(){
        
        FBSession.active().clearJSONCache()
        FBSession.active().close()
        FBSession.active().closeAndClearTokenInformation()
        FBSession.setActive(nil)
        FBSDKLogin.sharedManager().logOutUserFromFacebook()
        UserDefaults.standard.removeObject(forKey: "FBAccessTokenInformationKey")
        UserDefaults.standard.removeObject(forKey: "isLogginProcessCompleted")
        UserDefaults.standard.removeObject(forKey: kWooUserId)
        UserDefaults.standard.synchronize()
        WooScreenManager.sharedInstance.loadLoginView()
        
    }
    
    func authenticationFailedAlert(){
        let authenticatonAlert:UIAlertController = UIAlertController(title: NSLocalizedString("Authentication error", comment: ""), message: NSLocalizedString("Something unexpected has happened. Please login again", comment: ""), preferredStyle: .alert)
        let otherButton:UIAlertAction = UIAlertAction(title: NSLocalizedString("CMP00356", comment: ""), style: .default) { (otherButtonAction) in
            self.showLoginScreen()
        }
        authenticatonAlert.addAction(otherButton)
        self.present(authenticatonAlert, animated: true, completion: nil)
    }
    
    func selectedPhotoData(_ photoData:AnyObject){
        
        fbPhotoObjetId = "\((photoData as! NSDictionary).object(forKey: "objectId") ?? "")"
        if ((photoData as! NSDictionary).object(forKey: "srcBig") != nil){
            let strImage:String = ((photoData as! NSDictionary).object(forKey: "srcBig") as! String)
            utilities.showActivityIndicator()
            let imageGetterQueue = DispatchQueue(label: "com.woo.VPICropper", attributes: .concurrent)
            
            imageGetterQueue.async{
                if let imageUrl = URL(string: strImage){
                if let loadedImageData = NSData(contentsOf: imageUrl){
                    if let imageToSendForCropper = UIImage(data: loadedImageData as Data){
                
                DispatchQueue.main.async {
                    utilities.hideActivityIndicator()
                    self.openCropperNow(imageToSendForCropper)
                        }
                    }
                }
              }
            }
        }
        
    }
    
    
    func makeCropPickerController(_ type: CropPickerType, isCamera: Bool, maxAllowedImages: Int) -> CropPickerController {
        let cropPickerController = CropPickerController(type, isCamera: isCamera, maxAllowedImages: maxAllowedImages, comingFromEditProfile: true)
            cropPickerController.delegate = self as! CropPickerDelegate
        return cropPickerController
    }
    
    func openCropperNow(_ fbImage:UIImage){
        
        let width = SCREEN_WIDTH * 0.7361;
        let rect = CGRect(x: (SCREEN_WIDTH - width) / 2, y: 0.122 * SCREEN_HEIGHT, width: width, height: 0.655 * SCREEN_HEIGHT)
        
        var imgCropperVC: VPImageCropperViewController?
        
        imgCropperVC = VPImageCropperViewController(image: fbImage,
                                                    cropFrame: rect,
                                                    limitScaleRatio: 3)
        imgCropperVC!.albumData = AlbumPhoto()
        imgCropperVC?.wooAlbum = self.myProfile?.wooAlbum?.copy() as! WooAlbumModel
        imgCropperVC?.albumData.url = ""
        self.lastEditedPhotoIndex = -1
        imgCropperVC?.isOpenedFromWizard = true
        imgCropperVC!.isWooAlbumCallNotNeeded = true
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_AddPhoto")

        
        imgCropperVC?.imageBlock = { (imageData) in
            if imageData != nil {
//                if self.lastEditedPhotoIndex == -1 {
//                    self.myProfile?.wooAlbum?.addObject(imageData!)
//                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_AddPhoto")
//
//                }
//                else{
//                    self.myProfile?.wooAlbum?.replaceObject(imageData!, position: self.lastEditedPhotoIndex)
//                    self.lastEditedPhotoIndex = -1
//                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditPhoto")
//
//                }
                self.myProfile?.wooAlbum = imageData
                //self.isProfileModified = true
            }
            else{
                if self.lastEditedPhotoIndex != -1 {
                    //self.isProfileModified = true
                    self.myProfile?.wooAlbum?.removeObjectAt(self.lastEditedPhotoIndex)
                }
            }
            self.prepareCellDataFromProfile()
            self.editProfileTableView.reloadData()
        }
        
        self.navigationController!.pushViewController(imgCropperVC!, animated: true)
    }
    
    func getFacebookPhotos(authNeeded: Bool){
        if LoginModel.sharedInstance().isAlternateLogin{
            SwiftUtilities().getAccessTokenFromFacebook(self,isAuthNeeded: authNeeded, accessToken: { (isSucess, accessToken) in
                    if isSucess{
                        self.getPhotosFromFaceBook()
                    }
                })
        }else{
            getPhotosFromFaceBook()
        }
    }
    
    func getPhotosFromFaceBook(){
        ImageAPIClass.fetchAlbums { (response, success, statusCode) in
            if statusCode == 401{
                if (LoginModel.sharedInstance().isAlternateLogin){
                    self.showAuthPopUP()
                }else{
                    self.authenticationFailedAlert()
                }
                return
            }
            if success{
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let fbAlbumVC:FacebookAlbumViewController = mainStoryBoard.instantiateViewController(withIdentifier: kFacebookAlbumControllerID) as! FacebookAlbumViewController
                fbAlbumVC.delegate = self
                fbAlbumVC.isPresented = false
                if response != nil && response is NSDictionary{
                    if let albums = (response as! NSDictionary).object(forKey: "albums") as? [Any]{
                fbAlbumVC.arrAlbumData = albums
                    }
                }
                else{
                    fbAlbumVC.arrAlbumData = NSArray() as? [Any]
                }
                
                if let albumData = fbAlbumVC.arrAlbumData {
                 if albumData.count < 1{
                    let noAlbum:UIAlertController = UIAlertController(title: "", message: NSLocalizedString("No album found.", comment: ""), preferredStyle: .alert)
                    let okAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                    noAlbum.addAction(okAction)
                    self.present(noAlbum, animated: true, completion: nil)
                    return
                }
                }
                self.navigationController?.pushViewController(fbAlbumVC, animated: true)
                
            }
        }
    }
    
    func showAuthPopUP(){
        let alert = UIAlertController(title: "Need more details!", message: "We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Authorize Facebook", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            self.getFacebookPhotos(authNeeded: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDeleteConfirmationPopupForImage(_ toBeDeletedImage:UIImage, albumData:AlbumPhoto){
        let deletePhotoObject:DeletePhotoView = Bundle.main.loadNibNamed("DeletePhotoView", owner: self, options:nil)?.first as! DeletePhotoView
        deletePhotoObject.frame = self.view.bounds
        deletePhotoObject.setDeleteDataOnViewWith(toBeDeletedImage) {
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_EditPhoto_Delete")
            self.deleteFromUploadDictionary(imageTobeDeleted: toBeDeletedImage)
            self.deletePhoto(albumData)
        }
        
        self.view.addSubview(deletePhotoObject)
    }
    
    func deleteInCompatiblePhoto(_ albumData:AlbumPhoto, imageTobeDeleted : UIImage){
        
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("", comment: ""),message: NSLocalizedString("This photo did not meet our photo guidelines. Please upload another one.", comment:""),preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
            self.deleteFromUploadDictionary(imageTobeDeleted: imageTobeDeleted)
            self.deletePhoto(albumData)
        })
        
        let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Add a Photo", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.deleteFromUploadDictionary(imageTobeDeleted: imageTobeDeleted)
            self.deletePhoto(albumData)
            self.showImagePickerOptions()
        })
        
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        
        self.present(alert, animated: true, completion: {() -> Void in
            
        })
    }
    
    
    func deleteFromUploadDictionary(imageTobeDeleted : UIImage){
        
        var indexForDeletion : Int?
        let deleteImageData : NSData = imageTobeDeleted.pngData()! as NSData
        
        if(UserDefaults.standard.value(forKey: "uploadedDictionary") != nil){
            self.uploadImageSuccessfullDictionary = UserDefaults.standard.value(forKey: "uploadedDictionary") as! [[String : Any]]
        }
        
        
        for i in self.uploadImageSuccessfullDictionary.indices{
            
            if((self.uploadImageSuccessfullDictionary[i]["imageData"] as! NSData).isEqual(deleteImageData)){
                
               print("delete ho gya finally")
               indexForDeletion = i
                break
            }
        }
        
        print("indexForDeletion",indexForDeletion)
        if(indexForDeletion != nil){
            self.uploadImageSuccessfullDictionary.remove(at: indexForDeletion!)
            UserDefaults.standard.set(self.uploadImageSuccessfullDictionary, forKey: "uploadedDictionary")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func deletePhoto(_ album:AlbumPhoto){
        
        self.isProfileModified = true
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "EditProfile_Grid_Delete")
        ImageAPIClass.deletePhoto(forObjectID: album.objectId, andCompletionBlock: { (response, success, statusCode) in
            
            DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore = "\((response as? NSDictionary)?.object(forKey: "profileCompletenessScore") ?? "0")"
            let albumModel = WooAlbumModel()
            albumModel.isMyprofile = true
            albumModel.addObjectsFromArray((response as! NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
            self.myProfile?.wooAlbum = albumModel
            DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = albumModel
            self.prepareCellDataFromProfile()
            self.editProfileTableView.reloadData()
            
        })
    }
    
    func imageEqualityCheck(value: UIImage, isEqualTo image2: UIImage) -> Bool {
        let data1: NSData = value.pngData()! as NSData
        let data2: NSData = image2.pngData()! as NSData
        return data1.isEqual(data2)
    }
    
    
    @IBAction func segmentControlClicked(_ sender: UISegmentedControl) {
        scrollHappenedWhileChangingSegment = true
        var segmentPointIndex = 0
        switch sender.selectedSegmentIndex{
        case 0:
            break
        case 1:
            segmentPointIndex = segmentPointOfQuestions
            break
        case 2:
            segmentPointIndex = segmentPointOfOthers
            break
        default:
            break
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.editProfileTableView.scrollToRow(at: IndexPath(row: segmentPointIndex, section: 0), at: .top, animated: false)
        }) { (isCompleted) in
            self.scrollHappenedWhileChangingSegment = false
        }
    }
    
    private func pushToRespectiveTagsScreenBasedOnSelection(_ tagCellType:TagCellType){
        switch tagCellType {
        case .RelationShip_Lifestyle:
            let relationshipController = RelationshipViewController.loadNib("Relationship and Lifestyle")
            relationshipController.profileModelObject = self.myProfile
            relationshipController.setViewsfor(.PCW,tagData: .RelationshipAndLifestyle, closeBtn: false, title: "Relationship and Lifestyle")
            relationshipController.tableReloadHandler = {(tagsArray:NSMutableArray) in
                self.myProfile?.relationshipLifestyleTags = tagsArray as! [RelationshipLifestyleTagModel]
                self.prepareCellDataFromProfile()
                self.editProfileTableView.reloadData()
            }
            self.navigationController?.pushViewController(relationshipController, animated: true)
            break
        case .Zodiac:
            let relationshipController = RelationshipViewController.loadNib("Your Zodiac Sign")
            relationshipController.profileModelObject = self.myProfile
            relationshipController.setViewsfor(.PCW,tagData: .Zodiac, closeBtn: false, title: "Your Zodiac Sign")
            relationshipController.tableReloadHandler = {(tagsArray:NSMutableArray) in
                if tagsArray.count > 0{
                    self.myProfile?.zodiac = tagsArray.firstObject as? RelationshipLifestyleTagModel
                }
                else{
                    self.myProfile?.zodiac = nil
                }
                
                self.prepareCellDataFromProfile()
                self.editProfileTableView.reloadData()
            }
            self.navigationController?.pushViewController(relationshipController, animated: true)
            break
        case .Tags:
            let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
            wizardTagsVC.profileModelObject = self.myProfile
            wizardTagsVC.selectedTagsHandler = {(selectedTagsarray) in
                self.myProfile?.tags.removeAll()
                self.myProfile?.updateTags(selectedTagsarray)
                self.prepareCellDataFromProfile()
                self.editProfileTableView.reloadData()
            }
            wizardTagsVC.isUsedOutOfWizard = true
            self.navigationController?.pushViewController(wizardTagsVC, animated: true)
            break
        }
    }
    
    // MARK: - helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
//        loginViewController.delegate = self as AKFViewControllerDelegate
//        loginViewController.defaultCountryCode = "IN"
//        loginViewController.uiManager = MyUiManager(UIColor.white, isOpenedFromDiscover: false, isUsedInOnBoarding: false) as UIManager
    }
    
    @objc func showPhoneVerifiedPopUpNow(){
        self.showSnackBar("Phone number verified")
    }
    
    @objc func dismissPhoneVerifyFlow()
    {
       if(self.presentedViewController is AKFViewController)
       {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func openQuestionAnswerScreen(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let QNAScreen : QuestionsViewController = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
        self.navigationController?.pushViewController(QNAScreen, animated: true)
    }
    
    func openOptionScreenWithArrayAndType(_ dataArray:[ProfessionModel], type:String, oldTagID:String){
        let optionScreen = OptionSelectionViewController.loadNib(type)
        switch type {
        case "Work profile","Degree":
            if self.myProfile?.fbSynced == false && self.myProfile?.isLinkedInVerified == false {
                optionScreen.showSearchBar = true
                if(type == "Work profile")
                {
                    if(isTypeOfWorkEducation)
                    {
                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "PCW_DefaultList_Designation")
                    }
                    else
                    {
                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Edit_DefaultList_Designation")
                    }
                }
                else
                {
                    if(isTypeOfWorkEducation)
                    {
                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "PCW_DefaultList_Degree")
                    }
                    else
                    {
                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Edit_DefaultList_Degree")
                    }
                }

            }
            else
            {
                optionScreen.showSearchBar = false
            }
            break
        default:
            optionScreen.showSearchBar = false
        }
        optionScreen.dataSourceArr = dataArray
        optionScreen.selectionHandler = { (tagId) in
            if !tagId .isEqual("") {
                switch type {
                case "Work profile":
                    self.isWorkInfoModified = self.isWorkOrCollegeInfoChanged(tagId, oldTagID: oldTagID)
                    self.myProfile?.setSelectedDesignation(tagId, reccursiveSelection: true)
                    break
                case "Work place":
                    self.isWorkInfoModified = self.isWorkOrCollegeInfoChanged(tagId, oldTagID: oldTagID)
                    self.myProfile?.setSelectedCompany(tagId, reccursiveSelection: true)
                    break
                case "Degree":
                    self.isCollegeDegreeModified = self.isWorkOrCollegeInfoChanged(tagId, oldTagID: oldTagID)
                    self.myProfile?.setSelectedDegree(tagId, reccursiveSelection: true)
                    break
                case "College":
                    self.isCollegeDegreeModified = self.isWorkOrCollegeInfoChanged(tagId, oldTagID: oldTagID)
                    self.myProfile?.setSelectedCollege(tagId, reccursiveSelection: true)
                    break
                default:
                    break
                }
                self.prepareCellDataFromProfile()
                self.editProfileTableView.reloadData()
                //self.isProfileModified = true
            }
        }
        self.navigationController?.pushViewController(optionScreen, animated: true)
    }
    
    
    func userSelection(questionPosition:Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if (myProfile?.myQuestionsArray.count > 0) {
            alert.addAction(UIAlertAction(title: "Replace this question", style: .default, handler: { (action) in
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "QnA_REPLACE_QUESTION_TAP")
                
                let QNAScreen : QuestionsViewController = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
                
                if let selectedQuestions = self.myProfile?.myQuestionsArray[questionPosition]{
                    
                    QNAScreen.setReplacementQuestion(question: selectedQuestions, type: .replace)
                }
                QNAScreen.myProfileModel = self.myProfile
                self.navigationController?.pushViewController(QNAScreen, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Update my answer", style: .default, handler: { (action) in
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "QnA_UPDATE_ANSWER_TAP")

                let QNAAnswrScreen : QNAanswersScreenViewController = QNAanswersScreenViewController(nibName: "QNAanswersScreenViewController", bundle: Bundle.main)
                
                if let selectedQuestions = self.myProfile?.myQuestionsArray[questionPosition]{
                    QNAAnswrScreen.setAnswerTypeWithData(answerType: .update, question:selectedQuestions)
                }
                QNAAnswrScreen.myProfileModel = self.myProfile
                self.navigationController?.pushViewController(QNAAnswrScreen, animated: true)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let QNAScreen : QuestionsViewController = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
            QNAScreen.myProfileModel = self.myProfile
            self.navigationController?.pushViewController(QNAScreen, animated: true)
        }
    }
}

//MARK: UITableViewDataSource
extension EditProfileViewController: UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isTypeOfWorkEducation{
        var headerHeight = 0
        let workEducationLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 20, width: SCREEN_WIDTH - 20, height: 40))
        let increaseYourChancesLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 70, width: SCREEN_WIDTH - 20, height: 40))
            increaseYourChancesLabel.numberOfLines = 0
            increaseYourChancesLabel.text = "Increase your chances of finding like-minded people."
            increaseYourChancesLabel.font = UIFont(name: "Lato-Medium", size: 16.0)
            increaseYourChancesLabel.textAlignment = .center
            increaseYourChancesLabel.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#0077B5", alpha: 1.0)

            workEducationLabel.numberOfLines = 1
            workEducationLabel.adjustsFontSizeToFitWidth = true
            if myProfile?.isLinkedInVerified == true{
                workEducationLabel.text = "Verify your Work & Education info"
                headerHeight = 80
            }
            else{
                workEducationLabel.text = "Add Work & Education"
                headerHeight = 130
            }
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(SCREEN_WIDTH), height: headerHeight))

            if isShownFromWizard{
                headerView.backgroundColor = UIColor.white
                editProfileTableViewTopConstraint.constant = -55
                
                if SCREEN_WIDTH == Iphone_5S_Size.width{
                    workEducationLabel.font = UIFont(name: "Lato-Bold", size: 25.0)
                    editProfileTableViewbottomConstraint.constant = 40

                }
                else{
                workEducationLabel.font = UIFont(name: "Lato-Bold", size: 25.0)
                }
                workEducationLabel.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#0077B5", alpha: 1.0)
            }
            else{
                headerView.backgroundColor = UIColor.clear
                if SCREEN_WIDTH == 320{
                    editProfileTableViewTopConstraint.constant = -40
                }
                workEducationLabel.font = UIFont(name: "Lato-Bold", size: 30.0)
                workEducationLabel.textColor = UIColor.white
            }
        workEducationLabel.textAlignment = .center
        headerView.addSubview(workEducationLabel)
        if myProfile?.isLinkedInVerified == false{
            headerView.addSubview(increaseYourChancesLabel)
        }
        
        return headerView
        }
        else{
            return nil
        }
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isTypeOfWorkEducation && !isShownFromWizard{
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 90))
        footerView.backgroundColor = UIColor.clear
        let doneButton:UIButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: (SCREEN_WIDTH - 150)/2, y: 54, width: 150, height: 36)
        doneButton.backgroundColor = (Utilities.sharedUtility() as! Utilities).getUIColorObject(fromHexString: "#FA4849", alpha: 1.0)
        doneButton.setTitle("DONE", for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 14.0)
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 2.0
        doneButton.addTarget(self, action: #selector(EditProfileViewController.DoneButtonPressed(_:)), for: .touchUpInside)

        footerView.addSubview(doneButton)

        return footerView
        }
    
        return nil
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isTypeOfWorkEducation && !isShownFromWizard{
        return 90
        }
        else{
            return 0
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isTypeOfWorkEducation{
            if myProfile?.isLinkedInVerified == true{
                return 80
            }
            else{
                return 130
            }
        }
        return 0
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userdataArray.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        
        print("cellDictionary",cellDictionary)
        print("userdataArray",userdataArray)
        
        let cell : UITableViewCell
        
        let type : EditCellType = EditCellType(rawValue: cellDictionary["type"] as! String)!
        
        switch  type{
        case EditCellType.QnATableViewCell:
            cell = self.createQnATableViewCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.PhotoGalleryTableViewCell:
            cell = self.createImageGalleryCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.EditProfileGenericTableViewCell:
            cell = self.createEditGenericCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.EditProfileEditCellTableViewCell:
            cell = self.createHeaderCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.EditProfileHeightTableCell:
            cell = self.createHeightCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.EditQuoteTableCell:
            cell = self.createQuoteCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.EditProfileTagCell:
            cell = self.createTagCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.FBLinkedInCell:
            cell = self.createFBLinkedInCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.HideFromMutualFriendCell:
            cell = self.createHideFromMutualFriendCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.PhoneCaptureTableViewCell:
            cell = self.createPhoneCaptureTableViewCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case EditCellType.LinkedInSyncTableViewCell:
            cell = self.createLinkedInSyncTableViewCell(cellDictionary, tableView: tableView, indexPath: indexPath)
        case .TeamWooTableViewCell:
            cell = self.createTeamWooTableViewCell(cellDictionary, tableView: tableView, indexPath: indexPath)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension EditProfileViewController: UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        var height : CGFloat = 44.0
        
        let type : EditCellType = EditCellType(rawValue: cellDictionary["type"] as! String)!
        
        switch type {
        case EditCellType.PhotoGalleryTableViewCell:
            if let data = cellDictionary["data"] as? WooAlbumModel {
                height = self.calculateImageGalleryHeight(data)
            }
            break
        case EditCellType.EditProfileGenericTableViewCell:
            height = 49.0
            break
        case EditCellType.EditProfileEditCellTableViewCell:
            if cellDictionary["subText"] != nil{
                //let dyanamicHeight = (LoginModel.sharedInstance().isAlternateLogin == true) ? 44.0 : 64.0
                height = 80.0
            }
            else{
                height = 60.0
            }
            break
        case EditCellType.EditProfileHeightTableCell:
            height = 200.0
            break
        case EditCellType.EditQuoteTableCell:
            height = 180.0
            break
        case EditCellType.EditProfileTagCell:
            var tagcelltype = TagCellType.Tags
            if let subType = cellDictionary["subType"]{
                let subTypeString = subType as! String
                if subTypeString == "RelationShip"{
                    tagcelltype = TagCellType.RelationShip_Lifestyle
                }
                else{
                    tagcelltype = TagCellType.Zodiac
                }
            }
            height = self.calculateTagCellHeight((cellDictionary["data"] as? [TagModel])!, tagCellType: tagcelltype)

            break
        case EditCellType.FBLinkedInCell:
            height = 60.0
            break
        case EditCellType.HideFromMutualFriendCell:
            height = 60.0
            break
        case EditCellType.PhoneCaptureTableViewCell:
            height = 84.0
            break
            
        case EditCellType.LinkedInSyncTableViewCell:
                if(myProfile?.isLinkedInVerified == true)
                {
                    height = 44;
                }
                else
                {
                    //show sync with LinkedIn option
                    //if (myProfile?.fbSynced == true)
                        height = 96;
                }
            break
        case .QnATableViewCell:
            //let questionHeight : CGFloat = 10.0 + heightForView(questionModel.question, font: UIFont(name: "Lato-Regular", size: 20.0)!, width: 320 - 64)
            if myProfile?.myQuestionsArray.count > 0{
            var questionAnswerHeight:CGFloat = 0
            for questionModel in myProfile?.myQuestionsArray ?? [TargetQuestionModel()]{
                let questionText = questionModel.question
                let questionHeight = heightForView(questionText, font: UIFont(name: "Lato-Medium", size: 16.0) ?? UIFont(), width: widthDifferenceForQuestionAnswerLabel)
                questionAnswerHeight = questionAnswerHeight + questionHeight
                questionAnswerHeight = questionAnswerHeight + aswerHeightOfAnswerQnaCell + extraDifferenceOfQnaDataCell
            }
                if myProfile?.myQuestionsArray.count ?? 0 < Int(AppLaunchModel.sharedInstance()?.wooQuestionLimit ?? 3){
                    questionAnswerHeight = questionAnswerHeight + extraDifferenceOfQnaTableCell
                }
                else{
                    questionAnswerHeight = questionAnswerHeight + plusButtonDifference
                }
                return questionAnswerHeight
            }
            return 84
        case .TeamWooTableViewCell:
            return 194
        }
        
        return height
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let type : EditCellType = EditCellType(rawValue: cellDictionary["type"] as! String)!
        
        if type == EditCellType.EditProfileGenericTableViewCell  {
            if let subType = GenericTableViewCellSubType(rawValue: cellDictionary["subType"] as! String) {
                switch subType {
                case .Designation :
                    let oldTagId = myProfile?.selectedDesignation().tagId ?? KDefaultValueForWorkEducation
                    if !(oldTagId == "1"  && myProfile?.designation.count <= 2) {
                        self.openOptionScreenWithArrayAndType((myProfile?.designation)!, type: "Work profile", oldTagID: oldTagId)
                    }
                    
                    break
                case .Company :
                    let oldTagId = myProfile?.selectedCompany().tagId ?? KDefaultValueForWorkEducation
                    if !(oldTagId == "1" && myProfile?.company.count <= 2)  {
                        self.openOptionScreenWithArrayAndType((myProfile?.company)!, type: "Work place", oldTagID: oldTagId)
                    }
                    else{
                        if myProfile?.fbSynced == false && myProfile?.isLinkedInVerified == false{
                            openNextScreen = .Work_place
                            if(isTypeOfWorkEducation)
                            {
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "PCW_LinkedInSync_Company")
                            }
                            else
                            {
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Edit_LinkedInSync_Company")
                            }
                            self.startLinkedInFlow()
                        }
                    }
                    break
                case .Degree :
                    let oldTagId = myProfile?.selectedDegree().tagId ?? KDefaultValueForWorkEducation
                    if !(oldTagId == "1" && myProfile?.degree.count <= 2)  {
                        self.openOptionScreenWithArrayAndType((myProfile?.degree)!, type: "Degree", oldTagID: oldTagId)
                    }
                    break
                case .College :
                    let oldTagId = myProfile?.selectedCollege().tagId ?? KDefaultValueForWorkEducation
                    if !(oldTagId == "1" && myProfile?.college.count <= 2)  {
                        self.openOptionScreenWithArrayAndType((myProfile?.college)!, type: "College", oldTagID: oldTagId)

                    }
                    else{
                        if myProfile?.fbSynced == false && myProfile?.isLinkedInVerified == false{
                            openNextScreen = .College
                            self.startLinkedInFlow()
                            if(isTypeOfWorkEducation)
                            {
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "PCW_LinkedInSync_College")
                            }
                            else
                            {
                                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Edit_LinkedInSync_College")
                            }
                        }
                    }
                    break
                case .Location :
                    openSearchLocation()
                    break
                case .Name  :
                    if myProfile?.gender != "MALE" {
                        let optionScreen = OptionSelectionViewController.loadNib("Name")
                        optionScreen.showSearchBar = false
                        optionScreen.arrName = myProfile?.nameFormatArray() as NSArray?
                        
                        optionScreen.isNamePassed = true
                        optionScreen.selectedName = (myProfile?.myName())!
                        optionScreen.selectionHandler = { (selectedName) in
                            self.myProfile?.setShowInitialsFlag(selectedName)
                            self.prepareCellDataFromProfile()
                            self.editProfileTableView.reloadData()
                            //self.isProfileModified = true
                        }
                        self.navigationController?.pushViewController(optionScreen, animated: true)
                    }
                    break
                case .Phone :
                    showPhoneVerifyView()
                    break
                case .Religion :
                    let optionScreen = OptionSelectionViewController.loadNib("Religion")
                    optionScreen.showSearchBar = false
                    let religionArrayWithoutdoesntMatter = NSMutableArray.init(array: (myProfile?.religion)!)
                    religionArrayWithoutdoesntMatter.removeLastObject()
                    optionScreen.dataSourceArr = NSArray.init(array: religionArrayWithoutdoesntMatter) as! [ProfessionModel]
                    optionScreen.selectionHandler = { (tagId) in
                        if !tagId .isEqual("") {
                            self.myProfile?.setSelectedReligion(tagId)
                            self.prepareCellDataFromProfile()
                            self.editProfileTableView.reloadData()
                            //self.isProfileModified = true
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                        }
                    }
                    self.navigationController?.pushViewController(optionScreen, animated: true)
                    break
                case .Ethnicity :
//                    let optionScreen = EthnicitySelectionViewController.loadNib()
//                    let ethnicityArrayWithoutdoesntMatter = NSMutableArray.init(array: NSArray(contentsOfFile: Bundle.main.path(forResource: "Ethnicity", ofType:"plist")!)!)
//                    ethnicityArrayWithoutdoesntMatter.removeLastObject()
//                    optionScreen.mainDataSource = ethnicityArrayWithoutdoesntMatter as NSArray
//                    optionScreen.maxmimumSelection = 2
//                    optionScreen.isComingFromEditProfile = true
//                    if self.myProfile?.ethnicity.count > 0 {
//                        optionScreen.selectedEthnicity = []
//                        for item in (self.myProfile?.ethnicity)! {
//                            if((Int(item.tagId!)! > -1) && (item.isSelected == true)) {
//                                optionScreen.selectedEthnicity.append(item.name!)
//                            }
//                        }
//                    }
//
//                    optionScreen.selectionHandler = { (selectedData) in
//                        if selectedData.count > 0 {
//                            self.myProfile?.ethnicity =  (self.myProfile?.professionModelArrayFromDto((selectedData as? [[String : AnyObject]])!))!
//
//                            //setting value of selected to true
//
//                            for ethItem in (self.myProfile?.ethnicity)! {
//                                ethItem.isSelected = true
//                            }
//
//                            self.prepareCellDataFromProfile()
//                            self.editProfileTableView.reloadData()
//                            //self.isProfileModified = true
//                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
//                        }
//                        else {
//                            if self.myProfile?.ethnicity.count != 0  {
//                                self.myProfile?.ethnicity.removeAll()
//
//                                self.prepareCellDataFromProfile()
//                                self.editProfileTableView.reloadData()
//                                //self.isProfileModified = true
//                                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
//                            }
//                        }
//                    }
//                    self.navigationController?.pushViewController(optionScreen, animated: true)
                    break
                case .Relationship:
                    self.pushToRespectiveTagsScreenBasedOnSelection(TagCellType.RelationShip_Lifestyle)

                    break
                }
            }
        }
        else if type == EditCellType.QnATableViewCell{
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "QnA_EDIT_PROFILE_EMPTY_STATE_LAYOUT_TAP")
            self.userSelection(questionPosition: 0)
        }
        
    }
}


extension EditProfileViewController : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        if scrollView.contentOffset.y > 0 {
            navBarView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            navBarView.layer.shadowOpacity = 1.0
            navBarView.layer.shadowColor = UIColor.gray.cgColor
        }
        else{
            navBarView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            navBarView.layer.shadowOpacity = 0.0
        }
        */
        print("lastcontentOffest = \(lastContentOffset)")
        print("contentOffest.y = \(scrollView.contentOffset.y)")
        let visibleCellIndexesArray = editProfileTableView.indexPathsForVisibleRows
        print("visible cell Indexes = %@",visibleCellIndexesArray)
        
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            // did move up
            print("moving up")
            if scrollHappenedWhileChangingSegment == false{
                if visibleCellIndexesArray?.contains(IndexPath(row: 0, section: 0)) == false{
                    if visibleCellIndexesArray?.contains(IndexPath(row: 2, section: 0)) == false && visibleCellIndexesArray?.contains(IndexPath(row: 1, section: 0)) == false{
                        editProfileSegmentedControl.selectedSegmentIndex = 2
                    }
                    else{
                        editProfileSegmentedControl.selectedSegmentIndex = 1
                    }
                }
            }
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            // did move down
            print("moving down")
            if scrollHappenedWhileChangingSegment == false{
                    if visibleCellIndexesArray?.contains(IndexPath(row: 2, section: 0)) == true && visibleCellIndexesArray?.contains(IndexPath(row: 1, section: 0)) == true && visibleCellIndexesArray?.contains(IndexPath(row: 0, section: 0)) == true{
                        if scrollView.contentOffset.y <= 0{
                            editProfileSegmentedControl.selectedSegmentIndex = 0
                        }
                        else{
                            editProfileSegmentedControl.selectedSegmentIndex = 1
                        }

                    }
                    else if visibleCellIndexesArray?.contains(IndexPath(row: 0, section: 0)) == true && visibleCellIndexesArray?.count == 1{
                        editProfileSegmentedControl.selectedSegmentIndex = 0
                }
            }
         }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        //closeKeyBoard()
    }
}

// MARK: - AKFViewControllerDelegate extension

//extension EditProfileViewController: AKFViewControllerDelegate {
//
//
//    internal func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith accessToken: AKAccessToken, state: String) {
//        IQKeyboardManager.shared().isEnabled = false
//        IQKeyboardManager.shared().isEnableAutoToolbar = false
//        self.showWooLoader()
//        PhoneVerifyApiClass.verifyPhone(forAccessToken: accessToken.tokenString, request: false, trueCallerParameters: nil, withCompletionBlock: { (success, response, statusCode) in
//            self.removeWooLoader()
//            self.afterServerVerification(statusCode: NSInteger(statusCode))
//        })
//    }
//
//    func afterServerVerification(statusCode: NSInteger){
//        if statusCode == 200{
//            self.perform(#selector(self.showPhoneVerifiedPopUpNow), with: nil, afterDelay: 0.5)
//            self.myProfile = DiscoverProfileCollection.sharedInstance.myProfileData!.copy()
//            self.prepareCellDataFromProfile()
//            self.editProfileTableView.reloadData()
//            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
//          DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
//            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
//            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
//            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
//            DiscoverProfileCollection.sharedInstance.paginationToken = ""
//            DiscoverProfileCollection.sharedInstance.paginationIndex = ""
//
//            DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
//                if success{
//                }
//            })
//        }
//        else if statusCode == 404{
//            _ = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: false, withController: self)
//        }
//        else if statusCode == 400{
//            _ = AlertController.showAlert(withTitle: "", andMessage: "We are facing some technical issue. Please retry after some time.", needHandler: false, withController: self)
//        }
//    }
//
//    private func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
//        IQKeyboardManager.shared().isEnabled = false
//        IQKeyboardManager.shared().isEnableAutoToolbar = false
//    }
//
//    internal func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)) {
//        IQKeyboardManager.shared().isEnabled = false
//        IQKeyboardManager.shared().isEnableAutoToolbar = false
//    }
//}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage]{
            fbPhotoObjetId = nil
            openCropperNow(imagePicked as! UIImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let notificationName = Notification.Name("Test")
}

extension EditProfileViewController: CropPickerDelegate{
    
    func cropPickerBackAction(_ cropPickerController: CropPickerController) {
        if (cropPickerController.navigationController?.viewControllers.first as? CropPickerController) == nil {
            cropPickerController.navigationController?.popViewController(animated: true)
        } else {
            cropPickerController.dismiss(animated: true, completion: nil)
        }
    }
    
    func cropPickerCompleteAction(_ cropPickerController: CropPickerController, images: [UIImage]?, error: Error?, navigationController: UINavigationController) {
        
        cropPickerController.navigationController?.popViewController(animated: true)
        
        if let error = error as NSError? {
            let alertController = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            cropPickerController.present(alertController, animated: true, completion: nil)
            return
        }
        
        if let images = images {
            
            for image in images {
                remainingImagesForUploadingOnDiscover.append(image.pngData()!)
            }
            
            self.photoForMatching = 0
            
            uploadImage(imageData: self.remainingImagesForUploadingOnDiscover[0])
            
            UserDefaults.standard.set(remainingImagesForUploadingOnDiscover, forKey: "croppedImagesArrayForPhotoGalleryTableViewCell")
            
            self.prepareCellDataFromProfile()
            self.editProfileTableView.reloadData()
           
        }
        
    }
    
    func uploadImage(imageData: Data){
        
        let image = UIImage(data: imageData)
        
        ImageAPIClass.uploadImage(toServer: image, andObjectId: "", withFakeCheck: true) { (response, success, stausCode) in
                if(success){
                    
                let lastElementArray : NSArray = (response as! NSDictionary).object(forKey: "wooAlbum") as! NSArray
                
                let lastElementDetails :NSDictionary = lastElementArray[lastElementArray.count - 1] as! NSDictionary
                
                let imageData = try! Data(contentsOf: URL(string: lastElementDetails["cachedSrcBig"] as! String)!)
                let savedImage = UIImage(data: imageData)!
                
                self.uploadImageSuccessfullDictionary.append([
                    "imageURL"  : lastElementDetails["cachedSrcBig"]!,
                    "status"    : lastElementDetails["photoStatus"]!,
                    "imageData" : savedImage.pngData()! as NSData
                ])
                    
                self.remainingImagesForUploadingOnDiscover.remove(at: 0)
                    
                WooScreenManager.sharedInstance.uploadImageisStillProcessing = true
                    
                print("xyz",self.remainingImagesForUploadingOnDiscover)
                    
                UserDefaults.standard.set(self.remainingImagesForUploadingOnDiscover, forKey: "croppedImagesArrayForPhotoGalleryTableViewCell")
                UserDefaults.standard.synchronize()
                
                if(self.remainingImagesForUploadingOnDiscover.count == 0){
                    print("hahahaha")
                    UserDefaults.standard.removeObject(forKey: "croppedImagesArrayForPhotoGalleryTableViewCell")
                }
                    
                UserDefaults.standard.set(self.remainingImagesForUploadingOnDiscover, forKey: "totalImagesForUploading")
                UserDefaults.standard.synchronize()
                    
                UserDefaults.standard.set(self.uploadImageSuccessfullDictionary, forKey: "uploadedDictionary")
                UserDefaults.standard.synchronize()
                    
                    self.photoForMatching += 1
                    
                    print("reload data")

                    self.prepareCellDataFromProfile()
                    self.editProfileTableView.reloadData()
                    
                    WooScreenManager.sharedInstance.refreshTheEditProfileScrceen(updateDictionary: self.remainingImagesForUploadingOnDiscover as NSArray, responseDictionary: response as! NSDictionary)
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        
                        if(self.remainingImagesForUploadingOnDiscover.count != 0){
                            self.uploadImage(imageData: self.remainingImagesForUploadingOnDiscover[0])
                        }
                    
                    }
                    
                }
                
            }
    }
    
}


