
//
//  MyProfileModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 20/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PhoneVerifyModel: NSObject {
    var countryCode : String?
    var countryName : String?
    var flagUrl : String?
    var isoCountryCode : String?
    var phoneDigitCount = 10
    var smsTemplate : String?
    var phoneNumber : String?
    
    func setData(_ foneVerifyAvailabilityDto: NSDictionary) {
        if let _countryCode = foneVerifyAvailabilityDto["countryCode"] {
            countryCode = _countryCode as? String
        }
        
        if let _countryName = foneVerifyAvailabilityDto["countryName"] {
            countryName = _countryName as? String
        }
        
        if let _flagUrl = foneVerifyAvailabilityDto["flagUrl"] {
            flagUrl = _flagUrl as? String
        }
        
        if let _isoCountryCode = foneVerifyAvailabilityDto["isoCountryCode"] {
            isoCountryCode = _isoCountryCode as? String
        }
        
        if let _phoneDigitCount = foneVerifyAvailabilityDto["phoneDigitCount"] {
            phoneDigitCount = ((_phoneDigitCount as? NSNumber)?.intValue)!
        }
        
        if let _smsTemplate = foneVerifyAvailabilityDto["smsTemplate"] {
            smsTemplate = _smsTemplate as? String
        }
    }
}

class RelationshipLifestyleTagModel: NSObject,NSCopying,Copying {
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
        if let _tagsDtoType = data["tagsDtoType"] {
            self.tagsDtoType = _tagsDtoType as? String
        }
        else{
            self.tagsDtoType = "WOO_TAG"
        }
    }
    
    required init(original: RelationshipLifestyleTagModel){
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
    
    required init(_model : RelationshipLifestyleTagModel){
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
        return RelationshipLifestyleTagModel(_model: self)
    }
    
    func tagModel() -> (TagModel){
        let model = TagModel()
        model.tagId = self.tagId
        model.name = self.name
        model.imageName = self.imageName
        model.type = self.tagsDtoType
        return model
    }
    
    func dictionarify() -> NSMutableDictionary {
        let relationshipLifestyleModelDictionary : NSMutableDictionary = NSMutableDictionary()
        
        relationshipLifestyleModelDictionary["isSelected"] = NSNumber(value: (isSelected ? 1 : 0) as Int)
        
        if let _name = name {
            relationshipLifestyleModelDictionary["name"] = _name
        }
        if let _tagId = tagId{
            relationshipLifestyleModelDictionary["tagId"] = NSNumber(value: Int64(_tagId)! as Int64)
        }
        
        if let _tagsCategoryId = tagsSubCategoryId{
        relationshipLifestyleModelDictionary["tagsCategoryId"] = NSNumber(value: _tagsCategoryId)
        }
        if let _tagsSubCategoryId = tagsSubCategoryId{
        relationshipLifestyleModelDictionary["tagsSubCategoryId"] = NSNumber(value: _tagsSubCategoryId)
        }
        if let _imageName = imageName {
            relationshipLifestyleModelDictionary["imageName"] = _imageName
        }
        if let _tagsTitle = tagsTitle {
            relationshipLifestyleModelDictionary["tagsTitle"] = _tagsTitle
        }
        if let _tagsDtoType = tagsDtoType {
            relationshipLifestyleModelDictionary["tagsDtoType"] = _tagsDtoType
        }

        return relationshipLifestyleModelDictionary
    }
    
    func dictionarifyForSendingToServer() -> NSMutableDictionary {
        let relationshipLifestyleModelDictionary : NSMutableDictionary = NSMutableDictionary()
        
        if let _name = name {
            relationshipLifestyleModelDictionary["name"] = _name
        }
        if let _tagId = tagId{
            relationshipLifestyleModelDictionary["tagId"] = NSNumber(value: Int64(_tagId)! as Int64)
        }
        if let _tagsDtoType = tagsDtoType {
            relationshipLifestyleModelDictionary["tagsDtoType"] = _tagsDtoType
        }
        
        return relationshipLifestyleModelDictionary
    }
    
}

class ProfessionModel: NSObject,NSCopying,Copying {
    var isSelected = false
    var name : String?
    var tagId : String?
    var tagsDtoType = ""
    var inPlace = false
    
    required override init() {
        super.init()
    }
    
    required init(original: ProfessionModel){
        super.init()
        self.isSelected = original.isSelected
        self.name = original.name
        self.tagId = original.tagId
        self.tagsDtoType = original.tagsDtoType
    }
    
    required init(_model : ProfessionModel){
        super.init()
        self.isSelected = _model.isSelected
        self.name = _model.name
        self.tagId = _model.tagId
        self.tagsDtoType = _model.tagsDtoType
    }
    
    func copy(with zone: NSZone?) -> Any{
        return ProfessionModel(_model: self)
    }
    
    func icon() -> UIImage? {
        if tagsDtoType.contains("NONE") || tagsDtoType.contains("USER_WORK_CUSTOM") || tagsDtoType.contains("USER_EDUCATION_CUSTOM") || tagsDtoType.count <= 0 {
            return UIImage()
        }
        else if !tagsDtoType.contains("_LINKEDIN") {
            return UIImage(named: "fbIconCrop")!
        }
        else{
            return UIImage(named: "ic_wizard_linkedin_small")!
        }
    }
    
    func tagModel() -> (TagModel){
        let model = TagModel()
        model.tagId = self.tagId
        model.name = self.name
        
        return model
    }
    
    func dictionarify() -> NSMutableDictionary {
        let professionModelDictionary : NSMutableDictionary = NSMutableDictionary()
        
        professionModelDictionary["isSelected"] = NSNumber(value: (isSelected ? 1 : 0) as Int)
        
        if let _name = name {
            professionModelDictionary["name"] = _name
        }
        professionModelDictionary["tagId"] = NSNumber(value: Int64(tagId ?? "0")! as Int64)
        professionModelDictionary["tagsDtoType"] = tagsDtoType
        
        return professionModelDictionary
    }
}

class MyProfileModel: ProfileCardModel,Copying {
    var foneVerifyAvailabilityDto : PhoneVerifyModel?
    var college : [ProfessionModel] = []
    var degree : [ProfessionModel] = []
    var company : [ProfessionModel] = []
    var designation : [ProfessionModel] = []
    var relationshipLifestyleTags: [RelationshipLifestyleTagModel] = []
    var zodiac : RelationshipLifestyleTagModel?
    var lastName : String?
    var showInitials = false
    var isMutualFriendVisible = false
    var isPhoneVerificationPartOfOnboarding = false
    var fbSynced = false
    //var phoneNumberDto:NSDictionary?
    
    override init(userInfoDto : NSDictionary) {
        super.init(userInfoDto: userInfoDto)
    }
    
    required override init() {
        super.init()
    }
    
    required init(original: MyProfileModel){
        super.init()
        self.wooId = original.wooId
        self.about = original.about
        self.relationshipLifestyleTags = original.relationshipLifestyleTags
        self.zodiac = original.zodiac
        self.foneVerifyAvailabilityDto = original.foneVerifyAvailabilityDto
        self.profileCompletenessScore = original.profileCompletenessScore
        self.gender = original.gender
        self.firstName = original.firstName
        self.lastName = original.lastName
        self.location = original.location
        self.college = original.college
        self.degree = original.degree
        self.company = original.company
        self.designation = original.designation
        self.showHeightType = original.showHeightType
        self.showInitials = original.showInitials
        self.religion = original.religion.clone()
        self.religionText = original.religionText
        self.tags = original.tags.clone()
        self.height = original.height
        self.personalQuote = original.personalQuote
        self.wooAlbum = original.wooAlbum?.copy() as? WooAlbumModel
        self.isPhoneVerified = original.isPhoneVerified
        self.isLinkedInVerified = original.isLinkedInVerified
        self.isMutualFriendVisible = original.isMutualFriendVisible
        self.age = original.age
        self.badgeType = original.badgeType
        self.ethnicity = original.ethnicity
        self.ethnicityText = original.ethnicityText
        self.phoneNumberDto = original.phoneNumberDto
        self.fbSynced = original.fbSynced
        self.myQuestionsArray = original.myQuestionsArray
        self.profileInfoTags = original.profileInfoTags
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject{
        return MyProfileModel(original: self)
    }
    
    override func updateData(_ userInfoDto: NSDictionary) {
        super.isMyprofile = true
        super.updateData(userInfoDto)
        
        if let _foneVerifyAvailabilityDto = userInfoDto["foneVerifyAvailabilityDto"] {
            foneVerifyAvailabilityDto = PhoneVerifyModel()
            foneVerifyAvailabilityDto!.setData(_foneVerifyAvailabilityDto as! NSDictionary)
            if let _Msisdn = userInfoDto["msisdn"] {
                foneVerifyAvailabilityDto?.phoneNumber = _Msisdn as? String
            }
        }
        
        if userInfoDto.object(forKey: "isPhoneVerificationPartOfOnboarding") != nil {
            self.isPhoneVerificationPartOfOnboarding = userInfoDto.object(forKey: "isPhoneVerificationPartOfOnboarding") as! Bool
        }
//        if let _phoneNumberData = userInfoDto["phoneNumberDto"] {
//            phoneNumberDto = _phoneNumberData as? NSDictionary
//        }
        
        if userInfoDto.object(forKey: "showHeightType") != nil {
            self.showHeightType = HeightUnit(rawValue: (userInfoDto.object(forKey: "showHeightType") as? String)!)!
        }
        
        if userInfoDto.object(forKey: "college") != nil {
            self.college = professionModelArrayFromDto((userInfoDto.object(forKey: "college") as? [[String : AnyObject]])!)
        }
        
        if userInfoDto.object(forKey: "degree") != nil {
            //if self.fbSynced == false && self.isLinkedInVerified == false{
                var jsonResult :[[String:AnyObject]]?
                if let designationPath = Bundle.main.path(forResource: "Degree", ofType: "json")
                {
                    do {
                        let jsonData = try NSData(contentsOfFile: designationPath, options: NSData.ReadingOptions.mappedIfSafe)
                        do {
                            jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options:JSONSerialization.ReadingOptions.mutableContainers) as? [[String:AnyObject]]
                        }
                        catch {}
                    } catch {}
                }
                self.degree = professionModelArrayFromDto(jsonResult!)
                let degreeFromServer = professionModelArrayFromDto((userInfoDto.object(forKey: "degree") as? [[String : AnyObject]])!)

                if let degreeModel = degreeFromServer.first{
                   // if degreeModel.isSelected{
                        for model in degree{
                            if model.tagId == degreeModel.tagId{
                                model.isSelected = true
                            }
                        }
                    //}
                }
            //}
                /*
            else{
                self.degree = professionModelArrayFromDto((userInfoDto.object(forKey: "degree") as? [[String : AnyObject]])!)
            }
            */
        }
        
        if userInfoDto.object(forKey: "relationShipAndLifeStyle") != nil{
            self.relationshipLifestyleTags = relationshipLifestyleModelArrayFromDto((userInfoDto.object(forKey: "relationShipAndLifeStyle") as? [[String : AnyObject]])!)
        }
        
        if userInfoDto.object(forKey: "zodiac") != nil{
            self.zodiac = RelationshipLifestyleTagModel(data: (userInfoDto.object(forKey: "zodiac") as? NSDictionary)!)
        }
        else{
            self.zodiac = nil
        }
        
        if userInfoDto.object(forKey: "company") != nil {
            self.company = professionModelArrayFromDto((userInfoDto.object(forKey: "company") as? [[String : AnyObject]])!)
        }
        
        if userInfoDto.object(forKey: "designation") != nil {
           // if self.fbSynced == false && self.isLinkedInVerified == false{
                var jsonResult :[[String:AnyObject]]?
                if let designationPath = Bundle.main.path(forResource: "Designation", ofType: "json")
                {
                    do {
                        let jsonData = try NSData(contentsOfFile: designationPath, options: NSData.ReadingOptions.mappedIfSafe)
                        do {
                            jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options:JSONSerialization.ReadingOptions.mutableContainers) as? [[String:AnyObject]]
                        }
                        catch {}
                    } catch {}
                }
                self.designation = professionModelArrayFromDto(jsonResult!)
                let designationFromServer = professionModelArrayFromDto((userInfoDto.object(forKey: "designation") as? [[String : AnyObject]])!)
                
                if let designationModel = designationFromServer.first{
                   // if designationModel.isSelected{
                        for model in designation{
                            if model.tagId == designationModel.tagId{
                                model.isSelected = true
                            }
                        }
                    //}
                }
           // }
                /*
            else{
                self.designation = professionModelArrayFromDto((userInfoDto.object(forKey: "designation") as? [[String : AnyObject]])!)
            }
                */

        }
        
        if let _lastName = userInfoDto["lastName"] {
            lastName = _lastName as? String
        }
                
        if let _showInitials = userInfoDto["showInitials"] {
            showInitials = ((_showInitials as? NSNumber)?.boolValue)!
        }
        else{
            showInitials = false
        }
        
        if let _isMutualFriendVisible = userInfoDto["isMutualFriendVisible"] {
            isMutualFriendVisible = ((_isMutualFriendVisible as? NSNumber)?.boolValue)!
        }
        else{
            isMutualFriendVisible = false
        }
        
        if let _fbSynced = userInfoDto["fbSynced"] {
            fbSynced = ((_fbSynced as? NSNumber)?.boolValue)!
        }
        else{
            fbSynced = false
        }
        
        if self.wooAlbum != nil {
            self.wooAlbum!.moveProfilePicToFront()
        }
    }
    
    func updateDataWithLinkedInData(_ userInfoDto: NSDictionary) {
        if let _isMutualFriendVisible = userInfoDto["educationHistory"] {
            isMutualFriendVisible = ((_isMutualFriendVisible as? NSNumber)?.boolValue)!
        }
    }
    
    func relationshipLifestyleModelArrayFromDto(_ dtoArray : [[String : AnyObject]]) -> [RelationshipLifestyleTagModel] {
        var array : [RelationshipLifestyleTagModel] = []
        for dto in dtoArray {
            let model = RelationshipLifestyleTagModel(data: dto as NSDictionary)
            array.append(model)
        }
        return array
    }
    
    func getRelationshipLifestyleModelObjectBasedOnCategory(_ subCategoryId : Int) -> RelationshipLifestyleTagModel? {
        for dto in self.relationshipLifestyleTags {
            if dto.tagsSubCategoryId == subCategoryId{
                return dto
            }
        }
        return nil
    }
    
    
    func myName() -> String? {
            if self.gender == "MALE" {
                return self.nameFormatArray().last
            }
            else{
                if showInitials {
                    return (self.nameFormatArray().count > 0) ?  self.nameFormatArray()[0] : "";
                    
                }
                else{
                   return (self.nameFormatArray().count > 0) ?  self.nameFormatArray()[1] : "";
                }
            }
    }
    
    func nameFormatArray() -> [String]{
        
        if self.firstName.count>0 && self.lastName != nil {
            let fullName = (self.firstName)
            
            let shortName = "\((self.firstName.first)!)\((self.lastName!.first)!)"
            
            let nameArr = [shortName, fullName]
            return nameArr
        }else if self.firstName.count>0 && self.lastName == nil{
            let fullName = (self.firstName)
            
            let shortName = "\((self.firstName.first)!)"
            let nameArr = [shortName, fullName]
            return nameArr
        }else{
            return []
        }
//        if self.firstName.count>0 {
//            var nameArr:[String] = []
//            if self.displayName != nil && (self.displayName?.count)! > 0{
//                nameArr.append(self.displayName!)
//            }
//            nameArr.append(firstName)
//            return nameArr
//        }
//        else{
//            return []
//        }
    }
    
    func setShowInitialsFlag(_ nameFormat: String){
        if let name = nameFormatArray().first {
            if nameFormat == name {
                showInitials = true
            }
            else{
                showInitials = false
            }
        }else{
            showInitials = false
        }
    }

    func selectedCollege() -> ProfessionModel {
        for item in college {
            if item.isSelected {
                return item
            }
        }
        return college.first!
    }
    
    func selectedDegree() -> ProfessionModel {
        
        for item in degree {
            if item.isSelected {
                return item
            }
        }
        return ProfessionModel()
    }
    
    func selectedCompany() -> ProfessionModel {
        
        for item in company {
            if item.isSelected {
                return item
            }
        }
        return company.first!
    }
    
    func selectedDesignation() -> ProfessionModel {
        
        for item in designation {
            if item.isSelected {
                return item
            }
        }
        return ProfessionModel()
    }
    
    func setSelectedCollege(_ tagId : String, reccursiveSelection : Bool){
        for item in college {
            if item.tagId == tagId {
                item.isSelected = true
                if reccursiveSelection && (tagId != "1" && tagId != "2") &&
                   selectedDegree().tagId != "2" {
                    setSelectedDegree(tagId, reccursiveSelection: false)
                }
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    func setSelectedCompany(_ tagId : String, reccursiveSelection : Bool){
        for item in company {
            if item.tagId == tagId {
                item.isSelected = true
                if reccursiveSelection && (tagId != "1" && tagId != "2")  &&
                    selectedDesignation().tagId != "2" {
                    setSelectedDesignation(tagId, reccursiveSelection: false)
                }
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    func setSelectedDegree(_ tagId : String, reccursiveSelection : Bool){
        for item in degree {
            if item.tagId == tagId {
                item.isSelected = true
                if reccursiveSelection && (tagId != "1" && tagId != "2")  &&
                    selectedCollege().tagId != "2" {
                    setSelectedCollege(tagId, reccursiveSelection: false)
                }
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    func setSelectedDesignation(_ tagId : String, reccursiveSelection : Bool){
        for item in designation {
            if item.tagId == tagId {
                item.isSelected = true
                if reccursiveSelection && (tagId != "1" && tagId != "2")  &&
                    selectedCompany().tagId != "2" {
                    setSelectedCompany(tagId, reccursiveSelection: false)
                }
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    func jsonfy() -> String {
        let myProfileDictionary : NSMutableDictionary = super.dictionarify()
        //showHeightType - 1
        myProfileDictionary["showHeightType"] = self.showHeightType.rawValue
        //showInitials - 2
        myProfileDictionary["showInitials"] = NSNumber(value: showInitials as Bool)
        //college - 3
        var _college : [NSMutableDictionary] = []
        _college.append(selectedCollege().dictionarify())
        myProfileDictionary["college"] = _college
        //degree - 4
        var _degree : [NSMutableDictionary] = []
        _degree.append(selectedDegree().dictionarify())
        myProfileDictionary["degree"] = _degree
        //company - 5
        var _company : [NSMutableDictionary] = []
        _company.append(selectedCompany().dictionarify())
        myProfileDictionary["company"] = _company
        //designation - 6
        var _designation : [NSMutableDictionary] = []
        _designation.append(selectedDesignation().dictionarify())
        myProfileDictionary["designation"] = _designation
        
        myProfileDictionary["isMutualFriendVisible"] = isMutualFriendVisible
        
        var _ethnicity : [NSMutableDictionary] = []
        for item in ethnicity{
            _ethnicity.append((item.dictionarify()))
        }
        
        myProfileDictionary["ethnicity"] = _ethnicity
        
        let json = JSONStringify(value: myProfileDictionary)
        
        return json as String
    }
    
    func jsonfyForDictionary(_ profileDict:NSMutableDictionary) -> String{
        let json = JSONStringify(value: profileDict)
        
        return json as String
    }
}
