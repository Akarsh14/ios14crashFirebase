//
//  MyAnswersTableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 14/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MyQuestionForAnswersTableViewCell: UITableViewCell {

    fileprivate var localquestionForAnswerData:MyQuestions?

    
    @IBOutlet weak var myUserName: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var deleteAction:((MyQuestions)->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataOnCellFromModelObj(_ questionModel:MyQuestions?){
        if questionModel != nil {
            localquestionForAnswerData = questionModel
            
            questionTextLabel.text = localquestionForAnswerData?.questionText
            if let profilePicUrl = DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl() {
                
                let placeHolderImageStr:String = "ic_me_avatar_big"
                
                myImageView.sd_setImage(with: URL(string: profilePicUrl), placeholderImage: UIImage.init(named: placeHolderImageStr))
                
            }
            
            var timeString: String!
            timeString = Utilities().returnDateString(ofTimestamp: questionModel?.questionCreatedTime) // changed from lastUpdateTime to createdTime
            timeString = timeString + " ago"
            
            timeLabel.text = timeString

        }
    }

    @IBAction func optionsButtonTapped(_ sender: AnyObject) {
        self.deleteAction(self.localquestionForAnswerData!)
    }
    
}
