//
//  SideDrawerViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum FooterType {
    case boost
    case crush
    case woo_PLUS
    
    func color() -> UIColor {
        switch self {
        case .boost:
            return UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case .woo_PLUS:
            return UIColor(red: 117.0/255.0, green: 219.0/255.0, blue: 135.0/255.0, alpha: 1.0)
        case .crush:
            return UIColor(red: 245.0/255.0, green: 47.0/255.0, blue: 57.0/255.0, alpha: 1.0)
        }
    }
    
    func textcColor() -> UIColor {
        switch self {
        case .boost:
            return UIColor.white
        case .woo_PLUS:
            return UIColor(red: 55.0/255.0, green: 58.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        case .crush:
            return UIColor.white
        }
    }
    
    func footerIcon() -> UIImage {
        switch self {
        case .boost:
            return UIImage(named: "ic_left_menu_boost")!
        case .crush:
            return UIImage(named: "ic_left_menu_crush")!
        case .woo_PLUS:
            return UIImage(named: "ic_left_menu_woo_plus")!
        }
    }
    
    func text() -> String {
        switch self {
        case .boost:
            if let boostText = AppLaunchModel.sharedInstance().leftPanelAdsText["boostText"] {
                return boostText as! String
            }
            else{
                return ""
            }
        case .woo_PLUS:
            if let wooPlusText = AppLaunchModel.sharedInstance().leftPanelAdsText["wooPlusText"] {
                return wooPlusText as! String
            }
            else{
                return ""
            }
        case .crush:
            if let crushText = AppLaunchModel.sharedInstance().leftPanelAdsText["crushText"] {
                return crushText as! String
            }
            else{
                return ""
            }
        }
    }
}

enum SidePanelAction {
    case me
    case myPreference
    case myPurchases
    case invitation
    case feedback
    case referFriend
    case faq
    case tnC
    case guidelines
    case femaleTutorial
    case wooTrueStory
    case none
}



class SideBarCellData: NSObject {
    var image : String?
    var text : String?
    var isTagNeeded = false
    var tagValue : String?
    var gaEvent : String?
    var action : SidePanelAction = .none
    func setData(_ _image: String?, _text:String, _gaEvent : String?, _action : SidePanelAction) {
        image = _image
        text = NSLocalizedString(_text, comment: "")
        gaEvent = _gaEvent
        action = _action
    }
}

let CellIdentifier: String = "SidePanelCell"

let kLeftPanelCellsTextFont = UIFont(name: "Lato-Regular", size: 14.0)

let kNavBarButtonFont = UIFont(name: "Lato-Regular", size: 12.0)

class SideDrawerViewController: UIViewController {
    
    @IBOutlet weak var matchTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var matchTableView: UITableView!
    
    @IBOutlet weak var footerPanel: UIView!
    
    @IBOutlet weak var footerPanelIcon: UIImageView!
    
    @IBOutlet weak var footerPanelLabel: UILabel!
    
    
    @IBOutlet weak var iconTrailingConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var textWidthConstrain: NSLayoutConstraint!
    
    var isFemale: Bool?
    
    var leftDrawerDataSource : [SideBarCellData] = []
    
    var footerDataSource : [FooterType] = []
    
    var footerIndexCounter = -1
    
    var analyzeProfileShown = false
    var drawLineAfterIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFooterData()
        matchTableView.estimatedRowHeight = 150.0
        
        
        if  (DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"){
            isFemale = true
            drawLineAfterIndex = 3
        }else{
            isFemale = false
            drawLineAfterIndex = 4
        }
        
        matchTableView.rowHeight = UITableView.automaticDimension
        
        WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.didChange.addHandler(self, handler: SideDrawerViewController.didTabViewChanged)
        self.matchTableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        
        textWidthConstrain.constant = 310 - self.view.bounds.size.width/5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NavBar_Landing")
        super.viewWillAppear(animated)
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11"){
        matchTableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        }
        
        if #available(iOS 11.0, *) {
            if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                matchTableViewTopConstraint.constant = 0.0
            }
        }
        matchTableView.reloadData()
        reloadFooterView()
    }
    
    //MARK: IBAction Method
    
    @IBAction func footerButtonTapped(_ sender: AnyObject) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        if footerIndexCounter != -1 {
            var index = -1
            if footerIndexCounter == 0 {
                index = footerDataSource.count - 1
            }
            else{
                index = footerIndexCounter - 1
            }
            let footerType = footerDataSource[index]
            switch footerType {
            case .boost:
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NB_BoostAd_Tap")
                WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromSideMenu = true
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseBoost)
            case .crush:
             // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NB_CrushAd_Tap")
                WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromSideMenu = true
              WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseCrush)
            case .woo_PLUS:
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NB_WPAd_Tap")
                WooScreenManager.sharedInstance.oHomeViewController?.isOpenedFromSideMenu = true
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.PurchaseWooPlus)
                WooScreenManager.sharedInstance.oHomeViewController?.showTabBar(true)
            }
           // WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(3)
        }
    }
    
    
    //MARK: Private methods
    func configureDataSource() {
        
        leftDrawerDataSource.removeAll()
        
        //Me
        let meData = SideBarCellData()
        meData.setData("ic_leftmenu_me", _text: NSLocalizedString("Me", comment: ""), _gaEvent: "SideMenu.Me", _action: .me)
        leftDrawerDataSource.append(meData)
        
        //My Preference
        let myPreferenceData = SideBarCellData()
        myPreferenceData.setData("ic_left_menu_preferences", _text: NSLocalizedString("Settings", comment: ""), _gaEvent: "SideMenu.MyPreference", _action: .myPreference)
        leftDrawerDataSource.append(myPreferenceData)
        
        //My Purchase
        let myPurchases = SideBarCellData()
        myPurchases.setData("ic_leftmenu_purchase", _text: NSLocalizedString("My Purchases", comment: ""), _gaEvent: "SideMenu.MyPurchases", _action: .myPurchases)
            leftDrawerDataSource.append(myPurchases)
    
        // Tutorial Enabled
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
            let tutorialData = SideBarCellData()
            tutorialData.setData(nil, _text: "Woo Secret", _gaEvent: "SideMenu.FemaleTutorial", _action: .femaleTutorial)
            leftDrawerDataSource.append(tutorialData)
        }
        
        //Woo True Story
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
        let trueStoryData = SideBarCellData()
        trueStoryData.setData(nil, _text: "Woo True Stories", _gaEvent: "SideMenu.wooTrueStory", _action: .wooTrueStory)
        leftDrawerDataSource.append(trueStoryData)
        }
        
        
        //Invite
        let inviteCellData = SideBarCellData()
        inviteCellData.setData((isFemale!) ? nil : "ic_leftmenu_free_crushes"  , _text: (isFemale!) ? "Invite Friends" : "Free Crushes"   , _gaEvent: "SideMenu.Invite", _action: .invitation)
        leftDrawerDataSource.append(inviteCellData)
       
        let cellData = SideBarCellData()
        if AppLaunchModel.sharedInstance().inviteOnlyEnabled {
            cellData.setData(nil, _text: "CMP00327", _gaEvent: "SideMenu.Invite", _action: .invitation)
            leftDrawerDataSource.append(cellData)

        }
        
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE"{
            let trueStoryData = SideBarCellData()
            trueStoryData.setData(nil, _text: "Woo True Stories", _gaEvent: "SideMenu.wooTrueStory", _action: .wooTrueStory)
            leftDrawerDataSource.append(trueStoryData)
        }

        
//        if (DiscoverProfileCollection.sharedInstance.myProfileData?.gender != "FEMALE" && AppLaunchModel.sharedInstance().isCallingEnabled)
//        {
//            leftDrawerDataSource.remove(object:inviteCellData)
//        }
//        
        // Feedback Enabled
        let feedbackCellData = SideBarCellData()
        feedbackCellData.setData(nil, _text: "Feedback", _gaEvent: "SideMenu.Feedback", _action: .feedback)
        leftDrawerDataSource.append(feedbackCellData)

        
        
        // FAQ Enabled
        let faqCellData = SideBarCellData()
        faqCellData.setData(nil, _text: "faq", _gaEvent: "SideMenu.FAQ", _action: .faq)
        leftDrawerDataSource.append(faqCellData)
        
        // T&C Enabled
        let tncCellData = SideBarCellData()
        tncCellData.setData(nil, _text: "Privacy & Terms", _gaEvent: "SideMenu.TnC", _action: .tnC)
        leftDrawerDataSource.append(tncCellData)
        
        // Guidelines Enabled
        let guideLineData = SideBarCellData()
        guideLineData.setData(nil, _text: "Guidelines", _gaEvent: "SideMenu.GuideLines", _action: .guidelines)
        leftDrawerDataSource.append(guideLineData)
    }
    
    func prepareFooterData(){
        footerDataSource.removeAll()
        if BoostModel.sharedInstance().availableInRegion == true &&
            BoostModel.sharedInstance().checkIfUserNeedsToPurchase() == true && DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE" {
            footerDataSource.append(.boost)
        }
        if CrushModel.sharedInstance().availableInRegion == true &&
            CrushModel.sharedInstance().checkIfUserNeedsToPurchase() == true{
            footerDataSource.append(.crush)
        }
        if WooPlusModel.sharedInstance().availableInRegion == true && WooPlusModel.sharedInstance().isExpired == true{
            footerDataSource.append(.woo_PLUS)
        }
        
        if footerDataSource.count == 0 {
            footerIndexCounter = -1
        }
        else{
            footerIndexCounter = 0
        }
        reloadFooterView()
    }
    
    func reloadFooterView() {
        
        if footerIndexCounter < 0 {
            if footerPanel != nil {
            footerPanel.isHidden = true
            }
        }
        else{
            if footerPanel != nil {
                footerPanel.backgroundColor = footerDataSource[footerIndexCounter].color()
            }
            if footerPanelIcon  != nil {
                footerPanelIcon.image = footerDataSource[footerIndexCounter].footerIcon()
            }
            if footerPanelLabel  != nil {
                footerPanelLabel.textColor = footerDataSource[footerIndexCounter].textcColor()
                footerPanelLabel.text = footerDataSource[footerIndexCounter].text()
            }
            
            if footerIndexCounter == footerDataSource.count - 1 {
                footerIndexCounter = 0
            }
            else{
                footerIndexCounter += 1
            }
        }
    }
    
    func didTabViewChanged(_ tupleValue:(oldValue: Int, newValue: Int)) {
        if tupleValue.newValue == 3  && WooScreenManager.sharedInstance.isDrawerOpen {
            self.matchTableView.reloadData()
            reloadFooterView()
        }
    }
    
    func checkForSugessionText() -> String {
        var text = ""
        if AppLaunchModel.sharedInstance().leftPanelSuggestions != nil &&
            AppLaunchModel.sharedInstance().leftPanelSuggestions.count > 0 {
            
            let position = WooScreenManager.sharedInstance.drawerRoundRobinCounter
            
            if AppLaunchModel.sharedInstance().leftPanelSuggestions != nil &&
                AppLaunchModel.sharedInstance().leftPanelSuggestions.count > position {
                
                if let dto = AppLaunchModel.sharedInstance().leftPanelSuggestions[position] as? [String : String] {
                    text = (dto["text"])!
                }
                else{
                    let textName = AppLaunchModel.sharedInstance().leftPanelSuggestions[position]
                    text = textName as! String
                }
                if AppLaunchModel.sharedInstance().leftPanelSuggestions.count > position+1 {
                    WooScreenManager.sharedInstance.drawerRoundRobinCounter += 1
                }
                else{
                    WooScreenManager.sharedInstance.drawerRoundRobinCounter = 0
                }
            }
        }
        return text
    }
    
    func getUrlString() -> String{
        var text = ""
        if AppLaunchModel.sharedInstance().leftPanelSuggestions != nil &&
            AppLaunchModel.sharedInstance().leftPanelSuggestions.count > 0 {
            
            let position = WooScreenManager.sharedInstance.drawerRoundRobinCounter
            
            if AppLaunchModel.sharedInstance().leftPanelSuggestions != nil &&
                AppLaunchModel.sharedInstance().leftPanelSuggestions.count > position {
                
                if let dto = AppLaunchModel.sharedInstance().leftPanelSuggestions[position] as? [String : String] {
                    text = (dto["url"])!
                }
                else{
                    let textName = AppLaunchModel.sharedInstance().leftPanelSuggestions[position]
                    text = textName as! String
                }
            }
        }
        return text
    }
}

//MARK: TableView DataSource methods
extension SideDrawerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leftDrawerDataSource.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        self.configureDataSource()
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let identifier = "MyProfileCellId"
            
            let cell: MyProfileSidePanelCell? = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MyProfileSidePanelCell
//            if cell == nil {
//                cell = MyProfileSidePanelCell(style: .default, reuseIdentifier: CellIdentifier)
//            }
            cell?.selectionStyle = .none
            cell?.setData()
            cell?.imageButtonHandler = {
                if Utilities().reachable() == true {
                    let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                    controller.dismissHandler = { (needToOpenMyProfile, toClose) in
                        if needToOpenMyProfile {
                            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                            let myProfileDPV =
                                storyboard.instantiateViewController(withIdentifier: "ProfileDeckDetailViewControllerID")
                                    as? ProfileDeckDetailViewController
                            myProfileDPV?.profileData = DiscoverProfileCollection.sharedInstance.myProfileData! as ProfileCardModel
                            myProfileDPV?.isMyProfile = true
                            WooScreenManager.sharedInstance.oHomeViewController!.present(myProfileDPV!, animated: false, completion: nil)
                        }
                    }
                    
//                    let navController = UINavigationController(rootViewController: controller)
//                    self.present(navController, animated: true, completion: nil)
//                    let currentNavigation =  WooScreenManager.sharedInstance.oHomeViewController?.childViewControllers[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
//                    currentNavigation.pushViewController(controller, animated: true)
//
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(3)
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.EditProfile)

                }
            }
            cell?.editButtonHandler = {(buttonName:String) in
                if Utilities().reachable() == true {
                    if buttonName == kSideMenuAnalyzeProfileButtonText{
                        WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.AnalyzeProfile)
                        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "NavBar_Analyze_Tap")

                    }
                    else{
                    let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                    controller.dismissHandler = { (needToOpenMyProfile, toClose) in
                        if needToOpenMyProfile {
                            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                            let myProfileDPV =
                                storyboard.instantiateViewController(withIdentifier: "ProfileDeckDetailViewControllerID")
                                    as? ProfileDeckDetailViewController
                            myProfileDPV?.profileData = DiscoverProfileCollection.sharedInstance.myProfileData! as ProfileCardModel
                            myProfileDPV?.isMyProfile = true
                            WooScreenManager.sharedInstance.oHomeViewController!.present(myProfileDPV!, animated: false, completion: nil)
                        }
                    }
                    
//                    let navController = UINavigationController(rootViewController: controller)
//                    self.present(navController, animated: true, completion: nil)
//                    WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
//                    let currentNavigation =  WooScreenManager.sharedInstance.oHomeViewController?.childViewControllers[(WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get())!] as! UINavigationController
//                    currentNavigation.pushViewController(controller, animated: true)
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(3)
                    
                    WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.EditProfile)
                    }

                }else{
                    showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    return
                }
            }
            cell?.tipsButtonHandler = {
                
                if !(Utilities.sharedUtility() as AnyObject).reachable() {
                    showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                    return
                }

                var index = WooScreenManager.sharedInstance.drawerRoundRobinCounter
                if index == 0 {
                    index = AppLaunchModel.sharedInstance().leftPanelSuggestions.count - 1
                }
                else{
                    index -= 1
                }
                
                if AppLaunchModel.sharedInstance().leftPanelSuggestions.count <= index {
                    index = AppLaunchModel.sharedInstance().leftPanelSuggestions.count - 1
                }
                
                let dto = (AppLaunchModel.sharedInstance().leftPanelSuggestions[index] as? [String : String])!
                if let url = dto["url"] {
                    if url.count > 0 {
                        WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(3)
                        WooScreenManager.sharedInstance.openDeepLinkedScreen(url)
                    }
                }
            }
            //
//            var index = WooScreenManager.sharedInstance.drawerRoundRobinCounter
//            if index == 0 {
//                index = AppLaunchModel.sharedInstance().leftPanelSuggestions.count - 1
//            }
//            else{
//                index -= 1
//            }
//            
//            if AppLaunchModel.sharedInstance().leftPanelSuggestions.count <= index {
//                index = AppLaunchModel.sharedInstance().leftPanelSuggestions.count - 1
//            }
//            let dto = (AppLaunchModel.sharedInstance().leftPanelSuggestions[index] as? [String : String])!
//            if let url = dto["url"]{
//                cell?.setEditButtonImageBasedOnUrl(urlString: url)
//            }
            //
            var completenessScore = 0
            if let score = DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore{
                completenessScore = Int(score)!
            }
            if  completenessScore > AppLaunchModel.sharedInstance().profileCompletenessScoreThreshold{
                cell?.setEditButtonImageBasedOnUrl(urlString: getUrlString())
                cell?.tipslabel.text = checkForSugessionText()
                analyzeProfileShown = false
            }
            else{
            if analyzeProfileShown == false{
                
                if let analyzeData = AppLaunchModel.sharedInstance().analyzeProfileDto{
                        cell?.setEditButtonImageBasedOnUrl(urlString: (analyzeData as NSDictionary).object(forKey: "cta") as! String)
                    if (analyzeData as NSDictionary).object(forKey: "text") != nil && !((analyzeData as NSDictionary).object(forKey: "text") is NSNull){
                        cell?.tipslabel.text = ((analyzeData as NSDictionary).object(forKey: "text") as! String)
                    }
                }
                else{
                    cell?.setEditButtonImageBasedOnUrl(urlString: getUrlString())
                    cell?.tipslabel.text = checkForSugessionText()
                }
                analyzeProfileShown = true
            }
            else{
                cell?.setEditButtonImageBasedOnUrl(urlString: getUrlString())
                cell?.tipslabel.text = checkForSugessionText()
                analyzeProfileShown = false
            }
            }
            cell?.contentView.setNeedsLayout()
            cell?.layoutIfNeeded()
            return cell!
        }
        else {
            let identifier = "ImageTextCellId"
            
            var cell: ImageTextSidePanelCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? ImageTextSidePanelCell
            if cell == nil {
                cell = ImageTextSidePanelCell(style: .default, reuseIdentifier: CellIdentifier)
            }
            let cellData = leftDrawerDataSource[(indexPath as NSIndexPath).row - 1]
            cell?.optionTextLabel.textColor = UIColorHelper.color(withRGBA: "#72778A")
            if cellData.action == .femaleTutorial{
                cell?.optionTextLabel.textColor = UIColorHelper.color(withRGBA: "#35A8CA")
            }
            cell?.setData(cellData.text!, optionIcon: cellData.image)
            if (indexPath as NSIndexPath).row == drawLineAfterIndex {
                cell?.showLine(true)
            }else{
                cell?.showLine(false)
            }
                return cell!}
        }
    }



func showSnackBar(_ text:String){
    let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
    snackBarObj.multiline = true
    snackBarObj.show()
}



//MARK: TableView Delegate methods
extension SideDrawerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return UITableView.automaticDimension
        }
        else if((indexPath as NSIndexPath).row > 0 && (indexPath as NSIndexPath).row < drawLineAfterIndex+1){
            return 60.0
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if (indexPath as NSIndexPath).row > 0 {
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(3)
            let cellData = leftDrawerDataSource[(indexPath as NSIndexPath).row - 1]
            switch cellData.action {
            case .me:
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
                
                break
            case .myPreference:
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.Settings)
            
                break
            case .myPurchases:
                
                // Srwve Event
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NB_MyPurchases_Tap")

                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.MyPurchase)
            
                break
            case .invitation:
                
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NB_Invite_Tap")

                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.InviteCampaign)
            
                break
            case .feedback:
            
                (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "NavBar", withEventName: "3-VerticalNavBar.NavBar.NB_Feedback_Tap")

                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.Feedback)

            break
                
            case .referFriend:
                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.ReferFriend);
                
                break;
                
            case .faq:
                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.MyWebViewFAQ)

            
                break
            case .tnC:
                
                 WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.MyWebViewTC)

            
                break
                
            case .guidelines:
                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(DeepLinkingOptions.Content_Guidelines)
                
                
                break
                
            case .femaleTutorial:
                
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.FemaleTutorial)
                break
            case .none :
                
                break
            case .wooTrueStory:
                WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.Woo_TrueStory)
            }
        }
    }
}
