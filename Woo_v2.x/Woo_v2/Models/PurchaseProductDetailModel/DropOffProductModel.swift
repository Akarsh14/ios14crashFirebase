//
//  DropOffProductModel.swift
//  Woo_v2
//
//  Created by Ankit Batra on 25/07/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class DropOffProductModel: NSObject {
    var maxCountInDay : Int?
    var maxCountInLifeTime : Int?
    var productDto : [NSDictionary]?
    
    init(data dictData : NSDictionary) {
        self.maxCountInDay = dictData.object(forKey: kMaxCountInDay) as? Int ?? 0
        
        self.maxCountInLifeTime = dictData.object(forKey: kMaxCountInLifeTime)  as? Int ?? 0
        self.productDto = dictData.object(forKey: kPurchaseProductWooProductDto) as?[NSDictionary]
        
    }
   
    required init?(coder decoder: NSCoder) {
        super.init()
        //decode properties, other class vars
        self.maxCountInDay = decoder.decodeObject(forKey: "maxCountInDay") as? Int
        self.maxCountInLifeTime = decoder.decodeObject(forKey: "maxCountInLifeTime") as? Int
        self.productDto = decoder.decodeObject(forKey: "wooProductDto") as? [NSDictionary]
    }
    
    func encode(withCoder encoder: NSCoder) {
        //Encode properties, other class variables, etc
        encoder.encode(self.maxCountInDay, forKey: "maxCountInDay")
        encoder.encode(self.maxCountInLifeTime, forKey: "maxCountInLifeTime")
        encoder.encode(self.productDto, forKey: "wooProductDto")
        
    }

}
