//
//  MyPreferencesViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
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


enum MyPreferencesCellType : String{
    case AppSettingsNotificationTableViewCell            = "AppSettingsNotificationTableViewCell"
    case AppSettingsSoundTableViewCell                   = "AppSettingsSoundTableViewCell"
    case AppSettingsFeedbackTableViewCell                = "AppSettingsFeedbackTableViewCell"
    case AppSettingsSocialTableViewCell                  = "AppSettingsSocialTableViewCell"
    case AppSettingsAccountTableViewCell                 = "AppSettingsAccountTableViewCell"
    case DiscoverSettingsLocationTableViewCell           = "DiscoverSettingsLocationTableViewCell"
    case SettingsLocationPrefCell                        = "SettingsLocationPrefCell"
    case DiscoverSettingsMultipleCitiesTableViewCell     = "DiscoverSettingsMultipleCitiesTableViewCell"
    case DiscoverSettingsAgeTableViewCell                = "DiscoverSettingsAgeTableViewCell"
    case NewDiscoverSettingsAgeTableViewCell                = "NewDiscoverSettingsAgeTableViewCell"
    
    case DiscoverSettingsGenderTableViewCell             = "DiscoverSettingsGenderTableViewCell"
    case AppSettingsWooGlobeTableViewCell                = "AppSettingsWooGlobeTableViewCell"
    case SettingShowLocationTableViewCell                = "SettingShowLocationTableViewCell"
    case GoGlobeSettingTableViewCell                     =
        "GoGlobeSettingTableViewCell"
}

enum AppSettingsNotificationType : String{
    case MatchAndChat            = "MatchAndChat"
    case CrushRecieved           = "CrushRecieved"
    case QuestionsAndAnswers     = "QuestionsAndAnswers"
}

enum AppSettingsSocialType : String{
    case ReviewOnAppstore        = "ReviewOnAppstore"
    case LikeOnFacebook          = "LikeOnFacebook"
    case FollowWoo               = "FollowWoo"
}

enum AppSettingsAccountType : String{
    case Logout                  = "Logout"
    case DisableAccount          = "DisableAccount"
}




class MyPreferencesViewController: BaseClassViewController {
     var successHandler : ((Bool)->())?
    typealias onResponseReceived = (_ isSuccess:Bool)->Void
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var myPreferencesTableView: UITableView!
    var isComingFromMatchbox = false
    fileprivate var myPreferencesDataArray : NSMutableArray = []
    fileprivate var containerView:UIView?
    fileprivate var feedbackAlertViewObj:U2AlertView?
    fileprivate var feedbackTextviewObj:UITextView?
    fileprivate var placeholderLabel:UILabel?
    
    var locationManager: LocationManager? = LocationManager()
    var savedDate:Date?
    var isOpenedFromMyProfile = false
    
    var showPostWooGlobePurchasePopUp = false
    
    var customLoader:WooLoader?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.me, animated: false)
        self.navBar?.setTitleText("Settings")
        //self.navigationController?.navigationBarHidden = true;
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(MyPreferencesViewController.backButtonTapped))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall = false
        let attr = NSDictionary(object: UIFont(name: "Lato-Bold", size: 12.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateWooGlobeExpiredValue"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name(rawValue: "updateWooGlobeExpiredValue"), object: nil)
        
        if showPostWooGlobePurchasePopUp == false {
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
        }
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
        
    }
    
    @objc func dimissTheScreen()
    {
        NSLog("dimissTheScreen MyPreferences");
        dismiss(animated: false, completion: nil)
    }
    
    @objc func reloadTableData() {
        myPreferencesTableView.reloadData()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colorTheStatusBar(withColor: NavBarStyle.me.color())
        prepareCellDataForMyPreferences()
        myPreferencesTableView.reloadData()
        if showPostWooGlobePurchasePopUp == true {
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Start Globetrotting", comment: ""),
                                                             message: NSLocalizedString("Set your preferences under Woo Globe to get started.", comment:""),
                                                             preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .cancel, handler:{ (ok) in
                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "isWooGlobePopUpShownToUser")
            showPostWooGlobePurchasePopUp = false
        }
        else{
        }
        
        if WooGlobeModel.sharedInstance().isExpired == false {
            UserDefaults.standard.set(true, forKey: "isWooGlobePopUpShownToUser")
            UserDefaults.standard.synchronize();
        }
        
    }
    
    @objc func backButtonTapped(){
        
        if AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall == true {
            AppLaunchModel.sharedInstance().needToMakeUpdateNotificationPreferencesCall = false
            (AppLaunchApiClass.sharedManager() as AnyObject).updateNotificationConfigOptions()
        }
        
        if DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged == true {
            DiscoverProfileCollection.sharedInstance.appTerminationHandler()
            DiscoverProfileCollection.sharedInstance.needToSendWooIDsForFLP = true
            DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
            DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
            DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
            DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
            DiscoverProfileCollection.sharedInstance.paginationToken = ""
            DiscoverProfileCollection.sharedInstance.paginationIndex = ""
            
            if isOpenedFromMyProfile == true {
                DiscoverProfileCollection.sharedInstance.switchCollectionMode(.my_PROFILE)
            }
            if DiscoverProfileCollection.sharedInstance.collectionMode != .my_PROFILE {
                WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
            }
            
            //            DiscoverAPIClass.fetchDiscoverDataFromServer(false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
            //                if success{
            //                }
            //            })
        }
        
        //        if (WooGlobeModel.sharedInstance().religionArray.count < 1) {
        //            WooGlobeModel.sharedInstance().religionOption = false
        //        }
        //
        //        if (WooGlobeModel.sharedInstance().ethnicityArray.count < 1) {
        //            WooGlobeModel.sharedInstance().ethnicityOption = false
        //        }
        //        if WooGlobeModel.sharedInstance().wooGlobeLocationDictionary != nil {
        //            let wooLocationDict = WooGlobeModel.sharedInstance().wooGlobeLocationDictionary as NSDictionary
        //            let allKeysArray: NSArray = wooLocationDict.allKeys as NSArray
        //            if allKeysArray.count < 1 {
        //                WooGlobeModel.sharedInstance().locationOption = false
        //            }
        //        }
        //        else
        //        {
        //            WooGlobeModel.sharedInstance().locationOption = false
        //        }
        //
        //        if ((WooGlobeModel.sharedInstance().locationOption == false) && (WooGlobeModel.sharedInstance().ethnicityOption == false) && (WooGlobeModel.sharedInstance().religionOption == false)){
        //            WooGlobeModel.sharedInstance().wooGlobleOption = false
        //        }
        //        else{
        //            WooGlobeModel.sharedInstance().wooGlobleOption = true
        //        }
        
        WooGlobeModel.sharedInstance().wooGlobePurchaseStarted = false
        //        if isOpenedFromMyProfile == true {
        WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
        
        self.navigationController?.popViewController(animated:true)
        //        }
        //        self.dismiss(animated: true) {
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func prepareCellDataForMyPreferences() {
        
        myPreferencesDataArray.removeAllObjects()
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MyPrefDiscoverSettings", withEventName: "3-MyPreferences.MyPrefDiscoverSettings.MDP_Landing")
        
        
        let locationDataArray : NSMutableArray = []
        let locationDictionary = NSDictionary(objects: [MyPreferencesCellType.DiscoverSettingsLocationTableViewCell.rawValue],
                                              forKeys: ["type" as NSCopying])
        locationDataArray.add(locationDictionary as AnyObject)
        if AppLaunchModel.sharedInstance().showLocationToggle == true{
            let showLocationDictionary = NSDictionary(objects: [MyPreferencesCellType.SettingShowLocationTableViewCell.rawValue],
                                                      forKeys: ["type" as NSCopying])
            locationDataArray.add(showLocationDictionary as AnyObject)
        }
        myPreferencesDataArray.add(locationDataArray)
        
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE"
        {
            //woo globe
            let wooGlobeDataArray : NSMutableArray = []
            let wooGlobeDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsWooGlobeTableViewCell.rawValue],
                                                  forKeys: ["type" as NSCopying])
            wooGlobeDataArray.add(wooGlobeDictionary as AnyObject)
            myPreferencesDataArray.add(wooGlobeDataArray)
        }
        
        if DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobalButton.boolValue == true {

            let goGlobeDataArray : NSMutableArray = []
            let goGlobeDictionary = NSDictionary(objects: [MyPreferencesCellType.GoGlobeSettingTableViewCell.rawValue], forKeys: ["type" as NSCopying])
            goGlobeDataArray.add(goGlobeDictionary as AnyObject)

            myPreferencesDataArray.add(goGlobeDataArray)
        }
        
        
        
        let distanceDataArray : NSMutableArray = []
        let distanceDictionary = NSDictionary(objects: [MyPreferencesCellType.SettingsLocationPrefCell.rawValue],
                                              forKeys: ["type" as NSCopying])
        distanceDataArray.add(distanceDictionary as AnyObject)
        //will add multiple cities here later
        myPreferencesDataArray.add(distanceDataArray)
        let ageDataArray : NSMutableArray = []
        let ageDictionary = NSDictionary(objects: [MyPreferencesCellType.NewDiscoverSettingsAgeTableViewCell.rawValue],
                                         forKeys: ["type" as NSCopying])
        ageDataArray.add(ageDictionary as AnyObject)
        myPreferencesDataArray.add(ageDataArray)
        
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
            let locationDataArray : NSMutableArray = []
            
            let showLocationDictionary = NSDictionary(objects: [MyPreferencesCellType.SettingShowLocationTableViewCell.rawValue, "wooSecretType"],
                                                      forKeys: ["type" as NSCopying,"cellType" as NSCopying])
            locationDataArray.add(showLocationDictionary as AnyObject)
            myPreferencesDataArray.add(locationDataArray)
        }
        
        let genderDataArray : NSMutableArray = []
        let genderDictionary = NSDictionary(objects: [MyPreferencesCellType.DiscoverSettingsGenderTableViewCell.rawValue],
                                            forKeys: ["type" as NSCopying])
        genderDataArray.add(genderDictionary as AnyObject)
        myPreferencesDataArray.add(genderDataArray)
        
        // Srwve Event
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MyPrefAppSettings", withEventName: "3-MyPreferences.MyPrefAppSettings.MAP_Landing")
        let notificationDataArray : NSMutableArray = []
        let matchAndChatDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsNotificationTableViewCell.rawValue, AppSettingsNotificationType.MatchAndChat.rawValue],
                                                  forKeys: ["type" as NSCopying, "subType" as NSCopying])
        notificationDataArray.add(matchAndChatDictionary as AnyObject)
        
        let crushRecievedDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsNotificationTableViewCell.rawValue, AppSettingsNotificationType.CrushRecieved.rawValue],
                                                   forKeys: ["type" as NSCopying, "subType" as NSCopying])
        notificationDataArray.add(crushRecievedDictionary as AnyObject)
        
        _ = NSDictionary(objects: [MyPreferencesCellType.AppSettingsNotificationTableViewCell.rawValue, AppSettingsNotificationType.QuestionsAndAnswers.rawValue],
                         forKeys: ["type" as NSCopying, "subType" as NSCopying])
        //notificationDataArray.add(qADictionary as AnyObject)
        
        myPreferencesDataArray.add(notificationDataArray)
        
        let soundDataArray : NSMutableArray = []
        let soundDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsSoundTableViewCell.rawValue],
                                           forKeys: ["type" as NSCopying])
        soundDataArray.add(soundDictionary as AnyObject)
        myPreferencesDataArray.add(soundDataArray)
        
        //REmoved feedback
        //            let feedbackDataArray : NSMutableArray = []
        //            let feedbackDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsFeedbackTableViewCell.rawValue],
        //                                               forKeys: ["type" as NSCopying])
        //            feedbackDataArray.add(feedbackDictionary as AnyObject)
        //            myPreferencesDataArray.add(feedbackDataArray)
        
        /*
         let socialDataArray : NSMutableArray = []
         let reviewOnAppStoreDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsSocialTableViewCell.rawValue, AppSettingsSocialType.ReviewOnAppstore.rawValue],
         forKeys: ["type" as NSCopying, "subType" as NSCopying])
         socialDataArray.add(reviewOnAppStoreDictionary as AnyObject)
         
         let likeOnFbDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsSocialTableViewCell.rawValue, AppSettingsSocialType.LikeOnFacebook.rawValue],
         forKeys: ["type" as NSCopying, "subType" as NSCopying])
         socialDataArray.add(likeOnFbDictionary as AnyObject)
         
         let followWooDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsSocialTableViewCell.rawValue, AppSettingsSocialType.FollowWoo.rawValue],
         forKeys: ["type" as NSCopying, "subType" as NSCopying])
         socialDataArray.add(followWooDictionary as AnyObject)
         
         myPreferencesDataArray.add(socialDataArray)
         */
        
        let accountDataArray : NSMutableArray = []
        let logoutDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsAccountTableViewCell.rawValue, AppSettingsAccountType.Logout.rawValue],
                                            forKeys: ["type" as NSCopying, "subType" as NSCopying])
        accountDataArray.add(logoutDictionary as AnyObject)
        
        let disableAccountDictionary = NSDictionary(objects: [MyPreferencesCellType.AppSettingsAccountTableViewCell.rawValue, AppSettingsAccountType.DisableAccount.rawValue],
                                                    forKeys: ["type" as NSCopying, "subType" as NSCopying])
        accountDataArray.add(disableAccountDictionary as AnyObject)
        
        myPreferencesDataArray.add(accountDataArray)
        
    }
    //cell Methods
    func createDiscoverSettingsLocationCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : DiscoverSettingsLocationTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DiscoverSettingsLocationTableViewCell)!
        
        if cell == nil {
            cell = DiscoverSettingsLocationTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.updateLocationLabel()
        
        return cell!
    }
    
    func createDiscoverSettingsDistanceCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : SettingsLocationPrefCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SettingsLocationPrefCell)!
        
        if cell == nil {
            cell = SettingsLocationPrefCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.prepare(forLocation: DiscoverProfileCollection.sharedInstance.intentModelObject!.maxDistance.intValue)
        
        return cell!
    }
    
    func createDiscoverSettingsAgeCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : NewDiscoverSettingsAgeTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? NewDiscoverSettingsAgeTableViewCell)!
        
        if cell == nil {
            cell = NewDiscoverSettingsAgeTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell!.updateAgeAndSliderValues()
        
        return cell!
    }
    
    func createDiscoverSettingsGenderCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : DiscoverSettingsGenderTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DiscoverSettingsGenderTableViewCell)!
        
        if cell == nil {
            cell = DiscoverSettingsGenderTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.updateGenderAndPreferencesView()
        
        return cell!
    }
    
    func createAppSettingsNotificationCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AppSettingsNotificationTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AppSettingsNotificationTableViewCell)!
        
        if cell == nil {
            cell = AppSettingsNotificationTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        let notifType:String = cellData["subType"] as! String
        
        cell?.setDataForNotificationType(AppSettingsNotificationType(rawValue: notifType)!)
        
        return cell!
    }
    
    func createAppSettingsSoundCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AppSettingsSoundTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AppSettingsSoundTableViewCell)!
        
        if cell == nil {
            cell = AppSettingsSoundTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        return cell!
    }
    
    func createAppSettingsFeedbackCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AppSettingsFeedbackTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AppSettingsFeedbackTableViewCell)!
        if cell == nil {
            cell = AppSettingsFeedbackTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        return cell!
    }
    
    func createAppSettingsSocialCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AppSettingsSocialTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AppSettingsSocialTableViewCell)!
        
        if cell == nil {
            cell = AppSettingsSocialTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        let notifType:String = cellData["subType"] as! String
        
        cell?.setDataForSocialType(AppSettingsSocialType(rawValue: notifType)!)
        
        
        return cell!
    }
    
    func createAppSettingsAccountCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AppSettingsAccountTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AppSettingsAccountTableViewCell)!
        if cell == nil {
            cell = AppSettingsAccountTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        let notifType:String = cellData["subType"] as! String
        cell?.setViewBasedOnAccountType(AppSettingsAccountType(rawValue: notifType)!)
        return cell!
    }
    
    func createAppSettingsWooGlobeCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : AppSettingsWooGlobeTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AppSettingsWooGlobeTableViewCell)!
        
        if cell == nil {
            cell = AppSettingsWooGlobeTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.setTheValuesOfEverythingBasedOnWooGlobeState()
        cell?.buttonTapHandler = { (tappedCellType) in
            
            switch tappedCellType {
            case WooGlobeCellType.CELL_TYPE_ETHNICITY:
                print("ethnicity handler")
                
                if WooGlobeModel.sharedInstance().isExpired == true {
                    cell?.wooGlobeSwitch.isOn = false
                    
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                    
                    purchaseObj.scrollableIndex = 1
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
                    
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if wooGlobePurchased == true {
                                        cell?.wooGlobeSwitch.isOn = true
                                        UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                                        UserDefaults.standard.synchronize()
                                        WooGlobeModel.sharedInstance().isExpired = false
                                        WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                                        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                                        self.myPreferencesTableView.reloadData()
                                        self.openEthnicityScreen()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                    purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                        if wooGlobePurchased == true {
                            cell?.wooGlobeSwitch.isOn = true
                            UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                            UserDefaults.standard.synchronize()
                            WooGlobeModel.sharedInstance().isExpired = false
                            WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                            WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                            self.myPreferencesTableView.reloadData()
                            self.openEthnicityScreen()
                        }
                    }
                }
                else{
                    self.openEthnicityScreen()
                }
                break
            case WooGlobeCellType.CELL_TYPE_RELIGION:
                print("religion handler")
                print(WooGlobeModel.sharedInstance().isExpired)
                if WooGlobeModel.sharedInstance().isExpired == true {
                    cell?.wooGlobeSwitch.isOn = false
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                    purchaseObj.scrollableIndex = 2
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                    
                    purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                        if wooGlobePurchased == true {
                            cell?.wooGlobeSwitch.isOn = true
                            UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                            UserDefaults.standard.synchronize()
                            WooGlobeModel.sharedInstance().isExpired = false
                            WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                            WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                            self.myPreferencesTableView.reloadData()
                            self.openReligionScreen()
                        }
                    }
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if wooGlobePurchased == true {
                                        cell?.wooGlobeSwitch.isOn = true
                                        UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                                        UserDefaults.standard.synchronize()
                                        WooGlobeModel.sharedInstance().isExpired = false
                                        WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                                        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                                        self.myPreferencesTableView.reloadData()
                                        self.openReligionScreen()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                }
                else{
                    self.openReligionScreen()
                }
                
                break
            case WooGlobeCellType.CELL_TYPE_LOCATION:
                print("location handler")
                
                if WooGlobeModel.sharedInstance().isExpired == true {
                    cell?.wooGlobeSwitch.isOn = false
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                    purchaseObj.scrollableIndex = 3
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = false
                    
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if wooGlobePurchased == true {
                                        cell?.wooGlobeSwitch.isOn = true
                                        UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                                        UserDefaults.standard.synchronize()
                                        WooGlobeModel.sharedInstance().isExpired = false
                                        WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                                        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                                        self.myPreferencesTableView.reloadData()
                                        self.openLocationScreen()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                    purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                        if wooGlobePurchased == true {
                            cell?.wooGlobeSwitch.isOn = true
                            UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                            UserDefaults.standard.synchronize()
                            WooGlobeModel.sharedInstance().isExpired = false
                            WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                            WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                            self.myPreferencesTableView.reloadData()
                            self.openLocationScreen()
                        }
                    }
                }
                else{
                    self.openLocationScreen()
                }
                
                break
            default:
                
                if WooGlobeModel.sharedInstance().isExpired == true {
                    
                    // cell?.wooGlobeSwitch.isOn = false
                    
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                    purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
                    DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
                    purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                        if wooGlobePurchased == true {
                            cell?.wooGlobeSwitch.isOn = true
                            UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                            UserDefaults.standard.synchronize()
                            WooGlobeModel.sharedInstance().isExpired = false
                            WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                            WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                            DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                            self.myPreferencesTableView.reloadData()
                        }
                    }
                    purchaseObj.purchaseDismissedHandler = {
                        (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                        let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                        dropOffPurchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                            DispatchQueue.main.async
                                {
                                    if wooGlobePurchased == true {
                                        cell?.wooGlobeSwitch.isOn = true
                                        UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                                        UserDefaults.standard.synchronize()
                                        WooGlobeModel.sharedInstance().isExpired = false
                                        WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                                        WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                                        DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                                        self.myPreferencesTableView.reloadData()
                                    }
                            }
                        }
                        dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                        
                    }
                    
                }
                else{
                    UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                    UserDefaults.standard.synchronize()
                    WooGlobeModel.sharedInstance().isExpired = false
                    WooGlobeModel.sharedInstance().wooGlobleOption = (cell?.wooGlobeSwitch.isOn)!
                    
                    WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption && (WooGlobeModel.sharedInstance().religionArray != nil && WooGlobeModel.sharedInstance().religionArray.count > 0)
                    WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption && (WooGlobeModel.sharedInstance().ethnicityArray != nil && WooGlobeModel.sharedInstance().ethnicityArray.count > 0)
                    WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                    DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                    if WooGlobeModel.sharedInstance().wooGlobleOption {
                        self.showSnackBar(NSLocalizedString("Woo Globe enabled.", comment: "Woo Globe enabled."))
                    }
                    else{
                        self.showSnackBar(NSLocalizedString("Woo Globe disabled.", comment: "Woo Globe disabled."))
                    }
                }
                
                
                self.myPreferencesTableView.reloadData()
                print("switch value is changed")
                break
            }
            //            }
        }
        
        return cell!
    }
    
    func createGoGlobalSettingCell (_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        print(cellIdentifier)
        var cell : GoGlobalSettingTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GoGlobalSettingTableViewCell)!
        
        if cell == nil {
            cell = GoGlobalSettingTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        print("blah blah", DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal)
        
        cell?.currentGoGlobalState = DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal.boolValue
        cell?.showGoGlobalLabel.text = "Go Global"
        
        if DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal == true {
            cell?.goGlobalToggleSwitch.isOn = true
        }else{
            cell?.goGlobalToggleSwitch.isOn = false
        }
         
        return cell!
    }
    
    func createSettingsShowLocationCell(_ cellData:NSDictionary, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = cellData["type"] as! String
        var cell : SettingShowLocationTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SettingShowLocationTableViewCell)!
        
        if cell == nil {
            cell = SettingShowLocationTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        if let secret = cellData["cellType"]{
            if (secret as! String) == "wooSecretType"{
                cell?.locationLabel.text = "Woo Secret"
                cell?.showLocationSwitch.isHidden = true
            }
        }
        else{
            cell?.showLocationSwitch.isOn = (DiscoverProfileCollection.sharedInstance.intentModelObject?.showLocation.boolValue) ?? false
        }
        return cell!
    }
    
    
    func openEthnicityScreen() {
        let optionScreen = EthnicitySelectionViewController.loadNib()
        optionScreen.mainDataSource = NSArray(contentsOfFile: Bundle.main.path(forResource: "Ethnicity", ofType:"plist")!)!
        //                optionScreen.maxmimumSelection = 2
        optionScreen.showSwitchButton = true
        if ((WooGlobeModel.sharedInstance().ethnicityArray != nil) &&  (WooGlobeModel.sharedInstance().ethnicityArray.count > 0)){
            optionScreen.selectedEthnicity = []
            for item in WooGlobeModel.sharedInstance().ethnicityArray {
                let ethnicityName = (item as! NSDictionary)["name"] as! String
                optionScreen.selectedEthnicity.append(ethnicityName)
            }
        }
        
        optionScreen.selectionHandler = { (selectedData) in
            
            WooGlobeModel.sharedInstance().ethnicityArray = selectedData
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            self.myPreferencesTableView.reloadData()
            
        }
        optionScreen.viewControllerType = EthnicityClassType.TYPE_ETHNICITY
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //(optionScreen, animated: true, completion: nil)
    }
    
    func openReligionScreen() {
        let optionScreen = EthnicitySelectionViewController.loadNib()
        
        //        let religionArrayWithoutdoesntMatter = NSMutableArray.init(array: NSArray(contentsOfFile: Bundle.main.path(forResource: "Region", ofType:"plist")!)!)
        //
        //        let otherReligionObj = ["tagId" : "13",
        //            "name" : "Others",
        //            "tagsDtoType" : "USER_RELIGION",
        //            "order" : "0"
        //        ]
        //
        //        religionArrayWithoutdoesntMatter.remove(otherReligionObj)
        
        
        optionScreen.mainDataSource = getReligionArrayAfterReturningOthersOption()
        optionScreen.showSwitchButton = true
        //                optionScreen.maxmimumSelection = 2
        
        if let religionArray = WooGlobeModel.sharedInstance().religionArray{
            if religionArray.count > 0 {
                optionScreen.selectedEthnicity = []
                for item in WooGlobeModel.sharedInstance().religionArray {
                    let religionDetail = item as! NSDictionary
                    optionScreen.selectedEthnicity.append(religionDetail.object(forKey: "name") as! String)
                }
            }
        }
        
        optionScreen.selectionHandler = { (selectedData) in
            WooGlobeModel.sharedInstance().religionArray = selectedData
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            self.myPreferencesTableView.reloadData()
            
        }
        optionScreen.viewControllerType = EthnicityClassType.TYPE_RELIGION
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //present(optionScreen, animated: true, completion: nil)
    }
    
    func getReligionArrayAfterReturningOthersOption() -> NSArray {
        let religionArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "Region", ofType:"plist")!)
        let religionArrayWithoutOther = NSMutableArray.init(array: religionArray!)
        
        for religionData in religionArray! {
            //            let religionName = (religionData as! NSDictionary)["name"] as! String
            let selectedValueId = (religionData as! NSDictionary)["tagId"] as! NSNumber
            if selectedValueId.intValue == 13 {
                religionArrayWithoutOther.remove(religionData)
            }
        }
        
        return (religionArrayWithoutOther as NSArray)
    }
    
    func openLocationScreen(){
        let optionScreen = EthnicitySelectionViewController.loadNib()
        optionScreen.mainDataSource = NSArray(contentsOfFile: Bundle.main.path(forResource: "Region", ofType:"plist")!)!
        optionScreen.showSwitchButton = true
        if WooGlobeModel.sharedInstance().wooGlobeLocationCity != nil && WooGlobeModel.sharedInstance().wooGlobeLocationState != nil{
            if (WooGlobeModel.sharedInstance().wooGlobeLocationCity.count > 0) && (WooGlobeModel.sharedInstance().wooGlobeLocationState.count > 0) {
                if WooGlobeModel.sharedInstance().wooGlobeLocationDictionary != nil {
                    let wooLocationDict = WooGlobeModel.sharedInstance().wooGlobeLocationDictionary as NSDictionary
                    let allKeysArray: NSArray = wooLocationDict.allKeys as NSArray
                    if allKeysArray.count > 0 {
                        let aTempDict = [
                            "city" : WooGlobeModel.sharedInstance().wooGlobeLocationCity,
                            "state" : WooGlobeModel.sharedInstance().wooGlobeLocationState,
                            "selectedLocationDetail" : WooGlobeModel.sharedInstance().wooGlobeLocationDictionary,
                            "isSelected" : "true"
                            ] as [String : Any]
                        optionScreen.selectedLocation = aTempDict as NSDictionary?
                    }
                    else{
                        let aTempDict = [
                            "city" : WooGlobeModel.sharedInstance().wooGlobeLocationCity,
                            "state" : WooGlobeModel.sharedInstance().wooGlobeLocationState,
                            "isSelected" : "true"
                        ]
                        optionScreen.selectedLocation = aTempDict as NSDictionary?
                    }
                }
                else{
                    let aTempDict = [
                        "city" : WooGlobeModel.sharedInstance().wooGlobeLocationCity,
                        "state" : WooGlobeModel.sharedInstance().wooGlobeLocationState,
                        "isSelected" : "true"
                    ]
                    optionScreen.selectedLocation = aTempDict as NSDictionary?
                }
                
            }
        }
        
        //                optionScreen.maxmimumSelection = 2
        if let religionArray = WooGlobeModel.sharedInstance().religionArray{
            if religionArray.count > 0 {
                optionScreen.selectedEthnicity = []
                for item in WooGlobeModel.sharedInstance().religionArray {
                    let ethnicityDetail = item as! NSDictionary
                    optionScreen.selectedEthnicity.append(ethnicityDetail.object(forKey: "name") as! String)
                }
            }
        }
        
        
        optionScreen.selectionHandler = { (selectedData) in
            
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            
            if selectedData.count > 0 {
                let locationDetail = selectedData.first
                WooGlobeModel.sharedInstance().wooGlobeLocationCity = locationDetail?.object(forKey: "city") as! String?
                DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation = WooGlobeModel.sharedInstance().wooGlobeLocationCity
                WooGlobeModel.sharedInstance().wooGlobeLocationState = locationDetail?.object(forKey: "state") as! String?
                //                if let selectedLocationDetail: NSDictionary = locationDetail?.object(forKey: "selectedLocationDetail") as! NSDictionary? {
                WooGlobeModel.sharedInstance().wooGlobeLocationDictionary = locationDetail?.object(forKey: "selectedLocationDetail") as! [AnyHashable : Any]?
                
                if let referenceKey: String =  locationDetail?.object(forKey: "reference") as! String?{
                    print("\(referenceKey)")
                    self.getLatLong(fromPlaceId: locationDetail as! [AnyHashable : Any])
                }
                //                }
                
            }
            else{
                WooGlobeModel.sharedInstance().wooGlobeLocationCity = ""
                WooGlobeModel.sharedInstance().wooGlobeLocationState = ""
                WooGlobeModel.sharedInstance().wooGlobeLocationDictionary = NSDictionary() as! [AnyHashable : Any]
            }
            self.myPreferencesTableView.reloadData()
        }
        optionScreen.viewControllerType = EthnicityClassType.TYPE_LOCATION
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //present(optionScreen, animated: true, completion: nil)
    }
    
    
    
    /*
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
     if(segue.identifier == "discoverToDetailSegue"){
     let detailViewControllerObject = segue.destinationViewController as! ProfileDeckDetailViewController
     
     
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        SettingsToFeedbackViewController
        
        if segue.identifier == "SettingsToFeedbackViewController" {
            let answerController = segue.destination as! WriteAnswerViewController
            answerController.screenType = .feedback
        }
    }
    
    @IBAction func toggleBetweenDiscoverAndAppSettings(_ sender: AnyObject) {
        prepareCellDataForMyPreferences()
        self.myPreferencesTableView.reloadData()
        self.myPreferencesTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        
    }
    
    func feedBackButtonTapped(){
        
        self.performSegue(withIdentifier: "SettingsToFeedbackViewController", sender: nil)
        
    }
    
    func postFeedBack(){
        if (feedbackTextviewObj?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))?.count < 1 {
            (Utilities.sharedUtility() as AnyObject).showToast(withText: "Please enter some text.")
            return
        }
        (Utilities.sharedUtility() as AnyObject).showToast(withText: NSLocalizedString("CMP00320", comment: ""))
        
        if feedbackTextviewObj?.text.count > 0 {
            AppSettingsApiClass.sendFeedback(toServer: feedbackTextviewObj?.text, andNumberOfStars: -1, andEmail: "", andPhoneNumber: "", withCompletionBlock: nil)
        }
        feedbackAlertViewObj?.removeFromSuperview()
    }
    
    func logUserOut(){
        
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Do you want to log out?", comment: ""),
                                                         message: NSLocalizedString("Logging out of the Woo will remove some of your data stored with us and you won't receive any notifications as well.", comment:""),
                                                         preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("No", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
        })
        
        let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Yes", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
            
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            // Srwve Event
            
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MyPrefAppSettings", withEventName: "3-MyPreferences.MyPrefAppSettings.MAP_LogOut_Yes")
            
            
            self.confirmLogout()
        })
        
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        
        self.present(alert, animated: true, completion: {() -> Void in
            
        })
    }
    
    func confirmLogout(){
        
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorialForVoiceCall")
        UserDefaults.standard.removeObject(forKey: "hasSeenInviteViewForVoiceCall")
        UserDefaults.standard.removeObject(forKey: "inviteCampaignUpdatedTime")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorialForPreferences")
        UserDefaults.standard.removeObject(forKey: "hasSeenIntroductionForSearchTags")
        UserDefaults.standard.removeObject(forKey: "hasVisitedSkippedSection")
        UserDefaults.standard.removeObject(forKey: "hasVisitedLikedByMeSection")
        UserDefaults.standard.removeObject(forKey: "VoiceCallingTutorialSeenfor")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorialForVoiceCallForFirstTap")
        UserDefaults.standard.set(false, forKey: kFirstTimeFavouriteGlow)
        UserDefaults.standard.synchronize()

        //logout the fbsession from app
        
        FBSession.active().clearJSONCache()
        FBSession.active().close()
        FBSession.active().closeAndClearTokenInformation()
        FBSession.setActive(nil)
        FBSDKLogin.sharedManager().logOutUserFromFacebook()
        UserDefaults.standard.removeObject(forKey: "FBAccessTokenInformationKey")
        UserDefaults.standard.removeObject(forKey: kIsLoginProcessCompleted)
//        UserDefaults.standard.removeObject(forKey: kWooUserId)
        UserDefaults.standard.synchronize()
        
        
        self.performLogoutFlow()
    }
    
    func performLogoutFlow(){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        self.showWooLoader()
        AppSettingsApiClass.logoutUser { (success, response, statusCode) in
            
            print("response",response)
            print("statusCode",statusCode)
            
            if statusCode == 200 {
                self.logoutUser()
                UserDefaults.standard.removeObject(forKey: kWooUserId)
                DiscoverProfileCollection.sharedInstance.myProfileData = nil
                DiscoverProfileCollection.sharedInstance.clearAllData()
            }
        }
        
    }
    
    func logoutUser(){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp{ (success) in
            self.hideWooLoader()
            if(success){
                print(success)
                // self.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
               
                WooScreenManager.sharedInstance.loadLoginView()
                //}
            }
        }
    }
    
    func showDeleteOptionstoUserForButtonTapped()
    {
        let reportView: ReportUserView = ReportUserView(frame: self.view.frame)
        reportView.textView.placeholder = NSLocalizedString("Additional information", comment: "Additional information")
        reportView.reportViewType = reasonsForDelete
        reportView.reportedViewController = self
        reportView.setHeaderForReport(reasonsForDelete)
        reportView.delegate = self
        reportView.reasonsDelegate = self
        if UIDevice.current.systemVersion.compare("9.0",
                                                  options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending {
            self.view!.addSubview(reportView)
        }
        else {
            UIApplication.shared.delegate!.window!!.addSubview(reportView)
        }
        
    }
    func deleteAccount(_ userComment:String ){
        
        // Srwve Event
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MyPrefAppSettings", withEventName: "3-MyPreferences.MyPrefAppSettings.MAP_DeleteAccount_Select_Yes")
        
        DiscoverProfileCollection.sharedInstance.myProfileData = nil
        DiscoverProfileCollection.sharedInstance.clearAllData()
        
        self.showWooLoader()
        
        let feedbackValue = userComment == "Found Someone On Woo" ? true : false
        
        AppSettingsApiClass.deleteUser(withUserComment: userComment, withEmail: "", andPhoneNumber: "", andDeleteFeedback: feedbackValue, withCompletionBlock: {
            (success, response, statusCode) in
            self.hideWooLoader()
        })
        
        (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp{ (success) in
            if(success){
                //                    self.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
                WooScreenManager.sharedInstance.loadLoginView()
                /* Removed Tutorial
                 UserDefaults.standard.set(false, forKey: kIsTutorialShown)
                 */
                //                    }
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "tagTrainingShowExpiry")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorialForPreferences")
        UserDefaults.standard.removeObject(forKey: "hasSeenIntroductionForSearchTags")
        UserDefaults.standard.removeObject(forKey: "hasVisitedLikedByMeSection")
        UserDefaults.standard.removeObject(forKey: "hasVisitedSkippedSection")
        UserDefaults.standard.removeObject(forKey: "isFreetrailShown")
        FreeTrailModel.sharedInstance().updateData(withOfferDtoDictionary: [:])
        UserDefaults.standard.synchronize()
        
    }
    
    func disableAccount(){
        
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Disable your account for a week?", comment: ""),
                                                         message: NSLocalizedString("Once you disable your account, you are logged out for 7 days and people on Woo won’t be able to see your profile. However, after a week, you will be auto logged in and your profile is visible to everyone.", comment:""),
                                                         preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("No", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
        })
        
        let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Yes", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                return
            }
            // Srwve Event
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MyPrefAppSettings", withEventName: "3-MyPreferences.MyPrefAppSettings.MAP_DisableAccount_Select_Yes")
            
            
            
            UserDefaults.standard.set(false, forKey: kFirstTimeFavouriteGlow)
            UserDefaults.standard.synchronize()
            DiscoverProfileCollection.sharedInstance.myProfileData = nil
            DiscoverProfileCollection.sharedInstance.clearAllData()
            AppSettingsApiClass.disableUser { (success, response, statusCode) in
                
            }
            self.logoutUser()
        })
        
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        
        self.present(alert, animated: true, completion: {() -> Void in
            
        })
    }
    
    func showDisableAccountSheet(){
        
        let disableDeleteSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let disableAction:UIAlertAction = UIAlertAction(title:NSLocalizedString("Disable for a week", comment: "") , style: .default) { (action) in
            // add code here
            self.disableAccount()
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "Delete_Account")
        let deleteAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete account", comment: ""), style: .default) { (action) in
            //Show a popup for account deletion confirmation
            let deleteSheet: UIAlertController = UIAlertController(title: "Delete your account?", message: "Once you delete your account, all your information including chats & matches is permanently removed. If in future you wish to get back on Woo, you will be treated as a new user.", preferredStyle: .alert)
            let deleteAccountAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (action) in
                
                if(AppLaunchModel.sharedInstance().isFreeTrialOnDeleteActive){
                    self.deleteUponServerResponse(comment: "") { (response) in
                        self.showDeleteOptionstoUserForButtonTapped()
                    }
                }else{
                    self.showDeleteOptionstoUserForButtonTapped()
                }
               
            }
            let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default) { (action) in
                deleteSheet.dismiss(animated: true, completion: nil)
            }
            deleteSheet.addAction(cancelAction)
            deleteSheet.addAction(deleteAccountAction)
            
            self.present(deleteSheet, animated: true, completion: {() -> Void in
                
            })
            
        }
        
        let destructive:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        disableDeleteSheet.addAction(disableAction)
        disableDeleteSheet.addAction(deleteAction)
        disableDeleteSheet.addAction(destructive)
        self.present(disableDeleteSheet, animated: true) {
            // nothing here
        }
        
    }
    
    
    func deleteUponServerResponse(comment: String, onResponse: @escaping onResponseReceived){
        let url = kBaseUrlVersion1+"/grantFreeTrial?wooId=\(UserDefaults.standard.object(forKey: kWooUserId) as?String ?? "")&offerChannel=SYSTEM"
        self.showWooLoader()
        FreeTrail.sharedInstance.hitFreeTrailDeleteFlow(url: url) { (isSucess, statusCode, result)  in
            self.hideWooLoader()
            if(isSucess){
                if(statusCode == 200){
                       if let dict = result as? NSDictionary{ FreeTrailModel.sharedInstance().updateData(withOfferDtoDictionary: dict as! [AnyHashable : Any])
                    }
                }else if(statusCode == 204) {
                    FreeTrailModel.sharedInstance().updateData(withOfferDtoDictionary: [:] )
                }
               onResponse(true)

            }else{
           
                onResponse(false)
            }
        }
    }
    
    
    
    func checkForPermissionAndAskIfNotAvailable(discoverCell discoverCellObj:DiscoverSettingsLocationTableViewCell) {
        
        //ask for location permission
        if (locationManager?.isWooAllowedForLocation())! {
            // location permission is available
            //            self.locationManager?.gettingUserCurrentLocationForDiscover()
            discoverCellObj.showActivityIndicatorObject()
            
            self.locationManager?.getUserCurrentLocation({ (succes, locationObj) in
                if succes == true{
                    
                    //saving current time stamp
                    UserDefaults.standard.set(Date(), forKey: kLastLocationUpdatedTimeFromSettings)
                    self.locationManager?.makeLocationStringFromLatLongAndStartTheFlow(for: locationObj, withCompletion: { (sucess, city) in
                        discoverCellObj.hideActivityIndictorObject()
                        self.myPreferencesTableView.reloadData()
                    })
                }
                else{
                    //failed to fetch location
                    self.askUserToEnableLocationPermissionOrPurchaseWooGlobe(alertMSg:  NSLocalizedString("needLocationPermission", comment: "askingPermission") )
                }
            }, withoutChangingBlock: true)
        }
        else{
            // permission not available show pop up
            self.askUserToEnableLocationPermissionOrPurchaseWooGlobe(alertMSg:  NSLocalizedString("needLocationPermission", comment: "askingPermission") )
        }
        
    }
    
    
    
    
    func askUserToEnableLocationPermissionOrPurchaseWooGlobe(alertMSg: String) {
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
            self.openSearchLocation()
        }else{
            let alert = UIAlertController(title: NSLocalizedString("Give location permissions", comment: "Give location permissions"), message:alertMSg, preferredStyle: .actionSheet)
            if !(locationManager?.isWooAllowedForLocation())!  {
                //            if !(locationManager?.isWooAllowedForLocation())! {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Give Permission", comment: "Give Permission"), style: .default, handler: { (action: UIAlertAction) -> Void in
                    //update location button tapped
                    
                    if (CLLocationManager.locationServicesEnabled() ||  (CLLocationManager.authorizationStatus() == .denied)){
                        let giveLocationPermissionAlert = UIAlertController(title: "Location not detected", message: "Location services are turned off on your device. Plese go to settings and enable location services to use this feature.", preferredStyle: .alert)
                        giveLocationPermissionAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        giveLocationPermissionAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction) in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl)  {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    })
                                }
                                else  {
                                    UIApplication.shared.openURL(settingsUrl)
                                }
                            }
                        }))
                        self.present(giveLocationPermissionAlert, animated: true, completion: nil)
                    }
                    else{
                        self.locationManager?.getUserCurrentLocation({ (succes, locationObj) in
                            if succes == true{
                                self.locationManager?.makeLocationStringFromLatLongAndStartTheFlow(for: locationObj, withCompletion: { (sucess, city) in
                                    self.myPreferencesTableView.reloadData()
                                })
                            }
                            else{
                                //failed to fetch location
                                
                                self.askUserToEnableLocationPermissionOrPurchaseWooGlobe(alertMSg:  NSLocalizedString("needLocationPermission", comment: "askingPermission") )
                            }
                        })
                    }
                }))
                //            }
                
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Select Manually", comment: "Teleport Manually"), style: .default, handler: { (action: UIAlertAction) -> Void in
                //teleport manually button tapped
                self.clickedOnSelectManually()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: {
                //            alert.view.isUserInteractionEnabled = true
                ////            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.alertTapped(_ :))))
                //            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.testMethod)))
            })
        }
    }
    
    func clickedOnSelectManually(){
        if WooGlobeModel.sharedInstance().isExpired == true {
            let window:UIWindow = UIApplication.shared.keyWindow!
            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooGlobe)
            DiscoverProfileCollection.sharedInstance.comingFromDiscover = true
            purchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                if wooGlobePurchased == true {
                    UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                    UserDefaults.standard.synchronize()
                    WooGlobeModel.sharedInstance().isExpired = false
                    WooGlobeModel.sharedInstance().wooGlobleOption = true
                    WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                    WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                    WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                    DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                    DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                    self.myPreferencesTableView.reloadData()
                    self.openLocationScreen()
                }
            }
            purchaseObj.purchaseDismissedHandler = {
                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                dropOffPurchaseObj.purchasedHandler = {(wooGlobePurchased:Bool) in
                    DispatchQueue.main.async
                        {
                            if wooGlobePurchased == true {
                                UserDefaults.standard.set(true, forKey: "needToSendCurrentWooIDToServer")
                                UserDefaults.standard.synchronize()
                                WooGlobeModel.sharedInstance().isExpired = false
                                WooGlobeModel.sharedInstance().wooGlobleOption = true
                                WooGlobeModel.sharedInstance().religionOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                WooGlobeModel.sharedInstance().ethnicityOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                WooGlobeModel.sharedInstance().locationOption = WooGlobeModel.sharedInstance().wooGlobleOption
                                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
                                DiscoverProfileCollection.sharedInstance.needToMakeServerCallAndReload = false
                                self.myPreferencesTableView.reloadData()
                                self.openLocationScreen()
                            }
                    }
                }
                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                
            }
        }
        else{
            self.openLocationScreen()
        }
    }
    
    
    func getUserCurrentLocation(alertMSg: String, cell: DiscoverSettingsLocationTableViewCell) {
        let alert = UIAlertController(title: alertMSg, message:"Update your location to your current location or get WooGlobe to set another location", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Update to current location", style: .default, handler: { (action: UIAlertAction) -> Void in
            self.checkForPermissionAndAskIfNotAvailable(discoverCell: cell)
            
            
            //UnComment if you want to check the location update on every one hour only
            /*if self.isLocationUpdateNeeded(){
             self.checkForPermissionAndAskIfNotAvailable(discoverCell: cell)
             }else{
             let alert = UIAlertController(title: "Location is updated", message: "Get Woo Globe to swipe in another location.", preferredStyle: UIAlertControllerStyle.alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
             switch action.style{
             case .default:
             print("default")
             case .cancel:
             print("cancel")
             case .destructive: break
             
             }}))
             self.present(alert, animated: true, completion: nil)
             }*/
        }))
        alert.addAction(UIAlertAction(title: "Select Manually", style: .default, handler: { (action: UIAlertAction) -> Void in
            self.clickedOnSelectManually()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: {
        })
        
    }
    
    
    func testMethod() {
        print("method me aaya hai")
    }
    func alertTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        //        alertObj.dismiss(animated: true, completion: nil)
    }
    
    func openSearchLocation(){
        //method should not be used now
        let mainStoryBoard:UIStoryboard = UIStoryboard(name: "onboarding", bundle: nil)
        let searchLocation:SearchLocationViewController = mainStoryBoard.instantiateViewController(withIdentifier: kSearchLocationViewControllerID) as! SearchLocationViewController
        searchLocation.comingFromSettings = true
        searchLocation.isCancelButtonVisible = true
        self.navigationController?.pushViewController(searchLocation, animated: true)
        //(searchLocation, animated: true, completion: nil)
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    func isLocationUpdateNeeded()->Bool{
        if((UserDefaults.standard.value(forKey: kLastLocationUpdatedTimeFromSettings)) != nil){
            self.savedDate = UserDefaults.standard.value(forKey: kLastLocationUpdatedTimeFromSettings) as? Date
            let currentDate = Date()
            let interval:Int = Int(currentDate.timeIntervalSince(self.savedDate!))
            if interval >= kLocationThreshold{
                //Lcoation Update needed as the user crossed the kLocationThreshold value
                return true
            }else{
                return false
            }
            
        }
        else{
            return true
        }
    }
    
    func getLatLong(fromPlaceId searchData: [AnyHashable: Any]) {
        self.showWooLoader()
        let reachability = AFNetworkReachabilityManager.shared
        let isNetworkReachable = (reachability()?.isReachable ?? false || reachability()?.isReachableViaWiFi ?? false || reachability()?.isReachableViaWWAN ?? false)
        if !isNetworkReachable {
            showSnackBar(NSLocalizedString("Please check your internet connection", comment: ""))
            return
        }
        let aStrPlaceReferance = (searchData["reference"] as! String)
        let placeDetail = PlaceDetail(apiKey: kGoogleAPIKey)
        placeDetail?.getForReferance(aStrPlaceReferance)
        placeDetail?.getForReferance(aStrPlaceReferance, withCompletionHandler: { (referenceString, placeDetail) in
            print("\(referenceString!)");
            print("\(placeDetail!)");
            print("placeDetail\(placeDetail!.coordinate.latitude) long \(placeDetail!.coordinate.longitude)")
            let selectedCityDetail = [
                "city" : (searchData["city"] as! String),
                "state" : (searchData["state"] as! String),
                "reference" : (searchData["reference"] as! String),
                "isSelected" : "true"
            ]
            let aTempDict = [
                "latitude" : placeDetail!.coordinate.latitude,
                "longitude" : placeDetail!.coordinate.longitude,
                "placeId" : referenceString!,
                "selectedLocationDetail" : selectedCityDetail
                ] as [String : Any]
            WooGlobeModel.sharedInstance().wooGlobeLocationDictionary = aTempDict
            self.hideWooLoader()
        })
    }
    
    
    
    func showWooLoader(){
        
        customLoader?.removeFromSuperview()
        customLoader = nil
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        customLoader?.startAnimatingOnWindow(withBackgrooundColor: false)
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
        }, completion: { (true) in
            //                Utilities.sharedUtility().hideLoaderView
            self.customLoader?.stopAnimation()
            self.customLoader?.removeFromSuperview()
        })
        
    }
    
    //Location flow to get location from user
}

//MARK: UITableViewDataSource
extension MyPreferencesViewController: UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let cellArray = myPreferencesDataArray[section] as! NSMutableArray
        
        return cellArray.count
    }
    
    
    //    internal func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 24;
    //    }
    
    
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //        let cellArray = myPreferencesDataArray[section] as! NSMutableArray
        //
        //        var headerText:String?
        //
        //        for cellDictionary in cellArray {
        //
        //            let localCellDictionary = cellDictionary as! NSDictionary
        //
        //            let type : MyPreferencesCellType = MyPreferencesCellType(rawValue: localCellDictionary["type"] as! String)!
        //
        //            switch  type{
        //            case MyPreferencesCellType.DiscoverSettingsLocationTableViewCell:
        //                headerText = NSLocalizedString("My location is...", comment: "My location is...")
        //            case MyPreferencesCellType.SettingsLocationPrefCell:
        //                headerText =  NSLocalizedString("I want to meet people based on", comment: "I want to meet people based on")
        //            case MyPreferencesCellType.DiscoverSettingsAgeTableViewCell:
        //                headerText = NSLocalizedString("Their age...", comment: "Their age...")
        //            case MyPreferencesCellType.DiscoverSettingsGenderTableViewCell:
        //                headerText = NSLocalizedString("Their relationship preference and gender...", comment: "Their relationship preference and gender...")
        //            case MyPreferencesCellType.AppSettingsNotificationTableViewCell:
        //                headerText = NSLocalizedString("Send me notifications for", comment: "Send me notifications for")
        //            case MyPreferencesCellType.AppSettingsSoundTableViewCell:
        //                headerText = NSLocalizedString("Sound", comment: "Sound")
        //            case MyPreferencesCellType.AppSettingsFeedbackTableViewCell:
        //                headerText = NSLocalizedString("Show us your love", comment: "Show us your love")
        //            case MyPreferencesCellType.AppSettingsSocialTableViewCell:
        //                headerText = nil
        //            case MyPreferencesCellType.AppSettingsAccountTableViewCell:
        //                headerText = NSLocalizedString("Account", comment: "Account")
        //            default:
        //                return nil
        //            }
        //
        //        }
        
        return getHeaderText(forSection: section)
    }
    
    func getHeaderText(forSection sectionValue:Int) -> String {
        
        
        //        return ""
        
        let cellArray = myPreferencesDataArray[sectionValue] as! NSMutableArray
        var headerText:String?
        
        for cellDictionary in cellArray {
            
            let localCellDictionary = cellDictionary as! NSDictionary
            
            let type : MyPreferencesCellType = MyPreferencesCellType(rawValue: localCellDictionary["type"] as! String)!
            
            switch  type{
            case MyPreferencesCellType.DiscoverSettingsLocationTableViewCell:
                headerText = NSLocalizedString("", comment: "")
            case MyPreferencesCellType.SettingsLocationPrefCell:
                headerText =  NSLocalizedString("", comment: "")
            case MyPreferencesCellType.DiscoverSettingsAgeTableViewCell:
                headerText = NSLocalizedString("", comment: "")
            case MyPreferencesCellType.NewDiscoverSettingsAgeTableViewCell:
                headerText = NSLocalizedString("", comment: "")
            case MyPreferencesCellType.DiscoverSettingsGenderTableViewCell:
                headerText = NSLocalizedString("", comment: "")
            case MyPreferencesCellType.AppSettingsNotificationTableViewCell:
                headerText = NSLocalizedString("Notifications", comment: "Notifications")
            case MyPreferencesCellType.AppSettingsSoundTableViewCell:
                headerText = NSLocalizedString("", comment: "")
            case MyPreferencesCellType.AppSettingsSocialTableViewCell:
                headerText = NSLocalizedString("Show us your love", comment: "Show us your love")
            case MyPreferencesCellType.AppSettingsFeedbackTableViewCell:
                headerText = ""
            case MyPreferencesCellType.AppSettingsAccountTableViewCell:
                headerText = NSLocalizedString("Account", comment: "Account")
            default:
                headerText = ""
            }
            
        }
        
        return headerText!
    }
    
    internal func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView{
            let headerView:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            headerView.textLabel?.text = headerView.textLabel?.text?.capitalized
            headerView.textLabel?.text = getHeaderText(forSection: section)
            headerView.textLabel?.font = UIFont(name: "Lato-Medium", size: 16.0)
            headerView.textLabel!.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#373A43", alpha: 1.0)
        }
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        
        return myPreferencesDataArray.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellArray = myPreferencesDataArray[(indexPath as NSIndexPath).section] as! NSMutableArray
        
        let cellDictionary = cellArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let cell : UITableViewCell
        
        let type : MyPreferencesCellType = MyPreferencesCellType(rawValue: cellDictionary["type"] as! String)!
        
        switch  type{
        case MyPreferencesCellType.DiscoverSettingsLocationTableViewCell:
            cell = self.createDiscoverSettingsLocationCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.SettingsLocationPrefCell:
            cell = self.createDiscoverSettingsDistanceCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.DiscoverSettingsAgeTableViewCell:
            cell = self.createDiscoverSettingsAgeCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.NewDiscoverSettingsAgeTableViewCell:
            cell = self.createDiscoverSettingsAgeCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.DiscoverSettingsGenderTableViewCell:
            cell = self.createDiscoverSettingsGenderCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.AppSettingsNotificationTableViewCell:
            cell = self.createAppSettingsNotificationCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.AppSettingsSoundTableViewCell:
            cell = self.createAppSettingsSoundCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.AppSettingsFeedbackTableViewCell:
            cell = self.createAppSettingsFeedbackCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.AppSettingsSocialTableViewCell:
            cell = self.createAppSettingsSocialCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.AppSettingsAccountTableViewCell:
            cell = self.createAppSettingsAccountCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.AppSettingsWooGlobeTableViewCell:
            cell = self.createAppSettingsWooGlobeCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.SettingShowLocationTableViewCell:
            cell = self.createSettingsShowLocationCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        case MyPreferencesCellType.GoGlobeSettingTableViewCell:
            cell = self.createGoGlobalSettingCell(cellDictionary, tableView: tableView, indexPath: indexPath)
            break
        default:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
            break
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension MyPreferencesViewController: UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        let cellArray = myPreferencesDataArray[(indexPath as NSIndexPath).section] as! NSMutableArray
        
        let cellDictionary = cellArray[(indexPath as NSIndexPath).row] as! NSDictionary
        var height : CGFloat = 44.0
        
        let type : MyPreferencesCellType = MyPreferencesCellType(rawValue: cellDictionary["type"] as! String)!
        
        switch type {
        case .DiscoverSettingsLocationTableViewCell:
            height = 44.0
            break
        case .SettingsLocationPrefCell:
            height = 154.0
            break
        case .DiscoverSettingsAgeTableViewCell:
            height = 190.0
            break
        case .NewDiscoverSettingsAgeTableViewCell:
            height = 120.0
            break
        case .DiscoverSettingsGenderTableViewCell:
            height = 100.0
            break
        case .AppSettingsNotificationTableViewCell:
            height = 44.0
            break
        case .AppSettingsSoundTableViewCell:
            height = 44.0
            break
        case .AppSettingsFeedbackTableViewCell:
            height = 44.0
            break
        case .AppSettingsSocialTableViewCell:
            height = 44.0
            break
        case .AppSettingsAccountTableViewCell:
            height = 44.0
            break
        case .SettingShowLocationTableViewCell:
            height = 44.0
            break
        case .AppSettingsWooGlobeTableViewCell:
            var heightToBeReduced:CGFloat = 0.0
            var labelExtraHeight: CGFloat = 0.0
            if UIScreen.main.bounds.size.width <= 320 {
                labelExtraHeight = 18
            }
            if WooGlobeModel.sharedInstance().isExpired == false {
                heightToBeReduced = 18.0 + labelExtraHeight
            }
            else{
                heightToBeReduced = 40.0
            }
            height = (215.0 + labelExtraHeight - heightToBeReduced)
            
            break
        default:
            height = 44.0
            break
        }
        
        return height
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellArray = myPreferencesDataArray[(indexPath as NSIndexPath).section] as! NSMutableArray
        
        let cellDictionary = cellArray[(indexPath as NSIndexPath).row] as! NSDictionary
        
        let type : MyPreferencesCellType = MyPreferencesCellType(rawValue: cellDictionary["type"] as! String)!
        
        switch type {
        case .DiscoverSettingsLocationTableViewCell:
            //            self.openSearchLocation()
            //            self.checkForPermissionAndAskIfNotAvailable()
            
            
            let cell : DiscoverSettingsLocationTableViewCell
            cell = tableView.cellForRow(at: indexPath)! as! DiscoverSettingsLocationTableViewCell
            if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"{
                self.openSearchLocation()
            }else{
                if (locationManager?.isWooAllowedForLocation())! {
                    self.getUserCurrentLocation(alertMSg: "Change my location", cell: cell)
                }else{
                    self.checkForPermissionAndAskIfNotAvailable(discoverCell: cell)
                }
            }
            break
        case .SettingShowLocationTableViewCell:
            if let secret = cellDictionary["cellType"]{
                if (secret as! String) == "wooSecretType"{
                    
                    WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.FemaleTutorial)
                }
            }
            break
        case .SettingsLocationPrefCell:
            break
        case .DiscoverSettingsAgeTableViewCell:
            break
        case .DiscoverSettingsGenderTableViewCell:
            break
        case .AppSettingsNotificationTableViewCell:
            break
        case .AppSettingsSoundTableViewCell:
            break
        case .AppSettingsFeedbackTableViewCell:
            self.feedBackButtonTapped()
            break
        case .AppSettingsSocialTableViewCell:
            let subType : AppSettingsSocialType = AppSettingsSocialType(rawValue: cellDictionary["subType"] as! String)!
            switch subType{
            case .ReviewOnAppstore:
                (Utilities.sharedUtility() as AnyObject).openURL(forURLString: String(format: "itms-apps://itunes.apple.com/app/id885397079"))
                break
            case .LikeOnFacebook:
                if UIApplication.shared.canOpenURL(URL(string: "fb://profile/405406416267848")!) {
                    UIApplication.shared.openURL(URL(string: "fb://profile/405406416267848")!)
                }
                else{
                    UIApplication.shared.openURL(URL(string: "https://www.fb.com/DateOnWoo")!)
                }
                break
            case .FollowWoo:
                if UIApplication.shared.canOpenURL(URL(string: "twitter://user?screen_name=thewooapp")!) {
                    UIApplication.shared.openURL(URL(string: "twitter://user?screen_name=thewooapp")!)
                }
                else{
                    UIApplication.shared.openURL(URL(string: "https://twitter.com/thewooapp")!)
                }
                break
            }
            break
        case .AppSettingsAccountTableViewCell:
            let subType : AppSettingsAccountType = AppSettingsAccountType(rawValue: cellDictionary["subType"] as! String)!
            switch subType {
            case .Logout:
                self.logUserOut()
                break
            case .DisableAccount:
                self.showDisableAccountSheet()
                break
            }
            break
        default:
            break
        }
    }
    
    func handleDeleteSheet(comment: String){
         print(" Freetrail delete is \(AppLaunchModel.sharedInstance().isFreeTrialOnDeleteActive)")
         print("FreeTrail Plaind count \(FreeTrailModel.sharedInstance().planId.count)")
        
        if(AppLaunchModel.sharedInstance().isFreeTrialOnDeleteActive && FreeTrailModel.sharedInstance().planId.count > 0){
     let window:UIWindow = UIApplication.shared.keyWindow!
                        let purchaseObj:FreeTrailDeleteScreen = Bundle.main.loadNibNamed("FreeTrailDeleteScreen", owner: window.rootViewController, options: nil)?.first as! FreeTrailDeleteScreen
                        purchaseObj.initiatedView = "FreeTrail_getwooplus"
                        (Utilities.sharedUtility() as AnyObject).sendMixPanelEvent(withName: "FreeTrail_getwooplus")
            
                        purchaseObj.loadPopupOnWindowForFreeTrail()
            
                        purchaseObj.purchasedHandlerFreeTrail = {(purchased:Bool) in
                            if(purchased){
                                FreeTrailModel.sharedInstance().updateData(withOfferDtoDictionary: [:])
                            AppLaunchModel.sharedInstance()!.isChatEnabled = true
                            }
                        }
            
            purchaseObj.purchasedHandlerFreeTrailDeleteHandler = { (isDelete:Bool) in
                if(isDelete){
                    self.deleteAccount("Too many notifications")
                
            }
            }
        }else{
            self.deleteAccount(comment)
        }
    }
}

extension MyPreferencesViewController:UITextViewDelegate{
    internal func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            placeholderLabel?.isHidden = true
            feedbackAlertViewObj?.enableRightButton()
        }
        else{
            placeholderLabel?.isHidden = false
            feedbackAlertViewObj?.disableRightButton()
        }
    }
}

extension MyPreferencesViewController:UIActionSheetDelegate{
    internal func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            self.disableAccount()
        }
        else if buttonIndex == 2{
            self.showDeleteOptionstoUserForButtonTapped()
        }
    }
}

extension MyPreferencesViewController : ReasonsDelegate
{
    func reasons(forUnmatchOrDelete comment: String!)
    {
        if let commentSelected = comment{
            if commentSelected == "Found Someone On Woo"{
                if AppLaunchModel.sharedInstance()?.showCongratulationsScreenOnDelete ?? false{
                    let controller: DeleteSubmitFeedbackViewController = DeleteSubmitFeedbackViewController(nibName: "DeleteSubmitFeedbackViewController", bundle: nil)
                    self.present(controller, animated: true, completion: nil)
                }
                else{
                    self.handleDeleteSheet(comment: commentSelected)
                }
            }
            else{
                self.handleDeleteSheet(comment: commentSelected)
            }
        }else{
            self.handleDeleteSheet(comment: "Too many notifications")
        }
    }
}


