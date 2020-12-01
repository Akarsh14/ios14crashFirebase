//
//  BrandCardViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 23/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class BrandCardViewController: UIViewController {

    @IBOutlet weak var backOrCloseButton: UIButton!
    
    @IBOutlet weak var profileDetailTableView: UITableView!
    
    @IBOutlet weak var profileDetailHeaderView: UIView!
    
    @IBOutlet weak var navBarGradientView: UIImageView!
    @IBOutlet weak var navBarImageView: UIImageView!
    
    var brandDeckObject:BrandCardDeck?
    
    var dismissHandler:((String, Bool)->Void)!
/// Brand data model for currently selected profile
    var brandData : BrandCardModel?
/// Array needed for creating profile tableview. Datasource for table view
    fileprivate var userdataArray : NSMutableArray = []
    
    var tableViewWrapperView:UIView?
    
    var YConstraintForProfileDeck:CGFloat = 0
    
    var currentShownImageUrl : String?
    
    var needToMakeGallerySmall:Bool = false
    
    var tempImageView:UIImageView?
    
    var lastheightOfProfileDeckMainContainerView:CGFloat = 0
    
    var allowedToMakeProfileSmall: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.addProfileNow()
        
        self.backOrCloseButton.isSelected = false
        
        if UIScreen.main.bounds.size.height >= 736 {
            YConstraintForProfileDeck = 85
        }
        else{
            YConstraintForProfileDeck = 85
        }
        
        tableViewWrapperView = profileDetailTableView.subviews[1]
        tableViewWrapperView!.alpha = 0
        // preparing data before reloading table
        prepareCellDataFromProfile()
        profileDetailTableView.reloadData()
        if let imageUrlString = brandData?.mediaUrls?.objectAtIndex(0)?.url {
            self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dimissTheScreen()
    {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeDetailViewController(_ sender: UIButton) {
//        if needToMakeGallerySmall == true{
//            brandDeckObject?.imageGalleryView!.removeShadowLayersFromCurrentImage()
//            self.showFullScreenGalleryView(false)
//        }
//        else{
//           // rowValue = -1
            //profileDetailTableView.backgroundColor = UIColor.clear
            self.perform(#selector(nowMoveBackToDiscover), with: nil, afterDelay: 0.0)
       // }
    }
    
    @IBAction func optionButtonTapped(_ sender: UIButton) {
//        let reportAlertcontroller: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel, handler: {(action: UIAlertAction) -> Void in
//            NSLog("Cancel tapped")
//        })
//        let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Report as inappropriate",comment: "Report as inappropriate"), style: .Default, handler: {(action: UIAlertAction) -> Void in
//            self.startReporting(false)
//        })
//        reportAlertcontroller.addAction(cancelAction)
//        reportAlertcontroller.addAction(reportAction)
//        reportAlertcontroller.view!.tintColor = UIColor(red: 232.0 / 255.0, green: 89.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
//        self.presentViewController(reportAlertcontroller, animated: true, completion: {() -> Void in
//            reportAlertcontroller.view!.tintColor = UIColor(red: 232.0 / 255.0, green: 89.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
//        })
    }
    
    /**
     * Prepares the data source for the table view reading from profile data model
     */
    fileprivate func prepareCellDataFromProfile() {
        
        userdataArray.removeAllObjects()
        
        if let brandData = self.brandData
        {
//            if ((brandData.actionUrl) != nil) {
//
//                var actionDictionary = ["type": "ActionButtonTableViewCell", "url" : brandData.actionUrl!]
//                actionDictionary["text"] = brandData.buttonName
//                userdataArray.addObject(actionDictionary as AnyObject)
//            }
            
            if brandData.mutualFriendCount > 0 {
                let mutualFrndDictionary  = ["type": "LabeledTableViewCell", "text" : "\(brandData.mutualFriendCount) of your friends got this"]
                userdataArray.add(mutualFrndDictionary as AnyObject)
            }
            
            if brandData.tags.count > 0 {
                let aboutHeaderDictionary = ["type": "AboutHeaderCell", "subtype": "normal", "text" : "Brands's Tags"]
                let tagsDictionary  = ["type": "BrandTagCell", "subtype": "tag", "data" : brandData.tags] as [String : Any]
                
                userdataArray.add(aboutHeaderDictionary as AnyObject)
                userdataArray.add(tagsDictionary as AnyObject)
            }
            
            if brandData.moreInfo != nil && brandData.moreInfo?.count > 0 {
                let moreInfosHeaderDictionary = ["type": "AboutHeaderCell", "subtype": "normal", "text" : "More Information"]
                let moreInfoInDictionary  = ["type": "LabeledTableViewCell", "text" : "\(brandData.moreInfo!)"]
                userdataArray.add(moreInfosHeaderDictionary as AnyObject)
                userdataArray.add(moreInfoInDictionary as AnyObject)
            }
        }
    }

    fileprivate func addProfileNow(){
        
        var height:CGFloat = 0
        
        var heightToBeCalculated:CGFloat = 0
        
        var yPositionOfBottomLayerContainerViewOrHeight:CGFloat = 188
        
//        if brandData?.subCardType == .WOOGLOBE {
//            yPositionOfBottomLayerContainerViewOrHeight = 150
//        }
//        else{
//            yPositionOfBottomLayerContainerViewOrHeight = 170
//        }
        
        if  (brandData?.buttonName != nil && brandData?.buttonName?.count>0) && (brandData?.cardDescription != nil && brandData?.cardDescription.count>0) {
            let descriptionHeight:CGFloat = heightForView((brandData?.cardDescription)!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320 - 20) + 20 + 65
            heightToBeCalculated = descriptionHeight
        }
        else if (brandData?.buttonName == nil || brandData?.buttonName?.count<=0) && (brandData?.cardDescription != nil && brandData?.cardDescription.count>0){
            let descriptionHeight:CGFloat = heightForView((brandData?.cardDescription)!, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320 - 20) + 15
            heightToBeCalculated = descriptionHeight
        }
        else if (brandData?.cardDescription == nil || brandData?.cardDescription.count<=0) && (brandData?.buttonName != nil && brandData?.buttonName?.count>0) {
            yPositionOfBottomLayerContainerViewOrHeight = 80
            heightToBeCalculated = 60
        }
        else{
            yPositionOfBottomLayerContainerViewOrHeight = 80
            heightToBeCalculated = 0
        }

        height = SCREEN_HEIGHT + heightToBeCalculated - yPositionOfBottomLayerContainerViewOrHeight
        let width:CGFloat = UIScreen.main.bounds.size.width
        
        navBarImageView.snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
        
        profileDetailTableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        
        profileDetailTableView.contentOffset = CGPoint(x: 0, y: -height);
        
        brandDeckObject = BrandCardDeck.init(frame: CGRect(x: 0, y: -height, width: width, height: height))
        
        brandDeckObject?.isOpenedFromBrandDetail = true
        
        brandDeckObject!.brandDetails = brandData
        
        brandDeckObject!.showPurchaseOptions = {() in
            self.openPurchaseScreen()
        }


        profileDetailTableView.isScrollEnabled = false

        brandDeckObject!.profileDeckMainContainerViewLeadingConstraint.constant = 0.0
        brandDeckObject!.profileDeckMainContainerViewTrailingConstraint.constant = 0.0
        brandDeckObject!.setDataForProfileView()
        brandDeckObject?.needToBeShownOrHiddenToBeCompatibleWithProfileDetailView()
        brandDeckObject?.getTappedIndexForGallery =  {(val1: Int) in
            self.closeDetailViewController(self.backOrCloseButton)
//            if self.needToMakeGallerySmall == false{
//                self.showFullScreenGalleryView(true)
//            }
//            else{
//                self.showFullScreenGalleryView(false)
//            }
        }
        profileDetailTableView.backgroundColor = UIColor.white

        self.perform(#selector(nowHideBrandDeckViews), with: nil, afterDelay: 0.7)
        
        profileDetailTableView.addSubview(brandDeckObject!)
        profileDetailTableView.sendSubviewToBack(brandDeckObject!)
    }
    
    func openPurchaseScreen(){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }

        
        if let urlToOpen = self.brandData!.actionUrl {
            
            let urlString = urlToOpen.absoluteString
            
            if (urlString.contains("wooapp://")) {
                
                if (urlString.contains("wooapp://referFriend")){
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let myWebViewViewController =
                        storyboard.instantiateViewController(withIdentifier: kInviteCampaignViewController)
                            as? InviteFriendsSwiftViewController
                    //            myWebViewViewController?.navTitle = NSLocalizedString("FAQs", comment: "FAQ web view title")
                    //            myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().faqUrl
//                    let navController = UINavigationController(rootViewController: myWebViewViewController!)
                    self.navigationController?.pushViewController(myWebViewViewController!, animated: true)
                    //present(navController, animated: true, completion: nil)
                    return
                }
                else if urlString.contains("wooapp://verifyPhoneNumber"){
                    self.dismiss(animated: false, completion: {
                        self.dismissHandler(urlString, false)
                    })
                    return
                }
                
                let window:UIWindow = UIApplication.shared.keyWindow!
                let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                
                if self.brandData?.subCardType == .SEND_CRUSH {
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                }
                else if self.brandData?.subCardType == .GET_BOOSTED || self.brandData?.subCardType == .ACTIVATE_BOOST{
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
                }
                else if self.brandData?.subCardType == .WOOPLUS{
                    purchaseObj.purchaseShownOnViewController = self
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                }
                else if self.brandData?.subCardType == .WOOGLOBE{
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
                }
                
                DiscoverProfileCollection.sharedInstance.comingFromDiscover = false

                purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        if ((self.brandDeckObject?.imageGalleryView) != nil) {
                            self.brandData?.mediaUrls?.moveItemToFront((self.brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                        }
                        self.dismiss(animated: false, completion: {
                            if let localShownImageUrl = self.currentShownImageUrl{
                                self.dismissHandler(localShownImageUrl, true)
                            }
                            else{
                                self.dismissHandler("", true)
                            }
                        })
                }
                purchaseObj.purchaseDismissedHandler = { (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                    let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: window.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                    dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        
                        DispatchQueue.main.async {
                            
                            if (crushPurchased == true) {
                                if ((self.brandDeckObject?.imageGalleryView) != nil) {
                                    self.brandData?.mediaUrls?.moveItemToFront((self.brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                                }
                                self.dismiss(animated: false, completion: {
                                    if let localShownImageUrl = self.currentShownImageUrl{
                                        self.dismissHandler(localShownImageUrl, true)
                                    }
                                    else{
                                        self.dismissHandler("", true)
                                    }
                                })
                                
                            }
                        }
                    }
                    dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                    
                }

            }
            else{
                if UIApplication.shared.canOpenURL(urlToOpen) {
                    // Open url in internal browser
                    let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                    
                    let myWebViewViewController:WkWebViewController = (storyboard.instantiateViewController(withIdentifier: kMyWebViewController) as? WkWebViewController)!
                    
                    myWebViewViewController.navTitle = "Woo Promotions"
                    myWebViewViewController.webViewUrl = urlToOpen
                    self.navigationController?.pushViewController(myWebViewViewController, animated: true)
                    //present(myWebViewViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func showFullScreenGalleryView(_ makeItFull:Bool){
        
        if makeItFull == true {
            brandDeckObject?.badgeView.isHidden = true
            self.needToMakeGallerySmall = true
            self.backOrCloseButton.isSelected = true
            brandDeckObject?.imageGalleryView?.isAllowedToTapNow = false
            createATempImageViewToShowForRemovingFlickerWhileItIsBigOrSmall(false)
            self.perform(#selector(self.needToMakeProfileDeckBig), with: nil, afterDelay: 0.2)
        }
        else{
            brandDeckObject?.badgeView.isHidden = false
            self.backOrCloseButton.isSelected = false
            brandDeckObject?.imageGalleryView?.isAllowedToTapNow = false
            createATempImageViewToShowForRemovingFlickerWhileItIsBigOrSmall(true)
            self.perform(#selector(needToMakeProfileDeckBackToSameSize), with: nil, afterDelay: 0.2)
        }
    }

    fileprivate func createATempImageViewToShowForRemovingFlickerWhileItIsBigOrSmall(_ isItBig:Bool){
        if isItBig == true {
            let height:CGFloat = UIScreen.main.bounds.size.height
            tempImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: (brandDeckObject?.imageGalleryView?.frame.size.width)!, height: height))
            tempImageView!.contentMode = UIView.ContentMode.scaleAspectFill
            tempImageView!.clipsToBounds = true
            tempImageView!.backgroundColor = UIColor.clear
            self.view.addSubview(tempImageView!)
        }
        else{
            var height:CGFloat = 0
            if lastheightOfProfileDeckMainContainerView > 0 {
                height = lastheightOfProfileDeckMainContainerView
            }
            else{
                height = (self.brandDeckObject?.ProfileDeckMainContainerViewHeightConstraint.constant)!
            }
            tempImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: (brandDeckObject?.imageGalleryView?.frame.size.width)!, height: height))
            tempImageView!.contentMode = UIView.ContentMode.scaleAspectFill
            tempImageView!.clipsToBounds = true
            tempImageView!.backgroundColor = UIColor.clear
            self.view.addSubview(tempImageView!)
        }
        if let localurl = self.brandDeckObject!.brandDetails?.mediaUrls?.objectAtIndex((self.brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)?.url {
            let urlStr : String = localurl as String
            if urlStr.count > 0 {
                let placeHolderImageStr:String = "placeholder_male"
               
                self.tempImageView!.sd_setImage(with: URL(string: urlStr as String), placeholderImage: UIImage.init(named: placeHolderImageStr))
            }
        }
    }
    
    @objc fileprivate func needToMakeProfileDeckBig(){
        
        self.view.layoutIfNeeded()
        
        let height:CGFloat = UIScreen.main.bounds.size.height
        
        UIView.animate(withDuration: 0.25, animations: {
            self.tempImageView?.frame.size.height = height
            
        }, completion: { (true) in
            UIView.animate(withDuration: 0.25, animations: {
                self.profileDetailTableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
                self.profileDetailTableView.contentOffset = CGPoint(x: 0, y: -height);
                self.brandDeckObject!.frame.size.height = height
                self.brandDeckObject?.frame.origin.y = -height
                self.brandDeckObject?.imageGalleryView?.frame.size.height = height
                self.brandDeckObject?.imageGalleryView?.imageGalleryCollectionView.frame.size.height = height
                
                self.brandDeckObject?.bottomLayerContainerView.alpha = 0
                self.brandDeckObject?.imageGalleryView?.imageGalleryCollectionView.performBatchUpdates({
                    self.brandDeckObject?.imageGalleryView?.imageGalleryCollectionView.reloadSections(IndexSet(integer:0))
                    }, completion: { (true) in
                        self.tempImageView!.removeFromSuperview()
                })
                
                self.lastheightOfProfileDeckMainContainerView = (self.brandDeckObject?.ProfileDeckMainContainerViewHeightConstraint.constant)!
                
                self.brandDeckObject!.ProfileDeckMainContainerViewHeightConstraint.constant = height
                
                self.perform(#selector(self.updatePageControlYNow), with: nil, afterDelay: 0.0)
                
                self.profileDetailTableView.isScrollEnabled = false
                self.view.layoutIfNeeded()
                self.brandDeckObject?.imageGalleryView?.isAllowedToTapNow = true
            })
        }) 
        
    }
    
    @objc fileprivate func needToMakeProfileDeckBackToSameSize(){
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25, animations: {
            var height:CGFloat = 0
            if (self.brandData?.title == nil || self.brandData?.title?.count<=0) && (self.brandData?.cardDescription == nil || self.brandData?.cardDescription.count<=0){
                height = UIScreen.main.bounds.size.height - self.YConstraintForProfileDeck
            }
            else{
                height = UIScreen.main.bounds.size.height
            }
            self.profileDetailTableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
            self.profileDetailTableView.contentOffset = CGPoint(x: 0, y: -height);
            self.brandDeckObject!.frame.size.height = height
            self.brandDeckObject?.frame.origin.y = -height
            self.brandDeckObject?.imageGalleryView?.frame.size.height = self.lastheightOfProfileDeckMainContainerView
            self.brandDeckObject?.imageGalleryView?.imageGalleryCollectionView.frame.size.height = self.lastheightOfProfileDeckMainContainerView
            self.tempImageView?.frame.size.height = self.lastheightOfProfileDeckMainContainerView
            
            self.brandDeckObject?.imageGalleryView?.imageGalleryCollectionView.performBatchUpdates({
                self.brandDeckObject?.imageGalleryView?.imageGalleryCollectionView.reloadSections(IndexSet(integer:0))
                }, completion: { (true) in
                    self.tempImageView!.removeFromSuperview()
            })
            self.brandDeckObject!.ProfileDeckMainContainerViewHeightConstraint.constant = self.lastheightOfProfileDeckMainContainerView
            
            self.perform(#selector(self.updatePageControlYNow), with: nil, afterDelay: 0.0)
            
            self.brandDeckObject?.bottomLayerContainerView.alpha = 1
            self.profileDetailTableView.isScrollEnabled = true
            self.needToMakeGallerySmall = false
            self.view.layoutIfNeeded()
            
        }, completion: { (true) in
            self.brandDeckObject?.imageGalleryView?.isAllowedToTapNow = true
        }) 
    }
    
    @objc fileprivate func updatePageControlYNow(){
        brandDeckObject?.imageGalleryView?.pageControlObj.removeFromSuperview()
        brandDeckObject?.imageGalleryView?.createAddPageControlNow(withFrame: (brandDeckObject?.ProfileDeckMainContainerViewHeightConstraint.constant)! - 45, with: (brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.brandDeckObject?.imageGalleryView?.pageControlObj.alpha = 1
        }) 
    }

    @objc func nowHideBrandDeckViews(){
        profileDetailTableView.isScrollEnabled = true
        //brandDeckObject?.topView.alpha = 0
       // brandDeckObject?.bottomView.alpha = 0
    }
    
    @objc func nowMoveBackToDiscover(){
        if brandData != nil {
            if brandData?.mediaUrls != nil {
                if ((self.brandDeckObject?.imageGalleryView) != nil) {
                    self.brandData?.mediaUrls?.moveItemToFront((self.brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                }
            }
        }
        if let localShownImageUrl = self.currentShownImageUrl{
            self.dismissHandler(localShownImageUrl, false)
        }
        else{
            self.dismissHandler("", false)
        }
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: false, completion: {
//            
//        })
        
    }
    
    //MARK: Cell Creating Methods
    func createAboutMeCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AboutMeCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutMeCell)!
        
        if cell == nil {
            cell = AboutMeCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.setAboutMeText(cellData["text"] as! String)
        return cell!
    }
    
    func createAboutHeaderCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        let subType = cellData["subtype"] as! String
        var cell : AboutHeaderCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AboutHeaderCell)!
        
        if cell == nil {
            cell = AboutHeaderCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        if subType == "question" {
            cell?.contentView.backgroundColor = UIColor(red: 244.0/256.0, green: 244.0/256.0, blue: 244.0/256.0, alpha: 244.0/244.0)
        }
        else{
            cell?.contentView.backgroundColor = UIColor.white
        }
        
        cell!.setHeaderText(cellData["text"] as! String)
        return cell!
    }
    
    func createLabeledCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : LabeledTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? LabeledTableViewCell)!
        
        if cell == nil {
            cell = LabeledTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.cellTextLabel?.htmlText = cellData["text"] as? String
        // add data
        return cell!
    }
    
    func createActionButtonTableViewCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : ActionButtonTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ActionButtonTableViewCell)!
        
        if cell == nil {
            cell = ActionButtonTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.button?.setTitle(cellData["text"] as? String, for: UIControl.State())
        cell?.urlToOpen = cellData["url"] as? URL
        cell?.tapHandler = {(urlString) in
            
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            
            if urlString.contains("wooapp://") {
                
                if (urlString.contains("wooapp://referFriend")){
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let myWebViewViewController =
                        storyboard.instantiateViewController(withIdentifier: kInviteCampaignViewController)
                            as? InviteFriendsSwiftViewController
                    //            myWebViewViewController?.navTitle = NSLocalizedString("FAQs", comment: "FAQ web view title")
                    //            myWebViewViewController?.webViewUrl = AppLaunchModel.sharedInstance().faqUrl
//                    let navController = UINavigationController(rootViewController: myWebViewViewController!)
                    self.navigationController?.pushViewController(myWebViewViewController!, animated: true)
                    //present(navController, animated: true, completion: nil)
                    return
                }

                
                let window:UIWindow = UIApplication.shared.keyWindow!
                let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                
                
                if self.brandData?.subCardType == .SEND_CRUSH {
                    purchaseObj.initiatedView = "Crush_Brandcard"
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Crush_Brandcard")
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .crush)
                }
                else if self.brandData?.subCardType == .GET_BOOSTED || self.brandData?.subCardType == .ACTIVATE_BOOST{
                    purchaseObj.initiatedView = "Boost_brandcard"
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "Boost_brandcard")
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .boost)
                }
                else if self.brandData?.subCardType == .WOOPLUS{
                    purchaseObj.purchaseShownOnViewController = self
                    purchaseObj.initiatedView = "WP_brandcard"
                    (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "WP_brandcard")
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                }
                else if self.brandData?.subCardType == .WOOGLOBE{
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
                }
                
                DiscoverProfileCollection.sharedInstance.comingFromDiscover = false

                purchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        if ((self.brandDeckObject?.imageGalleryView) != nil) {
                            self.brandData?.mediaUrls?.moveItemToFront((self.brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                        }
                        self.dismiss(animated: false, completion: {
                            if let localShownImageUrl = self.currentShownImageUrl{
                                self.dismissHandler(localShownImageUrl, true)
                            }
                            else{
                                self.dismissHandler("", true)
                            }
                        })
                }
                
                purchaseObj.purchaseDismissedHandler = { (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                    let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: window.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                    dropOffPurchaseObj.purchasedHandler = {(crushPurchased:Bool) in
                        
                        DispatchQueue.main.async {
                            
                            
                            if ((self.brandDeckObject?.imageGalleryView) != nil)
                            {
                                self.brandData?.mediaUrls?.moveItemToFront((self.brandDeckObject?.imageGalleryView?.getCurrentImageIndex())!)
                            }
                            self.dismiss(animated: false, completion: {
                                if let localShownImageUrl = self.currentShownImageUrl{
                                    self.dismissHandler(localShownImageUrl, true)
                                }
                                else{
                                    self.dismissHandler("", true)
                                }
                            })
                        }
                    }
                    dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                    
                }

            }else{
                
                // This code is added to open url in internal browser
                // Open url in internal browser
                let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                
                let myWebViewViewController:WkWebViewController = (storyboard.instantiateViewController(withIdentifier: kMyWebViewController) as? WkWebViewController)!
                
                myWebViewViewController.navTitle = ""
                myWebViewViewController.webViewUrl = cell?.urlToOpen as URL?
                 self.navigationController?.pushViewController(myWebViewViewController, animated: true)
//                self.present(myWebViewViewController, animated: true, completion: nil)

            }
        }
        return cell!
    }
    
    func createTagCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : BrandTagCell? = (tableView.dequeueReusableCell(withIdentifier: "BrandTagCell") as? BrandTagCell)!
        
        if cell == nil {
            cell = BrandTagCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.tagArray = cellData["data"] as? [BrandCardTagModel]
        cell?.tapHandler = {() in
            self.openPurchaseScreen()
        }
        return cell!
    }
    
//MARK: Utility Methods
    /**
     * Calculates the height of a lable for given text
     * - parameter text : Given text
     * - parameter font : Font for the given text
     * - parameter width : Width of the label
     * - returns: Height for the given text
     */
    fileprivate func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func sizeForView(_ text:String, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 30 , height: height)
    }
    
    func calculateTagCellHeight(_ array:[BrandCardTagModel]) -> CGFloat {
        var height : CGFloat = 0.0
        let font = UIFont(name: "Lato-Regular", size: 14.0)!
        var rowWidth : CGFloat = 10.0
        var numberOfRows  : CGFloat = 1.0
        for model in array {
            let tagWidth = sizeForView(model.name!, font: font, height: 32.0).width
            rowWidth = rowWidth + tagWidth + 10
            if rowWidth > (profileDetailTableView.frame.width - 40) {
                rowWidth = 10.0 + tagWidth
                numberOfRows += 1
            }
        }
        height = numberOfRows * 32.0 + 10.0 * (numberOfRows + 1)
        return height
    }
}

//MARK: UITableViewDataSource
extension BrandCardViewController: UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userdataArray.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let cell : UITableViewCell
        
        UIView.animate(withDuration: 0.25, animations: {
            self.tableViewWrapperView!.alpha = 1
        })
        
        switch cellDictionary["type"] as! String {
        case "AboutHeaderCell":
            cell = self.createAboutHeaderCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case "LabeledTableViewCell":
            cell = self.createLabeledCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case "ActionButtonTableViewCell":
            cell = self.createActionButtonTableViewCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case "BrandTagCell" :
            cell = self.createTagCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        default:
            cell = UITableViewCell()
            break
        }
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension BrandCardViewController: UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let cellDictionary = userdataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        var height : CGFloat = 44.0
        switch cellDictionary["type"] as! String {
        case "AboutHeaderCell":
            height = 48.0
            break
        case "LabeledTableViewCell":
            let text = cellDictionary["text"] as! String
            height = heightForView(text, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: 320.0) + 20.0
            break
        case "ActionButtonTableViewCell":
            height = 60.0
            break
        case "BrandTagCell" :
            height = self.calculateTagCellHeight((cellDictionary["data"] as? [BrandCardTagModel])!)
            break
        default:
            height = 44.0
            break
        }
        
        return height
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.size.width,height: 20))
        view.backgroundColor = UIColor.white
        return view
    }
    
}

extension BrandCardViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        allowedToMakeProfileSmall = true
        
        if scrollView.contentOffset.y >= -64.0 {
            navBarImageView.isHidden = false
        }
        else{
            navBarImageView.isHidden = true
            if self.brandDeckObject != nil {
                if let imageUrlString = self.brandData?.mediaUrls?.objectAtIndex(0)?.url {
                    self.navBarImageView.sd_setImage(with: URL(string: imageUrlString))
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        allowedToMakeProfileSmall = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("end contentOffsety=\(scrollView.contentOffset.y), profileDeckObject=\(brandDeckObject?.frame.size.height)")
        
        if allowedToMakeProfileSmall == true {
            if let heightValue = brandDeckObject?.frame.size.height {
                if scrollView.contentOffset.y == -heightValue {
                    self.closeDetailViewController(UIButton())
                }
            }
        }
    }
}
