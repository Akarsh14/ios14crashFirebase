//
//  ProfileActionManager.swift
//  Woo_v2
//
//  Created by Akhil Singh on 11/05/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum ProfileType:Int {
    case ProfileCardModel
    case LikedMe
    case SkippedProfiles
    case MyAnswers
    case CrushesDashboard
    case MyMatches
    case MeDashboard
}

    enum ViewType:Int {
    case Discover
    case LikedMe
    case Visitor
    case SkippedProfiles
    case CrushesDashboard
    case MyAnswers
    case MyQuestions
    case TagSearch
}

@objc class ProfileActionManager: NSObject {
    
    var reloadHandler:((_ toBeDeletedIndexPath:IndexPath)->())?
    
    @objc var reloadHandlerObjC:(()->())?
    
    var performSegueHandler:((_ matchObject:MyMatches)->())?
    var otherActivityHandler: (()->())?
    @objc var performSegueHandlerObjC:((_ matchObject:MyMatches)->())?
    
    var callHandler : ((_ successValue: Bool, _ responseValue: AnyObject, _ statusCodeValue: Int) -> (Void))?
    
    var isCallOnGoing: Bool = false
        
    var crushText:String = ""
    
    var indexPathToBeDeleted:IndexPath?

    var currentProfileWooID:String = ""
    
    var previousProfileWooID:String = ""

    var currentUserDetail:AnyObject?
    
    var answerId: UInt64 = 0
    
    var comingFromProfile:Bool = false
    
    let utilities = Utilities.sharedUtility() as! Utilities
    
    var currentProfileType:ProfileType = ProfileType.ProfileCardModel
    var currentViewType:ViewType = ViewType.Discover

    //like Action
    func likeActionPerformed(_ profileType:ProfileType, userObject:AnyObject, withTagId tagId:String, andTagType tagType:String)
    {
        currentProfileType = profileType
        currentUserDetail = userObject
        likeOrSendCrushToUser(sendingCrush: false,tagId: tagId, andTagType:tagType)
    }
    
    func likeActionPerformed(_ profileType:ProfileType, userObject:AnyObject){
        currentProfileType = profileType
        currentUserDetail = userObject
        likeOrSendCrushToUser(sendingCrush: false,tagId: nil, andTagType:nil)
    }
    
    @objc func likeForObjectiveC(userObject:AnyObject){
        likeActionPerformed(currentProfileType, userObject: userObject)
    }
    
    
    //dislike Action
    func dislikeActionPerformed(_ profileType:ProfileType, userObject:AnyObject, withTagId tagId:String, andTagType tagType:String){
        currentProfileType = profileType
        currentUserDetail = userObject
        dislikeUser(tagId, andTagType: tagType)
    }
    
    func dislikeActionPerformed(_ profileType:ProfileType, userObject:AnyObject){
        currentProfileType = profileType
        currentUserDetail = userObject
        dislikeUser(nil, andTagType: nil)
    }
    
    @objc func dislikeForObjectiveC(userObject:AnyObject){
        dislikeActionPerformed(currentProfileType, userObject: userObject)
    }

    
    //Crush Action
    func crushActionPerformed(_ profileType:ProfileType, userObject:AnyObject, withTagId tagId:String, andTagType tagType:String){
        currentProfileType = profileType
        currentUserDetail = userObject
        likeOrSendCrushToUser(sendingCrush: true, tagId: tagId, andTagType: tagType)
    }
    
    func crushActionPerformed(_ profileType:ProfileType, userObject:AnyObject){
        currentProfileType = profileType
        currentUserDetail = userObject
        likeOrSendCrushToUser(sendingCrush: true, tagId: nil, andTagType: nil)
    }
    
    @objc func setCurrentViewType(type:Int){
        self.currentViewType = ViewType(rawValue: type)!
    }

    @objc func setCurrentProfileType(type:Int){
        self.currentProfileType = ProfileType(rawValue: type)!
    }

    ////Like and Send Crush Calls related method
    
    fileprivate func makeCallWithClosure(_ isCallForCrush:Bool,tagId:String?, andTagType tagType:String?, completionClosure: @escaping (_ successValue: Bool, _ responseValue: AnyObject, _ statusCodeValue: Int) -> Void ){
        
        
        callHandler = completionClosure;
        
        let wooID = currentProfileWooID
        
        if isCallOnGoing == false || wooID != previousProfileWooID {
            isCallOnGoing = true
            previousProfileWooID = wooID
            if isCallForCrush == true {
                DiscoverAPIClass.makeSendCrushCall(withParams: wooID, andCrushText: crushText, andCompletionBlock: { (Success, response, statusCode) in
                    self.isCallOnGoing = false
                    if Success{
                        
                        if ((response as! NSDictionary).allKeys as NSArray).contains("crushAvailable"){
                            CrushModel.sharedInstance().availableCrush = (response as! NSDictionary).object(forKey: "crushAvailable") as! Int
                        }
                        if statusCode == 202{
                            //Like done
                            if CrushModel.sharedInstance().availableCrush <= 0{
                                self.showSnackBar(NSLocalizedString("Crush sent. No more crush left.", comment: ""))
                                
                            }else {
                                
                                self.showSnackBar(String(format: NSLocalizedString("Crush sent.%d crushes left", comment: "Crush sent.%d crushes left"),CrushModel.sharedInstance().availableCrush))
                                
                            }
                            
                        }
                        else if statusCode == 200{
                            if self.currentViewType == .Discover{
                                Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: wooID, shouldDeleteFromAnswer: true, withCompletionHandler: nil)
                            }
                            else{
                            Utilities().deleteMatchUser(fromAppExceptMatchBox: wooID, shouldDeleteFromAnswer:true, withCompletionHandler:nil)
                            }
                        }
                        self.callHandler!(Success, (response as! NSDictionary), Int(statusCode))
                    }
                })
            }
            else{
                if currentProfileType == .MyAnswers {
                    
                    QuestionAnswerAPIClass.likeAAnswer(forAnswerObject: NSNumber(value: answerId as UInt64), andCompletionBlock: { (success, response, statusCode) in
                        self.isCallOnGoing = false
                        if success{
                            
                            if statusCode == 202{
                                //Like done
                            }
                            else if statusCode == 200{
                                //Match Flow
                                if self.currentViewType == .Discover{
                                    Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: wooID, shouldDeleteFromAnswer: true, withCompletionHandler: nil)
                                }
                                else{
                                    Utilities().deleteMatchUser(fromAppExceptMatchBox: wooID, shouldDeleteFromAnswer:true, withCompletionHandler:nil)
                                }
                            }
                            self.callHandler!(success, (response as! NSDictionary), Int(statusCode))
                        }
                        
                    })
                }
                else{
                DiscoverAPIClass.makeLikeCall(withParams: wooID, andSelectedTag: nil, withTagId: tagId , andTagDTOType: tagType, andCompletionBlock: { (Success, response, statusCode) in
                self.isCallOnGoing = false
                if Success{
                    
                    if statusCode == 202{
                        //Like done
                    }
                    else if statusCode == 200{
                        //Match Flow
                        if self.currentViewType == .Discover{
                            Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: wooID, shouldDeleteFromAnswer: true, withCompletionHandler: nil)
                        }
                        else{
                            Utilities().deleteMatchUser(fromAppExceptMatchBox: wooID, shouldDeleteFromAnswer:true, withCompletionHandler:nil)
                        }
                    }
                
                    if let data = response as? NSDictionary{
                        self.callHandler!(Success, data, Int(statusCode))
                    }else{
                        self.callHandler!(Success, ["":""] as NSDictionary, Int(statusCode))
                    }
                   
                }
            })
                }
            }
        }
    }
    
    fileprivate func likeOrSendCrushToUser(sendingCrush:Bool,tagId:String?, andTagType tagType:String?)
    {
        
        if sendingCrush == false {
            AppLaunchModel.sharedInstance().likeCount += 1
        }
        var isProfileLiked = false
        var currentUserWooID = ""
        switch currentProfileType {
        case .ProfileCardModel:
            self.utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_CrushTap")
            isProfileLiked = (self.currentUserDetail as! ProfileCardModel).isProfileLiked
            if let wooid = (self.currentUserDetail as! ProfileCardModel).wooId{
                currentUserWooID = wooid
            }
            break
        case .LikedMe:
            self.utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_CrushTap")
            isProfileLiked = ((self.currentUserDetail as! LikedByMe).isUserLiked?.boolValue) ?? false
            if let wooid = (self.currentUserDetail as! LikedByMe).userWooId{
                currentUserWooID = wooid
            }
            break
        case .MeDashboard:
            self.utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_CrushTap")
            isProfileLiked = ((self.currentUserDetail as! MeDashboard).isVisitorLiked?.boolValue) ?? false
            if let wooid = (self.currentUserDetail as! MeDashboard).visitorId{
                currentUserWooID = wooid
            }
            break
            
        case .SkippedProfiles:
            self.utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_CrushTap")
            isProfileLiked = ((self.currentUserDetail as! SkippedProfiles).isUserLiked?.boolValue) ?? false
            if let wooid = (self.currentUserDetail as! SkippedProfiles).userWooId{
                currentUserWooID = wooid
            }
            break
            
        case .MyAnswers:
            self.utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_CrushTap")
            isProfileLiked = true
            if let wooid = (self.currentUserDetail as! MyAnswers).wooId{
                currentUserWooID = wooid.stringValue
            }
            if let answerid = (currentUserDetail as! MyAnswers).answerId{
                answerId = answerid.uint64Value
            }
            break
        case .CrushesDashboard:
            isProfileLiked = true
            if let wooid = (self.currentUserDetail as! CrushesDashboard).userID{
                currentUserWooID = wooid
            }
            
        case .MyMatches:
            break
        }

        currentProfileWooID = currentUserWooID
        // Srwve Event
        //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "DiscoverCards", withEventName: "3-Discovery.DiscoverCards.DC_LikeByTapOrSwipe")
        
        //New flow that will work offline also.
        
        if isProfileLiked == true {
            if currentViewType == .Discover {
                Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: currentUserWooID, shouldDeleteFromAnswer: true, withCompletionHandler: { (success:Bool) in
                    if self.currentViewType == .CrushesDashboard{
                        if self.reloadHandlerObjC != nil {
                            self.reloadHandlerObjC!()
                        }
                    }
                    else{
                        if self.reloadHandler != nil {
                            print("reloadHandler")
                            if let index = self.indexPathToBeDeleted{
                                self.reloadHandler!(index)
                            }
                        }
                    }
                    
                })
            }
            else{
                Utilities().deleteMatchUser(fromAppExceptMatchBox: currentUserWooID, shouldDeleteFromAnswer:true, withCompletionHandler:{(success:Bool) in
                    if self.currentViewType == .CrushesDashboard{
                        if self.reloadHandlerObjC != nil {
                            self.reloadHandlerObjC!()
                        }
                    }
                    else{
                        if self.reloadHandler != nil {
                            print("reloadHandler")
                            if let index = self.indexPathToBeDeleted{
                                self.reloadHandler!(index)
                            }
                        }
                    }
                    
                })
            }

                let matchEventDict : NSDictionary = NSDictionary.init(object: self.maketheDummyDataForMatch(), forKey: "matchEventDto" as NSCopying)
            
            //Match Flow
            let matchDataDict = matchEventDict.object(forKey: "matchEventDto") as? NSDictionary
            self.completeMatchFlowForMatchObject(matchDataDict!, forCrush: sendingCrush, tagId: tagId,andTagType: tagType, profileLiked: isProfileLiked)
            
            //                        MyMatches.insert
        }
        else{
            if currentViewType == .Discover {
                Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: currentUserWooID, shouldDeleteFromAnswer: false, withCompletionHandler: { (success:Bool) in
                    if self.currentViewType == .CrushesDashboard{
                        if self.reloadHandlerObjC != nil {
                            self.reloadHandlerObjC!()
                        }
                    }
                    else{
                        if self.reloadHandler != nil {
                            print("reloadHandler")
                            if let index = self.indexPathToBeDeleted{
                                self.reloadHandler!(index)
                            }
                        }
                    }
                    
                })
            }
            else{
                Utilities().deleteMatchUser(fromAppExceptMatchBox: currentUserWooID, shouldDeleteFromAnswer:false, withCompletionHandler:{(success:Bool) in
                    if self.currentViewType == .CrushesDashboard{
                        if self.reloadHandlerObjC != nil {
                            self.reloadHandlerObjC!()
                        }
                    }
                    else{
                        if self.reloadHandler != nil {
                            print("reloadHandler")
                            if let index = self.indexPathToBeDeleted{
                                self.reloadHandler!(index)
                            }
                        }
                    }
                    
                })
            }
            
            if currentViewType == .Discover ||  currentViewType == .SkippedProfiles{
            
            LikedByMe.insertOrUpdateSkippedProfileData(fromDiscoverCard: [self.currentUserDetail], withCompletionHandler:{(completion) in
                if(completion)
                {
                    self.makeCallWithClosure(sendingCrush, tagId: tagId,andTagType: tagType, completionClosure: { (success, response, statusCode) in
                        if success{
                            if statusCode == 202{
                                //Like done
                            }
                            else if statusCode == 200{
                                //Match Flow
                                if isProfileLiked == false{
                                    let matchDataDict = (response as! NSDictionary).object(forKey: "matchEventDto") as? NSDictionary
                                    MyMatches.insertDataInMyMatches(from: NSArray(objects: matchDataDict!) as [AnyObject], withChatInsertionSuccess: {(success) in
                                        let matchedUserDataFromDb = MyMatches.getMatchDetail(forMatchID: matchDataDict?.object(forKey: "matchId") as? String)
                                        self.updateCrushText()

                                        print("matchedUserDataFromDb\(String(describing: matchedUserDataFromDb))")
                                        if matchedUserDataFromDb != nil{
                                            var overlayButtonType:OverlayButtonType = .Return_To_Dashboard
                                            if self.currentViewType == .Discover{
                                                overlayButtonType = .Keep_Swiping
                                            }
                                            let viewObj = NewMatchOverlayView.showView((response as? NSDictionary)!, buttonType: overlayButtonType)
                                            viewObj.removeViewOnStartChatButton = true
                                            viewObj.chatButtonHandler = {(matchDto) in
                                                if matchDto != nil{
                                                    self.addCrushMessageAfterUserMatchedThroughCrush(matchedUserDataFromDb!)
                                                    if self.currentViewType == .CrushesDashboard{
                                                        if self.performSegueHandlerObjC != nil {
                                                            self.performSegueHandlerObjC!(matchedUserDataFromDb!)
                                                        }
                                                    }
                                                    else{
                                                        if self.performSegueHandler != nil {
                                                            self.performSegueHandler!(matchedUserDataFromDb!)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    })
                                    
                                }
                                
                                
                            }
                        }
                    })
                }
            })
             }else{
                self.makeCallWithClosure(sendingCrush, tagId: tagId,andTagType: tagType, completionClosure: { (success, response, statusCode) in
                    if success{
                        if statusCode == 202{
                            //Like done
                        }
                        else if statusCode == 200{
                            //Match Flow
                            if isProfileLiked == false{
                                let matchDataDict = (response as! NSDictionary).object(forKey: "matchEventDto") as? NSDictionary
                                MyMatches.insertDataInMyMatches(from: NSArray(objects: matchDataDict!) as [AnyObject], withChatInsertionSuccess: {(success) in
                                    let matchedUserDataFromDb = MyMatches.getMatchDetail(forMatchID: matchDataDict?.object(forKey: "matchId") as? String)
                                    self.updateCrushText()

                                    print("matchedUserDataFromDb\(String(describing: matchedUserDataFromDb))")
                                    if matchedUserDataFromDb != nil{
                                        var overlayButtonType:OverlayButtonType = .Return_To_Dashboard
                                        if self.currentViewType == .Discover{
                                            overlayButtonType = .Keep_Swiping
                                        }
                                        let viewObj = NewMatchOverlayView.showView((response as? NSDictionary)!, buttonType: overlayButtonType)
                                        viewObj.removeViewOnStartChatButton = true
                                        viewObj.chatButtonHandler = {(matchDto) in
                                            if matchDto != nil{
                                                self.addCrushMessageAfterUserMatchedThroughCrush(matchedUserDataFromDb!)
                                                if self.currentViewType == .CrushesDashboard{
                                                    if self.performSegueHandlerObjC != nil {
                                                        self.performSegueHandlerObjC!(matchedUserDataFromDb!)
                                                    }
                                                }
                                                else{
                                                    if self.performSegueHandler != nil {
                                                        self.performSegueHandler!(matchedUserDataFromDb!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                })
                                
                            }
                            
                            
                        }
                    }
                })
            }
            
        }
    }
    
    fileprivate func maketheDummyDataForMatch() -> NSMutableDictionary{
    let matchDict : NSMutableDictionary = NSMutableDictionary()
    let matchIdStr = NSString(format:"\(currentProfileWooID)_\(UserDefaults.standard.object(forKey: "id")!)" as NSString)
    matchDict.setValue(matchIdStr, forKey: "matchId")
    matchDict.setValue("layer:///dummyChatId", forKey: "chatId")
        switch currentProfileType {
        case .ProfileCardModel:
            matchDict.setValue((currentUserDetail as! ProfileCardModel).location, forKey: "targetUserLocation")
            matchDict.setValue((currentUserDetail as! ProfileCardModel).gender, forKey: "requesterGender")
            matchDict.setValue((currentUserDetail as! ProfileCardModel).firstName, forKey: "requesterName")
            matchDict.setValue(UserDefaults.standard.object(forKey: "id")!, forKey: "targetId")
            matchDict.setValue((currentUserDetail as! ProfileCardModel).wooAlbum?.discoverProfilePicUrl() ?? "", forKey: "requesterProfilePicture")
            matchDict.setValue("<b>\((currentUserDetail as! ProfileCardModel).firstName)</b> likes you too!", forKey: "text")
            break
            
        case .LikedMe:
            matchDict.setValue(DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation, forKey: "targetUserLocation")
            matchDict.setValue((currentUserDetail as! LikedByMe).userGender, forKey: "requesterGender")
            matchDict.setValue((currentUserDetail as! LikedByMe).userFirstName, forKey: "requesterName")
            matchDict.setValue((currentUserDetail as! LikedByMe).userProfilePicURL, forKey: "requesterProfilePicture")
            if let name = (currentUserDetail as! LikedByMe).userFirstName{
                matchDict.setValue("<b>\(name)</b> likes you too!", forKey: "text")
            }
            break
            
        case .MeDashboard:
            matchDict.setValue(DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation, forKey: "targetUserLocation")
            matchDict.setValue((currentUserDetail as! MeDashboard).visitorGender, forKey: "requesterGender")
            matchDict.setValue((currentUserDetail as! MeDashboard).visitorFirstName, forKey: "requesterName")
            matchDict.setValue((currentUserDetail as! MeDashboard).visitorProfilePicURL, forKey: "requesterProfilePicture")
            matchDict.setValue("<b>\((currentUserDetail as! MeDashboard).visitorFirstName ?? "")</b> likes you too!", forKey: "text")
            break
            
        case .SkippedProfiles:
            matchDict.setValue(DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation, forKey: "targetUserLocation")
            matchDict.setValue((currentUserDetail as! SkippedProfiles).userGender, forKey: "requesterGender")
            matchDict.setValue((currentUserDetail as! SkippedProfiles).userFirstName, forKey: "requesterName")
            matchDict.setValue((currentUserDetail as! SkippedProfiles).userProfilePicURL, forKey: "requesterProfilePicture")
            matchDict.setValue("<b>\((currentUserDetail as! SkippedProfiles).userFirstName ?? "")</b> likes you too!", forKey: "text")

            break
            
        case .MyAnswers:
            matchDict.setValue(DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation, forKey: "targetUserLocation")
            matchDict.setValue((currentUserDetail as! MyAnswers).userName, forKey: "requesterName")
            matchDict.setValue((currentUserDetail as! MyAnswers).userImageURL, forKey: "requesterProfilePicture")
            matchDict.setValue("<b>\((currentUserDetail as! MyAnswers).userName ?? "")</b> likes you too!", forKey: "text")
            
            break
            
        case .CrushesDashboard:
            matchDict.setValue(DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation, forKey: "targetUserLocation")
            matchDict.setValue((currentUserDetail as! CrushesDashboard).userGender, forKey: "requesterGender")
            matchDict.setValue((currentUserDetail as! CrushesDashboard).userName, forKey: "requesterName")
            matchDict.setValue((currentUserDetail as! CrushesDashboard).imageURL, forKey: "requesterProfilePicture")
            matchDict.setValue("<b>\((currentUserDetail as! CrushesDashboard).userName ?? "")</b> likes you too!", forKey: "text")
            break
        case .MyMatches:
            break
        }

    matchDict.setValue(currentProfileWooID, forKey: "requesterId")
    matchDict.setValue(UserDefaults.standard.object(forKey: "id")!, forKey: "targetId")
    matchDict.setValue("WOOHOO!", forKey: "title")
    matchDict.setValue("\(NSDate().timeIntervalSince1970 * 1000)", forKey: "matchedTime")
    matchDict.setValue(NSNumber(value: MATCHED_USER_STATUS_NONE.rawValue), forKey: "matchedUserStatus")
        
        matchDict.setValue(NSNumber(value: MATCHED_USER_STATUS_NONE.rawValue), forKey: "requesterFlagged")
        matchDict.setValue(NSNumber(value: MATCHED_USER_STATUS_NONE.rawValue), forKey: "targetFlagged")

    
    return matchDict
    }
    
    fileprivate func completeMatchFlowForMatchObject(_ matchDataDict:NSDictionary, forCrush:Bool,tagId:String?, andTagType tagType:String?, profileLiked:Bool){
        MyMatches.insertDataInMyMatches(from: NSArray(objects: matchDataDict) as [AnyObject], withChatInsertionSuccess: {(success) in
            let matchedUserDataFromDb = MyMatches.getMatchDetail(forMatchID: matchDataDict.object(forKey: "matchId") as? String)
            
                self.updateCrushText()
                
                if matchedUserDataFromDb != nil{
                    self.addCrushMessageAfterUserMatchedThroughCrush(matchedUserDataFromDb!)
                    
                    var overlayButtonType:OverlayButtonType = .Return_To_Dashboard
                    if self.currentViewType == .Discover{
                        overlayButtonType = .Keep_Swiping
                    }
                    let viewObj = NewMatchOverlayView.showView(matchDataDict, buttonType: overlayButtonType)
                    viewObj.removeViewOnStartChatButton = false
                    
                    self.makeCallWithClosure(forCrush, tagId: tagId,andTagType: tagType, completionClosure: { (Success, response, statusCode) in
                        if Success{
                            //6999
                            if statusCode == 202{
                                
                                if profileLiked{
                                    //match user deleted
                                    MyMatches.updateMatchedUserDummyStatus(kisAppLozicServer, forID: kDummyApplozicChatID, forChatRoomId: matchDataDict.object(forKey: "matchId") as! String, withUpdationCompletionHandler: { (success) in
                                        
                                        MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue), forChatRoomId: matchDataDict.object(forKey: "matchId") as? String, withUpdationCompletionHandler:
                                            {(success) in
                                                
                                        })
                                        
                                    })
                                    
                                }
                                //Like done
                                //                                        if matchedUserDataFromDb?.matchedUserStatus.intValue != Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue) {
                                //                                            viewObj.changeTextOnButton(textOnButton: "Retry")
                                //                                        }
                                BoostProductsAPICalss.makeMatchFailureEventCallToServer(withTargetId: self.currentProfileWooID)
                            }
                            else if statusCode == 200{
                                //Match Flow
                                //                                                    MyMatches
                                let mainMatchDictionary = (response as! NSDictionary)
                                if  mainMatchDictionary.object(forKey: "matchEventDto") != nil {
                                    let matchDataDict = mainMatchDictionary.object(forKey: "matchEventDto") as! NSDictionary
                                    
                                    var chatServerKey = ""
                                    if let chatServer = matchDataDict.object(forKey: ksecretChatKey){
                                        chatServerKey = chatServer as! String
                                    }
                                    
                                    if chatServerKey == kisAppLozicServer{
                                        MyMatches.insertDataInMyMatches(from: NSArray(objects: matchDataDict) as [AnyObject], withChatInsertionSuccess: {(success) in
                                            MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue), forChatRoomId:matchDataDict.object(forKey: "matchId") as! String , withUpdationCompletionHandler: nil)
                                        })
                                    }
                                    else{
                                    if (matchDataDict.object(forKey: "chatId") != nil) {
                                        //                                            viewObj.removeFromSuperview()
                                        MyMatches.insertDataInMyMatches(from: NSArray(objects: matchDataDict) as [AnyObject], withChatInsertionSuccess: {(success) in
                                            MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue), forChatRoomId:matchDataDict.object(forKey: "matchId") as! String , withUpdationCompletionHandler: nil)
                                        })
                                        
                                    }
                                    else{
                                        //                                            if matchedUserDataFromDb?.matchedUserStatus.intValue != Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue) {
                                        //                                                viewObj.changeTextOnButton(textOnButton: "Retry")
                                        //                                            }
                                        BoostProductsAPICalss.makeMatchFailureEventCallToServer(withTargetId: self.currentProfileWooID)
                                        MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_RETRY.rawValue), forChatRoomId:matchDataDict.object(forKey: "matchId") as! String, withUpdationCompletionHandler: nil)
                                    }
                                    }
                                }
                            }
                        }
                    })
                    viewObj.otherActivityHandler = {
                        if(self.otherActivityHandler != nil)
                        {
                            self.otherActivityHandler!()
                        }
                    }
                    viewObj.chatButtonHandler = {(matchDto) in
                        if matchDto != nil{
                            //

                            if matchedUserDataFromDb?.matchedUserStatus.intValue != Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue){
                                
                                if matchedUserDataFromDb?.matchedUserStatus.intValue == Int(MATCHED_USER_STATUS_ESTABLISHING_CONNECTION.rawValue) {
                                    // go to matchbox
                                    viewObj.removeFromSuperview()
                                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                                }
                                else{
                                    viewObj.changeTextOnButton(textOnButton: "       Establishing connection")
                                    viewObj.addActivityIndicatorToButton()
                                    self.makeCallWithClosure(forCrush, tagId: nil, andTagType:nil, completionClosure: { (Success, response, statusCode) in
                                        if Success{
                                            //6999
                                            if statusCode == 202{
                                                if(matchedUserDataFromDb?.targetAppLozicId == kDummyApplozicChatID){
                                                     viewObj.removeFromSuperview()
                                                    MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue), forChatRoomId: matchDataDict.object(forKey: "matchId") as? String, withUpdationCompletionHandler:
                                                        {(success) in
                                                            
                                                            NSLog("Successfull???\(success)")
                                                            if self.currentViewType == .CrushesDashboard{
                                                                if self.performSegueHandlerObjC != nil {
                                                                    self.performSegueHandlerObjC!(matchedUserDataFromDb!)
                                                                }
                                                            }
                                                            else{
                                                                if self.performSegueHandler != nil {
                                                                    self.performSegueHandler!(matchedUserDataFromDb!)
                                                                }
                                                            }
                                                    })
                                                }else{
                                                //Like done
                                                if matchedUserDataFromDb?.matchedUserStatus.intValue != Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue) {
                                                    BoostProductsAPICalss.makeMatchFailureEventCallToServer(withTargetId: self.currentProfileWooID)
                                                    viewObj.changeTextOnButton(textOnButton: "Retry")
                                                    viewObj.removeActivityIndicatorFromButton()
                                                }
                                                }
                                            }
                                            else if statusCode == 200{
                                                //Match Flow
                                                //                                                    MyMatches
                                                let mainMatchDictionary = (response as! NSDictionary)
                                                let matchDataDict = mainMatchDictionary.object(forKey: "matchEventDto") as! NSDictionary
                                                if (matchDataDict.object(forKey: "chatId") != nil) {
                                                    viewObj.removeFromSuperview()
                                                    MyMatches.insertDataInMyMatches(from: NSArray(objects: matchDataDict) as [AnyObject], withChatInsertionSuccess: {(success) in
                                                        MyMatches.updateMatchedUserStatus(Int32(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue), forChatRoomId: matchDataDict.object(forKey: "matchId") as! String, withUpdationCompletionHandler:
                                                            {(success) in
                                                                
                                                                NSLog("Successfull???\(success)")
                                                                if self.currentViewType == .CrushesDashboard{
                                                                    if self.performSegueHandlerObjC != nil {
                                                                        self.performSegueHandlerObjC!(matchedUserDataFromDb!)
                                                                    }
                                                                }
                                                                else{
                                                                    if self.performSegueHandler != nil {
                                                                        self.performSegueHandler!(matchedUserDataFromDb!)
                                                                    }
                                                                }
                                                        })
                                                    })
                                                    
                                                }
                                                else{
                                                    if matchedUserDataFromDb?.matchedUserStatus.intValue != Int(MATCHED_USER_STATUS_CONNECTED_TO_LAYER.rawValue) {
                                                        BoostProductsAPICalss.makeMatchFailureEventCallToServer(withTargetId: self.currentProfileWooID)
                                                        viewObj.changeTextOnButton(textOnButton: "Retry")
                                                    }
                                                }
                                            }
                                        }
                                    })
                                }
                                
                                
                            }
                            else{
                                print("matchedUserDataFromDb >> \(String(describing: matchedUserDataFromDb))")
                                viewObj.removeFromSuperview()
                                if self.currentViewType == .CrushesDashboard{
                                    if self.performSegueHandlerObjC != nil {
                                        self.performSegueHandlerObjC!(matchedUserDataFromDb!)
                                    }
                                }
                                else{
                                    if self.performSegueHandler != nil {
                                        self.performSegueHandler!(matchedUserDataFromDb!)
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
            
        })
    }
    
    
    fileprivate func addCrushMessageAfterUserMatchedThroughCrush(_ matchedUserDetail: MyMatches) -> Void {
        if (crushText.count < 1) {
            return
        }
        
        let chatDetailDict : NSMutableDictionary = NSMutableDictionary()
        chatDetailDict.setObject(NSNumber(value: Date().timeIntervalSince1970*1000 as Double), forKey:"clientMessageID" as NSCopying)
        chatDetailDict.setObject(NSNumber(value: Date().timeIntervalSince1970*1000 as Double), forKey:"chatMessageCreatedTime" as NSCopying)
        chatDetailDict.setObject(NSNumber(value: 12 as Int32), forKey:"messageType" as NSCopying)
        chatDetailDict.setObject(crushText, forKey:"message" as NSCopying)
        chatDetailDict.setObject(NSNumber(value: false as Bool), forKey:"isDelivered" as NSCopying)
        chatDetailDict.setObject("", forKey:"serverMessageID" as NSCopying)
        chatDetailDict.setObject(matchedUserDetail.matchId, forKey:"chatRoomID" as NSCopying)
        if (crushText.count > 1)  {
            chatDetailDict.setObject(currentProfileWooID, forKey:"messageSenderID" as NSCopying)
            chatDetailDict.setObject(UserDefaults.standard.object(forKey: "id")!, forKey:"messageReceiverID" as NSCopying)
        }
        else{
            chatDetailDict.setObject(currentProfileWooID, forKey:"messageReceiverID" as NSCopying)
            chatDetailDict.setObject(UserDefaults.standard.object(forKey: "id")!, forKey:"messageSenderID" as NSCopying)
        }
        ChatMessage.insertNewChatMessage(intoDatabase: chatDetailDict as NSDictionary as! [AnyHashable: Any], withCompletionHandler: { (chatMessage) in
            
        })
    }
    
    fileprivate func dislikeUser(_ tagId:String?, andTagType tagType:String?){
        var currentUserWooID = ""
        switch currentProfileType {
        case .ProfileCardModel:
            utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_Skip")
            if let wooID = (self.currentUserDetail as! ProfileCardModel).wooId{
                currentUserWooID = wooID as String
            }
            break
        case .LikedMe:
            utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_Skip")
            if let wooID = (self.currentUserDetail as! LikedByMe).userWooId{
                currentUserWooID = wooID as String
            }
            break
            
        case .MeDashboard:
            utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_Skip")
            if let wooID = (self.currentUserDetail as! MeDashboard).visitorId{
                currentUserWooID = wooID as String
            }
            break
            
        case .SkippedProfiles:
            utilities.sendFirebaseEvent(withScreenName: "", withEventName: "MV_Deck_Skip")
            if let wooID = (self.currentUserDetail as! SkippedProfiles).userWooId{
                currentUserWooID = wooID as String
            }
            break
        case .MyAnswers:
            if let userID = self.currentUserDetail as? MyAnswers{
                currentUserWooID = userID.wooId.stringValue
            }
            break
        case .CrushesDashboard:
            currentUserWooID = (self.currentUserDetail as! CrushesDashboard).userID!
            break
        case .MyMatches:
            break
        }

        currentProfileWooID = currentUserWooID
        
        if currentViewType == .Discover {
            
            //check if is male or female
            if (DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "FEMALE"){
                Utilities().deleteMatchUser(fromAppExceptMatchBoxWithoutReload: currentUserWooID, shouldDeleteFromAnswer: false, withCompletionHandler: { (success:Bool) in
                    if self.currentViewType == .CrushesDashboard{
                        if self.reloadHandlerObjC != nil {
                            self.reloadHandlerObjC!()
                        }
                    }
                    else{
                        if self.reloadHandler != nil {
                            print("reloadHandler")
                            if let index = self.indexPathToBeDeleted{
                                self.reloadHandler!(index)
                            }
                        }
                    }
                    
                })
            }
            else
            {
                if self.currentViewType == .CrushesDashboard{
                    if self.reloadHandlerObjC != nil {
                        self.reloadHandlerObjC!()
                    }
                }
                else{
                    if self.reloadHandler != nil {
                        print("reloadHandler")
                        if let index = self.indexPathToBeDeleted{
                            self.reloadHandler!(index)
                        }
                    }
                }
            }
        }
        else{
            Utilities().deleteMatchUser(fromAppExceptMatchBox: currentUserWooID, shouldDeleteFromAnswer:false, withCompletionHandler:{(success:Bool) in
                if self.currentViewType == .CrushesDashboard{
                    if self.reloadHandlerObjC != nil {
                        self.reloadHandlerObjC!()
                    }
                }
                else{
                    if self.reloadHandler != nil {
                        print("reloadHandler")
                        if let index = self.indexPathToBeDeleted{
                            self.reloadHandler!(index)
                        }
                    }
                }
                
            })
        }
        
        var subsourceString = kDislikeSubSourceDislikeValue
        if currentViewType == .Discover {
            subsourceString = kDislikeSubSourcePassValue
            let commonTagData:NSMutableDictionary = NSMutableDictionary()
            let profileCardModelObject = currentUserDetail as! ProfileCardModel
            if profileCardModelObject.myQuestionsArray.count > 0{
                if let targetQuestion = profileCardModelObject.myQuestionsArray.first{
                    commonTagData.setValue(targetQuestion.question, forKey: "questionAsked")
                    commonTagData.setValue("USER_QUESTIONS", forKey: "tagsDtoType")
                    commonTagData.setValue(0, forKey: "order")
                    commonTagData.setValue("ic_question.png", forKey: "url")
                }
            }
            else if profileCardModelObject.tags.count > 0{
                if let tag = profileCardModelObject.tags.first{
                    commonTagData.setValue(tag.tagId, forKey: "tagId")
                    commonTagData.setValue(tag.name, forKey: "name")
                    commonTagData.setValue(tag.tagsDtoType, forKey: "tagsDtoType")
                    commonTagData.setValue(0, forKey: "order")
                    commonTagData.setValue("ic_tag.png", forKey: "url")
                }
            }
            else if let locationObject = profileCardModelObject.location{
                commonTagData.setValue(locationObject, forKey: "commonLocation")
                commonTagData.setValue("USER_DISTANCE", forKey: "tagsDtoType")
                commonTagData.setValue(0, forKey: "order")
                commonTagData.setValue("ic_location.png", forKey: "url")
            }
            
            profileCardModelObject.commonTagDto = commonTagData
            SkippedProfiles.insertOrUpdateSkippedProfileData(fromDiscoverCard: [profileCardModelObject], withCompletionHandler:{(completion) in
                if(completion)
                {
                    DiscoverAPIClass.makePassCall(withParams: self.currentProfileWooID, withSubsource: subsourceString, withTagId: tagId, andTagDTOType: tagType, andCompletionBlock: { (success, response, statuscode) in
                        if success{
                        }
                    })
                }
            })
         }
        else
        {
            DiscoverAPIClass.makePassCall(withParams: currentProfileWooID, withSubsource: subsourceString, withTagId: tagId, andTagDTOType: tagType, andCompletionBlock: { (success, response, statuscode) in
                if success{
                    //Pass Done
                }
            })
        }
        
        
    }
    
    fileprivate func updateCrushText(){
        switch self.currentProfileType {
        case .ProfileCardModel:
            if (self.currentUserDetail as! ProfileCardModel).crushText.length > 0 {
                self.crushText = (self.currentUserDetail as! ProfileCardModel).crushText as String
            }
            break
            
        case .LikedMe:
            if ((self.currentUserDetail as! LikedByMe).crushMsgSendToUser?.count) ?? 0 > 0 {
                self.crushText = ((self.currentUserDetail as! LikedByMe).crushMsgSendToUser)!
            }
            break
            
        case .MeDashboard:
            if ((self.currentUserDetail as! MeDashboard).crushMsgSendToUser?.count) ?? 0 > 0 {
                self.crushText = ((self.currentUserDetail as! LikedByMe).crushMsgSendToUser)!
            }
            break
            
        case .SkippedProfiles:
            if ((self.currentUserDetail as! SkippedProfiles).crushMsgSendToUser?.count) ?? 0 > 0 {
                self.crushText = ((self.currentUserDetail as! LikedByMe).crushMsgSendToUser)!
            }
            break
        case .MyAnswers:
            self.crushText = ""
            break
            
        default:
            break
    }

    }
    
    fileprivate func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }


}
