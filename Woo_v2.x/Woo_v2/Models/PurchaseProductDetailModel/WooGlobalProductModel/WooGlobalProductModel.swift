//
//  WooGlobalProductModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 15/11/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import StoreKit

class WooGlobalProductModel: NSObject {

    var backGroundImages : [String] = []
    var baseImageUrl = ""
    var carousalType = ""
    var circleImage : String?
    
    var carousals : [NSDictionary] = []
    var wooProductDto : [NSDictionary]?
    var isToShowMostPopular : NSNumber?
    var skProducts:NSArray?
    
    init(data dictData : NSDictionary) {
        if(dictData.allKeys.count == 0)
        {
            return
        }
        self.backGroundImages = dictData.object(forKey: kPurchaseProductBackGroundImages) as? [String] ?? []
        
        self.baseImageUrl = (dictData.object(forKey: kPurchaseProductBaseUrl) as! String) + "iOS/drawable-@3x/"
        
        self.carousalType = dictData.object(forKey: kPurchaseProductCarousalType) as! String
        
        self.circleImage = dictData.object(forKey: kPurchaseProductCircleImage) as? String
        
        self.wooProductDto = dictData.object(forKey: kPurchaseProductWooProductDto) as! [NSDictionary]?
        
        self.carousals = dictData.object(forKey: kPurchaseProductCarousals) as! [NSDictionary];
        
        self.isToShowMostPopular = NSNumber(value: dictData.object(forKey: kIsToShowMostPopular) as? Bool ?? false)
        (Utilities.sharedUtility() as AnyObject).precacheCarouselData(withData: carousals, circleImage: circleImage, backgroundImage: backGroundImages, andBaseURL: baseImageUrl)
        
    }
    
   @objc required init?(coder decoder: NSCoder) {
        super.init()
        //decode properties, other class vars
        self.backGroundImages = decoder.decodeObject(forKey: "backGroundImages")! as! [String]
        self.baseImageUrl = decoder.decodeObject(forKey: "baseImageUrl")! as! String
        self.carousalType = decoder.decodeObject(forKey: "carousalType")! as! String
        self.circleImage = decoder.decodeObject(forKey: "circleImage") as? String
        self.wooProductDto = decoder.decodeObject(forKey: "wooProductDto") as? [NSDictionary]
        self.carousals = decoder.decodeObject(forKey: "carousals")! as! [NSDictionary]
        self.isToShowMostPopular = decoder.decodeObject(forKey: "isToShowMostPopular") as? NSNumber
        self.skProducts = decoder.decodeObject(forKey: "skProducts") as? NSArray
    }
    
    func encode(withCoder encoder: NSCoder) {
        //Encode properties, other class variables, etc
        encoder.encode(self.backGroundImages, forKey: "backGroundImages")
        encoder.encode(self.baseImageUrl, forKey: "baseImageUrl")
        encoder.encode(self.carousalType, forKey: "carousalType")
        encoder.encode(self.circleImage, forKey: "circleImage")
        encoder.encode(self.wooProductDto, forKey: "wooProductDto")
        encoder.encode(self.carousals, forKey: "carousals")
        encoder.encode(self.isToShowMostPopular, forKey: "isToShowMostPopular")
        encoder.encode(self.skProducts, forKey: "skProducts")

    }
    
    func getProductToBePurchased(storeId:String) -> SKProduct?{
        for product in self.skProducts!{
            if (product as! SKProduct).productIdentifier == storeId{
                return product as? SKProduct
            }
        }
        return nil
    }
}
