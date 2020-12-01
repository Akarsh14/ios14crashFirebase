//
//  CommonPhoneNumberVerify.swift
//  Woo_v2
//
//  Created by Kuramsetty Harish on 22/08/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class CommonPhoneNumberVerify: UIViewController, TCTrueSDKDelegate, AKFViewControllerDelegate {

    var successHandler : ((Bool, NSInteger) -> ())?
    static let sharedInstance = CommonPhoneNumberVerify()
    var controller:UIViewController?
    //var _accountKit: AccountKit?
    
    var showLoaderAfterSucess: Bool?
    var _pendingLoginViewController: AKFViewController?
    fileprivate var customLoader :WooLoader?
    func initfbKit(){
        
        print("initialise the account kit")
//        if _accountKit == nil {
//            _accountKit = AccountKit(responseType: .authorizationCode)
//        }
//        _pendingLoginViewController = _accountKit!.viewControllerForLoginResume()
//        _pendingLoginViewController?.delegate = self
    }
    
    /*Description: This method will be tell if true caller is installed in the user phone or not. If tc is installed it will take to the true caller flow
     Parameters: NIl
     Returns: Bool
     */
    func canWeStartTrueCaller()->Bool{
        if isOSSupportingTrueCaller(){
            let tcManager = TCTrueSDK.sharedManager()
            if(tcManager.isSupported())
            {
                tcManager.delegate = self
                tcManager.requestTrueProfile()
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    
    /*Description: This method will be called whenver truecaller flow is sucess
     Parameters: Nil
     Returns: Nil
     */
    public func didReceive(_ profileResponse: TCTrueProfileResponse) {
        
        LoginModel.sharedInstance().isAlternateLogin = true
        LoginModel.sharedInstance().isAlertnativeLoginTypeTrueCaller = true
        let parameters = ["signature":profileResponse.signature! ,"payload": profileResponse.payload!, "requestNonce": profileResponse.requestNonce!, "signatureAlgorithm": profileResponse.signatureAlgorithm!] as NSDictionary
         IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        if (self.showLoaderAfterSucess)!{
              self.showWooLoader()
        }
      
        PhoneVerifyApiClass.verifyPhone(forAccessToken: nil, request: true, trueCallerParameters: parameters) { (success, response, statusCode) in
            if (self.showLoaderAfterSucess)!{
                 self.removeWooLoader()
            }
        
            self.successHandler!(success, NSInteger(statusCode))
            
        }
     }
    
    //MARK: Woo Loader
    func showWooLoader() {
        customLoader = WooLoader(frame: self.view.frame)
        customLoader!.startAnimation(on: controller?.view, withBackGround: true)
    }
    
    func removeWooLoader() {
        if customLoader != nil {
            customLoader!.removeFromSuperview()
            customLoader = nil
        }
    }
    
    
    /*Description: This method will be called whenver there is fail in login flow of the Truecaller     Parameters: Nil
     Returns: Nil
     */
   
    public func didFailToReceiveTrueProfileWithError(_ error: TCError) {
        NSLog("Error \(error.localizedDescription)")
        switch error.getCode() {
        case TCTrueSDKErrorCode.userCancelled:
//            self.displayActionSheet()
            break
        case TCTrueSDKErrorCode.internal:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.network:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.osNotSupported:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.sdkTooOld:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.truecallerTooOld:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.unauthorizedUser:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.userNotSignedIn:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.verificationFailed:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.userProfileContentNotValid:
            self.popAlert(withString: error.localizedDescription)
            break
        case TCTrueSDKErrorCode.badRequest:
            self.popAlert(withString: error.localizedDescription)
            break
        default:
            //TODO-DO
            // Error occurred in network communication
            break
        }
    }
    
    func didReceive(_ profile: TCTrueProfile) {}
    
    
    func popAlert(withString: String){
        let alert = UIAlertController(title: "Alert", message: withString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller?.present(alert, animated: true, completion: nil)
    }
    
    /*Description: This method will be Called whenever user clicks on the Sign IN With Phone Number in login screen
     Parameters: NIl
     Returns: Nil
     */
    @objc internal func loginViaNumber(){
        if (!canWeStartTrueCaller()){
            self.startFbAccountKitlogin(EditProfileViewController())
        }
    }
    
    
    /*Description: This method will Start FB Account Kit login Flow
     Returns: Nil
     Parameters: Nil
     */
    func startFbAccountKitlogin(_ presentViewController:EditProfileViewController){
        
        print("fb kit account starting")
//        initfbKit()
//        IQKeyboardManager.shared().isEnabled = true
//        IQKeyboardManager.shared().isEnableAutoToolbar = true
//        let viewController: AKFViewController = _accountKit!.viewControllerForPhoneLogin(with: nil, state: nil) as AKFViewController
//        prepareLoginViewController(viewController)
//        controller?.present(viewController as! UIViewController, animated: true, completion: {
//
//        })
    }
    
    
    /*Description: This method will be open the Fb Account kit login Flo
     Parameters: LoginViewController
     Returns: Nil
     */
    func prepareLoginViewController(_ loginViewController: AKFViewController) {
        
        print("prepare loginview contoller")
//        loginViewController.delegate = self
//        loginViewController.uiManager = MyUiManager(UIColor.white, isOpenedFromDiscover: false, isUsedInOnBoarding: true)
    }
    
    /*Description: This method will be called whenever the facebook account kit is success
     Parameters: ViewController
     Returns: Nil
     */
  /*  public func viewController(_ viewController: (UIViewController & AKFViewController)!,
                               didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        LoginModel.sharedInstance().isAlternateLogin = true
        LoginModel.sharedInstance().isAlertnativeLoginTypeTrueCaller = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //self.makeLoginCallToServer(withUserId: nil, withAccessToken: accessToken.tokenString, withDictionary: nil, andLoginThrough: LoginViaFacebookAccountKit)
     }}*/
}
