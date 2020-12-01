//
//  SelectionCardModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 21/10/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

enum SelectionSubCardType : String{
    case ETHNICITY  = "ETHNICITY"
    case RELIGION   = "RELIGION"
    case TAGS       = "TAGS"
    case PERSONAL_QUOTE = "PERSONAL_QUOTE"
    case WORK_EDUCATION = "WORK_EDUCATION"
    case ANALYZE_PROFILE = "ANALYZE_PROFILE"
    case NONE       = ""
}

class SelectionCardModel: NSObject {
    var cardId = ""
    var headerText = ""
    var subHeaderText = ""
    var footerText = ""
    var buttonText = ""
    var imageUrl = ""
    var maxSelection = 0
    var ctaIconAvailable = false
    var tags : [ProfessionModel] = []
    var subCardType : SelectionSubCardType = .NONE
    var descriptionText: String = ""
    var actionUrl = ""
    
    init(cardInfoDto : [String : AnyObject]) {
        super.init()
        self.setSelectionCardDataFromResponse(cardInfoDto)
    }
    
    func setSelectionCardDataFromResponse(_ data: [String : AnyObject]) {
        
        if let cardID = data["cardId"]{
        self.cardId = "\(cardID as! NSNumber)"
        }
        
        if let topHeaderText = data["topHeaderText"]{
            self.subHeaderText = topHeaderText as! String
        }
        
        if let textForButton = data["buttonText"]{
            self.buttonText = textForButton as! String
        }
        
        if let header = data["headerText"]{
            self.headerText = header as! String
        }
        
        if let description = data["description"]{
        self.descriptionText = description as! String
        }
        
        if data["footerText"] != nil {
            self.footerText = data["footerText"] as! String
        }
        
        if let actionUrlString = data["actionUrl"]{
            actionUrl = actionUrlString as! String
        }
        
        if let imageString = data["image"]{
            self.imageUrl = imageString as! String
        }
        
        if let maxSelection : NSNumber = data["maxSelection"] as? NSNumber {
            self.maxSelection = Int(maxSelection)
        }
        
        if let ctaIconAvailablity = data["ctaIconAvailable"] as? NSNumber{
            ctaIconAvailable = ctaIconAvailablity.boolValue
        }
        
        
        if let _tags : [NSDictionary] = data["tagsDto"] as? [NSDictionary] {
            tags.removeAll()
            for item in _tags {
                let tag : ProfessionModel = ProfessionModel()
                tag.tagId = "\((item.object(forKey: "tagId") as? NSNumber)!)"
                tag.name = item.object(forKey: "name") as? String
                self.tags.append(tag)
            }
        }
        
        if let _subCardType : String = data["subCardType"] as? String{
            self.subCardType = SelectionSubCardType(rawValue: _subCardType)!
        }
    }
}
