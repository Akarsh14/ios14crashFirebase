//
//  WizardQnAViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 14/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class WizardQnAViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var dummyAnswerTextLabel: UILabel!
    @IBOutlet weak var dummyQuestionTextLabel: UILabel!
    @IBOutlet weak var selectQuestionsButton: UIButton!
    @IBOutlet weak var dummyQuestionAnswerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var questionAnswerTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    fileprivate var profileData : MyProfileModel?
    fileprivate var isCloseTapped = false
    fileprivate var customLoader:WooLoader?
    var dummyQuestionModel:TargetQuestionModel?
    var cropperIsAlreadyOpen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileData = DiscoverProfileCollection.sharedInstance.myProfileData
        setupBottomArea()
        setDataForDummyQuestionAnswerLabel()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(WizardQnAViewController.updateQuestionAnswerCell(_:)),
                                               name: NSNotification.Name(rawValue: kUpdateEditProfileBasedOnQuestionAnswerChanges),
                                               object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc fileprivate func updateQuestionAnswerCell(_ notificationObject:Notification){
        if let profile = notificationObject.userInfo?["myProfile"] as? MyProfileModel {
            self.profileData = profile
        }
        setDataForDummyQuestionAnswerLabel()
    }
    
    private func setupBottomArea(){
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            nextButton.setTitle("DONE", for: .normal)
        }
        else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            backButton.isHidden = true
        }
        counterLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
    }

    private func setDataForDummyQuestionAnswerLabel(){
        if profileData?.myQuestionsArray.count ?? 0 > 0{
            questionAnswerTableView.isHidden = false
            questionAnswerTableView.reloadData()
            dummyQuestionAnswerView.isHidden = true
            if profileData?.myQuestionsArray.count ?? 0 >= Int(AppLaunchModel.sharedInstance()?.wooQuestionLimit ?? 3){
                plusButton.isHidden = true
            }
            else{
                plusButton.isHidden = false
            }
        }
        else{
            questionAnswerTableView.isHidden = true
            plusButton.isHidden = true
            dummyQuestionAnswerView.isHidden = false
        if dummyQuestionModel != nil{
            dummyQuestionTextLabel.text = dummyQuestionModel?.question
            dummyAnswerTextLabel.text = dummyQuestionModel?.hintText
        }
        }
    }

    private func showWizardCompleteView(_ isCompleted:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func checkIfFlowIsComplete() -> Bool{
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            return true
        }
        else{
            return false
        }
    }
    
    private func showWooLoader(){
        customLoader?.removeFromSuperview()
        customLoader = nil
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        customLoader?.shouldShowWooLoader = false
        
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    private func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
        }, completion: { (true) in
            self.customLoader?.stopAnimation()
            self.customLoader?.removeFromSuperview()
        })
        
    }
    
    private func checkIfToShowDiscoverOrMe(){
        if DiscoverProfileCollection.sharedInstance.discoverModelCollection.count > 0{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        else{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
        }
    }
    
    
    private func sendDataToServer(){
        let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        
        var _college : [NSMutableDictionary] = []
        _college.append((profileData?.selectedCollege().dictionarify())!)
        myProfileDictionary["college"] = _college
        //degree - 4
        var _degree : [NSMutableDictionary] = []
        _degree.append((profileData?.selectedDegree().dictionarify())!)
        myProfileDictionary["degree"] = _degree
        //company - 5
        var _company : [NSMutableDictionary] = []
        _company.append((profileData?.selectedCompany().dictionarify())!)
        myProfileDictionary["company"] = _company
        //designation - 6
        var _designation : [NSMutableDictionary] = []
        _designation.append((profileData?.selectedDesignation().dictionarify())!)
        myProfileDictionary["designation"] = _designation
        
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary))!)
        
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
            let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is WizardWorkViewController
            if !currenViewControllerIsSelf{
                return
            }
            self.hideWooLoader()
            if self.isCloseTapped{
                self.isCloseTapped = false
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                    
                    if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                        self.showWizardCompleteView(false)
                    }
                    else{
                        self.checkIfToShowDiscoverOrMe()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
            }
            else{
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
            }
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Work_Close")
        
        if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
            self.showWizardCompleteView(false)
        }
        else{
            if self.checkIfFlowIsComplete(){
                self.showWizardCompleteView(true)
            }
            else{
                self.checkIfToShowDiscoverOrMe()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
        
        if(WizardScreensCalculator.sharedInstance.currentWizardScreen == 1){
            cropperIsAlreadyOpen = true
        }
        
        if WizardScreensCalculator.sharedInstance.isCropperVisible == true && cropperIsAlreadyOpen == true {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
           
            WizardScreensCalculator.sharedInstance.isCropperVisible = false
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
//        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func nextButtonClicked(_ sender: Any) {
        isCloseTapped = false
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if self.checkIfFlowIsComplete(){
            self.showWizardCompleteView(true)
        }
        else{
            WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
        }
    }
    
    @IBAction func plusButtonClicked(_ sender: Any) {
        self.moveToQuestionsSelectionScreen(-1)
    }
    @IBAction func selectQuestions(_ sender: Any) {
        let buttonObject = sender as? UIButton
        var firebaseEventString = ""
        if buttonObject?.tag == 100{
            firebaseEventString = "QnA_PCW_EMPTY_STATE_LAYOUT_TAP"
        }
        else{
            firebaseEventString = "QnA_PCW_EMPTY_STATE_LAYOUT_BUTTON_TAP"
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: firebaseEventString)
        self.moveToQuestionsSelectionScreen(-1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileData?.myQuestionsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "QnADataCell"
        
        let array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
        let cell : QnADataCell? = array?.first as? QnADataCell
        cell?.updateViewBasedOnData(profileData?.myQuestionsArray[indexPath.row] ?? TargetQuestionModel())
        cell?.backgroundViewTopConstraint.constant = 10
        cell?.questionTextLabelTopConstraint.constant = 27
        cell?.tag = indexPath.row
        cell?.buttonTappedHandler = {(index) in
            self.userSelection(questionPosition: index)
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    fileprivate func moveToQuestionsSelectionScreen(_ position:Int){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let QNAScreen : QuestionsViewController = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
        QNAScreen.myProfileModel = self.profileData
        if position >= 0{
        if let selectedQuestions = self.profileData?.myQuestionsArray[position]{
            
            QNAScreen.setReplacementQuestion(question: selectedQuestions, type: .replace)
        }
        }
        self.navigationController?.pushViewController(QNAScreen, animated: true)
    }
    
    fileprivate func moveToAnswerUpdateScreen(_ position:Int){
        let QNAAnswrScreen : QNAanswersScreenViewController = QNAanswersScreenViewController(nibName: "QNAanswersScreenViewController", bundle: Bundle.main)
        QNAAnswrScreen.myProfileModel = self.profileData
        if let selectedQuestions = self.profileData?.myQuestionsArray[position]{
            QNAAnswrScreen.setAnswerTypeWithData(answerType: .update, question:selectedQuestions)
        }
        self.navigationController?.pushViewController(QNAAnswrScreen, animated: true)
    }
    
    func userSelection(questionPosition:Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (profileData?.myQuestionsArray.count ?? 0 > 0) {
            alert.addAction(UIAlertAction(title: "Replace this question", style: .default, handler: { (action) in
                self.moveToQuestionsSelectionScreen(questionPosition)
            }))
            
            alert.addAction(UIAlertAction(title: "Update my answer", style: .default, handler: { (action) in
                self.moveToAnswerUpdateScreen(questionPosition)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            self.moveToQuestionsSelectionScreen(-1)
        }
    }
}
