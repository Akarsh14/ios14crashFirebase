//
//  ProfileCardModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 31/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum Badges : String{
    case New        = "NEW"
    case Popular    = "POPULAR"
    case VIP        = "VIP"
    case DIASPORA   = "DIASPORA"
    case None       = ""
}

class TargetQuestionModel: NSObject {
    var questionId : Int = 0
    var question : String = ""
    var answerId : Int = 0
    var answer : String = ""
    var questionTime : UInt64 = 0
    var answerTime : UInt64 = 0
    var hintText : String = ""
    var activeStatus : Bool = true
    var backgroundTile:String = ""
    var position:Int = 0
    
    override init() {
        super.init()
    }
    
    init(data : NSDictionary) {
        super.init()
        
        if let questionId = data["questionId"] {
            self.questionId = questionId as! Int
        }
        
        if let text = data["questionHint"] {
            let hint = (Utilities.sharedUtility() as AnyObject).validString(text as? String)
            if hint!.count > 0{
            self.hintText = ((Utilities.sharedUtility() as AnyObject).getURLDecodedString(from: hint)!)
            }
            else{
                self.hintText = "Add your response. This is the best place to show off your personality."
            }
        }
        else{
            self.hintText = "Add your response. This is the best place to show off your personality."
        }
        
        if let question = data["questionText"] {
            let localQuestion = (Utilities.sharedUtility() as AnyObject).validString(question as? String)
            self.question = ((Utilities.sharedUtility() as AnyObject).getURLDecodedString(from: localQuestion)!)
        }
        
        if let bgTitle = data["questionBackgroundImage"] {
            let title = (Utilities.sharedUtility() as AnyObject).validString(bgTitle as? String)
            self.backgroundTile = ((Utilities.sharedUtility() as AnyObject).getURLDecodedString(from: title)!)
        }
        
        if let status = data["active"] {
            self.activeStatus = status as! Bool
        }
        
        if let answerId = data["answerId"] {
            self.answerId = answerId as! Int
        }
        
        if let pos = data["position"] {
            self.position = pos as! Int
        }
        
        if let answerForQuestion = data["answerText"] {
            let localAnswer = (Utilities.sharedUtility() as AnyObject).validString(answerForQuestion as! String)
            self.answer = ((Utilities.sharedUtility() as AnyObject).getURLDecodedString(from: localAnswer as String?)!) as String
            //self.answer = (answer as? String)!.stringByRemovingPercentEncoding!
        }
    
        if let questionTime = data["questionTime"] {
            self.questionTime = UInt64((questionTime as! NSNumber).int64Value)
        }
        if let answerTime = data["answerTime"] {
            self.answerTime = UInt64((answerTime as! NSNumber).int64Value)
        }
    }
    
 
    
    func dictionarify() -> NSMutableDictionary{
        let questionDictionary : NSMutableDictionary = NSMutableDictionary()
        
        questionDictionary["questionId"]    = NSNumber(value: questionId as Int)
        questionDictionary["question"]      = question
        questionDictionary["answerId"]      = NSNumber(value: answerId as Int)
        questionDictionary["answer"]        = answer
        questionDictionary["questionTime"]  = NSNumber(value: questionTime as UInt64)
        questionDictionary["answerTime"]    = NSNumber(value: answerTime as UInt64)

        return questionDictionary
    }
}

class MutualFriendModel: NSObject {
    var wooId : String?
    var uid : String?
    var name : String?
    var url : String?
    var wooUser : String?
    
    override init() {
        super.init()
    }
    
    init(data : NSDictionary) {
        super.init()
        
        if let wooId = data["wooId"] {
            self.wooId = wooId as? String
        }
        if let uid = data["uid"] {
            self.uid = uid as? String
        }
        if let name = data["name"] {
            self.name = name as? String
        }
        if let url = data["url"] {
            self.url = url as? String
        }
        if let wooUser = data["wooUser"] {
            self.wooUser = wooUser as? String
        }
    }
}

class ProfileInfoTagModel: NSObject,NSCopying,Copying {
    var isSelected = false
    var name : String?
    var tagId : String?
    var tagsCategoryId : Int?
    var tagsSubCategoryId : Int?
    var imageName : String?
    var tagsTitle : String?
    var tagsDtoType: String?
    
    required override init() {
        super.init()
    }
    
    init(data : NSDictionary) {
        super.init()
        
        if let tagId = data["tagId"] {
            self.tagId = "\(tagId)"
        }
        if let tagsDtoType = data["tagsDtoType"] {
            self.tagsDtoType = tagsDtoType as? String
        }
        else
        {
            self.tagsDtoType = "WOO_TAG"
        }
        if let name = data["name"] {
            self.name = name as? String
        }
        if let _isSelected = data["isSelected"]{
            self.isSelected = _isSelected as! Bool
        }
        if let _tagsCategoryId = data["tagsCategoryId"]{
            self.tagsCategoryId = _tagsCategoryId as? Int
        }
        if let _tagsSubCategoryId = data["tagsSubCategoryId"]{
            self.tagsSubCategoryId = _tagsSubCategoryId as? Int
        }
        if let _imageName = data["imageName"] {
            self.imageName = _imageName as? String
        }
        if let _tagsTitle = data["tagsTitle"] {
            self.tagsTitle = _tagsTitle as? String
        }
    }
    
    required init(original: ProfileInfoTagModel){
        super.init()
        self.isSelected = original.isSelected
        self.name = original.name
        self.tagId = original.tagId
        self.tagsCategoryId = original.tagsCategoryId
        self.tagsSubCategoryId = original.tagsSubCategoryId
        self.imageName = original.imageName
        self.tagsTitle = original.tagsTitle
        self.tagsDtoType = original.tagsDtoType
    }
    
    required init(_model : ProfileInfoTagModel){
        super.init()
        self.isSelected = _model.isSelected
        self.name = _model.name
        self.tagId = _model.tagId
        self.tagsCategoryId = _model.tagsCategoryId
        self.tagsSubCategoryId = _model.tagsSubCategoryId
        self.imageName = _model.imageName
        self.tagsTitle = _model.tagsTitle
        self.tagsDtoType = _model.tagsDtoType
    }
    
    func copy(with zone: NSZone?) -> Any{
        return ProfileInfoTagModel(_model: self)
    }
    
}

class TagModel: NSObject,Copying {
   @objc var tagId : String?
   @objc var tagsDtoType : String?
   @objc var name : String?
   @objc var url : String?
    @objc var type : String?
   @objc var isCommon : Bool = false
   @objc var isTagable : Bool = false
   @objc var imageName : String?
    
    override init() {
        super.init()
    }
    
    init(data : NSDictionary) {
        super.init()
        
        if let tagId = data["tagId"] {
            self.tagId = "\(tagId)"
        }
        if let tagsDtoType = data["tagsDtoType"] {
            self.tagsDtoType = tagsDtoType as? String
        }
        else
        {
            self.tagsDtoType = "WOO_TAG"
        }
        if let name = data["name"] {
            self.name = name as? String
        }
        if let nameOfImage = data["imageName"] {
            self.imageName = nameOfImage as? String
        }
        
        if let url = data["url"] {
            self.url = url as? String
        }
        if let isCommon = data["isCommon"] {
            self.isCommon = isCommon as! Bool
        }
        if let isTagable = data["isTagable"] {
            self.isTagable = isTagable as! Bool
        }
        if let type = data["tagsDtoType"] {
            self.type = type as? String
        }
        else{
            self.type = "WOO_TAG"
        }
    }
    
    required init(original: TagModel){
        super.init()
        if let tagId = original.tagId {
            self.tagId = tagId
        }
        if let tagsDtoType = original.tagsDtoType {
            self.tagsDtoType = tagsDtoType
        }
        if let name = original.name {
            self.name = name
        }
        if let imageName = original.imageName {
            self.imageName = imageName
        }
        if let url = original.url {
            self.url = url
        }
        self.isCommon = original.isCommon
        self.isTagable = original.isTagable
        if let type = original.type {
            self.type = type
        }
    }
    
    func professionModel() -> (ProfessionModel){
        let model = ProfessionModel()
        model.tagId = self.tagId
        model.name = self.name
        
        return model
    }
    
    func dictionarify() -> NSMutableDictionary{
        let tagDictionary : NSMutableDictionary = NSMutableDictionary()
        
        if tagId != nil {
            tagDictionary["tagId"] = tagId
        }
        if tagsDtoType != nil {
            tagDictionary["tagsDtoType"] = tagsDtoType
        }
        if name != nil {
            tagDictionary["name"] = name
        }
        if imageName != nil {
            tagDictionary["imageName"] = imageName
        }
        if url != nil {
            tagDictionary["url"] = url
        }
//        tagDictionary["isCommon"] = NSNumber(bool: isCommon)
//        tagDictionary["isTagable"] = NSNumber(bool: isTagable)
        if type != nil {
            tagDictionary["tagsDtoType"] = type
        }
        
        return tagDictionary
    }
}

@objc class ProfileCardModel: NSObject {
    @objc var about : String?
    @objc var age : String?
    @objc var firstName : String = ""
    @objc var location : NSString?
    @objc var displayName : String?
    @objc var personalQuote : String?
    @objc var tags : [TagModel] = []
    @objc var commonTags : [TagModel] = []
    @objc var commonTagDto : NSDictionary?
    @objc var profileInfoTags : [ProfileInfoTagModel] = []
    @objc var wooAlbum :WooAlbumModel?
    @objc var wooId : String?
    @objc var gender : String = "FEMALE"
    @objc var height : String?
    var badgeType : Badges = Badges.None
    @objc var crushText : NSString = ""
    @objc var isLinkedInVerified = false
    @objc var isPhoneVerified = false
    @objc var isPopular = false
    @objc var mutualFriends : [MutualFriendModel] = []
    @objc var myQuestionsArray : [TargetQuestionModel] = []
    @objc var profileCompletenessScore : String = "0"
    @objc var religion : [ProfessionModel] = []
    @objc var religionText = ""
    @objc var ethnicity : [ProfessionModel] = []
    @objc var ethnicityText = ""
    var showHeightType : HeightUnit = HeightUnit.INCHES
    @objc var isProfileSeen : Bool = false
    @objc var isProfileLiked : Bool = false
    @objc var diasporaLocation = ""
    @objc var diasporaLocationNearYou = false
    @objc var isMyprofile:Bool = false
    @objc var needToShowLikeBadge:Bool = false
    @objc var phoneNumberDto:NSDictionary?
    @objc var profileImage:UIImage?

    override init() {
        super.init()
    }
    
    @objc init(userInfoDto : NSDictionary, wooId : String) {
        super.init()
        self.updateData(userInfoDto)
        self.wooId = wooId
    }
    
    @objc init(userInfoDto : NSDictionary) {
        super.init()
        self.updateData(userInfoDto)
    }
    
    @objc init(matchObject:MyMatches){
        super.init()
        self.updateDataForModel(model: matchObject, profileType: .MyMatches)
    }
    
    init(model : AnyObject, profileType:ProfileType) {
        super.init()
        self.updateDataForModel(model: model, profileType: profileType)
    }
    
    init(cardModel:ProfileCardModel) {
        super.init()
        self.updateSelfBasedOnCardModel(cardModel)
    }
    
    func updateDataForModel(model:AnyObject, profileType:ProfileType){
        switch profileType {
        case .LikedMe:
            
            let likedMeModel:LikedByMe = model as! LikedByMe
            
            if let age = likedMeModel.userAge {
                self.age = "\(age)"
            }
            if let firstName = likedMeModel.userFirstName {
                self.firstName = firstName
            }
            
            if let wooAlbum = likedMeModel.userProfilePicURL {
                self.wooAlbum = WooAlbumModel()
                let singleAlbum = AlbumPhoto(isProfilePic:  true,
                                                          url: wooAlbum,
                                                          pStaus: nil,
                                                          objectId: nil,
                                                          order : 0)
                self.wooAlbum?.addObject(singleAlbum as AnyObject)
            }
            if let wooId = likedMeModel.userWooId {
                self.wooId = wooId as String
            }
            
            if let gender = likedMeModel.userGender {
                self.gender = gender
            }
            
            if let crushText = likedMeModel.crushMsgSendToUser {
                self.crushText = crushText as NSString
            }
            
            if let badgeType = likedMeModel.badgeType {
                switch badgeType {
                case "POPULAR":
                    self.badgeType = Badges.Popular
                    break
                case "NEW":
                    self.badgeType = Badges.New
                    break
                case "VIP":
                    self.badgeType = Badges.VIP
                    break
                default :
                    self.badgeType = Badges.None
                    break
                }
            }
            else{
                self.badgeType = Badges.None
            }
            
            if let isProfileLikedL = likedMeModel.isUserLiked {
                self.isProfileLiked = isProfileLikedL as! Bool
            }

            break
            
        case .MeDashboard:
            let boostModel:MeDashboard = model as! MeDashboard
            
            if let age = boostModel.visitorAge {
                self.age = "\(age)"
            }
            if let firstName = boostModel.visitorFirstName {
                self.firstName = firstName
            }
            
            if let wooAlbum = boostModel.visitorProfilePicURL {
                self.wooAlbum = WooAlbumModel()
                let singleAlbum = AlbumPhoto(isProfilePic:  true,
                                             url: wooAlbum,
                                             pStaus: nil,
                                             objectId: nil,
                                             order : 0)
                self.wooAlbum?.addObject(singleAlbum as AnyObject)
            }
            if let wooId = boostModel.visitorId {
                self.wooId = wooId as String
            }
            
            if let commonTag = boostModel.commonTagDto{
                self.commonTagDto = commonTag as? NSDictionary
            }
            
            if let gender = boostModel.visitorGender {
                self.gender = gender
            }
            
            if let crushText = boostModel.crushMsgSendToUser {
                self.crushText = crushText as NSString
            }
            
            if let badgeType = boostModel.badgeType {
                switch badgeType {
                case "POPULAR":
                    self.badgeType = Badges.Popular
                    break
                case "NEW":
                    self.badgeType = Badges.New
                    break
                case "VIP":
                    self.badgeType = Badges.VIP
                    break
                default :
                    self.badgeType = Badges.None
                    break
                }
            }
            else{
                self.badgeType = Badges.None
            }
            
            if let isProfileLikedL = boostModel.isVisitorLiked {
                self.isProfileLiked = isProfileLikedL as! Bool
            }

            break
            
        case .SkippedProfiles:
            let skippedProfileModel:SkippedProfiles = model as! SkippedProfiles
            
            if let age = skippedProfileModel.userAge {
                self.age = "\(age)"
            }
            if let firstName = skippedProfileModel.userFirstName {
                self.firstName = firstName
            }
            
            if let wooAlbum = skippedProfileModel.userProfilePicURL {
                self.wooAlbum = WooAlbumModel()
                let singleAlbum = AlbumPhoto(isProfilePic:  true,
                                             url: wooAlbum,
                                             pStaus: nil,
                                             objectId: nil,
                                             order : 0)
                self.wooAlbum?.addObject(singleAlbum as AnyObject)
            }
            if let wooId = skippedProfileModel.userWooId {
                self.wooId = wooId as String
            }
            
            if let gender = skippedProfileModel.userGender {
                self.gender = gender
            }
            
            if let crushText = skippedProfileModel.crushMsgSendToUser {
                self.crushText = crushText as NSString
            }
            
            if let badgeType = skippedProfileModel.badgeType {
                switch badgeType {
                case "POPULAR":
                    self.badgeType = Badges.Popular
                    break
                case "NEW":
                    self.badgeType = Badges.New
                    break
                case "VIP":
                    self.badgeType = Badges.VIP
                    break
                default :
                    self.badgeType = Badges.None
                    break
                }
            }
            else{
                self.badgeType = Badges.None
            }
            
            if let isProfileLikedL = skippedProfileModel.isUserLiked {
                self.isProfileLiked = isProfileLikedL as! Bool
            }

            break
            
        case .MyMatches:
            let matchModel:MyMatches = model as! MyMatches
            
            if let firstName = matchModel.matchUserName {
                self.firstName = firstName
            }
            
            if let wooAlbum = matchModel.matchUserPic {
                self.wooAlbum = WooAlbumModel()
                let singleAlbum = AlbumPhoto(isProfilePic:  true,
                                             url: wooAlbum,
                                             pStaus: nil,
                                             objectId: nil,
                                             order : 0)
                self.wooAlbum?.addObject(singleAlbum as AnyObject)
            }
            if let wooId = matchModel.matchedUserId {
                self.wooId = wooId as String
            }
            
            if let gender = matchModel.matchGender {
                self.gender = gender
            }
            break
            
        default:
            break
        }

    }

    func updateData(_ userInfoDto : NSDictionary){
        if userInfoDto["about"] != nil {
            //self.about = about as? String
        }
        if let age = userInfoDto["age"] {
            self.age = "\(age)"
        }
        if let firstName = userInfoDto["firstName"] {
            self.firstName = (firstName as? String)!
        }
        if let displayName = userInfoDto["displayName"] {
            self.displayName = (displayName as? String)!
        }
        if let location = userInfoDto["location"] {
            self.location = location as? String as NSString?
        }
        if let personalQuote = userInfoDto["personalQuote"] {
            self.personalQuote = (Utilities.sharedUtility() as AnyObject).getURLDecodedString(from: personalQuote as! String)
            //self.personalQuote = (personalQuote as? String)?.stringByRemovingPercentEncoding
        }
        
        //save questions
        if (userInfoDto.object(forKey: "userWooQuestionAnswerDto") != nil){
            let questionAnswerArray = userInfoDto.object(forKey: "userWooQuestionAnswerDto") as? NSArray
            var questionModelArray:[TargetQuestionModel] = []
            for questionDict in questionAnswerArray ?? NSArray(){
                let questionModel = TargetQuestionModel(data: questionDict as? NSDictionary ?? NSDictionary())
                questionModelArray.append(questionModel)
            }
            self.myQuestionsArray = questionModelArray
        }
        //54321
        //self.personalQuote = "Delhite\nOutgoing\nSmart and Sensible\nTalkative\nMovie Buff\nBeach bum\nMountain Lover\nLong Drives\nCalm and Happy\nGo Getter\nPagla\njaanwar\nPeeke pada hDelhite Outgoing Smart and Sensible Talkative Movie Buff Beach bum Mountain Lover Long Drives Calm and Happy Go Getter Pagla jaanwar Peeke pada h"
        if let _phoneNumberData = userInfoDto["phoneNumberDto"] {
            phoneNumberDto = _phoneNumberData as? NSDictionary
        }
        
        if let _religion = userInfoDto["religion"] {
            religion = professionModelArrayFromDto((_religion as? [[String : AnyObject]])!)
        }
        
        if let religionString = userInfoDto["religionText"]{
            religionText = religionString as! String
        }
        else{
            religionText = ""
        }
        
        if let wooAlbum = userInfoDto["wooAlbum"] {
            self.wooAlbum = WooAlbumModel()
            self.wooAlbum?.isMyprofile = isMyprofile
            self.wooAlbum?.addObjectsFromArray(wooAlbum as! [AnyObject])
        }
        if let wooId = userInfoDto["wooId"] {
            self.wooId = String(describing: wooId)
        }
        
        if let height = userInfoDto["height"] {
            self.height = height as? String
        }
        
        if let gender = userInfoDto["gender"] {
            self.gender = (gender as? String)!
        }
        
        if let crushText = userInfoDto["crushText"] {
            self.crushText = (crushText as? String)! as NSString
        }
        
       // self.crushText = "I'm a ganstaaa :D Hate us coz they ain't us..This is why i'm hot hot..This is why i'm hot...I m hot coz m flyyy...You ain't coz you not...This is why..This is why..This is why i'm hot hot...MUSIC IS MY SAVIOUR.(M.I.M.S)"
        
        if let badgeType = userInfoDto["badgeType"] {
            switch badgeType as! String {
            case "POPULAR":
                self.badgeType = Badges.Popular
                break
            case "NEW":
                self.badgeType = Badges.New
                break
            case "VIP":
                self.badgeType = Badges.VIP
                break
            default :
                self.badgeType = Badges.None
                break
            }
        }
        else{
            self.badgeType = Badges.None
        }
        
        if let diasporaLocationKey = userInfoDto["diasporaLocation"] {
            diasporaLocation = diasporaLocationKey as! String
        }
        
        if let diasporaLocationNearYouKey = userInfoDto["diasporaLocationNearYou"] {
            diasporaLocationNearYou = diasporaLocationNearYouKey as! Bool
        }
        
        if let mutualFriends = userInfoDto["mutualFriends"]{
            self.updateMutualFriends(mutualFriends as! NSArray)
        }
        
        //var wooId : String?
        //var name : String?
        
        /*
        let userDict = NSDictionary(objects: ["1234","Rakesh"], forKeys: ["wooId" as NSCopying,"name" as NSCopying])
        let friendsArray = NSArray(object: userDict)
        self.updateMutualFriends(friendsArray)
        */

        
        if let lCommonTags = userInfoDto["commonTagsDto"] {
            if (lCommonTags as! NSArray).count > 0 {
                self.addCommonTagsToAllTags(lCommonTags as! NSArray)
            }
        }
        else{
            self.tags.removeAll()
        }
        
        if let lTags = userInfoDto["tagsDtos"]{
            self.updateTags(lTags as! NSArray)
        }
        
        if let profileInfoDto = userInfoDto["myProfileInfoDto"]{
            self.profileInfoTags = profileInfoModelArrayFromDto(profileInfoDto as! [[String : AnyObject]])
        }
       
        
        if let lIsPhoneVerified  = userInfoDto["isVerifiedMsisdn"]{
            self.isPhoneVerified = lIsPhoneVerified as! Bool
        }
                
        if let lIsLinkedInVerified  = userInfoDto["isVerifiedOnLinkedin"]{
            self.isLinkedInVerified = lIsLinkedInVerified as! Bool
        }
        
        if let lProfileCompletenessScore = userInfoDto["profileCompletenessScore"]{
            self.profileCompletenessScore = "\(lProfileCompletenessScore)"
        }
        
        if let isPopularKey = userInfoDto["isPopular"] {
            isPopular = isPopularKey as! Bool
        }
        
        if let _ethnicity = userInfoDto["ethnicity"] {
            ethnicity = professionModelArrayFromDto((_ethnicity as? [[String : AnyObject]])!)
        }
        if let ethnicityString = userInfoDto["ethnicityText"]  {
            ethnicityText = ethnicityString as! String
        }
        else{
            ethnicityText = ""
        }
//        if let ethnicity = userInfoDto["ethnicity"]{
//            if (ethnicity as! [NSDictionary]).count > 0 {
//                let ethnicityValue = (ethnicity as! [NSDictionary]).first
//                self.ethnicity = ProfessionModel()
//                self.ethnicity?.name = ethnicityValue?.value(forKey: "name") as! String?
//                self.ethnicity?.tagId = "\((ethnicityValue?.value(forKey: "tagId") as! NSNumber))"
//                self.ethnicity?.tagsDtoType = ethnicityValue!.value(forKey: "tagsDtoType") as! String
//            }
//        }
        
		if let lIsProfilLiked  = userInfoDto["showLikeBadge"]{
            self.needToShowLikeBadge = lIsProfilLiked as! Bool
        }
        
        if let isProfileLikedL = userInfoDto["like"] {
            self.isProfileLiked = isProfileLikedL as! Bool
        }
    }
    
    private func updateSelfBasedOnCardModel(_ cardModel:ProfileCardModel){
        self.about = cardModel.about
        self.age = cardModel.age
        self.firstName = cardModel.firstName
        self.displayName = cardModel.displayName
        self.location = cardModel.location
        self.personalQuote = cardModel.personalQuote
        self.myQuestionsArray = cardModel.myQuestionsArray
        self.phoneNumberDto = cardModel.phoneNumberDto
        self.religion = cardModel.religion
        self.religionText = cardModel.religionText
        self.wooAlbum = cardModel.wooAlbum
        self.wooId = cardModel.wooId
        self.height = cardModel.height
        self.gender = cardModel.gender
        self.crushText = cardModel.crushText
        self.badgeType = cardModel.badgeType
        self.diasporaLocation = cardModel.diasporaLocation
        self.diasporaLocationNearYou = cardModel.diasporaLocationNearYou
        self.mutualFriends = cardModel.mutualFriends
        self.commonTags = cardModel.commonTags
        self.tags = cardModel.tags
        self.profileInfoTags = cardModel.profileInfoTags
        self.isPhoneVerified = cardModel.isPhoneVerified
        self.isLinkedInVerified = cardModel.isLinkedInVerified
        self.profileCompletenessScore = cardModel.profileCompletenessScore
        self.isPopular = cardModel.isPopular
        self.ethnicity = cardModel.ethnicity
        self.ethnicityText = cardModel.ethnicityText
        self.needToShowLikeBadge = cardModel.needToShowLikeBadge
        self.isProfileLiked = cardModel.isProfileLiked
    }
    
    func mutualFriendCount() -> Int{
        return mutualFriends.count
    }
    
    func firstMutualFriendImageURL() -> String?{
        if self.mutualFriends.count > 0 {
            return mutualFriends[0].url
        }
        return nil
    }
    
    func commonTagCount() -> Int{
            return commonTags.count
    }
    
    fileprivate func updateMutualFriends(_ friendArray: NSArray) {
        for friend in friendArray {
            let lFriend = friend as! NSDictionary
            let mutualFriend = MutualFriendModel(data: lFriend)
            self.mutualFriends.append(mutualFriend)
        }
    }
    
    
    fileprivate func addCommonTagsToAllTags(_ tagsArray: NSArray) {
        self.tags.removeAll()
        self.commonTags.removeAll()
        for tag in tagsArray {
            let lTag = tag as! NSDictionary
            let mutableTag = NSMutableDictionary(dictionary: lTag)
            mutableTag.setValue(true, forKey: "isCommon")
            let commonTag = TagModel(data: mutableTag)
            self.tags.append(commonTag)
            self.commonTags.append(commonTag)
        }
    }
    
    
    func updateTags(_ tagsArray: NSArray) {
        for tag in tagsArray {
            let lTag = tag as! NSDictionary
            let tag = TagModel(data: lTag)
            self.tags.append(tag)
        }
    }
    
    func professionModelArrayFromDto(_ dtoArray : [[String : AnyObject]]) -> [ProfessionModel] {
        var array : [ProfessionModel] = []
        for dto in dtoArray {
            let model = ProfessionModel()
            if let _isSelected = dto["isSelected"] {
                model.isSelected = (_isSelected as! NSNumber).boolValue
            }
            model.name = dto["name"] as? String
            model.tagId = "\(dto["tagId"]!)"
            if let tagsDtoType = dto["tagsDtoType"]{
                model.tagsDtoType = (tagsDtoType as? String)!
            }
            
            if let _inPlace = dto["inPlace"] {
                model.inPlace = (_inPlace as! NSNumber).boolValue
            }
            
            array.append(model)
        }
        return array
    }
    
    func profileInfoModelArrayFromDto(_ dtoArray : [[String : AnyObject]]) -> [ProfileInfoTagModel] {
        var array : [ProfileInfoTagModel] = []
        for dto in dtoArray {
            let model = ProfileInfoTagModel(data: dto as NSDictionary)
            array.append(model)
        }
        return array
    }
    
    func selectedReligion() -> ProfessionModel {
        for item in religion {
            if item.isSelected {
                return item
            }
        }
        let noInfo  = ProfessionModel()
        noInfo.tagId = "-1"
        noInfo.name = "Select"
        
        return noInfo
    }
    
    func setSelectedReligion(_ tagId : String){
        for item in religion {
            if item.tagId == tagId {
                item.isSelected = true
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    @objc func getBadgeType() -> String {
        return self.badgeType.rawValue
    }
    
    func printTags()  {
        for item in tags {
            print((item as TagModel).name)
        }
    }
    
    func dictionarify() -> NSMutableDictionary{
        let profileDictionary : NSMutableDictionary = (wooAlbum?.dictionaryfy())!
        //firstName - 1
//        profileDictionary["firstName"] = firstName
        //location - 2
        if location != nil {
//            profileDictionary["location"] = location
        }
        //personalQuote - 3
        if personalQuote != nil {
            profileDictionary["personalQuote"] = (Utilities.sharedUtility() as AnyObject).encode(fromPercentEscape: personalQuote)
        }
        //wooId - 4
        if self.wooId != nil {
//            profileDictionary["wooId"] = wooId!
        }
        //height - 5
        if self.height != nil {
            profileDictionary["height"] = self.height
        }

        //13
        var _tagsDtos : [NSMutableDictionary] = []
        for item in tags {
            _tagsDtos.append(item.dictionarify())
        }
        profileDictionary["tagsDtos"] = _tagsDtos
        //14
//        profileDictionary["wooAlbum"] = wooAlbum?.dictionaryfy()
        //15
        var _religion : [NSMutableDictionary] = []
        
        let item = self.selectedReligion()

        if item.name != "Select" {
            _religion.append(item.dictionarify())
        }
        profileDictionary["religion"] = _religion
        //location - 16
        if self.location != nil {
            profileDictionary["location"] = location
        }
        
        return profileDictionary
    }
}
