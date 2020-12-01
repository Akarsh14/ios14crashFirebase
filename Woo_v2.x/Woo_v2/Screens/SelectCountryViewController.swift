//
//  SelectCountryViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 05/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class SelectCountryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var countrySearchBar: UISearchBar!

    @IBOutlet weak var countryTableView: UITableView!
    
    var searchActive : Bool = false
    var countryDtoArray:[CountryDtoModel] = []
    var filteredCountryDtoArray:[CountryDtoModel] = []
    var selectedIndex = -1
    var selectedCountryDto:CountryDtoModel?
    
    @IBOutlet weak var searchView: UIView!
    var selectedCountryHandler:((CountryDtoModel)->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        let image = UIImage()
        countrySearchBar.setBackgroundImage(image, for: .any, barMetrics: .default)
        countrySearchBar.scopeBarBackgroundImage = image

        if AppLaunchModel.sharedInstance().countryDtoArray != nil && AppLaunchModel.sharedInstance().countryDtoArray.count > 0 {
            countryDtoArray = AppLaunchModel.sharedInstance().countryDtoArray as! [CountryDtoModel]
        }
        
        for countryDto in countryDtoArray{
            selectedIndex = selectedIndex + 1
            let tmp = countryDto.countryName
            let countryName = selectedCountryDto?.countryName
            if tmp == countryName{
                break
            }
        }
        
        if selectedIndex >= 0 && selectedIndex <= countryDtoArray.count {
            countryTableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .bottom, animated: true)
        }
        
        addShadowToSearchView()
        
       // makingCustomizedSearchBar()
        
        self.countryTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func addShadowToSearchView(){
        let shadowSize : CGFloat = 3.0
        
        let width = SCREEN_WIDTH - 20
        let height = 50
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: width + shadowSize,
                                                   height: CGFloat(height + Int(shadowSize))))
        self.searchView.layer.masksToBounds = false
        self.searchView.layer.shadowColor = UIColor.black.cgColor
        self.searchView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.searchView.layer.shadowOpacity = 0.3
        self.searchView.layer.shadowPath = shadowPath.cgPath
    }
    
    func makingCustomizedSearchBar(){
        let clearImage = imageWithColor(UIColor.clear, size: countrySearchBar.frame.size)
        countrySearchBar.setBackgroundImage(clearImage, for: .any, barMetrics: .default)
        countrySearchBar.setImage(UIImage(named: "searchMagnifyer"), for: .search, state: .normal)
        countrySearchBar.setImage(UIImage(named: "searchClear"), for: .clear, state: .normal)
        
        let tf:UITextField = countrySearchBar.value(forKey: "searchField") as! UITextField
        tf.font = UIFont(name: "Lato-Medium", size: 16.0)
        tf.backgroundColor = UIColor(red: 117/255, green: 196/255, blue: 219/255, alpha: 1.0)
        tf.textColor = UIColor.white
        tf.leftViewMode = .never
        tf.tintColor = UIColor.white
        tf.textAlignment = .left
    }
    
    func imageWithColor(_ color:UIColor, size:CGSize) -> UIImage? {
        var img:UIImage?
        let rect:CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor( color.cgColor )
        context.fill( rect )
        img = UIGraphicsGetImageFromCurrentImageContext()
        return img
    }

//    - (void) makingCustomizedSearchBar{
//    
//    UIImage* clearImg = [self imageWithColor:[UIColor clearColor] andSize:SearchBarObj.frame.size];
//    [SearchBarObj setBackgroundImage:clearImg];
//    
//    [SearchBarObj setImage:[UIImage imageNamed:@"searchMagnifyer"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//    [SearchBarObj setImage:[UIImage imageNamed:@"searchClear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
//    
//    if ([tblView respondsToSelector:@selector(setSeparatorInset:)]) {
//    [tblView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:kSearchBarDefaultColor];
//    
//    
//    //    for(UIView *subView in SearchBarObj.subviews) {
//    //        if ([subView isKindOfClass:[UITextField class]]) {
//    //            UITextField *searchField = (UITextField *)subView;
//    //            searchField.font = [UIFont fontWithName:@"Lato-Medium" size:16.0f];
//    //            searchField.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:196.0/255.0 blue:219.0/255.0 alpha:1.0];
//    //        }
//    //    }
//    
//    
//    UITextField *tf = [SearchBarObj valueForKey:@"searchField"];
//    tf.font = [UIFont fontWithName:@"Lato-Medium" size:16.0f];
//    tf.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:196.0/255.0 blue:219.0/255.0 alpha:1.0];
//    tf.textColor = [UIColor whiteColor];
//    tf.leftViewMode = UITextFieldViewModeNever;
//    [tf setTintColor:[UIColor whiteColor]];
//    tf.textAlignment = NSTextAlignmentLeft;
//    
//    }
//    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredCountryDtoArray = countryDtoArray.filter({ (countryModel) -> Bool in
            let tmp: NSString = countryModel.countryName as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filteredCountryDtoArray.count == 0){
            searchActive = false
        } else {
            searchActive = true
        }
        self.countryTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredCountryDtoArray.count
        }
        return countryDtoArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "SelectCountryCellTableViewCell", for: indexPath) as! SelectCountryCellTableViewCell)
        var countryDtoObject:CountryDtoModel?
        var countryCount = 0
        if searchActive {
            countryDtoObject = filteredCountryDtoArray[indexPath.row]
            countryCount = filteredCountryDtoArray.count
        }
        else{
            countryDtoObject = countryDtoArray[indexPath.row]
            countryCount = countryDtoArray.count
        }
        cell.setDataForCountryCell(countryDtoObject!)
        if selectedIndex >= 0 && selectedIndex <= countryCount {
            if selectedIndex == indexPath.row {
                cell.updateViewProperty(true)
            }
            else{
                cell.updateViewProperty(false)
            }
        }
        cell.selectionStyle = .none
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SelectCountryCellTableViewCell
        cell.updateViewProperty(true)
        
        var countryDtoObject:CountryDtoModel?
        var countryCount = 0

        if searchActive {
            countryDtoObject = filteredCountryDtoArray[indexPath.row]
            countryCount = filteredCountryDtoArray.count
        }
        else{
            countryDtoObject = countryDtoArray[indexPath.row]
            countryCount = countryDtoArray.count
        }
        
        if selectedIndex >= 0 && selectedIndex <= countryCount {
            let preSelectedIndexPath = IndexPath(row: selectedIndex, section: 0)
            let cell = tableView.cellForRow(at: preSelectedIndexPath) as! SelectCountryCellTableViewCell
            cell.updateViewProperty(false)
        }

        self.dismiss(animated: true) { 
            if self.selectedCountryHandler != nil{
                self.selectedCountryHandler(countryDtoObject!)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
