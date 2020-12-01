//
//  WizardWorkViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 06/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class WizardWorkViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var viewCounterLabel: UILabel!
    
    fileprivate var profileData : MyProfileModel?

    fileprivate var tokenGeneratorObj : TokenGenerator?

    @IBOutlet weak var secondLabel: UILabel!
    var customLoader:WooLoader?
    
    var userHasSyncedHisLinked = false
    
    var isCloseTapped = false
    var cropperIsAlreadyOpen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            closeTopConstraint.constant = 40
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Landing")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileData = DiscoverProfileCollection.sharedInstance.myProfileData
        if profileData?.gender == "MALE"{
            bottomLabel.text = "This will add a LinkedIn Verified badge to your profile"
        }
        else{
            bottomLabel.text = "You get to choose what to show or hide"
            secondLabel.text = "Increase your chances of finding like-minded people"
        }
        setupBottomArea()
    }
    @IBAction func back(_ sender: Any) {
        WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
        
        if(WizardScreensCalculator.sharedInstance.currentWizardScreen == 1){
            cropperIsAlreadyOpen = true
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
    @IBAction func next(_ sender: Any) {
        isCloseTapped = false
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Next")

        if self.checkIfFlowIsComplete(){
            self.showWizardCompleteView(true)
        }
        else{
            WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Close")

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
    
    @IBAction func syncWithLinkedIn(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Sync")
        startLinkedInFlow()
    }
    
    func checkIfToShowDiscoverOrMe(){
        if DiscoverProfileCollection.sharedInstance.discoverModelCollection.count > 0{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        else{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
        }
    }
    
    func showWizardCompleteView(_ isCompleted:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
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
    
    
    func setupBottomArea(){
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            nextButton.setTitle("DONE", for: .normal)
        }
        else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            backButton.isHidden = true
        }
        viewCounterLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
        print("WizardScreensCalculator.sharedInstance.currentWizardScreen = %d",WizardScreensCalculator.sharedInstance.currentWizardScreen)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openEditProfileOnlyForWorkEducation(){
        /*
        let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        controller.isTypeOfWorkEducation = true
        controller.isShownFromWizard = true
        controller.wizardViewCounterText = viewCounterLabel.text!
        if self.checkIfFlowIsComplete(){
            controller.nextOrDoneButtonText = "DONE"
        }
        else{
            controller.nextOrDoneButtonText = "NEXT"
        }
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            controller.showWizardBackButton = false
        }
        else{
            controller.showWizardBackButton = true
        }
        controller.dismissHandler = { (isModified, toClose) in
            self.isCloseTapped = toClose
            if isModified{
                if toClose{
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else{
                    if self.checkIfFlowIsComplete(){
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    else{
                        WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                    }
                }
            }
            else{
                self.back(UIButton())
            }
        }
        
        controller.isRefreshNeeded = true
        self.navigationController?.pushViewController(controller, animated: false)
    */
    }
    
    func sendDataToServer(){
        let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        
        var _college : [NSMutableDictionary] = []
        _college.append((profileData?.selectedCollege().dictionarify())!)
        myProfileDictionary["college"] = _college
        //degree - 4
        var _degree : [NSMutableDictionary] = []
        _degree.append((profileData?.selectedDegree().dictionarify())!)
        myProfileDictionary["degree"] = _degree
        //company - 5
        var _company : [NSMutableDictionary] = []
        _company.append((profileData?.selectedCompany().dictionarify())!)
        myProfileDictionary["company"] = _company
        //designation - 6
        var _designation : [NSMutableDictionary] = []
        _designation.append((profileData?.selectedDesignation().dictionarify())!)
        myProfileDictionary["designation"] = _designation
        
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary))!)
        
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
            let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is WizardWorkViewController
            if !currenViewControllerIsSelf{
                return
            }
            self.hideWooLoader()
            if self.isCloseTapped{
                self.isCloseTapped = false
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                    
                    if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                        self.showWizardCompleteView(false)
                    }
                    else{
                        self.checkIfToShowDiscoverOrMe()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
            }
            else{
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
            }
        }
    }
    
    func startLinkedInFlow(){
        if self.tokenGeneratorObj == nil {
            self.tokenGeneratorObj = TokenGenerator()
        }
        self.tokenGeneratorObj!.delegate = self
        self.tokenGeneratorObj!.successSelectorForTokenGenerated = #selector(self.tokenGeneratedSuccessfullyWithData)
        self.tokenGeneratorObj!.failureSelectorForTokenGenerated = #selector(self.tokenGenerationFailedWithData)
        
        self.navigationController?.pushViewController(self.tokenGeneratorObj!, animated: true)
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
    
    //MARK: LinkedIn delegate functions
    @objc func tokenGeneratedSuccessfullyWithData(_ tokenData: AnyObject) {
        
        let data: Data = (tokenData as! String).data(using: String.Encoding.utf8)!
        let json: AnyObject = try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        var tokenDictionary: [AnyHashable: Any] = (json as! [AnyHashable: Any])
        let access: String? = (tokenDictionary["access_token"] as! String)
        print("token >>> \(access ?? "")")
        
        if access != nil {
            self.showWooLoader()
            FBLinkedInAPIClass.updateLinkInSyncData(withAccessToken: access, andCompletionBlock: { (success, _response, errorCode) in
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "EditProfileScreen", withEventName: "3-EditProfile.EditProfileScreen.EP_SyncLinkedIn")
                
                
                self.hideWooLoader()
                if success {
                    if let response : NSDictionary = _response as? NSDictionary{
                        DiscoverProfileCollection.sharedInstance.myProfileData?.updateData(response)
                        self.openEditProfileOnlyForWorkEducation()
                    }
                    else{
                        self.handleErrorForResponseCode(Int(errorCode))
                    }
                }
            })
        }
    }
    
    @objc func tokenGenerationFailedWithData(_ failureData: [AnyHashable: Any]) {
        print("Failure data \(failureData)")
        UserDefaults.standard.set(false, forKey: kIsLinkedInVerified)
        UserDefaults.standard.synchronize()
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
