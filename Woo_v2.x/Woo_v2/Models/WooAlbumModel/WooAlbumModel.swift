//
//  WooAlbumModel.swift
//  Woo_v2
//
//  Created by Suparno Bose on 31/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AlbumPhoto: NSObject,NSCopying {
    var isProfilePic : Bool = false
    var url : String?
    @objc var status : String?
    var objectId : String?
    var imageOrder : Int32 = 0
    required override init() {
        super.init()
    }
    
    required init(_album : AlbumPhoto){
        super.init()
        self.isProfilePic = _album.isProfilePic
        self.url = _album.url
        self.status = _album.status
        self.objectId = _album.objectId
        self.imageOrder = _album.imageOrder
    }
    
    /*!
     * @discussion initialiser with decoder parameter
     * @param aDecoder decoder of the class
     */
    required internal init(coder aDecoder: NSCoder) {
        if (aDecoder.decodeObject(forKey: "isProfilePic") != nil) {
            self.isProfilePic         = (aDecoder.decodeObject(forKey: "isProfilePic") as? Bool)!
        }
        if (aDecoder.decodeObject(forKey: "url") != nil) {
        self.url                  = (aDecoder.decodeObject(forKey: "url") as? String)!
        }
        if (aDecoder.decodeObject(forKey: "status") != nil) {
        self.status               = (aDecoder.decodeObject(forKey: "status") as? String)!
        }
        if (aDecoder.decodeObject(forKey: "objectId") != nil) {
        self.objectId             = (aDecoder.decodeObject(forKey: "objectId") as? String)!
        }
        if (aDecoder.decodeObject(forKey: "imageOrder") != nil) {
        self.imageOrder           = aDecoder.decodeInt32(forKey: "imageOrder")
        }
    }
    
    /*!
     * @discussion This method is called when the class is archived
     * @param aCoder NScoder for the class
     */
    internal func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(isProfilePic, forKey: "isProfilePic")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(objectId, forKey: "objectId")
        aCoder.encodeCInt(imageOrder, forKey: "imageOrder")
    }
    
    init(isProfilePic:Bool?, url:String, pStaus:String?, objectId:String?, order:Int32?){
        super.init()
        self.isProfilePic = isProfilePic!
        self.url = url
        self.status = pStaus
        self.objectId = objectId
        self.imageOrder = order!
        
//        self.status = "PENDING"
    }
    
    init(url:String){
        super.init()
        self.url = url
    }
    
    func copy(with zone: NSZone?) -> Any{
        return AlbumPhoto(_album: self)
    }
    
    func dictionaryfy() -> NSMutableDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary["profilePic"] = NSNumber(value: isProfilePic as Bool)
        
        dictionary["srcBig"] = url
        
        dictionary["photoStatus"] = status
        
        dictionary["objectId"] = objectId
        
        dictionary["imageOrder"] = NSNumber(value: imageOrder as Int32)
        
        return dictionary
    }
}

class WooAlbumModel: NSObject,NSCopying {
    
    var isMyprofile:Bool = false
    
    var photoArray : NSMutableArray = NSMutableArray()
    
    override init() {
        super.init()
    }
    
    required init(_model : WooAlbumModel){
        super.init()
        self.photoArray = _model.photoArray.mutableCopy() as! NSMutableArray
    }
    
    func copy(with zone: NSZone?) -> Any{
        return WooAlbumModel(_model: self)
    }
    
    func addObjectsFromArray(_ otherArray: [AnyObject]) {
        for photo in otherArray as NSArray {
            if (photo as AnyObject).isKind(of: NSDictionary.classForCoder()) {
                var isProfilePic = false
                if let profilePic : Bool = (photo as! NSDictionary)["profilePic"] as? Bool{
                    isProfilePic = profilePic
                }
                let albumPhoto : AlbumPhoto?
                var croppedPhotoUrl:String = ""
                if isMyprofile == false {
                    
//                    let cachedURL = (photo as AnyObject).value(forKey: "cachedSrcBig") as! String
                    
                    if (photo as AnyObject).value(forKey: "cachedSrcBig") != nil {
                        let croppedPhoto = (photo as AnyObject).value(forKey: "cachedSrcBig")
                        print("croppedPhotoUrl cachedSrcBig %d",croppedPhoto!)
                        print("croppedPhotoUrl SrcBig %d",(photo as AnyObject).value(forKey: "srcBig")!)
                        croppedPhotoUrl = croppedPhoto as! String
                    }else{
                        let croppedPhoto = DiscoverProfileCollection.sharedInstance.storeImagesToCroppedServer(imageString: (photo as AnyObject).value(forKey: "srcBig") as! String)
                        
                        print("croppedPhotoUrl srcBig %d",croppedPhoto)
                        croppedPhotoUrl = croppedPhoto
                    }
                    
                }
                else{
                    
                    if (photo as AnyObject).value(forKey: "cachedSrcBig") != nil {
                        croppedPhotoUrl = (photo as AnyObject).value(forKey: "cachedSrcBig") as! String
                    }else{
                     croppedPhotoUrl = (photo as AnyObject).value(forKey: "srcBig") as! String
                    }
                }
                if (photo as AnyObject).value(forKey: "objectId") != nil {
                    albumPhoto = AlbumPhoto(isProfilePic:  isProfilePic,
                                                url: croppedPhotoUrl,
                                                pStaus: (photo as AnyObject).value(forKey: "photoStatus") as? String,
                                                objectId: "\((photo as AnyObject).value(forKey: "objectId") as! NSNumber)",
                                                order : ((photo as AnyObject).value(forKey: "imageOrder") as! NSNumber).int32Value)
                }
                else{
                    albumPhoto = AlbumPhoto(isProfilePic:  isProfilePic,
                                                url: croppedPhotoUrl,
                                                pStaus: (photo as AnyObject).value(forKey: "photoStatus") as? String,
                                                objectId: nil,
                                                order : ((photo as AnyObject).value(forKey: "imageOrder") as! NSNumber).int32Value)
                }
                
                self.addObject(albumPhoto!)
            }
            else{
                let albumPhoto = AlbumPhoto(url: photo as! String)
                self.addObject(albumPhoto)
            }
        }   
    }
    
    func addObjectsFromArrayForReviewPhoto(_ otherArray: [AnyObject]) {
        for photo in otherArray as NSArray {
            if (photo as AnyObject).isKind(of: NSDictionary.classForCoder()) {
                var isProfilePic = false
                if let profilePic : Bool = (photo as! NSDictionary)["profilePic"] as? Bool{
                    isProfilePic = profilePic
                }
                let albumPhoto : AlbumPhoto?
                var croppedPhotoUrl:String = ""
                if isMyprofile == false {
                    
                    if (!((photo as AnyObject).value(forKey: "cachedSrcBig") as! String).isEmpty) {
                        let croppedPhoto = (photo as AnyObject).value(forKey: "cachedSrcBig") as! String
                        croppedPhotoUrl = croppedPhoto
                    }
//                    else{
//                        let croppedPhoto = DiscoverProfileCollection.sharedInstance.getCroppedImageUrlForReviewPhoto(imageString: (photo as AnyObject).value(forKey: "srcBig") as! String)
//                        croppedPhotoUrl = croppedPhoto
//                    }
                    
                }
                else{
                    if (!((photo as AnyObject).value(forKey: "cachedSrcBig") as! String).isEmpty) {
                        croppedPhotoUrl = (photo as AnyObject).value(forKey: "cachedSrcBig") as! String
                    }
//                    else{
//                        croppedPhotoUrl = (photo as AnyObject).value(forKey: "srcBig") as! String
//                    }
                    
                }
                if (photo as AnyObject).value(forKey: "objectId") != nil {
                    albumPhoto = AlbumPhoto(isProfilePic:  isProfilePic,
                                            url: croppedPhotoUrl,
                                            pStaus: (photo as AnyObject).value(forKey: "photoStatus") as? String,
                                            objectId: "\((photo as AnyObject).value(forKey: "objectId") as! NSNumber)",
                        order : ((photo as AnyObject).value(forKey: "imageOrder") as! NSNumber).int32Value)
                }
                else{
                    albumPhoto = AlbumPhoto(isProfilePic:  isProfilePic,
                                            url: croppedPhotoUrl,
                                            pStaus: (photo as AnyObject).value(forKey: "photoStatus") as? String,
                                            objectId: nil,
                                            order : ((photo as AnyObject).value(forKey: "imageOrder") as! NSNumber).int32Value)
                }
                
                self.addObject(albumPhoto!)
            }
            else{
                let albumPhoto = AlbumPhoto(url: photo as! String)
                self.addObject(albumPhoto)
            }
        }
    }
    
    func addObject(_ anObject: AnyObject) {
        photoArray.add(anObject)
    }
    
    func replaceObject(_ anObject: AnyObject, position: Int) {
        if photoArray.count > position {
            photoArray.replaceObject(at: position, with: anObject)
        }
    }
    
    func removeObjectAt(_ position: Int) {
        if photoArray.count > position {
            photoArray.removeObject(at: position)
        }
    }
    
    @objc func profilePicUrl() -> String? {
        //New logic of approved photo only
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if (localItem.status == "APPROVED"){
                if localItem.isProfilePic {
                    return localItem.url
                }
            }
        }
        return ""
    }
    
    @objc func discoverProfilePicUrl() -> String? {
        for item in photoArray {
            let localItem = item as! AlbumPhoto
                if localItem.isProfilePic {
                    return localItem.url
                }
        }
        if photoArray.count > 0 {
            return (photoArray.firstObject as! AlbumPhoto).url
        }
        return ""
    }
    
    func approvedProfilePicUrl() -> String? {
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if !(localItem.status == "REJECTED"){
                if localItem.isProfilePic {
                    return localItem.url
                }
            }
        }
        return ""
    }

    
    func profilePicData() -> AlbumPhoto? {
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if localItem.isProfilePic {
                return localItem
            }
        }
        if photoArray.count > 0 {
            return (photoArray.firstObject as! AlbumPhoto)
        }
        return nil
    }
    
    func approvedProfilePicData() -> AlbumPhoto? {
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if !(localItem.status == "REJECTED"){
            if localItem.isProfilePic {
                return localItem
              }
            }
        }
        return nil
    }

    
    func allImagesUrl() -> [String] {
        var imageUrlArray:[String] = []
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            imageUrlArray.append(localItem.url!)
        }
        return imageUrlArray
    }
    
    func allImagesUrlWithOutPending() -> [String] {
        var imageUrlArray:[String] = []
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if !(localItem.status == "REJECTED"){
                imageUrlArray.append(localItem.url!)
            }
        }
        return imageUrlArray
    }
    
    func allApprovedImagesUrl() -> [String] {
        var imageUrlArray:[String] = []
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if (localItem.status == "APPROVED"){
                imageUrlArray.append(localItem.url!)
            }
        }
        return imageUrlArray
    }
    
    @objc func count() -> Int {
        return photoArray.count
    }
    
    @objc func countOfApprovedPhotos() -> Int {
        var imageUrlArray:[String] = []
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if (localItem.status == "APPROVED"){
                imageUrlArray.append(localItem.url!)
            }
        }
        return imageUrlArray.count
    }
    
    func countOfIncompatiblePhotos() -> Int {
        var imageUrlArray:[String] = []
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if (localItem.status == "REJECTED"){
                imageUrlArray.append(localItem.url!)
            }
        }
        return imageUrlArray.count
    }
    
    func checkIfAlbumHasAtleastOneInCompatiblePhoto() -> Bool {
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if (localItem.status == "REJECTED"){
                return true
            }
        }
        return false
    }
    
    
    func countWithOutPending() -> Int {
        var imageUrlArray:[String] = []
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if !(localItem.status == "REJECTED"){
                imageUrlArray.append(localItem.url!)
            }
        }
        return imageUrlArray.count
    }
    
    func objectAtIndex(_ index:Int) -> AlbumPhoto? {
        if index < self.count() {
            return photoArray.object(at: index) as? AlbumPhoto
        }
        return nil
    }
    
    func approvedObjectAtIndex(_ index:Int) -> AlbumPhoto? {
        let approvedPhotoArray:NSMutableArray = NSMutableArray()
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if (localItem.status == "APPROVED"){
                approvedPhotoArray.add(localItem)
            }
        }
        if index < self.countOfApprovedPhotos() {
            return approvedPhotoArray.object(at: index) as? AlbumPhoto
        }
        return nil
    }
    
    func objectAtIndexWithoutPending(_ index:Int) -> AlbumPhoto? {
        let approvedPhotoArray:NSMutableArray = NSMutableArray()
        
        for item in photoArray {
            let localItem = item as! AlbumPhoto
            if !(localItem.status == "REJECTED"){
                approvedPhotoArray.add(localItem)
            }
        }
        if index < self.countWithOutPending() {
            return approvedPhotoArray.object(at: index) as? AlbumPhoto
        }
        return nil
    }
    
    func moveItemToFront(_ index : Int) {
        if photoArray.count > 0 {
            var profilePicIndex = index
            if profilePicIndex >= photoArray.count {
                profilePicIndex = photoArray.count - 1
                
            }
            if photoArray.count > 1 {
                let tempObject: AnyObject = photoArray[0] as AnyObject
                photoArray[0] = photoArray[profilePicIndex]
                photoArray[profilePicIndex] = tempObject
            }
        }
    }
    
    func moveProfilePicToFront() {
        if photoArray.count > 0 {
            var profilePicIndex = 0
            for item in photoArray {
                let localItem = item as! AlbumPhoto
                if localItem.isProfilePic {
                    break
                }
                profilePicIndex += 1
            }
            if profilePicIndex >= photoArray.count {
                profilePicIndex = photoArray.count - 1
            }
            photoArray.exchangeObject(at: 0, withObjectAt: profilePicIndex)
        }
    }
    
    func dictionaryfy() -> NSMutableDictionary {
        
        let dictionary = NSMutableDictionary()
        
        let array : NSMutableArray = NSMutableArray()
        
        var counter : Int32 = 0
        for item in photoArray {
//            if (item as AnyObject).status != "REJECTED" {
                let temp = (item as! AlbumPhoto)
                temp.imageOrder = counter
                if counter == 0 {
                    temp.isProfilePic = true
                }
                else{
                    temp.isProfilePic = false
                }
                
                array.add(temp.dictionaryfy())
                counter += 1
//            }
        }
        
        dictionary["wooAlbum"] = array
        
        return dictionary
    }
    
    func dictionaryfyHavingRejected() -> NSMutableDictionary {
        
        let dictionary = NSMutableDictionary()
        
        let array : NSMutableArray = NSMutableArray()
        
        var counter : Int32 = 0
        for item in photoArray {
                let temp = (item as! AlbumPhoto)
                temp.imageOrder = counter
                if counter == 0 {
                    temp.isProfilePic = true
                }
                else{
                    temp.isProfilePic = false
                }
                
                array.add(temp.dictionaryfy())
                counter += 1
        }
        
        dictionary["wooAlbum"] = array
        
        return dictionary
    }
    
    func stringfy() -> NSString {

        let array : NSMutableArray = NSMutableArray()
        
        var counter : Int32 = 0
        for item in photoArray {
            let temp = (item as! AlbumPhoto)
            temp.imageOrder = counter
            
            array.add(temp .dictionaryfy())
            counter += 1
        }

        let nsJson = JSONStringify(value: array)
        
        print("\(nsJson)")
        
        return nsJson
    }
    
    func printModelUrls() {
        for item in photoArray {
            print("\((item as! AlbumPhoto).url!)")
        }
    }
}
