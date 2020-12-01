 //
//  DiscoverEmptyManager.swift
//  Woo_v2
//
//  Created by Suparno Bose on 29/06/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

enum DiscoverEmptySubCardType : String {  // Swift 2.0; for < 2.0 use Printable
    case DISCOVER_EMPTY_PREFERENCES = "DISCOVER_EMPTY_PREFERENCES";
    case DISCOVER_EMPTY_SEARCH = "DISCOVER_EMPTY_SEARCH";
    case DISCOVER_EMPTY_PERSONAL_QUOTE = "DISCOVER_EMPTY_PERSONAL_QUOTE";
    case DISCOVER_EMPTY_PHOTO = "DISCOVER_EMPTY_PHOTO";
    case DISCOVER_EMPTY_TAGS = "DISCOVER_EMPTY_TAGS";
    case DISCOVER_EMPTY_BOOST = "DISCOVER_EMPTY_BOOST";
    case DISCOVER_EMPTY_PHONE_VERIFY = "DISCOVER_EMPTY_PHONE_VERIFY";
    case DISCOVER_EMPTY_WORK = "DISCOVER_EMPTY_WORK";
    case DISCOVER_EMPTY_EDUCATION = "DISCOVER_EMPTY_EDUCATION";
    case DISCOVER_EMPTY_LINKEDIN_VERIFY = "DISCOVER_EMPTY_LINKEDIN_VERIFY";
    case DISCOVER_EMPTY_HEIGHT = "DISCOVER_EMPTY_HEIGHT";
    case DISCOVER_EMPTY_NOTIFICATION = "DISCOVER_EMPTY_NOTIFICATION";
    case DISCOVER_EMPTY_FEEDBACK_APPSTORE = "DISCOVER_EMPTY_FEEDBACK_APPSTORE";
    case DISCOVER_EMPTY_FEEDBACK_INTERNAL = "DISCOVER_EMPTY_FEEDBACK_INTERNAL";
    case DISCOVER_EMPTY_MATCH = "DISCOVER_EMPTY_MATCH";
    case DISCOVER_EMPTY_DEFAULT = "DISCOVER_EMPTY_DEFAULT";
    case SEARCH_EMPTY_END = "SEARCH_EMPTY_END";
    case SEARCH_EMPTY_NO_RESULT = "SEARCH_EMPTY_NO_RESULT";
    case DISCOVER_EMPTY_DIASPORA = "DISCOVER_EMPTY_DIASPORA";
    case DISCOVER_EMPTY_DIASPORA_OFF = "DISCOVER_EMPTY_DIASPORA_OFF";
    case DISCOVER_EMPTY_DIASPORA_OFF_NEW = "DISCOVER_EMPTY_DIASPORA_OFF_NEW";
    case DISCOVER_EMPTY_WOOPLUS_PURCHASE = "DISCOVER_EMPTY_WOOPLUS_PURCHASE";
    case DISCOVER_EMPTY_GO_GLOBAL = "DISCOVER_EMPTY_GO_GLOBAL";
}

class DiscoverEmptyButtonModel: NSObject {
    var buttonText : String?
    var actionUrl : String?
}

class DiscoverEmptyModel: NSObject {
    var id : String?
    var title : String?
    var modelDescription : String?
    var buttons : [DiscoverEmptyButtonModel] = []
    var subCardType : DiscoverEmptySubCardType?
    
    var gettingUsedForTagSearch = false
    
    func setButtonData(_ dataArray: [NSDictionary]) {
        for button in dataArray {
            let buttonModel = DiscoverEmptyButtonModel()
            buttonModel.buttonText = (button as! Dictionary)["buttonText"]
            buttonModel.actionUrl = (button as! Dictionary)["actionUrl"]
            self.buttons.append(buttonModel)
        }
    }
}

class DiscoverEmptyManager: NSObject {
    
    static let sharedInstance = DiscoverEmptyManager()
    
    var discoverEmptyModelArray : [DiscoverEmptyModel] = []
    
    fileprivate override init() {
        super.init()
    }
    
    func addDiscoverEmptyModel(_ data: NSDictionary) -> DiscoverEmptyModel{
        
        if let currentEmptyModel = getDiscoverEmptyModelForType(DiscoverEmptySubCardType(rawValue: (data["subCardType"] as? String)!) ?? DiscoverEmptySubCardType(rawValue: "DISCOVER_EMPTY_DEFAULT")!) {
            if let index = discoverEmptyModelArray.index(of: currentEmptyModel) {
                discoverEmptyModelArray.remove(at: index)
            }
        }
        
        let lDiscoverEmptyModel = DiscoverEmptyModel();
        
        if let _id = data["id"] {
            lDiscoverEmptyModel.id = "\(_id)"
        }
        
        if let _title = data["title"] {
            lDiscoverEmptyModel.title = _title as? String
        }
        
        if let _modelDescription = data["description"] {
            lDiscoverEmptyModel.modelDescription = _modelDescription as? String
        }
        
        if let _buttons : [NSDictionary] = data["buttons"] as? [NSDictionary]{
            lDiscoverEmptyModel.setButtonData(_buttons)
        }
        
        if let _subCardType = data["subCardType"] {
            lDiscoverEmptyModel.subCardType =  DiscoverEmptySubCardType(rawValue: (_subCardType as? String)!)
        }
        
        discoverEmptyModelArray.append(lDiscoverEmptyModel)
        
        return lDiscoverEmptyModel
    }
    
    func count() -> Int {
        return discoverEmptyModelArray.count
    }
    
    func objectAtIndex(_ index: Int) -> AnyObject? {
        if discoverEmptyModelArray.count > index {
            return discoverEmptyModelArray[index]
        }
        return nil
    }
    
    func firstObject() -> AnyObject? {
        if discoverEmptyModelArray.count > 0 {
            return discoverEmptyModelArray.first
        }
        return nil
    }
    
    func removeFirstObject() {
        if discoverEmptyModelArray.count > 0 {
           discoverEmptyModelArray.removeFirst()
        }
    }
    
    func removeObjectsForType(_ cardType: DiscoverEmptySubCardType) -> Bool {
        if discoverEmptyModelArray.count > 0 {
            for discoverEmptyModel in discoverEmptyModelArray {
                if discoverEmptyModel.subCardType == cardType {
                    if let index = discoverEmptyModelArray.index(of: discoverEmptyModel) {
                        discoverEmptyModelArray.remove(at: index)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func getDiscoverEmptyModelForType(_ cardType: DiscoverEmptySubCardType) -> DiscoverEmptyModel? {
        if discoverEmptyModelArray.count > 0 {
            for discoverEmptyModel in discoverEmptyModelArray {
                if discoverEmptyModel.subCardType == cardType {
                    return discoverEmptyModel
                }
            }
        }
        return nil
    }
}
