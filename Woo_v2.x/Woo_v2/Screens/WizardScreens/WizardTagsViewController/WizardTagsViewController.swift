//
//  WizardTagsViewController.swift
//  Woo_v2
//
//  Created by Ankit Batra on 09/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class WizardTagsViewController: UIViewController, VPImageCropperDelegate {

    @IBOutlet weak var searchButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var seperatorImageView: UIImageView!
    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedTagsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allTagsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var increaseChanceLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var  kBottomBarHeight : Float = 50.0
    @IBOutlet weak var selectedTagCollectionView: UICollectionView!
    @IBOutlet weak var tagViewBottomHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTagsButton: UIButton!
    @IBOutlet weak var minimumTagsTextLabel: UILabel!
    
    @IBOutlet weak var wizardStepNumberLabel: UILabel!
    @IBOutlet weak var tagsSubTextView : UIView!
    @IBOutlet weak var allTagsCollectionView: UICollectionView!
    
    @IBOutlet weak var customJustifiedFlowLayoutForSelectedTags: ERJustifiedFlowLayout!
    
    var sizingCell : TagCollectionViewCell?

    var mainTagsArray : NSMutableArray?
    var initallySelectedTags : NSMutableArray?
    var selectedTagsArray : NSMutableArray?
    var totalSelectedTagsArray : NSMutableArray?
    var isShowMoreTagButtonVisible  = false
    var indexToBeAnimated = -1
    var isTagViewFullyVisible = false
    var indexOfTagCreepingOut = -1
    var kOriginalHeight : CGFloat = 130.0

    var isCloseTapped = false
    var customLoader:WooLoader?
    var profileModelObject:MyProfileModel?
    var isUserGoingToFindTags = false
    @objc var isUsedOutOfWizard = false
    @objc var isPartOfOnboarding = false
    @objc var isThisFirstScreenAfterRegistration = false
    
    var selectedTagsHandler:((NSMutableArray)->Void)!
    var cropperIsAlreadyOpen:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            closeTopConstraint.constant = 40
        }
        //search button UI
        searchTagsButton.layer.borderWidth = 1.0
        searchTagsButton.layer.borderColor = UIColorHelper.color(withRGBA: "#E9E9E9").cgColor
        //Setup subtext
        switch LoginModel.sharedInstance().minTagsAllowedCount {
        case 0:
            minimumTagsTextLabel.text = "Add tags to your profile"
            break
            
        case 1:
            minimumTagsTextLabel.text = "Add atleast 1 tag"
            break
            
        default:
            minimumTagsTextLabel.text = "Add atleast \(LoginModel.sharedInstance().minTagsAllowedCount) tags"
            break
            
        }
        //
        mainTagsArray = NSMutableArray(array: TagsModel.sharedInstance().allTags as! [Any], copyItems: true)

       //set  initial values for Selectedtags and maintags = main - selected
        setInitialSelectedValues()
        
        if isUsedOutOfWizard{
            nextButton.setTitle("DONE", for: .normal)
            increaseChanceLabel.text = "Add tags that describe you best to meet like-minded people."
            increaseChanceLabel.textColor = UIColorHelper.color(fromRGB: "#616161", withAlpha: 1.0)
            minimumTagsTextLabel.textColor = UIColorHelper.color(fromRGB: "#616161", withAlpha: 1.0)
            if isPartOfOnboarding{
                searchButtonBottomConstraint.constant = 0
                searchButtonHeightConstraint.constant = 0
                searchTagsButton.isHidden = true
                headerLabel.textColor = UIColorHelper.color(fromRGB: "#A0A0A0", withAlpha: 1.0)
                headerLabel.text = "Choose interests"
                let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
                let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
                let onboardingPageNumber:Int = Int(pagesDict.object(forKey: "pageNumber") as! String) ?? 1
                if onboardingPageNumber <= Int(ON_BOARDING_PAGE_NUMBER_ONE.rawValue) && !(LoginModel.sharedInstance()?.isAlternateLogin)!{
                    backButton.isHidden = true
                }
                else if (LoginModel.sharedInstance()?.isAlternateLogin)!{
                    if isThisFirstScreenAfterRegistration{
                        backButton.isHidden = true
                    }
                    else{
                        backButton.isHidden = false
                    }
                }
            }
            else{
            backButton.isHidden = true
            wizardStepNumberLabel.isHidden = true
            }
            closeButton.isHidden = true
            
        }
        else{
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE"{
            increaseChanceLabel.text = "Increase your chances of being discovered."
        }
        }
       
        //get main Tags from server if any
        let reachability = AFNetworkReachabilityManager.shared()
        let isNetworkReachable = (reachability!.isReachable || reachability!.isReachableViaWiFi || reachability!.isReachableViaWWAN)
        if (isNetworkReachable == false)
        {
            //show no internet screen
            loadingNoInternetScreenwithTag()
        }
        else
        {
            self.getTagsDataFromServerAndUpdateView()
        }
       
        // Do any additional setup after loading the view.
        let cellnib = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        self.allTagsCollectionView.register(cellnib , forCellWithReuseIdentifier: "TagCollectionViewCell")
        sizingCell = cellnib.instantiate(withOwner: nil, options: nil).first as? TagCollectionViewCell
        
        self.selectedTagCollectionView.register(cellnib , forCellWithReuseIdentifier: "TagCollectionViewCell")

//        customJustifiedFlowLayout.setTagIsMovingOutOfViewBlock { (indexOfTag, isTagMoving) in
//            NSLog("indexOfTag: \(indexOfTag)")
//        }
        /*
        customJustifiedFlowLayout.horizontalJustification = .center
        customJustifiedFlowLayout.notifyWhenTagWillGoBeyondViewHeight = false
        customJustifiedFlowLayout.horizontalCellPadding = 5;
        customJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 20)
        */
        /////
        
        
        isShowMoreTagButtonVisible = false
        customJustifiedFlowLayoutForSelectedTags.horizontalJustification = .center
        customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
        customJustifiedFlowLayoutForSelectedTags.horizontalCellPadding = 5;
        customJustifiedFlowLayoutForSelectedTags.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        customJustifiedFlowLayoutForSelectedTags.setTagIsMovingOutOfViewBlock { (indexOfTag, isTagMoving) in
            self.indexOfTagCreepingOut = Int(indexOfTag)
            NSLog("indexOfTag: \(indexOfTag)")
            self.indexToBeAnimated = -1
            self.makeDataAccordingToTheView(OutOfViewIndex: Int(indexOfTag))
        }
        setupBottomArea()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colorTheStatusBar(withColor: UIColor.white)
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "AnalyzeProfile_Tags_Landing")
        //set  initial values for Selectedtags and maintags = main - selected
     if(isUserGoingToFindTags == false)
     {
        setInitialSelectedValues()
    }
        self.isUserGoingToFindTags = false
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setInitialSelectedValues()
    {
        self.selectedTagsArray =  NSMutableArray()
        //array: TagsModel.sharedInstance().selectedTags as! [Any], copyItems: true)
        self.totalSelectedTagsArray = NSMutableArray()
        //array: TagsModel.sharedInstance().selectedTags as! [Any], copyItems: true)
        self.initallySelectedTags = NSMutableArray()
        
        if profileModelObject == nil{
            profileModelObject = DiscoverProfileCollection.sharedInstance.myProfileData?.copy()
        }
        if(profileModelObject?.tags.count ?? 0 > 0)
        {
            //Change TO array of dictionaries and set as selected Tags
            for tagmodel in (profileModelObject?.tags)!
            {
                let tagsDictionary = NSMutableDictionary()
                tagsDictionary.setValue(tagmodel.name, forKey: "name")
                tagsDictionary.setValue("", forKey: "tagColorCode")
                tagsDictionary.setValue(NSNumber(integerLiteral: Int(tagmodel.tagId!)!), forKey: "tagId")
                tagsDictionary.setValue(tagmodel.tagsDtoType, forKey: "tagsDtoType")
                self.selectedTagsArray?.add(NSDictionary(dictionary: tagsDictionary))
                self.totalSelectedTagsArray?.add(NSDictionary(dictionary: tagsDictionary))
                self.initallySelectedTags?.add(NSDictionary(dictionary: tagsDictionary))
            }
        }
        
        //remove selected tags form mainTags
        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
        {
            for selectedtagsDictionary in self.totalSelectedTagsArray!
            {
                for tagsDictionary in self.mainTagsArray!
                {
                    if( (((tagsDictionary as! NSDictionary).object(forKey: "tagId")) as! NSNumber).intValue ==  (((selectedtagsDictionary as! NSDictionary).object(forKey: "tagId")) as! NSNumber).intValue)
                    {
                        self.mainTagsArray?.remove(tagsDictionary)
                    }
                }
            }
        }
        //Check if need to show or hide views based on tags
        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
        {
            self.selectedTagCollectionView.isHidden = false
            self.tagsSubTextView.isHidden = true
        }
        else
        {
            self.selectedTagCollectionView.isHidden = true
            self.tagsSubTextView.isHidden = false
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
            utilitiesObj.decreaseOnBoardingPageNumber()
            
            let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
            let onboardingPageNumber:Int = Int(pagesDict.object(forKey: "pageNumber") as! String) ?? 1
            
            if onboardingPageNumber == Int(ON_BOARDING_PAGE_NUMBER_ONE.rawValue) {
                cropperIsAlreadyOpen = true
            }
        }
        else{
            WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
            
            if(WizardScreensCalculator.sharedInstance.currentWizardScreen == 1){
                cropperIsAlreadyOpen = true
            }
        }
        
//        self.navigationController?.popViewController(animated: true)
        
        if WizardScreensCalculator.sharedInstance.isCropperVisible == true && cropperIsAlreadyOpen == true {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
           
            WizardScreensCalculator.sharedInstance.isCropperVisible = false
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "AnalyzeProfile_Tags_Next")

        if isUsedOutOfWizard{
            if(self.totalSelectedTagsArray?.count ?? 0 >= LoginModel.sharedInstance().minTagsAllowedCount)
            {
                if isPartOfOnboarding{
                    
                    (Utilities() as AnyObject).increaseOnBoardingPageNumber()

                    TagScreenAPIClass.postTagsDataToServer(withTagsArray: self.totalSelectedTagsArray as? [Any], withType: "TAGS") { (success, statusCode, response) in
                        if ((LoginModel.sharedInstance()?.personalQuoteText) == nil) && LoginModel.sharedInstance()?.profilePicUrl != nil{
                            if LoginModel.sharedInstance()?.gender == "MALE"{
                                (Utilities() as AnyObject).sendToDiscover()
                            }
                        }
                    }
                    let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)
                    if LoginModel.sharedInstance()?.personalQuoteText != nil{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            let aboutMeScreenViewController:AboutMeScreenViewController = storyBoard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
                            self.navigationController?.pushViewController(aboutMeScreenViewController, animated: true)
                        }
                    }
                    else if LoginModel.sharedInstance()?.profilePicUrl == nil{
                        if LoginModel.sharedInstance()?.isAlternateLogin ?? false{
                            (Utilities() as AnyObject).sendToDiscover()
                        }
                        else{
                            let width = SCREEN_WIDTH * 0.7361
                            let imgCropperVC: VPImageCropperViewController = VPImageCropperViewController(image: UIImage(named:"crop_default"), cropFrame: CGRect(x: (SCREEN_WIDTH-width)/2, y: 0.122*SCREEN_HEIGHT, width: width, height: 0.655*SCREEN_HEIGHT), limitScaleRatio:Int(3.0))
                            imgCropperVC.isImageAdded = true;
                            imgCropperVC.delegate = self
                            self.navigationController?.pushViewController(imgCropperVC, animated: true)
                        }
                    }
                    else{
                        if LoginModel.sharedInstance()?.isAlternateLogin ?? false{
                            (Utilities() as AnyObject).sendToDiscover()
                        }
                        else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let  id = UserDefaults.standard.object(forKey: "id") {
                                    let wooid:NSString = id as! NSString
                                    ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue)) { (response, success, statusCode) in
                                        let wizardPhotoScreen = WizardPhotoViewController(nibName: "WizardPhotoViewController", bundle: nil)
                                        LoginModel.sharedInstance().isNewUserNoPicScreenOn = false
                                        self.navigationController?.pushViewController(wizardPhotoScreen, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
                else{
                
            if selectedTagsHandler != nil{
                selectedTagsHandler(totalSelectedTagsArray ?? NSMutableArray())
            }
            self.navigationController?.popViewController(animated: true)
                }
            }
            else{
                WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("Please select minimum \(LoginModel.sharedInstance().minTagsAllowedCount) tags", comment: ""))

            }
        }
        else{
        if(self.totalSelectedTagsArray?.count ?? 0 >= LoginModel.sharedInstance().minTagsAllowedCount)
        {
            isCloseTapped = false
            
            if(hasUserChangedTags() == true)
            {
                if checkIfFlowIsComplete(){
                    showWooLoader()
                    sendDataToServer()
                }
                else{
                    sendDataToServer()
                    WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                }
            }
            else
            {
                if self.checkIfFlowIsComplete(){
                    self.showWizardCompleteView(true)
                }
                else
                {
                    WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                }
            }
        }
        else
        {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("Please select minimum \(LoginModel.sharedInstance().minTagsAllowedCount) tags", comment: ""))
        }
        }
    }
    
    func sendDataToServer(){
        
        if (self.mainTagsArray?.count)! > 0{
        let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        
        myProfileDictionary["tagsDtos"] = self.totalSelectedTagsArray as! [Any]
            var _relationshipDtos : [NSMutableDictionary] = []
            for item in (DiscoverProfileCollection.sharedInstance.myProfileData?.relationshipLifestyleTags)! {
                _relationshipDtos.append(item.dictionarifyForSendingToServer())
            }
            myProfileDictionary["relationShipAndLifeStyle"] = _relationshipDtos
            
            if let zodiacData = DiscoverProfileCollection.sharedInstance.myProfileData!.zodiac{
                myProfileDictionary["zodiac"] = zodiacData.dictionarifyForSendingToServer()
            }
        
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((profileModelObject?.jsonfyForDictionary(myProfileDictionary))!)
            TagsModel.sharedInstance().updateSelectedTags(self.totalSelectedTagsArray)
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "AnalyzeProfile_Tags_Tap")
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
            
            let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is WizardTagsViewController
            if !currenViewControllerIsSelf{
                return
            }
            self.hideWooLoader()
            if self.isCloseTapped{
            self.isCloseTapped = false
            if success{
                //set initial array same as selected
                self.initallySelectedTags?.removeAllObjects()
                self.initallySelectedTags = NSMutableArray(array:self.totalSelectedTagsArray as! [Any], copyItems: true)
                //
                    if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                        self.showWizardCompleteView(false)
                    }
                    else{
                        if self.checkIfFlowIsComplete(){
                            self.showWizardCompleteView(true)
                        }
                        else{
                        self.checkIfToShowDiscoverOrMe()
                        self.navigationController?.popToRootViewController(animated: true)
                        }
                        }
                }
            }
            else{
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                }
            }
        }
    }
    
    func showWooLoader(){
        customLoader?.removeFromSuperview()
        customLoader = nil
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        customLoader?.shouldShowWooLoader = false
        
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
        }, completion: { (true) in
            self.customLoader?.stopAnimation()
            self.customLoader?.removeFromSuperview()
        })        
    }
    
    func setupBottomArea(){
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            nextButton.setTitle("DONE", for: .normal)
        }
        else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            backButton.isHidden = true
        }
        if isPartOfOnboarding{
            wizardStepNumberLabel.isHidden = true
            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
            let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
            wizardStepNumberLabel.text = "\(pagesDict.object(forKey: "pageNumber") ?? "1") of \(pagesDict.object(forKey: "totalPages") ?? "1")"
            nextButton.setTitle("NEXT", for: .normal)
            
        }
        else{
        wizardStepNumberLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
        }
    }
    
    func showWizardCompleteView(_ isCompleted:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
            self.navigationController?.popToRootViewController(animated: true)
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
    
    func checkIfFlowIsComplete() -> Bool{
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            return true
        }
        else{
            return false
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "AnalyzeProfile_Tags_Close")
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
      if(self.totalSelectedTagsArray?.count ?? 0 >= LoginModel.sharedInstance().minTagsAllowedCount)
      {
            isCloseTapped = true

        if(hasUserChangedTags() == true)
        {
            showWooLoader()
            sendDataToServer()
        }
        else
        {
            if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                self.showWizardCompleteView(false)
            }
            else{
                if self.checkIfFlowIsComplete(){
                    self.showWizardCompleteView(true)
                }
                else{
                    self.checkIfToShowDiscoverOrMe()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
      }
      else
      {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("Please select minimum \(LoginModel.sharedInstance().minTagsAllowedCount) tags", comment: ""))
        }
    }

    
    @IBAction func searchTagsButtonTapped(_ sender: UIButton)
    {
        let mainStoryboard = UIStoryboard(name: "onboarding", bundle: nil)
        let findTagsVc = mainStoryboard.instantiateViewController(withIdentifier: "FindTagViewController") as! FindTagViewController
        findTagsVc.selectedTagArray = self.totalSelectedTagsArray
        findTagsVc.tagSelectionBlock = { tagsArray in
            NSLog("\(tagsArray!)")
            self.totalSelectedTagsArray?.removeAllObjects()
            self.totalSelectedTagsArray?.addObjects(from:tagsArray as! [Any])
            if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
            {
                self.selectedTagCollectionView.isHidden = false
                self.tagsSubTextView.isHidden = true
            }
            else
            {
                self.selectedTagCollectionView.isHidden = true
                self.tagsSubTextView.isHidden = false
            }
            self.indexToBeAnimated = -1
            self.makeNewDataAccordingToTheView(OutOfViewIndex: self.indexOfTagCreepingOut == -1 ? (self.totalSelectedTagsArray?.count ?? 0) : self.indexOfTagCreepingOut)
           // self.isUserGoingToFindTags = false
        }
        
        self.isUserGoingToFindTags = true
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "AnalyzeProfile_Tags_Search")
        self.navigationController?.pushViewController(findTagsVc, animated: true)
    }
    
    func getTagsDataFromServerAndUpdateView()
    {
        //allTagsActivityIndicator.isHidden = false
        TagsModel.sharedInstance().getNewTagsIfAny { (newTagsArray) in
            if(newTagsArray != nil && newTagsArray?.count ?? 0 > 0)
            {
                var  tagsArrayTemp = newTagsArray!
                tagsArrayTemp = tagsArrayTemp.shuffled()
                let alreadyPresentTagsArray = NSMutableArray(array:self.mainTagsArray as! [Any] , copyItems: true)
                let newAllTagsArray = NSMutableArray(array:tagsArrayTemp, copyItems: true)
                newAllTagsArray.removeObjects(in: alreadyPresentTagsArray as! [Any])
                self.mainTagsArray?.addObjects(from:newAllTagsArray as! [Any])
                
            }
            else
            {
                self.mainTagsArray = NSMutableArray(array: (TagsModel.sharedInstance().allTags as! [Any]), copyItems: true)
            }

            if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
            {
                for selectedtagsDictionary in self.totalSelectedTagsArray!
                {
                    for tagsDictionary in self.mainTagsArray!
                    {
                        if( (((tagsDictionary as! NSDictionary).object(forKey: "tagId")) as! NSNumber).intValue ==  (((selectedtagsDictionary as! NSDictionary).object(forKey: "tagId")) as! NSNumber).intValue)
                        {
                            self.mainTagsArray?.remove(tagsDictionary)
                        }
                    }
                }
                self.selectedTagCollectionView.isHidden = false
                self.tagsSubTextView.isHidden = true
                
            }
            else
            {
                self.selectedTagCollectionView.isHidden = true
                self.tagsSubTextView.isHidden = false
            }
            self.allTagsCollectionView.reloadData()
        }
    }
    
    func loadingNoInternetScreenwithTag() {
        
        let noInternetView = NoInternetScreenView(frame: CGRect(x: 0, y: self.tagsSubTextView.frame.origin.y, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - self.tagsSubTextView.frame.origin.y - CGFloat(kBottomBarHeight)))
        noInternetView.delegate = self
        noInternetView.tag = 10000
        noInternetView.showLoader = false
        self.view.addSubview(noInternetView)
    }
    
    fileprivate func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    func imageCropper(_ cropperViewController: VPImageCropperViewController!, didFinished editedImageData: [AnyHashable : Any]!) {
    
    cropperViewController.navigationController?.popViewController(animated: false)
        (Utilities() as AnyObject).sendToDiscover()
    }
    
    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController!) {
        cropperViewController.navigationController?.popViewController(animated: false)
        (Utilities() as AnyObject).sendToDiscover()
        
    }

}

extension WizardTagsViewController
{
    func refreshButtonClicked(_ snder: UIButton)
    {
        let reachability = AFNetworkReachabilityManager.shared()
        let isNetworkReachable = (reachability!.isReachable || reachability!.isReachableViaWiFi || reachability!.isReachableViaWWAN)
        if (isNetworkReachable == true)
        {
            self.removeNoInternetScreenWithTag()
            self.getTagsDataFromServerAndUpdateView()
        }
    }
    
    func removeNoInternetScreenWithTag()
    {
        for view in self.view.subviews
        {
            if(view.tag == 10000){
                view.removeFromSuperview()
            }
        }
    }
    
    func hasUserChangedTags() -> Bool
    {
        if(self.initallySelectedTags?.count != self.totalSelectedTagsArray?.count)
        {
            return true
        }
        else
        {
            //when tag count is same
            //Check if tags contained are the same
            //need to check with tagsIDs
        let tempTagsDictionary = NSMutableArray(array: self.initallySelectedTags as! [Any], copyItems: true)
          for selectedTagsDictionary in self.totalSelectedTagsArray!
          {
                var elementFound = false
                for  intialTagsDictionary in self.initallySelectedTags!
                {
                    if( (((intialTagsDictionary as! NSDictionary).object(forKey: "tagId")) as! NSNumber).intValue ==  (((selectedTagsDictionary as! NSDictionary).object(forKey: "tagId")) as! NSNumber).intValue)
                    {
                        tempTagsDictionary.remove(intialTagsDictionary)
                        elementFound = true
                    }
                }
                if(elementFound == false)
                {
                    return true
                }
            }
            if(tempTagsDictionary.count == 0)
            {
                return false
            }
            else
            {
                return true
            }
        }
    }
}
extension WizardTagsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == allTagsCollectionView)
        {
            return mainTagsArray?.count ?? 0
        }
        else
        {
            return selectedTagsArray?.count ?? 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        if(collectionView == allTagsCollectionView)
        {
            configureCell(sizingCell!, forIndexPath: indexPath)
        }
        else
        {
            configureSelectedTagsCell(sizingCell!, forIndexPath: indexPath)
        }
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "12.0"){
            if let ns_str:NSString = sizingCell?.stringLabel.text as NSString? {
                
                let sizeOfString = ns_str.boundingRect(
                    with:CGSize(width: sizingCell?.stringLabel.frame.size.width ?? 200, height: CGFloat.infinity),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: [NSAttributedString.Key.font: sizingCell?.stringLabel.font! ?? UIFont(name: "Lato-Regular", size: 14.0)!],
                    context: nil).size
                return CGSize(width: sizeOfString.width + 50, height: 32)
            }
        }
        return self.sizingCell!.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == allTagsCollectionView)
        {
            let cell: TagCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell)!
            self.configureCell(cell, forIndexPath: indexPath)
            return cell
        }
        else
        {
            let cell: TagCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell)!
            self.configureSelectedTagsCell(cell, forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        if(collectionView == allTagsCollectionView)
        {
        }
        else
        {
        }
    }
    func configureCell(_ cell:TagCollectionViewCell, forIndexPath indexpath:IndexPath)
    {
     
        let cellDetail = mainTagsArray?.object(at: indexpath.row) as! [AnyHashable:Any]
        cell.itemData = cellDetail
        cell.labelText = cellDetail[kTagsNameKey] as? String ?? ""
        cell.animateMyView { (completed) in
            NSLog("success")
        }
        cell.destroyCellOnSelection =  !(self.totalSelectedTagsArray?.count ?? 0 >= LoginModel.sharedInstance().maxTagsAllowedCount)

        cell.destroyMe { (success, destroyedObj) in
            if(success)
            {
               //called when the cell is tapped
                //Add to selectedTagsArray and remove from mainTagsArray
                if (self.totalSelectedTagsArray?.count ?? 0 >= LoginModel.sharedInstance().maxTagsAllowedCount)
                {
                    self.showSnackBar(NSLocalizedString("You have just reached the maximum number of tags. Delete a tag to replace it.", comment: ""))
                    DispatchQueue.main.async {
                        self.allTagsCollectionView.reloadData()
                        
                    }
                }
                else
                {
                    if(self.totalSelectedTagsArray?.contains(cellDetail) == false)
                    {
                        self.totalSelectedTagsArray?.add(cellDetail)
                        self.selectedTagsArray?.add(cellDetail)
                        self.customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
                        self.indexToBeAnimated = (self.totalSelectedTagsArray?.index(of: cellDetail))!
                    }
                    if(self.mainTagsArray?.contains(cellDetail) == true)
                    {
                        self.mainTagsArray?.remove(cellDetail)
                    }
                    if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
                    {
//                        self.selectedTagCollectionView.isHidden = false
                        self.tagsSubTextView.isHidden = true
                    }
                    else
                    {
                        self.selectedTagCollectionView.isHidden = true
                        self.tagsSubTextView.isHidden = false
                    }
                    DispatchQueue.main.async {
                        self.allTagsCollectionView.reloadData()
                       // self.selectedTagCollectionView.reloadData()
                        self.makeNewDataAccordingToTheView(OutOfViewIndex: self.indexOfTagCreepingOut == -1 ? (self.totalSelectedTagsArray?.count ?? 0) : self.indexOfTagCreepingOut)
                    }
                }
            }
        }
        cell.showAsSelected = false
        cell.animateView = false
        cell.showBorder = true
        cell.showAddButton = true
        cell.changeViewBasedOnProperties()
    }

    
    func configureSelectedTagsCell(_ cell:TagCollectionViewCell, forIndexPath indexpath:IndexPath)
    {
        
        let cellDetail = selectedTagsArray?.object(at: indexpath.row) as! [AnyHashable:Any]
        cell.itemData = cellDetail
        cell.isShowLessButton = isTagViewFullyVisible
        cell.labelText = cellDetail[kTagsNameKey] as? String ?? ""
        cell.animateView = (indexToBeAnimated == indexpath.row)
        cell.showAsSelected =  !((cellDetail[kTagsIdKey] as? NSString)?.intValue  == 9991999)
        cell.destroyCellOnSelection = true
        cell.changeViewBasedOnProperties()

        cell.animateMyView { (completed) in
            NSLog("success")
        }
        cell.destroyMe { (success, destroyedObj) in
            if(success)
            {
                //called when the cell is tapped
                //Add to selectedTagsArray and remove from mainTagsArray
               
                //
                if((destroyedObj?[kTagsIdKey] as? NSString)?.intValue  == 9991999)
                {
                    if (self.isTagViewFullyVisible) {
                        //hide AllTags View and SearchButtonView
                        self.customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
                        self.allTagsCollectionView.isHidden = false
                        self.seperatorImageView.isHidden = false
                        if !self.isPartOfOnboarding{
                        self.searchTagsButton.isHidden = false
                        }
                    
                        self.isTagViewFullyVisible = false
                        self.selectedTagsCollectionViewHeightConstraint.constant = self.kOriginalHeight
                        self.selectedTagCollectionView.setNeedsUpdateConstraints()
                        UIView.animate(withDuration: 0.1, animations: {
                            self.view.layoutIfNeeded()
                        })
                        //
                        self.selectedTagsArray?.removeAllObjects()
                        self.selectedTagsArray?.addObjects(from: self.totalSelectedTagsArray as! [Any])
                        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
                        {
                            self.selectedTagCollectionView.isHidden = false
                            self.tagsSubTextView.isHidden = true
                        }
                        else
                        {
                            self.selectedTagCollectionView.isHidden = true
                            self.tagsSubTextView.isHidden = false
                        }
                        DispatchQueue.main.async {
                            self.allTagsCollectionView.reloadData()
                            self.selectedTagCollectionView.reloadData()
                            //  self.makeNewDataAccordingToTheView(OutOfViewIndex: self.indexOfTagCreepingOut == -1 ? (self.totalSelectedTagsArray?.count ?? 0) : self.indexOfTagCreepingOut)
                        }
                    }
                    else{
                        //show AllTags View and SearchButtonView
                        self.allTagsCollectionView.isHidden = true
                        self.seperatorImageView.isHidden = true
                        if !self.isPartOfOnboarding{
                        self.searchTagsButton.isHidden = true
                        }
                        self.customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = false
                        self.isTagViewFullyVisible = true
                        self.selectedTagsCollectionViewHeightConstraint.constant = self.view.frame.size.height - 126 - 50
//                        self.tagViewBottomHeightConstraint.constant = 1;
                        self.selectedTagCollectionView.setNeedsUpdateConstraints()
                        UIView.animate(withDuration: 0.1, animations: {
                            self.view.layoutIfNeeded()
                        })
                        self.selectedTagsArray?.removeAllObjects()
                        self.selectedTagsArray?.addObjects(from: self.totalSelectedTagsArray as! [Any])
                        self.selectedTagsArray?.add([kTagsIdKey:"9991999", kTagsNameKey:"Show Less"])
                        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
                        {
                            self.selectedTagCollectionView.isHidden = false
                            self.tagsSubTextView.isHidden = true
                        }
                        else
                        {
                            self.selectedTagCollectionView.isHidden = true
                            self.tagsSubTextView.isHidden = false
                        }
                        DispatchQueue.main.async {
                            self.allTagsCollectionView.reloadData()
                            self.selectedTagCollectionView.reloadData()
                        }
                        
                    }
                }
                else
                {
                    if(self.mainTagsArray?.contains(cellDetail) == false)
                    {
                        self.mainTagsArray?.add(cellDetail)
                    }
                    if(self.totalSelectedTagsArray?.contains(cellDetail) == true)
                    {
                        self.totalSelectedTagsArray?.remove(cellDetail)
//                        self.customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
                        
                    }
                    //
                    if(self.isTagViewFullyVisible == false)
                    {
                        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
                        {
                            self.selectedTagCollectionView.isHidden = false
                            self.tagsSubTextView.isHidden = true
                        }
                        else
                        {
                            self.selectedTagCollectionView.isHidden = true
                            self.tagsSubTextView.isHidden = false
                            self.customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
                            self.allTagsCollectionView.isHidden = false
                            self.seperatorImageView.isHidden = false
                            if !self.isPartOfOnboarding{
                            self.searchTagsButton.isHidden = false
                            }
                            
                            self.isTagViewFullyVisible = false
                            self.selectedTagsCollectionViewHeightConstraint.constant = self.kOriginalHeight

                            UIView.animate(withDuration: 0.1, animations: {
                                self.view.layoutIfNeeded()
                            })
                        }
                        DispatchQueue.main.async {
                            self.allTagsCollectionView.reloadData()
                             if(self.totalSelectedTagsArray?.count ?? 0 > 0)
                            {
                              //  self.selectedTagCollectionView.reloadData()
                                self.makeDataAccordingToTheView(OutOfViewIndex: self.indexOfTagCreepingOut == -1 ? (self.totalSelectedTagsArray?.count ?? 0) : self.indexOfTagCreepingOut)
                            }
                            else
                             {
                                self.selectedTagCollectionView.reloadData()
                            }
                        }
                    }
                    else
                    {
                        if(self.selectedTagsArray?.contains(cellDetail) == true)
                        {
                            self.selectedTagsArray?.remove(cellDetail)
                        }
                        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
                        {
                            self.selectedTagCollectionView.isHidden = false
                            self.tagsSubTextView.isHidden = true
                        }
                        else
                        {
                            self.selectedTagCollectionView.isHidden = true
                            self.tagsSubTextView.isHidden = false
                            //also show
                        self.customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
                            self.allTagsCollectionView.isHidden = false
                            self.seperatorImageView.isHidden = false
                            if !self.isPartOfOnboarding{
                            self.searchTagsButton.isHidden = false
                            }
                            
                            self.isTagViewFullyVisible = false
                            self.selectedTagsCollectionViewHeightConstraint.constant = self.kOriginalHeight
                            self.selectedTagCollectionView.setNeedsUpdateConstraints()
                            UIView.animate(withDuration: 0.1, animations: {
                                self.view.layoutIfNeeded()
                            })
                            //

                        }
                        DispatchQueue.main.async {
                            self.allTagsCollectionView.reloadData()
                            self.selectedTagCollectionView.reloadData()
                        }
                        //
                    }
                }
            }
            
        }
    }
    
    func makeNewDataAccordingToTheView(OutOfViewIndex index:Int)
    {
        if(index < 0)
        {return;}
        //indexToBeAnimated = -1
        self.selectedTagsArray?.removeAllObjects()
        var iterationCount = index
        if(index > totalSelectedTagsArray?.count ?? 0)
        {
            iterationCount = totalSelectedTagsArray?.count ?? 0
        }
        for i in 0...iterationCount-1
        {
            self.selectedTagsArray?.add(totalSelectedTagsArray?.object(at: i) as! [AnyHashable:Any] )
        }
        let totalNumberOfInvisibleTags = (totalSelectedTagsArray?.count ?? 0) - (self.selectedTagsArray?.count ?? 0)
        if(totalNumberOfInvisibleTags > 0)
        {
            let titleForButton = "+\(totalNumberOfInvisibleTags) more"
            selectedTagsArray?.add([kTagsIdKey:"9991999",kTagsNameKey:titleForButton])
            isShowMoreTagButtonVisible = true
            customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
        }
        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
        {
            self.selectedTagCollectionView.isHidden = false
           // self.tagsSubTextView.isHidden = true
        }
        self.selectedTagCollectionView.reloadData()
    }
    
    func makeDataAccordingToTheView(OutOfViewIndex index:Int)
    {
        if(index < 0)
        {return;}
        //indexToBeAnimated = -1
        self.selectedTagsArray?.removeAllObjects()
        var iterationCount = index
        if(index >= totalSelectedTagsArray?.count ?? 0)
        {
            if(index > totalSelectedTagsArray?.count ?? 0)
            {
                iterationCount = totalSelectedTagsArray?.count ?? 0
            }
            for i in 0...iterationCount-1
            {
                self.selectedTagsArray?.add(totalSelectedTagsArray?.object(at: i) as! [AnyHashable:Any] )
            }
        }
        else
        {
            for i in 0...iterationCount-2
            {
                self.selectedTagsArray?.add(totalSelectedTagsArray?.object(at: i) as! [AnyHashable:Any] )
            }
        }
        let totalNumberOfInvisibleTags = (totalSelectedTagsArray?.count ?? 0) - (self.selectedTagsArray?.count ?? 0)
        if(totalNumberOfInvisibleTags > 0)
        {
            let titleForButton = "+\(totalNumberOfInvisibleTags) more"
            selectedTagsArray?.add([kTagsIdKey:"9991999",kTagsNameKey:titleForButton])
            isShowMoreTagButtonVisible = true
            customJustifiedFlowLayoutForSelectedTags.notifyWhenTagWillGoBeyondViewHeight = true
        }
        if((self.totalSelectedTagsArray?.count) ?? 0 != 0)
        {
            self.selectedTagCollectionView.isHidden = false
        }
        self.selectedTagCollectionView.reloadData()
    }

}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

