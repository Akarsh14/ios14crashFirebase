//
//  SwiftConstants.swift
//  Woo_v2
//
//  Created by Suparno Bose on 04/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import Foundation
import UIKit
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH = UIScreen.main.bounds.width
let Iphone_5S_Size = CGSize(width: 320, height: 568)
let Iphone_6S_Size = CGSize(width: 375, height: 667)
let Iphone_6P_Size = CGSize(width: 414, height: 736)
let Iphone_X_Size = CGSize(width: 375, height: 812)

let kBoostPurchaseViewController = "BoostPurchaseViewController"
let kMyPurchaseViewController = "PushToMyPurchase"
let kMyWebViewController  = "wkWebViewStoryBoardID"
let kMyPreferencesController  = "MyPreferencesViewControllerID"
let kMyFeedbackController  = "WriteAnswerViewControllerID"
let kTagsSearchViewController = "TagSearchViewControllerID"
let kInviteCampaignViewController = "InviteCompaignViewControllerID"
let kCrushesViewController = "CrushPanelViewControllerID"
let kLikedMeViewController = "LikedMePanelViewControllerID"
let kSkippedViewController = "SkippedPanelViewControllerID"
let kLikedByMeViewController = "LikedMePanelViewControllerID"
let kVisitorsViewController = "VisitorsPanelViewControllerID"
let kTagSelectionViewController = "TagScreenViewControllerID"
let kMyQuestionsController =  "MyQuestionsController"
let kIsOnboardingMyProfileeShown = "isOnboardingMyProfileShown"

let kIsTutorialShown = "isTutorialShown"
let KDefaultLengthForQuote = 300
let KDefaultValueForWorkEducation = "0"
let baseTutorialString = "OnBoarding_Tutorial_"
let baseSecretTutorialString = "Woo_Secret_Left_Panel_Tutorial_"

let kUpdateEditProfileBasedOnQuestionAnswerChanges = "updateEditProfileBasedOnQuestionAnswerChanges"
let KHasSeenWooPlusSellingViewLikes = "hasSeenWooPlusSellingViewLikes"

let kRedColor = UIColor(red: 247.0/255.0, green: 47.0/255.0, blue: 57.0/255.0, alpha: 1.0).cgColor
let kRedColorDisbled = UIColor(red: 247.0/255.0, green: 47.0/255.0, blue: 57.0/255.0, alpha: 0.50).cgColor
let kGrayColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.30).cgColor
let kGrayColorDeep = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.40).cgColor
let kSeaBlueColor = UIColor(red: 18.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0).cgColor
let kRedArcColor = UIColor(red: 250.0/255.0, green: 72.0/255.0, blue: 73.0/255.0, alpha: 1.00).cgColor

let kCircularImageSize: Int32 = 40

let kIphone_X_Height = 2436
let kIphone_XsMAX_Height = 2688
let kIphone_XR_Height = 1792
let kIphone_SE_Height = 568

let kGradientColorBlackBottom:CGColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor
let kGradientColorBlackBottomForDPV:CGColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
let kGradientColorBlackTop:CGColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
let kGradientColorBlackTopForMeProfile:CGColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
let kGradientColorClear:CGColor = UIColor.clear.cgColor

let kIntentModelKey = "IntentModel"
let kPendingPhotoList = "PendingPhotoList"

let utilities = Utilities.sharedUtility() as! Utilities

let kPhotoApproved  = "APPROVED"
let kPhotoPending   = "PENDING"
let kPhotoRejected  = "REJECTED"

let kSideMenuAnalyzeProfileButtonText  = "ANALYZE PROFILE"
let imageIconFolderName = "ios/3x/"

//Safe Area Constants
let safeAreaTop:CGFloat = (Utilities.sharedUtility() as AnyObject).getSafeArea(forTop: true, andBottom: false)
let safeAreaBottom:CGFloat = (Utilities.sharedUtility() as AnyObject).getSafeArea(forTop: false, andBottom: true)
let safeAreaBoth:CGFloat = (Utilities.sharedUtility() as AnyObject).getSafeArea(forTop: true, andBottom: true)

let wooTrueStoryUrl = "https://medium.com/@dateonwoo"
//AppLozic
//54321
let AppLozicAuthenticationKey = "doubleyou393a25ca31528e80f8c2f"
let kBaseUrlVersion1 =  "\( Bundle.main.infoDictionary![API_BASE_URL] ?? "" )/woo/api/v1"
let kBaseURLV3 = "\( Bundle.main.infoDictionary![API_BASE_URL] ?? "" )/woo/api/v3"
enum SegueIdentifier: String {
    case NewMtchSegue = "NewMatchSegue"
    case DiscoverToDetailSegue = "discoverToDetailSegue"
    case DiscoverToBrandSegue = "discoverToBrandSegue"
    case ProfileDeckToWriteAnswerSegue = "ProfileDeckToWriteAnswerSegue"
    case TagSearchToProfileDetailSegue = "TagSearchToProfileDetailSegue"
    case HomeToChatSegue = "HomeToChatSegue"
}

enum DeepLinkingOptions: String {
    case Settings = "settings"
    case Search = "search"
    case PurchaseBoost = "boostPurchase"
    case PurchaseCrush = "crushPurchase"
    case PurchaseWooPlus = "wooPlusPurchase"
    case PurchaseWooGlobe = "wooGlobePurchase"
    case PhoneVerify = "phoneVerify"
    case EditProfile = "editProfile"
    case EnableNotification = "enableNotification"
    case FeedbackAppStore = "feedbackAppStore"
    case Feedback = "feedback"
    case ReferFriend = "referFriend"
    case MyPurchase = "mypurchases"
    case MyWebViewFAQ = "myWebViewFAQ"
    case MyWebViewTC = "myWebViewTC"
    case Me           = "me"
    case InviteCampaign = "inviteCampaign"
    case likedMeSection = "likedMe"
    case skippedSection = "skipped"
    case visitorsSection = "visitors"
    case crushSection = "crush"
    case tagSelectionScreen = "tagSelection"
    case ethnicitySelectionScreen = "ethnicitySelection"
    case verifyPhoneNumber = "verifyPhoneNumber"
    case MyQuestions = "questions"
    case AnalyzeProfile = "analyzeProfile"
    case Content_Guidelines = "CONTENT_GUIDELINES"
    case Woo_TrueStory = "Woo_TrueStory"
    case FemaleTutorial = "femaleTutorial"
}

enum WooNotifications: String {
    case MatchOverlaySeen = "MatchOverlaySeen"
}

enum MeDataType: String {
    case Visitors = "Visitors"
    case LikedMe = "LikedMe"
    case SkippedProfiles = "SkippedProfiles"
}

enum HeightUnit : String {
    case INCHES = "INCHES"
    case CM = "CM"
}

enum TagsDtoType : String {
    case USER_EDUCATION = "USER_EDUCATION"
    case USER_WORK = "USER_WORK"
}

enum EthnicityClassType : String {
    case TYPE_NONE = "TYPE_NONE"
    case TYPE_ETHNICITY = "TYPE_ETHNICITY"
    case TYPE_RELIGION = "TYPE_RELIGION"
    case TYPE_LOCATION = "TYPE_LOCATION"
}

enum WooGlobeCellType : String {
    case CELL_TYPE_ETHNICITY = "CELL_TYPE_ETHNICITY"
    case CELL_TYPE_RELIGION = "CELL_TYPE_RELIGION"
    case CELL_TYPE_LOCATION = "CELL_TYPE_LOCATION"
    case CELL_TYPE_SWITCH = "CELL_TYPE_SWITCH"
}

enum ActionTutorialType: String {
    case Like = "like"
    case Dislike = "dislike"
    case LikeDone = "likeDone"
}

enum ExpireType : String {
    case None               = "None"
    case Expiry             = "Expiry"
    case Expired            = "Expired"
}

enum BoostMatchBoxType: String {
    case BoostNow = "BoostNow"
    case ActivateBoost = "ActivateBoost"
    case None = "None"
}

func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version,
                                                          options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
}

func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version,
                                                          options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
}

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version,
                                                          options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version,
                                                          options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
}

func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version,
                                                          options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
}

func isNotchPhone()->Bool{
    if(isIphoneX() || isIphoneXSMAX() || isIphoneXR())
    { return true } else { return false }}


func isIphoneX ()-> Bool{
    if(UIScreen.main.nativeBounds.height == CGFloat(kIphone_X_Height))
        { return true } else { return false }}

func isIphoneXSMAX()->Bool{
    if(UIScreen.main.nativeBounds.height == CGFloat(kIphone_XsMAX_Height))
    { return true } else { return false }
}

func isIphoneXR()->Bool{
    if(UIScreen.main.nativeBounds.height == CGFloat(kIphone_XR_Height))
    {return true} else { return false}
}

func iPhoneIsAboveIPhoneXS()->Bool{
    if(UIScreen.main.nativeBounds.height > CGFloat(2688))
        { return true } else { return false }
}

func isIphoneSE()->Bool{
    if(UIScreen.main.bounds.height == CGFloat(kIphone_SE_Height))
    { return true } else { return false }
}


func updateExpiryArrayForExpiredData(_ expiryDataArray:NSArray, type:MeDataType) -> NSMutableArray{
    let expiryArray:NSMutableArray = NSMutableArray(array: expiryDataArray)
    let expiredArray = NSMutableArray()
    for data in expiryDataArray{
        let expiryDays:Double = Double(AppLaunchModel.sharedInstance().meSectionProfileExpiryDays * 24 * 3600)
        DateFormatter().timeZone = TimeZone(secondsFromGMT: 0)
        var timeStamp:Date = Date()
        switch type{
        case .LikedMe:
            timeStamp = (data as! LikedByMe).userExpiryTime  ?? Date()
            break
        
        case .Visitors:
            timeStamp = (data as! MeDashboard).visitorExpiryTime  ?? Date()
            break
            
        case .SkippedProfiles:
            timeStamp = (data as! SkippedProfiles).userExpiryTime  ?? Date()
            break
        }
        
        let serverTime = timeStamp.timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        
        var daysOfExpiry:Double = 0
        if currentTime <= (serverTime + expiryDays){
            daysOfExpiry = (serverTime + expiryDays) - currentTime
            daysOfExpiry = Double(Int(daysOfExpiry/(24*3600))) + 1
        }
        if daysOfExpiry == 0{
            expiredArray.add(data)
            expiryArray.remove(data)
        }
    }
    
    expiryArray.addObjects(from: expiredArray as! [Any])
    return expiryArray
}

func calculateDaysOfExpiry(_ userTimeStamp:Date) -> Double{
    let expiryDays:Double = Double(AppLaunchModel.sharedInstance().meSectionProfileExpiryDays * 24 * 3600)
    DateFormatter().timeZone = TimeZone(secondsFromGMT: 0)
    let serverTime = userTimeStamp.timeIntervalSince1970
    let currentTime = Date().timeIntervalSince1970
    
    var daysOfExpiry:Double = 0
    if currentTime <= (serverTime + expiryDays){
        daysOfExpiry = (serverTime + expiryDays) - currentTime
        daysOfExpiry = Double(Int(daysOfExpiry/(24*3600))) + 1
    }
    return daysOfExpiry
}


func isOSSupportingTrueCaller()->Bool{
    return true
//    if #available(iOS 12, *) {
//       return false
//    } else {
//        return true
//    }
}

//54321
func colorTheStatusBar(withColor: UIColor){
    if(isIphoneX() || isIphoneXSMAX() || isIphoneXR()){
//        let view: UIView = UIApplication.shared.value(forKey: "statusBarWindow.statusBar") as! UIView
//        view.backgroundColor = withColor
        
        
        var statusBarUIView: UIView? {
          if #available(iOS 13.0, *) {
              let tag = 38482
              let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

              if let statusBar = keyWindow?.viewWithTag(tag) {
                  return statusBar
              } else {
                  guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
                  let statusBarView = UIView(frame: statusBarFrame)
                  statusBarView.tag = tag
                  keyWindow?.addSubview(statusBarView)
                  return statusBarView
              }
          } else {
              return nil
          }
        }
        
        statusBarUIView?.backgroundColor = withColor
    }
}



extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class AlertController:NSObject{
    class func showAlert(withTitle:String, andMessage:String, needHandler:Bool, withController: UIViewController)-> UIAlertController{
        let alert = UIAlertController(title: withTitle, message: andMessage, preferredStyle: UIAlertController.Style.alert)
        if !needHandler{
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            withController.present(alert, animated: true, completion: nil)
        }
        return alert
    }
    
}


extension String {
    func capitalizingFirstLetter() -> String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    
    func removeWhiteSpaces() -> String{
        return dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func localizedString()->String{
        return NSLocalizedString(self, comment:"")
    }
}

extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}




extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
    
}
