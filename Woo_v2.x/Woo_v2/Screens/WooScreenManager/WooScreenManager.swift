//
//  WooScreenManager.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import MMDrawerController

@objc class WooScreenManager: NSObject, UINavigationControllerDelegate {
    
    @objc static let sharedInstance = WooScreenManager()
    
    var navController : UINavigationController?

    @objc var drawerController : MMDrawerController?
    
    var loginController : LoginViewController?
    
    @objc var oHomeViewController : HomeViewController?
    
    var oSideDrawerViewController : SideDrawerViewController?
    
    var drawerRoundRobinCounter = 0
    
    var autoLoginShouldNotHappen = false

    var uploadImageisStillProcessing = false
    
    @objc var isDrawerOpen = false
    
    var presentationCompletion : ((Bool) -> (Void))?
    
    fileprivate override init() {
        
        var appDelegate : UIApplicationDelegate?
        if let localAppDelegate = UIApplication.shared.delegate {
             appDelegate = localAppDelegate
        }
        
        var window : UIWindow?
        if let localWindow = appDelegate?.window {
            window = localWindow
            if let localNavController = window?.rootViewController {
                navController = localNavController as? UINavigationController
                
                print("onboardingPassed",LoginModel.sharedInstance()?.wooUserId ?? 0)
                
                if LoginModel.sharedInstance().onboardingPassed {
                    
                    if let  id = UserDefaults.standard.object(forKey: "id") {
                        let wooid:NSString = id as! NSString
                        
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                    }
                    
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    drawerController = storyboard.instantiateViewController(withIdentifier: "MMDrawerController") as? MMDrawerController
                    drawerController?.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionMode.full
                    navController?.pushViewController(drawerController!, animated: false)
                    NSLog("Root was set to  dreawer)")

                }
                else {
                    let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
                    loginController = storyboard.instantiateViewController(withIdentifier: "LoginViewControllerID") as? LoginViewController
                    print("navigation controllers \(navController!.viewControllers)")
                    navController = UINavigationController.init(rootViewController: loginController!)
                    window?.rootViewController = navController
                    print("navigation controllers \(navController!.viewControllers)")
                }
            }
            NSLog("Root was set to \(String(describing: window?.rootViewController))")
        }
    }
    
/**
 * Configures the very base container for left drawer
 */
    func configureDrawerController(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        oHomeViewController =
            storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        oSideDrawerViewController = storyboard.instantiateViewController(withIdentifier: "SideDrawerViewController") as? SideDrawerViewController
        
        if drawerController != nil {
            drawerController!.centerViewController = oHomeViewController;
//            drawerController!.rightDrawerViewController = oSideDrawerViewController;
        }
        
        drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningNavigationBar
        
        drawerController?.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionMode.full
        
        drawerController!.maximumRightDrawerWidth = (UIScreen.main.bounds.size.width*0.843)
        
        drawerController?.showsShadow = false
        
        drawerController?.setGestureShouldRecognizeTouch({ (draweController, gestureRecognizer, touch) -> Bool in
            
            if (gestureRecognizer?.isKind(of: UITabBarItem.classForCoder()))!{
                return true
            }
            else{
                return false
            }
        })
    }
    
    func openDrawerSlider(){
        if !isDrawerOpen {
            drawerController!.rightDrawerViewController = oSideDrawerViewController
            drawerController?.open(MMDrawerSide.right, animated: true, completion: nil)
            isDrawerOpen = true
        }
        else{
            self.isDrawerOpen = false
            drawerController?.closeDrawer(animated: true, completion: { (isAnimated) in
                self.drawerController!.rightDrawerViewController = nil
            })
        }
    }
    
    @objc func loadDrawerView() {
        
        if DiscoverProfileCollection.sharedInstance.intentModelObject?.interestedGender
            != "UNKNOWN"{
        let wooId : String = (UserDefaults.standard.object(forKey: "id") as? String)!
        ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooId)!, withCompletionBlock: nil)
        }
        
        var appDelegate : UIApplicationDelegate?
        if let localAppDelegate = UIApplication.shared.delegate {
            appDelegate = localAppDelegate
        }
        
        var window : UIWindow?
        if let localWindow = appDelegate?.window {
            window = localWindow
            if let localNavController = window?.rootViewController {
                navController = localNavController as? UINavigationController
                navController?.delegate = self
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                drawerController = storyboard.instantiateViewController(withIdentifier: "MMDrawerController") as? MMDrawerController
                print("navigation controllers \(navController!.viewControllers)")
                navController?.popToRootViewController(animated: false)
                navController?.viewControllers.removeAll()
                navController?.pushViewController(drawerController!, animated: false)
                self.configureDrawerController()
            }
        }
        
        if LoginModel.sharedInstance().gender == "FEMALE"{
        if UserDefaults.standard.bool(forKey: "tutorialNotShown"){
            WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.FemaleTutorial)
            UserDefaults.standard.set(false, forKey: "tutorialNotShown")
            UserDefaults.standard.synchronize()
        }
        }
    }
    
    func loadLoginView() {
        var appDelegate : UIApplicationDelegate?
        if let localAppDelegate = UIApplication.shared.delegate {
            appDelegate = localAppDelegate
        }
        var window : UIWindow?
        if let localWindow = appDelegate?.window {
            window = localWindow
            if let localNavController = window?.rootViewController {
                navController = localNavController as? UINavigationController
//                navController?.delegate = self
                let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
                var isLoginViewControllerPresent = false
                for viewController in navController!.viewControllers {
                    if viewController.isKind(of: LoginViewController.self) {
                        isLoginViewControllerPresent = true
                    }
                }
                 print("navigation controllers \(navController!.viewControllers)")
                loginController = storyboard.instantiateViewController(withIdentifier: "LoginViewControllerID") as? LoginViewController
                navController = UINavigationController.init(rootViewController: loginController!)
                 print("navigation controllers \(navController!.viewControllers)")
                window?.rootViewController = navController
                
                print("navigation controllers \(navController!.viewControllers)")
//                 navController?.popToRootViewControllerAnimated(false)
//                if isLoginViewControllerPresent == false {
//                    
//                    print("loginController \(loginController)")
//                    print("navigation controllers \(navController!.viewControllers)")
//                   
//                    print("navigation controllers \(navController!.viewControllers)")
//                    navController?.pushViewController(loginController!, animated: false)
//                }
                
                
                print("navigation controllers \(navController!.viewControllers)")
            }
        }
    }
    
   @objc func hideHomeViewTabBar(_ isTrue : Bool, isAnimated : Bool) {
        if !isTrue {
            oHomeViewController?.showTabBar(isAnimated)
//            oHomeViewController?.hidesBottomBarWhenPushed = true
        }
        else{
            oHomeViewController?.hideTabBar(isAnimated)
            oHomeViewController?.hidesBottomBarWhenPushed = true
        }
    }
    
    
    func refreshTheEditProfileScrceen(updateDictionary : NSArray, responseDictionary : NSDictionary){
        print("wooscreen main", updateDictionary)
        
        UserDefaults.standard.set(updateDictionary, forKey: "croppedImagesArrayForPhotoGalleryTableViewCell")
        UserDefaults.standard.synchronize()
        
        let profileDataDict:[String: Any] = ["myProfile": responseDictionary];
        NotificationCenter.default.post(name: Notification.Name("refreshView"), object: nil, userInfo: profileDataDict)
    }
    
    
    func openDeepLinkedScreen(_ urlStr : String) {
        if urlStr.contains("wooapp://") {

        //    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)

            let deepLinkKey = urlStr.replacingOccurrences(of: "wooapp://", with: "")

            NSLog("HomeViewController \(oHomeViewController!)")
            let isModalPresent = oHomeViewController?.isModalPresent()
            
            if deepLinkKey.count > 0 {
                let arr:[String?] = deepLinkKey.components(separatedBy: "?")
            if (isModalPresent == true)
            {
//                oHomeViewController?.dismiss(animated: false, completion:
//                    {
                        if arr.count < 2 {
                            if let option = DeepLinkingOptions(rawValue: deepLinkKey) {
                                self.oHomeViewController?.presentViewController(option)
                            }
                        }
//                    })
            }
            else
            {
                    let optionValue = (arr[0]!).replacingOccurrences(of: "/link", with: "")
                    if let option = DeepLinkingOptions(rawValue: optionValue) {
                        if arr.count < 2 {
                            oHomeViewController?.presentViewController(option)
                        }
                        else{
                            oHomeViewController?.presentViewController(option, parameter: arr[1]!)
                        }
                    }
            }
            
        }
      }
    }
    
    @objc func openIncomingCallScreen(ForCallFromUserWithId uid: UInt, withMatchDetail matchDetail:MyMatches, andChannelId channelId:String, withPresentationCompletion presentationCompletion:@escaping ((Bool) -> (Void)))
    {
        
        print("openIncomingCallScreen me ghusa hai")
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let voiceCallingViewController = storyboard.instantiateViewController(withIdentifier: "VoiceCallingViewController") as! VoiceCallingViewController
        
        print("openIncomingCallScreen matchDetail %@",matchDetail)
        voiceCallingViewController.matchDetail = matchDetail
        voiceCallingViewController.currentChannelId = channelId
        voiceCallingViewController.currentCallState = .incoming
        voiceCallingViewController.matcheduserUid = uid
        let isModalPresent = oHomeViewController?.isModalPresent()
        
        if (isModalPresent == true)
        {
            oHomeViewController?.dismiss(animated: false, completion:
                {
                    self.oHomeViewController?.modalPresentationStyle = .currentContext
                    self.oHomeViewController?.present(voiceCallingViewController, animated: true, completion: {
                        presentationCompletion(true)
                })
            })
        }
        else
        {
            self.oHomeViewController?.modalPresentationStyle = .overCurrentContext
                self.oHomeViewController?.present(voiceCallingViewController, animated: true, completion: {
                        presentationCompletion(true)
                    
                })
            
        }
    }
    
    internal func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        return PushAnimator.init()
    }
}

open class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.5
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        let toViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        transitionContext.containerView.addSubview(toViewController.view)
        
        toViewController.view.alpha = 0.0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { 
            toViewController.view.alpha = 1.0
        }) 
    }
}
