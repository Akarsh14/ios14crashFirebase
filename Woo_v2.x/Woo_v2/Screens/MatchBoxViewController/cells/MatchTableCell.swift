//
//  MatchTableCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 27/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MatchTableCell: UITableViewCell {
    
    @IBOutlet weak var newMatchLabelView: UIView!
    @IBOutlet weak var matchChatText: UILabel!
    
    @IBOutlet weak var matchUserImageView: UIImageView!
    
    @IBOutlet weak var matchUserNameLabel: UILabel!
    
    @IBOutlet weak var crushBoostIndicatorImage: UIImageView!
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var errorMsgLbl: UILabel!
    
    @IBOutlet weak var seperatorView: UIView!
   
    @IBOutlet weak var replyIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteMatchButton: UIButton!
    
    var getMatchObjectHandler:((MyMatches)->Void)!
    
    var matchesObject:MyMatches?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        newMatchLabelView.layer.cornerRadius = 12.0
        newMatchLabelView.layer.masksToBounds = true
        newMatchLabelView.layer.borderColor = UIColorHelper.color(withRGBA: "#75DB87").cgColor
        newMatchLabelView.layer.borderWidth = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func moveToProfile(_ sender: Any) {
        if getMatchObjectHandler != nil{
            if let matchObject = matchesObject{
                getMatchObjectHandler(matchObject)
            }
        }
    }
    
    
    func setImageIfMatchFrom(_ source: NSString?) -> Void {
        
        if ((source == nil) || (source!.length == 0)) {
            crushBoostIndicatorImage.isHidden = true
        }
        else{
            crushBoostIndicatorImage.isHidden = false
            if ((source?.isEqual(to: "BOOST")) == true) {
                crushBoostIndicatorImage.image = UIImage(named:"ic_matchbox_boost")
            }
            else if ((source?.isEqual(to: "CRUSH")) == true){
                crushBoostIndicatorImage.image = UIImage(named:"ic_matchbox_crush")
            
            }else if ((source?.isEqual(to: "GLOBE")) == true){
                crushBoostIndicatorImage.image = UIImage(named:"WooGlobe_Matchbox")                
            }
        }
    }
    
    func setDataOnCellFromObj(myMatchesData: MyMatches?){
            
            if myMatchesData == nil {
                return
            }
            matchesObject = myMatchesData
            matchUserNameLabel.text = myMatchesData!.matchUserName
            matchChatText.numberOfLines = 1
            //Setting user image
            matchUserImageView.image = UIImage(named: "ic_me_avatar_big")
            if let urlString = myMatchesData!.matchUserPic{
                if myMatchesData!.matchUserPic!.hasPrefix(kImageCroppingServerURL) == false{
                    matchUserImageView.sd_setImage(with: (NSURL(string: urlString as String) as URL?), placeholderImage: UIImage(named: "ic_me_avatar_big"))
                }
                else
                {
                    matchUserImageView.sd_setImage(with: (NSURL(string: urlString as String) as URL?), placeholderImage: UIImage(named: "ic_me_avatar_big"))
                }
            }
            //UI modifications for read unread status
            if let isReadNumber = myMatchesData!.isRead{
            let isReadBool = isReadNumber.boolValue
                
                    if isReadBool {
                        print("isReadBool >>>\(isReadBool)")
                        matchChatText.font = UIFont(name: "Lato-Regular", size:15)
                        matchChatText.textColor = UIColorHelper.color(withRGBA: "#9097AF")
                        errorMsgLbl.font = UIFont(name: "Lato-Regular", size:15)
                        errorMsgLbl.textColor = UIColorHelper.color(withRGBA: "#4B4F5C")
                        self.contentView.backgroundColor = UIColor.clear
                        
                    }
                    else{
                        matchChatText.font = UIFont(name: "Lato-Bold", size:15)
                        matchChatText.textColor = UIColorHelper.color(withRGBA: "#4B4F5C")
                        errorMsgLbl.font = UIFont(name: "Lato-Bold", size:15)
                        errorMsgLbl.textColor = UIColorHelper.color(withRGBA: "#4B4F5C")
                        blurView.backgroundColor = Utilities().getUIColorObject(fromHexString: "#F3F3F3", alpha: 0.7)

                    }
                
                matchUserNameLabel.textColor = Utilities().getUIColorObject(fromHexString: "#5E6374", alpha: 1.0)

            }
        
            //Set chat snippet text
            if let chatSnipt: String = myMatchesData!.chatSnippet{
                if (chatSnipt.count > 0 && chatSnipt.contains("Matched on") == false)
                {
                    matchChatText.text = chatSnipt;
                    newMatchLabelView.isHidden = true
                }
                else{
                    newMatchLabelView.isHidden = false
                    matchChatText.text = "Start the conversation"
                    let isReadBool = myMatchesData?.isRead
                    if (isReadBool != nil && isReadBool == true) {
                        matchChatText.font = UIFont(name: "Lato-Italic", size:15)
                        matchChatText.textColor = UIColorHelper.color(withRGBA: "#4B4F5C")
                    }
                    else
                    {
                        matchChatText.font = UIFont(name: "Lato-BoldItalic", size:15)
                        matchChatText.textColor = UIColorHelper.color(withRGBA: "#4B4F5C")
                    }
                    
                }
            }
        
        var matchUserID = ""
        if myMatchesData?.chatServer == kisAppLozicServer{
            matchUserID = myMatchesData?.targetAppLozicId ?? ""
        }
        else{
            matchUserID = myMatchesData?.matchedUserId ?? ""
        }
        if(myMatchesData?.chatSnippetUserId != nil && (myMatchesData?.chatSnippetUserId.count) ?? 0 > 0 && myMatchesData?.chatSnippetUserId != matchUserID)
                {
                    replyIconWidthConstraint.constant = 11
                }
               else
               {
                    replyIconWidthConstraint.constant = 0
                }
            // Setting source if match from crush, boost, globe.
            setImageIfMatchFrom(myMatchesData?.source as NSString?)
            
            if myMatchesData!.matchedUserStatus.intValue != Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue) {
                if myMatchesData!.matchedUserStatus.intValue == Int(MATCHED_USER_STATUS_ESTABLISHING_CONNECTION.rawValue) {
                    errorMsgLbl.text = "Establishing connection"
                    matchChatText.text = "Establishing connection"
                }
                else{
                    errorMsgLbl.text = "Tap to retry"
                    matchChatText.text = "Tap to retry"
                }
                errorMsgLbl.font = UIFont(name: "Lato-Bold", size:15)
                errorMsgLbl.textColor = UIColorHelper.color(withRGBA: "#4B4F5C")
                blurView.isHidden = false
                errorMsgLbl.isHidden = false
                matchChatText.alpha = 0
                blurView.backgroundColor = Utilities().getUIColorObject(fromHexString: "#F3F3F3", alpha: 0.7)
                seperatorView.backgroundColor = Utilities().getUIColorObject(fromHexString: "#E0E0E0", alpha: 0.7)
            }
            else{
                blurView.isHidden = true
                errorMsgLbl.isHidden = true
                matchChatText.alpha = 1
                seperatorView.backgroundColor = Utilities().getUIColorObject(fromHexString: "#E0E0E0", alpha: 0.7)
            }
            if((myMatchesData?.isDel != nil) && myMatchesData?.isDel.boolValue == true) || (myMatchesData?.isTargetFlagged != nil && myMatchesData?.isTargetFlagged.boolValue == true)
            {
                //change blur color
                blurView.isHidden = false
                blurView.backgroundColor = UIColorHelper.color(fromRGB: "#F3F3F3", withAlpha: 0.7)
                self.contentView.backgroundColor = UIColor.clear
                seperatorView.backgroundColor = Utilities().getUIColorObject(fromHexString: "#E0E0E0", alpha: 0.7)
                matchChatText.font = UIFont(name: "Lato-Regular", size:15)


                if((myMatchesData?.isDel != nil) && myMatchesData?.isDel.boolValue == true)
                {
                    deleteMatchButton.isHidden = false
                    matchChatText.text = "\(myMatchesData!.matchUserName ?? "") has left this chat"
                }
                else
                {
                    deleteMatchButton.isHidden = true
                    self.contentView.bringSubviewToFront(matchChatText)
                    matchChatText.numberOfLines = 2
                    matchChatText.text = "\(myMatchesData!.matchUserName ?? "") was reported by our community and is being reviewed."

                }
            }
            else
            {
               // blurView.isHidden = true
                deleteMatchButton.isHidden = true
            }
    }
}
        
