//
//  EthnicitySelectionViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 13/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import IQKeyboardManager
import GooglePlaces

class EthnicitySelectionViewController: BaseClassViewController {
    
    @IBOutlet weak var ethnicitySearchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var dropDownTable: UITableView!
    
    @IBOutlet weak var mainEthnicityTable: UITableView!
    
    @IBOutlet weak var dropDownView: UIView!
    
    @IBOutlet weak var dropDownHeightCOnstrain: NSLayoutConstraint!
    
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    @IBOutlet weak var topViewheightConstraint: NSLayoutConstraint!
    
    
    var isComingFromEditProfile = false
    
    var maxmimumSelection = -1
    
    var mainDataSource : NSArray = []
    
    var dropDownDataSourceForLocation : NSMutableArray = []
    var selectedLocation : NSDictionary?        // pre selected location value make sure it contains valye city and state.
    
    var dropDownDataSource : [String] = []
    
    let ethnicityDataSource : [String] = []
    
    var selectedEthnicity : [String] = []
    
    var selectionHandler : (([NSDictionary])->())?
    
    var viewControllerType: EthnicityClassType = EthnicityClassType.TYPE_NONE //EthnicityClassType.TYPE_ETHNICITY
    
    var placesClient : GMSPlacesClient = GMSPlacesClient()
    
    var showSwitchButton: Bool = false
    
    var doesnotMatterWasSelect: Bool = false
    
    class func loadNib() -> EthnicitySelectionViewController {
        
        let controller: EthnicitySelectionViewController = EthnicitySelectionViewController(nibName: "EthnicitySelectionViewController", bundle: nil)
        
        return controller
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if #available(iOS 11.0, *) {
            if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                ethnicitySearchViewTopConstraint.constant = 64.0
            }
        }
        else{
            ethnicitySearchViewTopConstraint.constant = 64.0
        }
        
        self.navBar!.setStyle(NavBarStyle.selectionOption, animated: false)
        self.navBar?.setTitleText(NSLocalizedString("ethnicity_header", comment: ""))
        self.navBar!.snp.makeConstraints { (make) in
            make.top.equalTo(0)
        }
        self.navigationController?.isNavigationBarHidden = true;
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(OptionSelectionViewController.backButton))
        self.navBar?.customSwitch?.isHidden = !showSwitchButton
        ///
        
        self.navBar?.doneButton.isHidden = false
        self.navBar?.addDoneButtonTarget(self, action: #selector(OptionSelectionViewController.backButton))
        dropDownView.layer.borderColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor

        dropDownView.layer.borderWidth = 1.0
        
        dropDownView.layer.shadowColor = UIColor.lightGray.cgColor
        dropDownView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        dropDownView.layer.shadowRadius = 5.0
        dropDownView.layer.shadowOpacity = 1.0
        dropDownView.layer.masksToBounds = false
        
        searchView.layer.borderColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor
        searchView.layer.borderWidth = 1.0
        
        searchView.layer.shadowColor = UIColor.lightGray.cgColor
        searchView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        searchView.layer.shadowRadius = 5.0
        searchView.layer.shadowOpacity = 1.0
        searchView.layer.masksToBounds = false

        textField.keyboardType = .asciiCapable
        if viewControllerType == EthnicityClassType.TYPE_LOCATION {
            self.navBar?.setTitleText(NSLocalizedString("Swiping_Location_Header", comment: ""))
            self.textField.placeholder = NSLocalizedString("Search City", comment: "")
            self.navBar?.switchValueChanged = {(switchOn: Bool) in 
                // here we have to add code when I change the value of switch
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)

        self.navBar?.setTitleText(NSLocalizedString("ethnicity_header", comment: ""))
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        if selectedEthnicity.count > 0 {
            var counter = 0
            for item in mainDataSource {
                let ethnicityName = (item as! NSDictionary)["name"] as! String
                if selectedEthnicity.last == ethnicityName {
                    break;
                }
                counter += 1
            }
            if counter >=  mainDataSource.count{
                counter = (mainDataSource.count - 1)
            }
            mainEthnicityTable.reloadData()
            
            mainEthnicityTable.scrollToRow(at: NSIndexPath.init(row: counter, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: false)
        }
        
        topViewheightConstraint.constant = 75
        self.sectionHeaderLabel.text = NSLocalizedString("", comment: "")
        
        if viewControllerType == EthnicityClassType.TYPE_LOCATION {
            //change the default value
            mainDataSource = (UserDefaults.standard.object(forKey: "locationOptions") as! NSArray?)!
            mainEthnicityTable.reloadData()
            self.navBar?.setTitleText(NSLocalizedString("Swiping_Location_Header", comment: ""))
            self.textField.placeholder = NSLocalizedString("Search City", comment: "")
            self.sectionHeaderLabel.text = NSLocalizedString("Top Cities", comment: "")
            if selectedLocation != nil {
                
                if (selectedLocation?["selectedLocationDetail"] != nil){
                    let wooLocationDict = selectedLocation?["selectedLocationDetail"] as! NSDictionary
                    let allKeysArray: NSArray = wooLocationDict.allKeys as NSArray
                    
                    if allKeysArray.count > 0 {
                        let aTempDict = [
                            "city" : selectedLocation?["city"] as! String,
                            "state" : selectedLocation?["state"] as! String,
                            "selectedLocationDetail" : selectedLocation?["selectedLocationDetail"] as! NSDictionary,
                            "isSelected" : "true"
                            ] as [String : Any]
                        mainDataSource = [aTempDict]
                    }
                    else{
                        let aTempDict = [
                            "city" : selectedLocation?["city"],
                            "state" : selectedLocation?["city"],
                            "isSelected" : "true"
                        ]
                        mainDataSource = [aTempDict]
                    }
                }
                else{
                    let aTempDict = [
                        "city" : selectedLocation?["city"],
                        "state" : selectedLocation?["city"],
                        "isSelected" : "true"
                    ]
                    mainDataSource = [aTempDict]
                }
                
                
                
//                let aTempDict = [
//                    "city" : selectedLocation?["city"],
//                    "state" : selectedLocation?["state"],
//                    "isSelected" : "true"
//                ]
                
                self.sectionHeaderLabel.text = NSLocalizedString("Your_Selection", comment: "")
            }
            topViewheightConstraint.constant = 110
        }
        else if viewControllerType == EthnicityClassType.TYPE_RELIGION {
            print("religion \(mainDataSource)")
//            mainDataSource = UserDefaults.standard.object(forKey: "locationOptions") as! NSArray!
            mainEthnicityTable.reloadData()
            self.navBar?.setTitleText(NSLocalizedString("label_religion", comment: ""))
            self.textField.placeholder = NSLocalizedString("Search Religion", comment: "")
//            self.sectionHeaderLabel.text = NSLocalizedString("", comment: "")
            topViewheightConstraint.constant = 75
        }
        else if viewControllerType == EthnicityClassType.TYPE_NONE {
            topViewheightConstraint.constant = 110
            self.sectionHeaderLabel.text = NSLocalizedString("Select upto two communities", comment: "")
        }
        self.view.layoutIfNeeded()
        self.navBar?.customSwitch?.isHidden = !showSwitchButton
        
        if self.viewControllerType == EthnicityClassType.TYPE_LOCATION {
            self.navBar?.customSwitch?.isOn = WooGlobeModel.sharedInstance().locationOption
        }
        else if self.viewControllerType == EthnicityClassType.TYPE_ETHNICITY{
            self.navBar?.customSwitch?.isOn = WooGlobeModel.sharedInstance().ethnicityOption
        }
        else if self.viewControllerType == EthnicityClassType.TYPE_RELIGION{
            self.navBar?.customSwitch?.isOn = WooGlobeModel.sharedInstance().religionOption
        }
        
        self.navBar?.switchValueChanged = {(switchOn:Bool) in
            
            if self.viewControllerType == EthnicityClassType.TYPE_LOCATION {
                WooGlobeModel.sharedInstance().locationOption = switchOn
            }
            else if self.viewControllerType == EthnicityClassType.TYPE_ETHNICITY{
                WooGlobeModel.sharedInstance().ethnicityOption = switchOn
            }
            else if self.viewControllerType == EthnicityClassType.TYPE_RELIGION{
                WooGlobeModel.sharedInstance().religionOption = switchOn
            }
            

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
        
    }
    
    @objc func dimissTheScreen()
    {
        self.dismiss(animated: false, completion: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainEthnicityTable.register(UINib(nibName: "EthnicityTableViewCell", bundle: nil), forCellReuseIdentifier: "EthnicitySelectionCell")
        
        textField.delegate = self
        
        //This is test code. Remove this code before giving it for testing. 
//        if viewControllerType == EthnicityClassType.TYPE_LOCATION {
//            selectedLocation = [
//                "city" : "New Delhi",
//                "state" : "Delhi",
//            ]
//        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textFieldValueChanged(_ sender: AnyObject) {
        
        let textFieldText =  ((sender as! UITextField) as UITextField).text!
        
        if textFieldText.count > 0 {
            clearButton.isHidden = false
        }
        else{
            clearButton.isHidden = true
            dropDownView.isHidden = true
            return
        }
        
        if viewControllerType == EthnicityClassType.TYPE_LOCATION{
            dropDownDataSourceForLocation.removeAllObjects()
            if textFieldText.count > 2 {
                getPlacesAutoSuggetionFromGoogle(forText: textFieldText)
            }
            
        }
        else{
            
            
            dropDownDataSource.removeAll()
            for item in mainDataSource {
                let ethnicityName = (item as! NSDictionary)["name"] as! String
                if textFieldText.count <= ethnicityName.count{
                    if (ethnicityName.substring(to: textFieldText.endIndex).lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == textFieldText.lowercased()){
                        dropDownDataSource.append(ethnicityName)
                    }
                }
            }
            
            if dropDownDataSource.count > 0 {
                dropDownView.isHidden = false
                if dropDownDataSource.count > 3 {
                    dropDownHeightCOnstrain.constant = 48 * 4
                }
                else{
                    let count : CGFloat = CGFloat(dropDownDataSource.count)
                    let cellHeight : CGFloat = 48.0
                    dropDownHeightCOnstrain.constant = cellHeight * count
                }
            }
            else{
                dropDownView.isHidden = true
            }
            dropDownTable.reloadData()
        }
        
        
        
    }
    
    @IBAction func clearText(_ sender: AnyObject) {
        textField.text = ""
        clearButton.isHidden = true
        dropDownView.isHidden = true
    }
    
    @objc func backButton(){
        if self.isComingFromEditProfile {
            if selectionHandler != nil {
                if selectedEthnicity.count == 0 {
                    selectionHandler!([])
                }
                else{
                    var slectedDisctionaryArray : [NSDictionary] = []
                    for item in mainDataSource {
                        let ethnicityName = (item as! NSDictionary)["name"] as! String
                        if (selectedEthnicity.contains(ethnicityName)){
                            slectedDisctionaryArray.append(item as! NSDictionary)
                        }
                    }
                    selectionHandler!(slectedDisctionaryArray)
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        else{
            
            if viewControllerType == EthnicityClassType.TYPE_LOCATION {
                if self.mainDataSource.count != 1 {
                    WooGlobeModel.sharedInstance().locationOption = false
                }
            }
            if viewControllerType == EthnicityClassType.TYPE_RELIGION {
                if selectedEthnicity.count < 1 {
                    WooGlobeModel.sharedInstance().religionOption = false
                }
            }
            if viewControllerType == EthnicityClassType.TYPE_ETHNICITY {
                if selectedEthnicity.count < 1 {
                    WooGlobeModel.sharedInstance().ethnicityOption = false
                }
            }
            
            
            if ((WooGlobeModel.sharedInstance().locationOption == false) && (WooGlobeModel.sharedInstance().ethnicityOption == false) && (WooGlobeModel.sharedInstance().religionOption == false)){
                WooGlobeModel.sharedInstance().wooGlobleOption = false
            }
            else{
                WooGlobeModel.sharedInstance().wooGlobleOption = true
            }
//            self.dismiss(animated: true, completion: {
                if self.selectionHandler != nil {
                    
                    
                    
                    if self.viewControllerType == EthnicityClassType.TYPE_LOCATION{
                        
                        if self.mainDataSource.count == 1 {
                            self.selectionHandler!(self.mainDataSource as! [NSDictionary])
                        }
                        else{
                            self.selectionHandler!([])
                        }
                    }
                    else{
                        if self.selectedEthnicity.count == 0 {
                            self.selectionHandler!([])
                        }
                        else{
                            var slectedDisctionaryArray : [NSDictionary] = []
                            for item in self.mainDataSource {
                                let ethnicityName = (item as! NSDictionary)["name"] as! String
                                if (self.selectedEthnicity.contains(ethnicityName)){
                                    slectedDisctionaryArray.append(item as! NSDictionary)
                                }
                            }
                            self.selectionHandler!(slectedDisctionaryArray)
                        }
                        
                    }
                    
                    self.navigationController?.popViewController(animated: true)

                    
//                    if self.selectedEthnicity.count == 0 {
//                        self.selectionHandler!([])
//                    }
//                    else{
//                        if self.viewControllerType == EthnicityClassType.TYPE_LOCATION {
//                            self.selectionHandler!(self.mainDataSource as! [NSDictionary])
//                            
//                        }
//                        else{
//                            var slectedDisctionaryArray : [NSDictionary] = []
//                            for item in self.mainDataSource! {
//                                let ethnicityName = (item as! NSDictionary)["name"] as! String
//                                if (self.selectedEthnicity.contains(ethnicityName)){
//                                    slectedDisctionaryArray.append(item as! NSDictionary)
//                                }
//                            }
//                            self.selectionHandler!(slectedDisctionaryArray)
//                        }
//                        
//                    }
                }
//            })
        }
    }

    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    //MARK: UITableView Delegate
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewControllerType == EthnicityClassType.TYPE_LOCATION {
            if tableView == dropDownTable {
                return dropDownDataSourceForLocation.count
            }
            else{
                return mainDataSource.count
            }
        }
        
        
        if tableView == dropDownTable {
            return dropDownDataSource.count
        }
        else{
            return mainDataSource.count
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if tableView == dropDownTable {
            return 48.0
        }
        else{
            return 50.0
        }
        
    }

    internal func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        if viewControllerType == EthnicityClassType.TYPE_LOCATION {
            //location flow
            
            if tableView == dropDownTable {
                var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "dropDownTableCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "dropDownTableCell")
                }
                let locationSearchOption = dropDownDataSourceForLocation[indexPath.row] as! NSDictionary
                cell?.textLabel?.attributedText = gettingAttributedString(from: locationSearchOption.object(forKey: "description") as! String)
                return cell!
            }
            else{
                let cell : EthnicityTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "EthnicitySelectionCell")  as? EthnicityTableViewCell
                
                if mainDataSource.count > 0{
                let locationOption = (mainDataSource.object(at: indexPath.row) as! NSDictionary)
                
                cell?.titleLabel?.text = "\(locationOption["city"] as! String), \(locationOption["state"] as! String)"
                
                let allKeysArray : NSArray = locationOption.allKeys as NSArray
                
                cell?.checkBox.isHidden = true
                
                if allKeysArray.contains("isSelected") {
                    cell?.checkBox.isHidden = false
                    cell?.checkBox.image = UIImage(named: "ic_my_preference_close_blue")
                }
                }
                return cell!
            }
        }
        
        if tableView == dropDownTable {
            var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "dropDownTableCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "dropDownTableCell")
            }
            cell?.textLabel?.text = dropDownDataSource[indexPath.row]
            return cell!
        }
        else{
            let cell : EthnicityTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "EthnicitySelectionCell")  as? EthnicityTableViewCell
            
            let name = (mainDataSource.object(at: indexPath.row) as! NSDictionary).object(forKey: "name") as! String?
            
            cell?.titleLabel?.text = name
            
            if selectedEthnicity.contains(name!) {
                cell?.checkBox.isHighlighted = true
            }
            else  {
                cell?.checkBox.isHighlighted = false
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        dropDownView.isHidden = true
        textField.text = ""
        textField.resignFirstResponder()
        clearButton.isHidden = true
        
        
        if viewControllerType == EthnicityClassType.TYPE_LOCATION {
            
            if tableView == dropDownTable {
                let searchData = dropDownDataSourceForLocation.object(at: indexPath.row) as! NSDictionary
                let desc = (searchData["description"] as! String)
                var arrValue = desc.components(separatedBy: ",")
                var location = arrValue.first!
                location = location.trimmingCharacters(in: CharacterSet.whitespaces)
                let stateValue = Int(arrValue.count) - 2
                if stateValue > 0 {
                    var state = arrValue[stateValue]
                    state = state.trimmingCharacters(in: CharacterSet.whitespaces)
                    
                    let selectedCityDetail = [
                        "city" : location,
                        "state" : state,
                        "reference" : (searchData["reference"] as! String),
                        "isSelected" : "true"
                    ]
                    
                    
                    
                    let aTempDict = [
                        "city" : location,
                        "state" : state,
                        "reference" : (searchData["reference"] as! String),
                        "isSelected" : "true",
                        "selectedLocationDetail" : selectedCityDetail
                    ] as [String : Any]
                    self.sectionHeaderLabel.text = NSLocalizedString("Your_Selection", comment: "")
                    mainDataSource = [aTempDict]
                    mainEthnicityTable.reloadData()
                    self.navBar?.customSwitch?.isOn = true
                    self.navBar?.switchValueChanged!((self.navBar?.customSwitch?.isOn)!)
                    self.backButton()
                    location = "\(location), \(state)"
                }
                else{
                    var state = arrValue.last!
                    state = state.trimmingCharacters(in: CharacterSet.whitespaces)
                    let selectedCityDetail = [
                        "city" : location,
                        "state" : state,
                        "reference" : (searchData["reference"] as! String),
                        "isSelected" : "true"
                    ]
                    let aTempDict = [
                        "city" : location,
                        "state" : state,
                        "reference" : (searchData["reference"] as! String),
                        "isSelected" : "true",
                        "selectedLocationDetail" : selectedCityDetail
                    ] as [String : Any]
                    self.sectionHeaderLabel.text = NSLocalizedString("Your_Selection", comment: "")
                    mainDataSource = [aTempDict]
                    mainEthnicityTable.reloadData()
                    self.navBar?.customSwitch?.isOn = true
                    self.navBar?.switchValueChanged!((self.navBar?.customSwitch?.isOn)!)
                    self.backButton()
                    location = "\(location), \(state)"
                }
            }
            else{
                if mainDataSource.count > 1 {
                    let selectCityDetails : NSDictionary = mainDataSource.object(at: indexPath.row) as! NSDictionary
                    let aTempDict = [
                        "city" : selectCityDetails["city"],
                        "state" : selectCityDetails["state"],
                        "selectedLocationDetail" : selectCityDetails,
                        "isSelected" : "true"
                    ]
//                    self.sectionHeaderLabel.text = NSLocalizedString("Top Cities", comment: "")
                    self.sectionHeaderLabel.text = NSLocalizedString("Your_Selection", comment: "")
                    
                    mainDataSource = [aTempDict]
                    mainEthnicityTable.reloadData()
                    self.navBar?.customSwitch?.isOn = true
                    self.navBar?.switchValueChanged!((self.navBar?.customSwitch?.isOn)!)
                    self.backButton()
                }
                else{
                    mainDataSource = (UserDefaults.standard.object(forKey: "locationOptions") as! NSArray?)!
                    mainEthnicityTable.reloadData()
                    self.sectionHeaderLabel.text = NSLocalizedString("Top Cities", comment: "")
                }
                
            }
            
            
        }
        else{
        
            if tableView == dropDownTable {
                
                if (maxmimumSelection == -1 || maxmimumSelection > selectedEthnicity.count) {
                    var counter = 0
                    for item in mainDataSource {
                        let ethnicityName = (item as! NSDictionary)["name"] as! String
                        if dropDownDataSource[indexPath.row] == ethnicityName {
                            let selectedValueId = (item as! NSDictionary)["tagId"] as! NSNumber
                            if (((selectedValueId.intValue == 14) && (self.viewControllerType == EthnicityClassType.TYPE_RELIGION)) || ((selectedValueId.intValue == 131) && (self.viewControllerType == EthnicityClassType.TYPE_ETHNICITY))) {
                                selectedEthnicity.removeAll()
                                doesnotMatterWasSelect = true
                            }
                            else{
                                if doesnotMatterWasSelect {
                                    selectedEthnicity.removeAll()
                                    doesnotMatterWasSelect = false
                                }
                            }
                            selectedEthnicity.append(ethnicityName)
                            break;
                        }
                        counter += 1
                    }
                    if selectedEthnicity.count > 0 {
                        self.navBar?.customSwitch?.isOn = true
                        self.navBar?.switchValueChanged!((self.navBar?.customSwitch?.isOn)!)
                    }
                    if counter >= mainDataSource.count {
                        counter = (mainDataSource.count - 1)
                    }
                    mainEthnicityTable.reloadData()
                    mainEthnicityTable.scrollToRow(at: NSIndexPath.init(row: counter, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
                }
                else{
                    showSnackBar("You can select upto 2 communities to add to your profile")
                }
            }
            else{
                let selectEthnicity = mainDataSource[indexPath.row]
                print("selectEthnicity \(selectEthnicity)")
                let ethnicity = (mainDataSource[indexPath.row] as! NSDictionary)["name"] as! String
                let selectedValueId = (mainDataSource[indexPath.row] as! NSDictionary)["tagId"] as! NSNumber
                if selectedEthnicity.contains(ethnicity) {
                    selectedEthnicity.remove(object: ethnicity)
                }
                else{
                    
                    if (((selectedValueId.intValue == 14) && (self.viewControllerType == EthnicityClassType.TYPE_RELIGION)) || ((selectedValueId.intValue == 131) && (self.viewControllerType == EthnicityClassType.TYPE_ETHNICITY))) {
                        selectedEthnicity.removeAll()
                        selectedEthnicity.append(ethnicity)
                        doesnotMatterWasSelect = true
                    }
                    else if maxmimumSelection == -1 || maxmimumSelection > selectedEthnicity.count {
                        if doesnotMatterWasSelect {
                            selectedEthnicity.removeAll()
                            doesnotMatterWasSelect = false
                        }
                        selectedEthnicity.append(ethnicity)
                    }
                    else{
                        showSnackBar("You can select upto 2 communities to add to your profile")
                    }
                }
                if selectedEthnicity.count > 0 {
                    self.navBar?.customSwitch?.isOn = true
                    self.navBar?.switchValueChanged!((self.navBar?.customSwitch?.isOn)!)
                }
                mainEthnicityTable.reloadData()
            }
        }
    }
    
    //method to get attributed string for search result
    func gettingAttributedString(from locationString: String) -> NSAttributedString {
        let count = textField.text?.count
        let firstString = locationString.substring(to: locationString.index(locationString.startIndex, offsetBy: count!))
        let secondString = locationString.replacingOccurrences(of: firstString, with: "")
        let latoFontBold = UIFont(name: "Lato-Bold", size: 16.0)
        let arialDict = [ NSAttributedString.Key.font : latoFontBold ]
        let aAttrString = NSMutableAttributedString(string: firstString, attributes: arialDict as [NSAttributedString.Key : Any])
        let latoFont = UIFont(name: "Lato-Regular", size: 16.0)
        let verdanaDict = [ NSAttributedString.Key.font : latoFont ]
        let vAttrString = NSMutableAttributedString(string: secondString, attributes: verdanaDict as [NSAttributedString.Key : Any])
        aAttrString.append(vAttrString)
        return aAttrString
    }
    
    
    func getPlacesAutoSuggetionFromGoogle(forText searchText: String) {
        if !Utilities().reachable() {
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
        var aQuery = searchText
        NSObject.cancelPreviousPerformRequests(withTarget: placesClient, selector: #selector(GMSPlacesClient.findAutocompletePredictions(fromQuery:filter:sessionToken:callback:)), object: self)
        if aQuery.count > 0 {
            let filter = GMSAutocompleteFilter()
            filter.type = .city
            
//            placesClient.autocompleteQuery(aQuery, bounds: nil, filter: filter, callback: { (results, error) in
//                <#code#>
//            })
            
            placesClient.findAutocompletePredictions(fromQuery: aQuery, filter: filter, sessionToken:nil) { (results, error) in
                print(results)
                print(error)
                if ((error?.localizedDescription != nil) &&  ((error?.localizedDescription.count)! > 0)){
                    print("Autocomplete error of ethinicity \(error?.localizedDescription)")
                    return
                }
                if (results?.count)! > 0 {
                    let arrfinal : NSMutableArray = []
                    for result in results! {
                        let gmsResult : GMSAutocompletePrediction = result as! GMSAutocompletePrediction
                        let aTempDict = [
                            "description" : gmsResult.attributedFullText.string,
                            "reference" : gmsResult.placeID
                        ]
                        
                        arrfinal.add(aTempDict)
                    }
                    if self.dropDownDataSourceForLocation.count > 0 {
                        self.dropDownDataSourceForLocation.removeAllObjects()
                    }
                    self.dropDownDataSourceForLocation = arrfinal
                    if self.dropDownDataSourceForLocation.count > 0 {
                        
                        
                        if self.dropDownDataSourceForLocation.count > 0 {
                            self.dropDownView.isHidden = false
                            if self.dropDownDataSourceForLocation.count > 3 {
                                self.dropDownHeightCOnstrain.constant = 48 * 4
                            }
                            else{
                                let count : CGFloat = CGFloat(self.dropDownDataSourceForLocation.count)
                                let cellHeight : CGFloat = 48.0
                                self.dropDownHeightCOnstrain.constant = cellHeight * count
                            }
                        }
                        else{
                            self.dropDownView.isHidden = true
                        }
                        
                        self.dropDownTable.reloadData()
//                        self.dropDownTable.delegate = self
//                        dropDownTable.dataSource = self
//                        tblViewSearch.isHidden = false
//                        tblView.isHidden = true
//                        dropDownTable.reloadData()
//                        tblView.userInteractionEnabled = false
                    }
                }
                else {
                    
                }
            }
            
        }
        else {
            
        }
    }
}

extension EthnicitySelectionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @objc(textField:shouldChangeCharactersInRange:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if string.utf16.count > 1{
            return false
        }
        return true
        
    }
    
}
