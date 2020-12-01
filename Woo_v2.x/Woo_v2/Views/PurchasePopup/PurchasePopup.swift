//
//  PurchasePopup.swift
//  Woo_v2
//
//  Created by Vaibhav Gautam on 06/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

@objc enum PurchaseType: Int {
    case none = 0
    case boost = 1
    case crush = 2
    case wooPlus = 3
    case wooGlobe = 4
}

enum PurchasePopupType: Int {
    case purchase = 0
    case paymentoption = 1
}

class PurchasePopup: UIView, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var subscriptionTextView: UITextView!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var scrollableContainerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var popupContentArea: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var purchaseTableView: UITableView!
    @IBOutlet weak var carouselArea: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    //
    @IBOutlet weak var circleImagetoCarouselHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carousalBottomToBgBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var circleImageToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleImageToBottomContraint: NSLayoutConstraint!
    //
    var scrollableView:PurchasePopupScrollableView?
    var screenType:PurchaseType = .none
    var purchaseScreenType:PurchasePopupType = .purchase
    
    var isScreenWithLargeCell:Bool = false
    
    var selectedIndex:Int = 0
    
    var scrollableIndex:Int = 1
    
    var modelObject:Any?
    var productsArray:NSArray = []
    var comboProductsDto : WooGlobalProductModel?
    
    var initiatedView:String?
    
    var loader : WooLoader?
    
    @objc var purchasedHandler:((Bool)->Void)!
    @objc var popupDismissedHandler:(()->Void)!
    @objc var purchaseDismissedHandler:((PurchaseType,NSDictionary,Any)->Void)!
    
    var purchaseShownOnViewController:UIViewController?
    
    var isToShowMostPopular:Bool = false
    
    var dropOffProductDTOsToBeShown :[NSDictionary] = []
    @objc func loadPopupOnWindowWith(productToBePurchased:PurchaseType){
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        dropOffProductDTOsToBeShown.removeAll()
        
        self.screenType = productToBePurchased
        switch self.screenType {
        case .boost:
            subscriptionView.isHidden = true
            BoostProductsAPICalss.makePopupEventAPIwithType("BOOST")
            
            headerLabel.text = NSLocalizedString("Boost Yourself", comment: "boost purchase header")
            
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.57, green: 0.46, blue: 0.86, alpha: 1.0)
            self.backgroundImageView.backgroundColor = UIColor(red: 0.57, green: 0.46, blue: 0.86, alpha: 1.0)
            if let boostProducts = PurchaseProductDetailModel.sharedInstance().boostModel
            {
                modelObject = boostProducts as BoostProductModel
                if(boostProducts.isToShowMostPopular != nil)
                {
                    isToShowMostPopular = boostProducts.isToShowMostPopular.boolValue
                }
                if boostProducts.wooProductDto != nil{
                    self.productsArray = boostProducts.wooProductDto as NSArray
                }
                let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
                let ratioMultiplier : CGFloat = (window.rootViewController?.view.bounds.size.width)!/320.0
                //if combo visible or number of packs > 3
                if (boostProducts.comboDto != nil && boostProducts.comboDto.wooProductDto != nil && WooPlusModel.sharedInstance().hasEverPurchased == false && WooPlusModel.sharedInstance().isExpired == true)
                {
                    self.comboProductsDto = boostProducts.comboDto as WooGlobalProductModel
                    carousalBottomToBgBottomConstraint.constant = 51
                    circleImageToTopConstraint.constant = 7 * ratioMultiplier
                    circleImageToBottomContraint.constant = 6 * ratioMultiplier
                    circleImagetoCarouselHeightConstraint.constant = 0
                    heightConstraint.constant = SCREEN_WIDTH * 1.4062
                    
                }
                else
                {
                    circleImagetoCarouselHeightConstraint.constant = 10
                    carousalBottomToBgBottomConstraint.constant = 61
                    circleImageToTopConstraint.constant = 7 * ratioMultiplier
                    circleImageToBottomContraint.constant = 6 * ratioMultiplier
                    if(self.productsArray.count > 3)
                    {
                        heightConstraint.constant = SCREEN_WIDTH * 1.4062
                        
                    }
                    else
                    {
                        heightConstraint.constant = SCREEN_WIDTH * 1.30
                    }
                }
                
                if boostProducts.carousalType == "IMAGE" {
                    self.backgroundImageView.image = nil
                    self.circleImageView.image = nil
                }
                else{
                    let baseUrlString:String = "\(boostProducts.baseImageUrl!)"
                    if(boostProducts.backGroundImages.count > 0)
                    {
                        let backGroundImageString: String = baseUrlString + "\(boostProducts.backGroundImages.first!)"
                        self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                            self.backgroundImageView.image = image
                        })
                    }
                    if boostProducts.carousalType == "TEXT" {
                        self.circleImageView.image = nil
                    }
                    else{
                        let circleImageString: String = baseUrlString + "\(boostProducts.circleImage!)"
                        self.circleImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                            self.circleImageView.image = image
                        })
                    }
                }
            }
            break
        case .crush:
            
            subscriptionView.isHidden = true
            BoostProductsAPICalss.makePopupEventAPIwithType("CRUSH")
            
            headerLabel.text = NSLocalizedString("Get Crushes", comment: "crush purchase header")
            
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.98, green: 0.28, blue: 0.29, alpha: 1.0)
            self.backgroundImageView.backgroundColor = UIColor(red: 0.98, green: 0.28, blue: 0.29, alpha: 1.0)
            
            if let crushProducts:CrushProductModel = PurchaseProductDetailModel.sharedInstance().crushModel{
                modelObject = crushProducts as CrushProductModel
                
                if(crushProducts.isToShowMostPopular != nil)
                {
                    isToShowMostPopular = crushProducts.isToShowMostPopular.boolValue
                }
                if crushProducts.wooProductDto != nil{
                    self.productsArray = crushProducts.wooProductDto as NSArray
                }
                
                if (crushProducts.comboDto != nil && crushProducts.comboDto.wooProductDto != nil && WooPlusModel.sharedInstance().hasEverPurchased == false && WooPlusModel.sharedInstance().isExpired == true)
                {
                    self.comboProductsDto = crushProducts.comboDto as WooGlobalProductModel
                    carousalBottomToBgBottomConstraint.constant = 51
                    circleImageToTopConstraint.constant = 7
                    circleImageToBottomContraint.constant = 6
                    circleImagetoCarouselHeightConstraint.constant = 0
                    heightConstraint.constant = SCREEN_WIDTH * 1.4062
                    
                    
                }
                else
                {
                    carousalBottomToBgBottomConstraint.constant = 61
                    circleImageToTopConstraint.constant = 7
                    circleImageToBottomContraint.constant = 6
                    circleImagetoCarouselHeightConstraint.constant = 10
                    if(self.productsArray.count > 3)
                    {
                        heightConstraint.constant = SCREEN_WIDTH * 1.4062
                        
                    }
                    else
                    {
                        heightConstraint.constant = SCREEN_WIDTH * 1.30
                    }
                }
                
                if crushProducts.carousalType == "IMAGE" {
                    self.backgroundImageView.image = nil
                    self.circleImageView.image = nil
                }
                else{
                    let baseUrlString:String = "\(crushProducts.baseImageUrl!)"
                    if(crushProducts.backGroundImages.count > 0)
                    {
                        let backGroundImageString: String = baseUrlString + "\(crushProducts.backGroundImages.first!)"
                        self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                            self.backgroundImageView.image = image
                        })
                    }
                    if crushProducts.carousalType == "TEXT" {
                        self.circleImageView.image = nil
                    }
                    else{
                        let circleImageString: String = baseUrlString + "\(crushProducts.circleImage!)"
                        self.circleImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                            self.circleImageView.image = image
                        })
                    }
                }
            }
            break
        case .wooPlus:
            
            subscriptionView.isHidden = false
            BoostProductsAPICalss.makePopupEventAPIwithType("WOOPLUS")
            
            headerLabel.text = NSLocalizedString("WooPlus", comment: "woo plus purchase header")
            
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
            self.backgroundImageView.backgroundColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
            
            if let wooPlusProducts:WooPlusProductModel = PurchaseProductDetailModel.sharedInstance().wooPlusModel{
                modelObject = wooPlusProducts as WooPlusProductModel
                if(wooPlusProducts.isToShowMostPopular != nil)
                {
                    isToShowMostPopular = wooPlusProducts.isToShowMostPopular.boolValue
                }
                if wooPlusProducts.wooProductDto != nil{
                    self.productsArray = wooPlusProducts.wooProductDto as NSArray
                }
                
                if wooPlusProducts.carousalType == "IMAGE" {
                    self.backgroundImageView.image = nil
                    self.circleImageView.image = nil
                }
                else{
                    let baseUrlString:String = "\(wooPlusProducts.baseImageUrl!)"
                    if(wooPlusProducts.backGroundImages.count > 0)
                    {
                        let backGroundImageString: String = baseUrlString + "\(wooPlusProducts.backGroundImages.first!)"
                        self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                            self.backgroundImageView.image = image
                        })
                    }
                    if wooPlusProducts.carousalType == "TEXT" {
                        self.circleImageView.image = nil
                    }
                    else{
                        //                    let circleImageString: String = baseUrlString + "\((modelObject as! WooPlusProductModel).circleImage!)"
                        //                    self.circleImageView.sd_setImage(with: URL.init(string: circleImageString) as URL!, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        //                        self.circleImageView.image = image
                        //                    })
                    }
                }
            }
            carousalBottomToBgBottomConstraint.constant = 61
            circleImageToTopConstraint.constant = 3
            circleImageToBottomContraint.constant = 2
            circleImagetoCarouselHeightConstraint.constant = 10
            heightConstraint.constant = SCREEN_WIDTH * 1.4062
            
            break
        case .wooGlobe:
            subscriptionView.isHidden = true
            
            BoostProductsAPICalss.makePopupEventAPIwithType("WOOGLOBE")
            
            headerLabel.text = NSLocalizedString("Get Woo Globe", comment: "woo Global purchase header")
            
            self.headerBackgroundView.backgroundColor = UIColor(red: 57/255, green: 200/255, blue: 195/255, alpha: 1.0)
            
            
            if let wooGlobalProducts:WooGlobalProductModel = PurchaseProductDetailModel.sharedInstance().wooGlobalModel{
                modelObject = wooGlobalProducts as WooGlobalProductModel
                if(wooGlobalProducts.isToShowMostPopular != nil)
                {
                    isToShowMostPopular = (wooGlobalProducts.isToShowMostPopular?.boolValue) ?? false
                }
                if wooGlobalProducts.wooProductDto != nil{
                    self.productsArray = wooGlobalProducts.wooProductDto! as NSArray
                }
                self.carouselArea.backgroundColor = UIColor(red: 57/255, green: 200/255, blue: 195/255, alpha: 1.0)
                
                if wooGlobalProducts.carousalType == "IMAGE" {
                    self.backgroundImageView.image = nil
                    self.circleImageView.image = nil
                }
                else{
                    let baseUrlString:String = "\(wooGlobalProducts.baseImageUrl)"
                    
                    let circleImageString: String = baseUrlString + "\(wooGlobalProducts.circleImage ?? "")"
                    
                    //                if((modelObject as! WooGlobalProductModel).backGroundImages.count > 0)
                    //                {
                    let backGroundImageString: String = circleImageString
                    self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        self.backgroundImageView.image = image
                    })
                    //                }
                    if wooGlobalProducts.carousalType == "TEXT" {
                        self.circleImageView.image = nil
                    }
                    else{
                        //                    let circleImageString: String = baseUrlString + "\((modelObject as! WooGlobalProductModel).circleImage ?? "")"
                        //                    self.circleImageView.sd_setImage(with: URL.init(string: circleImageString) as URL!, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        //                        self.circleImageView.image = image
                        //                    })
                    }
                }
            }
            WooGlobeModel.sharedInstance().wooGlobePurchaseStarted = true
            heightConstraint.constant = headerBackgroundView.bounds.size.height + carouselArea.bounds.size.height + ((SCREEN_WIDTH / 4.5714) * CGFloat(self.productsArray.count)) + 25
            
            break
        default:
            subscriptionView.isHidden = true
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
            modelObject = nil
            heightConstraint.constant = SCREEN_WIDTH * 1.4062
            
        }
        
        
        
        self.frame = window.frame
        
        // self.layoutIfNeeded()
        
        ////
        self.perform(#selector(addScrollableView), with: nil, afterDelay: 0.2)
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            (window2.subviews.first! as UIView).addSubview(self)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                for subViewObj in (window2.subviews.last?.subviews)! {
                    if subViewObj is PurchasePopup {
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
    
    func autoSelectPlan(forPlanId planId:String){
        var indexOfProd = 0
        var indexVal = 0
        for itemObj in self.productsArray {
            let productData:NSDictionary = itemObj as! NSDictionary
            let planIdValueFromArray = productData["planId"] as! String
            if (planIdValueFromArray == planId) {
                indexOfProd = indexVal
                
                break
            }
            indexVal = indexVal + 1
        }
        
        
        self.tableView(purchaseTableView, didSelectRowAt: IndexPath.init(row: indexOfProd, section: 0))
    }
    
    @objc func addScrollableView()
    {
        if(scrollableView == nil)
        {
            scrollableView = PurchasePopupScrollableView.init(frame: CGRect(x: 0, y: 0, width: scrollableContainerView.frame.size.width, height: scrollableContainerView.frame.size.height))
            scrollableView?.backgroundColor = UIColor.clear
            scrollableContainerView.addSubview(scrollableView!)
        }
        //        if self.screenType.rawValue != 3 {
        //            scrollableIndex = 1;
        //        }
        scrollableView?.setupData(withModel: modelObject, forType: Int32(Int(self.screenType.rawValue)), with: Int32(scrollableIndex))
        scrollableView?.createAddPageControlNow(withFrame: (scrollableView?.frame.size.height)! - 20, with: 0)
        if(self.screenType == .crush && purchaseScreenType == .purchase)
        {
            scrollableView?.changePageControlTint(UIColorHelper.color(fromRGB: "#AA091E", withAlpha: 1.0))
        }
        else
        {
            scrollableView?.changePageControlTint(UIColor(red: 232.0/255.0, green: 89.0/255.0, blue: 94.0/255.0, alpha: 1.0))
        }
    }
    
    /*
     @objc func setupDataforScrollableView()
     {
     scrollableContainerView.frame = carouselArea.frame
     scrollableView?.frame =
     CGRect(x: 0, y: 0, width: scrollableContainerView.frame.size.width, height: scrollableContainerView.frame.size.height)
     scrollableView?.backgroundColor = UIColor.clear
     
     scrollableView?.setupData(withModel: modelObject, forType: Int32(Int(self.screenType.rawValue)), with: Int32(scrollableIndex))
     scrollableView?.resetPageNumberForPageControl()
     
     }
     */
    
    override func awakeFromNib() {
        self.popupContentArea.layer.cornerRadius = 7.0
        self.popupContentArea.clipsToBounds = true
        //450
        self.registerNibs()
        
    }
    
    func registerNibs(){
        
        purchaseTableView.register(UINib(nibName:"LargePurchaseCell", bundle: nil), forCellReuseIdentifier: "LargePurchaseCell")
        purchaseTableView.register(UINib(nibName:"PurchaseTableViewCell", bundle: nil), forCellReuseIdentifier: "PurchaseTableViewCell")
        purchaseTableView.register(UINib(nibName:"ComboPurchaseTableViewCell", bundle: nil), forCellReuseIdentifier: "ComboPurchaseTableViewCell")
        purchaseTableView.register(UINib(nibName:"PurchaseOptionSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "PurchaseOptionSelectionTableViewCell")
        performLinkMaker()
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(purchaseScreenType == .purchase)
        {
            //doesnot have wooplus and has never purchased
            
            if comboProductsDto != nil && comboProductsDto?.wooProductDto != nil && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false
            {
                return self.productsArray.count + 1
            }
            return self.productsArray.count
        }
        else
        {
            return comboProductsDto?.wooProductDto?.count ?? 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        print(self.productsArray)
        if(purchaseScreenType == .paymentoption)
        {
            return 50
        }
        if(self.screenType == .wooGlobe)
        {
            return (SCREEN_WIDTH / 4.5714)
        }
        //if most popular
        //Divide available area between first and rest of the cells
        let tableHeight =  Float(tableView.bounds.size.height)
        var productCount = Float(self.productsArray.count)
        if(comboProductsDto != nil &&  comboProductsDto?.wooProductDto != nil && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false)
        {
            productCount = Float(self.productsArray.count + 1)
        }
        if(isToShowMostPopular)
        {
            if(comboProductsDto != nil && comboProductsDto?.wooProductDto != nil && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false)
            {
                if indexPath.row == 0 {
                    let height  = Float(tableHeight/productCount)
                    //height - extraHeight/numberOfProducts + extraheightforMostPopular
                    let comboExtraHeightDistribution = 18.0/(productCount-1.0)
                    let rowHeight = CGFloat(floor( height + 4.0 - comboExtraHeightDistribution))
                    return rowHeight
                }
                else if indexPath.row == (self.productsArray.count) {
                    let height  = Float((tableHeight)/productCount)
                    let productCountWOCombo = productCount-1
                    let comboExtraHeightDistribution = 18.0/productCountWOCombo
                    let rowHeight = CGFloat(floor( tableHeight - productCountWOCombo*(height - comboExtraHeightDistribution)))
                    
                    return rowHeight                    // return height
                }
                else
                {
                    let height  = tableHeight/productCount
                    let comboExtraHeightDistribution = 18.0/(productCount-1)
                    return CGFloat(floor(height - comboExtraHeightDistribution - 4.0/(productCount-2)))
                    
                    //                    let heightOfOtherProds = (2 * height) + 19.0
                    //                    let leftNoOfProds = productCount-2.0
                    //                    let heightForRow  = CGFloat((tableHeight - heightOfOtherProds)/leftNoOfProds)
                    //                    return heightForRow
                }
                
                
            }
            else
            {
                if indexPath.row == 0 {
                    let height  = CGFloat((tableHeight)/productCount) + 4.0
                    return height
                }
                    
                else
                {
                    let height  = (tableHeight - (((tableHeight)/productCount) + 4.0))/(productCount-1.0)
                    return CGFloat(floor(height))
                }
            }
        }
        else{
            if(comboProductsDto != nil &&  comboProductsDto?.wooProductDto != nil && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false)
            {
                if indexPath.row == (self.productsArray.count) {
                    let height  = (tableHeight/productCount) + 18.0
                    return CGFloat(floor(height))
                }
                else
                {
                    let height  = (tableHeight - (((tableHeight)/productCount) + 18.0))/(productCount-1.0)
                    return CGFloat(floor(height))
                }
                
            }
            else
            {
                let height  = tableHeight/productCount
                return CGFloat(floor(height))
            }
        }
        
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if(comboProductsDto != nil && self.purchaseScreenType == .paymentoption &&  comboProductsDto?.wooProductDto != nil && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false)
        {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40.0))
            headerView.backgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.89, alpha: 1.0)
            
            //
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40.0))
            headerLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
            
            let productDictionary = comboProductsDto?.wooProductDto?.first
            let productCount = productDictionary?.object(forKey: "count") as! Int
            let price = productDictionary?.object(forKey: "pricePerUnit") as! String
            
            if AppLaunchModel.sharedInstance().disableFP == false{
                headerLabel.text = "Pick Payment option - \(productDictionary?.object(forKey: "priceUnit") as? String ?? "")\(Int(price)! * productCount)"
            }
            else{
                headerLabel.text = "Pick Payment option - \(productDictionary?.object(forKey: "priceUnit") as? String ?? "") \(price)/\(productDictionary?.object(forKey: "productNamePerUnit") as? String ?? "")"
            }
            headerLabel.backgroundColor = UIColor.clear
            headerLabel.textAlignment = .center
            headerLabel.textColor =  UIColor.black
            
            headerView.addSubview(headerLabel)
            return headerView
        }
        else
        {
            if(self.screenType != .wooGlobe)
            {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 5.0))
                headerLabel.backgroundColor = UIColor.clear
                return headerView
            }
        }
        let headerView = UIView()
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(purchaseScreenType == .purchase)
        {
            if self.screenType != .wooGlobe {
                return 5.0
            }
            return 15.0
        }
        else
        {
            return 40
        }
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if(purchaseScreenType == .purchase)
        {
            if(comboProductsDto != nil &&  comboProductsDto?.wooProductDto != nil && indexPath.row == self.productsArray.count && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false)
            {
                let cellIdentifier:String = "ComboPurchaseTableViewCell"
                let cellObj:ComboPurchaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ComboPurchaseTableViewCell
                cellObj.setDataOnCellwith(cellData:comboProductsDto! , productType: self.screenType)
                return cellObj
            }
            
            
            if(self.screenType == .wooGlobe)
            {
                let cellIdentifier = "PurchaseTableViewCell"
                let cellObj = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PurchaseTableViewCell
                cellObj.setDataOnCellwith(cellData:self.productsArray.object(at: indexPath.row) as! NSDictionary,  isSelected: (self.selectedIndex == indexPath.row), isLargeCell:self.isScreenWithLargeCell, productType: self.screenType)
                
                return cellObj
            }
            else
            {
                let cellIdentifier:String = "LargePurchaseCell"
                let cellObj : LargePurchaseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LargePurchaseCell
                
                cellObj.setDataOnCellwith(cellData:self.productsArray.object(at: indexPath.row) as! NSDictionary,  isSelected: (self.selectedIndex == indexPath.row), isLargeCell:self.isScreenWithLargeCell, productType: self.screenType)
                
                if(isToShowMostPopular && indexPath.row == 0)
                {
                    switch self.screenType {
                    case .boost:
                        cellObj.mostPopularImageView.image = UIImage(named: "ic_purchase_boost_popular")
                        break
                    case .crush:
                        cellObj.mostPopularImageView.image = UIImage(named: "ic_purchase_crush_popular")
                        break
                    case .wooPlus:
                        cellObj.mostPopularImageView.image = UIImage(named: "ic_purchase_wooplus_popular")
                        break
                    case .wooGlobe:
                        cellObj.mostPopularImageView.image = UIImage(named: "ic_purchase_wooglobe_popular")
                        break
                    default: break
                        // nothing to do here
                    }
                    cellObj.layer.zPosition = 10
                    cellObj.layer.shadowOffset = CGSize(width: 0, height: 0)
                    cellObj.layer.shadowColor = UIColor.black.cgColor
                    cellObj.layer.shadowRadius = 3.0;
                    cellObj.layer.shadowOpacity = 0.5
                    let shadowFrame = cellObj.layer.bounds;
                    let shadowPath = UIBezierPath(rect: shadowFrame).cgPath
                    cellObj.layer.shadowPath = shadowPath
                    cellObj.layer.shouldRasterize = true
                    cellObj.layer.rasterizationScale = UIScreen.main.scale
                    cellObj.mostPopularImageView.isHidden = false
                    cellObj.mostPopularLabel.isHidden = false
                    
                }
                else
                {
                    cellObj.mostPopularLabel.isHidden = true
                    cellObj.mostPopularImageView.isHidden = true
                }
                return cellObj
            }
            
        }
        else
        {
            let cellIdentifier:String = "PurchaseOptionSelectionTableViewCell"
            let cellObj:PurchaseOptionSelectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PurchaseOptionSelectionTableViewCell
            cellObj.payButtonTappedHandler = {
                //initiate woo plus purchase
                //                let eventName : NSString = NSString(format:"3-WooPlusPurchase.WP_What_You_Get.WP_\(count)_Months" as NSString )
                //                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "WP_What_You_Get", withEventName: eventName as String)
                
                if let storeProduct:NSDictionary = self.comboProductsDto?.wooProductDto?.first?.object(forKey: "i_store") as? NSDictionary
                {
                    if let storeID = storeProduct.object(forKey: "storeProductId") as? String{
                        
                        let setObj = NSSet(array:[storeID])
                        let strCount  = self.comboProductsDto?.wooProductDto?.first?["count"] as! NSNumber
                        
                        if let funnelString = self.initiatedView{
                            _ = funnelString + "_paynow"
                            //(Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                        }
                        
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")
                        
                        self.showLoader()
                        
                        var product:SKProduct?
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")
                        switch self.screenType{
                        case .boost:
                            product = (self.modelObject as! BoostProductModel).getProductToBePurchased(storeID)
                            break
                        case .crush:
                            product = (self.modelObject as! CrushProductModel).getProductToBePurchased(storeID as String?)
                            break
                        case .wooPlus:
                            product = (self.modelObject as! WooPlusProductModel).getProductToBePurchased(storeID)
                            break
                        case .wooGlobe:
                            product = (self.modelObject as! WooGlobalProductModel).getProductToBePurchased(storeId: storeID)
                            break
                        default:
                            break
                        }
                        self.initiatePurchaseFlow(product, productSet: setObj, planID: (self.comboProductsDto?.wooProductDto?.first?.object(forKey: "planId") as? String)!, productCount: strCount.stringValue)
                    }
                }
                
            }
            
            return cellObj
        }
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
    func turnStringIntoLink(inputString: String) -> NSMutableAttributedString {
        
        // Turns a String into an NSMutableAttributedString
        let linkString = NSMutableAttributedString(string: inputString)
        
        // Use addAttribute function to make 'linkString' an  NSURL object and to customize the font
        
        var linkUrl = NSURL()
        if inputString == "Privacy Policy." && (AppLaunchModel.sharedInstance().termsUrl != nil){
            linkUrl = AppLaunchModel.sharedInstance().termsUrl! as NSURL
        }
        else{
            linkUrl = NSURL(string: "http://www.getwooapp.com/SubscriptionFAQ.html")!
        }
        linkString.addAttribute(NSAttributedString.Key.link, value: linkUrl, range: NSMakeRange(0, inputString.count))
        
        
        subscriptionTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        linkString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Lato-Bold", size: 12.0)!, range: NSMakeRange(0, inputString.count))
        linkString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, inputString.count))
        
        return linkString
    }
    
    func performLinkMaker() {
        
        let subscriptionString = NSMutableAttributedString()
        
        let headerString = "Recurring billing. Cancel any time."
        let headerMutableString = NSMutableAttributedString(string: headerString)
        headerMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Lato-Bold", size: 12.0)!, range: NSMakeRange(0, headerString.count))
        headerMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, headerString.count))
        subscriptionString.append(headerMutableString)
        
        let middleString = "\nIf you choose to purchase a subscription, payment will be charged to your iTunes account, and your account will be charged within 24 hours prior to the end of current period. Auto-renewal may be turned off at any time by going to your settings in the iTunes store after purchase. For more information, please visit our "
        let middleMutableString = NSMutableAttributedString(string: middleString)
        middleMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, middleString.count))
        
        subscriptionString.append(middleMutableString)
        
        let termsString = "Terms of Service"
        let termsMutableString = turnStringIntoLink(inputString: termsString)
        subscriptionString.append(termsMutableString)
        
        let andString = " and "
        let andMutableString = NSMutableAttributedString(string: andString)
        andMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, andString.count))
        subscriptionString.append(andMutableString)
        
        let privacyString = "Privacy Policy."
        let privacyMutableString = turnStringIntoLink(inputString:privacyString)
        subscriptionString.append(privacyMutableString)
        
        self.subscriptionTextView.attributedText = subscriptionString
        self.subscriptionTextView.textAlignment = .center
        self.subscriptionTextView.delegate = self
        self.subscriptionTextView.isEditable = false
        self.subscriptionTextView.isSelectable = true
        self.subscriptionTextView.dataDetectorTypes = .link
        self.subscriptionTextView.isUserInteractionEnabled = true
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
            DispatchQueue.main.async {
                self.loader?.removeFromSuperview()
            }
        }
    }
    
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if self.purchaseScreenType == .paymentoption
        {
            //initiate payment
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else
        {
            if(comboProductsDto != nil &&  comboProductsDto?.wooProductDto != nil && indexPath.row == self.productsArray.count && WooPlusModel.sharedInstance().isExpired == true && WooPlusModel.sharedInstance().hasEverPurchased == false)
            {
                
                switch self.screenType
                {
                case .boost:
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Boost_combo_pack_tap")
                    
                    break
                case .crush:
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Crush_combo_pack_tap")
                    break
                default:
                    break
                }
                //open payment options
                self.purchaseScreenType = .paymentoption
                //show back button
                backButton.isHidden = false
                //
                subscriptionView.isHidden = false
                //
                headerLabel.text = NSLocalizedString("WooPlus", comment: "woo plus purchase header")
                
                self.headerBackgroundView.backgroundColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
                self.backgroundImageView.backgroundColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
                //comboProductsDto
                
                modelObject = comboProductsDto!
                //                    PurchaseProductDetailModel.sharedInstance().wooPlusModel as WooPlusProductModel
                let wooPlusProducts:WooGlobalProductModel = modelObject as! WooGlobalProductModel
                isToShowMostPopular = wooPlusProducts.isToShowMostPopular?.boolValue ?? false
                
                if wooPlusProducts.wooProductDto != nil{
                    self.productsArray = wooPlusProducts.wooProductDto! as NSArray
                }
                
                if (modelObject as! WooGlobalProductModel).carousalType == "IMAGE" {
                    self.backgroundImageView.image = nil
                    self.circleImageView.image = nil
                }
                else{
                    let baseUrlString:String = "\((modelObject as! WooGlobalProductModel).baseImageUrl)"
                    if((modelObject as! WooGlobalProductModel).backGroundImages.count > 0)
                    {
                        let backGroundImageString: String = baseUrlString + "\((modelObject as! WooGlobalProductModel).backGroundImages.first!)"
                        self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                            self.backgroundImageView.image = image
                        })
                    }
                    if (modelObject as! WooGlobalProductModel).carousalType == "TEXT" {
                        self.circleImageView.image = nil
                    }
                    else{
                        self.circleImageView.image = nil
                    }
                }
                
                //use new
                self.perform(#selector(addScrollableView), with: nil, afterDelay: 0.2)
                
                DispatchQueue.main.async {
                    self.purchaseTableView.reloadData()
                }
                
                heightConstraint.constant = headerBackgroundView.bounds.size.height + carouselArea.bounds.size.height + 40.0 + 50.0
            }
            else
            {
                if !Utilities().reachable() { // If there is no internet connection
                    
                    Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
                    return
                }
                
                self.showLoader()
                
                
                selectedIndex = indexPath.row
                
                DispatchQueue.main.async {
                    self.purchaseTableView.reloadData()
                }
                
                let productData:NSDictionary = self.productsArray.object(at: indexPath.row) as! NSDictionary
                
                
                print(productData.object(forKey: "priceUnit"))
                //This user defaults sets to send the data to firebase and facebook events from informServerAboutPurchaseWithTransaction method
                UserDefaults.standard.set(productData.object(forKey: "priceUnit"), forKey: "priceUnitForSelectedProduct")
//                print(productData.object(forKey: "isUpdateStatOnFirebase") ?? "")
                UserDefaults.standard.synchronize()
                
                switch self.screenType {
                case .boost:
                    
                    if let count = productData["count"]{
                        let eventName : NSString = NSString(format:"3-GetBoost.Boost_What_You_Get.GB_\(count)_BoostsPack" as NSString )
                        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Boost_What_You_Get", withEventName: eventName as String)
                    }
                    
                    break
                case .crush:
                    if let count = productData["count"]{
                        let _ : NSString = NSString(format:"3-GetCrush.Crush_What_You_Get.GC_\(count)_CrushPack" as NSString )
                        //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Crush_What_You_Get", withEventName: eventName as String)
                    }
                    break
                case .wooPlus:
                    if let count = productData["count"]{
                        let _ : NSString = NSString(format:"3-WooPlusPurchase.WP_What_You_Get.WP_\(count)_Months" as NSString )
                        //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "WP_What_You_Get", withEventName: eventName as String)
                    }
                    break
                case .wooGlobe:
                    if productData["count"] != nil{
                        let _ : NSString = NSString(format:"3-WooPlusPurchase.WP_What_You_Get.WG" as NSString )
                        //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "WP_What_You_Get", withEventName: eventName as String)
                    }
                    break
                default: break
                    // nothing to do here
                }
                
                if let storeProduct:NSDictionary = productData.object(forKey: "i_store") as? NSDictionary {
                    if let storeID:NSString = storeProduct.object(forKey: "storeProductId") as! String as NSString? {
                        
                        let setObj = NSSet(array: [storeID])
                        let strCount  = productData["count"] as! NSNumber
                        
                        if let funnelString = self.initiatedView{
                            _ = funnelString + "_paynow"
                            //(Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                        }
                        var product:SKProduct?
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "paynow")
                        switch self.screenType{
                        case .boost:
                            break
                        case .crush:
                            //product = (modelObject as! CrushProductModel).getProductToBePurchased(storeID as String?)
                            break
                        case .wooPlus:
                            break
                        case .wooGlobe:
                            break
                        default:
                            break
                        }
                        self.initiatePurchaseFlow(product, productSet: setObj, planID: (productData.object(forKey: "planId") as? String)!, productCount: strCount.stringValue)
                    }
                }
            }
        }
    }
    
    func increaseCancellationCounter()
    {
        let keyForProductId = "\(self.screenType.rawValue)-cancellationCount"
        
        let cancellationCount = UserDefaults.standard.integer(forKey: keyForProductId) + 1
        UserDefaults.standard.set(cancellationCount, forKey: keyForProductId)
        UserDefaults.standard.synchronize()
    }
    
    /* -(void)increaseCancellationCounterForProductWithIdentifier:(NSString *)identifier
     {
     NSString *keyForProductId = [NSString stringWithFormat:@"%@-cancellationCount",identifier];
     if ([[NSUserDefaults standardUserDefaults] integerForKey:keyForProductId])
     {
     NSInteger cancellationCount = [[NSUserDefaults standardUserDefaults] integerForKey:keyForProductId];
     [[NSUserDefaults standardUserDefaults] setInteger:cancellationCount+1 forKey:keyForProductId];
     }else
     {
     [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:keyForProductId];
     }
     [[NSUserDefaults standardUserDefaults]synchronize];
     
     }
     */
    func initiatePurchaseFlow(_ skProduct:SKProduct?, productSet:NSSet, planID:String , productCount:String) {
        
        print("🎾🎾🎾🎾 In initiate");
        FBAppEvents.logEvent("initiate_checkout")
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "initate_checkout")
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
        
        if skProduct != nil{
            var prodType:InAppPRoductType
            
            //if combo prod DTO and screentype is options pick then donot check screen type add prodType = Wooplus by default
            
            if(self.purchaseScreenType == .purchase)
            {
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
            }
            else
            {
                prodType = InAppPRoductType.wooPlus
            }
            
            (InAppPurchaseManager.sharedIAPManager() as AnyObject).purchaseProduct(with: skProduct, withProductType: prodType, withPlanID: planID, andResult: { (successFlag,error, canMakePayment, serverResponse) in
                if (!successFlag){
                    self.removeLoader()
                    if let error = error as? NSError
                    {
                        if(error.code == 2 )//|| error.code == 0)
                        {
                            //check if this product has DTO
                            let productData = self.productsArray.object(at: self.selectedIndex) as? NSDictionary
                            let planProductId = productData?["planId"] as! String
                            
                            self.increaseCancellationCounter()
                            
                            var planIDArray: [String] = UserDefaults.standard.object(forKey:"DropOffPlanIDArray") as? [String] ?? []
                            if(planIDArray.contains(planProductId) == false)
                            {
                                planIDArray.append(planProductId)
                                UserDefaults.standard.set(planIDArray, forKey: "DropOffPlanIDArray")
                                UserDefaults.standard.synchronize()
                                
                            }
                            
                            if let productInfo = productData?["dropOffPlanDto"] as? NSDictionary
                            {
                                let dropOffPlanDto = DropOffProductModel(data: productInfo)
                                let maxCountInDay = dropOffPlanDto.maxCountInDay ?? 0
                                let maxCountInLifeTime = dropOffPlanDto.maxCountInLifeTime ?? 0
                                
                                let cancellationCountForProduct = UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-cancellationCount")
                                //
                                let shownTodayCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenTodayCount")
                                let seenLifetimeCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenLifetimeCount")
                                
                                let lastSeenDate = UserDefaults.standard.object(forKey: "\(self.screenType.rawValue)-lastSeenDate") as? String
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd-MMM-yyyy"
                                //                                        dateFormatter.dateStyle = DateFormatter.Style(rawValue: 1)!
                                //NSDateFormatterShortStyle
                                
                                var DateToday = Date()
                                let dateString = dateFormatter.string(from: DateToday)
                                DateToday = dateFormatter.date(from: dateString)!
                                
                                if(seenLifetimeCount == 0 || seenLifetimeCount < maxCountInLifeTime)
                                {
                                    //if lastseendate nahi hai
                                    if(lastSeenDate == nil)
                                    {
                                        
                                        for product in dropOffPlanDto.productDto!
                                        {
                                            if(shownTodayCount == 0 || shownTodayCount < maxCountInDay)
                                            {
                                                let dropOffCount =  product["dropOffCount"] as! Int
                                                if (dropOffCount == cancellationCountForProduct)
                                                {
                                                    self.appendtoDropOffArray(forProductWithDetail: product, andParentPricePerUnit: productData!["pricePerUnit"] as! String, andParentPlanId: planProductId)
                                                    
                                                }
                                            }
                                        }
                                        
                                    }
                                        //lastseendate same hai as today
                                        //to phir aaj ka count to khatam nahi hua ye chek
                                    else if( dateFormatter.date(from: lastSeenDate!) == DateToday)
                                    {
                                        
                                        if(shownTodayCount == 0 || shownTodayCount < maxCountInDay)
                                        {
                                            for product in dropOffPlanDto.productDto!
                                            {
                                                let dropOffCount =  product["dropOffCount"] as! Int
                                                if (dropOffCount == cancellationCountForProduct)
                                                {
                                                    self.appendtoDropOffArray(forProductWithDetail: product, andParentPricePerUnit: productData!["pricePerUnit"] as! String, andParentPlanId: planProductId)
                                                }
                                            }
                                            
                                        }
                                    }
                                    else
                                    {
                                        //reset seen today count to 0
                                        UserDefaults.standard.set(0, forKey: "\(self.screenType.rawValue)-seenTodayCount")
                                        UserDefaults.standard.synchronize()
                                        let shownTodayCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenTodayCount")
                                        /// reset cancellation count for product to 1
                                        UserDefaults.standard.set(1, forKey: "\(self.screenType.rawValue)-cancellationCount")
                                        let cancellationCountForProduct = UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-cancellationCount")
                                        
                                        if(shownTodayCount == 0 || shownTodayCount < maxCountInDay)
                                        {
                                            for product in dropOffPlanDto.productDto!
                                            {
                                                let dropOffCount =  product["dropOffCount"] as! Int
                                                if (dropOffCount == cancellationCountForProduct)
                                                {
                                                    self.appendtoDropOffArray(forProductWithDetail: product, andParentPricePerUnit: productData!["pricePerUnit"] as! String, andParentPlanId: planProductId)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            self.dropOffProductDTOsToBeShown.removeAll()
                        }
                    }
                    return
                    
                }
                self.dropOffProductDTOsToBeShown.removeAll()
                
                //
                //FBAppEvents.logEvent("Purchase_Successful");
                
                let productDataForFb = self.productsArray.object(at: self.selectedIndex) as? NSDictionary
                
                let paramsDict = NSDictionary(object: productDataForFb?.object(forKey: "priceUnit")! as! String, forKey: "priceUnit" as NSCopying)
                var unitOfPrice = "INR"
                
                if productDataForFb?.object(forKey: "priceUnit") as! String == "$"{
                    unitOfPrice = "USD"
                }
                var amountInDouble:Double = 0.0
                if let productAmount = productDataForFb?.object(forKey: "price"){
                    let amount = productAmount as! Double
                    amountInDouble = amount
                }
                (Utilities.sharedUtility() as AnyObject).logPurchaseEvent(onFacebook: unitOfPrice, withParameters: paramsDict as? [AnyHashable : Any], withPurchaseAmount: amountInDouble)
                
                if let funnelString = self.initiatedView{
                    _ = funnelString + "_success"
                    //(Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                }
                
                (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "success")
                
                if(self.purchaseScreenType == .purchase)
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
                        boostDict["hasEverPurchased"] = true
                        boostDict["availableInRegion"] = boostModel.availableInRegion
                        boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                        boostDict["currentlyActive"] = boostModel.currentlyActive
                        BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                        //WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                        
                        self.moveToMe()
                        
                        
                        if self.purchasedHandler != nil{
                            self.purchasedHandler(true)
                        }
                        self.removeLoader()
                        self.removeFromSuperview()
                        
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
                        crushDict["hasEverPurchased"] = true
                        crushDict["availableInRegion"] = crushModel.availableInRegion
                        CrushModel.sharedInstance().updateData(withCrush: crushDict)
                        
                        
                        
                        if self.purchasedHandler != nil{
                            self.purchasedHandler(true)
                        }
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                            //WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                            
                            self.moveTodiscover()
                        }
                        self.removeLoader()
                        self.removeFromSuperview()
                        
                        break
                        
                    case .wooPlus:
                        
                        
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
                        
                        if let chatBlockingDetails:NSDictionary = (responseDictionary.object(forKey: "wooFeatureDto") as? NSDictionary)!{
                            if let isChatEnabled = chatBlockingDetails.object(forKey: "isChatEnabled") as? Bool{
                             AppLaunchModel.sharedInstance()!.isChatEnabled = isChatEnabled
                            }
                        }
                        
                        WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                            // WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                            self.moveToMe()
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
                        
                        let wooGlobeData:NSDictionary = (responseDictionary.object(forKey: "wooGlobeDto") as? NSDictionary)!
                        
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
                else
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
                        boostDict["hasEverPurchased"] = true
                        boostDict["availableInRegion"] = boostModel.availableInRegion
                        boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                        boostDict["currentlyActive"] = boostModel.currentlyActive
                        BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                        
                    }
                    if let crushData = responseDictionary.object(forKey: "crushDto") as? NSDictionary
                    {
                        let crushModel: CrushModel = CrushModel.sharedInstance()
                        var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                        crushDict["expiryTime"] = crushData.object(forKey: "expiryTime") as! Int
                        crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                        crushDict["hasEverPurchased"] = true
                        crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                        crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                        crushDict["availableInRegion"] = crushModel.availableInRegion
                        CrushModel.sharedInstance().updateData(withCrush: crushDict)
                        
                    }
                    
                    
                    if let wooPlusData =  responseDictionary.object(forKey: "wooPlusDto") as? NSDictionary
                    {
                        let wooPlusModel: WooPlusModel = WooPlusModel.sharedInstance()
                        
                        var wooPlusDict: [AnyHashable: Any] = [AnyHashable: Any]()
                        
                        wooPlusDict["expired"] = wooPlusData.object(forKey: "expired") as! Bool
                        
                        if (wooPlusDict["expired"] as! Bool) != true
                        {
                            
                            wooPlusDict["subscriptionId"] = wooPlusData.object(forKey: "subscriptionId") as! String
                            wooPlusDict["availableInRegion"] = wooPlusModel.availableInRegion
                            
                        }
                        wooPlusDict["hasEverPurchased"] = true
                        
                        WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                        
                        if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                        }
                        
                        if self.purchasedHandler != nil{
                            self.purchasedHandler(true)
                        }
                        self.removeLoader()
                        self.removeFromSuperview()
                        
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
                    
                    DispatchQueue.main.async {
                        let snackBarObj: MDSnackbar = MDSnackbar(text:NSLocalizedString("We are facing some issue connecting store. Please try after some time.", comment: "We are facing some issue connecting store. Please try after some time.") , actionTitle: "", duration: 2.0)
                        snackBarObj.multiline = true
                        snackBarObj.show()
                    }
                     
                }
                if (successFlag == true) && (canMakePurchase == true){
                    
                    let prods:NSArray = productsFromServer! as NSArray
                    
                    var prodType:InAppPRoductType
                    
                    //if combo prod DTO and screentype is options pick then donot check screen type add prodType = Wooplus by default
                    
                    if(self.purchaseScreenType == .purchase)
                    {
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
                    }
                    else
                    {
                        prodType = InAppPRoductType.wooPlus
                    }
                    
                    (InAppPurchaseManager.sharedIAPManager() as AnyObject).purchaseProduct(with: (prods.firstObject as! SKProduct), withProductType:prodType, withPlanID:planID, andResult:{(successFlag,error, canMakePayment, serverResponse) in
                        
                        if (!successFlag){
                            self.removeLoader()
                            if let error = error as? NSError
                            {
                                if(error.code == 2 )//|| error.code == 0)
                                {
                                    //check if this product has DTO
                                    let productData = self.productsArray.object(at: self.selectedIndex) as? NSDictionary
                                    let planProductId = productData?["planId"] as! String
                                    
                                    self.increaseCancellationCounter()
                                    
                                    var planIDArray: [String] = UserDefaults.standard.object(forKey:"DropOffPlanIDArray") as? [String] ?? []
                                    if(planIDArray.contains(planProductId) == false)
                                    {
                                        planIDArray.append(planProductId)
                                        UserDefaults.standard.set(planIDArray, forKey: "DropOffPlanIDArray")
                                        UserDefaults.standard.synchronize()
                                        
                                    }
                                    
                                    if let productInfo = productData?["dropOffPlanDto"] as? NSDictionary
                                    {
                                        let dropOffPlanDto = DropOffProductModel(data: productInfo)
                                        let maxCountInDay = dropOffPlanDto.maxCountInDay ?? 0
                                        let maxCountInLifeTime = dropOffPlanDto.maxCountInLifeTime ?? 0
                                        
                                        let cancellationCountForProduct = UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-cancellationCount")
                                        //
                                        let shownTodayCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenTodayCount")
                                        let seenLifetimeCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenLifetimeCount")
                                        
                                        let lastSeenDate = UserDefaults.standard.object(forKey: "\(self.screenType.rawValue)-lastSeenDate") as? String
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd-MMM-yyyy"
                                        //                                        dateFormatter.dateStyle = DateFormatter.Style(rawValue: 1)!
                                        //NSDateFormatterShortStyle
                                        
                                        var DateToday = Date()
                                        let dateString = dateFormatter.string(from: DateToday)
                                        DateToday = dateFormatter.date(from: dateString)!
                                        
                                        if(seenLifetimeCount == 0 || seenLifetimeCount < maxCountInLifeTime)
                                        {
                                            //if lastseendate nahi hai
                                            if(lastSeenDate == nil)
                                            {
                                                
                                                for product in dropOffPlanDto.productDto!
                                                {
                                                    if(shownTodayCount == 0 || shownTodayCount < maxCountInDay)
                                                    {
                                                        let dropOffCount =  product["dropOffCount"] as! Int
                                                        if (dropOffCount == cancellationCountForProduct)
                                                        {
                                                            self.appendtoDropOffArray(forProductWithDetail: product, andParentPricePerUnit: productData!["pricePerUnit"] as! String, andParentPlanId: planProductId)
                                                            
                                                        }
                                                    }
                                                }
                                                
                                            }
                                                //lastseendate same hai as today
                                                //to phir aaj ka count to khatam nahi hua ye chek
                                            else if( dateFormatter.date(from: lastSeenDate!) == DateToday)
                                            {
                                                
                                                if(shownTodayCount == 0 || shownTodayCount < maxCountInDay)
                                                {
                                                    for product in dropOffPlanDto.productDto!
                                                    {
                                                        let dropOffCount =  product["dropOffCount"] as! Int
                                                        if (dropOffCount == cancellationCountForProduct)
                                                        {
                                                            self.appendtoDropOffArray(forProductWithDetail: product, andParentPricePerUnit: productData!["pricePerUnit"] as! String, andParentPlanId: planProductId)
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                            else
                                            {
                                                //reset seen today count to 0
                                                UserDefaults.standard.set(0, forKey: "\(self.screenType.rawValue)-seenTodayCount")
                                                UserDefaults.standard.synchronize()
                                                let shownTodayCount =  UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-seenTodayCount")
                                                /// reset cancellation count for product to 1
                                                UserDefaults.standard.set(1, forKey: "\(self.screenType.rawValue)-cancellationCount")
                                                let cancellationCountForProduct = UserDefaults.standard.integer(forKey: "\(self.screenType.rawValue)-cancellationCount")
                                                
                                                if(shownTodayCount == 0 || shownTodayCount < maxCountInDay)
                                                {
                                                    for product in dropOffPlanDto.productDto!
                                                    {
                                                        let dropOffCount =  product["dropOffCount"] as! Int
                                                        if (dropOffCount == cancellationCountForProduct)
                                                        {
                                                            self.appendtoDropOffArray(forProductWithDetail: product, andParentPricePerUnit: productData!["pricePerUnit"] as! String, andParentPlanId: planProductId)
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    self.dropOffProductDTOsToBeShown.removeAll()
                                }
                            }
                            return
                        }
                        self.dropOffProductDTOsToBeShown.removeAll()
                        
                        //
                        //FBAppEvents.logEvent("Purchase_Successful");
                        
                        // [APP_DELEGATE logPurchaseEventOnFacebook:@"" withParameters:nil withPurchaseAmount:productData!["pricePerUnit"]];
                        let productDataForFb = self.productsArray.object(at: self.selectedIndex) as? NSDictionary
                        var amountInDouble:Double = 0.0
                        if let productAmount = productDataForFb?.object(forKey: "price"){
                            let amount = productAmount as? Double
                            amountInDouble = amount ?? 0
                        }
                        let paramsDict = NSDictionary(object: productDataForFb?.object(forKey: "priceUnit")! as! String, forKey: "priceUnit" as NSCopying)
                        var unitOfPrice = "INR"
                        if productDataForFb?.object(forKey: "priceUnit") as! String == "$"{
                            unitOfPrice = "USD"
                        }
                        
                        (Utilities.sharedUtility() as AnyObject).logPurchaseEvent(onFacebook: unitOfPrice, withParameters: paramsDict as? [AnyHashable : Any], withPurchaseAmount: amountInDouble)
                        
                        if let funnelString = self.initiatedView{
                            _ = funnelString + "_success"
                            //(Utilities.sharedUtility() as AnyObject).sendFirebaseEvent(withScreenName: "", withEventName: paynowString)
                        }
                        let purchaseDictionary: [String:String] = [
                            "currency" : unitOfPrice,
                            "value" : String(amountInDouble)
                        ]
                        (Utilities.sharedUtility() as AnyObject).sendPurchasedFirebaseEventwithEventName("ecommerce_purchase", andPurchaseData: purchaseDictionary)
                        
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "success")
                        
                        if(self.purchaseScreenType == .purchase)
                        {
                            
                            switch (self.screenType){
                                
                            case .boost:
                                
                                let boostModel: BoostModel = BoostModel.sharedInstance()
                                
                                var boostDict: [AnyHashable: Any] = [AnyHashable: Any]()
                                
                                let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                                
                                let boostedData:NSDictionary = (responseDictionary.object(forKey: "boostDto") as? NSDictionary)!
                                boostDict["availableBoost"] = boostedData.object(forKey: "availableBoost") as! Int
                                
                                if let expiryTime = boostedData.object(forKey: "expiryTime") as? Int{
                                    boostDict["expiryTime"] = expiryTime
                                }else{
                                    boostDict["expiryTime"] = 0
                                }
                                
                                
                                boostDict["percentageCompleted"] = boostedData.object(forKey: "percentageCompleted") as! Int
                                boostDict["hasPurchased"] = true
                                boostDict["hasEverPurchased"] = true
                                boostDict["availableInRegion"] = boostModel.availableInRegion
                                boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                                boostDict["currentlyActive"] = boostModel.currentlyActive
                                BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                                //WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                                
                                self.moveToMe()
                                
                                
                                if self.purchasedHandler != nil{
                                    self.purchasedHandler(true)
                                }
                                self.removeLoader()
                                self.removeFromSuperview()
                                
                                break
                                
                            case .crush:
                                
                                let crushModel: CrushModel = CrushModel.sharedInstance()
                                
                                var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                                
                                let responseDictionary:NSDictionary = (serverResponse as? NSDictionary)!
                                
                                let crushData:NSDictionary = (responseDictionary.object(forKey: "crushDto") as? NSDictionary)!
                                crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                                if let expiryTime = crushData.object(forKey: "expiryTime") as? Int{
                                    crushDict["expiryTime"] = expiryTime
                                }else{
                                    crushDict["expiryTime"] = 0
                                }
                                crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                                crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                                crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                                crushDict["hasEverPurchased"] = true
                                crushDict["availableInRegion"] = crushModel.availableInRegion
                                CrushModel.sharedInstance().updateData(withCrush: crushDict)
                                
                                
                                
                                if self.purchasedHandler != nil{
                                    self.purchasedHandler(true)
                                }
                                
                                if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                                    //WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                                    
                                    self.moveTodiscover()
                                }
                                self.removeLoader()
                                self.removeFromSuperview()
                                
                                break
                                
                            case .wooPlus:
                                
                                
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
                                    // WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                                    self.moveToMe()
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
                                print("responseDictionary is", responseDictionary)
                                
                                if((responseDictionary.object(forKey: "wooGlobeDto") as? NSDictionary) != nil){
                                    let wooGlobeData:NSDictionary = (responseDictionary.object(forKey: "wooGlobeDto") as? NSDictionary)!
                                    
                                    wooGlobeModel.isExpired = wooGlobeData.object(forKey: "expired") as! Bool
                                    wooGlobeModel.hasEverPurchased = true
                                }else{
                                    
                                    DispatchQueue.main.async {
                                        let snackBarObj: MDSnackbar = MDSnackbar(text:NSLocalizedString("We are facing some issue. Please try after some time.", comment: "We are facing some issue connecting store. Please try after some time.") , actionTitle: "", duration: 2.0)
                                        snackBarObj.multiline = true
                                        snackBarObj.show()
                                    }
                                     
                                }
                                
                                
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
                        else
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
                                boostDict["hasEverPurchased"] = true
                                boostDict["availableInRegion"] = boostModel.availableInRegion
                                boostDict["showInLeftMenu"] = boostModel.showInLeftMenu
                                boostDict["currentlyActive"] = boostModel.currentlyActive
                                BoostModel.sharedInstance().updateData(withBoostDictionary: boostDict)
                                
                            }
                            if let crushData = responseDictionary.object(forKey: "crushDto") as? NSDictionary
                            {
                                let crushModel: CrushModel = CrushModel.sharedInstance()
                                var crushDict: [AnyHashable: Any] = [AnyHashable: Any]()
                                crushDict["availableCrush"] = crushData.object(forKey: "availableCrush") as! Int
                                crushDict["expiryTime"] = crushData.object(forKey: "expiryTime") as! Int
                                crushDict["hasPurchased"] = crushData.object(forKey: "hasPurchased") as! Bool
                                crushDict["hasEverPurchased"] = true
                                crushDict["totalCrush"] = crushData.object(forKey: "totalCrush") as! Int
                                crushDict["showInLeftMenu"] = crushModel.showInLeftMenu
                                crushDict["availableInRegion"] = crushModel.availableInRegion
                                CrushModel.sharedInstance().updateData(withCrush: crushDict)
                                
                            }
                            
                            
                            if let wooPlusData =  responseDictionary.object(forKey: "wooPlusDto") as? NSDictionary
                            {
                                let wooPlusModel: WooPlusModel = WooPlusModel.sharedInstance()
                                
                                var wooPlusDict: [AnyHashable: Any] = [AnyHashable: Any]()
                                
                                wooPlusDict["expired"] = wooPlusData.object(forKey: "expired") as! Bool
                                
                                if (wooPlusDict["expired"] as! Bool) != true
                                {
                                    
                                    wooPlusDict["subscriptionId"] = wooPlusData.object(forKey: "subscriptionId") as! String
                                    wooPlusDict["availableInRegion"] = wooPlusModel.availableInRegion
                                    
                                }
                                wooPlusDict["hasEverPurchased"] = true
                                
                                WooPlusModel.sharedInstance().updateData(withWooPlusDictionary: wooPlusDict)
                                
                                if (DiscoverProfileCollection.sharedInstance.comingFromDiscover == false){
                                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                                }
                                
                                if self.purchasedHandler != nil{
                                    self.purchasedHandler(true)
                                }
                                self.removeLoader()
                                self.removeFromSuperview()
                                
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
    func appendtoDropOffArray(forProductWithDetail product:NSDictionary, andParentPricePerUnit pricePerUnit:String, andParentPlanId planProductId:String)
    {
        
        switch (self.screenType){
            
        case .boost:
            if(!BoostModel.sharedInstance().hasEverPurchased || BoostModel.sharedInstance().hasEverPurchased == false)
            {
                self.dropOffProductDTOsToBeShown.append(["productDetail":product,"parentPricePerUnit":pricePerUnit, "parentPlanId":planProductId])
                
            }
            break
        case .crush:
            if(!CrushModel.sharedInstance().hasEverPurchased  || CrushModel.sharedInstance().hasEverPurchased == false)
            {
                self.dropOffProductDTOsToBeShown.append(["productDetail":product,"parentPricePerUnit":pricePerUnit, "parentPlanId":planProductId])
                
            }
            break
        case .wooPlus:
            if(!WooPlusModel.sharedInstance().hasEverPurchased || WooPlusModel.sharedInstance().hasEverPurchased == false )
            {
                self.dropOffProductDTOsToBeShown.append(["productDetail":product,"parentPricePerUnit":pricePerUnit, "parentPlanId":planProductId])
                
                
            }
            break
            
        case .wooGlobe:
            if(!WooGlobeModel.sharedInstance().hasEverPurchased || WooGlobeModel.sharedInstance().hasEverPurchased == false )
            {
                self.dropOffProductDTOsToBeShown.append(["productDetail":product,"parentPricePerUnit":pricePerUnit, "parentPlanId":planProductId])
                
                
            }
            break
            
        case .none:
            break
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
            
            if(self.purchaseScreenType == .purchase)
            {
                
                if(self.screenType == .crush)
                {
                    if DiscoverProfileCollection.sharedInstance.collectionMode != .my_PROFILE {
                        let currentNavigation =   WooScreenManager.sharedInstance.oHomeViewController?.children[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
                        if(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 0 || (currentNavigation.viewControllers.last is MyPurchaseViewController) == true)
                            
                        {
                            
                            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
                        }
                        else{
                            DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                                if success{
                                }
                            })
                        }
                    }
                    else{
                        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                            if success{
                            }
                        })
                    }
                }
                else{
                    DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                        if success{
                        }
                    })
                }
                
            }
            else{
                DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                    if success{
                    }
                })
            }
        }
        
    }
    
    @IBAction func screenTappedToRemovePopup(_ sender: AnyObject) {
        WooGlobeModel.sharedInstance().wooGlobePurchaseStarted = false
        
        if(dropOffProductDTOsToBeShown.count > 0)
        {
            if(purchaseDismissedHandler != nil)
            {
                purchaseDismissedHandler(self.screenType,dropOffProductDTOsToBeShown.last!,modelObject!)
            }
        }
        else{
            if popupDismissedHandler != nil{
                popupDismissedHandler()
            }
        }
        self.removeFromSuperview()
         
    }
    
    @IBAction func tnCButtonTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let myWebViewViewController =
            storyboard.instantiateViewController(withIdentifier: kMyWebViewController)
                as? WkWebViewController
        myWebViewViewController?.navTitle = NSLocalizedString("Subscription FAQs", comment: "FAQ web view title")
        myWebViewViewController?.webViewUrl = NSURL(string: "http://www.getwooapp.com/SubscriptionFAQ.html") as URL?
        //        let navController = UINavigationController(rootViewController: myWebViewViewController!)
        if purchaseShownOnViewController != nil {
            self.removeFromSuperview()
            purchaseShownOnViewController?.navigationController?.pushViewController(myWebViewViewController!, animated: true)  //(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton)
    {
        heightConstraint.constant = SCREEN_WIDTH * 1.4062
        self.purchaseScreenType = .purchase
        switch self.screenType
        {
        case .boost:
            subscriptionView.isHidden = true
            BoostProductsAPICalss.makePopupEventAPIwithType("BOOST")
            
            headerLabel.text = NSLocalizedString("Boost Yourself", comment: "boost purchase header")
            
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.57, green: 0.46, blue: 0.86, alpha: 1.0)
            self.backgroundImageView.backgroundColor = UIColor(red: 0.57, green: 0.46, blue: 0.86, alpha: 1.0)
            modelObject = PurchaseProductDetailModel.sharedInstance().boostModel as BoostProductModel
            let boostProducts:BoostProductModel = modelObject as! BoostProductModel
            if (boostProducts.isToShowMostPopular != nil)
            {
                isToShowMostPopular = boostProducts.isToShowMostPopular.boolValue
            }
            if boostProducts.wooProductDto != nil{
                self.productsArray = boostProducts.wooProductDto as NSArray
            }
            
            //base width
            //current width
            let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
            let ratioMultiplier = (window.rootViewController?.view.bounds.size.width)!/320.0
            
            
            //if combo visible or number of packs > 3
            if (boostProducts.comboDto != nil && boostProducts.comboDto.wooProductDto != nil && WooPlusModel.sharedInstance().hasEverPurchased == false && WooPlusModel.sharedInstance().isExpired == true)
            {
                self.comboProductsDto = boostProducts.comboDto as WooGlobalProductModel
                carousalBottomToBgBottomConstraint.constant = 51
                circleImageToTopConstraint.constant = 7 * ratioMultiplier
                circleImageToBottomContraint.constant = 6 * ratioMultiplier
                circleImagetoCarouselHeightConstraint.constant = 0
                heightConstraint.constant = SCREEN_WIDTH * 1.4062
                
            }
            else
            {
                circleImagetoCarouselHeightConstraint.constant = 10
                carousalBottomToBgBottomConstraint.constant = 61
                circleImageToTopConstraint.constant = 7 * ratioMultiplier
                circleImageToBottomContraint.constant = 6 * ratioMultiplier
                if(self.productsArray.count > 3)
                {
                    heightConstraint.constant = SCREEN_WIDTH * 1.4062
                    
                }
                else
                {
                    heightConstraint.constant = SCREEN_WIDTH * 1.30
                }
            }
            
            if (modelObject as! BoostProductModel).carousalType == "IMAGE" {
                self.backgroundImageView.image = nil
                self.circleImageView.image = nil
            }
            else{
                let baseUrlString:String = "\(boostProducts.baseImageUrl!)"
                if(boostProducts.backGroundImages.count > 0)
                {
                    let backGroundImageString: String = baseUrlString + "\(boostProducts.backGroundImages.first!)"
                    self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        self.backgroundImageView.image = image
                    })
                }
                if (modelObject as! BoostProductModel).carousalType == "TEXT" {
                    self.circleImageView.image = nil
                }
                else{
                    let circleImageString: String = baseUrlString + "\((modelObject as! BoostProductModel).circleImage!)"
                    self.circleImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        self.circleImageView.image = image
                    })
                }
            }
            break
        case .crush:
            
            subscriptionView.isHidden = true
            BoostProductsAPICalss.makePopupEventAPIwithType("CRUSH")
            
            headerLabel.text = NSLocalizedString("Get Crushes", comment: "crush purchase header")
            
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.98, green: 0.28, blue: 0.29, alpha: 1.0)
            self.backgroundImageView.backgroundColor = UIColor(red: 0.98, green: 0.28, blue: 0.29, alpha: 1.0)
            
            modelObject = PurchaseProductDetailModel.sharedInstance().crushModel as CrushProductModel
            let crushProducts:CrushProductModel = modelObject as! CrushProductModel
            if (crushProducts.isToShowMostPopular != nil)
            {
                isToShowMostPopular = crushProducts.isToShowMostPopular.boolValue
            }
            if crushProducts.wooProductDto != nil{
                self.productsArray = crushProducts.wooProductDto as NSArray
            }
            
            if (crushProducts.comboDto != nil && crushProducts.comboDto.wooProductDto != nil && WooPlusModel.sharedInstance().hasEverPurchased == false && WooPlusModel.sharedInstance().isExpired == true)
            {
                self.comboProductsDto = crushProducts.comboDto as WooGlobalProductModel
                carousalBottomToBgBottomConstraint.constant = 51
                circleImageToTopConstraint.constant = 7
                circleImageToBottomContraint.constant = 6
                circleImagetoCarouselHeightConstraint.constant = 0
                heightConstraint.constant = SCREEN_WIDTH * 1.4062
                
            }
            else
            {
                carousalBottomToBgBottomConstraint.constant = 61
                circleImageToTopConstraint.constant = 7
                circleImageToBottomContraint.constant = 6
                circleImagetoCarouselHeightConstraint.constant = 10
                if(self.productsArray.count > 3)
                {
                    heightConstraint.constant = SCREEN_WIDTH * 1.4062
                    
                }
                else
                {
                    heightConstraint.constant = SCREEN_WIDTH * 1.30
                }
                
            }
            
            if (modelObject as! CrushProductModel).carousalType == "IMAGE" {
                self.backgroundImageView.image = nil
                self.circleImageView.image = nil
            }
            else{
                let baseUrlString:String = "\((modelObject as! CrushProductModel).baseImageUrl!)"
                if((modelObject as! CrushProductModel).backGroundImages.count > 0)
                {
                    let backGroundImageString: String = baseUrlString + "\((modelObject as! CrushProductModel).backGroundImages.first!)"
                    self.backgroundImageView.sd_setImage(with: URL.init(string: backGroundImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        self.backgroundImageView.image = image
                    })
                }
                if (modelObject as! CrushProductModel).carousalType == "TEXT" {
                    self.circleImageView.image = nil
                }
                else{
                    let circleImageString: String = baseUrlString + "\((modelObject as! CrushProductModel).circleImage!)"
                    self.circleImageView.sd_setImage(with: URL.init(string: circleImageString) as URL?, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, type, imageUrl) in
                        self.circleImageView.image = image
                    })
                }
            }
            break
        default:
            subscriptionView.isHidden = true
            self.headerBackgroundView.backgroundColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0)
            modelObject = nil
            
        }
        self.layoutIfNeeded()
        ////
        self.perform(#selector(addScrollableView), with: nil, afterDelay: 0.2)
        //hide back button
        backButton.isHidden = true
        
        DispatchQueue.main.async {
            self.purchaseTableView.reloadData()
        }
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
}

