//
//  ReviewPhotoCardModel.swift
//  Woo_v2
//
//  Created by Akhil Singh on 24/10/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum ReviewPhotoCardSubCardType : String{
    case UPDATE_PHOTOS
}

enum ReviewPhotoCardExpiryType : String{
    case PASS
}

enum ReviewPhotoCardMediaType : String{
    case IMAGE
}

class ReviewPhotoCardTagModel: NSObject {
    var tagId : String?
    var name : String?
}

class ReviewPhotoCardModel: NSObject {
    
    var subCardType : ReviewPhotoCardSubCardType = .UPDATE_PHOTOS
    
    var cardId : String?
    
    var cardDescription : String = ""
    
    var mediaUrls : WooAlbumModel?
    
    var buttonName : String?
    
    var actionUrl : URL?
    
    var expiryType : ReviewPhotoCardExpiryType = .PASS
    
    var mediaType : ReviewPhotoCardMediaType = .IMAGE
    
    var tags : [ReviewPhotoCardTagModel] = []
    
    init(cardInfo : [String : AnyObject]) {
        super.init()
        self.setReviewCardDataFromResponse(cardInfo)
    }
    
    func setReviewCardDataFromResponse(_ data: [String : AnyObject]) {
        self.cardId = "\(data["cardId"]!)"
        
        if (data["description"] != nil) {
            self.cardDescription = data["description"] as! String
        }
        else{
            self.cardDescription = ""
        }
        
        switch (data["subCardType"] as! String) {
        case "UPDATE_PHOTOS":
            self.subCardType = .UPDATE_PHOTOS
            break
        default:
            break
        }
        
        if let wooAlbum = data["wooAlbum"] {
            self.mediaUrls = WooAlbumModel()
            self.mediaUrls?.addObjectsFromArrayForReviewPhoto(wooAlbum as! [AnyObject])
        }
        
        buttonName = data["buttonName"] as? String
        
        if let actionUrl = data["actionUrl"]{
            self.actionUrl = URL(string: actionUrl as! String)
        }
        switch (data["expiryType"] as! String) {
        case "PASS":
            self.expiryType = .PASS
            break
        default:
            break
        }
        
        if let mediaType = data["mediaType"]{
            switch (mediaType as! String) {
            case "IMAGE":
                self.mediaType = .IMAGE
                break
            default:
                break
            }
        }
        
        if let tags : [NSDictionary] = data["tags"] as? [NSDictionary] {
            for item in tags {
                let tag : ReviewPhotoCardTagModel = ReviewPhotoCardTagModel()
                tag.tagId = item.object(forKey: "tagId") as? String
                tag.name = item.object(forKey: "name") as? String
                
                self.tags.append(tag)
            }
        }
    }
}
