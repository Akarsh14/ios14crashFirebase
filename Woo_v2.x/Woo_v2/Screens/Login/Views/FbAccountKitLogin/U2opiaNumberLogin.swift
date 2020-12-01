//
//  U2opiaNumberLogin.swift
//  Woo_v2
//
//  Created by Kuramsetty Harish on 05/07/2018.
//  Copyright © 2018 Woo. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    @objc static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}


class U2opiaNumberLogin: UIView {
    //Use this space if we want to customize Ph Number login area.. Just connect the FBview and customize
}

// MARK: - Login ViewController Extension

extension LoginViewController : AKFViewControllerDelegate{
    /*Description: This method will initiate the delegate of the Facebook
     Parameters: LoginViewController
     Returns: Nil
     */
    func prepareLoginViewController(loginViewController: AKFViewController) {
        loginViewController.delegate = self
    }
    
    
    /*Description: This method will be Called whenever user clicks on the Sign IN With Phone Number in login screen
     Parameters: NIl
     Returns: Nil
     */
    
    @objc internal func loginViaNumber(){
        if (!canWeStartTrueCaller()){
             startNativeLoginFlow()
             //self.startFbAccountKitlogin()
        }
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
                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TRUECALLER_LOGIN")
                        (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "TRUECALLER_LOGIN")
                        return true
                    }else{
                        return false
                    }
        }else{
            return false
        }
      }
    
    
    func startNativeLoginFlow(){
        let onBoardingStoryboard = UIStoryboard(name: "onboarding", bundle: nil)
               let onBoardingName = onBoardingStoryboard.instantiateViewController(withIdentifier: "NativeOTPScreenViewController") as! NativeOTPScreenViewController
               onBoardingName.delegate = self
               self.navigationController?.pushViewController(onBoardingName, animated: true)
    }
    
    /*Description: This method will Start FB Account Kit login Flow
     Returns: Nil
     Parameters: Nil
     */
    func startFbAccountKitlogin(){
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
//        let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil) as AKFViewController
//        prepareLoginViewController(viewController)
//        if let viewController = viewController as? UIViewController {
//            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAP_PHONE_LOGIN")
//            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "TAP_PHONE_LOGIN")
//            if #available(iOS 13.0, *) {
//                viewController.modalPresentationStyle = .fullScreen
//            } else {
//                // Fallback on earlier versions
//            }
//            present(viewController, animated: true, completion: nil)
        //}
    }
    
    
    /*Description: This method will be open the Fb Account kit login Flo
     Parameters: LoginViewController
     Returns: Nil
     */
    func prepareLoginViewController(_ loginViewController: AKFViewController) {
//        loginViewController.delegate = self
//        loginViewController.uiManager = MyUiManager(UIColor.white, isOpenedFromDiscover: false, isUsedInOnBoarding: true) as UIManager
    }
    
    /*Description: This method will be called whenever the facebook account kit is success
     Parameters: ViewController
     Returns: Nil
     */
    public func viewController(_ viewController: (UIViewController & AKFViewController),
                               didCompleteLoginWith accessToken: AKAccessToken, state: String) {
//        LoginModel.sharedInstance().isAlternateLogin = true
//        LoginModel.sharedInstance().isAlertnativeLoginTypeTrueCaller = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.makeLoginCallToServer(withUserId: nil, withAccessToken: accessToken.tokenString, withDictionary: nil, andLoginThrough: LoginViaFacebookAccountKit)
        //}
    }
   
    /*Description: This method will be called whenver there is fail in login flow of the Facebook account kit
     Parameters: Nil
     Returns: Nil
     */
    public func viewController(_ viewController: (UIViewController & AKFViewController), didFailWithError error: Error) {
        
        //Facebook is handling automatically
        
    }
    
    /*Description: This method will move the screen to onBoarding
     Parameters: Nil
     Returns: Nil
     */
    fileprivate func moveToOnBoardingScreensBasedOnData(){
        let onBoardingStoryboard = UIStoryboard(name: "onboarding", bundle: nil)
        let onBoardingName = onBoardingStoryboard.instantiateViewController(withIdentifier: "OnBoardingNameViewController")
        self.navigationController?.pushViewController(onBoardingName, animated: true)
    }
}





// MARK: - Extention to true caller
extension LoginViewController : TCTrueSDKDelegate
{
    
    /*Description: This method will be called whenver truecaller flow is sucess
     Parameters: Nil
     Returns: Nil
     */
    public func didReceive(_ profileResponse: TCTrueProfileResponse) {
        LoginModel.sharedInstance().isAlternateLogin = true
        LoginModel.sharedInstance().isAlertnativeLoginTypeTrueCaller = true
        let parameters = ["signature":profileResponse.signature! ,"payload": profileResponse.payload!, "requestNonce": profileResponse.requestNonce!, "signatureAlgorithm": profileResponse.signatureAlgorithm!] as NSDictionary
        self.makeLoginCallToServer(withUserId: nil, withAccessToken: "", withDictionary: parameters, andLoginThrough: LoginViaTrueCaller)
    }
    
    
    /*Description: This method will be called whenver there is fail in login flow of the Truecaller     Parameters: Nil
     Returns: Nil
     */
 public func didFailToReceiveTrueProfileWithError(_ error: TCError) {
        NSLog("Error \(error.localizedDescription)")
        switch error.getCode() {
        case TCTrueSDKErrorCode.userCancelled:
            self.displayActionSheet()
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
            break
        }
    }
    
    
    func popAlert(withString: String){
        let alert = UIAlertController(title: "Alert", message: withString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func didReceive(_ profile: TCTrueProfile) {
        NSLog("TCTrueProfile didReceive")
    }
    
    /*Description: This method will display a action sheet with alternate login modes
     Parameters: Nil
     Returns: Nil
     */
    
    func displayActionSheet(){
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Login With", message: "", preferredStyle: .actionSheet)
    let trueCaller = UIAlertAction(title: "TrueCaller", style: .default)
        { _ in
            _ = self.canWeStartTrueCaller()
        }
        actionSheetController.addAction(trueCaller)
        let enterANumber = UIAlertAction(title: "Enter a Phone Number", style: .default)
        { _ in
            self.startNativeLoginFlow()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        actionSheetController.addAction(enterANumber)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}

extension LoginViewController : NativeOTPLoginDelegate{
    func afterOTPServerCall(accessToken: String) {
        if(accessToken.count == 0){
            
            print("we start our own method here")
       //self.startFbAccountKitlogin()
        }else{
        LoginModel.sharedInstance().isAlternateLogin = true
               LoginModel.sharedInstance().isAlertnativeLoginTypeTrueCaller = true
               self.makeLoginCallToServer(withUserId: nil, withAccessToken: accessToken, withDictionary: nil, andLoginThrough: LoginViaNativeOTP)
        }
    }

}
