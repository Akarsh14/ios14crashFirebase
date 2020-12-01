//
//  OptionSelectionTableViewCell.swift
//  Woo_v2
//
//  Created by Deepak Gupta on 7/27/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class OptionSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblOption: UILabel!
    
    @IBOutlet weak var imgCheckMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ model: ProfessionModel, modelType type:String) {
        
        lblOption.text = model.name
        if(model.tagId == "2" && DiscoverProfileCollection.sharedInstance.myProfileData!.gender == "FEMALE" && type != "Religion")
        {
            setRecommenedOptionForLabelText(model.name!)
        }
        
    }
    
    func setRecommenedOptionForLabelText(_ selectedModelName:String){
        let font = UIFont(name: "Lato-Regular", size: 12.0)!
        let strokeTextAttributes :[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor(red: (100.0/255.0), green: (183.0/255.0), blue: (211.0/255.0), alpha: 1.0),
            NSAttributedString.Key.font : font
        ]
        let modelName = NSMutableAttributedString(string: selectedModelName, attributes: nil)
        let recommended = NSMutableAttributedString(string: "  (Recommended)", attributes: strokeTextAttributes)
        let combination = NSMutableAttributedString()
        combination.append(modelName)
        combination.append(recommended)
        lblOption.attributedText = combination
    }
    
}
