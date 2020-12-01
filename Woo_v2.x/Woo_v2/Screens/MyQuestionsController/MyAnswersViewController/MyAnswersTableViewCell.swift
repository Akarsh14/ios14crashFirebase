//
//  MyAnswersTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 14/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//


enum ActionType {
    case view_USER_PROFILE
    case options
    case like_ANSWER
    case dislike_ANSWER

}

import UIKit

class MyAnswersTableViewCell: UITableViewCell {

    fileprivate var localAnswerData:MyAnswers?

    @IBOutlet weak var asnwerTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var AnsweredUserImageView: UIImageView!
    @IBOutlet weak var answeredUserName: UILabel!
    
    fileprivate var actionType:ActionType = ActionType.like_ANSWER
    
    var performedAction:((MyAnswers, ActionType)->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataOnCellFromModelObj(_ answerModel:MyAnswers?){
        if answerModel != nil {
            localAnswerData = answerModel
            
            asnwerTextLabel.text = localAnswerData?.answerDescription
            
            answeredUserName.text = (localAnswerData?.userName)! + ", " + (localAnswerData?.userAge.stringValue)!
            if let profilePicUrl = localAnswerData?.userImageURL {
                
                let urlString: NSString = NSString(format: "\(kImageCroppingServerURL)?width=54&height=54&url=\(profilePicUrl)" as NSString)
                
                let placeHolderImageStr:String = "ic_me_avatar_big"
                
                AnsweredUserImageView.sd_setImage(with: URL(string: urlString as String), placeholderImage: UIImage.init(named: placeHolderImageStr))
                
            }
            
            
            var timeString: String!
            timeString = Utilities().returnDateString(ofTimestamp: localAnswerData?.createdTime)
            timeString = timeString + " ago"
            
            timeLabel.text = timeString
        }
        
    }
    @IBAction func viewUserProfile(_ sender: AnyObject) {
        actionType = .view_USER_PROFILE
        self.performedAction(self.localAnswerData!, actionType)
    }

    @IBAction func optionsButtonTapped(_ sender: AnyObject) {
        actionType = .options
        self.performedAction(self.localAnswerData!, actionType)
    }
    @IBAction func likeThisAnswer(_ sender: AnyObject) {
        actionType = .like_ANSWER
        self.performedAction(self.localAnswerData!, actionType)
    }
    @IBAction func dislikeThisAnser(_ sender: UIButton) {
        actionType = .dislike_ANSWER
        self.performedAction(self.localAnswerData!, actionType)


    }
}
