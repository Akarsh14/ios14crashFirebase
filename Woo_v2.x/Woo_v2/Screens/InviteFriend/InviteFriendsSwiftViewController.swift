//
//  InviteFriendsSwiftViewController.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 27/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import FBSDKMessengerShareKit
import Social
import Applozic


class InviteFriendsSwiftViewController: BaseClassViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    let tagImageViewIcon = 70001
    let tagLableTitle = 70002
    let Iphone_5S_WidthSpacing:CGFloat = 3
    var inset: CGFloat = 28
    let minimumLineSpacing: CGFloat = 5
    let minimumInteritemSpacing: CGFloat = 10
    let cellsPerRow = 4
    
    @IBOutlet weak var inviteMessageLabel: UILabel!
    @IBOutlet weak var inviteCollObj: UICollectionView!
    var inviteReferalArray : NSArray!
    var inviteMessageText: String!
    var inviteImageBaseURL: String!
    var dynamicHeight:CGFloat = 0
    let inviteFrndVCObj = InviteFriendViewController()
    
    
    //MARK:- View Lify cycle
    /// Description: This is the initial View loading Method
    /// Parameter: Nil
    /// Returns: Nil
    override func viewDidLoad() {
        super.viewDidLoad()
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_Landing")
        dynamicHeight = (SCREEN_WIDTH == Iphone_5S_Size.width) ? 27 : (SCREEN_HEIGHT > Iphone_6P_Size.height) ? 18 : 22
        getCachedInviteDataFromServer()
    }
    
    /// Description: This method will load after view did load method
    /// Parameter: Nil
    /// Returns: Nil
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorTheStatusBar(withColor: NavBarStyle.invite.color())
        self.navigationController?.isNavigationBarHidden = true
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(InviteFriendsSwiftViewController.backButton))
    }
    
    
    /// Initial Nib which will be called
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.invite, animated: false)
        self.navBar?.setTitleText(NSLocalizedString("Invite Friends", comment: ""))
    }
    
    //MARK:- IBActions
    /// Description: This method will when user clicks on the back button in the navigation pane
    /// Parameter: Nil
    /// Returns: Nil
    @IBAction func backButton(){
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- CollectionView Delegates
    ///*******************************-CollectionView Delegates Start-*******************************///
    /// Description: These are all collectionview delegates
    /// Parameter: Nil
    /// Returns: Nil
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (SCREEN_WIDTH == Iphone_5S_Size.width){
            return Iphone_5S_WidthSpacing
        }
        else{
            return minimumInteritemSpacing
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        var spacing = minimumInteritemSpacing
        if SCREEN_WIDTH == Iphone_5S_Size.width{
            spacing = Iphone_5S_WidthSpacing
        }
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (spacing * CGFloat(cellsPerRow - 1))
        let cellWidth:CGFloat = (collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow)
        return CGSize(width: cellWidth, height: cellWidth + dynamicHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if inviteReferalArray != nil  {
            return inviteReferalArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellDataFromServer: NSDictionary = inviteReferalArray.object(at: indexPath.row) as! NSDictionary
        let socialMediaType = Int(truncating: cellDataFromServer.object(forKey:"socialMediaId") as! NSNumber)
        var title = ""
        var subtitle = ""
        switch socialMediaType {
        case 1:
            //facebook
            title = NSLocalizedString("Facebook", comment: "")
            subtitle = NSLocalizedString("Invite friends from Facebook Messanger", comment: "")
            break
        case 2,7:
            //whatapp
            title = NSLocalizedString("WhatsApp", comment: "")
            break
        case 3,8:
            //Email
            title = NSLocalizedString("Email", comment: "")
            break
        case 4,9:
            //Twitter
            title = NSLocalizedString("Twitter", comment: "")
            subtitle = NSLocalizedString("Post on my timeline", comment: "")
            break
        case 5,10:
            //Copy link
            title = NSLocalizedString("Copy Link", comment: "")
            break
        case 6,11:
            //Others
            title = NSLocalizedString("Others", comment: "")
            break
            
        default:
            //nothing
            break
        }
        let cellIdentifier = "InviteCollectionTitleSubTitleCell"
        let cellObj = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let imageIcon = cellObj.viewWithTag(tagImageViewIcon) as! UIImageView
        let lbltitle = cellObj.viewWithTag(tagLableTitle) as! UILabel
        if subtitle.count > 0 {
            let ImageUrl: String = NSString(format: "%@IOS/%@",inviteImageBaseURL,(cellDataFromServer.object(forKey: "referMediaImg") as! String)) as String
            imageIcon.sd_setImage(with: URL(string: ImageUrl))
            lbltitle.text = title
            return cellObj
        }
        else{
            let ImageUrl: String = NSString(format: "%@IOS/%@",inviteImageBaseURL,(cellDataFromServer.object(forKey: "referMediaImg") as! String)) as String
            imageIcon.sd_setImage(with: URL(string: ImageUrl))
            lbltitle.text = title
            return cellObj
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellDataFromServer: NSDictionary = inviteReferalArray.object(at: indexPath.row) as! NSDictionary
        let socialMediaType = Int(truncating: cellDataFromServer.object(forKey:"socialMediaId") as! NSNumber)
        
        switch socialMediaType {
        case 1:
            //Facebook
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_FB_Tap")
            shareViaFacebook(shareDetail: cellDataFromServer)
            break
        case 2,7:
            //WhatsApp
           
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_Whatsapp_Tap")
            inviteFrndVCObj.sendWhatsApp(withDetail: cellDataFromServer as Any? as! [AnyHashable : Any]?)
            break
        case 3,8:
            //Email
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_Mail_Tap")
            inviteFrndVCObj.sendEmail(on: self, withEmailDetail: cellDataFromServer as Any? as! [AnyHashable : Any]?)
            break
        case 4,9:
            //Twitter
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_Twitter_Tap")
            
            shareViaTwitter(shareDetail: cellDataFromServer)
            break
        case 5,10:
            //Copy Link
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_CopyLink_Tap")
            copyTextToClipBoard(shareDetail: cellDataFromServer)
            break
        case 6,11:
            // Others
            (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "InviteScreenLanding", withEventName: "3-InviteScreen.InviteScreenLanding.IS_Others_Tap")
            openOptionSheet(shareDetail: cellDataFromServer)
            break
        default:
            //nothing
            break
        }
    }
    
    
    ///*******************************-CollectionView Delegates End-*******************************///
    
    
    //MARK:- Server Calls
    /// Description: This method will get the data from the server and reload the collectionView
    /// Parameter: Nil
    /// Returns: Nil
    
    func getInviteDataFromServer()
    {
        InviteFriendAPIClass.getInviteCampaignDataFromServer { (success, response) in
            if success{
                if response != nil{
                    let responseDict: NSDictionary = response as! NSDictionary
                    
                    let responseDictKeys: NSArray = responseDict.allKeys as NSArray
                    
                    if responseDictKeys.contains("campaignDesc") {
                        self.inviteMessageText = responseDict.object(forKey: "campaignDesc") as? String
                    }
                    if responseDictKeys.contains("appReferMediaList"){
                        self.inviteReferalArray = responseDict.object(forKey: "appReferMediaList") as? NSArray
                    }
                    if responseDictKeys.contains("referMediaImgBasePath"){
                        self.inviteImageBaseURL = responseDict.object(forKey: "referMediaImgBasePath") as? String
                    }
                    DispatchQueue.main.async {
                        self.inviteMessageLabel.text = self.inviteMessageText
                        self.inviteCollObj.reloadData()
                    }
                }
            }
        }
    }
    
    
    /// Description: This method will get the data from the cached server and if not it will call getInviteDataFromServer()
    /// Parameter: Nil
    /// Returns: Nil
   
    func getCachedInviteDataFromServer()
    {
        InviteFriendAPIClass.getCachedInviteCampaignDataFromServer { (success, response) in
            if success{
                if response != nil{
                    let responseDict: NSDictionary = response as! NSDictionary
                    
                    let responseDictKeys: NSArray = responseDict.allKeys as NSArray
                    
                    if responseDictKeys.contains("campaignDesc") {
                        self.inviteMessageText = responseDict.object(forKey: "campaignDesc") as! String
                    }
                    if responseDictKeys.contains("appReferMediaList"){
                        self.inviteReferalArray = responseDict.object(forKey: "appReferMediaList") as! NSArray
                    }
                    if responseDictKeys.contains("referMediaImgBasePath"){
                        self.inviteImageBaseURL = responseDict.object(forKey: "referMediaImgBasePath") as! String
                    }
                    DispatchQueue.main.async {
                        self.inviteMessageLabel.text = self.inviteMessageText
                        self.inviteCollObj.reloadData()
                    }
                }else{
                    self.getInviteDataFromServer()
                }
               
            }
            else
            {
                self.getInviteDataFromServer()
            }
        }
    }
    
 
    //MARK:- Sharing Methods
    /// Description: This method will helpful to share the link Via twitter
    /// Parameter: shareDetails
    /// Returns: Nil
    
    func shareViaTwitter(shareDetail: NSDictionary) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            let shareText = NSString(format: "%@\n %@: %@ \n %@: %@", shareDetail.object(forKey: "referMediaDesc") as! String,"Download Android Link",shareDetail.object(forKey: "androidTinyUrl") as! String, "Download IOS Link",shareDetail.object(forKey: "iosTinyUrl") as! String)
            twitterSheet.setInitialText(shareText as String?)
            twitterSheet.add(URL(string:"http://www.getwooapp.com/"))
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /// Description: This method will helpful to share the link Via twitter
    /// Parameter: shareDetails
    /// Returns: Nil
    func shareViaFacebook(shareDetail: NSDictionary) {
        /*
        let shareText_post = NSString(format: "%@ \n\n %@: %@ \n\n %@: %@", shareDetail.object(forKey: "referMediaDesc") as! String,"Download Android Link",shareDetail.object(forKey: "androidTinyUrl") as! String, "Download IOS Link",shareDetail.object(forKey: "iosTinyUrl") as! String)
        let contentObj: FBSDKShareLinkContent = FBSDKShareLinkContent()
        contentObj.contentURL =  URL(string:"http://www.getwooapp.com/") as URL?
        contentObj.quote = shareText_post as String?
        let shareDialog = FBSDKShareDialog()
        shareDialog.fromViewController = self
        shareDialog.shareContent = contentObj
        if shareDialog.canShow() {
            shareDialog.show()
        }
        else
        {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
 */
    }
    
    
    /// Description: This method will helpful to share the whatsapp
    /// Parameter: Nil
    /// Returns: Nil
    
    func sendWhatApp() {
        var messageBody = NSLocalizedString("Text for whatsapp", comment: "")
        messageBody = NSString(format: "%@<br><br>%@", messageBody, UserDefaults.value(forKey: "wooUserName") as! String) as String
        var urlWhats = NSString(format: "whatsapp://send?text=%@", messageBody) as String
        urlWhats = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let whatsAppURL: NSURL = NSURL(string: urlWhats)!
        UIApplication().openURL(whatsAppURL as URL)
    }
    
    /// Description: This method will helpful to share the link Via More Options
    /// Parameter: shareDetails
    /// Returns: Nil
    
    func openOptionSheet(shareDetail: NSDictionary) {
        let shareText = NSString(format: "%@\n %@: %@ \n %@: %@", shareDetail.object(forKey: "referMediaDesc") as! String,"Download Android Link",shareDetail.object(forKey: "androidTinyUrl") as! String, "Download IOS Link",shareDetail.object(forKey: "iosTinyUrl") as! String)
        var sharingItems = [AnyObject]()
        sharingItems.append(shareText as AnyObject)
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /// Description: This method will helpful to copy text
    /// Parameter: shareDetails
    /// Returns: Nil
    
    func copyTextToClipBoard(shareDetail: NSDictionary) {
        let shareText = NSString(format: "%@\n %@: %@ \n %@: %@", shareDetail.object(forKey: "referMediaDesc") as! String,"Download Android Link",shareDetail.object(forKey: "androidTinyUrl") as! String, "Download IOS Link",shareDetail.object(forKey: "iosTinyUrl") as! String)
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = shareText as String
        showSnackBar("Copied to Clipboard")
    }
    
    
    /// Description: This method will show the alert on the top
    /// Parameter: Text
    /// Returns: Nil
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
}
