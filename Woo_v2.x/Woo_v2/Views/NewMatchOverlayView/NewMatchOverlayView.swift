//
//  NewMatchOverlayView.swift
//  Woo_v2
//
//  Created by Suparno Bose on 18/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit
import SDWebImage

enum OverlayButtonType : String{
    case Return_To_Answer = "Return To Answer"
    case Retun_To_Profile = "Retun To Profile"
    case Keep_Swiping = "Keep Swiping"
    case Return_To_Dashboard = "Return To Dashboard"
    
    func buttonIcon() -> String {
        switch self {
        case .Return_To_Answer:
            return "ic_match_answer"
        case .Retun_To_Profile:
            return "ic_match_profile"
        case .Keep_Swiping:
            return "ic_match_discover"
        case .Return_To_Dashboard:
            return "ic_match_profile"
    }
}
}

class NewMatchOverlayView: UIView {

    //MARK: IBOutlet variables
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var matchImageView: UIImageView!
    
    @IBOutlet weak var otherActivityButtonIcon: UIImageView!
    
    @IBOutlet weak var otherActivityButtonLabel: UILabel!
    @IBOutlet weak var startChatingButton: UIButton!
    
    @IBOutlet weak var globeIconImage: UIImageView!
    
    var chatButtonHandler : ((NSDictionary?) -> ())?
    
    var otherActivityHandler : (() -> ())?
    
    var removeViewOnStartChatButton: Bool = false
    
    var activityIndicatorViewObj : UIActivityIndicatorView?
    
    //MARK: private variables
    fileprivate var matchData : NSDictionary?

    fileprivate var buttonType : OverlayButtonType = .Keep_Swiping
    
    //MARK: View Lifecycle method
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview(){
        super.didMoveToSuperview()
        self.updateViewWithMatchData()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        matchImageView.layer.cornerRadius = matchImageView.frame.size.width/2
        matchImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        matchImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    func showglobeIcon(shouldShowGlobeIcon showGlobeIcon: Bool) {
        globeIconImage.isHidden = !showGlobeIcon
    }
    
    //MARK: IBAction methods
    @IBAction func closeOverlay(_ sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    @IBAction func chattingButtonPressed(_ sender: AnyObject) {
        if removeViewOnStartChatButton == true {
            self.removeFromSuperview()
        }
        if chatButtonHandler != nil {
            chatButtonHandler!(matchData)
        }
    }
    
    @IBAction func otherActivityButtonPressed(_ sender: AnyObject) {
        self.removeFromSuperview()
        if otherActivityHandler != nil {
            otherActivityHandler!()
        }
    }
    
    //MARK: Exposed methods
    
    @objc class func showViewForObjCClass(_ matchData : NSDictionary, buttonType : NSString) -> NewMatchOverlayView{
        UserDefaults.standard.set(true, forKey: kFirstMAtchOnV3Key)
        UserDefaults.standard.synchronize()
        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MatchOverlayAggregate", withEventName: "3-MatchOverlay.MatchOverlayAggregate.MO_SplashScreenShow")
        
        
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        

        for matchOverlayView in window.subviews {
            if matchOverlayView is NewMatchOverlayView{
                matchOverlayView.removeFromSuperview()
            }
        }
        let matchPopup: NewMatchOverlayView =
            Bundle.main.loadNibNamed("NewMatchOverlayView", owner: window.rootViewController, options: nil)!.first as! NewMatchOverlayView
        matchPopup.frame = window.frame
        matchPopup.alpha = 0.0
        matchPopup.matchData = matchData
        matchPopup.buttonType = OverlayButtonType(rawValue: buttonType as String)!
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            (window2.subviews.first! as UIView).addSubview(matchPopup)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(matchPopup)
            }
            else{
                (window.subviews.first! as UIView).addSubview(matchPopup)
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            matchPopup.alpha = 1.0
        })
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: WooNotifications.MatchOverlaySeen.rawValue), object: nil))
        
        return matchPopup

    }
    
     class func showView(_ matchData : NSDictionary, buttonType : OverlayButtonType) -> NewMatchOverlayView{
        
        // Srwve Event
        UserDefaults.standard.set(true, forKey: kFirstMAtchOnV3Key)
        UserDefaults.standard.synchronize()

        
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MatchOverlayAggregate", withEventName: "3-MatchOverlay.MatchOverlayAggregate.MO_SplashScreenShow")

        
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let matchPopup: NewMatchOverlayView =
            Bundle.main.loadNibNamed("NewMatchOverlayView", owner: window.rootViewController, options: nil)!.first as! NewMatchOverlayView
        matchPopup.frame = window.frame
        matchPopup.alpha = 0.0
        matchPopup.matchData = matchData
        matchPopup.buttonType = buttonType
        
        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
//            if window2 is MDSnackbar {
//                window2.removeFromSuperview()
//            }
           // window2 = window.subviews.last! as UIView
            (window2.subviews.first! as UIView).addSubview(matchPopup)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(matchPopup)
            }
            else{
                (window.subviews.first! as UIView).addSubview(matchPopup)
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            matchPopup.alpha = 1.0
        }) 
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: WooNotifications.MatchOverlaySeen.rawValue), object: nil))
        
        return matchPopup
    }
    
    class func showView(_ matchData : NSDictionary, buttonType : OverlayButtonType, parent : UIView) -> NewMatchOverlayView{
        
        UserDefaults.standard.set(true, forKey: kFirstMAtchOnV3Key)
        UserDefaults.standard.synchronize()

        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let matchPopup: NewMatchOverlayView =
            Bundle.main.loadNibNamed("NewMatchOverlayView", owner: window.rootViewController, options: nil)!.first as! NewMatchOverlayView
        matchPopup.frame = window.frame
        matchPopup.alpha = 0.0
        matchPopup.matchData = matchData
        matchPopup.buttonType = buttonType
        
        parent.addSubview(matchPopup)
        
        UIView.animate(withDuration: 0.4, animations: {
            matchPopup.alpha = 1.0
        }) 
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: WooNotifications.MatchOverlaySeen.rawValue), object: nil))
        
        return matchPopup
    }
    
    func changeTextOnButton(textOnButton buttonText: NSString) -> Void {
        startChatingButton.setTitle(buttonText as String, for: .normal)
    }
    
    func addActivityIndicatorToButton() -> Void {
        activityIndicatorViewObj = UIActivityIndicatorView.init(style: .gray)
//        let halfButtonHeight = startChatingButton.bounds.size.height / 2;
//        let buttonWidth = startChatingButton.bounds.size.width;
        activityIndicatorViewObj?.frame = CGRect(x: 4, y: 7, width: 25, height: 25)
        startChatingButton.addSubview(activityIndicatorViewObj!)
        activityIndicatorViewObj?.startAnimating()
    }
    
    func removeActivityIndicatorFromButton() -> Void {
        activityIndicatorViewObj?.removeFromSuperview()
        activityIndicatorViewObj?.stopAnimating()
        activityIndicatorViewObj = nil
    }
    func updateViewWithMatchData() {
        
        startChatingButton.layer.shadowColor = UIColor.gray.cgColor
        startChatingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        startChatingButton.layer.shadowRadius = 2.0
        startChatingButton.layer.shadowOpacity = 1.0
        startChatingButton.layer.cornerRadius = 3.0
        
        if matchData != nil {
            if matchData!["matchEventDto"] != nil {
                matchData = matchData!["matchEventDto"] as? NSDictionary
            }
            
            if let title = matchData!["title"] {
                self.titleLabel.text = title as? String
            }
            else{
                self.titleLabel.text = ""
            }
            if let text = matchData!["text"] {
                var yourString:String = text as! String
                yourString = yourString.replacingOccurrences(of: "/", with: "")
                let componentsArray = yourString.components(separatedBy: "<b>")
                yourString = yourString.replacingOccurrences(of: "<b>", with: "")
                if componentsArray.count > 2 {
                    let boldedString1 = componentsArray[1]
                    let boldedString2 = componentsArray[2]
                    
                    let lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 17.0)!]
                    let lString = NSMutableAttributedString(string: boldedString1, attributes: lAttribute)
                    let attrString = NSAttributedString(string: boldedString2)
                    lString.append(attrString)
                    
                    self.textLabel.attributedText = lString
                }
                else{
                    self.textLabel.text = yourString
                }
            }
            
            let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
            let heightOfScreen = window.frame.size.height * 0.24
            self.matchImageView.layer.masksToBounds = true
            self.matchImageView.layer.cornerRadius = heightOfScreen/2.0
//            let width_Height = Int(heightOfScreen)
            
            if let url = matchData!["requesterProfilePicture"] {
                print("url>>\(url)")
//                let encodedUrl: NSString =   Utilities().encode(fromPercentEscape: url as! String) as NSString
//                NSLog("encodedUrl %@", encodedUrl)
//
                let matchImageHeight = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:kCircularImageSize)
                let matchImageWidth = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:kCircularImageSize)
                
                let matchaImageURL = "?url=" + (url as! String)
                let matchaHeightOfURL = "&height=" + (NSString(format: "%d", matchImageHeight) as String)
                let matchaWidthOfURL = "&width=" + (NSString(format: "%d", matchImageWidth) as String)
                
                var matchUrlString = (url as! String)
                
                if matchUrlString.hasPrefix(kImageCroppingServerURL) == false {
                    matchUrlString = kImageCroppingServerURL + matchaImageURL + matchaHeightOfURL + matchaWidthOfURL
                }
                (Utilities.sharedUtility() as AnyObject).downloadMatchImage(forImageUrl: URL(string: matchUrlString))
                
                
                var width = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints: 150)
                var height = width * 3/2

                if(self.buttonType == .Keep_Swiping)
                {
                    width = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int32(UIScreen.main.bounds.size.width))
                    height = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints: Int32(UIScreen.main.bounds.size.height))
                }
            
                
                let aImageURL = "?url=" + (url as! String)
                let aHeightOfURL = "&height=" + (NSString(format: "%d", height) as String)
                let aWidthOfURL = "&width=" + (NSString(format: "%d", width) as String)
              
                var urlString = (url as! String)
                if urlString.hasPrefix(kImageCroppingServerURL) == false{
                     urlString = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
                }
               
                
                NSLog("urlString %@", urlString)
                matchImageView.sd_setImage(with: (URL(string:(urlString as String))), placeholderImage: UIImage(named: "ic_me_avatar_big"), options: SDWebImageOptions(), completed: { (imageObj, errorObj, SDImageCacheTypeDisk, urlObj) in
                    if imageObj != nil{
                        self.matchImageView.image = imageObj
                    }
                    self.matchImageView.layer.cornerRadius = heightOfScreen/2.0
                })
            }
            
            otherActivityButtonLabel.text = buttonType.rawValue
            
            otherActivityButtonIcon.image = UIImage(named: buttonType.buttonIcon())
            self.showglobeIcon(shouldShowGlobeIcon: (!WooGlobeModel.sharedInstance().isExpired && WooGlobeModel.sharedInstance().wooGlobleOption))
        }
    }
}
