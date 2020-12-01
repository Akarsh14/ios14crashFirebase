//
//  PhoneCaptureTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 08/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

protocol PhoneCaptureTableCellDelegate {
    func fireBasePhoneAuth()
}

class PhoneCaptureTableViewCell: UITableViewCell {

    @IBOutlet weak var addOrChangeButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var delegate : PhoneCaptureTableCellDelegate?
    
    var initiatePhoneVerifyFlowHandler:(()->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addOrChange(_ sender: Any) {
        initiatePhoneVerifyFlowHandler()
        delegate?.fireBasePhoneAuth()
    }
    
    
    func setStateForPhoneNumberLabelAndButton(_ isActivated:Bool, phoneNumber:String){
        if isActivated {
            phoneNumberLabel.alpha = 1.0
            phoneNumberLabel.text = phoneNumber
            addOrChangeButton .isHidden = true
            addOrChangeButton.setTitle("CHANGE", for: .normal)
        }
        else{
            phoneNumberLabel.alpha = 0.5
            phoneNumberLabel.text = "Verify Number"
            addOrChangeButton .isHidden = false
            addOrChangeButton.setTitle("ADD", for: .normal)
        }
    }
    
}




