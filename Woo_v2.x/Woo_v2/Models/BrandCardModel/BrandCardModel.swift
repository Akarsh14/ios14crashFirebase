//
//  BrandCardModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 20/06/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

enum SubCardType : String{
    case EXTERNAL
    case GET_BOOSTED
    case ACTIVATE_BOOST
    case SEND_CRUSH
    case WOOPLUS
    case WOOGLOBE
}

enum ExpiryType : String{
    case PASS
    case CLICK
    case NEXT_LAUNCH
    case NEXT_DAY
}

enum MediaType : String{
    case IMAGE
    case GIF
    case VIDEO
}

class BrandCardTagModel: NSObject {
    var tagId : String?
    var name : String?
}

class BrandCardModel: NSObject {
    
    var subCardType : SubCardType = .EXTERNAL
    
    var cardId : String?
    
    var title : String?
    
    var cardDescription : String = ""
    
    var mediaUrls : WooAlbumModel?
    
    var buttonName : String?
    
    var actionUrl : URL?
    
    var expiryType : ExpiryType = .PASS
    
    var mediaType : MediaType = .IMAGE
    
    var mutualFriendCount : Int = 0
    
    var mutualFriendFirstImageUrl : URL?
    
    var logoUrl : URL?
    
    var moreInfo : String?
    
    var tags : [BrandCardTagModel] = []
    
    var isBrandCardSeen:Bool = false
    
    init(cardInfoDto : [String : AnyObject]) {
        super.init()
        self.setBrandCardDataFromResponse(cardInfoDto)
    }
    
    func setBrandCardDataFromResponse(_ data: [String : AnyObject]) {
        self.cardId = "\(data["cardId"]!)"
        
        self.title = data["title"] as? String
        
        if (data["description"] != nil) {
            self.cardDescription = data["description"] as! String
        }
        else{
            self.cardDescription = ""
        }
        
        switch (data["subCardType"] as! String) {
        case "EXTERNAL":
            self.subCardType = .EXTERNAL
            break
        case "GET_BOOSTED":
            self.subCardType = .GET_BOOSTED
            break
        case "ACTIVATE_BOOST":
            self.subCardType = .ACTIVATE_BOOST
            break
        case "SEND_CRUSH":
            self.subCardType = .SEND_CRUSH
            break
        case "WOOPLUS":
            self.subCardType = .WOOPLUS
            break
        case "WOOGLOBE":
            self.subCardType = .WOOGLOBE
            break

        default:
            break
        }
        
        if let wooAlbum = data["mediaUrls"] {
            self.mediaUrls = WooAlbumModel()
            self.mediaUrls!.addObjectsFromArray(wooAlbum as! [AnyObject])
        }
        
        buttonName = data["buttonName"] as? String
        
        if let actionUrl = data["actionUrl"]{
        self.actionUrl = URL(string: actionUrl as! String)
        }
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
        
        if let mutualFriendFirstImageUrl : String = data["mutualFriendFirstImageUrl"] as? String {
            self.mutualFriendFirstImageUrl = URL(string: mutualFriendFirstImageUrl)
        }
        
        if let logoUrl : String = data["logoUrl"] as? String {
            self.logoUrl = URL(string: logoUrl)
        }        
        
        if let tags : [NSDictionary] = data["tags"] as? [NSDictionary] {
            for item in tags {
                let tag : BrandCardTagModel = BrandCardTagModel()
                tag.tagId = item.object(forKey: "tagId") as? String
                tag.name = item.object(forKey: "name") as? String
                
                self.tags.append(tag)
            }
        }
        
        if let _moreInfo : String = data["moreInfo"] as? String {
            moreInfo = _moreInfo
        }
    }
}
