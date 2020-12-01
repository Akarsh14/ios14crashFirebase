//
//  CrushPurchaseFlowHandler.swift
//  Woo_v2
//
//  Created by Akhil Singh on 28/05/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class CrushPurchaseFlowHandler: NSObject {

    var crushText:String{
        didSet{
            checkIfUserNeedsToPurchaseCrush(self.crushText)
        }
    }
    
    var sendCrushViewObject:SendCrushView?
    
    var sendButtonTapped:Bool = true
    
    var templateTapped:Bool = true
    
    var rowSelectedOfTemplate:Int = -1
    
    var currentUserData :AnyObject?

    var purchaseFlowCompleteHandler:((String, Bool, Bool)->Void)?
    
    var presentedViewController:UIViewController?
    
    init(with viewController:UIViewController){
        self.crushText = ""
        self.presentedViewController = viewController
    }
    
    fileprivate func checkIfUserNeedsToPurchaseCrush(_ crush:String){
        if (!(CrushModel.sharedInstance().checkIfUserNeedsToPurchase()) && CrushModel.sharedInstance().availableCrush > 0){
        if let handler = self.purchaseFlowCompleteHandler{
            handler(crush, sendButtonTapped, templateTapped)
        }
        }
        else{
            startCrushPurchaseFlowNow(crush)
        }
    }
    
    fileprivate func startCrushPurchaseFlowNow(_ crush:String){
        //out of crushes view
        DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
        WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromSideMenu = false
        WooScreenManager.sharedInstance.oHomeViewController?.crushFunnelMessage = "Discover_crush_tap"
        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseCrush)
        WooScreenManager.sharedInstance.oHomeViewController?.dismissHandler = {(crushPurchased:Bool) in
            if CrushModel.sharedInstance().availableCrush > 0{
//                if let handler = self.purchaseFlowCompleteHandler{
//                    handler(crush, true, true)
//                }
                self.showSendCrushView(true)
            }
            else{
                if let handler = self.purchaseFlowCompleteHandler{
                    handler("", false, false)
                }
            }
        }
    }
    
    func showSendCrushView(_ crushHasBeenPurchased:Bool){
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        if sendCrushViewObject == nil {
            let mainWindow:UIWindow = ((UIApplication.shared.delegate?.window)!)!
            sendCrushViewObject = SendCrushView.init(frame: mainWindow.rootViewController!.view.frame)
        }
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        if crushHasBeenPurchased{
        sendCrushViewObject?.crushMessageTyped = crushText
        sendCrushViewObject?.wasTemplateSelected = templateTapped
        sendCrushViewObject?.isTemplateTapped = templateTapped
        sendCrushViewObject?.selectedRow = rowSelectedOfTemplate
        }
        
        sendCrushViewObject?.presentView(on: presentedViewController?.view, withTemplateQuestions: CrushModel.sharedInstance().templateQuestionArray, userName: currentUserData?.firstName, withAnimationTime: 0.25, withCompletionBlock: { (true) in
            self.sendCrushViewObject?.viewDismissed({ (crush, isSendButtonTapped, isTemplateTapped, selectedRow) in
                if self.presentedViewController is DiscoverViewController{
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                }
                if crush?.count ?? 0 > 0 && (isSendButtonTapped || isTemplateTapped){
                    if CrushModel.sharedInstance().availableCrush > 0{
                        if let handler = self.purchaseFlowCompleteHandler{
                            handler(crush ?? "", isSendButtonTapped, isTemplateTapped)
                        }
                    }
                    else{
                    self.crushText = crush ?? ""
                    self.sendButtonTapped = isSendButtonTapped
                    self.templateTapped = isTemplateTapped
                    self.rowSelectedOfTemplate = selectedRow
                    }
                }
                else{
                    if let handler = self.purchaseFlowCompleteHandler{
                        handler(crush ?? "", isSendButtonTapped, isTemplateTapped)
                    }
                }
            })
        })
    }
    
}
