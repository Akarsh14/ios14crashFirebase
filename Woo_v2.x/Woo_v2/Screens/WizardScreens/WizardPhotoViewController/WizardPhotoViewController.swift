 //
 //  WizardPhotoViewController.swift
 //  Woo_v2
 //
 //  Created by Akhil Singh on 29/12/17.
 //  Copyright © 2017 Vaibhav Gautam. All rights reserved.
 //
 
 import UIKit
 import AssetsLibrary
 import Photos
 import AVFoundation
 import SDWebImage
 import CropPickerController
 
 
 class WizardPhotoViewController: UIViewController, URLSessionTaskDelegate, URLSessionDelegate {
    @IBOutlet weak var closebtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgDescription: UIImageView!
    
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var photosLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var morePicsLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    var photoCounter = 1
    var isPhotoDragStarted = false
    @IBOutlet weak var viewCountLabel: UILabel!
    
    var dataSource : WooAlbumModel?
    
    var isProfileModified = false
    
    fileprivate var lastEditedPhotoIndex = -1
    
    var imageToSendForCropper: UIImage?
    
    var imagePicker:UIImagePickerController?
    
    var isCloseTapped = false
    
    var customLoader:WooLoader?
    
    var fbPhotoObjetId:String?
    
    var needToMakeDiscoverCall = false
    
    var photoArray:[String] = []
    var changedPhotoArray:[String] = []
    
    var currentPhotoCount = 0
    
    var needToShowInReviewAlert = false
    
    var photoArrayPhotosCounter = 0
    var multipleImagesFetchingFromCropPickerViewArray = [NSData]()
    var lastItemforCropperPickerArray = false
    
    var saveImageIntoDictionaryWithStatusAfterUpload = [String:UIImage]()
    
    var cropPickerControllerForClose : CropPickerController?
    
    var photoForMatching : Int = 0
    
    public var uploadImageSuccessfullDictionary = [[String:Any]]()
    public var remainingImagesForUploadingOnDiscover = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            closeTopConstraint.constant = 40
        }
        if SCREEN_WIDTH == 320{
            //morePicsLabelTopConstraint.constant = 0.0
            photosLabelTopConstraint.constant = 0.0
            
        }
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Photos_Landing")
        
        dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
        if let photos = dataSource?.allImagesUrl()
        {
            photoArray.removeAll()
            for photo in photos{
                photoArray.append(photo)
            }
        }
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewwillappear on wizard")
        
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
        colorTheStatusBar(withColor: UIColor.white)
        self.perform(#selector(hideTabBar), with: nil, afterDelay: 0.2)
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCellID")
        
        
        self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
        
        self.photoCounter = 1
        self.photoArrayPhotosCounter = 0
        self.lastItemforCropperPickerArray = false
        collectionView.reloadData()
        
        self.setupBottomArea()
        
        if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            closeButton.isHidden = true
            closebtnConstraint.constant = 0
            photosLabelTopConstraint.constant = -30.0
            backButton.isHidden = true
        }
         doDynamicHeading()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFromDictionaryWhichComesfromSingleCropper),
                                               name:NSNotification.Name(rawValue: "deleteFromDictionaryInWizardScreen"), object: nil)
    }
    
    
    
    @objc fileprivate func deleteFromDictionaryWhichComesfromSingleCropper(_ notif : Notification) {
        
       if let dict = notif.userInfo?["UIImage"] as? UIImage {
           deleteFromUploadDictionary(imageTobeDeleted: dict)
       }
        
    }
    
    func doDynamicHeading() {
        
        print("doDynamicHeading")
        if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false) { shouldNextButtonVisible()}
        
        if self.dataSource?.allImagesUrl().count == 0{
             secondLabel.text = "Add your photos"
          }else{
            if self.dataSource?.allApprovedImagesUrl().count == 1{
                secondLabel.text = "Do you want to add more photos?"
            }
            else if((self.dataSource?.allApprovedImagesUrl().count)! > 1){
                self.imgDescription.isHidden = false
                secondLabel.isHidden = false
                // firstLabel.text = "Add more or hold & drag to re-order"
                self.imgDescription.image = UIImage (named: "ic_blue_onboarding_drag")
                secondLabel.text = "Add more or \nhold & drag to re-order"
            }
            
            else if(self.dataSource?.allApprovedImagesUrl().count == 0) {
                self.imgDescription.isHidden = false
                secondLabel.text = "Your photo was incompatible. \nAdd another."
            }
        }
    }
    
    
    func shouldNextButtonVisible(){

        if((self.dataSource?.allApprovedImagesUrl().count)! < Int(LoginModel.sharedInstance().minPhotoCountForOnboarding) ){
            nextButton.alpha = 0.5
           
        }else{
            nextButton.alpha = 1
        }
    }
    
    @objc func hideTabBar(){
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isPhotosChanged() -> Bool{
        let album = dataSource?.photoArray
        if let _ = album
        {
            for photo in album!{
                let photoFromAlbum = photo as! AlbumPhoto
                if photoFromAlbum.status == "REJECTED"{
                    return true
                }
            }
        }
        
        return false
    }
    
    @IBAction func close(_ sender: Any) {
        isCloseTapped = true
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Photos_Close")
        
        if isPhotosChanged(){
            showWooLoader()
            sendDataToServer()
        }
        else{
            if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                self.showWizardCompleteView(false)
                if needToMakeDiscoverCall{
                  WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
            }
            else{
                if self.checkIfFlowIsComplete(){
                    self.showWizardCompleteView(true)
                }
                else{
                    if needToMakeDiscoverCall{
                        WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                    }
                    self.checkIfToShowDiscoverOrMe()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func showWizardCompleteView(_ isCompleted:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
            if isCompleted && self.needToMakeDiscoverCall{
                WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
            }
            self.navigationController?.popToRootViewController(animated: true)
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
    
    func sendDataToServer(){
        let myProfileDictionary : NSMutableDictionary = (dataSource?.dictionaryfy())!
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary))!)
        
        if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
            utilitiesObj.sendToDiscover()
        }
        else{
            WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
                let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is WizardPhotoViewController
                if !currenViewControllerIsSelf{
                    self.needToMakeDiscoverCall = false
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                    self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
                    let photos = self.dataSource?.allImagesUrl()
                    self.currentPhotoCount = (self.dataSource?.count())!
                    self.photoArray.removeAll()
                    for photo in photos!{
                        self.photoArray.append(photo)
                    }
                     self.photoCounter = 1
                    self.collectionView.reloadData()
                    return
                }
                self.hideWooLoader()
                if self.isCloseTapped{
                    self.isCloseTapped = false
                    if success{
                        self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
                        let photos = self.dataSource?.allImagesUrl()
                        self.currentPhotoCount = (self.dataSource?.count())!
                        self.photoArray.removeAll()
                        for photo in photos!{
                            self.photoArray.append(photo)
                        }
                         self.photoCounter = 1
                        self.collectionView.reloadData()
                        
                        if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                            self.needToMakeDiscoverCall = false
                            self.showWizardCompleteView(false)
                        }
                        else{
                            if self.checkIfFlowIsComplete(){
                                self.showWizardCompleteView(true)
                            }
                            else{
                                self.needToMakeDiscoverCall = false
                                self.checkIfToShowDiscoverOrMe()
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
                else{
                    if success{
                        let photos = self.dataSource?.allImagesUrl()
                        self.currentPhotoCount = (self.dataSource?.count())!
                        self.photoArray.removeAll()
                        for photo in photos!{
                            self.photoArray.append(photo)
                        }
                        if self.checkIfFlowIsComplete(){
                            self.showWizardCompleteView(true)
                        }
                        else{
                            WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                        }
                    }
                }
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
    
    private func moveToNextScreen(){
        
        let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)

        if !(LoginModel.sharedInstance()?.userRelationshipTagsAvailable)! || !(LoginModel.sharedInstance()?.userLifestyleTagsAvailable)!{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

                let relationshipController = RelationshipViewController.loadNib("Relationship and Lifestyle")

                relationshipController.setViewsfor(.OnBoarding,tagData: .RelationshipAndLifestyle, closeBtn: false, title: "Relationship and Lifestyle")
                
                self.navigationController?.pushViewController(relationshipController, animated: true)
            }
        }
        else if !(LoginModel.sharedInstance()?.userOtherTagsAvailable)!{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

                let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
                wizardTagsVC.isUsedOutOfWizard = true
                wizardTagsVC.isPartOfOnboarding = true
                self.navigationController?.pushViewController(wizardTagsVC, animated: true)
            }
        }
        else if (LoginModel.sharedInstance().personalQuoteText) != nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let aboutMeScreenViewController:AboutMeScreenViewController = storyBoard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
                self.navigationController?.pushViewController(aboutMeScreenViewController, animated: true)
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                (Utilities() as AnyObject).sendToDiscover()
            }
        }
    }
    
    @IBAction func next(_ sender: Any){
        
        isCloseTapped = false
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
         nextButton.isUserInteractionEnabled = false
         if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "onboarding_photos_grid_next")
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "onboarding_photos_grid_next")
            
//            if LoginModel.sharedInstance().isAlternateLogin{
                
                 if((self.dataSource?.allApprovedImagesUrl().count)! < Int(LoginModel.sharedInstance().minPhotoCountForOnboarding) ){
                        var photoString = ""
                        (LoginModel.sharedInstance().minPhotoCountForOnboarding == 1) ? (photoString = "photo") : (photoString = "photos");
                        nextButton.isUserInteractionEnabled = true
                        nextButton.alpha = 0.5
                        _ =  AlertController.showAlert(withTitle: "Add at least \(LoginModel.sharedInstance().minPhotoCountForOnboarding) approved \(photoString) to continue", andMessage: "", needHandler: false, withController: self)
                 }else{
                        print("increaseOnBoardingPageNumber")
                        (Utilities() as AnyObject).increaseOnBoardingPageNumber()
                        moveToNextScreen()
                 }
               
//            }
//            else{
//                if isPhotosChanged(){
//                    showWooLoader()
//                    sendDataToServer()
//                }
//                else{
//                    let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
//                    utilitiesObj.sendToDiscover()
//                }
//            }
        }
         else{
            
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Photos_Next")
            
            if isPhotosChanged(){
                if checkIfFlowIsComplete(){
                    showWooLoader()
                    sendDataToServer()
                }
                else{
                    needToMakeDiscoverCall = false
                    sendDataToServer()
                    WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                }
            }
            else{
                if self.checkIfFlowIsComplete(){
                    self.showWizardCompleteView(true)
                }
                else{
                    if needToMakeDiscoverCall{
                        WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                    }
                    WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                }
            }
        }
    }
    
    
    
    func callBackFromGalleryForNextScreen(){
        isCloseTapped = false
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
         if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "onboarding_photos_grid_next")
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "onboarding_photos_grid_next")
//            if LoginModel.sharedInstance().isAlternateLogin{
                    print("increaseOnBoardingPageNumber callback")
                    (Utilities() as AnyObject).increaseOnBoardingPageNumber()
                     moveToNextScreen()
//            }
//            else{
//            if isPhotosChanged(){
//                showWooLoader()
//                sendDataToServer()
//            }
//            else{
//                let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
//                utilitiesObj.sendToDiscover()
//            }
//            }
        }
        else{
            
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Photos_Next")
            
            if isPhotosChanged(){
                if checkIfFlowIsComplete(){
                    showWooLoader()
                    sendDataToServer()
                }
                else{
                    needToMakeDiscoverCall = false
                    sendDataToServer()
                    WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                }
            }
            else{
                if self.checkIfFlowIsComplete(){
                    self.showWizardCompleteView(true)
                }
                else{
                    if needToMakeDiscoverCall{
                        WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                    }
                    WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                }
            }
        }
    }
    
    
    
    
    @IBAction func back(_ sender: Any) {
        if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
            utilitiesObj.sendFirebaseEvent(withScreenName: "", withEventName: "onboarding_photos_grid_back")
            utilitiesObj.sendMixPanelEvent(withName: "onboarding_photos_grid_back")
            utilitiesObj.decreaseOnBoardingPageNumber()
        }
        else{
            if isPhotosChanged(){
                sendDataToServer()
            }
            else{
                if needToMakeDiscoverCall{
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
            }
            WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupBottomArea(){
        
        if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false){
            if LoginModel.sharedInstance().isAlternateLogin{
                viewCountLabel.isHidden =  true
                if LoginModel.sharedInstance().isNewUserNoPicScreenOn || LoginModel.sharedInstance().profilePicUrl == nil{
                    backButton.isHidden = false
                }
                else{
                    backButton.isHidden = true
                }
            }
            else{
//            let utilitiesObj = (Utilities.sharedUtility() as! Utilities)
//            let pagesDict:NSDictionary = utilitiesObj.getOnboardingPageNumberAndTotalNumberOfPages()! as NSDictionary
//            viewCountLabel.text = "\(pagesDict.object(forKey: "pageNumber") ?? "1") of \(pagesDict.object(forKey: "totalPages") ?? "1")"
            
                viewCountLabel.isHidden =  true
                if LoginModel.sharedInstance().isNewUserNoPicScreenOn || LoginModel.sharedInstance().profilePicUrl == nil{
                    backButton.isHidden = false
                }
                else{
                    backButton.isHidden = true
                }
            }
        }
        else{
            if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
                nextButton.setTitle("DONE", for: .normal)
            }
            else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
                backButton.isHidden = true
            }
            viewCountLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
        }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
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
            imagePickerOptions(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    DispatchQueue.main.async {
                        self.imagePickerOptions(true)
                    }
                    
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
    
    func deleteImageForIndex(_ index:Int){
    DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.removeObjectAt(index)
        self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
        self.photoCounter = 1
        collectionView.reloadData()
        
        if self.currentPhotoCount != self.dataSource?.count(){
            self.needToMakeDiscoverCall = true
        }
        else{
            let photos = dataSource?.allImagesUrl()
            changedPhotoArray.removeAll()
            for photo in photos!{
                changedPhotoArray.append(photo)
            }
            if containSameElements(photoArray, secondArray: changedPhotoArray){
                self.needToMakeDiscoverCall = false
            }
            else{
                self.needToMakeDiscoverCall = true
            }
        }
    }
    
    func addImage(_ index:Int, image:UIImage?){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        needToMakeDiscoverCall = true
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Photos_Add")
        
        var toBeEditedImage = UIImage(named: "crop_default")
        if image != nil{
            toBeEditedImage = image
        }
        
        let width = SCREEN_WIDTH * 0.7361;
        let rect = CGRect(x: (SCREEN_WIDTH - width) / 2, y: 0.122 * SCREEN_HEIGHT, width: width, height: 0.655 * SCREEN_HEIGHT)
        
        var imgCropperVC: VPImageCropperViewController?
        if index < (self.dataSource?.count())! {
            
            let imageData = (self.dataSource?.objectAtIndex(index))! as AlbumPhoto
            
            imgCropperVC = VPImageCropperViewController(image: toBeEditedImage,
                                                        cropFrame: rect,
                                                        limitScaleRatio: 3)
            imgCropperVC!.isWooAlbumCallNotNeeded = true
            imgCropperVC!.albumData = imageData.copy() as! AlbumPhoto
            if index == 0{
                imgCropperVC?.albumData.isProfilePic = true
            }
            imgCropperVC?.wooAlbum = self.dataSource?.copy() as! WooAlbumModel
            imgCropperVC?.isOpenedFromWizard = true
            
            self.lastEditedPhotoIndex = index
            self.navigationController!.pushViewController(imgCropperVC!, animated: true)
        }
        else{
            self.lastEditedPhotoIndex = index
            self.showImagePickerOptions()
        }
        
        imgCropperVC?.imageBlock = { (imageData) in
            if imageData != nil {
                self.dataSource = imageData
                DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = imageData
                self.isProfileModified = true
            }
            else{
                if self.lastEditedPhotoIndex != -1 {
                    self.isProfileModified = true
                    DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.removeObjectAt(self.lastEditedPhotoIndex)
                    self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
                }
            }
            self.photoCounter = 1
            self.lastItemforCropperPickerArray = false
            self.photoArrayPhotosCounter = 0
            self.collectionView.reloadData()
        }
    }
    
    func showImagePickerOptions(){
        let imagePickerOptions:UIAlertController = UIAlertController(title: "", message: "Where do you want to add your picture from?", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Gallery",
                                          style: .default, handler:{ (alertAction:UIAlertAction) in
                                            self.imagePickerOptions(false)
        })
        
       
        let fbAction = UIAlertAction(title: "Facebook",
                                     style: .default, handler:{ (alertAction:UIAlertAction) in
                                        self.getFacebookPhotos(authNeeded: false)
        })
              imagePickerOptions.addAction(fbAction)
        
        
        let cameraAction = UIAlertAction(title: "Camera",
                                         style: .default, handler:{ (alertAction:UIAlertAction) in
                                            self.checkCameraPermission()
                                            
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
                self.present(self.imagePicker!, animated: true, completion: nil)
                
            }else{
                
                let cropPickerController = self.makeCropPickerController(.single, isCamera: false, maxAllowedImages: 9 - ((dataSource?.count())! + multipleImagesFetchingFromCropPickerViewArray.count))
                
//                let navigationController = UINavigationController(rootViewController: cropPickerController)
//                navigationController.modalPresentationStyle = .fullScreen
//                self.present(navigationController, animated: true, completion: nil)
                self.navigationController?.pushViewController(cropPickerController, animated: true)
               
            }
            
//        }else{
//
//            if isCamera{
//                self.imagePicker?.sourceType = .camera
//                self.imagePicker?.cameraDevice = .front
//            }
//            else{
//                self.imagePicker?.sourceType = .photoLibrary
//            }
//            self.present(self.imagePicker!, animated: true, completion: nil)
//        }

    }
    
    func showAuthPopUP(){
        let alert = UIAlertController(title: "Need more details!", message: "We need some more details to build \nan accurate Woo profile for you. \nPlease allow Woo to access \nFacebook for this information. \n\nWoo never posts on your wall", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Authorize Facebook", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
            self.getFacebookPhotos(authNeeded: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
                let imageUrl = URL(string: strImage)
                let loadedImageData = NSData(contentsOf: imageUrl as! URL)
                let imageToSendForCropper = UIImage(data: loadedImageData! as Data)
                
                DispatchQueue.main.async {
                    utilities.hideActivityIndicator()
                    self.openCropperNow(imageToSendForCropper!)
                }
        }
        
    }
    
    func openCropperNow(_ fbImage:UIImage){
        
        let width = SCREEN_WIDTH * 0.7361;
        let rect = CGRect(x: (SCREEN_WIDTH - width) / 2, y: 0.122 * SCREEN_HEIGHT, width: width, height: 0.655 * SCREEN_HEIGHT)
        
        var imgCropperVC: VPImageCropperViewController?
        imgCropperVC = VPImageCropperViewController(image: fbImage,
                                                    cropFrame: rect,
                                                    limitScaleRatio: 3)
        imgCropperVC!.albumData = AlbumPhoto()
        
        imgCropperVC?.wooAlbum = self.dataSource?.copy() as! WooAlbumModel
        imgCropperVC?.albumData.url = ""
        self.lastEditedPhotoIndex = -1
        imgCropperVC?.isOpenedFromWizard = true
        imgCropperVC!.isWooAlbumCallNotNeeded = true
        
        needToMakeDiscoverCall = true
        imgCropperVC?.imageBlock = { (imageData) in
            if imageData != nil {
                self.dataSource = imageData
                DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = imageData
                self.isProfileModified = true
            }
            else{
                if self.lastEditedPhotoIndex != -1 {
                    self.isProfileModified = true
                    DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.removeObjectAt(self.lastEditedPhotoIndex)
                    self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
                }
            }
             self.photoCounter = 1
            self.lastItemforCropperPickerArray = false
            self.photoArrayPhotosCounter = 0
            self.collectionView.reloadData()
        }
        
        
        self.navigationController!.pushViewController(imgCropperVC!, animated: true)
    }
    
    
    func getFacebookPhotos(authNeeded: Bool){
        if LoginModel.sharedInstance().isAlternateLogin{
            SwiftUtilities().getAccessTokenFromFacebook(self, isAuthNeeded: authNeeded, accessToken: { (isSucess, accessToken) in
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
                if let albums = (response as! NSDictionary).object(forKey: "albums") as? [Any]{
                    fbAlbumVC.arrAlbumData = albums
                }
                if fbAlbumVC.arrAlbumData.count < 1{
                    let noAlbum:UIAlertController = UIAlertController(title: "", message: NSLocalizedString("No album found.", comment: ""), preferredStyle: .alert)
                    let okAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
                    noAlbum.addAction(okAction)
                    self.present(noAlbum, animated: true, completion: nil)
                    return
                }
                self.navigationController?.pushViewController(fbAlbumVC, animated: true)
                
            }
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
    
    func showInReviewAlert(){
        let inReviewAlert:UIAlertController = UIAlertController(title: "", message: "You can only set an approved photo as your main photo.", preferredStyle: .alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        inReviewAlert.addAction(okAction)
        self.present(inReviewAlert, animated: true, completion: nil)
    }
    
    
    func imageEqualityCheck(value: UIImage, isEqualTo image2: UIImage) -> Bool {
        let data1: NSData = value.pngData()! as NSData
        let data2: NSData = image2.pngData()! as NSData
        return data1.isEqual(data2)
    }
    
    func showDeleteConfirmationPopupForImage(_ toBeDeletedImage:UIImage, albumData:AlbumPhoto){
        
        print("album data", albumData)
        let deletePhotoObject:DeletePhotoView = Bundle.main.loadNibNamed("DeletePhotoView", owner: self, options:nil)?.first as! DeletePhotoView
        deletePhotoObject.frame = self.view.bounds
        
        if(albumData.url != nil){
            deletePhotoObject.setDeleteDataOnViewWith(toBeDeletedImage) {
                
                self.deleteFromUploadDictionary(imageTobeDeleted: toBeDeletedImage)
                self.deletePhoto(albumData)
            }
        }
        
        if(albumData.url == nil){
            
            self.deleteFromUploadDictionary(imageTobeDeleted: toBeDeletedImage)
            photoArrayPhotosCounter = 0
            lastItemforCropperPickerArray = false
            collectionView.reloadData()
        }
        
        photoArrayPhotosCounter = 0
        lastItemforCropperPickerArray = false
        collectionView.reloadData()
        
        self.view.addSubview(deletePhotoObject)
    }
    
    
    func deletionOfCropSelectedPhoto(toBeSelectedImage : UIImage){
        
        let deletePhotoObject:DeletePhotoView = Bundle.main.loadNibNamed("DeletePhotoView", owner: self, options:nil)?.first as! DeletePhotoView
        deletePhotoObject.frame = self.view.bounds
        deletePhotoObject.setDeleteDataOnViewWith(toBeSelectedImage) {
            
            self.deleteFromUploadDictionary(imageTobeDeleted: toBeSelectedImage)
            self.photoArrayPhotosCounter = 0
            self.lastItemforCropperPickerArray = false
            self.collectionView.reloadData()
        
        }
        
            photoArrayPhotosCounter = 0
            lastItemforCropperPickerArray = false
            collectionView.reloadData()
        
        
        self.view.addSubview(deletePhotoObject)
        
    }
    
    func deleteInCompatiblePhoto(_ albumData:AlbumPhoto, imageToBeDeleted : UIImage){
        
        let alert: UIAlertController = UIAlertController(title: "",
                                                         message: NSLocalizedString("This photo did not meet our photo guidelines. Please upload another one.", comment:""),
                                                         preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
            self.deleteFromUploadDictionary(imageTobeDeleted: imageToBeDeleted)
            self.deletePhoto(albumData)
        })
        
        let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Add a Photo", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.deleteFromUploadDictionary(imageTobeDeleted: imageToBeDeleted)
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
        
       for i in self.uploadImageSuccessfullDictionary.indices{
           
           if((self.uploadImageSuccessfullDictionary[i]["imageData"] as! NSData).isEqual(deleteImageData)){
               
              print("delete ho gya finally")
              indexForDeletion = i
               break
           }
       }
        
        if(indexForDeletion != nil){
            self.uploadImageSuccessfullDictionary.remove(at: indexForDeletion!)
        }
         
        
        UserDefaults.standard.set(self.uploadImageSuccessfullDictionary, forKey: "uploadedDictionary")
        UserDefaults.standard.synchronize()
        
    }
    
    
    
    func deletePhoto(_ album:AlbumPhoto){
        
        print("delete this photo")
        ImageAPIClass.deletePhoto(forObjectID: album.objectId, andCompletionBlock: { (response, success, statusCode) in
            let albumModel = WooAlbumModel()
            albumModel.isMyprofile = true
            if (response as! NSDictionary).object(forKey: "wooAlbum") != nil{
                albumModel.addObjectsFromArray((response as! NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
            }
//            else{
//                self.showSnackBar(NSLocalizedString("We are facing some issue. Please try after some time.", comment: ""))
//                return
//            }
            self.dataSource = albumModel
            DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = albumModel
            self.photoCounter = 1
            self.doDynamicHeading()
            if let myProfile = DiscoverProfileCollection.sharedInstance.myProfileData{
                myProfile.profileCompletenessScore = "\((response as! NSDictionary).object(forKey: "profileCompletenessScore") ?? "0")"
                myProfile.wooAlbum = albumModel
            }
            
            self.lastItemforCropperPickerArray = false
            self.photoArrayPhotosCounter = 0
            self.collectionView.reloadData()
        })
        
    }
    
    func makeEditProfileCallForMove(){
        let myProfileDictionary = dataSource?.dictionaryfyHavingRejected()
        let profilePicID = dataSource?.profilePicData()?.objectId
        ProfileAPIClass.updateMyProfileDataForUser(withPayload: DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary!), andProfilePicID: profilePicID, andCompletionBlock: { (response, success, statusCode) in
            DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore = "\((response as! NSDictionary).object(forKey: "profileCompletenessScore") ?? "0")"
            let albumModel = WooAlbumModel()
            albumModel.isMyprofile = true
            albumModel.addObjectsFromArray((response as! NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
            self.dataSource = albumModel
            DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = albumModel
            self.photoCounter = 1
            self.lastItemforCropperPickerArray = false
            self.photoArrayPhotosCounter = 0
            self.collectionView.reloadData()
        })
   }
    
    
    private func showDeletePopup(_ showForSingleImage:Bool){
        var commentString = ""
        var cancelString = ""
        if showForSingleImage{
            commentString = NSLocalizedString("You need more than one approved photo to delete your main photo.", comment:"")
            cancelString = NSLocalizedString("Later", comment:"")
        }
//        else{
//            var photoString = ""
//            if LoginModel.sharedInstance().minPhotoCountForOnboarding == 1{
//                photoString = " photo"
//            }
//            else{
//                photoString = " photos"
//            }
//            commentString = "You need minimum \(LoginModel.sharedInstance().minPhotoCountForOnboarding)" + photoString
//
//            cancelString = "OK"
//        }
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("", comment: ""),
                                                         message: commentString,
                                                         preferredStyle: .alert)
    
        let cancelAction: UIAlertAction = UIAlertAction(title: cancelString, style: .cancel, handler: {(action: UIAlertAction) -> Void in
            
        })
        
        let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Add another", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.showImagePickerOptions()
        })
        
        alert.addAction(cancelAction)
        
        if showForSingleImage{
        alert.addAction(reportAction)
        }
        //t3681510
        self.present(alert, animated: true, completion: {() -> Void in
        })
    }
    
    
    func makeCropPickerController(_ type: CropPickerType, isCamera: Bool, maxAllowedImages: Int) -> CropPickerController {
        let cropPickerController = CropPickerController(type, isCamera: isCamera, maxAllowedImages: maxAllowedImages, comingFromEditProfile: false)
        cropPickerController.delegate = self as! CropPickerDelegate
            return cropPickerController
        }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
 }
 
 extension WizardPhotoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
 
 extension WizardPhotoViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       var cell : PhotoCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellID", for: indexPath)  as? PhotoCollectionViewCell
        
        if cell == nil {
            let array = Bundle.main.loadNibNamed("PhotoCollectionViewCell", owner: self, options: nil)
            cell = array?.first as? PhotoCollectionViewCell
        }
        
        print("datasource count is", dataSource?.count())
        if (indexPath as NSIndexPath).item < (dataSource?.count()) ?? 0 {
            
            let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)
            if  album != nil{
                cell?.lblTopNumber.text = nil
                cell?.deleteButton.isHidden = false
                cell?.isUserInteractionEnabled = false
                
                if indexPath.item == 0{
                    cell?.deleteButton.setImage(UIImage(named: "ic_edit_main_photo_delete"), for: .normal)
                    cell?.deleteButtonWidthConstraint.constant = 48
                    cell?.deleteButtonHeightConstraint.constant = 48
                }
                else{
                    cell?.deleteButton.setImage(UIImage(named: "ic_edit_other_photo_delete"), for: .normal)
                    cell?.deleteButtonWidthConstraint.constant = 38
                    cell?.deleteButtonHeightConstraint.constant = 38
                }
                
                
                cell?.imageDeleteHandler = {() in
                    
                    if indexPath.item == 0{
                        let album = self.dataSource!.objectAtIndex(indexPath.item)!
                        if album.status == "REJECTED"{
                            self.deleteInCompatiblePhoto(album, imageToBeDeleted: (cell?.imageView.image!)!)
                        }
                        else{
                            if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false) {
                                if (self.dataSource?.countOfApprovedPhotos())! <= Int(LoginModel.sharedInstance().minPhotoCountForOnboarding){
                                    if LoginModel.sharedInstance().minPhotoCountForOnboarding == 1{
                                        self.showDeletePopup(true)
                                    }
                                    else{
                                        self.showDeletePopup(false)
                                    }
                                }
                                else{
                                    self.showDeleteConfirmationPopupForImage((cell?.imageView.image!)!, albumData: album)

                                }
                            }
                            else{
                            if self.dataSource!.countOfApprovedPhotos() > 1{
                                self.showDeleteConfirmationPopupForImage((cell?.imageView.image!)!, albumData: album)
                            }
                            else{
                                
                                self.showDeletePopup(true)
                            }
                            }
                        }
                    }
                    else{
                        let album = self.dataSource!.objectAtIndex(indexPath.item)!
                        if album.status == "REJECTED"{
                            self.deleteInCompatiblePhoto(album, imageToBeDeleted: (cell?.imageView.image!)!)
                        }
                        else{
                           if (UserDefaults.standard.bool(forKey: "isOnboardingMyProfileShown") == false) {
                            if (self.dataSource?.countOfApprovedPhotos())! <= Int(LoginModel.sharedInstance().minPhotoCountForOnboarding){
                                self.showDeletePopup(false)
                            }
                            else{
                                self.showDeleteConfirmationPopupForImage((cell?.imageView.image!)!, albumData: album)

                            }
                            }
                           else{
                            self.showDeleteConfirmationPopupForImage((cell?.imageView.image!)!, albumData: album)
                            }
                        }
                    }
                }
                cell?.imageView.isHidden = false
                cell?.imageView.sd_setImage(with: URL(string: (album?.url)!), placeholderImage: UIImage(named: "ic_edit_profile_placeholder"), options: SDWebImageOptions(), completed: { (image, error, cacheType, url) in
                    cell?.imageView.isHidden = false
                    cell?.isUserInteractionEnabled = true
                    if (indexPath as NSIndexPath).item == 0 {
                        //cell?.deleteButton.isHidden = true
                    }
                    else{
                        cell!.deleteButton.isHidden = false
                    }
                })
                
                if album?.status == "PENDING" {
                     cell?.lblTopNumber.isHidden = true
                    cell?.statusView.isHidden = false
                    cell?.statusView.backgroundColor = UIColor.black
                    //cell?.statusView.alpha = 0.93
                    let utilities = Utilities.sharedUtility() as! Utilities
                    cell?.statusView.backgroundColor = utilities.getUIColorObject(fromHexString: "#DE8600", alpha: 1.0)
                    
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main - In Review"
                    }
                    else{
                        cell?.statusLabel.text = "In Review"
                    }
                }
                else if album?.status == "APPROVED" {
                    if !isPhotoDragStarted{
                        cell?.lblTopNumber.isHidden = false
                    }
                    else{
                        cell?.lblTopNumber.isHidden = true
                    }
                    cell?.lblTopNumber.text = String(indexPath.row+1)
                    photoCounter += 1
                    cell?.statusView.backgroundColor = UIColor.black
                    
                    if DiscoverProfileCollection.sharedInstance.pendingListContains(album!) {
                        cell?.statusView.isHidden = true
                        if indexPath.item == 0 {
                            cell?.statusLabel.text = "Main - Approved"
                        }
                        else{
                            cell?.statusLabel.text = "Approved"
                        }
                    }
                    else{
                        if indexPath.item == 0 {
                            cell?.statusLabel.text = "Main"
                            cell?.statusView.isHidden = true
                        }
                        else{
                            cell?.statusView.isHidden = true
                        }
                    }
                }
                else if album?.status == "REJECTED" {
                    cell?.lblTopNumber.isHidden = true
                    cell?.statusView.isHidden = false
                    cell?.statusView.backgroundColor = UIColor(red: 250.0/255.0, green: 72.0/255.0, blue: 73.0/255.0, alpha: 1.0)
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main - Incompatible"
                    }
                    else{
                        cell?.statusLabel.text = "Incompatible"
                    }
                }
                
            }
        }
        else{
            
            if multipleImagesFetchingFromCropPickerViewArray.count != 0 && lastItemforCropperPickerArray == false {
                
                let indicator = UIActivityIndicatorView(style: .whiteLarge)
                indicator.color = .orange
                indicator.center = CGPoint(x: cell!.frame.size.width / 2, y: cell!.frame.size.height / 2)
                cell?.addSubview(indicator)
                
                cell?.imageView.image = nil
                cell?.lblTopNumber.isHidden = false
                cell?.lblTopNumber.text = String(indexPath.row+1)
                photoCounter += 1
                cell?.statusView.backgroundColor = UIColor.black
                cell?.imageView.isHidden = false
                cell?.imageView.image = UIImage(data: multipleImagesFetchingFromCropPickerViewArray[photoArrayPhotosCounter] as Data)
                cell?.imageView.image = UIImageEffects.imageByApplyingDarkEffect(to: cell?.imageView.image)
                indicator.startAnimating()
                
                cell?.deleteButton.isHidden = true
                if indexPath.item == 0{
                    cell?.deleteButton.setImage(UIImage(named: "ic_edit_main_photo_delete"), for: .normal)
                    cell?.deleteButtonWidthConstraint.constant = 48
                    cell?.deleteButtonHeightConstraint.constant = 48
                }
                else{
                    cell?.deleteButton.setImage(UIImage(named: "ic_edit_other_photo_delete"), for: .normal)
                    cell?.deleteButtonWidthConstraint.constant = 38
                    cell?.deleteButtonHeightConstraint.constant = 38
                }
                
            if(multipleImagesFetchingFromCropPickerViewArray[photoArrayPhotosCounter] == multipleImagesFetchingFromCropPickerViewArray.last){
                    lastItemforCropperPickerArray = true
            }else{
                    lastItemforCropperPickerArray = false
            }
                
            photoArrayPhotosCounter += 1
                
            }else{
                cell!.imageView.isHidden = true
                cell!.deleteButton.isHidden = true
                cell?.statusView.isHidden = true
                cell?.lblTopNumber.isHidden = true
            }
            
        }
        return cell!
    }
 }
 
 extension WizardPhotoViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        if dataSource?.count() == 0 || (indexPath as NSIndexPath).item != 0 {
            
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            if (indexPath as NSIndexPath).item < (dataSource?.count())! {
                let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)
                if album?.status == "REJECTED" {
                    self.deleteInCompatiblePhoto(album!, imageToBeDeleted: cell.imageView.image!)
                }
                else{
                    self.addImage(indexPath.row, image: cell.imageView.image!)
                }
            }
            else{
                if let cellImage = cell.imageView.image{
                    self.addImage(indexPath.row, image: cellImage)
                }
                else{
                    self.addImage(indexPath.row, image: nil)
                }
            }
        }
        else{
            if (indexPath as NSIndexPath).item == 0{
                let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                if album?.status == "REJECTED" {
                    self.deleteInCompatiblePhoto(album!, imageToBeDeleted: cell.imageView.image!)
                }
                else{
                    self.addImage(indexPath.row, image: cell.imageView.image!)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemAtIndexPath
        fromIndexPath: IndexPath, didMoveToIndexPath toIndexPath: IndexPath) {
        isPhotoDragStarted = true
        
        if (toIndexPath as NSIndexPath).item != (fromIndexPath as NSIndexPath).item {
            needToMakeDiscoverCall = true
            if (toIndexPath as NSIndexPath).item == 0 {
                dataSource?.objectAtIndex(0)?.isProfilePic = false
                dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.isProfilePic = true
            }
            else if (fromIndexPath as NSIndexPath).item == 0 {
                dataSource?.objectAtIndex(0)?.isProfilePic = true
                dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.isProfilePic = false
            }
            
            let fromItem = dataSource!.photoArray.object(at: (fromIndexPath as NSIndexPath).item)
            dataSource!.photoArray.removeObject(at: (fromIndexPath as NSIndexPath).item)
            if (toIndexPath as NSIndexPath).item > (fromIndexPath as NSIndexPath).item {
                dataSource!.photoArray.insert(fromItem, at: (toIndexPath as NSIndexPath).item)
            }
            else{
                dataSource!.photoArray.insert(fromItem, at: (toIndexPath as NSIndexPath).item)
            }
            makeEditProfileCallForMove()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemAtIndexPath fromIndexPath: IndexPath, canMoveToIndexPath toIndexPath: IndexPath) -> Bool {
        // self.photoCounter = 1
        if (fromIndexPath as NSIndexPath).item < (dataSource?.count())! && (toIndexPath as NSIndexPath).item < (dataSource?.count())!{
            if (dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.status == "PENDING" ||
                dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.status == "REJECTED") &&
                (toIndexPath as NSIndexPath).item == 0 {
                needToShowInReviewAlert = true
                return false
            }
            else if (fromIndexPath as NSIndexPath).item == 0{
                if (dataSource?.objectAtIndex((toIndexPath as NSIndexPath).item)?.status == "PENDING" ||
                    dataSource?.objectAtIndex((toIndexPath as NSIndexPath).item)?.status == "REJECTED"){
                    needToShowInReviewAlert = true
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item){
            if album.status == "REJECTED"{
                
                if let data = try? Data(contentsOf: URL(string: album.url!)!)
                {
                    let image: UIImage = UIImage(data: data)!
                    self.deleteInCompatiblePhoto(album, imageToBeDeleted: image)
                }
                
                return false
            }
            return true
        }
        else{
            return false
        }
    }
    
    @objc(collectionView:canFocusItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).item < (dataSource?.count())! && (indexPath as NSIndexPath).item != 0  {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, movementEndedAtIndexPath indexPath: IndexPath){
       
        isPhotoDragStarted = false
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.photoCounter = 1
            self.lastItemforCropperPickerArray = false
            self.photoArrayPhotosCounter = 0
            collectionView.reloadData()
            
            
            if self.needToShowInReviewAlert{
                self.showInReviewAlert()
                self.needToShowInReviewAlert = false
            }
        })
    }
    
    func sectionSpacingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 5.0
    }
    
    func minimumInteritemSpacingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 5.0
    }
    
    func minimumLineSpacingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 5.0
    }
    
    func insetsForCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func autoScrollTrigerEdgeInsets(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50.0, left: 0, bottom: 50.0, right: 0)
    }
    
    func autoScrollTrigerPadding(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 64.0, left: 0, bottom: 0, right: 0)
    }
    
    func reorderingItemAlpha(_ collectionview: UICollectionView) -> CGFloat {
        return 0.3
    }
 }
 
 
 extension WizardPhotoViewController : CropPickerDelegate{
  
    
    func cropPickerBackAction(_ cropPickerController: CropPickerController) {
        if (cropPickerController.navigationController?.viewControllers.first as? CropPickerController) == nil {
            cropPickerController.navigationController?.popViewController(animated: true)
        } else {
            cropPickerController.dismiss(animated: true, completion: nil)
        }
        
        self.photoCounter = 1
        photoArrayPhotosCounter = 0
        lastItemforCropperPickerArray = false
        collectionView.reloadData()
    }
    
    func cropPickerCompleteAction(_ cropPickerController: CropPickerController, images: [UIImage]?, error: Error?,navigationController: UINavigationController) {
        
        self.cropPickerControllerForClose = cropPickerController
        
        callBackFromGalleryForNextScreen()
        
        if let error = error as NSError? {
            let alertController = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            cropPickerController.present(alertController, animated: true, completion: nil)
            return
        }
        
        if let images = images {
            
            self.photoForMatching = 0
            
            for image in images {
                self.multipleImagesFetchingFromCropPickerViewArray.append(image.pngData()! as NSData)
                remainingImagesForUploadingOnDiscover.append(image.pngData()!)
            }
            
            self.photoCounter = 1
            self.photoArrayPhotosCounter = 0
            self.collectionView.reloadData()
            uploadImage(imageData: remainingImagesForUploadingOnDiscover[photoForMatching])
            
        }

        WizardScreensCalculator.sharedInstance.isCropperVisible = true
        WizardScreensCalculator.sharedInstance.cropPickerNavigationController = navigationController
    }
    
    func uploadImage(imageData: Data){
        
        let image = UIImage(data: imageData)
        
        ImageAPIClass.uploadImage(toServer: image, andObjectId: "", withFakeCheck: true) { (response, success, stausCode) in
                
                if(success){
                    
//                    if (self.remainingImagesForUploadingOnDiscover.count == 1){
                        DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore = String((response as! NSDictionary).object(forKey: "profileCompletenessScore") as! Int)
                        let albumModel = WooAlbumModel()
                        albumModel.isMyprofile = true
                        albumModel.addObjectsFromArray((response as! NSDictionary).object(forKey: "wooAlbum") as! [AnyObject])
                        DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum = albumModel
                        self.dataSource = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum
                        
//                        self.multipleImagesFetchingFromCropPickerViewArray = [self.remainingImagesForUploadingOnDiscover[0] as NSData]
//                    }
                 
                    let lastElementArray : NSArray = (response as! NSDictionary).object(forKey: "wooAlbum") as! NSArray
                    
                    let lastElementDetails :NSDictionary = lastElementArray[lastElementArray.count - 1] as! NSDictionary
                    
                    let imageData = try! Data(contentsOf: URL(string: lastElementDetails["cachedSrcBig"] as! String)!)
                    let savedImage = UIImage(data: imageData)!
                    
                    print("uploadImageSuccessfullDictionary")
                    
                    self.uploadImageSuccessfullDictionary.append([
                        "imageURL" :  lastElementDetails["cachedSrcBig"]!,
                        "status"   :  lastElementDetails["photoStatus"]!,
                        "imageData" : savedImage.pngData()! as NSData
                    ])
                    
                    self.remainingImagesForUploadingOnDiscover.remove(at: 0)
                    self.multipleImagesFetchingFromCropPickerViewArray.remove(at: 0)
                    
                    UserDefaults.standard.set(self.remainingImagesForUploadingOnDiscover, forKey: "totalImagesForUploading")
                    UserDefaults.standard.set(self.uploadImageSuccessfullDictionary, forKey: "uploadedDictionary")
                    UserDefaults.standard.synchronize()
                    
                    self.photoForMatching += 1
                    
                    if(self.remainingImagesForUploadingOnDiscover.count != 0){
                        self.uploadImage(imageData: self.remainingImagesForUploadingOnDiscover[0])
                    }
                    
                    self.photoCounter = 1
                    self.photoArrayPhotosCounter = 0
                    self.lastItemforCropperPickerArray = false
                    self.collectionView.reloadData()
                    
                }
                
            }
        }
 }
 

 
