//
//  EditProfileHeightTableCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 20/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class EditProfileHeightTableCell: UITableViewCell {

    @IBOutlet weak var lblHeight: UILabel!
    
    @IBOutlet weak var maximumValueLabel: UILabel!
    @IBOutlet weak var minimumValueLabel: UILabel!
    @IBOutlet weak var heightSlider: UISlider!
    let minimumSliderValue : Float = 122.0
    let maximumSliderValue : Float = 240.0
    
    @IBOutlet weak var heightSegmentControl: UISegmentedControl!
    var heightType : HeightUnit = (DiscoverProfileCollection.sharedInstance.myProfileData?.showHeightType)!
    
    var heightUpdateHandler : ((String , HeightUnit, Bool)->())?
    
    var heightValue : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(_ height: String) {
        heightValue = height
        
        
        if heightType == .CM{
            heightSegmentControl.selectedSegmentIndex = 0
        }else{
            heightSegmentControl.selectedSegmentIndex = 1
        }
        let value : String =  (Utilities.sharedUtility() as AnyObject).getCentimeterFromFeetInches(heightValue)
        
        heightSlider.value = (Float(value))!
        lblHeight.text = value
        changeToFeetAndCm(heightSegmentControl)
        //update UI here
    }
    
    @IBAction func heightSliderValueChanged(_ sender: UISlider) {
        if heightType == .CM{
            
            let feetInchValue : String =  (Utilities.sharedUtility() as AnyObject).getfeetAndInches(sender.value)
            
            lblHeight.text = String(format: "%.0f",sender.value)
            
            heightValue = String(feetInchValue)
            
            if self.heightUpdateHandler != nil {
                self.heightUpdateHandler!(feetInchValue , heightType, true)
            }
        }else{ // Feet Inch
            let feetInchValue : String =  (Utilities.sharedUtility() as AnyObject).getfeetAndInches(sender.value)
            
            heightValue = String(sender.value)
            lblHeight.text = String(feetInchValue)
            
            if self.heightUpdateHandler != nil {
                self.heightUpdateHandler!(String(feetInchValue) , heightType, true)
            }
        }
    }
    @IBAction func changeToFeetAndCm(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // CM button clicked
            
            heightType = .CM
            let centimeterValue : String =  (Utilities.sharedUtility() as AnyObject).getCentimeterFromFeetInches(lblHeight.text)
            print(centimeterValue)
            minimumValueLabel.text = "\(Int(minimumSliderValue))"
            maximumValueLabel.text = "\(Int(maximumSliderValue))"
            lblHeight.text = centimeterValue
            
            
        }else{ // FT button clicked
            
            heightType = .INCHES
            if let height : Float = Float((lblHeight?.text)!){
                let feetInchValue : String =  (Utilities.sharedUtility() as AnyObject).getfeetAndInches(height)
                print(feetInchValue)
                minimumValueLabel.text = "4'0\""
                maximumValueLabel.text = "7'11\""
                lblHeight.text = feetInchValue
                
            }
        }
        
        
        if self.heightUpdateHandler != nil {
            self.heightUpdateHandler!(heightValue! , heightType, false)
        }
        
    }
}
