//
//  SelectCountryCellTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 06/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class SelectCountryCellTableViewCell: UITableViewCell {

    @IBOutlet weak var countryBackGroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeNumberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataForCountryCell(_ countryDto:CountryDtoModel){
        nameLabel.text = countryDto.countryName
        codeNumberLabel.text = countryDto.countryCode
    }
    
    func updateViewProperty(_ isSelected:Bool){
        if isSelected {
            countryBackGroundView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
            codeNumberLabel.textColor = UIColor(red: 61/255, green: 180/255, blue: 215/255, alpha: 1.0)
        }
        else{
            countryBackGroundView.backgroundColor = UIColor.clear
            codeNumberLabel.textColor = UIColor(red: 114/255, green: 119/255, blue: 138/255, alpha: 1.0)
        }
    }

}
