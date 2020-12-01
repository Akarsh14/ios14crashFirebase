//
//  QuestionTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 17/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit

class ActorQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionText: UILabel!
    
    @IBOutlet weak var answerContainerView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var answerTimeLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var questionTextHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var answerTextHeightConstrain: NSLayoutConstraint!
    
    fileprivate var cellData : TargetQuestionModel?
    
    var likeButtonHandler : ((TargetQuestionModel) -> (Void))?
    
    var optionButtonHandler : ((TargetQuestionModel) -> (Void))?
    
    
    @IBAction func likeButtonTapped(_ sender: AnyObject) {
        if likeButtonHandler != nil {
            self.likeButtonHandler!(cellData!)
        }
    }
    
    @IBAction func optionButtonTapped(_ sender: AnyObject) {
        if optionButtonHandler != nil {
            self.optionButtonHandler!(cellData!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUserData(_ data: TargetQuestionModel, userName: String, userAge: String, imageUrl: String) {
        cellData = data
        
        questionText.text = data.question
        let questionHeight : CGFloat = heightForView(data.question, font: UIFont(name: "Lato-Regular", size: 20.0)!, width: 320 - 64)
        questionTextHeightConstrain.constant = questionHeight
        
        if data.answer.count > 0 {
            if let myProfile = DiscoverProfileCollection.sharedInstance.myProfileData {
                
                let isMale = (Utilities.sharedUtility() as AnyObject).isGenderMale(myProfile.gender as String)
                var placeHolderImage = "male_placeholder_bigger"
                
                if !isMale {
                    placeHolderImage = "female_placeholder_bigger"
                }
                
                if let myWooAlbum = myProfile.wooAlbum {
                    if myWooAlbum.profilePicUrl() != nil {
                        myImageView.sd_setImage(with: URL(string: myWooAlbum.profilePicUrl()!),
                                                       placeholderImage: UIImage(named: placeHolderImage))
                    }
                    else{
                        myImageView.image = UIImage(named: placeHolderImage)
                    }
                }
                else{
                    myImageView.image = UIImage(named: placeHolderImage)
                }
                
                nameLabel.text = myProfile.myName()
            }

            let date : Date = (Utilities.sharedUtility() as AnyObject).returnDate(fromTimeStamp: Int64(data.questionTime))
            timeLabel.text = (Utilities.sharedUtility() as AnyObject).returnDateString(ofTimestamp: date) + "ago"
            
            let answerDate : Date = (Utilities.sharedUtility() as AnyObject).returnDate(fromTimeStamp: Int64(data.answerTime))
            answerTimeLabel.text = (Utilities.sharedUtility() as AnyObject).returnDateString(ofTimestamp: answerDate) + " ago"
            
            answerLabel.text = data.answer
            let answerHeight : CGFloat = heightForView(data.question, font: UIFont(name: "Lato-Regular", size: 22.0)!, width: 320 - 64 - 32)
//            answerTextHeightConstrain.constant = answerHeight
            
            userNameLabel.text = userName + " , " + userAge
            
            userImageView.sd_setImage(with: URL(string: imageUrl))
            
            let ansDate : Date = (Utilities.sharedUtility() as AnyObject).returnDate(fromTimeStamp: Int64(data.questionTime))
            timeLabel.text = (Utilities.sharedUtility() as AnyObject).returnDateString(ofTimestamp: ansDate) + " ago"
            
        }
        else{
            
            answerLabel.text = ""
        }
    }
    
    fileprivate func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}
