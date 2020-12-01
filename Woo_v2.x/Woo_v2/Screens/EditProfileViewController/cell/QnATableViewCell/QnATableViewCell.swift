//
//  QnATableViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 09/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class QnATableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var questionAnswerTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionAnswerTableView: UITableView!
    @IBOutlet weak var emptyQuestionLabel: UILabel!
    @IBOutlet weak var emptyQuestionView: UIView!
    var questionAnswersArray:[TargetQuestionModel]?
    
    var indexHandler : ((Int) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViewBasedOnData(_ questionAnswerArray:[TargetQuestionModel]){
        if questionAnswerArray.count > 0{
            emptyQuestionView.isHidden = true
            questionAnswerTableView.isHidden = false
            questionAnswersArray = questionAnswerArray
            questionAnswerTableView.reloadData()
            if questionAnswerArray.count >= Int(AppLaunchModel.sharedInstance()?.wooQuestionLimit ?? 3){
                plusButton.isHidden = true
                questionAnswerTableViewBottomConstraint.constant = 45
            }
            else{
                plusButton.isHidden = false
                questionAnswerTableViewBottomConstraint.constant = 110
            }
        }
        else{
            emptyQuestionView.isHidden = false
            emptyQuestionLabel.text = NSLocalizedString("Add an answer", comment: "") + " (upto 3)"
            questionAnswerTableView.isHidden = true
            plusButton.isHidden = true
        }
    }
    
    @IBAction func plusButtonClicked(_ sender: Any) {
        if self.indexHandler != nil{
            self.indexHandler?(-1)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionAnswersArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "QnADataCell"
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : QnADataCell? = array?.first as? QnADataCell
        cell?.updateViewBasedOnData(questionAnswersArray?[indexPath.row] ?? TargetQuestionModel())
        cell?.tag = indexPath.row
        cell?.buttonTappedHandler = {(index) in
            if self.indexHandler != nil{
                self.indexHandler?(index)
            }
        }
        cell?.backgroundViewTopConstraint.constant = 0
        cell?.questionTextLabelTopConstraint.constant = 17
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
