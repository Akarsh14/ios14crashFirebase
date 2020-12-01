//
//  QuotationCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 09/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ActorQuestionSwiftCell: UITableViewCell {
    
    @IBOutlet weak var questionTableView: UITableView!
    
    fileprivate var _questionArray : [TargetQuestionModel]?
    
    fileprivate var userName: String?
    
    fileprivate var userAge: String?
    
    fileprivate var imageUrl: String?
    
    var likeButtonHandler : ((TargetQuestionModel) -> (Void))?
    
    var optionButtonHandler : ((TargetQuestionModel) -> (Void))?
    
    func setUserData(_ data: [TargetQuestionModel], userName: String, userAge: String, imageUrl: String){
        _questionArray = data
        
        self.userName = userName
        
        self.userAge = userAge
        
        self.imageUrl = imageUrl
        
        self.questionTableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        questionTableView.rowHeight = UITableView.automaticDimension
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

extension ActorQuestionSwiftCell: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        let question = _questionArray![(indexPath as NSIndexPath).row]
        
        if question.answer.count > 0 {
            return 180.0
        }
        else{
            return 180.0 + heightForView(_questionArray![(indexPath as NSIndexPath).row].answer, font: UIFont(name: "Lato-Regular", size: 14.0)!, width: (320) - 32.0)
        }
    }
}



extension ActorQuestionSwiftCell: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (_questionArray?.count)!
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "ActorQuestionTableViewCell"
        var cell : ActorQuestionTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ActorQuestionTableViewCell)!
        if cell == nil {
            cell = ActorQuestionTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.likeButtonHandler = self.likeButtonHandler
        
        cell?.optionButtonHandler = self.optionButtonHandler
        
        cell?.setUserData(_questionArray![(indexPath as NSIndexPath).row],userName: userName!,userAge: userAge!, imageUrl: imageUrl!)
        
        return cell!
    }
}
