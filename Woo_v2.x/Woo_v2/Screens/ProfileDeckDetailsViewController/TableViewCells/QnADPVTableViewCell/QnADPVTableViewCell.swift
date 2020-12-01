//
//  QnADPVTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 16/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class QnADPVTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var paddingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerTextLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDataForViewBasedOnModel(_ questionModel:TargetQuestionModel){
        questionTextLabel.text = questionModel.question
        answerTextLabel.text = questionModel.answer
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
