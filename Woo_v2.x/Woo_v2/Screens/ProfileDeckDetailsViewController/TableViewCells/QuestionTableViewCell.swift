//
//  QuestionTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 17/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionText: UILabel!
    
    @IBOutlet weak var answerContainerView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var answerButton: UIButton!
    
    @IBOutlet weak var youAnsweredLabel: UILabel!
    
    fileprivate var cellData : TargetQuestionModel?
    
    @IBOutlet weak var answerLabelBottomConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var answerLabelTopConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var questionHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var answerHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var answerContainerHeightConstrain: NSLayoutConstraint!
    
    var needToHideAnswerButton: Bool = false
    
    var answerButtonHandler : ((TargetQuestionModel) -> (Void))?
    
    
    @IBAction func answerButtonTapped(_ sender: AnyObject) {
        if answerButtonHandler != nil {
            self.answerButtonHandler!(cellData!)
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

    func setUserData(_ data: TargetQuestionModel) {
        cellData = data
        
        questionText.text = data.question
        
        var questionHeight : CGFloat = heightForView(data.question, font: UIFont(name: "Lato-Regular", size: 18.0)!, width: 320 - 64)
        
        if questionHeight < 20 {
            questionHeight = 20
        }
        
        questionHeightConstrain.constant = questionHeight
        
        if data.answer.count > 0 {
            if let myProfile = DiscoverProfileCollection.sharedInstance.myProfileData {
                if let myWooAlbum = myProfile.wooAlbum {
                    if myWooAlbum.count() > 0 {
                        userImageView.sd_setImage(with: URL(string: myWooAlbum.objectAtIndex(0)!.url!), placeholderImage: UIImage(named: "ic_me_avatar_big"))
                    }
                    else{
                        userImageView.image = UIImage(named: "ic_me_avatar_big")
                    }
                }
                nameLabel.text = myProfile.myName()
            }

            let date : Date = (Utilities.sharedUtility() as AnyObject).returnDate(fromTimeStamp: Int64(data.answerTime))
            timeLabel.text = (Utilities.sharedUtility() as AnyObject).returnDateString(ofTimestamp: date)
            
            let answerHeight : CGFloat = heightForView(data.answer, font: UIFont(name: "Lato-Regular", size: 16.0)!, width: 320 - 64)
            answerHeightConstrain.constant = answerHeight
            answerContainerHeightConstrain.constant = 84.0
            answerLabelBottomConstrain.constant = 10.0
            answerLabelTopConstrain.constant = 10.0
            self.layoutIfNeeded()
            answerLabel.text = data.answer
            youAnsweredLabel.isHidden = false
            self.answerButton.isUserInteractionEnabled = false
            answerButton.isHidden = true
        }
        else{
            if self.needToHideAnswerButton == true{
                answerContainerHeightConstrain.constant = 0.0
                answerButton.isHidden = true
            }
            else{
            answerContainerHeightConstrain.constant = 48.0
            answerButton.isHidden = false
            }
            
            answerHeightConstrain.constant = 0.0
            answerLabelBottomConstrain.constant = 0.0
            answerLabelTopConstrain.constant = 0.0
            self.layoutIfNeeded()
            
            youAnsweredLabel.isHidden = true
            
            answerLabel.text = ""
            
            self.answerButton.isUserInteractionEnabled = true
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
