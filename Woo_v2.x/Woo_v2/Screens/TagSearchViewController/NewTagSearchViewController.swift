//
//  NewTagSearchViewController.swift
//  Woo_v2
//
//  Created by Ankit Batra on 04/06/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

typealias onClick = (_ onClicked:Bool)->Void

class NewTagSearchViewController: UIViewController {
    let KCategoryCellWidth = 150
    let KCategoryCellHeight = 55
    let KCategoryCollectionViewHeight = 60
    private var isSelectedLifeStyletag = false
    static let sharedInstance = NewTagSearchViewController()
    private var isRelationShipTagSelected = false
    private var arrRelationship = [[String:AnyObject]]()
    @IBOutlet weak var tblRelationshp: UITableView!
    @IBOutlet weak var editMyTagsButton: UIButton!
    @IBOutlet weak var collectionViewSeparator: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewRelationship: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchContainerViewHeightConstraint: NSLayoutConstraint!
    @objc var currentTagData:TagDataType = .RelationshipAndLifestyle
    @IBOutlet weak var searchTagTextField: UITextField!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var categoriesCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    @IBOutlet weak var noTagsLabel: UILabel!
    var categoriesArray = [[String:AnyObject]]()
    var selectedCategoryTagsArray = [AnyObject]()
    var selectedCategoryIndex = 1
    var isSearchMode = false
    var searchResultsArray = [[String:AnyObject]]()
    var allTagsArray =  [[String:AnyObject]]()//TagsModel.sharedInstance().allTags
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(AppLaunchModel.sharedInstance().showSearchViewInTagSearch == false)
        {
            searchContainerViewHeightConstraint.constant = 0
        }
        else
        {
            searchContainerViewHeightConstraint.constant = 50.0
        }
        searchContainerView.layer.cornerRadius = 5.0
        searchContainerView.layer.masksToBounds = true
        searchContainerView.layer.borderColor = UIColorHelper.color(fromRGB: "#D6D6D6", withAlpha: 1.0).cgColor
        searchContainerView.layer.borderWidth = 2.0
        colorTheStatusBar(withColor: UIColor .white)
        categoriesCollectionView.register(UINib(nibName: "TagSearchCategoriesCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TagSearchCategoriesCollectionViewCell")
        tagsCollectionView.register(UINib(nibName: "NewTagsCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: "NewTagsCollectionViewCell")
        tagsCollectionView.register(UINib(nibName: "TagsCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TagsCollectionHeaderView")
        tagsCollectionView.register(UINib(nibName: "TagsCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "TagsCollectionFooterView")
        
        //
        self.tblRelationshp.register(UINib(nibName: "TagScreenSectionHeader", bundle: nil), forCellReuseIdentifier: "tagScreenHeader")
        self.tblRelationshp.register(UINib.init(nibName: "RelationshipTableviewCell", bundle: nil), forCellReuseIdentifier: "RelationshipTableviewCell")
        self.tblRelationshp.register(UINib.init(nibName: "TagCollectionViewCell", bundle: nil), forCellReuseIdentifier: "TagCollectionViewCell")
        self.tblRelationshp.isHidden = false;
        //
        /*
         TagsModel.sharedInstance().getNewTagsIfAny { (newTagsArray) in
         if(newTagsArray != nil && newTagsArray?.count ?? 0 > 0)
         {
         var  tagsArrayTemp = newTagsArray!
         tagsArrayTemp = tagsArrayTemp.shuffled()
         let alreadyPresentTagsArray = NSMutableArray(array:self.allTagsArray as! [NSDictionary] , copyItems: true)
         let newAllTagsArray = NSMutableArray(array:tagsArrayTemp, copyItems: true)
         newAllTagsArray.removeObjects(in: alreadyPresentTagsArray as! [Any])
         self.allTagsArray?.addObjects(from:newAllTagsArray as! [Any])
         
         }
         else
         {
         self.allTagsArray = NSMutableArray(array: (TagsModel.sharedInstance().allTags as! [NSDictionary]), copyItems: true)
         }
         }
         */
        
        
        // Do any additional setup after loading the view.
        //Parse Categories Data
        self.getJson(forString: "EditedTags", allTagsParsing: true)
        
         self.getJson(forString: "RelationshipLifestyleZodiacTags", allTagsParsing: false)
        
        if(selectedCategoryIndex == 0)
        {
            editMyTagsButton.isHidden = false
        }
        else
        {
            editMyTagsButton.isHidden = true
        }
        
        if UserDefaults.standard.bool(forKey: "tagOverlayShown") == false{
            self.perform(#selector(showTagSearchOverlayView), with: nil, afterDelay: 0.5)
        }
    }
    
    private func getJson(forString: String, allTagsParsing:Bool){
        var jsonResult :[[String:AnyObject]]?
        jsonResult = jsonforPath(Path: forString)
        if (allTagsParsing) {
            categoriesArray = jsonResult!
            populateAllTagsArray()
            
        }else{
            arrRelationship = jsonResult!
            populateRelationShipArray()
        }
    }
    
    private func jsonforPath(Path: String)-> [[String:AnyObject]]{
        var jsonResult :[[String:AnyObject]]?
        if let tagsPath = Bundle.main.path(forResource: Path, ofType: "json")
        {
            do {
                let jsonData = try NSData(contentsOfFile: tagsPath, options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options:JSONSerialization.ReadingOptions.mutableContainers) as? [[String:AnyObject]]
                }
                catch {}
            }
            catch {}
        }
        return jsonResult!
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorTheStatusBar(withColor: UIColor .white)
        //SwipeBack
        
        if let nav = self.navigationController{
            nav.swipeBackEnabled = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func showTagSearchOverlayView(){
        
        if let relationshipTableViewCell = tblRelationshp.cellForRow(at: IndexPath(row: 0, section: 0)){
            let cell = relationshipTableViewCell as! RelationshipTableviewCell
            if let relationshipCollectionView = cell.collectionView{
                if let firstCell = relationshipCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)){
                    let attributes:UICollectionViewLayoutAttributes = relationshipCollectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))!
                    let cellRect = attributes.frame
                    var cellFrameInSuperview = relationshipCollectionView.convert(cellRect, to: relationshipCollectionView.superview)
                    cellFrameInSuperview.origin.y = cellFrameInSuperview.origin.y + tblRelationshp.frame.origin.y + viewRelationship.frame.origin.y
                    _ = TagSearchOverlayView.showView((firstCell as! NewTagsCollectionViewCell).tagLabel.text!, tagLabelCoordinates:cellFrameInSuperview)
                }
            }
        }
    }
    
    func populateAllTagsArray()
    {
        allTagsArray.removeAll()
        
        let arrCatogories = jsonforPath(Path: "EditedTags")
        for i in 0..<arrCatogories.count
        {
            let categoryDictionary = categoriesArray[i] as [String:AnyObject]
            let tagsArray = categoryDictionary["tags"] as! [[String:AnyObject]]
            allTagsArray.append(contentsOf: tagsArray)
        }
        
        let temparrRelationship = jsonforPath(Path: "RelationshipLifestyleZodiacTags")
        for items in temparrRelationship{
            let indTags = items["subType"] as! [[String:Any]]
            for items in indTags{
                let tagsArray = items["tags"] as! [[String:AnyObject]]
                allTagsArray.append(contentsOf: tagsArray)
            }
        }
        
        //        for i in 0..<categoriesArray.count
        //        {
        //            let categoryDictionary = categoriesArray[i] as [String:AnyObject]
        //            let tagsArray = categoryDictionary["tags"] as! [[String:AnyObject]]
        //            allTagsArray.append(contentsOf: tagsArray)
        //        }
    }
    
    private func populateRelationShipArray(){
        //User Selected "RelationShip Tag
        if ((selectedCategoryIndex) == 1){
            isRelationShipTagSelected = true
            arrRelationship.remove(at: (1))
        }
            //User Selected "LifeStyle Tag
        else{
            arrRelationship.remove(at: (0))
            isSelectedLifeStyletag = true
        }
        viewRelationship.isHidden = false
    }
    
    @IBAction func backButtonTapped(_ sender:UIButton)
    {
        if(isSearchMode)
        {
            noTagsLabel.isHidden = true
            isSearchMode = false
            categoriesCollectionViewHeightConstraint.constant = 60.0
            self.viewRelationship.isHidden = (isRelationShipTagSelected || isSelectedLifeStyletag) ? false : true;
            collectionViewSeparator.isHidden = false
            backButton.setImage(UIImage(named: "ic_arrow_back_black"), for: UIControl.State.normal)
            searchTagTextField.text = ""
            searchResultsArray.removeAll()
            searchTagTextField.resignFirstResponder()
            tagsCollectionView.reloadData()
        }
        else
        {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editMyTagsTapped(_ sender: UIButton)
    {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAP_EDIT_TAGS_MY_TAGS_TAG_SEARCH")
        
        /*
         let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
         let oTagScreenViewController =
         storyboard.instantiateViewController(withIdentifier: "TagScreenViewControllerID")
         as? TagScreenViewController
         oTagScreenViewController?.editProfileTagArray = DiscoverProfileCollection.sharedInstance.myProfileData?.tags.objcClone()
         oTagScreenViewController?.isPushedFromDiscover = true
         oTagScreenViewController?.removeBubbleViewsWhenViewDisappears = true
         oTagScreenViewController?.blockHandler = { (tagsArray) in
         
         DiscoverProfileCollection.sharedInstance.myProfileData?.updateTags(tagsArray!)
         
         self.tagsCollectionView.reloadData()
         }
         */
        
        let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
        wizardTagsVC.isUsedOutOfWizard = true
        wizardTagsVC.selectedTagsHandler = {(selectedTagsarray) in

           DiscoverProfileCollection.sharedInstance.myProfileData?.tags.removeAll()
            DiscoverProfileCollection.sharedInstance.myProfileData?.updateTags(selectedTagsarray)
            self.sendDataToServer(selectedTagsarray)
            
            self.tagsCollectionView.reloadData()
        }
        
        self.navigationController?.pushViewController(wizardTagsVC, animated: true)
    }
    
    
    func sendDataToServer(_ mainTagsArray:NSArray){
        
        if (mainTagsArray.count) > 0{
            let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
            
            myProfileDictionary["tagsDtos"] = mainTagsArray as! [Any]
            var _relationshipDtos : [NSMutableDictionary] = []
            for item in (DiscoverProfileCollection.sharedInstance.myProfileData?.relationshipLifestyleTags ?? [RelationshipLifestyleTagModel()]) {
                _relationshipDtos.append(item.dictionarifyForSendingToServer())
            }
            myProfileDictionary["relationShipAndLifeStyle"] = _relationshipDtos
            
            if let zodiacData = DiscoverProfileCollection.sharedInstance.myProfileData?.zodiac{
                myProfileDictionary["zodiac"] = zodiacData.dictionarifyForSendingToServer()
            }
            
            WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary) ?? ""))
            TagsModel.sharedInstance().updateSelectedTags(mainTagsArray as? NSMutableArray)
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "AnalyzeProfile_Tags_Tap")
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
        }
    }
}

extension NewTagSearchViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == categoriesCollectionView)
        {
            return categoriesArray.count + 1
        }
        else
        {
            if(!isSearchMode)
            {
                if(selectedCategoryIndex == 0)
                {
                    return DiscoverProfileCollection.sharedInstance.myProfileData?.tags.count ?? 0
                }
                else
                {
                    let categoryDictionary = categoriesArray[selectedCategoryIndex-1] as [String:AnyObject]
                    let tagsArray = categoryDictionary["tags"] as? [[String:AnyObject]]
                    return tagsArray?.count ?? 0
                }
            }
            else
            {
                return searchResultsArray.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == categoriesCollectionView)
        {
            var categoryType = ""
            if(indexPath.row == 0)
            {
                categoryType = "MY TAGS"
            }
            else
            {
                let categoryDictionary = categoriesArray[indexPath.row-1] as [String:AnyObject]
                categoryType = categoryDictionary["type"] as! String
            }
            let widthForCell = categoryType.width(withConstrainedHeight: CGFloat(KCategoryCellHeight), font: UIFont(name: "Lato-Bold", size: 14.0)!) + CGFloat(20.0)
            return CGSize(width: widthForCell , height: CGFloat(KCategoryCellHeight))
        }
        else
        {
            if(!isSearchMode)
            {
                if(selectedCategoryIndex != 0)
                {
                    let categoryDictionary = categoriesArray[selectedCategoryIndex-1] as [String:AnyObject]
                    let tagsArray = categoryDictionary["tags"] as? [[String:AnyObject]]
                    let tagDictionary = tagsArray?[indexPath.row]
                    return self.sizeForView(((tagDictionary?["name"] as? String) ?? ""), font: UIFont(name: "Lato-Medium", size: 14.0)!, height: 32.0)
                }
                else
                {
                    let tagsArray = DiscoverProfileCollection.sharedInstance.myProfileData?.tags
                    let tagModel = tagsArray?[indexPath.row]
                    return self.sizeForView((tagModel?.name ?? ""), font: UIFont(name: "Lato-Regular", size: 14.0)!, height: 32.0)
                    
                }
            }
            else
            {
                let tagDictionary = searchResultsArray[indexPath.row]
                return self.sizeForView(((tagDictionary["name"] as? String) ?? ""), font: UIFont(name: "Lato-Regular", size: 14.0)!, height: 32.0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == categoriesCollectionView)
        {
            let cell : TagSearchCategoriesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagSearchCategoriesCollectionViewCell", for: indexPath) as! TagSearchCategoriesCollectionViewCell
            if(indexPath.row == 0)
            {
                cell.categoryLabel.text = "MY TAGS"
            }
            else
            {
                let categoryDictionary = categoriesArray[indexPath.row-1] as [String:AnyObject]
                let categoryType = categoryDictionary["type"] as! String
                cell.categoryLabel.text = categoryType
            }
            if (selectedCategoryIndex == indexPath.row)
            {
                cell.changeToSelected(true)
            }
            else
            {
                cell.changeToSelected(false)
            }
            return cell
        }
        else
        {
            //Tags
            let cellIdentifier = "NewTagsCollectionViewCell"
            let cell : NewTagsCollectionViewCell? = tagsCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? NewTagsCollectionViewCell
            if(!isSearchMode)
            {
                if(selectedCategoryIndex != 0)
                {
                    cell?.isSelected(false)
                    let categoryDictionary = categoriesArray[selectedCategoryIndex-1] as [String:AnyObject]
                    let tagsArray = categoryDictionary["tags"] as? [[String:AnyObject]]
                    let tagDictionary = tagsArray?[indexPath.row]
                    cell?.tagLabel.text = ((tagDictionary?["name"] as? String) ?? "")
                }
                else
                {
                    cell?.isSelected(true)
                    let tagsArray = DiscoverProfileCollection.sharedInstance.myProfileData?.tags
                    let tagModel = tagsArray?[indexPath.row]
                    cell?.tagLabel.text =  (tagModel?.name ?? "")
                }
            }
            else
            {
                
                cell?.isSelected(false)
                let tagsArray = searchResultsArray
                let tagDictionary = tagsArray[indexPath.row]
                cell?.tagLabel.text =  ((tagDictionary["name"] as? String) ?? "")
                
            }
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if(collectionView != categoriesCollectionView)
        {
            if(kind == UICollectionView.elementKindSectionHeader)
            {
                let header = collectionView .dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TagsCollectionHeaderView", for: indexPath) as! TagsCollectionHeaderView
                header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
                return header
            }
            else //if (kind == UICollectionElementKindSectionFooter)
            {
                let footer = collectionView .dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "TagsCollectionFooterView", for: indexPath) as! TagsCollectionFooterView
                footer.editMyTagsButtonTappedHandler = {
                    
                    /*
                     let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
                     let oTagScreenViewController =
                     storyboard.instantiateViewController(withIdentifier: "TagScreenViewControllerID")
                     as? TagScreenViewController
                     oTagScreenViewController?.editProfileTagArray = DiscoverProfileCollection.sharedInstance.myProfileData?.tags.objcClone()
                     oTagScreenViewController?.isPushedFromDiscover = true
                     oTagScreenViewController?.removeBubbleViewsWhenViewDisappears = true
                     oTagScreenViewController?.blockHandler = { (tagsArray) in
                     
                     DiscoverProfileCollection.sharedInstance.myProfileData?.updateTags(tagsArray!)
                     
                     self.tagsCollectionView.reloadData()
                     }
                     */
                    
                    let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
                    wizardTagsVC.isUsedOutOfWizard = true
                    wizardTagsVC.selectedTagsHandler = {(selectedTagsarray) in
                       
                        DiscoverProfileCollection.sharedInstance.myProfileData?.tags.removeAll()
                        DiscoverProfileCollection.sharedInstance.myProfileData?.updateTags(selectedTagsarray)
                        self.sendDataToServer(selectedTagsarray)
                        
                        self.tagsCollectionView.reloadData()
                    }
                    self.navigationController?.pushViewController(wizardTagsVC, animated: true)
                }
                return footer
            }
        }
        else
        {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(collectionView == categoriesCollectionView)
        {
            return .zero
        }
        else
        {
            return CGSize(width: collectionView.bounds.size.width, height: 50.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func sizeForView(_ text:String, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 16 + 32 , height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //show selected
        if(collectionView == categoriesCollectionView)
        {
            isSelectedLifeStyletag = false
            isRelationShipTagSelected = false
            if(indexPath.row != selectedCategoryIndex)
            {
                //set selected Index
                selectedCategoryIndex = indexPath.row
                //
                if(indexPath.row == 0)
                {
                    
                    editMyTagsButton.isHidden = false
                    viewRelationship.isHidden = true
                    
                    //Relationship and Lifestyle
                }else if (indexPath.row == 1 || indexPath.row == 2){
                    self.getJson(forString: "RelationshipLifestyleZodiacTags", allTagsParsing: false)
                    viewRelationship.isHidden = false
                    tblRelationshp.reloadData()
                    tblRelationshp.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    //tblRelationshp.setContentOffset(.zero, animated: true)
                }
                else
                {
                    viewRelationship.isHidden = true
                    editMyTagsButton.isHidden = true
                }
                // let middleIndex = collectionView.indexPathsForVisibleItems.count/2
                if(indexPath.row < categoriesArray.count)
                {
                    categoriesCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                    
                    //                    if(indexPath.row >= collectionView.indexPathsForVisibleItems[middleIndex].row)
                    //                    {
                    //                        //scroll to next item
                    //                        categoriesCollectionView.scrollToItem(at: IndexPath(item: indexPath.row+1, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
                    //                    }
                    //                    else
                    //                    {
                    //
                    //                    }
                }
                //show UIChanges
                categoriesCollectionView.reloadData()
                //reload
                tagsCollectionView.reloadData()
                tagsCollectionView.contentOffset = .zero
                
            }
        }
        else
        {
            self.processTagClick(indexPath, tag: nil)
        }
    }
    
    func processTagClick(_ forIndex: IndexPath, tag:TagModel?){
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if tag != nil{
            DiscoverProfileCollection.sharedInstance.selectedTagData = tag
        }
        else{
            if(!isSearchMode)
            {
                if(selectedCategoryIndex != 0)
                {
                    (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAG_SEARCH_TAGS_TAP_TO_SEARCH")
                    let categoryDictionary = categoriesArray[selectedCategoryIndex-1] as [String:AnyObject]
                    let tagsArray = categoryDictionary["tags"] as? [[String:AnyObject]]
                    let tagDictionary = NSDictionary(dictionary: tagsArray![forIndex.row])
                    
                    DiscoverProfileCollection.sharedInstance.selectedTagData = TagModel(data: tagDictionary)
                }
                else
                {
                    (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAG_SEARCH_MY_TAGS_TAP_TO_SEARCH")
                    let tagsArray = DiscoverProfileCollection.sharedInstance.myProfileData?.tags
                    let tagModel = tagsArray?[forIndex.row]
                    DiscoverProfileCollection.sharedInstance.selectedTagData = tagModel!
                }
            }
            else
            {
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAP_SEARCH_RESULT_TAG")
                let tagsArray = searchResultsArray
                let tagDictionary = NSDictionary(dictionary:tagsArray[forIndex.row])
                DiscoverProfileCollection.sharedInstance.selectedTagData = TagModel(data: tagDictionary)
            }
        }
        
        
        
        if (DiscoverProfileCollection.sharedInstance.selectedTagData?.tagsDtoType?.count == 0 || DiscoverProfileCollection.sharedInstance.selectedTagData?.tagsDtoType == nil){
             DiscoverProfileCollection.sharedInstance.selectedTagData?.tagsDtoType = "TAG_SEARCH"
           
        }
        DiscoverProfileCollection.sharedInstance.searchModelCollection.removeAllObjects()
        //push to tag search
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tagSearchViewController =
            storyboard.instantiateViewController(withIdentifier: kTagsSearchViewController)
                as? TagSearchViewController
        tagSearchViewController?.tagSearchHasBeenPerformedFromDiscover = false
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        self.navigationController?.pushViewController(tagSearchViewController!, animated: true)
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if(collectionView == tagsCollectionView)
        {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        else
        {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == tagsCollectionView)
        {
            return 10
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == tagsCollectionView)
        {
            return 10
        }
        else
        {
            return 20
        }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
}

extension NewTagSearchViewController : UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isSearchMode = true
        self.viewRelationship.isHidden = true
        categoriesCollectionViewHeightConstraint.constant = 0.0
        collectionViewSeparator.isHidden = true
        backButton.setImage(UIImage(named: "ic_match_close_black.png"), for: UIControl.State.normal)
        tagsCollectionView.reloadData()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        tagsCollectionView.reloadData()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if let text = textField.text,
            let textRange = Range(range, in: text)
        {
            var searchText = text.replacingCharacters(in: textRange, with: string)
            searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            searchResultsArray.removeAll()
            if(searchText.count > 0)
            {
                //search tags searchText
                searchTags(forsearchText: searchText)
            }
            tagsCollectionView.reloadData()
            if(searchResultsArray.count == 0 && searchText.count > 0)
            {
                //No search results found
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "TAG_SEARCH_EMPTY_RESULT")
                noTagsLabel.isHidden = false
            }
            else
            {
                //
                noTagsLabel.isHidden = true
            }
            
        }
        return true
        
    }
    
    func searchTags(forsearchText tagname:String)
    {
        for tagsDictionary in self.allTagsArray
        {
            //            if let tagsDictionary = tagsInfo
            //            {
            let name = tagsDictionary["name"] as! String
            if name.lowercased().range(of: tagname.lowercased()) != nil
            {
                searchResultsArray.append(tagsDictionary)
            }
            //            }
            
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
}


extension NewTagSearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Tableview Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isRelationShipTagSelected || isSelectedLifeStyletag){
            return arrRelationship[section]["subType"]!.count
        }else{
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (isRelationShipTagSelected || isSelectedLifeStyletag) ? arrRelationship.count : 0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subType = arrRelationship[indexPath.section]["subType"]! as! [[String:Any]]
        let tagArray = (subType[indexPath.row]["tags"]! as! NSArray)
        return calculateTagCellHeight(tagArray, indexPath: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelationshipTableviewCell") as! RelationshipTableviewCell
        cell.isCameFromTagSearchScreen = true
        let subType = arrRelationship[indexPath.section]["subType"]! as! [[String:Any]]
        let subCategoryObject = subType[indexPath.row]
        let tagArray = (subCategoryObject["tags"]! as! NSArray)
        cell.subCategory = subCategoryObject["tagsSubCategoryId"] as? Int
        
        cell.populateTagsArrayAndReload(tagArray)
        cell.lblSecondaryHeading.text = (subType[indexPath.row]["subTypeName"]!
            as! String)
        cell.categoryImageView.image = UIImage(named: (subType[indexPath.row]["subTypeImage"]!
            as! String))
        
        if ((isRelationShipTagSelected) && (subType[indexPath.row]["subTypeName"]!
            as! String) == "What are you looking for on Woo"){
            cell.lblSecondaryHeading.text = " What are they looking for on woo"
        }
        
        
        cell.seperatorCell.backgroundColor = UIColor.clear
        
        cell.getTagHandler = {(selectedTag:TagModel) in
            self.processTagClick(indexPath, tag: selectedTag)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentTagData == .RelationshipAndLifestyle{
            return 35
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentTagData == .RelationshipAndLifestyle{
            let header = tableView.dequeueReusableCell(withIdentifier: "tagScreenHeader")! as! TagScreenSectionHeader
            
            if let headerText = arrRelationship[section]["tagsCategory"] as? String{
                header.lblHeaderTitle.text = headerText
                return header.contentView
            }else{
                return nil
            }
            
        }
        else{
            return nil
        }
    }
    
    func didSelectRow(clickedOn: onClick){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tagSearchViewController =
            storyboard.instantiateViewController(withIdentifier: kTagsSearchViewController)
                as? TagSearchViewController
        tagSearchViewController?.tagSearchHasBeenPerformedFromDiscover = false
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            
            self.navigationController?.pushViewController(tagSearchViewController!, animated: true)
        })
    }
    
    func moveTheController(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tagSearchViewController =
            storyboard.instantiateViewController(withIdentifier: kTagsSearchViewController)
                as? TagSearchViewController
        tagSearchViewController?.tagSearchHasBeenPerformedFromDiscover = false
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.navigationController?.pushViewController(tagSearchViewController!, animated: true)
        })
    }
    
    func calculateTagCellHeight(_ array:NSArray, indexPath:IndexPath) -> CGFloat {
        var height : CGFloat = 0.0
        let font = UIFont(name: "Lato-Regular", size: 14.0)!
        var rowWidth : CGFloat = 10.0
        var numberOfRows  : CGFloat = 1.0
        var extraHeight:CGFloat = (isSelectedLifeStyletag) ? 73 : 80
        let subType = arrRelationship[indexPath.section]["subType"]! as! [[String:Any]]
        if indexPath.row == subType.count - 1 && isSelectedLifeStyletag{
            extraHeight = 150.0
        }
        else if(SCREEN_HEIGHT > 735 && isSelectedLifeStyletag && (indexPath.row == 1)){
            extraHeight = 57
        }else if (SCREEN_HEIGHT > 735 && isSelectedLifeStyletag && (indexPath.row != subType.count - 1)){
            extraHeight = 20
        }
        for model in array {
            let modelDict = model as! NSDictionary
            let tagWidth = sizeForView(modelDict.object(forKey: kTagsNameKey) as! String, font: font, height: 32.0).width
            rowWidth = rowWidth + tagWidth + 10
            if rowWidth > (UIScreen.main.bounds.width - 48) {
                rowWidth = tagWidth + 10
                numberOfRows += 1
            }
        }
        
        height = numberOfRows * 38 + extraHeight + ((SCREEN_WIDTH == 320)
            ? 13 : 5)
        return height
    }
}
