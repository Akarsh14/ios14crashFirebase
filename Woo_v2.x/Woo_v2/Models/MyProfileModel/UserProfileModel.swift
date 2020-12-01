//
//  UserProfileModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 15/04/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

@objc open class UserProfileModel: NSObject {
    
    var arrayOfPropertyCompilation :NSMutableArray
    
    var wooId : NSString = ""
    var age : NSInteger = 0
    var firstName : NSString = ""
    var gender : NSString = "MALE"
    var height : NSString = ""
    var isVerifiedMsisdn : Bool = false
    var isVerifiedOnLinkedin : Bool = false
    var like : Bool = false
    var location : NSString = ""
    var profileCompletenessScore : NSInteger = 0
    var verifiedOnLinkedin : Bool = false
    var voiceIntroUrl : NSString = ""
    var mutualFriends : NSArray?
    var userHomeTown : NSDictionary?
    var userRelationShipStatus : NSDictionary?
    var userReligion : NSDictionary?
    var userWorkArea : NSDictionary?
    var workExperienceHistory : NSArray?
    var educationHistory : NSArray?
    var interests : NSArray?
    var personality : NSArray?
    var lifeStyle : NSDictionary?
    var passionAndInterests : NSDictionary?
    var wooAlbum : WooAlbumModel?
    
    public override init() {
        arrayOfPropertyCompilation = NSMutableArray();
        super.init();
    }
    
    public init(data: NSDictionary) {
        
        arrayOfPropertyCompilation = NSMutableArray();
        super.init()
        
        self.updateModel(data)
    }
/*!
 * @discussion initialiser with decoder parameter
 * @param aDecoder decoder of the class
 */
    required public init(coder aDecoder: NSCoder) {
        
        arrayOfPropertyCompilation = NSMutableArray();
        if (aDecoder.decodeObject(forKey: "id") != nil){
        self.wooId                      = (aDecoder.decodeObject(forKey: "id") as? NSString)!
        }
        if (aDecoder.decodeObject(forKey: "age") != nil){
        self.age                        = (aDecoder.decodeObject(forKey: "age") as? NSInteger)!
        }
        if (aDecoder.decodeObject(forKey: "firstName") != nil){
        self.firstName                  = (aDecoder.decodeObject(forKey: "firstName") as? NSString)!
        }
        if (aDecoder.decodeObject(forKey: "gender") != nil){
        self.gender                     = (aDecoder.decodeObject(forKey: "gender") as? NSString)!
        }
        if (aDecoder.decodeObject(forKey: "isVerifiedMsisdn") != nil){
        self.isVerifiedMsisdn           = (aDecoder.decodeObject(forKey: "isVerifiedMsisdn") as? Bool)!
        }
        if (aDecoder.decodeObject(forKey: "isVerifiedOnLinkedin") != nil){
        self.isVerifiedOnLinkedin       = (aDecoder.decodeObject(forKey: "isVerifiedOnLinkedin") as? Bool)!
        }
        if (aDecoder.decodeObject(forKey: "like") != nil){
        self.like                       = (aDecoder.decodeObject(forKey: "like") as? Bool)!
        }
        if (aDecoder.decodeObject(forKey: "location") != nil){
        self.location                   = (aDecoder.decodeObject(forKey: "location") as? NSString)!
        }
        if (aDecoder.decodeObject(forKey: "profileCompletenessScore") != nil){
        self.profileCompletenessScore   = (aDecoder.decodeObject(forKey: "profileCompletenessScore") as? NSInteger)!
        }
        if (aDecoder.decodeObject(forKey: "verifiedOnLinkedin") != nil){
        self.verifiedOnLinkedin         = (aDecoder.decodeObject(forKey: "verifiedOnLinkedin") as? Bool)!
        }
        if (aDecoder.decodeObject(forKey: "height") != nil){
        self.height                     = (aDecoder.decodeObject(forKey: "height") as? NSString)!
        }
        if (aDecoder.decodeObject(forKey: "voiceIntroUrl") != nil){
        self.voiceIntroUrl              = (aDecoder.decodeObject(forKey: "voiceIntroUrl") as? NSString)!
        }
        if aDecoder.decodeObject(forKey: "mutualFriends") != nil {
            self.mutualFriends          = (aDecoder.decodeObject(forKey: "mutualFriends") as? NSArray)!
        }
        if aDecoder.decodeObject(forKey: "userHomeTown") != nil {
            self.userHomeTown           = (aDecoder.decodeObject(forKey: "userHomeTown") as? NSDictionary)!
        }
        if aDecoder.decodeObject(forKey: "userRelationShipStatus") != nil {
            self.userRelationShipStatus = (aDecoder.decodeObject(forKey: "userRelationShipStatus") as? NSDictionary)!
        }
        if aDecoder.decodeObject(forKey: "userReligion") != nil {
            self.userReligion           = (aDecoder.decodeObject(forKey: "userReligion") as? NSDictionary)!
        }
        if aDecoder.decodeObject(forKey: "userWorkArea") != nil {
            self.userWorkArea           = (aDecoder.decodeObject(forKey: "userWorkArea") as? NSDictionary)!
        }
        if aDecoder.decodeObject(forKey: "workExperienceHistory") != nil {
            self.workExperienceHistory  = (aDecoder.decodeObject(forKey: "workExperienceHistory") as? NSArray)!
        }
        if aDecoder.decodeObject(forKey: "educationHistory") != nil {
            self.educationHistory  = (aDecoder.decodeObject(forKey: "educationHistory") as? NSArray)!
        }
        if aDecoder.decodeObject(forKey: "interests") != nil {
            self.interests  = (aDecoder.decodeObject(forKey: "interests") as? NSArray)!
        }
        if aDecoder.decodeObject(forKey: "personality") != nil {
            self.personality  = (aDecoder.decodeObject(forKey: "personality") as? NSArray)!
        }
        if aDecoder.decodeObject(forKey: "lifeStyle") != nil {
            self.lifeStyle  = (aDecoder.decodeObject(forKey: "lifeStyle") as? NSDictionary)!
        }
//        if aDecoder.decodeObjectForKey("wooAlbum") != nil {
//            self.wooAlbum  = (aDecoder.decodeObjectForKey("wooAlbum") as? NSArray)!
//        }
    }
    
/*!
 * @discussion This method is called when the class is archived
 * @param aCoder NScoder for the class
 */
    open func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(wooId, forKey: "id")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(isVerifiedMsisdn, forKey: "isVerifiedMsisdn")
        aCoder.encode(like, forKey: "like")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(profileCompletenessScore, forKey: "profileCompletenessScore")
        aCoder.encode(verifiedOnLinkedin, forKey: "verifiedOnLinkedin")
        aCoder.encode(isVerifiedOnLinkedin, forKey: "isVerifiedOnLinkedin")
        aCoder.encode(height, forKey: "height")
        aCoder.encode(voiceIntroUrl, forKey: "voiceIntroUrl")
        aCoder.encode(mutualFriends, forKey: "mutualFriends")
        aCoder.encode(userHomeTown, forKey: "userHomeTown")
        aCoder.encode(userRelationShipStatus, forKey: "userRelationShipStatus")
        aCoder.encode(userReligion, forKey: "userReligion")
        if userWorkArea != nil {
            aCoder.encode(userWorkArea, forKey: "userWorkArea")
        }
        if workExperienceHistory != nil {
            aCoder.encode(workExperienceHistory, forKey: "workExperienceHistory")
        }
        if educationHistory != nil {
            aCoder.encode(educationHistory, forKey: "educationHistory")
        }
        if interests != nil {
            aCoder.encode(interests, forKey: "interests")
        }
        if personality != nil {
            aCoder.encode(personality, forKey: "personality")
        }
        if lifeStyle != nil {
            aCoder.encode(lifeStyle, forKey: "lifeStyle")
        }
//        aCoder.encodeObject(wooAlbum, forKey: "wooAlbum")
    }
    
/*!
 * @discussion This method parse the given dictionary and aupdates the model accordingly.
 * @param data data in NSDictionary format.
 */
    open func updateModel(_ data: NSDictionary){
        
        if (data.object(forKey: "id") != nil) {
            wooId = "\(data.object(forKey: "id")!)" as NSString
        }
        
        if (data.object(forKey: "age") != nil) {
            age = ((data.object(forKey: "age") as AnyObject).intValue)!
        }
        
        if let __firstname =  data.object(forKey: "firstName") {
            firstName = __firstname as! NSString
        }
        
        if (data.object(forKey: "gender") != nil) {
            gender = data.object(forKey: "gender") as! NSString
        }

        if (data.object(forKey: "height") != nil) {
            height = data.object(forKey: "height") as! NSString
        }
        else{
            height = ""
        }
        
        if (data.object(forKey: "location") != nil) {
            location = (data.object(forKey: "location")as! NSString?)!
        }
        
        if (data.object(forKey: "profileCompletenessScore") != nil) {
            profileCompletenessScore = ((data.object(forKey: "profileCompletenessScore") as AnyObject).intValue)!
        }
        
        if ((data.object(forKey: "voiceIntro") as! NSDictionary).object(forKey: "voiceIntroUrl") != nil) {
            voiceIntroUrl = ((data.object(forKey: "voiceIntro") as AnyObject).object(forKey: "voiceIntroUrl"))! as! NSString;
        }
        else{
            voiceIntroUrl = ""
        }
        
        if data.object(forKey: "mutualFriends") != nil {
            mutualFriends = data.object(forKey: "mutualFriends") as? NSArray
        }
        
        if data.object(forKey: "userHomeTown") != nil {
            self.userHomeTown = (data.object(forKey: "userHomeTown") as? NSDictionary)!
        }
        if data.object(forKey: "userRelationShipStatus") != nil {
            self.userRelationShipStatus = (data.object(forKey: "userRelationShipStatus") as? NSDictionary)!
        }
        if data.object(forKey: "userReligion") != nil {
            self.userReligion = (data.object(forKey: "userReligion") as? NSDictionary)!
        }
        if data.object(forKey: "userWorkArea") != nil {
            self.userWorkArea = (data.object(forKey: "userWorkArea") as? NSDictionary)!
        }
        if data.object(forKey: "workExperienceHistory") != nil {
            self.workExperienceHistory = (data.object(forKey: "workExperienceHistory") as? NSArray)!
        }
        if data.object(forKey: "educationHistory") != nil {
            self.educationHistory = (data.object(forKey: "educationHistory") as? NSArray)!
        }
        if data.object(forKey: "interests") != nil {
            self.interests = (data.object(forKey: "interests") as? NSArray)!
        }
        if data.object(forKey: "personality") != nil {
            self.personality = (data.object(forKey: "personality") as? NSArray)!
        }
        if data.object(forKey: "lifeStyle") != nil {
            self.lifeStyle = (data.object(forKey: "lifeStyle") as? NSDictionary)!
        }
        if let wooAlbum = data["wooAlbum"] {
            self.wooAlbum = WooAlbumModel()
            self.wooAlbum?.addObjectsFromArray(wooAlbum as! [AnyObject])
        }
        if data.object(forKey: "isVerifiedMsisdn") != nil {
            isVerifiedMsisdn = ((data.object(forKey: "isVerifiedMsisdn") as AnyObject).boolValue)!
        }
        if data.object(forKey: "isVerifiedOnLinkedin") != nil {
            isVerifiedOnLinkedin = ((data.object(forKey: "isVerifiedOnLinkedin") as AnyObject).boolValue)!
        }
        if data.object(forKey: "like") != nil {
            like = ((data.object(forKey: "like") as AnyObject).boolValue)!
        }
        if data.object(forKey: "verifiedOnLinkedin") != nil {
            verifiedOnLinkedin = ((data.object(forKey: "verifiedOnLinkedin") as AnyObject).boolValue)!
        }
    }

}
