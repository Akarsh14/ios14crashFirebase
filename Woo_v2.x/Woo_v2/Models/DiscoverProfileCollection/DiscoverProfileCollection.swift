//
//  DiscoverProfileCollection.swift
//  Woo_v2
//
//  Created by Suparno Bose on 31/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



enum CardType {
    case profile_CARD
    case brand_CARD
    case new_USER_NO_PIC
}

@objc enum CollectionMode : Int {
    case discover
    case my_PROFILE
    case discover_EMPTY
}

class DiscoverProfileCollection: NSObject {
    
    @objc static let sharedInstance = DiscoverProfileCollection()
    
    @objc var myProfileData : MyProfileModel?
    
   @objc var selectedTagData : TagModel?
    
   @objc var selectedUserTagWooID : String?
    
    @objc var discoverModelCollection : NSMutableArray = NSMutableArray()
    
    var profileCardCollection : NSMutableArray = NSMutableArray()
    
    var searchModelCollection : NSMutableArray = NSMutableArray()
    
    var searchEmptyModelCollection : NSMutableArray = NSMutableArray()
    
    var tagSearchHasBeenPerformed : Bool = false
    
    var comingFromDiscover : Bool = false

    @objc var collectionMode = CollectionMode.discover
    
   @objc var paginationToken = ""
    
   @objc var paginationIndex = ""
    
  @objc  var isPaginationTokenExpired:Bool = false
    
    var tagSearchPaginationToken = ""
    
    var tagSearchPaginationIndex = ""
    
    var istagSearchPaginationTokenExpired:Bool = false
    
    @objc var intentModelObject : IntentModel?
    
    var pendingPhotoList : [AlbumPhoto]?
    
    var cardCollection : Observable<NSMutableArray> = Observable<NSMutableArray>(NSMutableArray())
    
    var collectionScilentlyReloded = false
    
    @objc var needToMakeDiscoverCallAsPreferencesHasBeenChanged:Bool = false
    
    var needToMakeServerCallAndReload = false
    
   @objc var callInProgress = false

    var discoverDataHasArrivedButViewNotPresent = false
    
    var discoverDataCount = 0
    
    var searchProfileCount = 0
    
    var currentProfileWooID = ""
        
   @objc var needToSendWooIDsForFLP = false
    
    var flpWooIDs:NSMutableArray = NSMutableArray()
    
    var wizardCurrentScreen = 0

    var wooTipsCurrenScreenIndex = 0

    fileprivate override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(DiscoverProfileCollection.appTerminationHandler), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnectionStatusChanged),
                                                         name: NSNotification.Name(rawValue: kInternetConnectionStatusChanged), object: nil)
        
        let userDefault: UserDefaults = UserDefaults.standard
        
        let intentDecodedData: Data? = userDefault.object(forKey: kIntentModelKey) as? Data
        if intentDecodedData != nil {
            intentModelObject = NSKeyedUnarchiver.unarchiveObject(with: intentDecodedData!) as? IntentModel
        }
        else{
            intentModelObject = IntentModel()
        }
        
        let pendingImageDecodedData: Data? = userDefault.object(forKey: kPendingPhotoList) as? Data
        if pendingImageDecodedData != nil {
            pendingPhotoList = NSKeyedUnarchiver.unarchiveObject(with: pendingImageDecodedData!) as? [AlbumPhoto]
        }
        else{
            pendingPhotoList = []
        }
    }
    
    func count() -> Int {
        return cardCollection.get().count
    }
    
    func searchDataCount() -> Int {
        return self.searchModelCollection.count
    }
    
  @objc func updateMyProfileData(_ myData : NSDictionary) {
        if (myProfileData != nil) {
            myProfileData?.updateData(myData)
            (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: myProfileData?.wooAlbum?.allImagesUrl())
        }
        else{
            myProfileData = MyProfileModel(userInfoDto: myData)
            (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: myProfileData?.wooAlbum?.allImagesUrl())
        }
    
        //save questions
    if (myData.object(forKey: "userWooQuestionAnswerDto") != nil){
        let questionAnswerArray = myData.object(forKey: "userWooQuestionAnswerDto") as? NSArray
        var questionModelArray:[TargetQuestionModel] = []
        for questionDict in questionAnswerArray ?? NSArray(){
            let questionModel = TargetQuestionModel(data: questionDict as? NSDictionary ?? NSDictionary())
            questionModelArray.append(questionModel)
        }
        myProfileData?.myQuestionsArray = questionModelArray        
    }
    
        myProfileData?.wooId = UserDefaults.standard.object(forKey: "id") as? String
        
        let imageSize = (Utilities.sharedUtility() as! Utilities).getImageSize(forPoints: 85)
        let leftUserImageURL : String = "http://dd66jla1ca8rb.cloudfront.net/image-server/api/v1/image/crop/?width=\(imageSize)&height=\(imageSize)&url=\(DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl() ?? "")"
        if leftUserImageURL != "" {
            let profilePicurl = [URL(string: leftUserImageURL)!];
            SDWebImagePrefetcher.shared().prefetchURLs(profilePicurl)
        }
            
        if((myProfileData != nil) && (myProfileData?.firstName != nil)) {
            //Added below code to update user name in user default, as it will be used in chat push notification, if not updated it can show complete name of female user. There was a bug for same.
//            UserDefaults.standard.set(myProfileData?.firstName, forKey: "wooUserName")
            UserDefaults.standard.set(myProfileData?.myName(), forKey: "wooUserName")
            UserDefaults.standard.synchronize()
        }
        if self.collectionMode == CollectionMode.my_PROFILE {
            switchCollectionMode(.my_PROFILE)
        }
    }
    
   @objc func updateCardCollection(_ cardArray : NSArray) {
        discoverDataCount = 0
        SDImageCache.shared().clearMemory()
        for cardObject in cardArray {
            if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "PROFILE_CARD" {
                if let userInfoDto : NSDictionary = (cardObject as! NSDictionary)["discoverUserInfoDto"] as? NSDictionary {
                    
                    let profileCard = ProfileCardModel(userInfoDto: userInfoDto)
                    if (checkIfUserExist(profileCard.wooId!) == false) {
                        (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: profileCard.wooAlbum?.allImagesUrl())
                        discoverModelCollection.add(profileCard)
                        
                        discoverDataCount = discoverDataCount + 1
                    }   
                }
            }
            else if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "BRAND_CARD"{
                // Brand card handling
                if let cardInfoDto : [String : AnyObject] = (cardObject as! NSDictionary).object(forKey: "cardInfo") as? [String : AnyObject] {
                    let brandCard = BrandCardModel(cardInfoDto : cardInfoDto)
                    (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: brandCard.mediaUrls?.allImagesUrl())
                    discoverModelCollection.add(brandCard)
                    
                    discoverDataCount = discoverDataCount + 1
                    
                }
            }
            else if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "NEW_USER_NO_PIC"{
                // No user no pic handling
                if let cardInfoDto : [String : AnyObject] = (cardObject as! NSDictionary).object(forKey: "cardInfo") as? [String : AnyObject] {
                    let noUserNoPicCard = NewUserNoPicCardModel(cardInfoDto : cardInfoDto)
//                    for cardObject in self.discoverModelCollection {
//                        if cardObject is NewUserNoPicCardModel {
//                            self.discoverModelCollection.remove(cardObject)
//                        }
//                    }
//                    (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: noUserNoPicCard.mediaUrls?.allImagesUrl())

                    discoverModelCollection.add(noUserNoPicCard)
                    
                    discoverDataCount = discoverDataCount + 1
                }
            }
            else if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "SELECTION_CARD"{
                if let selectionCardDto : [String : AnyObject] = (cardObject as! NSDictionary).object(forKey: "selectionCardDto") as? NSDictionary as! [String : AnyObject]? {
                    let selectionCard = SelectionCardModel(cardInfoDto : selectionCardDto)
//                    for cardObject in self.discoverModelCollection {
//                        if cardObject is SelectionCardModel {
//                            self.discoverModelCollection.remove(cardObject)
//                        }
//                    }
                    (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: [selectionCard.imageUrl])
                    discoverModelCollection.add(selectionCard)
                    
                    discoverDataCount = discoverDataCount + 1
                    
                }
            }
            else if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "DISCOVER_EMPTY"{
                if let discoverEmptyInfoDto : [String : AnyObject] = (cardObject as! NSDictionary).object(forKey: "discoverEmpty") as? [String : AnyObject] {
                    _ = DiscoverEmptyManager.sharedInstance.addDiscoverEmptyModel(discoverEmptyInfoDto as NSDictionary)
                }
            }
            else if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "REVIEW_PHOTOS"{
                if let cardInfoDto : [String : AnyObject] = (cardObject as! NSDictionary).object(forKey: "cardInfo") as? [String : AnyObject] {
                    let reviewPhotoCard = ReviewPhotoCardModel(cardInfo: cardInfoDto)
                    (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: reviewPhotoCard.mediaUrls?.allImagesUrl())
                    
                    (Utilities.sharedUtility() as AnyObject).precacheImages(withData: reviewPhotoCard.mediaUrls?.allImagesUrl(), withCompletionHandler: { (imageDownloadCompleted) in
                        if imageDownloadCompleted{
                            for cardObject in self.discoverModelCollection {
                                if cardObject is ReviewPhotoCardModel {
                                    self.discoverModelCollection.remove(cardObject)
                                }
                            }
                            self.discoverModelCollection.add(reviewPhotoCard)
                            self.discoverDataCount = self.discoverDataCount + 1
                        }
                    })
                }
            }
        }
                
        //remove Notification Discover Empty card if notification is Allowed
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            removeDiscoverEmptyCardForType(DiscoverEmptySubCardType.DISCOVER_EMPTY_NOTIFICATION)
        }
        
        if collectionMode != .my_PROFILE {
            if discoverModelCollection.count == 0 {
                self.switchCollectionMode(.discover_EMPTY)
            }
            else{
                self.switchCollectionMode(.discover)
            }
        }
   }
    
    func updateSearchCardCollection(_ cardArray : NSArray) {
        
        searchProfileCount = 0
        SDImageCache.shared().clearMemory()

        for cardObject in cardArray {
            if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "PROFILE_CARD" {
                if let userInfoDto : NSDictionary = (cardObject as! NSDictionary)["discoverUserInfoDto"] as? NSDictionary {
                    
                    let profileCard = ProfileCardModel(userInfoDto: userInfoDto)
                    (Utilities.sharedUtility() as AnyObject).precacheDiscoverImages(withData: profileCard.wooAlbum?.allImagesUrl())
                    searchModelCollection.add(profileCard)
                    searchProfileCount = searchProfileCount + 1
                }
            }
            else if (cardObject as! NSDictionary).object(forKey: "cardType") as! String == "DISCOVER_EMPTY"{
                if let discoverEmptyInfoDto : [String : AnyObject] = (cardObject as! NSDictionary).object(forKey: "discoverEmpty") as? [String : AnyObject] {
                    DiscoverEmptyManager.sharedInstance.addDiscoverEmptyModel(discoverEmptyInfoDto as NSDictionary)
                }
            }
        }
        //Utilities().precacheDiscoverImages(withData: cardArray as! [Any])

    }
    
   @objc func switchCollectionMode(_ mode : CollectionMode) {
        collectionMode = mode
        cardCollection.get().removeAllObjects()
        
        switch collectionMode {
        case CollectionMode.discover:
            if discoverModelCollection.count > 0 {
                cardCollection.set(NSMutableArray(array: discoverModelCollection))
            }
            else{
                if DiscoverEmptyManager.sharedInstance.count()>0 {
                    self.switchCollectionMode(.discover_EMPTY)
                }
            }
        case CollectionMode.my_PROFILE:
            if myProfileData != nil && myProfileData?.firstName != nil && myProfileData?.firstName.count > 0{
                let profile = myProfileData!.copy()
                cardCollection.set(NSMutableArray(object: profile))
            }
        case CollectionMode.discover_EMPTY:
            self.discoverModelCollection.removeAllObjects()
            if DiscoverEmptyManager.sharedInstance.count() > 0 {
                cardCollection.set(NSMutableArray(object: DiscoverEmptyManager.sharedInstance.firstObject()!))
            }
        }
    }
    
    func updateDiscoverModelCollectionBasedOnReadStatus(){
        if discoverModelCollection.count > 0{
        for profileCard in discoverModelCollection {
            if profileCard is ProfileCardModel {
                if (profileCard as! ProfileCardModel).isProfileSeen == true {
                    discoverModelCollection.remove(profileCard)
                }
            }
            else if profileCard is BrandCardModel{
                if (profileCard as! BrandCardModel).isBrandCardSeen == true{
                    discoverModelCollection.remove(profileCard)
                }
            }
        }
        //discoverDataCount = discoverModelCollection.count
        if self.collectionMode == CollectionMode.discover {
            switchCollectionMode(CollectionMode.discover)
        }
        }
    }
    
    func updateSearchModelCollectionBasedOnReadStatus(){
        if searchModelCollection.count > 0{
        for profileCard in searchModelCollection {
            if profileCard is ProfileCardModel {
                if (profileCard as! ProfileCardModel).isProfileSeen == true {
                    searchModelCollection.remove(profileCard)
                }
            }
            else if profileCard is BrandCardModel{
                if (profileCard as! BrandCardModel).isBrandCardSeen == true{
                    searchModelCollection.remove(profileCard)
                }
            }
        }
        }
    }
    
    func objectAtIndex(_ index: Int) -> AnyObject? {
        if cardCollection.get().count > index {
            return cardCollection.get().object(at: index) as AnyObject?
        }
        return nil
    }
    
    func searchObjectAtIndex(_ index: Int) -> AnyObject? {
        if searchModelCollection.count > index {
            return searchModelCollection.object(at: index) as AnyObject?
        }
        return nil
    }
    
    func removeItemsFromTop(_ numberofItems : Int) {
        if numberofItems <= cardCollection.get().count {
            let range : NSRange = NSMakeRange(0, numberofItems)
            if discoverModelCollection.count > 0 {
                discoverModelCollection.removeObjects(in: range)
            }
            if self.collectionMode == .discover {
                if cardCollection.get().count>0 {
                    cardCollection.get().removeObjects(in: range)
                }
            }
        }
        else{
            if self.collectionMode == .my_PROFILE {
                let range : NSRange = NSMakeRange(0, numberofItems)
                if discoverModelCollection.count>0 {
                    discoverModelCollection.removeObjects(in: range)
                }
            }
        }
    }
    
    func removeSearchItemsFromTop(_ numberofItems : Int) {
        if numberofItems <= searchModelCollection.count {
            let range : NSRange = NSMakeRange(0, numberofItems)
            if searchModelCollection.count > 0 {
                searchModelCollection.removeObjects(in: range)
            }
        }
        
    }
    
    func removeProfileItemsFromTop(_ numberofItems : Int) {
        if numberofItems <= discoverModelCollection.count {
            let range : NSRange = NSMakeRange(0, numberofItems)
            if discoverModelCollection.count > 0 {
                discoverModelCollection.removeObjects(in: range)
            }
        }
    }
    
    func isPaginationAllowed() -> Bool {
        if paginationIndex.count > 0 && paginationToken.count > 0 {
            return true
        }
        else{
            return false
        }
    }
    
    @objc func removeUserFromCollection(_ wooId: String, reloadDiscover: Bool = true) {
        if discoverModelCollection.count <= 0 || cardCollection.get().count<=0 {
            return
        }
        for cardObject in cardCollection.get() {
            if cardObject is ProfileCardModel {
                if (cardObject as! ProfileCardModel).wooId == wooId {
                    discoverModelCollection.remove(cardObject)
                    self.switchCollectionMode(.discover)
                    collectionScilentlyReloded = reloadDiscover
                    return
                }
            }
        }
    }
    
    func checkIfUserExist(_ wooId: String) -> Bool {
        for cardObject in cardCollection.get() {
            if cardObject is ProfileCardModel {
                if (cardObject as! ProfileCardModel).wooId == wooId {
                    return true
                }
            }
        }
        return false
    }
    
    func removeNewUserNoPicCard() {
        if discoverModelCollection.count <= 0 || cardCollection.get().count<=0 {
            return
        }
        for cardObject in cardCollection.get() {
            if cardObject is NewUserNoPicCardModel {
                discoverModelCollection.remove(cardObject)
                self.switchCollectionMode(.discover)
                collectionScilentlyReloded = true
            }
        }
    }
    
    func removeReviewPhotoCard() {
        if discoverModelCollection.count <= 0 || cardCollection.get().count<=0 {
            return
        }
        for cardObject in discoverModelCollection {
            if cardObject is ReviewPhotoCardModel {
                discoverModelCollection.remove(cardObject)
                self.switchCollectionMode(.discover)
            }
        }
    }
    
    func removeSelectionCard(subType: SelectionSubCardType) {
        if discoverModelCollection.count <= 0 {
            return
        }
        for cardObject in discoverModelCollection {
            if cardObject is SelectionCardModel {
                if (cardObject as! SelectionCardModel).subCardType == subType {
                    discoverModelCollection.remove(cardObject)
                    self.switchCollectionMode(.discover)
                    collectionScilentlyReloded = true
                }
            }
        }
    }
    
    func removeFirstDiscoverEmptyCard(){
        if collectionMode == CollectionMode.discover_EMPTY {
            DiscoverEmptyManager.sharedInstance.removeFirstObject()
        }
    }
    
    func removeDiscoverEmptyCardForType(_ cardType: DiscoverEmptySubCardType){
        let status = DiscoverEmptyManager.sharedInstance.removeObjectsForType(cardType)
        if collectionMode == CollectionMode.discover_EMPTY && status {
            collectionScilentlyReloded = true
        }
    }
    
    func storeImagesToCroppedServer(imageString:String) -> String {
        
        let height = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int32(SCREEN_HEIGHT))
        let width = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int32(SCREEN_WIDTH))
        
        if imageString.hasPrefix(kImageCroppingServerURL) {
            return imageString
        }else{
            
            let aImageURL = "?url=" + imageString
            let aHeightOfURL = "&height=" + (NSString(format: "%d", height) as String)
            let aWidthOfURL = "&width=" + (NSString(format: "%d", width) as String)
            let cropperImageUrl = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
            return cropperImageUrl
        }
        
    }
    
    func getCroppedImageUrlForReviewPhoto(imageString:String) -> String {
        
        let height = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int32(SCREEN_HEIGHT/3))
        let width = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int32(SCREEN_WIDTH/3))
        
        if imageString.hasPrefix(kImageCroppingServerURL) {
            return imageString
        }else{
            
            let aImageURL = "?url=" + imageString
            let aHeightOfURL = "&height=" + (NSString(format: "%d", height) as String)
            let aWidthOfURL = "&width=" + (NSString(format: "%d", width) as String)
            let cropperImageUrl = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
            return cropperImageUrl
        }
        
    }

    @objc func clearAllData(){
        self.discoverModelCollection.removeAllObjects()
        cardCollection.get().removeAllObjects()
        self.searchModelCollection.removeAllObjects()
        UserDefaults.standard.synchronize()
        DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
        self.paginationToken = ""
        self.paginationIndex = ""
        self.intentModelObject?.modelHasBeenUpdatedByServer = false
    }
    
//    func storeImagesToCroppedServer(imageString:String) -> String {
//        
//        let height = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int(SCREEN_HEIGHT))
//        let width = (Utilities.sharedUtility() as AnyObject).getImageSize(forPoints:Int(SCREEN_WIDTH))
//
//                                    let aImageURL = "?url=" + imageString
//                                    let aHeightOfURL = "&height=" + (NSString(format: "%d", Int(height)) as String)
//                                    let aWidthOfURL = "&width=" + (NSString(format: "%d", Int(width)) as String)
//                                    let cropperImageUrl = kImageCroppingServerURL + aImageURL + aHeightOfURL + aWidthOfURL
//        return cropperImageUrl
//    }
    
    func reloadPendingImageList(){
        self.pendingPhotoList?.removeAll()
        if let photoArr = myProfileData?.wooAlbum?.photoArray {
            for item in photoArr {
                let localItem = item as! AlbumPhoto
                if localItem.status == kPhotoPending {
                    self.pendingPhotoList?.append(localItem);
                }
            }
        }
    }
    
    func pendingListContains(_ photo : AlbumPhoto) -> Bool{
        if let photoArr = pendingPhotoList {
            var counter = 0
            for item in photoArr {
                if item.objectId == photo.objectId {
                    break
                }
                counter += 1
            }
            
            if pendingPhotoList?.count != 0 && counter < (pendingPhotoList?.count)! - 1 {
                pendingPhotoList?.remove(at: counter)
                return true
            }
            else{
                return false
            }
        }
        return false
    }
    
  @objc  func addProfileCard(_ profileCard : ProfileCardModel) {
        
        profileCardCollection.add(profileCard)
    }
    
    @objc func getProfileCardForWooID(_ wooID : String) -> ProfileCardModel {
        
        for cardObject in profileCardCollection {
            if cardObject is ProfileCardModel {
                if (cardObject as! ProfileCardModel).wooId == wooID {
                    return cardObject as! ProfileCardModel
                }
            }
        }
        return ProfileCardModel()
    }
    
    @objc func appTerminationHandler(){
        if (intentModelObject != nil) {
            let intentEncodedObject = NSKeyedArchiver.archivedData(withRootObject: intentModelObject!)
            UserDefaults.standard.set(intentEncodedObject, forKey: kIntentModelKey)
        }
        if (pendingPhotoList != nil) {
            let pendingImageEncodedObject = NSKeyedArchiver.archivedData(withRootObject: pendingPhotoList!)
            UserDefaults.standard.set(pendingImageEncodedObject, forKey: kPendingPhotoList)
        }
        

        UserDefaults.standard.synchronize()
    }
    
    @objc fileprivate func internetConnectionStatusChanged(_ notif : Notification) {
        
        let notiValue: Int = (notif.object as! NSNumber).intValue
        if notiValue == AFNetworkReachabilityStatus.reachableViaWiFi.rawValue ||
            notiValue == AFNetworkReachabilityStatus.reachableViaWWAN.rawValue
        {
            if myProfileData?.firstName == nil || myProfileData?.firstName.count == 0 {
                if let  id = UserDefaults.standard.object(forKey: "id") {
                    let wooid:NSString = id as! NSString
                    
                    ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue), withCompletionBlock: nil)
                }
            }
        }
    }
}
