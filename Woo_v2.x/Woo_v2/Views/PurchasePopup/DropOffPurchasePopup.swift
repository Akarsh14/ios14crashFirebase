//
//  DropOffPurchasePopup.swift
//  Woo_v2
//
//  Created by Ankit Batra on 24/07/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

class DropOffPurchasePopup: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var strikeThroughTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var comboTextLabel: UILabel!
    @IBOutlet weak var popupContentArea: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var purchaseImageView: UIImageView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var bottomtextLabel: UILabel!
    @IBOutlet weak var getNowButton: UIButton!
    var screenType:PurchaseType = .none
    var loader : WooLoader?
    var initiatedView:String?
    @objc var purchasedHandler:((Bool)->Void)!
    var modelObject:Any?
    var currentProduct :NSDictionary?
    
    @IBOutlet weak var strikethroughImage: UIImageView!

    @IBOutlet weak var limitedPeriodOfferIMage: UIImageView!
    override func awakeFromNib() {
        self.popupContentArea.layer.cornerRadius = 7.0
        self.popupContentArea.layer.masksToBounds = true
        //        
    }
    
    @objc func loadPopupOnWindowWith(productToBePurchased productType:PurchaseType, andProductDTO productDto:NSDictionary, andModelObj model:Any)
    {
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        self.currentProduct = productDto.object(forKey: "productDetail") as? NSDictionary
       // let parentPlanId = productDto.object(forKey: "parentPlanId") as? String ?? ""
        self.screenType = productType
        
        //Set values
        let shownTodayCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenTodayCount")
        UserDefaults.standard.set(shownTodayCount+1, forKey: "\(self.screenType.rawValue)-seenTodayCount")
        
        let seenLifetimeCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenLifetimeCount")
        UserDefaults.standard.set(seenLifetimeCount+1, forKey: "\(self.screenType.rawValue)-seenLifetimeCount")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let dateString =  dateFormatter.string(from: Date())
//        dateFormatter.dateStyle = DateFormatter.Style(rawValue: 1)!
        
        UserDefaults.standard.set(dateString, forKey: "\(self.screenType.rawValue)-lastSeenDate")
        UserDefaults.standard.synchronize()
        
        //combo pack check
        
        //islimitedperiod
        if(self.currentProduct?["showLimitedOffer"] as? Bool  ?? false == true)
        {
           limitedPeriodOfferIMage.isHidden = false
        }
        else
        {
             limitedPeriodOfferIMage.isHidden = true
        }
        
        //Get
        let topLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        let topGetLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "Get ")
        topGetLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 16.0)!,NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, topGetLabelAttributeString.length))
        
        topLabelAttributeString.append(topGetLabelAttributeString)
        // add showLimitedOffer handling
        
        
        //product 
        var bottomOfferPriceLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let bottomLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        if(self.screenType.rawValue == 3 && self.currentProduct?["isComboPlan"] as? Bool ?? false == true)
        {
            topTextLabel.isHidden = true
            bottomtextLabel.isHidden = true
            
            comboTextLabel.isHidden = false
            /*
            let topProductLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(self.currentProduct!["comboOfferText"] ?? "") \(self.currentProduct!["productName"] ?? "")")
            topProductLabelAttributeString.addAttributes([NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16.0)!,NSForegroundColorAttributeName :  UIColorHelper.color(withRGBA: "#11A93E")], range: NSMakeRange(0, topProductLabelAttributeString.length))
            
            topLabelAttributeString.append(topProductLabelAttributeString)
            
            let topforLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: " free")
            topforLabelAttributeString.addAttributes([NSFontAttributeName : UIFont(name: "Lato-Regular", size: 16.0)!,NSForegroundColorAttributeName : UIColor.black], range: NSMakeRange(0, topforLabelAttributeString.length))
            topLabelAttributeString.append(topforLabelAttributeString)
            
            topTextLabel.attributedText = topLabelAttributeString
            
            
            //
            
            let bottomParentPriceLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "with Wooplus")
            bottomParentPriceLabelAttributeString.addAttributes([NSFontAttributeName : UIFont(name: "Lato-Regular", size: 16.0)!,NSForegroundColorAttributeName : UIColorHelper.color(withRGBA: "#11A93E")], range: NSMakeRange(0, bottomParentPriceLabelAttributeString.length))

            bottomLabelAttributeString.append(bottomParentPriceLabelAttributeString)
             */
            
    
        }
        else
        {
           
            let topProductLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(self.currentProduct!["count"] ?? "") \(self.currentProduct!["productName"] ?? "")")
            topProductLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 16.0)!,NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, topProductLabelAttributeString.length))
            
            topLabelAttributeString.append(topProductLabelAttributeString)
            
            let topforLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: " for")
            topforLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 16.0)!,NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, topforLabelAttributeString.length))
            topLabelAttributeString.append(topforLabelAttributeString)
            
            topTextLabel.attributedText = topLabelAttributeString
            
            ////////
            //
            
            let productCount:Int = self.currentProduct!["count"] as! Int
            let maxPrice:String = self.currentProduct!["maxPricePerUnit"] as! String
            
            var bottomParentPriceLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(self.currentProduct!["priceUnit"] ?? "₹")\(maxPrice)")

            if AppLaunchModel.sharedInstance().disableFP == false && productType == .wooPlus{
                bottomParentPriceLabelAttributeString = NSMutableAttributedString(string: "\(self.currentProduct!["priceUnit"] ?? "₹")\(Int(maxPrice)! * productCount)")
            }
            bottomParentPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 16.0)!,NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, bottomParentPriceLabelAttributeString.length))
            
            bottomLabelAttributeString.append(bottomParentPriceLabelAttributeString)
            // add showLimitedOffer handling
            
            if AppLaunchModel.sharedInstance().disableFP == false && productType == .wooPlus{
                let price:String = self.currentProduct!["pricePerUnit"] as! String
            
                bottomOfferPriceLabelAttributeString = NSMutableAttributedString(string: "\(self.currentProduct!["priceUnit"] ?? "₹")\(Int(price)! * productCount)")
            }
            else{
             bottomOfferPriceLabelAttributeString = NSMutableAttributedString(string: "\(self.currentProduct!["priceUnit"] ?? "₹")\(self.currentProduct!["pricePerUnit"] ?? "")/\(self.currentProduct!["productNamePerUnit"] ?? "")*")
            }
            
            topTextLabel.isHidden = false
            bottomtextLabel.isHidden = false
            comboTextLabel.isHidden = true

        }
        var offerPriceStr = "\(self.currentProduct!["priceUnit"] ?? "₹")\(self.currentProduct!["pricePerUnit"] ?? "")/"
        
        if AppLaunchModel.sharedInstance().disableFP == false && productType == .wooPlus{
            strikeThroughTrailingConstraint.constant = -90
            let productCount:Int = self.currentProduct!["count"] as! Int
            let price:String = self.currentProduct!["pricePerUnit"] as! String
            offerPriceStr = "\(self.currentProduct!["priceUnit"] ?? "₹")\(Int(price)! * productCount)"
        }
        
        
        switch productType
        {
        case .boost:
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Boost_dropoff_landing")
            let boostProducts:BoostProductModel = model as! BoostProductModel
            self.backgroundImageView.backgroundColor = UIColor(red: 0.57, green: 0.46, blue: 0.86, alpha: 1.0)
            
            let baseUrlString:String = "\(boostProducts.baseImageUrl!)"
            let circleImageString: String = baseUrlString + "\(boostProducts.circleImage ?? "")"
            self.purchaseImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                self.purchaseImageView.image = image
            })

            bottomOfferPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 20.0)!,NSAttributedString.Key.foregroundColor : UIColorHelper.color(withRGBA: "#936DD1")], range:  NSMakeRange(0, offerPriceStr.count))
            bottomOfferPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 20.0)!,NSAttributedString.Key.foregroundColor :UIColorHelper.color(withRGBA: "#936DD1") ], range: NSMakeRange(offerPriceStr.count,bottomOfferPriceLabelAttributeString.length - offerPriceStr.count))

            bottomLabelAttributeString.append(bottomOfferPriceLabelAttributeString)
            
            bottomtextLabel.attributedText = bottomLabelAttributeString


            break

        case .crush:
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Crush_dropoff_landing")
            let crushProducts:CrushProductModel = model as! CrushProductModel
              self.backgroundImageView.backgroundColor = UIColor(red: 0.98, green: 0.28, blue: 0.29, alpha: 1.0)
            
            let baseUrlString:String = "\(crushProducts.baseImageUrl!)"
            let circleImageString: String = baseUrlString + "\(crushProducts.circleImage ?? "")"
            self.purchaseImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                self.purchaseImageView.image = image
            })
            bottomOfferPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 20.0)!,NSAttributedString.Key.foregroundColor : UIColorHelper.color(withRGBA: "#E7465C")], range: NSMakeRange(0, offerPriceStr.count))
            bottomOfferPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 20.0)!,NSAttributedString.Key.foregroundColor :UIColorHelper.color(withRGBA: "#E7465C") ], range: NSMakeRange(offerPriceStr.count,bottomOfferPriceLabelAttributeString.length - offerPriceStr.count))

            bottomLabelAttributeString.append(bottomOfferPriceLabelAttributeString)
            
            bottomtextLabel.attributedText = bottomLabelAttributeString


            break

        case .wooPlus:
            (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "WooPlus_dropoff_landing")
            let subscriptionProducts:WooPlusProductModel = model as! WooPlusProductModel
            self.backgroundImageView.backgroundColor =             UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
            
            let baseUrlString:String = "\(subscriptionProducts.baseImageUrl!)"
            let circleImageString: String = baseUrlString + "\(subscriptionProducts.circleImage ?? "")"
            self.purchaseImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                self.purchaseImageView.image = image
            })
            
            if(self.currentProduct?["isComboPlan"] as? Bool ?? false == true)
            {
               /* bottomOfferPriceLabelAttributeString.addAttributes([NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16.0)!,NSForegroundColorAttributeName :  UIColorHelper.color(withRGBA: "#11A93E")], range: NSMakeRange(0, bottomOfferPriceLabelAttributeString.length))
                 */
                
                if(self.currentProduct?["textLine"] as? String ?? "" != "")
                {
                    var textLine = self.currentProduct?["textLine"] as? String ?? ""
                    textLine = textLine.replacingOccurrences(of: "#", with: self.currentProduct?["comboOfferText"] as? String ?? "")
                    
                    let componentsArray = textLine.components(separatedBy: " ")
                    let indexOfCountOffered = componentsArray.firstIndex(of: self.currentProduct?["comboOfferText"] as? String ?? "")
                    let element = componentsArray[indexOfCountOffered! + 1]
                    
                    let rangeOfOfferedProductName = textLine.range(of:element)
                    
                    
                    let rangeOfofferedProduct = textLine.range(of: self.currentProduct?["comboOfferText"] as! String)
                    
                    let topProductLabelAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: textLine)
                    topProductLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 16.0)!,NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, topProductLabelAttributeString.length))
                    topProductLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 16.0)!,NSAttributedString.Key.foregroundColor :             UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)], range:textLine.nsRange(from: rangeOfofferedProduct!))
                    
                    
                    topProductLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 16.0)!,NSAttributedString.Key.foregroundColor :             UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)], range:textLine.nsRange(from: rangeOfOfferedProductName!))

                    
                    comboTextLabel.attributedText = topProductLabelAttributeString
                }
                comboTextLabel.isHidden = false
                topTextLabel.isHidden = true
                bottomtextLabel.isHidden = true
                
                strikethroughImage.isHidden = true

                
            }
            else{
                comboTextLabel.isHidden = true
                strikethroughImage.isHidden = false

            }
            break

        
        case .wooGlobe:
            let globeProducts:WooGlobalProductModel = model as! WooGlobalProductModel
            self.backgroundImageView.backgroundColor =             UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
            
            let baseUrlString:String = "\(globeProducts.baseImageUrl)"
            let circleImageString: String = baseUrlString + "\(globeProducts.circleImage ?? "")"
            self.purchaseImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                self.purchaseImageView.image = image
            })
            bottomOfferPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 20.0)!,NSAttributedString.Key.foregroundColor :UIColorHelper.color(withRGBA: "#20ADA8") ], range: NSMakeRange(0, offerPriceStr.count))
            bottomOfferPriceLabelAttributeString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 20.0)!,NSAttributedString.Key.foregroundColor :UIColorHelper.color(withRGBA: "#20ADA8") ], range: NSMakeRange(offerPriceStr.count,bottomOfferPriceLabelAttributeString.length - offerPriceStr.count))

            bottomLabelAttributeString.append(bottomOfferPriceLabelAttributeString)
            
            bottomtextLabel.attributedText = bottomLabelAttributeString


            break

        default:
            break
        }
        

        self.frame = window.frame
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            (window2.subviews.first! as UIView).addSubview(self)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                for subViewObj in (window2.subviews.last?.subviews)! {
                    if subViewObj is DropOffPurchasePopup ||  subViewObj is PurchasePopup{
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
    
    @IBAction func getNowButtonTapped(_ sender: UIButton)
    {
        //initiate purchase
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")

        self.showLoader()
                
        if let storeProduct:NSDictionary = self.currentProduct?.object(forKey: "i_store") as? NSDictionary {
            if let storeID = storeProduct.object(forKey: "storeProductId") as? String  {
                
                let setObj = NSSet(array:[storeID])
                let strCount  = self.currentProduct?["count"] as! NSNumber
                
                if let funnelString = self.initiatedView{
                    let paynowString = funnelString + "_paynow"
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                }
                
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")
                
                var product:SKProduct?
                switch self.screenType{
                case .boost:
                    product = (self.modelObject as? BoostProductModel)?.getProductToBePurchased(storeID)
                    break
                case .crush:
                    product = (self.modelObject as? CrushProductModel)?.getProductToBePurchased(storeID)
                    break
                case .wooPlus:
                    product = (self.modelObject as? WooPlusProductModel)?.getProductToBePurchased(storeID)
                    break
                case .wooGlobe:
                    product = (self.modelObject as? WooGlobalProductModel)?.getProductToBePurchased(storeId: storeID)
                    break
                default:
                    break
                }
                self.initiatePurchaseFlow(product, productSet: setObj, planID: (self.currentProduct?.object(forKey: "planId") as? String)!, productCount: strCount.stringValue)
            }

        }
    }
    
    func initiatePurchaseFlow(_ skProduct:SKProduct?, productSet:NSSet, planID:String , productCount:String) {
        
        print("🎾🎾🎾🎾 In initiate");
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
        if skProduct != nil{
            
            var prodType:InAppPRoductType
            switch  (self.screenType){
            case .none:
                prodType = InAppPRoductType.boost
                break
                
            case .boost:
                prodType = InAppPRoductType.boost
                
                break
                
            case .crush:
                prodType = InAppPRoductType.crush
                break
                
            case .wooPlus:
                prodType = InAppPRoductType.wooPlus
                break
            
            case .wooGlobe:
                prodType = InAppPRoductType.wooGlobal
                break
            }
            (InAppPurchaseManager.sharedIAPManager() as AnyObject).purchaseProduct(with: skProduct, withProductType:prodType, withPlanID:planID, andResult:{(successFlag,error, canMakePayment, serverResponse) in
                
                if (!successFlag){
                    self.removeLoader()
                    return
                    
                }
                if let funnelString = self.initiatedView{
                    let paynowString = funnelString + "_success"
                    (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                }
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "success")
                
                if(self.currentProduct?["isComboPlan"] as? Bool ?? false == true)
                {
                    let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                    
                    //                        let comboDtoDict = responseDictionary.object(forKey: "comboPurchaseDto") as? NSDictionary
                    
                    if let boostedData = responseDictionary.object(forKey: "boostDto") as? NSDictionary
                    {
                        let boostModel: BoostModel = BoostModel.sharedInstance()
                        var boostDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        boostDict["availableBoost"] = boostedData.object(forKey: "availableBoost") as! Int
                        boostDict["expiryTime"] = boostedData.object(forKey: "expiryTime") as! Int
                        boostDict["percentageCompleted"] = boostedData.object(forKey: "percentageCompleted") as! Int
                        boostDict["hasPurchased"] = true
                        boostDict["availableInRegion"] = boostModel.availableInRegion
                        boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                        boostDict["currentlyActive"] = boostModel.currentlyActive
                        boostDict["hasEverPurchased"] = true
                        BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                        
                    }
                    if let crushData = responseDictionary.object(forKey: "crushDto") as? NSDictionary
                    {
                        let crushModel: CrushModel = CrushModel.sharedInstance()
                        var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                        crushDict["expiryTime"] = crushData.object(forKey: "expiryTime") as! Int
                        crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                        crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                        crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                        crushDict["availableInRegion"] = crushModel.availableInRegion
                        crushDict["hasEverPurchased"] = true
                        CrushModel.sharedInstance().updateData(withCrush: crushDict)
                        
                    }
                    
                    
                    if let wooPlusData =  responseDictionary.object(forKey: "wooPlusDto") as? NSDictionary
                    {
                        let wooPlusModel: WooPlusModel = WooPlusModel.sharedInstance()
                        
                        var wooPlusDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        
                        wooPlusDict["expired"] = wooPlusData.object(forKey: "expired") as! Bool
                        wooPlusDict["hasEverPurchased"] = true
                        
                        if (wooPlusDict["expired"] as! Bool) != true
                        {
                            
                            wooPlusDict["subscriptionId"] = wooPlusData.object(forKey: "subscriptionId") as! String
                            wooPlusDict["availableInRegion"] = wooPlusModel.availableInRegion
                            
                        }
                        
                        WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                        }
                        
                        
                    }
                    if self.purchasedHandler != nil{
                        self.purchasedHandler(true)
                    }
                    self.removeLoader()
                    self.removeFromSuperview()
                    
                }
                else
                {
                    switch (self.screenType){
                        
                    case .boost:
                        
                        let boostModel: BoostModel = BoostModel.sharedInstance()
                        
                        var boostDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        
                        let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                        
                        let boostedData:NSDictionary = (responseDictionary.object(forKey: "boostDto") as? NSDictionary)!
                        boostDict["availableBoost"] = boostedData.object(forKey: "availableBoost") as! Int
                        boostDict["expiryTime"] = boostedData.object(forKey: "expiryTime") as! Int
                        boostDict["percentageCompleted"] = boostedData.object(forKey: "percentageCompleted") as! Int
                        boostDict["hasPurchased"] = true
                        boostDict["availableInRegion"] = boostModel.availableInRegion
                        boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                        boostDict["currentlyActive"] = boostModel.currentlyActive
                        boostDict["hasEverPurchased"] = true
                        BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                        
                        DispatchQueue.main.async {
                            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                            if self.purchasedHandler != nil{
                                self.purchasedHandler(true)
                            }
                            self.removeLoader()
                            self.removeFromSuperview()
                            
                            
                        }
                        
                        break
                        
                    case .crush:
                        
                        let crushModel: CrushModel = CrushModel.sharedInstance()
                        
                        var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        
                        let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                        
                        let crushData:NSDictionary = (responseDictionary.object(forKey: "crushDto") as? NSDictionary)!
                        crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                        crushDict["expiryTime"] = crushData.object(forKey: "expiryTime") as! Int
                        crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                        crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                        crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                        crushDict["availableInRegion"] = crushModel.availableInRegion
                        crushDict["hasEverPurchased"] = true
                        CrushModel.sharedInstance().updateData(withCrush: crushDict)
                        
                        DispatchQueue.main.async {
                            
                            if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                            }
                            
                            if self.purchasedHandler != nil{
                                self.purchasedHandler(true)
                            }
                            self.removeLoader()
                            self.removeFromSuperview()
                        }
                        break
                        
                    case .wooPlus:
                        
                        
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
                        
                        if self.purchasedHandler != nil{
                            self.purchasedHandler(true)
                        }
                        self.removeLoader()
                        self.removeFromSuperview()
                        
                        break
                        
                    case .wooGlobe:
                        
                        let wooGlobeModel: WooGlobeModel = WooGlobeModel.sharedInstance()
                        
                        let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                        
                        let wooGlobeData:NSDictionary = (responseDictionary.object(forKey: "globe") as? NSDictionary)!
                        
                        wooGlobeModel.isExpired = wooGlobeData.object(forKey: "expired") as! Bool
                        wooGlobeModel.hasEverPurchased = true
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                        }
                        
                        if self.purchasedHandler != nil{
                            self.purchasedHandler(true)
                        }
                        self.removeLoader()
                        self.removeFromSuperview()
                        
                        break
                        
                  
                        
                    case .none:
                        break
                        
                    }
                }
                
                if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == true){
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                    DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
                }
                else{
                    DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                    self.makeDiscoverCallForInternalBrandCardManagement()
                }
                
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
                
                var prodType:InAppPRoductType
                switch  (self.screenType){
                case .none:
                    prodType = InAppPRoductType.boost
                    break
                    
                case .boost:
                    prodType = InAppPRoductType.boost

                    break
                    
                case .crush:
                    prodType = InAppPRoductType.crush
                    break
                    
                case .wooPlus:
                    prodType = InAppPRoductType.wooPlus
                    break
                    
                   
                case .wooGlobe:
                    prodType = InAppPRoductType.wooGlobal
                    break
                }
                (InAppPurchaseManager.sharedIAPManager() as AnyObject).purchaseProduct(with: (prods.firstObject as! SKProduct), withProductType:prodType, withPlanID:planID, andResult:{(successFlag,error, canMakePayment, serverResponse) in
                    
                    if (!successFlag){
                        self.removeLoader()
                        return
                        
                    }
                    if let funnelString = self.initiatedView{
                        let paynowString = funnelString + "_success"
                        (Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                    }
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "success")
                    
                    if(self.currentProduct?["isComboPlan"] as? Bool ?? false == true)
                    {
                        let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                        
//                        let comboDtoDict = responseDictionary.object(forKey: "comboPurchaseDto") as? NSDictionary
                        
                        if let boostedData = responseDictionary.object(forKey: "boostDto") as? NSDictionary
                        {
                            let boostModel: BoostModel = BoostModel.sharedInstance()
                            var boostDict: [AnyHashable: Any] = [AnyHashable: Any]()
                            boostDict["availableBoost"] = boostedData.object(forKey: "availableBoost") as! Int
                            boostDict["expiryTime"] = boostedData.object(forKey: "expiryTime") as! Int
                            boostDict["percentageCompleted"] = boostedData.object(forKey: "percentageCompleted") as! Int
                            boostDict["hasPurchased"] = true
                            boostDict["availableInRegion"] = boostModel.availableInRegion
                            boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                            boostDict["currentlyActive"] = boostModel.currentlyActive
                            boostDict["hasEverPurchased"] = true
                            BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                            
                        }
                        if let crushData = responseDictionary.object(forKey: "crushDto") as? NSDictionary
                        {
                            let crushModel: CrushModel = CrushModel.sharedInstance()
                            var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                            crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                            crushDict["expiryTime"] = crushData.object(forKey: "expiryTime") as! Int
                            crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                            crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                            crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                            crushDict["availableInRegion"] = crushModel.availableInRegion
                            crushDict["hasEverPurchased"] = true
                            CrushModel.sharedInstance().updateData(withCrush: crushDict)
                            
                        }
                        
                        
                        if let wooPlusData =  responseDictionary.object(forKey: "wooPlusDto") as? NSDictionary
                        {
                            let wooPlusModel: WooPlusModel = WooPlusModel.sharedInstance()
                            
                            var wooPlusDict: [AnyHashable: Any] = [AnyHashable: Any]()
                            
                            wooPlusDict["expired"] = wooPlusData.object(forKey: "expired") as! Bool
                            wooPlusDict["hasEverPurchased"] = true

                            if (wooPlusDict["expired"] as! Bool) != true
                            {
                                
                                wooPlusDict["subscriptionId"] = wooPlusData.object(forKey: "subscriptionId") as! String
                                wooPlusDict["availableInRegion"] = wooPlusModel.availableInRegion
                                
                            }
                            
                            WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                            
                            if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                            }
                            
                            
                        }
                        if self.purchasedHandler != nil{
                            self.purchasedHandler(true)
                        }
                        self.removeLoader()
                        self.removeFromSuperview()

                    }
                    else
                    {
                        switch (self.screenType){
                            
                        case .boost:
                            
                            let boostModel: BoostModel = BoostModel.sharedInstance()
                            
                            var boostDict: [AnyHashable: Any] = [AnyHashable: Any]()
                            
                            let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                            
                            let boostedData:NSDictionary = (responseDictionary.object(forKey: "boostDto") as? NSDictionary)!
                            boostDict["availableBoost"] = boostedData.object(forKey: "availableBoost") as! Int
                            boostDict["expiryTime"] = boostedData.object(forKey: "expiryTime") as! Int
                            boostDict["percentageCompleted"] = boostedData.object(forKey: "percentageCompleted") as! Int
                            boostDict["hasPurchased"] = true
                            boostDict["availableInRegion"] = boostModel.availableInRegion
                            boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                            boostDict["currentlyActive"] = boostModel.currentlyActive
                            boostDict["hasEverPurchased"] = true
                            BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)

                            DispatchQueue.main.async {
                                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                                if self.purchasedHandler != nil{
                                    self.purchasedHandler(true)
                                }
                                self.removeLoader()
                                self.removeFromSuperview()
                                

                            }
                            
                            break
                            
                        case .crush:
                            
                            let crushModel: CrushModel = CrushModel.sharedInstance()
                            
                            var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                            
                            let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                            
                            let crushData:NSDictionary = (responseDictionary.object(forKey: "crushDto") as? NSDictionary)!
                            crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                            crushDict["expiryTime"] = crushData.object(forKey: "expiryTime") as! Int
                            crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                            crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                            crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                            crushDict["availableInRegion"] = crushModel.availableInRegion
                            crushDict["hasEverPurchased"] = true
                            CrushModel.sharedInstance().updateData(withCrush: crushDict)
                            
                            DispatchQueue.main.async {

                            if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                            }
                            
                            if self.purchasedHandler != nil{
                                self.purchasedHandler(true)
                            }
                            self.removeLoader()
                            self.removeFromSuperview()
                            }
                            break
                            
                        case .wooPlus:
                            
                            
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
                            
                            if self.purchasedHandler != nil{
                                self.purchasedHandler(true)
                            }
                            self.removeLoader()
                            self.removeFromSuperview()
                            
                            break
                            
                        case .wooGlobe:
                            
                            let wooGlobeModel: WooGlobeModel = WooGlobeModel.sharedInstance()
                            
                            let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                            
                            let wooGlobeData:NSDictionary = (responseDictionary.object(forKey: "globe") as? NSDictionary)!
                            
                            wooGlobeModel.isExpired = wooGlobeData.object(forKey: "expired") as! Bool
                            wooGlobeModel.hasEverPurchased = true
                            
                            if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                            }
                            
                            if self.purchasedHandler != nil{
                                self.purchasedHandler(true)
                            }
                            self.removeLoader()
                            self.removeFromSuperview()
                            
                            break
                            
                        case .none:
                            break
                     
                        }
                    }
                    
                    if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == true){
                        DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = true
                    }
                    else{
                        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                        self.makeDiscoverCallForInternalBrandCardManagement()
                    }
                    
                    if WooScreenManager.sharedInstance.oSideDrawerViewController != nil{
                        WooScreenManager.sharedInstance.oSideDrawerViewController?.prepareFooterData()
                    }
                    
                })
                
            } // if success ends here
            
        })
        }
    }

    func makeDiscoverCallForInternalBrandCardManagement(){
        if DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged == true {
            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
            DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
            DiscoverProfileCollection.sharedInstance.paginationToken = ""
            DiscoverProfileCollection.sharedInstance.paginationIndex = ""
            //            if DiscoverProfileCollection.sharedInstance.collectionMode != .MY_PROFILE {
            //               // WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            //            }
            //
            //            DiscoverAPIClass.fetchDiscoverDataFromServer(false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
            //                if success{
            //                }
            //            })
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
    
    @IBAction func backgroundButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
    }
}

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
        
    }
}
