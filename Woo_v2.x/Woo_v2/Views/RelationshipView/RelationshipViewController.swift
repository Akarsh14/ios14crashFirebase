//
//  RelationshipViewController.swift
//  Woo
//
//  Created by Kuramsetty Harish on 20/12/18.
//  Copyright © 2018 Woo. All rights reserved.
//

import UIKit

@objc enum TagScreenType:Int {
    case PCW
    case OnBoarding
}

@objc enum TagDataType:Int {
    case RelationshipAndLifestyle
    case Zodiac
}

class RelationshipViewController: BaseClassViewController, VPImageCropperDelegate {
    
    //MARK : - Constants & Variables
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var onboardingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @objc var currentScreen:TagScreenType = .PCW
    @objc var currentTagData:TagDataType = .RelationshipAndLifestyle
    @objc var isCloseBtnEnabled:Bool = false
    private var categoriesArray = [[String:AnyObject]]()
    var previouslySelectedRelationShipModelArray = NSMutableArray()
    var selectedRelationShipModelArray = NSMutableArray()
    var profileModelObject:MyProfileModel?
    var customLoader:WooLoader?
    var tableReloadHandler:((NSMutableArray)->Void)!

    //MARK : - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTop: NSLayoutConstraint!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var pcwView: UIView!
    @IBOutlet weak var onboardingView: UIView!
    @IBOutlet weak var differentiaterView: UIView!
    var navTitle : String = String()
    var isCloseButtonTapped:Bool = false
    var cropperIsAlreadyOpen:Bool = false
    @IBOutlet weak var pcwViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Implementation
    
    class func loadNib(_ title : String) -> RelationshipViewController {
        
        let controller: RelationshipViewController = RelationshipViewController(nibName: "RelationshipViewController", bundle: nil)
        controller.navTitle = title
        
        return controller
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        
        self.navBar!.setStyle(NavBarStyle.selectionOption, animated: false)
        self.navBar!.snp.makeConstraints { (make) in
            make.top.equalTo(0)
        }
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(RelationshipViewController.backClicked(_:)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Registering the cells to the tableView
        self.tableView.register(UINib(nibName: "TagScreenSectionHeader", bundle: nil), forCellReuseIdentifier: "tagScreenHeader")
        self.tableView.register(UINib.init(nibName: "RelationshipTableviewCell", bundle: nil), forCellReuseIdentifier: "RelationshipTableviewCell")
        self.tableView.register(UINib.init(nibName: "TagCollectionViewCell", bundle: nil), forCellReuseIdentifier: "TagCollectionViewCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(currentScreen == .PCW){
            if !isCloseBtnEnabled{
            colorTheStatusBar(withColor: NavBarStyle.me.color())
            }
            else{
                colorTheStatusBar(withColor: UIColor .white)
            }
        }else{
            colorTheStatusBar(withColor: UIColor .white)
        }
        setupBottomArea()
    }
    
    private func populateData(){
        var jsonPath = ""
        switch currentTagData {
        case .RelationshipAndLifestyle:
            jsonPath = "tagsRelationShip"
            break
        case .Zodiac:
            headerLabel.text = "Your Zodiac Sign"
            subHeaderLabel.isHidden = true
            differentiaterView.isHidden = true
            jsonPath = "tagsZodiac"
            break
        }
        
        // Switching the Views
        switch currentScreen {
        case .PCW:
            btnClose.isHidden = !isCloseBtnEnabled
            onboardingViewHeightConstraint.constant = 0
            tableViewToTopConstraint.constant = pcwViewHeightConstraint.constant
            if isCloseBtnEnabled{
                self.navBar?.isHidden = true
                self.navBar!.snp.makeConstraints { (make) in
                    make.height.equalTo(0)
                }
                if currentTagData == .Zodiac{
                    pcwViewHeightConstraint.constant = 100
                    tableViewToTopConstraint.constant = 60
                }
            }
            else{
                self.pcwView.isHidden = true
                pcwViewHeightConstraint.constant = 0
                differentiaterView.isHidden = true
                if currentTagData == .RelationshipAndLifestyle{
                    tableViewToTopConstraint.constant = 60
                }
                else{
                    tableViewToTopConstraint.constant = 0
                }
            }
            break
        case .OnBoarding:
            self.viewTop.constant = -60
            
            tableViewToTopConstraint.constant = onboardingViewHeightConstraint.constant

            btnClose.isHidden = true
            self.navBar?.isHidden = true
            self.navBar!.snp.makeConstraints { (make) in
                make.height.equalTo(0)
            }
            break
        }
        
        var jsonResult :[[String:AnyObject]]?
        if let tagsPath = Bundle.main.path(forResource: jsonPath, ofType: "json")
        {
            do {
                let jsonData = try NSData(contentsOfFile: tagsPath, options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options:JSONSerialization.ReadingOptions.mutableContainers) as? [[String:AnyObject]]
                    categoriesArray = jsonResult!
                }
                catch {}
            }
            catch {}
        }
        previouslySelectedRelationShipModelArray.removeAllObjects()
        if currentScreen == .PCW && isCloseBtnEnabled == true{
            profileModelObject = DiscoverProfileCollection.sharedInstance.myProfileData?.copy()
        }
        if profileModelObject != nil{
        if currentTagData == .RelationshipAndLifestyle{
            previouslySelectedRelationShipModelArray.addObjects(from: (profileModelObject?.relationshipLifestyleTags)!)
        }
        else{
            if let zodiacModel = profileModelObject?.zodiac{
                previouslySelectedRelationShipModelArray.add(zodiacModel)
            }
        }
        selectedRelationShipModelArray.removeAllObjects()
        selectedRelationShipModelArray.addObjects(from: previouslySelectedRelationShipModelArray as! [Any])
        }
    }
    
    func calculateTagCellHeight(_ array:NSArray, indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0.0
        let font = UIFont(name: "Lato-Regular", size: 14.0)!
        var rowWidth : CGFloat = 10.0
        var numberOfRows  : CGFloat = 1.0
        var extraHeight:CGFloat = 80.0
        if currentTagData == .Zodiac{
            extraHeight = 120.0
        }
        for model in array {
            let modelDict = model as! NSDictionary
            let tagWidth = sizeForView(modelDict.object(forKey: kTagsNameKey) as! String, font: font, height: 32.0).width
            rowWidth = rowWidth + tagWidth + 10
            if rowWidth > (UIScreen.main.bounds.width - 45) {
                rowWidth = tagWidth + 10
                numberOfRows += 1
            }
        }
        var cellHeight:CGFloat = 28
        if(SCREEN_HEIGHT > 735 && indexPath.row == 0 && (indexPath.section == 0) ){
           cellHeight = 32
        }
        else if(SCREEN_HEIGHT == 568 && indexPath.row == 0 && (indexPath.section == 0) ){
            cellHeight = 34
        }
        
        else if (SCREEN_HEIGHT > 735 && (indexPath.row > 1)){
            cellHeight = 28
            extraHeight = 20
            if SCREEN_HEIGHT == 812{
                if indexPath.section == 1{
                    cellHeight = 50
                }
            }
        }
        else if (SCREEN_HEIGHT > 735 && (indexPath.section == 1)){
            if (indexPath.row == 0){
                if SCREEN_HEIGHT == 812{
                    cellHeight = 40
                }
                else{
                    cellHeight = 12
                }
                numberOfRows = 1
            }
        }
        height = numberOfRows * cellHeight + extraHeight + 20
        return height
    }
    
    private func sizeForView(_ text:String, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 50, height: 32)
    }
    
    func heightForView(_ text:String, font:UIFont) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 60, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        return CGSize(width: (UIScreen.main.bounds.size.width - 40)/2, height: label.frame.size.height)
    }
    
    private func setupBottomArea(){
        if currentScreen == .OnBoarding{
//            if (LoginModel.sharedInstance()?.isAlternateLogin)!{
                counterLabel.isHidden = true
//            }
            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
            let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
            counterLabel.text = "\(pagesDict.object(forKey: "pageNumber") ?? "1") of \(pagesDict.object(forKey: "totalPages") ?? "1")"
            print(pagesDict.object(forKey: "pageNumber") as! String)
            if pagesDict.object(forKey: "pageNumber") as! String == "1"{
//                backButton.isHidden = true
            }
//            WizardScreensCalculator.sharedInstance.isCropperVisible = true
            nextButton.setTitle("NEXT", for: .normal)
        }
        else{
            if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
                nextButton.setTitle("DONE", for: .normal)
            }
            else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
                backButton.isHidden = true
            }
            
            
            if isCloseBtnEnabled == false{
                bottomView.isHidden = true
                bottomViewHeightConstraint.constant = 0
            }
            counterLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
        }
    }
        
    
    //Thos method will set the views as per Tagscreentype
    func setViewsfor(_ screen: TagScreenType, tagData:TagDataType, closeBtn:Bool, title:String){
        self.currentScreen = screen
        self.currentTagData = tagData
        self.isCloseBtnEnabled = closeBtn
        self.navTitle = title
        self.navBar?.setTitleText(self.navTitle)
        populateData()

    }
    
    //Back Button Action
    @IBAction func backClicked(_ sender: Any) {
        if tableReloadHandler != nil{
            tableReloadHandler(self.selectedRelationShipModelArray)
        }
//        self.navigationController?.popViewController(animated: true)
        
        let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
        utilitiesObj.decreaseOnBoardingPageNumber()
        let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
        let onboardingPageNumber:Int = Int(pagesDict.object(forKey: "pageNumber") as! String) ?? 1
        
        print("onboardingPageNumber", onboardingPageNumber)
        if onboardingPageNumber == Int(ON_BOARDING_PAGE_NUMBER_ONE.rawValue) {
            cropperIsAlreadyOpen = true
        }
        
        if WizardScreensCalculator.sharedInstance.isCropperVisible == true && cropperIsAlreadyOpen == true {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
           
            WizardScreensCalculator.sharedInstance.isCropperVisible = false
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        isCloseButtonTapped = true
        if hasUserChangedTags(){
            showWooLoader()
            sendDataToServer()
        }
        else{
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
    
    @IBAction func next(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        performWorkAfterSuccess()
    }
    
    private func sendDataToServer(){
        let totalSelectedTagsArray : NSMutableArray = NSMutableArray()
        for tag in selectedRelationShipModelArray{
                let relationshipTag = tag as! RelationshipLifestyleTagModel
                totalSelectedTagsArray.add(relationshipTag.dictionarify())
            }
        
        if totalSelectedTagsArray.count > 0{
            if currentTagData == .RelationshipAndLifestyle{
            TagScreenAPIClass.postTagsDataToServer(withTagsArray: totalSelectedTagsArray as? [Any], withType: "RelationShip") { (success, statusCode, response) in
                
                
                if let profileDataModel = DiscoverProfileCollection.sharedInstance.myProfileData{
                    profileDataModel.relationshipLifestyleTags = self.selectedRelationShipModelArray as! [RelationshipLifestyleTagModel]
                    if let  id = UserDefaults.standard.object(forKey: "id") {
                        let wooid:NSString = id as! NSString
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                    }
                }
                
                if self.isCloseButtonTapped{
                    self.isCloseButtonTapped = false
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
            }
            else{
                TagScreenAPIClass.postTagsDataToServer(withTagsArray: totalSelectedTagsArray as? [Any], withType: "Zodiac") { (success, statusCode, response) in
                    
                    if let profileDataModel = DiscoverProfileCollection.sharedInstance.myProfileData{
                        profileDataModel.zodiac = self.selectedRelationShipModelArray.firstObject as? RelationshipLifestyleTagModel
                        if let  id = UserDefaults.standard.object(forKey: "id") {
                            let wooid:NSString = id as! NSString
                            ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                        }
                    }
                    
                    if self.isCloseButtonTapped{
                        self.isCloseButtonTapped = false
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
            }
        }
    }
    
    private func performWorkAfterSuccess(){
        
        let isUsedInOnboarding = (currentScreen == .OnBoarding) ? true : false
        if(hasUserChangedTags() == true)
        {
            if isUsedInOnboarding{
                (Utilities() as AnyObject).increaseOnBoardingPageNumber()
                sendDataToServer()
                self.moveToNextScreen(false)
            }
            else{
                
            if checkIfFlowIsComplete(){
                showWooLoader()
                sendDataToServer()
                if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                    self.showWizardCompleteView(false)
                }
                else{
                    self.showWizardCompleteView(true)
                }
            }
            else{
                sendDataToServer()
                WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
            }
            }
        }
        else
        {
            if isUsedInOnboarding{
                (Utilities() as AnyObject).increaseOnBoardingPageNumber()
                self.moveToNextScreen(false)
            }
            else{
            if self.checkIfFlowIsComplete(){
                self.showWizardCompleteView(true)
            }
            else
            {
                WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
            }
            }
        }

    }
    
    
    private func moveToNextScreen(_ afterNewUserNoPic:Bool){
        let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)
        var showNewUserNoPic = LoginModel.sharedInstance().isNewUserNoPicScreenOn
        if afterNewUserNoPic{
            showNewUserNoPic = false
        }
        else if LoginModel.sharedInstance().profilePicUrl != nil{
            showNewUserNoPic = false
        }
        
        if (LoginModel.sharedInstance()?.isAlternateLogin)!{
            
            if !(LoginModel.sharedInstance()?.userOtherTagsAvailable)!{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
                    wizardTagsVC.isUsedOutOfWizard = true
                    wizardTagsVC.isPartOfOnboarding = true
                    wizardTagsVC.isThisFirstScreenAfterRegistration = false
                    self.navigationController?.pushViewController(wizardTagsVC, animated: true)
                }
            }
            else if (LoginModel.sharedInstance().personalQuoteText) != nil{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let aboutMeScreenViewController:AboutMeScreenViewController = storyBoard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
                    self.navigationController?.pushViewController(aboutMeScreenViewController, animated: true)
                }
            }
            else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    (Utilities() as AnyObject).sendToDiscover()
                }
            }
        }
        else{
         if !(LoginModel.sharedInstance()?.userOtherTagsAvailable)!{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
                wizardTagsVC.isUsedOutOfWizard = true
                wizardTagsVC.isPartOfOnboarding = true
                self.navigationController?.pushViewController(wizardTagsVC, animated: true)
            }
        }
        else if (LoginModel.sharedInstance().personalQuoteText) != nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let aboutMeScreenViewController:AboutMeScreenViewController = storyBoard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
                self.navigationController?.pushViewController(aboutMeScreenViewController, animated: true)
            }
        }
        else if showNewUserNoPic{
                let width = SCREEN_WIDTH * 0.7361
                let imgCropperVC: VPImageCropperViewController = VPImageCropperViewController(image: UIImage(named:"crop_default"), cropFrame: CGRect(x: (SCREEN_WIDTH-width)/2, y: 0.122*SCREEN_HEIGHT, width: width, height: 0.655*SCREEN_HEIGHT), limitScaleRatio:Int(3.0))
                imgCropperVC.isImageAdded = true;
                imgCropperVC.delegate = self
                self.navigationController?.pushViewController(imgCropperVC, animated: true)
            }
            else if LoginModel.sharedInstance().isPhotoScreenGridOn{
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
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                (Utilities() as AnyObject).sendToDiscover()
            }
        }
        }
    }
    
    @IBAction func moveBack(_ sender: Any) {
        
        if currentScreen == .PCW{
            WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
            print("currentWizardScreen is ",WizardScreensCalculator.sharedInstance.currentWizardScreen)
            
            if(WizardScreensCalculator.sharedInstance.currentWizardScreen == 1){
                cropperIsAlreadyOpen = true
            }
        }
        else{
            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
            utilitiesObj.decreaseOnBoardingPageNumber()
            let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
            let onboardingPageNumber:Int = Int(pagesDict.object(forKey: "pageNumber") as! String) ?? 1
            
            print("onboardingPageNumber", onboardingPageNumber)
            if onboardingPageNumber == Int(ON_BOARDING_PAGE_NUMBER_ONE.rawValue) {
                cropperIsAlreadyOpen = true
            }
        }
        
        if WizardScreensCalculator.sharedInstance.isCropperVisible == true && cropperIsAlreadyOpen == true {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
           
            WizardScreensCalculator.sharedInstance.isCropperVisible = false
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }else{
            print("else entering")
            self.navigationController?.popViewController(animated: true)
        }
        
//        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropper(_ cropperViewController: VPImageCropperViewController!, didFinished editedImageData: [AnyHashable : Any]!) {
        self.moveToNextScreen(true)
    }
    
    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController!) {
        self.moveToNextScreen(true)
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
    
    func hasUserChangedTags() -> Bool
    {
            let oldRelationshipTagsArray = self.previouslySelectedRelationShipModelArray
            var selectedOldTagsArray:[String] = []
            
        for tag in oldRelationshipTagsArray{
                let relationshipTag = tag as! RelationshipLifestyleTagModel
                selectedOldTagsArray.append(relationshipTag.tagId!)
            }
            
            let newTagsArray = self.selectedRelationShipModelArray
            var selectedNewTagsArray:[String] = []
        for tag in newTagsArray{
                let relationshipTag = tag as! RelationshipLifestyleTagModel
                selectedNewTagsArray.append(relationshipTag.tagId!)
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
}

// MARK : - Tableview delegates

extension RelationshipViewController : UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Tableview Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  categoriesArray[section]["subType"]!.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subType = categoriesArray[indexPath.section]["subType"]! as! [[String:Any]]
        let tagArray = (subType[indexPath.row]["tags"]! as! NSArray)
        return calculateTagCellHeight(tagArray, indexPath: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelationshipTableviewCell") as! RelationshipTableviewCell
        cell.relationshipViewControllerObject = self
        let subType = categoriesArray[indexPath.section]["subType"]! as! [[String:Any]]
        let subCategoryObject = subType[indexPath.row]
        let tagArray = (subCategoryObject["tags"]! as! NSArray)
        cell.subCategory = subCategoryObject["tagsSubCategoryId"] as? Int
        cell.tagDataType = self.currentTagData
        cell.populateTagsArrayAndReload(tagArray)
        
        let attrSubTypeName = subType[indexPath.row]["subTypeName"]!
            as! String
        
        let latoRegHeader = UIFont(name: "Lato-Medium", size: 16.0)
        let arialDict = [ NSAttributedString.Key.font : latoRegHeader ]
        
        
        let aAttrString = NSMutableAttributedString(string: attrSubTypeName, attributes: arialDict as [NSAttributedString.Key : Any])
        let latoSmallFont = UIFont(name: "Lato-Medium", size: 12.0)
        let verdanaDict = [ NSAttributedString.Key.font : latoSmallFont ]
        
        
        let vAttrString = NSMutableAttributedString(string: " (Select one)", attributes: verdanaDict as [NSAttributedString.Key : Any])
        
        aAttrString.append(vAttrString)
        let attributes0 = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 55/255, green: 58/255, blue: 67/255, alpha: 1)]
        aAttrString.addAttributes(attributes0, range: NSMakeRange(0, aAttrString.length))
     
        let subTypString = attrSubTypeName + " (Select one)"
        let heightOfText = heightForView(subTypString, font: UIFont(name: "Lato-Medium", size: 16.0)!)
        cell.lblSecondaryHeightConstraint.constant = heightOfText.height
        cell.lblSecondaryHeading.attributedText = aAttrString
        cell.categoryImageView.image = UIImage(named: (subType[indexPath.row]["subTypeImage"]!
            as! String))
        if indexPath.section == 0{
        if (indexPath.row == 1){
            cell.seperatorCell.isHidden = false
        }else{
             cell.seperatorCell.isHidden = true
        }
        }
        else{
            cell.seperatorCell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentTagData == .RelationshipAndLifestyle{
            return 35
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentTagData == .RelationshipAndLifestyle{
            let header = tableView.dequeueReusableCell(withIdentifier: "tagScreenHeader")! as! TagScreenSectionHeader
            header.lblHeaderTitle.text = (categoriesArray[section]["tagsCategory"] as? String)!
            return header.contentView
        }
        else{
            return nil
        }
    }
}
