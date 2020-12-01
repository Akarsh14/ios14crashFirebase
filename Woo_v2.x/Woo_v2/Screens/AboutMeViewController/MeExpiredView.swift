//
//  MeExpiredView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 12/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MeExpiredView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var leftMargin: CGFloat = 20.0
    var spaceBetweenCells = 50.0
    var cellWidth: CGFloat = 100.0
    var cellHeight: CGFloat = 100.0

    @IBOutlet weak var expiryHeaderLabel: UILabel!
    @IBOutlet weak var expiredCollectionView: UICollectionView!
    var expiredDataArray = [AnyObject]()
    var shownExpiredDataArray = [AnyObject]()
    var dataType:MeDataType = MeDataType.Visitors
    var openProfileDetailHandler:((PerformAction, AnyObject, Bool, IndexPath)->Void)!
    var openExpiryVcHandler:((MeDataType) -> Void)!
    var removeViewHandler:(()->Void)!
    var purchaseHandler:(()->Void)!
    var currentAction:PerformAction = PerformAction.None
    var indexPathToDelete:IndexPath?
    var currentUserWooID = ""
    var viewedProfilesIdArray: [String] = []
    var paidUser = false
    var needToShowLock = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        return self
    }
    
    /**
     This function loads the nib
     */
    class func loadViewFromNib(frame:CGRect) -> MeExpiredView {
        let profileView: MeExpiredView =
            Bundle.main.loadNibNamed("MeExpiredView", owner: self, options: nil)!.first as! MeExpiredView
        profileView.frame = frame
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return profileView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return expiredDataArray.count>13 ? 7 : expiredDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (expiredDataArray.count>13 && indexPath.row == 6) ?cellWidth*1.3 : cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "MeCollectionViewCell"
        let cell: MeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MeCollectionViewCell) ?? MeCollectionViewCell()
        let expiredUserDetail = self.expiredDataArray[indexPath.item]
        cell.setUserDetail(userDetail: expiredUserDetail,isBundledProfile:(expiredDataArray.count>13 && indexPath.row == 6),  forType:dataType, isPaidUser: paidUser, showLock: needToShowLock, noOfTotalProfiles: 0, isExpired: true, profileIndex: indexPath.row, usedInExpiryProfiles: false)
        if((expiredDataArray.count>13 && indexPath.row == 6))
        {
            cell.bundledProfileDeckView?.extraNumberOfProfilesLabel.text = "+ \(expiredDataArray.count - 6) more"
        }
        if self.dataType == .LikedMe {
            self.currentUserWooID = (expiredUserDetail as! LikedByMe).userWooId ?? ""
            if paidUser
            {
                LikedMe.updateHasUserProfileVisited(byAppUser: true, forUserWooId: self.currentUserWooID, withCompletionHandler: { (success) in
                
                })
            }
        }
        else if self.dataType == .SkippedProfiles{
            self.currentUserWooID = (expiredUserDetail as! SkippedProfiles).userWooId ?? ""
        }
        else if self.dataType == .Visitors{
            if let userDetails = expiredUserDetail as? MeDashboard
            {
                if let visitorID = userDetails.visitorId{
                    self.currentUserWooID = visitorID
                    if paidUser{
                        MeDashboard.updateHasVisitorProfileVisited(byUser: true, forVisitorId: self.currentUserWooID, withCompletionHandler: { (success) in
                            
                        })
                    }
                }
            }
        }
        
        if self.viewedProfilesIdArray.contains(self.currentUserWooID) == false && paidUser{
            self.viewedProfilesIdArray.append(self.currentUserWooID)
        }
        
        cell.meProfileDeckView?.dismissHandler = { (needToTakeAction:PerformAction, userProfile:AnyObject) in
            
            let touchPoint = CGPoint(x: cell.center.x, y: cell.center.y)
            
            let tappedIndexPath = collectionView.indexPathForItem(at: touchPoint)
            self.indexPathToDelete = tappedIndexPath
            let expiredUser = self.expiredDataArray[(tappedIndexPath?.item)!]
            
            if needToTakeAction == PerformAction.Pass {
                self.openProfileDetailHandler(PerformAction.Pass,expiredUser as AnyObject, true, self.indexPathToDelete!)
                //self.reloadViewAfterRemovingData()
            }
            else if needToTakeAction == PerformAction.CrushSent{
                self.openProfileDetailHandler(PerformAction.CrushSent,expiredUser as AnyObject, true, self.indexPathToDelete!)
                //self.reloadViewAfterRemovingData()
            }
            else if needToTakeAction == PerformAction.Like{
               // self.reloadViewAfterRemovingData()
                self.openProfileDetailHandler(PerformAction.Like,expiredUser as AnyObject, true, self.indexPathToDelete!)
                //self.reloadViewAfterRemovingData()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: leftMargin);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let expiredUserDetail = self.expiredDataArray[((indexPath as NSIndexPath).row)]
        if paidUser{
            if(expiredDataArray.count>13 && indexPath.row == 6)
            {
                openExpiryVcHandler(dataType)
            }
           else
            {
                self.indexPathToDelete = indexPath
                openProfileDetailHandler(PerformAction.None,expiredUserDetail as AnyObject, true, self.indexPathToDelete!)
            }
        }
        else{
            if (LoginModel.sharedInstance()?.gender == "MALE" && expiredDataArray.count>13 && indexPath.row == 6)
            {
                openExpiryVcHandler(dataType)
            }
            else
            {
                var userTimeStamp = Date()
                if self.dataType == .LikedMe {
                    userTimeStamp = (expiredUserDetail as! LikedByMe).userExpiryTime  ?? Date()
                }
                else if self.dataType == .Visitors{
                    userTimeStamp = (expiredUserDetail as! MeDashboard).visitorExpiryTime  ?? Date()
                }
                else if self.dataType == .SkippedProfiles{
                    userTimeStamp = (expiredUserDetail as! SkippedProfiles).userExpiryTime  ?? Date()
                }
                if calculateDaysOfExpiry(userTimeStamp) == 0{
                    let alert: UIAlertController = UIAlertController(title: NSLocalizedString("", comment: ""),
                                                                     message: NSLocalizedString("This profile is no longer available.\nGet WooPlus to save other profiles from expiring.", comment:""),
                                                                     preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Expire Profiles", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
                    })
                    
                    let reportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Get WooPlus", comment:""), style: .default, handler: {(action: UIAlertAction) -> Void in
                        
                        self.purchaseHandler()
                        
                    })
                    
                    alert.addAction(cancelAction)
                    alert.addAction(reportAction)
                    
//                    window?.rootViewController?.present(alert, animated: true, completion: nil)
                    WooScreenManager.sharedInstance.oHomeViewController?.present(alert, animated: true, completion: nil)
                    
                }
                else{
                    purchaseHandler()
                }
            }
        }
    }
    
    func setMarginAccordingToData() -> Void {
            let widthForCell = SCREEN_WIDTH - 18
            cellWidth = widthForCell/2.3
            spaceBetweenCells = 20
            cellHeight = cellWidth * 1.7
            leftMargin = 6
        
        if dataType == .LikedMe {
            expiryHeaderLabel.text = "Liked Profiles expiring today"
        }
        else if dataType == .Visitors{
            expiryHeaderLabel.text = "Likes & Visits expiring today"
        }
    }
    
    func updateExpiredData(){
        if expiredDataArray.count > 0 {
            expiredDataArray.removeAll()
        }
        if dataType == .LikedMe {
            let array:[AnyObject] = LikedMe.getAllExpiringLikedMeProfiles() as [AnyObject]
            expiredDataArray = array
        }
        else if dataType == .SkippedProfiles{
            let array:[AnyObject] = SkippedProfiles.getAllExpiringSKippedProfiles() as [AnyObject]
            expiredDataArray = array
        }
        else if dataType == .Visitors{
            let array:[AnyObject] = MeDashboard.getAllExpiringVisitors() as [AnyObject]
            expiredDataArray = array
        }
        
    }
    
    func prepareExpiryData(){
        self.expiredCollectionView.register(UINib(nibName: "MeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MeCollectionViewCell")
        //updateExpiredData()
        setMarginAccordingToData()
       // self.expiredCollectionView.reloadData()
    }
    
    func reloadViewAfterRemovingData() {
        
        self.expiredDataArray.remove(at: (self.indexPathToDelete?.item)!)
        
//        if(self.expiredDataArray.count>13)
//        {
//            self.expiredCollectionView.reloadData()
//        }
//        else
//        {
//        }
        
        if (self.expiredDataArray.count >= 13){
            self.expiredCollectionView.reloadData()
        }
        else{
            self.expiredCollectionView.deleteItems(at: [self.indexPathToDelete!])
        }

        if self.expiredDataArray.count <= 0{
            self.removeViewHandler()
        }
    }
    
    @objc func showCrushOverlayAndUpdateView(){
        if (indexPathToDelete != nil) {
            let cell: MeCollectionViewCell? = expiredCollectionView.cellForItem(at: indexPathToDelete!) as? MeCollectionViewCell
            cell?.meProfileDeckView?.showOverlayForCrushSent()
        }
    }
}
