//
//  RelationshipTableviewCell.swift
//  Woo_v2
//
//  Created by Kuramsetty Harish on 20/12/18.
//  Copyright © 2018 Woo. All rights reserved.
//


import UIKit

class RelationshipTableviewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var categoryImageView: UIImageView!
    var sizingCell : TagCollectionViewCell?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seperatorCell: UIView!
    var tagsArray:NSMutableArray = NSMutableArray()
    var tagDataType:TagDataType = .RelationshipAndLifestyle
    @IBOutlet weak var lblSecondaryHeading: UILabel!
    private var selectedTag:NSDictionary?
    var subCategory:Int?
    var relationshipViewControllerObject:RelationshipViewController?
    var categoriesArray = [[String:AnyObject]]()
    var isCameFromTagSearchScreen = false
    var getTagHandler:((TagModel)->Void)!
    
    @IBOutlet weak var lblSecondaryHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let cellnib = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        collectionView.register(cellnib, forCellWithReuseIdentifier: "TagCollectionViewCell")
        sizingCell = cellnib.instantiate(withOwner: nil, options: nil).first as? TagCollectionViewCell
        collectionView.register(UINib(nibName: "NewTagsCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: "NewTagsCollectionViewCell")
        /*
        tagJustifiedFlowLayout.horizontalJustification = .center
        tagJustifiedFlowLayout.notifyWhenTagWillGoBeyondViewHeight = false
        tagJustifiedFlowLayout.horizontalCellPadding = 5;
        tagJustifiedFlowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 20)
        */
    }
    
    private func getRelationshipLifestyleModelObjectBasedOnCategory(_ subCategoryId : Int) -> RelationshipLifestyleTagModel? {
        for dto in (relationshipViewControllerObject?.selectedRelationShipModelArray)! {
            let relationshipModel = dto as! RelationshipLifestyleTagModel
            var tagId = relationshipModel.tagsSubCategoryId
            if tagDataType == .Zodiac{
                tagId = relationshipModel.tagsCategoryId
            }
            if tagId == subCategoryId{
                return relationshipModel
            }
        }
        return nil
    }
    
    func populateTagsArrayAndReload(_ tagArray:NSArray)
    {
        
        tagsArray.removeAllObjects()
        for tag in tagArray{
            let tagModel = RelationshipLifestyleTagModel(data: tag as! NSDictionary)
            tagsArray.add(tagModel)
        }
        
        if relationshipViewControllerObject?.selectedRelationShipModelArray.count ?? 0 > 0{
            
            let selectedRelationshipModel = self.getRelationshipLifestyleModelObjectBasedOnCategory(subCategory!)
            selectedTag = selectedRelationshipModel?.dictionarify()
        }
        
        collectionView.reloadData()
    }
    
    func configureCell(_ cell:TagCollectionViewCell, forIndexPath indexpath:IndexPath)
    {
        let cellDetail = tagsArray.object(at: indexpath.row) as! RelationshipLifestyleTagModel
        let cellDetailDict = cellDetail.dictionarify()
        cell.itemData = cellDetailDict as? [AnyHashable : Any]
        cell.labelText = cellDetail.name
        cell.animateMyView { (completed) in
            NSLog("success")
        }
        cell.destroyCellOnSelection =  false
        
        cell.destroyMe { (success, destroyedObj) in
            if(success)
            {
                //called when the cell is tapped
                //Add to selectedTagsArray and remove from mainTagsArray
                
                if self.selectedTag != nil{
                    let tagId:Int = ((destroyedObj! as NSDictionary).object(forKey: kTagsIdKey) as! NSNumber).intValue
                    let selectedTagId = self.selectedTag?.object(forKey: kTagsIdKey) as? Int
                    if tagId == selectedTagId{
                        self.selectedTag = nil
                    }
                    else{
                        self.selectedTag = (destroyedObj! as NSDictionary)
                    }
                }
                else{
                    self.selectedTag = (destroyedObj! as NSDictionary)
                }
                
                let relationshipLifestyleModel = RelationshipLifestyleTagModel(data: destroyedObj! as NSDictionary)
                
                if let oldRelationshipLifestyleModel = self.getRelationshipLifestyleModelObjectBasedOnCategory(self.subCategory!){
                   
                    if (self.relationshipViewControllerObject?.selectedRelationShipModelArray.contains(oldRelationshipLifestyleModel))!{
                        self.relationshipViewControllerObject?.selectedRelationShipModelArray.remove(oldRelationshipLifestyleModel)
                    }
                }
                
               
                if self.selectedTag != nil{
                    self.relationshipViewControllerObject?.selectedRelationShipModelArray.add(relationshipLifestyleModel)
                }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        if selectedTag != nil{
            let tagId:Int = (cellDetailDict.object(forKey: kTagsIdKey) as! NSNumber).intValue
            let selectedTagId = selectedTag?.object(forKey: kTagsIdKey) as? Int
            if tagId == selectedTagId{
                cell.showAsSelected = true
            }
            else{
                cell.showAsSelected = false
            }
        }
        else{
            cell.showAsSelected = false
        }
        cell.needToBeUsedForRelationship = true
        cell.animateView = false
        cell.showBorder = true
        cell.showAddButton = true
        cell.changeViewBasedOnProperties()
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (isCameFromTagSearchScreen){
            let cellSearch : NewTagsCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "NewTagsCollectionViewCell", for: indexPath) as? NewTagsCollectionViewCell
            configureOnlyTagsCell(cellSearch!, forIndexPath: indexPath)
            return cellSearch!
        }else{
            let cell: TagCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell)!
            configureCell(cell, forIndexPath: indexPath)
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        configureCell(sizingCell!, forIndexPath: indexPath)
        let tagData = tagsArray.object(at: indexPath.row) as! RelationshipLifestyleTagModel
        return self.sizeForView(tagData, font: UIFont(name: "Lato-Medium", size: 14.0)!, height: 32.0)

        /*
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "12.0"){
            if let ns_str:NSString = sizingCell?.stringLabel.text as NSString? {
                
                let sizeOfString = ns_str.boundingRect(
                    with:CGSize(width: sizingCell?.stringLabel.frame.size.width ?? collectionView.frame.size.width/2, height: CGFloat.infinity),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: [NSAttributedStringKey.font: sizingCell?.stringLabel.font! ?? UIFont(name: "Lato-Regular", size: 14.0)!],
                    context: nil).size
                return CGSize(width: sizeOfString.width + 55, height: 32)
            }
        }
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    */
    
    }
    
    func sizeForView(_ tagData:RelationshipLifestyleTagModel, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = tagData.name
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 16 + 32 , height: height)
    }
    
    func configureOnlyTagsCell(_ cell:NewTagsCollectionViewCell, forIndexPath indexpath:IndexPath){
         cell.isSelected(false)
        let cellDetail = tagsArray.object(at: indexpath.row) as! RelationshipLifestyleTagModel
        cell.tagLabel.text = cellDetail.name
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.processTagClick(forIndex: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    func processTagClick(forIndex: IndexPath){
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
      
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAG_SEARCH_MY_TAGS_TAP_TO_SEARCH")
        
        let tempTag = tagsArray[forIndex.row] as! RelationshipLifestyleTagModel
        let selectedTag = tempTag.tagModel()
        if getTagHandler != nil{
            getTagHandler(selectedTag)
        }
    }
   
    
    func showSnackBar(_ text:String){
        let snackBarObj = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
   
}
