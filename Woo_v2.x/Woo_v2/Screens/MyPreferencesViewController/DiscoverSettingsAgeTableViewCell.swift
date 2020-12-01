//
//  DiscoverSettingsAgeTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 19/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class DiscoverSettingsAgeTableViewCell: UITableViewCell {

    @IBOutlet weak var maxWheelText: UILabel!
    @IBOutlet weak var maxWheel: UICircularSlider!
    @IBOutlet weak var minWheel: UICircularSlider!
    @IBOutlet weak var minWheelText: UILabel!
    
    var currentMaxAge = 0
    var currentMinAge = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateAgeAndSliderValues(){
        minWheel.addTarget(self, action: #selector(updateProgress), for: UIControl.Event.valueChanged)
        minWheel.minimumValue = Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAllowedAge.intValue)
        minWheel.maximumValue = Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAllowedAge.intValue - DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue)
        minWheel.isContinuous = true
        minWheel.thumbnailRadius = 10.0
        minWheel.minimumTrackTintColor = UIColor.clear
        minWheel.maximumTrackTintColor = UIColor.clear
        minWheel.thumbTintColor = UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        minWheel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        maxWheel.addTarget(self, action: #selector(updateProgress), for: UIControl.Event.valueChanged)

        maxWheel.maximumValue = Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAllowedAge.intValue)
        maxWheel.minimumValue = Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAllowedAge.intValue + DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue)
        maxWheel.thumbnailRadius = 10.0
        maxWheel.isContinuous = true
        maxWheel.minimumTrackTintColor = UIColor.clear
        maxWheel.maximumTrackTintColor = UIColor.clear
        maxWheel.thumbTintColor = UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        maxWheel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

        minWheel.value = Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge.intValue)
        currentMinAge = DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge.intValue
        //minWheel.setValueAndDoNotNotify(Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge))
        minWheelText.text = String(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge.intValue)
        
        maxWheel.value = Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge.intValue)
        currentMaxAge = DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge.intValue
        //maxWheel.setValueAndDoNotNotify(Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge))
        maxWheelText.text = String(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge.intValue)
        
        self.needsUpdateConstraints()
        minWheel.needsUpdateConstraints()
        minWheel.needsUpdateConstraints()
        
        minWheel.layoutIfNeeded()
        maxWheel.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    @objc func updateProgress(_ slider:UISlider){
        if slider == minWheel{
            let sliderValue:Int = Int(slider.value)
            var maxWheelValue:Int = Int(maxWheel.value)
            minWheelText.text = String(sliderValue)
            if Int(maxWheel.value - minWheel.value) < DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue{
                maxWheel.setValueAndDoNotNotify(minWheel.value + Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue))
                maxWheelValue = Int(maxWheel.value)
                maxWheelText.text = String(maxWheelValue)
            }
            if currentMinAge != Int(slider.value) || currentMaxAge != Int(maxWheel.value){
                DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge = NSNumber.init(value: slider.value)
                DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge = NSNumber.init(value: maxWheel.value)
                print("min slider.value=\(slider.value)")
                print("min maxWheel.value=\(maxWheel.value)")
                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            }
            else{
                DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge = NSNumber.init(value: currentMinAge)
                DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge = NSNumber.init(value: currentMaxAge)
                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
            }
        }
        else{
            let sliderValue:Int = Int(slider.value)
            var minWheelValue:Int = Int(minWheel.value)
            maxWheelText.text = String(sliderValue)
            if Int(maxWheel.value - minWheel.value) < DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue{
                minWheel.setValueAndDoNotNotify(maxWheel.value - Float(DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue))
                minWheelValue = Int(minWheel.value)
                minWheelText.text = String(minWheelValue)
            }
            
            if currentMinAge != Int(minWheel.value) || currentMaxAge != Int(slider.value) {
                DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge = NSNumber.init(value: minWheel.value)
                print("max minWheel.value=\(minWheel.value)")
                DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge = NSNumber.init(value: slider.value)
                print("max slider.value=\(slider.value)")
                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
            }
            else{
                DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge = NSNumber.init(value: currentMinAge)
                DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge = NSNumber.init(value: currentMaxAge)
                DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
            }
        }
    }

}
