//
//  OptionSelectionViewController.swift
//  Woo_v2
//
//  Created by Deepak Gupta on 7/27/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

class OptionSelectionViewController: BaseClassViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewObj: UITableView!
    
    @IBOutlet weak var searchToTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    var dataSourceArr : [ProfessionModel] = []
    var navTitle : String = String()
    var filtered:[ProfessionModel] = []
    var isNamePassed = false
    
    var selectedName = ""
    var arrName : NSArray?
    
    var selectedIndex = -1
    var selectionHandler : ((String)->())?
    
    var searchActive = false
    var expectedKeyBoardHeight:CGFloat = 216

    var showSearchBar = false
    var kSearchBarConstantHeight : CGFloat = 44.0
    
    class func loadNib(_ title : String) -> OptionSelectionViewController {
        
        let controller: OptionSelectionViewController = OptionSelectionViewController(nibName: "OptionSelectionViewController", bundle: nil)
        controller.navTitle = title
        
        return controller
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navBar!.setStyle(NavBarStyle.selectionOption, animated: false)
        self.navBar!.snp.makeConstraints { (make) in
            make.top.equalTo(0)
        }
        self.navBar?.setTitleText(navTitle)
        self.navigationController?.isNavigationBarHidden = true;
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(OptionSelectionViewController.backButton))
        //
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
//        textFieldInsideSearchBar?.textColor = UIColor.white
        
        //searchBar.setImage(UIImage(named: "ic_onboarding_search.png"), for: UISearchBarIcon.search, state: .normal)
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textAlignment = .left
        textFieldInsideSearchBarLabel?.font = UIFont(name: "Lato-Regular", size: 15.0)
        textFieldInsideSearchBarLabel?.textColor = UIColor.lightGray
        
        
        
        searchBar.layer.borderColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor
        searchBar.layer.borderWidth = 1.0
        
        searchBar.layer.shadowColor = UIColor.lightGray.cgColor
        searchBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        searchBar.layer.shadowRadius = 5.0
        searchBar.layer.shadowOpacity = 1.0
        searchBar.layer.masksToBounds = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OptionSelectionViewController.keyboardDidShow(_:)),
                                               name:UIResponder.keyboardDidShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OptionSelectionViewController.keyboardDidHide(_:)),
                                               name:UIResponder.keyboardDidHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OptionSelectionViewController.keyboardDidShow(_:)),
                                               name:UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)

        self.navBar?.setTitleText(navTitle)
        
        if(navTitle != "Name"){
            self.navBar?.doneButton.isHidden = false
            self.navBar?.addDoneButtonTarget(self, action: #selector(OptionSelectionViewController.backButton))
        }
  }
    

    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                tableViewTopConstraint.constant = 64.0
            }
            else{
                tableViewTopConstraint.constant = 64.0
            }
        }
        else{
            tableViewTopConstraint.constant = 64.0
        }
        
        if(isNamePassed || showSearchBar == false)
        {
            searchBarHeightConstraint.constant = 0
            searchToTableViewTopConstraint.constant = 0
        }
        else
        {
            searchBarHeightConstraint.constant = kSearchBarConstantHeight
            searchToTableViewTopConstraint.constant = 10.0
            if #available(iOS 11.0, *) {
                if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                    tableViewTopConstraint.constant = 74.0
                    
                }
                else{
                    tableViewTopConstraint.constant = 74.0
                }
            }
            else
            {
                tableViewTopConstraint.constant = 74.0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navBar?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewObj.register(UINib(nibName: "OptionSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "OptionSelectionCell")

    }
    
    @objc fileprivate func keyboardDidShow(_ notificationObject:Notification){
      
        let keyboardSize:CGSize = ((notificationObject as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        let heightInInt:Int = Int(keyboardSize.height)
        let widthInInt:Int = Int(keyboardSize.width)
        let height:Int = min(heightInInt,widthInInt)
        expectedKeyBoardHeight = CGFloat(height)
        if expectedKeyBoardHeight > 216 {
            tableViewBottomConstraint.constant = expectedKeyBoardHeight - safeAreaBottom
        }
        else{
            tableViewBottomConstraint.constant = 216
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc fileprivate func keyboardDidHide(_ notificationObject:Notification)
    {
        tableViewBottomConstraint.constant = safeAreaBottom
        UIView.animate(withDuration: 0.25, animations: {
        self.view.layoutIfNeeded()
        })
    }
    
    @objc func backButton(){
        if self.navigationController != nil {
            if !isNamePassed {
                if selectionHandler != nil {
                    if selectedIndex != -1 {
                        if(searchActive && filtered.count > 0)
                        {
                            selectionHandler!(filtered[selectedIndex].tagId!)
                        }
                        else
                        {
                            selectionHandler!(dataSourceArr[selectedIndex].tagId!)
                        }
                    }
                }
                
            }else{
                if(selectionHandler != nil)
                {
                    selectionHandler!(selectedName)
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.dismiss(animated: true, completion: { 
                if !self.isNamePassed {
                    if self.selectionHandler != nil {
                        if self.selectedIndex != -1 {
                            if(self.searchActive && self.filtered.count > 0)
                            {
                                 self.selectionHandler!(self.filtered[self.selectedIndex].tagId!)
                            }
                            else
                            {
                                self.selectionHandler!(self.dataSourceArr[self.selectedIndex].tagId!)
                               
                            }
                        }
                    }
                    
                }else{
                    if(self.selectionHandler != nil)
                    {

                        self.selectionHandler!(self.selectedName)
                    }
                }
            })
        }
    }
    
    //MARK: UITableView Delegate
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isNamePassed {
            return (arrName?.count)!
        }
        else
        {
            if(searchActive)
            {
                return filtered.count
            }
            else
            {
                return dataSourceArr.count
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    internal func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: OptionSelectionTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: "OptionSelectionCell", for: indexPath) as? OptionSelectionTableViewCell)!
        
        cell!.layoutMargins = UIEdgeInsets.zero
        cell!.separatorInset = UIEdgeInsets.zero;

        
        if !isNamePassed {
           
            if(!searchActive)
            {
                cell?.setData(dataSourceArr[(indexPath as NSIndexPath).item], modelType: self.navTitle) //
                if dataSourceArr[(indexPath as NSIndexPath).item].isSelected {
                    selectedIndex = (indexPath as NSIndexPath).item
                    // cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
                    cell?.imgCheckMark.isHidden = false

                }
                else{
                    // cell!.accessoryType = UITableViewCellAccessoryType.none
                    
                    cell?.imgCheckMark.isHidden = true

                }
            }
            else
            {
                cell?.setData(filtered[(indexPath as NSIndexPath).item], modelType: self.navTitle)
                if filtered[(indexPath as NSIndexPath).item].isSelected {
                    selectedIndex = (indexPath as NSIndexPath).item
                    // cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                    cell?.imgCheckMark.isHidden = false
                    
                }
                else{
                    // cell!.accessoryType = UITableViewCellAccessoryType.none
                    
                    cell?.imgCheckMark.isHidden = true
                    
                }
            }
        }
        else{
            
            cell?.lblOption.text = arrName?.object(at: (indexPath as NSIndexPath).item) as? String
            
            let selected : String = (arrName?.object(at: (indexPath as NSIndexPath).item) as? String)!
            
            if selectedName == selected {
           //     cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                cell?.imgCheckMark.isHidden = false
            }
            else  {
              //  cell?.accessoryType = UITableViewCellAccessoryType.none
                cell?.imgCheckMark.isHidden = true
            }
            if indexPath.item == 0{
            if (arrName?.count)! > 1{
                let shortName = arrName?.firstObject as! String
                cell?.setRecommenedOptionForLabelText(shortName)
            }
            }
            
        }
        cell?.selectionStyle = .none
        cell?.separatorInset = UIEdgeInsets.zero
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsets.zero
        
//        cell!.selectionStyle = UITableViewCellSelectionStyle.None
//         tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
//        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if !isNamePassed {
            
            if(!searchActive)
            {
                if let tagId = dataSourceArr[(indexPath as NSIndexPath).item].tagId{
                    for item in dataSourceArr {
                        if item.tagId == tagId {
                            item.isSelected = true
                        }
                        else {
                            item.isSelected = false
                        }
                    }
                }
            }
            else
            {
                if let tagId = filtered[(indexPath as NSIndexPath).item].tagId{
                    for item in filtered {
                        if item.tagId == tagId {
                            item.isSelected = true
                        }
                        else {
                            item.isSelected = false
                        }
                    }
                }
            }
            
        }else{
            selectedName = (arrName?.object(at: (indexPath as NSIndexPath).item) as? String)!
        }
        
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension OptionSelectionViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       if(searchActive == false)
       {
            filtered = dataSourceArr
            if self.selectedIndex != -1 {

                let selectedModel = dataSourceArr[selectedIndex]
                setSelectedForFilteredDataSourceOnceSearchStartsWithSelectedTagId(selectedModel.tagId ?? "")
            }
            searchActive = true;
            tableViewObj.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
     //   searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         if self.selectedIndex != -1
         {
            let selectedModel = filtered[selectedIndex]
            setSelectedForMainDataSourceOnceSearchFinishesWithSelectedTagId(selectedModel.tagId ?? "")
        }
        searchActive = false;
        searchBar.resignFirstResponder()
        tableViewObj.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let selectedModel = filtered[selectedIndex]
//        setSelectedForMainDataSourceOnceSearchFinishesWithSelectedTagId(selectedModel.tagId ?? "")
//        searchActive = false;
        searchBar.resignFirstResponder()
        tableViewObj.reloadData()
    }
    
    
    func setSelectedForMainDataSourceOnceSearchFinishesWithSelectedTagId(_ tagId:String)
    {
        for item in dataSourceArr {
            if item.tagId == tagId {
                item.isSelected = true
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    func setSelectedForFilteredDataSourceOnceSearchStartsWithSelectedTagId(_ tagId:String)
    {
        for item in filtered {
            if item.tagId == tagId {
                item.isSelected = true
            }
            else {
                item.isSelected = false
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText == "")
        {
            if self.selectedIndex != -1 && filtered.count > 0
            {
                let selectedModel = filtered[selectedIndex]
                filtered = dataSourceArr
            setSelectedForFilteredDataSourceOnceSearchStartsWithSelectedTagId(selectedModel.tagId ?? "")
            }
            else
            {
                filtered = dataSourceArr
            }
            self.tableViewObj.reloadData()
        }
        else
        {
            DispatchQueue.main.async {
                self.filtered = self.dataSourceArr.filter({ (model) -> Bool in
                    let tmp: NSString = NSString(string: model.name ?? "")
                    let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return range.location != NSNotFound
                })
                self.tableViewObj.reloadData()
            }

        }
    }
}

