//
//  QNAanswersScreenViewController.swift
//  QNA
//
//  Created by Kuramsetty Harish on 11/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//


enum ansType {
    case new
    case update
    case replace
}

import UIKit
class QNAanswersScreenViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var btnPost: UIButton!
    private var answerType:ansType = .new
    private var alreadySelectedQuestion:TargetQuestionModel?
    private var answerText = ""
    private var isUpdate = false
    private let minCharacter = 1
    private var question: TargetQuestionModel?
    var myProfileModel:MyProfileModel?
    @IBOutlet weak var placeHolderLabel: UILabel!
    fileprivate var customLoader :WooLoader?
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var btnSpaceWarning: NSLayoutConstraint!
    
    var questionAddedHandler:((MyProfileModel)->Void)?
    
    var maxCharacter:Int{
        if let maxChar = AppLaunchModel.sharedInstance()?.wooAnswerCharLimit {
            return maxChar
        }else{
            return 300
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        placeHolderLabel.text = String(describing: maxCharacter)
        textView.delegate = self
        if (answerType == .new){
            btnPost.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5), for: .normal)
        }else if(answerType == .update){
            if let answer = question?.answer{
                textView.text = answer
                updateLimitCount()
                btnPost.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1), for: .normal)
            }
        }else{
            btnPost.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5), for: .normal)
        }
        
        if let title = question?.question{
            questionTitle.text = title
        }
        
        if let hinttxt = question?.hintText{
            textView.placeholder = hinttxt
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        colorTheStatusBar(withColor: UIColorHelper.color(fromRGB: "#75C4DB", withAlpha: 1.0))
    }
    
    @IBAction func btnPost(_ sender: Any) {
        if(answerText.count > 0 ){
            self.handleAnswer(type: answerType)
        }else if (answerType == .update){
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setAnswerTypeWithData(answerType:ansType, question:TargetQuestionModel){
        self.answerType = answerType
        self.question = question
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateLimitCount()
        answerText = textView.text
        if (textView.text.count >= minCharacter){
            self.btnPost.isEnabled = true
           btnPost.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1), for: .normal)
        }else{
            self.btnPost.isEnabled = false
           btnPost.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5), for: .normal)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if (keyboardSize.size.height > 100) {
                let extraHeight:CGFloat = isNotchPhone() ? -23 : 15
                btnSpaceWarning.constant = keyboardSize.height+extraHeight
            }
        }
    }
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setReplacementQuestion(question: TargetQuestionModel){
        self.alreadySelectedQuestion = question
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var text = text
        updateLimitCount()
        let finalTextLength: Int = textView.text.count + text.count
        if range.location == 0 && (text == " ") {
            return false
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            return false
        } else if finalTextLength > maxCharacter && text.count > 0 {
            let pendingTextLength = maxCharacter - textView.text.count
            if pendingTextLength != 0 && Int(pendingTextLength) < text.count {
                text = (text as NSString).substring(to: pendingTextLength)
                textView.text = "\(String(describing: textView.text))\(text)"
                updateLimitCount()
            }
            return false
        }
        return true
    }
    
    func updateLimitCount() {
        let diff: Int = maxCharacter - textView.text.count
        let limitText = ("\(diff)")
        placeHolderLabel.text = limitText
    }
    
    func showWooLoader() {
        customLoader = WooLoader(frame: self.view.frame)
        customLoader!.startAnimation(on: self.view, withBackGround: true)
    }
    
    func removeWooLoader() {
        if customLoader != nil {
            customLoader!.removeFromSuperview()
            customLoader = nil
        }
    }
    
    // MARK: - API Handling
    func handleAnswer(type:ansType){
        answerText = answerText.condenseWhitespace()
        if(type == .replace){
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "QnA_REPLACE_QUESTION_POST")
            replaceQuestion()
        }else if(type == .update){
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "QnA_UPDATE_ANSWER_POST")
            updateAnswer()
        }else{
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "" , withEventName: "QnA_ANSWER_POST")
            addNewAnswer()
        }
    }
    
    
    
    func replaceQuestion(){
        self.showWooLoader()
        QuestionAnswerAPIClass.updateQuestion(self.alreadySelectedQuestion?.questionId as NSNumber?, withNew: self.question?.questionId as NSNumber?, withText: answerText) { (isSuccess, response, status) in
            self.removeWooLoader()
            if(isSuccess){
                var position = 0
                if let addedQuestions = self.myProfileModel?.myQuestionsArray{
                    if let row = addedQuestions.firstIndex(where: {$0.questionId == self.alreadySelectedQuestion!.questionId}){
                        self.myProfileModel?.myQuestionsArray.remove(at: row)
                        position = row
                    }
                }
                if  let questions = response as? NSDictionary{
                    if let questionModel = questions["wooQuestionAnswerDto"]{
                    let model = TargetQuestionModel(data: questionModel as? NSDictionary ?? NSDictionary())
                    self.myProfileModel?.myQuestionsArray.insert(model, at: position)
                    let profileDataDict:[String: MyProfileModel] = ["myProfile": self.myProfileModel ?? MyProfileModel()]
                NotificationCenter.default.post(name: Notification.Name(kUpdateEditProfileBasedOnQuestionAnswerChanges), object: nil, userInfo: profileDataDict)
                self.navigationController?.popViewControllers(viewsToPop: 2)
                    }
                    else{
                        showSnackBar(NSLocalizedString("Generic_error", comment:"error"))
                    }
                }
                else{
                    showSnackBar(NSLocalizedString("Generic_error", comment:"error"))
                }
            }else{
                showSnackBar(NSLocalizedString("Generic_error", comment:"error"))
            }
        }
    }
    
    func updateAnswer(){
        self.showWooLoader()
        QuestionAnswerAPIClass.updateAnswer(question?.answerId as NSNumber?, withText: answerText) { (isSuccess, response, status) in
            self.removeWooLoader()
            if(isSuccess){
                self.question?.answer = self.answerText
                let profileDataDict:[String: MyProfileModel] = ["myProfile": self.myProfileModel ?? MyProfileModel()]
                NotificationCenter.default.post(name: Notification.Name(kUpdateEditProfileBasedOnQuestionAnswerChanges), object: nil, userInfo: profileDataDict)
                self.navigationController?.popViewController(animated: true)
            }else{
                showSnackBar("Generic_error".localizedString())
            }
        }
    }
    
    
    func addNewAnswer(){
        self.showWooLoader()
        QuestionAnswerAPIClass.postAnswer(question?.questionId as NSNumber?, withText: answerText) { (isSuccess, response, status) in
            if(isSuccess){
                if  let questions = response as? NSDictionary{
                    if let questionModel = questions["wooQuestionAnswerDto"]{
                        self.removeWooLoader()
                        let model = TargetQuestionModel(data: questionModel as? NSDictionary ?? NSDictionary())
                        self.myProfileModel?.myQuestionsArray.append(model)
                        let profileDataDict:[String: MyProfileModel] = ["myProfile": self.myProfileModel ?? MyProfileModel()]
                        NotificationCenter.default.post(name: Notification.Name(kUpdateEditProfileBasedOnQuestionAnswerChanges), object: nil, userInfo: profileDataDict)
                        
                        if self.myProfileModel?.myQuestionsArray.count ?? 0 < Int(AppLaunchModel.sharedInstance()?.wooQuestionLimit ?? 3){
                            showSnackBar("Answer posted")
                            if let handler = self.questionAddedHandler{
                                handler(self.myProfileModel ?? MyProfileModel())
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                        else{
                            self.navigationController?.popViewControllers(viewsToPop: 2)
                        }
                    }
                    else{
                        self.updateAnswer()
                    }
                }
                else{
                    self.removeWooLoader()
                    showSnackBar(NSLocalizedString("Generic_error", comment:"error"))
                }
            }else{
                self.removeWooLoader()
                showSnackBar("Generic_error".localizedString())
            }
        }
    }
}

