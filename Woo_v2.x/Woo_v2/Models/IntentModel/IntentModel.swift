//
//  IntentModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 11/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

 class IntentModel: NSObject {
    @objc var maxAge : NSNumber = 50
    @objc var minAge : NSNumber = 18
    @objc var maxAllowedAge :NSNumber = 65
    @objc var minAllowedAge : NSNumber = 18
    @objc var interestedGender : String = "FEMALE"
    @objc  var maxDistance : NSNumber = 2147483647
    @objc var favIntent:String = "LOVE"
    @objc var isKms:NSNumber = true
    @objc var intentAgeDifferenceThreshold:NSNumber = 4
    @objc var modelHasBeenUpdatedByServer:NSNumber = false
    @objc var showLocation:NSNumber = false
    @objc var showGoGlobal: NSNumber = false
    @objc var showGoGlobalButton : NSNumber = false
    
    override init(){
        super.init()

    }
    
    
    /*!
     * @discussion initialiser with decoder parameter
     * @param aDecoder decoder of the class
     */
   @objc required internal init(coder aDecoder: NSCoder) {
        if (aDecoder.decodeObject(forKey: "maxAge") != nil){
        self.maxAge                  = (aDecoder.decodeObject(forKey: "maxAge") as? NSNumber)!
        }
        else{
            self.maxAge = 50
        }
        
        if (aDecoder.decodeObject(forKey: "minAge") != nil){
        self.minAge                  = (aDecoder.decodeObject(forKey: "minAge") as? NSNumber)!
        }
        else{
            self.minAge = 18
        }
        
        if (aDecoder.decodeObject(forKey: "maxAllowedAge") != nil){
        self.maxAllowedAge           = (aDecoder.decodeObject(forKey: "maxAllowedAge") as? NSNumber)!
        }
        else{
           self.maxAllowedAge = 65
        }
        
        if (aDecoder.decodeObject(forKey: "minAllowedAge") != nil){
        self.minAllowedAge           = (aDecoder.decodeObject(forKey: "minAllowedAge") as? NSNumber)!
        }
        else{
            self.minAllowedAge = 18
        }
        
        if (aDecoder.decodeObject(forKey: "interestedGender") != nil){
        self.interestedGender        = (aDecoder.decodeObject(forKey: "interestedGender") as? String)!
        }
        else{
            self.interestedGender = "FEMALE"
        }
        
        if (aDecoder.decodeObject(forKey: "maxDistance") != nil){
        self.maxDistance             = (aDecoder.decodeObject(forKey: "maxDistance") as? NSNumber)!
        }
        else{
           self.maxDistance = 2147483647
        }
        
        if (aDecoder.decodeObject(forKey: "favIntent") != nil){
        self.favIntent               = (aDecoder.decodeObject(forKey: "favIntent") as? String)!
        }
        else{
            self.favIntent = "LOVE"
        }
        
        if (aDecoder.decodeObject(forKey: "isKms") != nil){
        self.isKms                   = (aDecoder.decodeObject(forKey: "isKms") as! NSNumber)
        }
        else{
           self.isKms = true
        }
        
        if (aDecoder.decodeObject(forKey: "showLocation") != nil){
            self.showLocation                   = (aDecoder.decodeObject(forKey: "showLocation") as! NSNumber)
        }
        
        if (aDecoder.decodeObject(forKey: "intentAgeDifferenceThreshold") != nil){
        self.intentAgeDifferenceThreshold                  = (aDecoder.decodeObject(forKey: "intentAgeDifferenceThreshold") as? NSNumber)!
        }
        else{
          self.intentAgeDifferenceThreshold = 4
        }
        
        if (aDecoder.decodeObject(forKey: "modelHasBeenUpdatedByServer") != nil){
            self.modelHasBeenUpdatedByServer                  = (aDecoder.decodeObject(forKey: "modelHasBeenUpdatedByServer") as? NSNumber)!
        }
        else{
            self.modelHasBeenUpdatedByServer = false
        }

        if(aDecoder.decodeObject(forKey: "showGlobal") != nil){

            self.showGoGlobal = (aDecoder.decodeObject(forKey: "showGlobal") as? NSNumber)!

        }else{

            self.showGoGlobal = false
        }

        if(aDecoder.decodeObject(forKey: "showGoGlobalButton") != nil){

            self.showGoGlobalButton = (aDecoder.decodeObject(forKey: "showGoGlobalButton") as? NSNumber)!

        }else{

            self.showGoGlobalButton = false
        }
    }
    
    /*!
     * @discussion This method is called when the class is archived
     * @param aCoder NScoder for the class
     */
    internal func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(maxAge, forKey: "maxAge")
        aCoder.encode(minAge, forKey: "minAge")
        aCoder.encode(maxAllowedAge, forKey: "maxAllowedAge")
        aCoder.encode(minAllowedAge, forKey: "minAllowedAge")
        aCoder.encode(interestedGender, forKey: "interestedGender")
        aCoder.encode(maxDistance, forKey: "maxDistance")
        aCoder.encode(favIntent, forKey: "favIntent")
        aCoder.encode(isKms, forKey: "isKms")
        aCoder.encode(showLocation, forKey: "showLocation")
        aCoder.encode(intentAgeDifferenceThreshold, forKey: "intentAgeDifferenceThreshold")
        aCoder.encode(modelHasBeenUpdatedByServer, forKey: "modelHasBeenUpdatedByServer")
        aCoder.encode(showGoGlobal, forKey: "showGlobal")
        aCoder.encode(showGoGlobalButton, forKey: "showGoGlobalButton")
    }
}
