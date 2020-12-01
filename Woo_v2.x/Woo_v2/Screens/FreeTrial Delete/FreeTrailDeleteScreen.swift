//
//  FreeTrailDeleteScreen.swift
//  Woo_v2
//
//  Created by Harish kuramsetty on 19/08/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class FreeTrailDeleteScreen: UIView {
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblMainPriceTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnCloseRight: NSLayoutConstraint!
    @IBOutlet weak var btnDeleteBottom: NSLayoutConstraint!
    @IBOutlet weak var btnWooPlus: UIButton!
    @IBOutlet weak var topView: UIView!
    
    var dropOffProductDTOsToBeShown :[NSDictionary] = []
    var productsArray:NSArray = []
    var initiatedView:String?
    var timer = Timer()
    var selectedIndex:Int = 0
    var modelObject:Any?
    // var screenType:PurchaseType = .freeTrial
    var comboProductsDto : WooGlobalProductModel?
    var loader : WooLoader?
    @objc var purchasedHandlerFreeTrail:((Bool)->Void)!
    @objc var purchasedHandlerFreeTrailDeleteHandler:((Bool)->Void)!
    
    
    
    @IBAction func btnDeleteBottom(_ sender: Any) {
        
        if(purchasedHandlerFreeTrailDeleteHandler != nil)
        {
            purchasedHandlerFreeTrailDeleteHandler(true)
            
            
        }
        
        self.removeFromSuperview()
        
    }
    
    
    @objc func showClose(){
        timer.invalidate()
        btnClose.isHidden = false
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if(btnClose.isHidden == false){
            self.removeFromSuperview()
            
        }    }
    
    
    @objc func loadPopupOnWindowForFreeTrail(){
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        lblMainPriceTitle.text = "\(FreeTrailModel.sharedInstance().noOfDays) Days FREE WooPlus"
        lblPrice.text = "(\(FreeTrailModel.sharedInstance().priceUnit)\(FreeTrailModel.sharedInstance().price)/- pm after trial. Cancel anytime)"
        btnClose.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.showClose), userInfo: nil, repeats: true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      //  topView.addGestureRecognizer(tap)
        btnWooPlus.layer.masksToBounds = false
        btnWooPlus.layer.shadowRadius = 2
        btnWooPlus.layer.shadowOpacity = 0.7
        btnWooPlus.layer.shadowColor = UIColor.gray.cgColor
        btnWooPlus.layer.shadowOffset = CGSize(width:0, height:2)
        if(UIScreen.main.bounds.size.width <= 320 ){
            btnDeleteBottom.constant = 30
            btnCloseRight.constant = 15
        }
        dropOffProductDTOsToBeShown.removeAll()
        if let wooPlusProducts:WooPlusProductModel = PurchaseProductDetailModel.sharedInstance().wooPlusModel{
            modelObject = wooPlusProducts as WooPlusProductModel
            
            if wooPlusProducts.wooProductDto != nil{
                self.productsArray = wooPlusProducts.wooProductDto as NSArray
            }
            
        }
        self.frame = window.frame
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            (window2.subviews.first! as UIView).addSubview(self)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                for subViewObj in (window2.subviews.first?.subviews)! {
                    if subViewObj is FreeTrailUnlock {
                        print("pop up aphle se hi hai")
                        subViewObj.removeFromSuperview()
                    }
                }
                (window2.subviews.last! as UIView).addSubview(self)
            }
            else{
                (window.subviews.first! as UIView).addSubview(self)
            }
        }
    }
    
    
    @IBAction func btnGetWooPlus(_ sender: Any) {
        onPayButtonCliciked()
    }
    
    override func awakeFromNib() {
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
    
    func onPayButtonCliciked(){
        let storeID = FreeTrailModel.sharedInstance().storeProductId
        let setObj = NSSet(array:[storeID])
        let strCount  = 0
        
        if let funnelString = self.initiatedView{
            let paynowString = funnelString + "_paynow"
            //(Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
        }
        
        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")
        self.showLoader()
        var product:SKProduct?
        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")
        
        product = (self.modelObject as! WooPlusProductModel).getProductToBePurchased(storeID)
        
        self.initiatePurchaseFlow(product, productSet: setObj, planID:FreeTrailModel.sharedInstance().planId, productCount: "0")
    }
    
    
    func initiatePurchaseFlow(_ skProduct:SKProduct?, productSet:NSSet, planID:String , productCount:String) {
        
        print("🎾🎾🎾🎾 In initiate");
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
        if skProduct != nil{
            
            
            (InAppPurchaseManager.sharedIAPManager() as AnyObject).purchaseProduct(with: skProduct, withProductType:InAppPRoductType.freeTrail, withPlanID:planID, andResult:{(successFlag,error, canMakePayment, serverResponse) in
                
                if (!successFlag){
                    self.removeLoader()
                    return
                    
                }
                if let funnelString = self.initiatedView{
                    let paynowString = funnelString + "_success"
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                }
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "success")
                
                let wooPlusModel: WooPlusModel = WooPlusModel.sharedInstance()
                
                var wooPlusDict: [AnyHashable: Any] = [AnyHashable: Any]()
                
                let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                
                let wooPlusData:NSDictionary = (responseDictionary.object(forKey: "subscription") as? NSDictionary)!
                
                print(wooPlusData)
                print(wooPlusDict)
                
                wooPlusDict["expired"] = wooPlusData.object(forKey: "expired") as! Bool
                wooPlusDict["hasEverPurchased"] = true
                
                if (wooPlusDict["expired"] as! Bool) != true {
                    
                    wooPlusDict["subscriptionId"] = wooPlusData.object(forKey: "subscriptionId") as! String
                    wooPlusDict["availableInRegion"] = wooPlusModel.availableInRegion
                    
                }
                
                WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                
                if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                }
                
                if self.purchasedHandlerFreeTrail != nil{
                    self.purchasedHandlerFreeTrail(true)
                }
                self.removeLoader()
                self.removeFromSuperview()
                
                
                
                if WooScreenManager.sharedInstance.oSideDrawerViewController != nil{
                    WooScreenManager.sharedInstance.oSideDrawerViewController?.prepareFooterData()
                }
                
            })
            
        }
        else{
            
            (InAppPurchaseManager.sharedIAPManager() as AnyObject).getAllProductsFromApple(withProductIdentifiers: productSet as Set<NSObject>,withProductCount:productCount, withCallback: { (successFlag, canMakePurchase, productsFromServer) in
                
                if (successFlag == false){
                    self.removeLoader()
                    let snackBarObj: MDSnackbar = MDSnackbar(text:NSLocalizedString("We are facing some issue connecting store. Please try after some time.", comment: "We are facing some issue connecting store. Please try after some time.") , actionTitle: "", duration: 2.0)
                    snackBarObj.multiline = true
                    snackBarObj.show()
                    
                }
                if (successFlag == true) && (canMakePurchase == true){
                    
                    let prods:NSArray = productsFromServer! as NSArray
                    
                    
                    (InAppPurchaseManager.sharedIAPManager() as AnyObject).purchaseProduct(with: (prods.firstObject as! SKProduct), withProductType:InAppPRoductType.freeTrail, withPlanID:planID, andResult:{(successFlag,error, canMakePayment, serverResponse) in
                        
                        if (!successFlag){
                            self.removeLoader()
                            let snackBarObj: MDSnackbar = MDSnackbar(text:NSLocalizedString("We are facing some issue connecting store. Please try after some time.", comment: "We are facing some issue connecting store. Please try after some time.") , actionTitle: "", duration: 2.0)
                            snackBarObj.multiline = true
                            snackBarObj.show()
                            return
                            
                        }
                        if let funnelString = self.initiatedView{
                            let paynowString = funnelString + "_success"
                            (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                        }
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "success")
                        
                        let wooPlusModel: WooPlusModel = WooPlusModel.sharedInstance()
                        
                        var wooPlusDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        
                        let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                        
                        let wooPlusData:NSDictionary = (responseDictionary.object(forKey: "wooPlusDto") as? NSDictionary)!
                        
                        print(wooPlusData)
                        print(wooPlusDict)
                        
                        wooPlusDict["expired"] = wooPlusData.object(forKey: "expired") as! Bool
                        wooPlusDict["hasEverPurchased"] = true
                        
                        if (wooPlusDict["expired"] as! Bool) != true {
                            
                            wooPlusDict["subscriptionId"] = wooPlusData.object(forKey: "subscriptionId") as! String
                            wooPlusDict["availableInRegion"] = wooPlusModel.availableInRegion
                            
                        }
                        
                        WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                        }
                        
                        if self.purchasedHandlerFreeTrail != nil{
                            self.purchasedHandlerFreeTrail(true)
                        }
                        self.removeLoader()
                        self.removeFromSuperview()
                        
                        
                        
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == true){
                            DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
                        }
                        else{
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                            // self.makeDiscoverCallForInternalBrandCardManagement()
                        }
                        
                        if WooScreenManager.sharedInstance.oSideDrawerViewController != nil{
                            WooScreenManager.sharedInstance.oSideDrawerViewController?.prepareFooterData()
                        }
                        
                    })
                    
                } // if success ends here
                
            })
        }
    }
    
    
    func appendtoDropOffArray(forProductWithDetail product:NSDictionary, andParentPricePerUnit pricePerUnit:String, andParentPlanId planProductId:String)
    {
        
        if(!WooPlusModel.sharedInstance().hasEverPurchased || WooPlusModel.sharedInstance().hasEverPurchased == false )
        {
            self.dropOffProductDTOsToBeShown.append(["productDetail":product,"parentPricePerUnit":pricePerUnit, "parentPlanId":planProductId])
            
            
        }
    }
    
    func increaseCancellationCounter()
    {
    }
    
    
    func moveToMe()
    {
        if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 0)
        {
            let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
            NSLog("openMeSection popToRootViewController")
            currentNavigation.popToRootViewController(animated: true)
            
            if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 1)
            {
                //DISCOVER TAB
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
                //DISCOVER TAB
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                let discoverVc = currentNavigation.viewControllers.first as! DiscoverViewController
                discoverVc.makeProfileDeckSmall()
                discoverVc.myProfileBackButtonPressed(UIButton())
            }
            else
            {
                NSLog("openMeSection moveToTab 0")
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
        }
        else
        {
            //            let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.childViewControllers[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
            //            currentNavigation.popToRootViewController(animated: true)
        }
    }
    
    func moveTodiscover()
    {
        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
        
        if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 0 || (currentNavigation.viewControllers.last is MyPurchaseViewController) == true)
            
        {
            if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() == 1)
            {
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
                let discoverVc = currentNavigation.viewControllers.first as! DiscoverViewController
                discoverVc.didTabViewChanged((0, newValue: 1))
            }
            else
            {
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.discover)
                DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            }
            
        }
    }
    
    func showLoader(){
        if loader == nil {
            loader  = WooLoader.init(frame: self.frame)
            loader?.customLoadingText("")
        }
        
        loader?.startAnimation(on: self, withBackGround: false)
    }
    
    func removeLoader(){
        if (loader != nil){
            loader?.removeFromSuperview()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
