//
//  NewUserNoPicCardModel.swift
//  Woo_v2
//
//  Created by Akhil Singh on 24/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit


enum SubCardTypeForNewUserNoPic : String{
    case NEW_USER_NO_PIC
}

enum MediaTypeForNewUserNoPic : String{
    case IMAGE
    case GIF
    case VIDEO
}

enum ExpiryTypeForNewUserNoPic : String{
    case PASS
    case CLICK
    case NEXT_LAUNCH
    case NEXT_DAY
}

class NewUserNoPicCardModel: NSObject {
    
    var subCardType : SubCardTypeForNewUserNoPic = .NEW_USER_NO_PIC
    
    var cardId : String?
        
    var cardDescription : String = ""
    
    var mediaUrls : WooAlbumModel?
    
    var buttonName : String?
    
    var expiryType : ExpiryTypeForNewUserNoPic = .NEXT_DAY
    
    var mediaType : MediaTypeForNewUserNoPic = .IMAGE
    
    var mutualFriendCount : Int = 0
    
    init(cardInfoDto : [String : AnyObject]) {
        super.init()
        self.setNewUserNoPicCardDataFromResponse(cardInfoDto)
    }
    
    func setNewUserNoPicCardDataFromResponse(_ data: [String : AnyObject]) {
        self.cardId = data["cardId"] as? String
        
        if let desc = data["description"] {
            self.cardDescription = desc as! String

        }
        switch (data["subCardType"] as! String) {
        case "NEW_USER_NO_PIC":
            self.subCardType = .NEW_USER_NO_PIC
            break
            default:
            break
        }
        
        if let wooAlbum = data["mediaUrls"] {
            self.mediaUrls = WooAlbumModel()
            self.mediaUrls!.addObjectsFromArray(wooAlbum as! [AnyObject])
        }
        
        buttonName = data["buttonName"] as? String
        
        switch (data["expiryType"] as! String) {
        case "PASS":
            self.expiryType = .PASS
            break
        case "CLICK":
            self.expiryType = .CLICK
            break
        case "NEXT_LAUNCH":
            self.expiryType = .NEXT_LAUNCH
            break
        case "NEXT_DAY":
            self.expiryType = .NEXT_DAY
            break
        default:
            break
        }
        
        if let mediaType = data["mediaType"]{
            switch (mediaType as! String) {
            case "IMAGE":
                self.mediaType = .IMAGE
                break
            case "GIF":
                self.mediaType = .GIF
                break
            case "VIDEO":
                self.mediaType = .VIDEO
                break
            default:
                break
            }
        }
        if let mutualFriendCount : NSNumber = data["mutualFriendCount"] as? NSNumber {
            self.mutualFriendCount = Int(mutualFriendCount)
        }
        
    }
}
