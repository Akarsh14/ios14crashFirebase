//
//  QnADataCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 14/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class QnADataCell: UITableViewCell {

    @IBOutlet weak var answerTextLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    
    @IBOutlet weak var questionTextLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewTopConstraint: NSLayoutConstraint!
    var buttonTappedHandler : ((Int) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func optionsButtonClicked(_ sender: Any) {
        if buttonTappedHandler != nil{
            buttonTappedHandler?(self.tag)
        }
    }
    
    func updateViewBasedOnData(_ questionAnswerObject:TargetQuestionModel){
        questionTextLabel.text = questionAnswerObject.question
        answerTextLabel.text = questionAnswerObject.answer
    }
    
}
