//
//  NewDiscoverSettingsAgeTableViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 27/04/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class NewDiscoverSettingsAgeTableViewCell: UITableViewCell {

    @IBOutlet weak var rangeLabel: UILabel!
//    @IBOutlet weak var rangeSeekAgeSlider: RangeSeekSlider!
    @IBOutlet weak var minRangeLabel: UILabel!
    @IBOutlet weak var maxRangeLabel: UILabel!

    var currentMaxAge = 0
    var currentMinAge = 0
    @IBOutlet weak var rangeSeekAgeSlider: RangeSeekSlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        rangeSeekAgeSlider.hideLabels = false
//        rangeSeekAgeSlider.labelsFixed = true
//        rangeSeekAgeSlider.tintColor = UIColor.lightGray
        rangeSeekAgeSlider.handleBorderColor = UIColor.clear
        rangeSeekAgeSlider.lineHeight = 4.0
    }
    
    func updateAgeAndSliderValues(){
        
        rangeSeekAgeSlider.delegate = self
        currentMinAge = DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge.intValue
        currentMaxAge = DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge.intValue
        rangeLabel.text = "\(Int(currentMinAge))-\(Int(currentMaxAge))"
        minRangeLabel.text = "\(Int(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAllowedAge.intValue))"
        maxRangeLabel.text = "\(Int(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAllowedAge.intValue))"
        
        rangeSeekAgeSlider.minValue = CGFloat(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAllowedAge.intValue)
        rangeSeekAgeSlider.maxValue = CGFloat(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAllowedAge.intValue)
        rangeSeekAgeSlider.minDistance = CGFloat(DiscoverProfileCollection.sharedInstance.intentModelObject!.intentAgeDifferenceThreshold.intValue)
        rangeSeekAgeSlider.selectedMinValue = CGFloat(DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge.intValue)
        rangeSeekAgeSlider.selectedMaxValue = CGFloat(DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge.intValue)
    }

}

extension NewDiscoverSettingsAgeTableViewCell: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
        rangeLabel.text = "\(Int(minValue))-\(Int(maxValue))"
        //minRangeLabel.text = "\(Int(minValue))"
        //maxRangeLabel.text = "\(Int(maxValue))"
        if currentMinAge != Int(minValue) || currentMaxAge != Int(maxValue){
            DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge = NSNumber(value: Float(minValue))
            DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge = NSNumber(value: Float(maxValue))
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = true
        }
        else{
            DiscoverProfileCollection.sharedInstance.intentModelObject!.minAge = NSNumber.init(value: currentMinAge)
            DiscoverProfileCollection.sharedInstance.intentModelObject!.maxAge = NSNumber.init(value: currentMaxAge)
            DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
        }
        
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
