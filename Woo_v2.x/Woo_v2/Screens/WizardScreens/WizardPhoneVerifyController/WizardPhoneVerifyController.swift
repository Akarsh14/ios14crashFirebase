//
//  WizardPhoneVerifyController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 13/03/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit
import IQKeyboardManager
import AccountKit

class WizardPhoneVerifyController: UIViewController {

    @IBOutlet weak var verifyNumberButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var phoneVerifiedView: UIView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    fileprivate var profileData : MyProfileModel?
    fileprivate var customLoader :WooLoader?
    //fileprivate var accountKit = AccountKit(responseType: .accessToken)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser(not:)), name: NSNotification.Name(rawValue: "kGetResultFromFirebaseAuthenticationForWizardScreen"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileData = DiscoverProfileCollection.sharedInstance.myProfileData
        
        var phoneNumber = ""
        if profileData?.phoneNumberDto != nil {
            if ((profileData?.phoneNumberDto?.object(forKey: "phoneNumber")) != nil){
                phoneNumber = profileData?.phoneNumberDto?.object(forKey: "phoneNumber") as! String
            }
        }
        if phoneNumber.count > 0{
            phoneVerifiedView.isHidden = false
            phoneImageView.isHidden = true
            verifyNumberButton.isHidden = true
        }
        else{
            phoneVerifiedView.isHidden = true
            phoneImageView.isHidden = false
            verifyNumberButton.isHidden = false
        }
        if profileData?.gender == "MALE"{
            secondLabel.text = "Verify your phone number to increase your chances of a match"
        }
        setupBottomArea()
    }
    
    func setupBottomArea(){
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            nextButton.setTitle("DONE", for: .normal)
        }
        else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            backButton.isHidden = true
        }
        counterLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
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
    
    @IBAction func verifyNumber(_ sender: Any) {
        
        CommonPhoneNumberVerify.sharedInstance.controller = self
        CommonPhoneNumberVerify.sharedInstance.showLoaderAfterSucess = true
        CommonPhoneNumberVerify.sharedInstance.successHandler = { (isSuccess, StatusCode)
            in
                self.verifyPhoneNumberFromServer(statusCode: StatusCode)
            
        }
        
           if(!CommonPhoneNumberVerify.sharedInstance.canWeStartTrueCaller()){
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
//        if let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil) as? AKFViewController {
//            prepareLoginViewController(viewController)
//            if let viewController = viewController as? UIViewController {
//                present(viewController, animated: true, completion: nil)
//            }
//        }
        }
        
        let phoneVerifyfromWhichScreen:[String: String] = ["screen": "WizardPhoneVerifyController"]
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: kFirebasePhoneAuthenticationObserver),
            object: self,
            userInfo: phoneVerifyfromWhichScreen
        )
        
    }
    
    
    @objc func updateUser(not: Notification) {
        // userInfo is the payload send by sender of notification
        if let userInfo = not.userInfo {
           // Safely unwrap the name sent out by the notification sender
            if let statusCode = userInfo["statusCode"] as? Int {
                handlePhoneVerification(statusCode: statusCode)
            }
        }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    func handlePhoneVerification(statusCode: NSInteger){
        if statusCode == 200{
            self.showSnackBar("Phone number verified")
            phoneVerifiedView.isHidden = false
            phoneImageView.isHidden = true
            verifyNumberButton.isHidden = true
        }
        else if statusCode == 404{
            _ = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: false, withController: self)
        }
        else if statusCode == 400{
            _ = AlertController.showAlert(withTitle: "", andMessage: "           We are facing some technical issue. Please retry after some time.", needHandler: false, withController: self)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
            if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                self.showWizardCompleteView(false)
            }
            else{
                self.showWizardCompleteView(true)
            }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func back(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func next(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        if self.checkIfFlowIsComplete(){
            self.showWizardCompleteView(true)
        }
        else
        {
            WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
        }
    }
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
        
        print("wizard comments account kit")
//        loginViewController.delegate = self as AKFViewControllerDelegate
//        loginViewController.defaultCountryCode = "IN"
//        loginViewController.uiManager = MyUiManager(UIColor.white, isOpenedFromDiscover: false, isUsedInOnBoarding: false) as UIManager
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - AKFViewControllerDelegate extension

extension WizardPhoneVerifyController: AKFViewControllerDelegate {
    
    private func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AccessToken!, state: String!) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
       
       
            IQKeyboardManager.shared().isEnabled = false
            IQKeyboardManager.shared().isEnableAutoToolbar = false
            self.showWooLoader()
            PhoneVerifyApiClass.verifyPhone(forAccessToken: accessToken.tokenString, request: false, trueCallerParameters: nil, withCompletionBlock: { (success, response, statusCode) in
                self.hideWooLoader()
                self.verifyPhoneNumberFromServer(statusCode: NSInteger(statusCode))
            })
        
    }
    
    func verifyPhoneNumberFromServer(statusCode: NSInteger){
        if statusCode == 200{
            self.profileData = DiscoverProfileCollection.sharedInstance.myProfileData
            WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
            self.next(UIButton())
        }
        else if statusCode == 404{
            _ = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: false, withController: self)
        }
        else if statusCode == 400{
            _ = AlertController.showAlert(withTitle: "", andMessage: "We are facing some technical issue. Please retry after some time.", needHandler: false, withController: self)

        }
    }
    
    private func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
    
    internal func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)) {
        print("\(viewController) did cancel:")
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
}
