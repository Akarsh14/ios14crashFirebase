//
//  TemplateAnswerCell.swift
//  Woo_v2
//
//  Created by Vaibhav Gautam on 12/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class TemplateAnswerCell: UITableViewCell {

    
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var selectedTic: UIImageView!
    @IBOutlet weak var backgroundArea: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func setDataOnViewWithQuestionText(_ question:NSString, isSelected:Bool){
        
        
        backgroundArea.layer.shadowColor = UIColor.darkGray.cgColor
        backgroundArea.layer.shadowOpacity = 0.1
        backgroundArea.layer.shadowRadius = 3.0
        backgroundArea.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        
        
        if isSelected == true {
            selectedTic.isHidden = false
            backgroundArea.backgroundColor = UIColor(red:0.46, green:0.77, blue:0.86, alpha:1.0)
            questionText.textColor = UIColor.white
        }else{
            selectedTic.isHidden = true
            backgroundArea.backgroundColor = UIColor.white
            questionText.textColor = UIColor(red:0.45, green:0.47, blue:0.54, alpha:1.0)
            

        }
        
        questionText.text = question as String
        
        
    }
    
    
}
