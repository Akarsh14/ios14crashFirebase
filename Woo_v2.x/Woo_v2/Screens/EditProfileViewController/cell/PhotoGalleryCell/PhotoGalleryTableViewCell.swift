  //
//  PhotoGalleryTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage
import PINRemoteImage

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


class PhotoGalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var photoTipsLabel: UILabel!
    @IBOutlet weak var mainLabelWidthConstrain: NSLayoutConstraint!
    
    var dataSource : WooAlbumModel?
    
    var imageEditHandler : ((Int,UIImage?,Bool) -> ())?
    
    var albumModifiedHandler : ((WooAlbumModel) -> ())?
    
    var showPhotoTipsHandler : (() -> ())?
    
    var needToShowInReviewAlert = false
    
    var photoArrayPhotosCounter = 0
    
    var multipleImagesFetchingFromCropPickerViewArray = [Data]()
    
    var lastItemforCropperPickerArray = false
    
    var photoCounter = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCellID")
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Photo tips", attributes: underlineAttribute)
        photoTipsLabel.attributedText = underlineAttributedString
        self.resetPhotoCounting()
//        multipleImagesFetchingFromCropPickerViewArray = UserDefaults.standard.object(forKey: "croppedImagesArrayForPhotoGalleryTableViewCell") as! [UIImage]
        
        
        print("reloading the cell")
        
        if let fetchingImages = UserDefaults.standard.object(forKey: "croppedImagesArrayForPhotoGalleryTableViewCell") as? [Data] {
            print("fetchingImages",fetchingImages)
            multipleImagesFetchingFromCropPickerViewArray = fetchingImages
        }
        
    }

    @IBAction func showPhotoTipsView(_ sender: Any) {
        showPhotoTipsHandler!()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resetPhotoCounting(){
        self.photoCounter = 1
    }
    func showInReviewAlert(){
        let inReviewAlert:UIAlertController = UIAlertController(title: "", message: "You can only set an approved photo as your main photo.", preferredStyle: .alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        inReviewAlert.addAction(okAction)
        WooScreenManager.sharedInstance.oHomeViewController?.present(inReviewAlert, animated: true, completion: nil)
    }
}

extension PhotoGalleryTableViewCell : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell : PhotoCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellID", for: indexPath)  as? PhotoCollectionViewCell
        
        if cell == nil {
            let array = Bundle.main.loadNibNamed("PhotoCollectionViewCell", owner: self, options: nil)
            cell = array?.first as? PhotoCollectionViewCell
        }
        
        cell?.lblTopNumber.text = nil
        if (indexPath as NSIndexPath).item < dataSource?.count() {
            let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)! as? AlbumPhoto
            if  album != nil{
                //cell?.deleteButton.isHidden = true
                cell?.isUserInteractionEnabled = false
//cell?.imageView.sd_setImage(with: URL(string: (album?.url)!), placeholderImage: UIImage(named: "ic_edit_profile_placeholder"), completed: { (image, error, cacheType, url) in
//    
//})
                if indexPath.item == 0{
                    cell?.deleteButton.setImage(UIImage(named: "ic_edit_main_photo_delete"), for: .normal)
                    cell?.deleteButtonWidthConstraint.constant = 48
                    cell?.deleteButtonHeightConstraint.constant = 48
                }
                else{
                    cell?.deleteButton.setImage(UIImage(named: "ic_edit_other_photo_delete"), for: .normal)
                    cell?.deleteButtonWidthConstraint.constant = 38
                    cell?.deleteButtonHeightConstraint.constant = 38
                }
                cell?.imageDeleteHandler = {() in
                    self.imageEditHandler!((indexPath as NSIndexPath).item, cell?.imageView.image, true)
                }
                cell!.imageView.isHidden = false
                
                PINRemoteImageManager.shared().setProgressiveRendersShouldBlur(true, completion: nil)
                cell?.imageView.pin_updateWithProgress = true
                cell?.imageView.pin_setPlaceholder(with: UIImage(named: "ic_edit_profile_placeholder"))
                
                cell?.imageView.pin_setImage(from: URL(string: (album?.url)!), completion: { (PINRemoteImageManagerResult) in
                    cell?.isUserInteractionEnabled = true
                    if (indexPath as NSIndexPath).item == 0 {
                        //cell?.deleteButton.isHidden = true
                    }
                    else{
                        cell!.deleteButton.isHidden = false
                    }
                })
//                cell?.imageView.sd_setImage(with: URL(string: (album?.url)!), placeholderImage: UIImage(named: "ic_edit_profile_placeholder"), options: SDWebImageOptions(), completed: { (image, error, cacheType, url) in
//                    cell?.isUserInteractionEnabled = true
//                    if (indexPath as NSIndexPath).item == 0 {
//                        //cell?.deleteButton.isHidden = true
//                    }
//                    else{
//                        cell!.deleteButton.isHidden = false
//                    }
//
//
//                    let imageData = cell?.imageView.image?.highestQualityJPEGNSData
//                    print(imageData?.count ?? "")
//                    print("actual size of image in KB: %f ", Double(imageData!.count) / 1000.0)
//
//                    cell?.imageView.image = UIImage(data: imageData! as Data)
////                     let inputImage = CIImage(image: cell!.imageView.image!)!
////                     let parameters = [
////                        "inputContrast": NSNumber(value: 1.3)
////                     ]
////                     let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)
////
////                     let context = CIContext(options: nil)
////                     let img = context.createCGImage(outputImage, from: outputImage.extent)!
////
////                    cell?.imageView.image = UIImage(cgImage: img)
//
//
//                })
                
                if album?.status == "PENDING" {
                    cell?.lblTopNumber.isHidden = true
                    cell?.statusView.isHidden = false
                    cell?.statusView.backgroundColor = UIColor.black
                    cell?.statusView.alpha = 0.93
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main - In Review"
                    }
                    else{
                        cell?.statusLabel.text = "In Review"
                    }
                    cell?.statusView.backgroundColor = utilities.getUIColorObject(fromHexString: "#DE8600", alpha: 1.0)
                }
                else if album?.status == "APPROVED" {
                    cell?.lblTopNumber.text = String(indexPath.row+1)
                   // photoCounter += 1
                    cell?.statusView.backgroundColor = UIColor.black
                    if DiscoverProfileCollection.sharedInstance.pendingListContains(album!) {
                        cell?.statusView.isHidden = true
                       cell?.leftlblNumberConstraint.constant  = 10
                        cell?.ToplblNumConstraint.constant = 10
                        cell?.statusView.isHidden = true
                    }
                    else{
                        if indexPath.item == 0 {
                           // cell?.statusLabel.text = "Main"
                            
                            cell?.statusView.isHidden = true
                        }
                        else{
                            cell?.statusView.isHidden = true
                        }
                    }
                }
                else if album?.status == "REJECTED" {
                    cell?.lblTopNumber.isHidden = true
                    cell?.statusView.isHidden = false
                    cell?.statusView.backgroundColor = UIColor(red: 250.0/255.0, green: 72.0/255.0, blue: 73.0/255.0, alpha: 1.0)
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main - Incompatible"
                    }
                    else{
                        cell?.statusLabel.text = "Incompatible"
                    }
                }
                else{
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main"
                        cell?.statusView.isHidden = true
                    }
                }
            }
    }
    else{
        
        print(photoArrayPhotosCounter)
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
            indicator.color = .orange
            indicator.center = CGPoint(x: 55, y: 60)
            cell?.addSubview(indicator)
        if multipleImagesFetchingFromCropPickerViewArray.count != 0 && lastItemforCropperPickerArray == false {
            
        if(multipleImagesFetchingFromCropPickerViewArray[photoArrayPhotosCounter] == multipleImagesFetchingFromCropPickerViewArray.last){
                lastItemforCropperPickerArray = true
            }else{
                lastItemforCropperPickerArray = false
            }
            cell?.deleteButton.isHidden = true
            cell!.imageView.isHidden = false
            cell?.statusView.isHidden = true
//           cell?.statusLabel.text = "In Review"
            cell?.imageView.image = UIImage(data: multipleImagesFetchingFromCropPickerViewArray[photoArrayPhotosCounter])
            
            cell?.imageView.image = UIImageEffects.imageByApplyingDarkEffect(to: cell?.imageView.image)
            photoArrayPhotosCounter += 1
            
            indicator.startAnimating()
        }else{
            
            cell?.lblTopNumber.isHidden = true
            cell!.imageView.isHidden = true
            cell!.deleteButton.isHidden = true
            cell?.statusView.isHidden = true
            
        }
        
    }
        return cell!
    }
}

extension PhotoGalleryTableViewCell : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if dataSource?.count() == 0 || (indexPath as NSIndexPath).item != 0 {
            if imageEditHandler != nil {
                
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                if (indexPath as NSIndexPath).item < dataSource?.count() {
                    let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)! as? AlbumPhoto
                    if album?.status == "REJECTED" {
                        imageEditHandler!((indexPath as NSIndexPath).row, cell.imageView.image, true)
                    }
                    else{
                        imageEditHandler!((indexPath as NSIndexPath).row, cell.imageView.image, false)
                    }
                }
                else{
                    if cell.imageView.image != nil{
                    imageEditHandler!((indexPath as NSIndexPath).row, cell.imageView.image, false)
                    }
                    else{
                        imageEditHandler!((indexPath as NSIndexPath).row, UIImage(), false)
                    }
                }
            }
        }
        else{
            if (indexPath as NSIndexPath).item == 0{
                let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)! as? AlbumPhoto
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                if album?.status == "REJECTED" {
                    if imageEditHandler != nil {
                    imageEditHandler!((indexPath as NSIndexPath).row, cell.imageView.image, true)
                    }
                }
                else{
                    imageEditHandler!((indexPath as NSIndexPath).row, cell.imageView.image, false)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemAtIndexPath
                        fromIndexPath: IndexPath, didMoveToIndexPath toIndexPath: IndexPath) {
        if (toIndexPath as NSIndexPath).item != (fromIndexPath as NSIndexPath).item {
            if (toIndexPath as NSIndexPath).item == 0 {
                dataSource?.objectAtIndex(0)?.isProfilePic = false
                dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.isProfilePic = true
            }
            else if (fromIndexPath as NSIndexPath).item == 0 {
                dataSource?.objectAtIndex(0)?.isProfilePic = true
                dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.isProfilePic = false
            }
            
            let fromItem = dataSource!.photoArray.object(at: (fromIndexPath as NSIndexPath).item)
            dataSource!.photoArray.removeObject(at: (fromIndexPath as NSIndexPath).item)
            if (toIndexPath as NSIndexPath).item > (fromIndexPath as NSIndexPath).item {
                dataSource!.photoArray.insert(fromItem, at: (toIndexPath as NSIndexPath).item)
            }
            else{
                dataSource!.photoArray.insert(fromItem, at: (toIndexPath as NSIndexPath).item)
            }
            
            albumModifiedHandler!(dataSource!)

//            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
//            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                collectionView.reloadData()
//            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemAtIndexPath fromIndexPath: IndexPath, canMoveToIndexPath toIndexPath: IndexPath) -> Bool {
        if (fromIndexPath as NSIndexPath).item < dataSource?.count() && (toIndexPath as NSIndexPath).item < dataSource?.count(){
            if (dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.status == "PENDING" ||
                dataSource?.objectAtIndex((fromIndexPath as NSIndexPath).item)?.status == "REJECTED") &&
                (toIndexPath as NSIndexPath).item == 0 {
                needToShowInReviewAlert = true
                return false
            }
            else if (fromIndexPath as NSIndexPath).item == 0{
                if (dataSource?.objectAtIndex((toIndexPath as NSIndexPath).item)?.status == "PENDING" ||
                    dataSource?.objectAtIndex((toIndexPath as NSIndexPath).item)?.status == "REJECTED"){
                    needToShowInReviewAlert = true
                    return false
                }
            }
            return true
        }
        return false
    }
    
    @objc(collectionView:canFocusItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).item < dataSource?.count() && (indexPath as NSIndexPath).item != 0  {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item){
            if album.status == "REJECTED"{
            if imageEditHandler != nil {
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                imageEditHandler!((indexPath as NSIndexPath).item, cell.imageView.image, true)
            }
            return false
        }
        return true
        }
        else{
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, movementEndedAtIndexPath indexPath: IndexPath){
        self.resetPhotoCounting()
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            collectionView.reloadItems(at: [IndexPath(row: 0, section:0),
                                                    IndexPath(row: 1, section:0)])
            if self.needToShowInReviewAlert{
                self.showInReviewAlert()
                self.needToShowInReviewAlert = false
            }
        })
        
    }
    
    func sectionSpacingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 5.0
    }
    
    func minimumInteritemSpacingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 5.0
    }
    
    func minimumLineSpacingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 5.0
    }
    
    func insetsForCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func autoScrollTrigerEdgeInsets(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50.0, left: 0, bottom: 50.0, right: 0)
    }
    
    func autoScrollTrigerPadding(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 64.0, left: 0, bottom: 0, right: 0)
    }
    
    func reorderingItemAlpha(_ collectionview: UICollectionView) -> CGFloat {
        return 0.3
    }
}
  
  
  extension UIImage {
      func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
          let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
          let format = imageRendererFormat
          format.opaque = isOpaque
          return UIGraphicsImageRenderer(size: canvas, format: format).image {
              _ in draw(in: CGRect(origin: .zero, size: canvas))
          }
      }
      func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
          let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
          let format = imageRendererFormat
          format.opaque = isOpaque
          return UIGraphicsImageRenderer(size: canvas, format: format).image {
              _ in draw(in: CGRect(origin: .zero, size: canvas))
          }
      }
  }
  
  
  extension UIImage
  {
    var highestQualityJPEGNSData: NSData { return self.jpegData(compressionQuality: 1.0)! as NSData }
    var highQualityJPEGNSData: NSData    { return self.jpegData(compressionQuality: 0.75)! as NSData}
    var mediumQualityJPEGNSData: NSData  { return self.jpegData(compressionQuality: 0.5)! as NSData }
    var lowQualityJPEGNSData: NSData     { return self.jpegData(compressionQuality: 0.25)! as NSData}
    var lowestQualityJPEGNSData: NSData  { return self.jpegData(compressionQuality: 0.0)! as NSData }
  }
