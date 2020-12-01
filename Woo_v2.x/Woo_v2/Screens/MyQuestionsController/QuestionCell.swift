//
//  QuestionCell.swift
//  Woo_v2
//
//  Created by Vaibhav Gautam on 13/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    
    fileprivate var localQuestionData:MyQuestions?
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerCountLabel: UILabel!
    @IBOutlet weak var timeUpdateLocation: UILabel!
    @IBOutlet weak var answerCountImage: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    
    var deleteAction:((MyQuestions)->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func optionsButtonTapped(_ sender: AnyObject) {
        self.deleteAction(self.localQuestionData!)
    }
    
    func setDataOnCellFromModelObj(_ questionModel:MyQuestions?){
        
        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        
        if questionModel != nil {
            
            localQuestionData = questionModel
            
            if localQuestionData?.questionText != nil {
                questionLabel.text = localQuestionData?.questionText
            }
            
            answerCountLabel.isHidden = false
            answerCountImage.isHidden = false
            answerCountImage.image = UIImage.init(named: "ic_me_answer_grey")
            
            if ((localQuestionData?.totalAnswers == nil) || (localQuestionData?.totalAnswers.intValue == 0)) {
                answerCountLabel.isHidden = true
                answerCountImage.isHidden = true
            }
            else{
                if localQuestionData?.totalUnreadAnswers != nil {
//                    answerCountLabel.text = String((localQuestionData?.totalUnreadAnswers as! Int))
                    if Int(localQuestionData!.totalUnreadAnswers) < 1 {
                        answerCountImage.image = UIImage.init(named: "ic_me_answer_grey")
                    }
                    else{
                        answerCountImage.image = UIImage.init(named: "answerCountImage")
                    }
                }
                if localQuestionData?.totalAnswers != nil {
                    answerCountLabel.text = String((localQuestionData?.totalAnswers as! Int))
                }
            }
            
            
            
            if localQuestionData?.lastUpdateTime != nil {
                
                var timeString: String!
                timeString = Utilities().returnDateString(ofTimestamp: questionModel?.lastUpdateTime)
                timeString = timeString + " ago"
                
                timeUpdateLocation.text = timeString
            }
            
            /*
             if Int(localQuestionData!.totalUnreadAnswers) < 1 {
             
             answerCountImage.hidden = true
             }
             else{
             
             answerCountImage.hidden = false
             }
             
             if Int(localQuestionData!.totalAnswers) < 1 {
             answerCountLabel.hidden = true
             }else{
             answerCountLabel.hidden = false
             }
             */


        }
        
    }
}
