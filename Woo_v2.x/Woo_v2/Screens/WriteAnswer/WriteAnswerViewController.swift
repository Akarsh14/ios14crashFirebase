//
//  WriteAnswerViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 20/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import IQKeyboardManager
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum ScreenPostType {
    case question
    case answer
    case feedback
    
}

class WriteAnswerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    @IBOutlet weak var feedBackText: UITextField!
    
    
    
     @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var thankqFeedView: UIView!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var selectedQuestionID:NSString = ""
    
    
    var screenType:ScreenPostType = .question
    var starsSelected:Int = -1
    var isOpenedFromSettings:Bool = false
    
    var questionsArray:NSArray = []
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var alertField: UILabel!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var templateButton: UIButton!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    @IBOutlet weak var templateBar: UIView!
    @IBOutlet weak var keyboardBar: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var constraint_y: NSLayoutConstraint!

    
    var isKeyboardSelected:Bool = true
    
    var selectedCell:Int = -1
    
    var maximumAllowedHeightOfTextArea: CGFloat = 75.0
    
    //additional variables ends here
    
    
    @IBOutlet weak var questionBarHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var answerTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardRelatedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextCharacterLimitLabel: UILabel!
    @IBOutlet weak var answerTextView: KMPlaceholderTextView!
    @IBOutlet weak var templateQuestionTable: UITableView!
    
    var expectedKeyBoardHeight:CGFloat = 216
    
    var answerTextCharacterLimitLabelText:String = ""

    var dismissHandler:((Bool, Any)->Void)!
    
    
    var questionData:TargetQuestionModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        templateQuestionTable.register(UINib(nibName:"TemplateAnswerCell", bundle: nil), forCellReuseIdentifier: "TemplateAnswerCell")
        if(screenType == .feedback){
            emailField.delegate = self
            feedBackText.delegate = self
            mobileNumberField.delegate = self
        }
        // Do any additional setup after loading the view.
//        answerTextView.backgroundColor = UIColor.redColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(screenType != .feedback){
        answerTextView.becomeFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == mobileNumberField){
            textField.keyboardType = .numberPad
        }else if (textField == emailField){
            textField.keyboardType = .emailAddress
        }else{
            textField.keyboardType = .default
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.shared().isEnabled = true
        colorTheStatusBar(withColor: UIColor.white)
        postButton.isEnabled = true
        
        switch screenType {
        
        case .question:
            feedBackView.isHidden = true
            headerLabel.text = NSLocalizedString("Write Question", comment:"Write Question")
            questionLabel.isHidden = true
            templateQuestionTable.isHidden = false
            self.questionBarHeightContraint.constant = 54
//            answerTextView.becomeFirstResponder()
            topBarView.backgroundColor = UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            self.manageSelectionOfTabs()
            answerTextCharacterLimitLabelText = "\(AppLaunchModel.sharedInstance().qaQuestionCharLimit)"
            answerTextCharacterLimitLabel.text = answerTextCharacterLimitLabelText
            templateQuestionTable.rowHeight = UITableView.automaticDimension
            templateQuestionTable.estimatedRowHeight = 120.0
            
            
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
            questionLabel.text = ""
            constraint_y.constant = -20
            answerTextView.layoutIfNeeded()
            
            NotificationCenter.default.addObserver(self, selector: #selector(WriteAnswerViewController.keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        case .answer:
            feedBackView.isHidden = true
            questionLabel.isHidden = false
            templateQuestionTable.isHidden = true
            self.questionBarHeightContraint.constant = 0
            answerTextCharacterLimitLabelText = "\(AppLaunchModel.sharedInstance().qaAnswerCharLimit)"
            answerTextCharacterLimitLabel.text = answerTextCharacterLimitLabelText
            
            
            topBarView.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            
            if let questionText = questionData?.question {
                
                let txtQuestion = String(format: "\"%@\"", questionText)
                
//                questionLabel.text = questionText
                
                questionLabel.text = txtQuestion

            }
            answerTextView.placeholder = NSLocalizedString("Respond here...", comment: "")
            
          //  self.perform(#selector(nowShowTextView), with: nil, afterDelay: 0.3)
            NotificationCenter.default.addObserver(self, selector: #selector(WriteAnswerViewController.keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        case .feedback:
            IQKeyboardManager.shared().isEnabled = true
            IQKeyboardManager.shared().isEnableAutoToolbar = true
            thankqFeedView.isHidden = true
            feedBackView.isHidden = false
            questionLabel.isHidden = true
            templateQuestionTable.isHidden = true
            self.questionBarHeightContraint.constant = 0
            answerTextCharacterLimitLabel.isHidden = true
            answerTextCharacterLimitLabel.text = ""
//            self.perform(#selector(nowShowTextView), with: nil, afterDelay: 0.3)
//            topBarView.backgroundColor = UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)

            headerLabel.text = NSLocalizedString("Feedback", comment:"feedback screen header text")
            answerTextView.placeholder = NSLocalizedString("\"Your feedback/suggestion is valuable to us. We hope it will make Woo app more awesome.\"", comment: "")
            submitButton.layer.shadowColor = UIColor.darkGray.cgColor
            submitButton.layer.shadowOpacity = 0.4
            submitButton.layer.shadowRadius = 3.0
            submitButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            feedBackText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
            questionLabel.text = ""
            constraint_y.constant = -20
            answerTextView.layoutIfNeeded()
            

        }
        super.viewWillAppear(animated)

//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)


      
       
        //Notification kRemoveViewWithKeyboard is never posted
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRemoveViewWithKeyboard), object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(removeView), name: NSNotification.Name(rawValue: kRemoveViewWithKeyboard), object: nil)
        
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (emailField.text?.count) > 0 && (feedBackText.text?.count)>0{
            self.submitButton.backgroundColor = UIColor .red
        }else{
            //BBBBBB
            self.submitButton.backgroundColor = UIColor(hexString: "BBBBBB")
        }
    }

    
    @objc func removeView() {
        self.backButtonTapped(backButton)
    }
    
    @objc func dimissTheScreen()
    {
        dismiss(animated: false, completion: nil)
    }
    
    func manageSelectionOfTabs() {
        if self.isKeyboardSelected == true {
            answerTextView.placeholder = NSLocalizedString("Ask something worthy of an awesome answer...", comment: "")
            keyboardButton.setImage(UIImage(named: "TextSelectedImage"), for: UIControl.State())
            templateButton.setImage(UIImage(named: "templateDeselctedImage"), for: UIControl.State())
            templateBar.isHidden = true
            keyboardBar.isHidden = false
            keyboardButton.isUserInteractionEnabled = false
            templateButton.isUserInteractionEnabled = true
            
        }else{
            answerTextView.placeholder = NSLocalizedString("Select from the list of template questions below one to ask one.", comment: "")
            keyboardButton.setImage(UIImage(named: "textDeselectedImage"), for: UIControl.State())
            templateButton.setImage(UIImage(named: "templateSelectedImage"), for: UIControl.State())
            keyboardBar.isHidden = true
            templateBar.isHidden = false
            keyboardButton.isUserInteractionEnabled = true
            templateButton.isUserInteractionEnabled = false
            self.fetchAndUpdateTemplateQuestions()

        }
    }
    
    
    func fetchAndUpdateTemplateQuestions(){
        
        if TemplateQuestions.getAllTemplateQuestions() != nil {
            questionsArray = TemplateQuestions.getAllTemplateQuestions()
        }
        
        
        if questionsArray.count > 0{
            templateQuestionTable.reloadData()
        }
    }
    
    //MARK: Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if questionsArray.count > 0 {
            return questionsArray.count
            
        }
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "TemplateAnswerCell"
        let cellObj:TemplateAnswerCell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TemplateAnswerCell)!

        if let questionObj:TemplateQuestions = (self.questionsArray.object(at: (indexPath as NSIndexPath).row) as! TemplateQuestions) {
            cellObj.setDataOnViewWithQuestionText(questionObj.templateQuestion as NSString, isSelected: (((indexPath as NSIndexPath).row == selectedCell) ? true : false))

        }
        
        return cellObj
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let questionObj:TemplateQuestions = (self.questionsArray.object(at: (indexPath as NSIndexPath).row) as! TemplateQuestions) {
            
            selectedCell = (indexPath as NSIndexPath).row
            answerTextView.text = questionObj.templateQuestion
            selectedQuestionID = questionObj.qid.stringValue as NSString
            templateQuestionTable.reloadData()
            self.textViewDidChange(answerTextView)
            
        }

    }
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        answerTextView.resignFirstResponder()

//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject){
        if !self.isOpenedFromSettings {
            UserDefaults.standard.set(Date(timeIntervalSinceReferenceDate: kCFAbsoluteTimeIntervalSince1970), forKey: kRemindMePopupTimestampV3)
            UserDefaults.standard.synchronize()
            WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonTapped(_ sender: AnyObject) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
        }else{
            if (emailField.text?.count == 0){
                alertField.text = "*   Field required"
            }else{
                if (emailField.text?.count) > 0 && (feedBackText.text?.count)>0{
                    if (isValidEmail(testStr: emailField.text!)){
                        hitFeedbacktoServer()
                    }else{
                        alertField.text = "*   Email ID doesn't seems right"
                    }
                }else{
                    return
                }
                
            }
        
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func hitFeedbacktoServer(){
        if (!self.thankqFeedView.isHidden){
            if !self.isOpenedFromSettings {
                UserDefaults.standard.set(Date(timeIntervalSinceReferenceDate: kCFAbsoluteTimeIntervalSince1970), forKey: kRemindMePopupTimestampV3)
                UserDefaults.standard.synchronize()
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            progressView.startAnimating()
            AppSettingsApiClass.sendFeedback(toServer: feedBackText.text, andNumberOfStars: 0, andEmail: emailField.text, andPhoneNumber: mobileNumberField.text) { (sucess, response, status) in
                self.progressView.stopAnimating()
                if (sucess){
                    DispatchQueue.main.async {
                        self.thankqFeedView.isHidden = false
                        self.submitButton.setTitle("OK", for: .normal)
                        self.submitButton.backgroundColor = UIColor .red
                    }
                }else{
                    showSnackBar("Please try again.")
                }
            }
        }
        
    }

    
    @IBAction func keyboardButtonTapped(_ sender: AnyObject) {
        
        self.isKeyboardSelected = true
        self.manageSelectionOfTabs()
        answerTextView.becomeFirstResponder()
    }
    @IBAction func templateButtonTapped(_ sender: AnyObject) {
        
        self.isKeyboardSelected = false
        self.manageSelectionOfTabs()
        answerTextView.resignFirstResponder()
//        answerTextView.setContentOffset(CGPointMake(0, answerTextView.contentSize.height - answerTextViewHeightConstraint.constant), animated: false)
    }
    @objc fileprivate func keyboardWasShown(_ notificationObject:Notification){
        self.view.layoutIfNeeded()
        let keyboardSize:CGSize = ((notificationObject as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        let heightInInt:Int = Int(keyboardSize.height)
        let widthInInt:Int = Int(keyboardSize.width)
        print("heightInInt \(heightInInt)")
        
        let height:Int = min(heightInInt,widthInInt)
        expectedKeyBoardHeight = CGFloat(height)
        
        self.view.layoutIfNeeded()
        if expectedKeyBoardHeight > 216 {
            keyboardRelatedViewHeightConstraint.constant = expectedKeyBoardHeight - safeAreaBottom
        }
        else{
            keyboardRelatedViewHeightConstraint.constant = 216
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        }) 
        print("self.view.bounds.size.height \(self.view.bounds.size.height)")
        maximumAllowedHeightOfTextArea = self.view.bounds.size.height - (CGFloat(heightInInt) + 110)
        print("maximumAllowedHeightOfTextArea \(maximumAllowedHeightOfTextArea)")
        
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        
        DispatchQueue.main.async{
            self.answerTextView.resignFirstResponder()
            
            switch self.screenType {
            case .question:
                
                if self.navigationController?.viewControllers.count > 0{
                    // WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
                
            case .answer:
                if self.navigationController?.viewControllers.count > 0{
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                    self.navigationController?.popViewController(animated: true)
                }
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                //self.dismiss(animated: true, completion: nil)
                
            case .feedback:
                if !self.isOpenedFromSettings {
                    UserDefaults.standard.set(Date(timeIntervalSinceReferenceDate: kCFAbsoluteTimeIntervalSince1970), forKey: kRemindMePopupTimestampV3)
                    UserDefaults.standard.synchronize()
                    WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                }
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    @IBAction func postAnswer(_ sender: AnyObject) {

        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }

        let trimmedString = answerTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (trimmedString.count < 1) {
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("Please enter some text.", comment: "Please enter some text."), withActionTitle: "", withDuration: 2.0)
            return
        }
        
        switch screenType {
        case .question:
            postQuestionAndUpdateLocalDB()
            
            
        case .answer:
            backButton.isEnabled = false
            postButton.isEnabled = false
            postButton.alpha = 0.5

            PostAnswerApiClass.postAnswer(forQuestionID: (questionData?.questionId)!, andAnswer: trimmedString) { (success, response) in
                

                if success{
                    self.questionData?.answer = trimmedString
                    let seconds: TimeInterval = Date().timeIntervalSince1970
                    let  answerDate:Double =  seconds*1000
                    self.questionData?.answerTime = UInt64(answerDate)
                    
                    // Srwve Event
                    (Utilities.sharedUtility() as! Utilities).sendSwrveEvent(withScreenName: "DC_PostAnswer", withEventName: "3-Discovery.DiscoverCards.DC_PostAnswer")
                    
                }
                
                self.postButton.isEnabled = true
                self.postButton.alpha = 1.0
                self.answerTextView.resignFirstResponder()
                self.navigationController?.popViewController(animated: true)

                if response != nil{
                    self.dismissHandler(success,response!)
                    
                }
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)

//                self.dismiss(animated: true, completion: {
                
               // })
            }
            
        case .feedback:
            
            postFeedback()
            // nothing to do here
        }
        
        
    }
    
    
    func postFeedback(){
        
        postButton.isEnabled = false
        postButton.alpha = 0.5
        
        if answerTextView?.text.count > 0 {
            let window:UIWindow = UIApplication.shared.keyWindow!
            let contactForm:PostFeedbackContactView = Bundle.main.loadNibNamed("PostFeedbackContactView", owner: window.rootViewController, options: nil)?.first as! PostFeedbackContactView
            contactForm.loadContactScreen()
            contactForm.feedBackText = (answerTextView?.text)!
            contactForm.contactDetailsHandler = {(detailsSubmitted:Bool) in
//                self.dismiss(animated: true, completion: {
//                    // nothing to do here.
//                })
                self.navigationController?.popViewController(animated: true)
                WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: true)
                UserDefaults.standard.set(true, forKey: kUserSubmittedV3Feedback)
                UserDefaults.standard.synchronize()
                
                self.postButton.isEnabled = true
                self.postButton.alpha = 1.0
            }
        }
    }
    
    func postQuestionAndUpdateLocalDB() {
        
        postButton.isEnabled = false
        postButton.alpha = 0.5
        
        QuestionAnswerAPIClass.postQuestion(forWooID: (UserDefaults.standard.object(forKey: kWooUserId) as?String), withText: answerTextView.text, preselectedQuestionID: String(selectedQuestionID)) {
            
            (successFlag, response, statusCode) in
            if successFlag == true{
                
                // Srwve Event
                //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "Me_MyQuestions", withEventName: "3-MeSection.Me_MyQuestions.MMQ_CreateQuestion_Post")

                //self.navigationController?.popViewController(animated: true)
                
                self.backButtonTapped(self)
                
            }else{
                self.postButton.isEnabled = true
                self.postButton.alpha = 1.0
                
            }
        }
    }
    
    @objc fileprivate func nowShowTextView(){
        answerTextView.becomeFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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


extension WriteAnswerViewController:UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {


        
        let trimmedString = textView.text.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        if trimmedString.count>0 {
            postButton.isEnabled = true
        }
        
        var currentTextCount = 0
        
        if screenType != .feedback {
            currentTextCount = Int(answerTextCharacterLimitLabelText)! - trimmedString.count
        }
        
        answerTextCharacterLimitLabel.text = "\(currentTextCount)"
        self.view.layoutIfNeeded()
        
        var heightForAnswerTextView = self.heightForView(textView.text, font: UIFont(name: "Lato-Medium", size: 18.0)!, width: textView.frame.size.width) + 18
        
        if heightForAnswerTextView > 75 {
            if heightForAnswerTextView > maximumAllowedHeightOfTextArea {
                heightForAnswerTextView = maximumAllowedHeightOfTextArea
            }
            self.answerTextViewHeightConstraint.constant = heightForAnswerTextView
            print("self.answerTextViewHeightConstraint.constant \(self.answerTextViewHeightConstraint.constant)")
            textView.isScrollEnabled = true
        }
        else{
            self.answerTextViewHeightConstraint.constant = 75
            textView.isScrollEnabled = false
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        }) 
    }

    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        switch screenType {
        
        case .question:
            if isKeyboardSelected == false {
                isKeyboardSelected = true
                self.manageSelectionOfTabs()
            }
        case .answer:
            break
        case .feedback:
            break
        default:
            break
            
        }
        
        return true
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        

        selectedCell = -1
        if text.count > 0 {
            
             let totalTextCount = textView.text.count + text.count
            
            switch screenType {
                
            case .question:
                if totalTextCount > AppLaunchModel.sharedInstance().qaQuestionCharLimit || text == "\n"{
                    return false
                }
                else{
                    return true
                }
            case .answer:
                if totalTextCount > AppLaunchModel.sharedInstance().qaAnswerCharLimit || text == "\n"{
                    return false
                }
                else{
                    return true
                }
            case .feedback:
                return true
            }
            

        }
        else{
            return true
        }
        
    }
}
