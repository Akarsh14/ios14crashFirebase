//
//  AppSettingsWooGlobeTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 17/11/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class AppSettingsWooGlobeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var religionArrowImageview: UIImageView!
    @IBOutlet weak var ethnicityArrowImageView: UIImageView!
    @IBOutlet weak var locationArrowImageView: UIImageView!
    @IBOutlet weak var religionLabel: UILabel!
    @IBOutlet weak var ethnicityLabel: UILabel!
    @IBOutlet weak var locationHeaderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var wooGlobeSelectionLocationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wooGlobeSelectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wooGlobeHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wooGlobeSelectionView: UIView!
    @IBOutlet weak var wooGlobeHeaderViewLabel: UILabel!
    @IBOutlet weak var wooGlobeSwitch: UISwitch!
    @IBOutlet weak var wooGlobeHeaderView: UIView!
    
    var buttonTapHandler : ((_ tappedCellType: WooGlobeCellType) -> (Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showalertForDebugging(_ titleMessage: String , commentMessage: String){
        let alert: UIAlertController = UIAlertController(title:titleMessage, message: commentMessage, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .cancel, handler: {(action: UIAlertAction) -> Void in
        })
        
        alert.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    func setTheValuesOfEverythingBasedOnWooGlobeState(){
        
        let abcd = WooGlobeModel.sharedInstance().wooGlobleOption
        let abcde = WooGlobeModel.sharedInstance().isExpired
        let enableWooGlobleValue_Bool = WooGlobeModel.sharedInstance().wooGlobleOption
            && (!WooGlobeModel.sharedInstance().isExpired)
        
        print("enableWooGlobleValue_Bool",abcd)
        print("abcde", abcde)
//    showalertForDebugging("setTheValuesOfEverythingBasedOnWooGlobeState"+String(enableWooGlobleValue_Bool), commentMessage: "isExpired"+String(abcde))
            
        enableWooGlobleValue(enableWooGlobleValue: enableWooGlobleValue_Bool)
        
        if ((WooGlobeModel.sharedInstance().wooGlobeLocationCity != nil) && (WooGlobeModel.sharedInstance().wooGlobeLocationCity.count > 0)) {
            locationLabel.text = WooGlobeModel.sharedInstance().wooGlobeLocationCity
        }
        else{
            if let location = DiscoverProfileCollection.sharedInstance.myProfileData?.location {
                locationLabel.text = location as String
                DiscoverProfileCollection.sharedInstance.myProfileData?.diasporaLocation = location as String

            }
        }
        
        if let selectedEthnicityArrayValue: NSArray = WooGlobeModel.sharedInstance().ethnicityArray as NSArray? {
            if selectedEthnicityArrayValue.count > 0 {
                if selectedEthnicityArrayValue.count == 1 {
                    let firstObjectDetail: NSDictionary = selectedEthnicityArrayValue.firstObject as! NSDictionary
                    let stringToBeDisplayed = "\(firstObjectDetail.object(forKey: "name")!)"
                    print("\(stringToBeDisplayed)")
//                    ethnicityLabel.text = stringToBeDisplayed
                }
                else{
                    let firstObjectDetail: NSDictionary = selectedEthnicityArrayValue.firstObject as! NSDictionary
                    let stringToBeDisplayed = "\(firstObjectDetail.object(forKey: "name")!) + \(selectedEthnicityArrayValue.count - 1) more"
                    print("\(stringToBeDisplayed)")
//                    ethnicityLabel.text = stringToBeDisplayed
                }
                
            }
            else{
//                ethnicityLabel.text = "Select"
            }
        }
        
        if let selectedReligionArrayValue: NSArray = WooGlobeModel.sharedInstance().religionArray as NSArray? {
            if selectedReligionArrayValue.count > 0 {
                if selectedReligionArrayValue.count == 1 {
                    let firstObjectDetail: NSDictionary = selectedReligionArrayValue.firstObject as! NSDictionary
                    let stringToBeDisplayed = "\(firstObjectDetail.object(forKey: "name")!)"
                    print("\(stringToBeDisplayed)")
                    religionLabel.text = stringToBeDisplayed
                }
                else{
                    let firstObjectDetail: NSDictionary = selectedReligionArrayValue.firstObject as! NSDictionary
                    let stringToBeDisplayed = "\(firstObjectDetail.object(forKey: "name")!) + \(selectedReligionArrayValue.count - 1) more"
                    print("\(stringToBeDisplayed)")
                    religionLabel.text = stringToBeDisplayed
                }
                
            }
            else{
                religionLabel.text = "Select"
            }
        }
        
    }
    
    func enableWooGlobleValue(enableWooGlobleValue: Bool) {
        
        var labelExtraHeight: CGFloat = 0.0
        if UIScreen.main.bounds.size.width <= 320 {
            labelExtraHeight = 18
        }
        
        wooGlobeSwitch.isOn = enableWooGlobleValue
        
//        if ((WooGlobeModel.sharedInstance().isExpired == true) || (WooGlobeModel.sharedInstance().wooGlobleOption == false)) {
//            wooGlobeSwitch.isOn = false
//        }
//        else{
//            wooGlobeSwitch.isOn = true
//        }
        
        if enableWooGlobleValue {
            
//            showalertForDebugging("enableWooGlobleValue is true "+String(enableWooGlobleValue), commentMessage: String(enableWooGlobleValue))
            
            if WooGlobeModel.sharedInstance().religionArray != nil{
            if ((WooGlobeModel.sharedInstance().religionArray.count > 0) && (WooGlobeModel.sharedInstance().religionOption != false)) {
                religionLabel.textColor = Utilities().getUIColorObject(fromHexString: "22A0C5", alpha: 1.0)
                religionArrowImageview.image = UIImage(named: "ic_my_preference_arrow_blue")
            }
            else{
                religionLabel.textColor = Utilities().getUIColorObject(fromHexString: "373A43", alpha: 0.5)
                religionArrowImageview.image = UIImage(named: "ic_my_preference_arrow_grey")
            }
            }
            
//            if WooGlobeModel.sharedInstance().ethnicityArray != nil{
//                if ((WooGlobeModel.sharedInstance().ethnicityArray.count > 0) && (WooGlobeModel.sharedInstance().ethnicityOption != false)){
//                    ethnicityLabel.textColor = Utilities().getUIColorObject(fromHexString: "22A0C5", alpha: 1.0)
//                    ethnicityArrowImageView.image = UIImage(named: "ic_my_preference_arrow_blue")
//                }
//                else{
//                    ethnicityLabel.textColor = Utilities().getUIColorObject(fromHexString: "373A43", alpha: 0.5)
//                    ethnicityArrowImageView.image = UIImage(named: "ic_my_preference_arrow_grey")
//                }
//            }
            
            if (WooGlobeModel.sharedInstance().locationOption == true) {
                locationLabel.textColor = Utilities().getUIColorObject(fromHexString: "22A0C5", alpha: 1.0)
                locationArrowImageView.image = UIImage(named: "ic_my_preference_arrow_blue")
            }
            else{
                locationLabel.textColor = Utilities().getUIColorObject(fromHexString: "373A43", alpha: 0.5)
                locationArrowImageView.image = UIImage(named: "ic_my_preference_arrow_grey")
                
            }
 
            
            
        }
        else{
            
//            showalertForDebugging("enableWooGlobleValue is false "+String(enableWooGlobleValue), commentMessage: String(enableWooGlobleValue))
            
            religionLabel.textColor = Utilities().getUIColorObject(fromHexString: "373A43", alpha: 0.5)
//            ethnicityLabel.textColor = Utilities().getUIColorObject(fromHexString: "373A43", alpha: 0.5)
            locationLabel.textColor = Utilities().getUIColorObject(fromHexString: "373A43", alpha: 0.5)
            
            religionArrowImageview.image = UIImage(named: "ic_my_preference_arrow_grey")
//            ethnicityArrowImageView.image = UIImage(named: "ic_my_preference_arrow_grey")
            locationArrowImageView.image = UIImage(named: "ic_my_preference_arrow_grey")
        
        }
        
        if WooGlobeModel.sharedInstance().isExpired == false {
            
//            showalertForDebugging("isExpired is false "+String(enableWooGlobleValue), commentMessage: String(enableWooGlobleValue))
            
            wooGlobeHeaderViewLabel.isHidden = true
            locationHeaderLabel.isHidden = false
            wooGlobeHeaderViewHeightConstraint.constant = 70 - 18 - labelExtraHeight
            wooGlobeSelectionLocationViewHeightConstraint.constant = 90
//            wooGlobeSelectionViewHeightConstraint.constant = 140
        }
        else{
            
//            showalertForDebugging("isExpired is true "+String(enableWooGlobleValue), commentMessage: String(enableWooGlobleValue))
            
            wooGlobeHeaderViewLabel.isHidden = false
            locationHeaderLabel.isHidden = true
            wooGlobeHeaderViewHeightConstraint.constant = 70 + labelExtraHeight
            wooGlobeSelectionLocationViewHeightConstraint.constant = 90 - 40
//            wooGlobeSelectionViewHeightConstraint.constant = 140
        }
        
//        if wooGlobeSwitch.isOn {
            /*For on state*/
//            wooGlobeSwitch.onTintColor = Utilities().getUIColorObject(fromHexString: "75C4DB", alpha: 1.0)
//
//            /*For off state*/
//            wooGlobeSwitch.tintColor = Utilities().getUIColorObject(fromHexString: "D6D6D6", alpha: 1.0)
//            wooGlobeSwitch.backgroundColor = Utilities().getUIColorObject(fromHexString: "D6D6D6", alpha: 1.0)
//            wooGlobeSwitch.layer.cornerRadius = 16
//        }
    }

    @IBAction func onOrOffWooGlobe(_ sender: AnyObject) {
        print("value change for switch \(wooGlobeSwitch.isOn)")
        buttonTapHandler!(WooGlobeCellType.CELL_TYPE_SWITCH)
    }
    @IBAction func selectionLocation(_ sender: AnyObject) {
        print("location button tapped")
        buttonTapHandler!(WooGlobeCellType.CELL_TYPE_LOCATION)
    }
    @IBAction func selectEthnicity(_ sender: AnyObject) {
        print("Ethnicity button tapped")
        buttonTapHandler!(WooGlobeCellType.CELL_TYPE_ETHNICITY)
    }
    @IBAction func selectReligion(_ sender: AnyObject) {
        print("Religion button tapped")
        buttonTapHandler!(WooGlobeCellType.CELL_TYPE_RELIGION)
    }
}
