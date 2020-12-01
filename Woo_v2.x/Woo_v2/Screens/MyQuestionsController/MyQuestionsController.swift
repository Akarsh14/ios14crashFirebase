//
//  MyQuestionsController.swift
//  Woo_v2
//
//  Created by Vaibhav Gautam on 10/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
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


class MyQuestionsController: BaseClassViewController {

    
    @IBOutlet weak var questionTableViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var questionFloatingButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointerImage: UIImageView!
    @IBOutlet weak var emptyScreenUserImageView: UIView!
    
    @IBOutlet weak var questionsTableView: UITableView!
    
    var questionsArray:NSMutableArray = []
    
    var selectedQuestion:MyQuestions?
    
    var userImageView: MatchedUsersImageView?
    
    var isPresentedFromMyProfile:Bool = false
    
    let profileAction:ProfileActionManager = ProfileActionManager()
    
    var currentUserDetail:ProfileCardModel?
    
    var crushText:String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        questionsTableView.register(UINib(nibName:"QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
        questionsTableView.rowHeight = UITableView.automaticDimension
        questionsTableView.estimatedRowHeight = 120.0
    }

    @objc func reloadQuestionAnswersView()
    {
        if questionsArray.count > 0 {
            questionsArray = []
        }
        if MyQuestions.getAllMyQuestions() != nil {
            
            questionsArray = MyQuestions.getAllMyQuestions() as NSMutableArray
            questionsTableView.isHidden = false
        }else{
            questionsTableView.isHidden = true
        }
        questionsTableView.reloadData()
        addEmptyScreenUserImageView()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addEmptyScreenUserImageView() -> Void {
        if userImageView == nil {
            userImageView = MatchedUsersImageView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 120))
            userImageView!.backgroundColor = UIColor.clear
            var rightImageUrl = ""
            
            if DiscoverProfileCollection.sharedInstance.myProfileData != nil {
                if DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum != nil &&
                    DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.count() > 0 {
                    rightImageUrl = NSString.init(format: "%@?width=%d&height=%d&url=%@", kImageCroppingServerURL,Utilities().getImageSize(forPoints: kCircularImageSize),Utilities().getImageSize(forPoints: kCircularImageSize),Utilities().encode(fromPercentEscape: DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl())) as String
                }
            }
            userImageView!.setLeftUserImage("ic_me_my_questions_big", getFromUrl: false, andRightUserImage: rightImageUrl as String, getFromURl: true)
            emptyScreenUserImageView.addSubview(userImageView!)
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.myQuestions, animated: false)
        self.navBar?.setTitleText("My Questions")
        self.navigationController?.isNavigationBarHidden = true;
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(MyQuestionsController.backButton))
    }
    
    
    @objc func backButton(){
        
        if isPresentedFromMyProfile == true{
            DiscoverProfileCollection.sharedInstance.collectionMode = CollectionMode.my_PROFILE
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //Add observer that reloads view once answers have been fetched
        NotificationCenter.default.addObserver(self, selector: #selector(reloadQuestionAnswersView), name: NSNotification.Name(rawValue: kAnswersFetched), object: nil)

        //SwipeBack
        
        if let nav = self.navigationController{
            nav.swipeBackEnabled = true
        }
        
        
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)

        if questionsArray.count > 0 {
            questionsArray = []
        }
        if MyQuestions.getAllMyQuestions() != nil {
            
            questionsArray = MyQuestions.getAllMyQuestions() as NSMutableArray
            questionsTableView.isHidden = false
        }else{
            questionsTableView.isHidden = true
        }
        questionsTableView.reloadData()
        addEmptyScreenUserImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.questionsArray.count > 0 {
            questionsTableView.addSubview(questionFloatingButton)
        }else{
            self.view.addSubview(questionFloatingButton)
        }
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top > 0){
                questionTableViewTopConstraint.constant = 64.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAnswersFetched), object: nil)
    }
    
    
    @IBAction func postQuestionButtonTapped(_ sender: AnyObject) {
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }
    
        if (AppLaunchModel.sharedInstance().questionsAskedToday >= AppLaunchModel.sharedInstance().qaQuestionLimit){

            let maxLimitAlert:UIAlertController = UIAlertController(title: "", message:NSLocalizedString("You have exceeded maximum number of questions that can be asked. Please delete some question to post a new one.", comment:"Dismiss" ) , preferredStyle: .alert)
            
            let dismissAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Dismiss",     comment: "Dismiss"), style: .default, handler: { (action) in
                

            })
            
            maxLimitAlert.addAction(dismissAction)
            
            self.present(maxLimitAlert, animated: true, completion: {
                // nothing to do here
            })

            return
        }
        
        
        self.performSegue(withIdentifier: "MyQuestionToTypeQuestionSegue", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "MyQuestionToTypeQuestionSegue") {
            let controllerObj = segue.destination as! WriteAnswerViewController
            controllerObj.screenType = .question
        }
        else if(segue.identifier == "MyQuestionsToMyAnswersSegue"){
            let controllerObj = segue.destination as! MyAnswersViewController
            controllerObj.relatedQuestion = selectedQuestion
            controllerObj.dismissHandler = { (currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel?) in
                if userProfile != nil {
                    self.currentUserDetail = userProfile
                    self.crushText = crushString
                    
                    if needToTakeAction == .Like{
                        self.likeUser()
                    }
                    else if needToTakeAction == .CrushSent{
                        self.sendCrush()
                    }
                }
            }
            
        }
        else if (segue.identifier == kPushToChatFromQuestions) {
            let chatViewControllerObj: NewChatViewController  =  segue.destination  as! NewChatViewController
            let model = sender as! MyMatches
            chatViewControllerObj.myMatchesData = model
            chatViewControllerObj.isAutomaticallyPushedFromChat = true
            chatViewControllerObj.parentView = .questionCard
        }
    }
    
    func sendCrush(){
        performActionForType(.CrushSent)
}
    
    func likeUser(){
        performActionForType(.Like)
    }
    
    func performActionForType(_ actionType:PerformAction){
        
        profileAction.currentViewType = .MyQuestions
        profileAction.crushText = self.crushText
        
        profileAction.reloadHandler = {(indexPath:IndexPath) in
        }
        profileAction.performSegueHandler = { (matchedUserDataFromDb:MyMatches) in
            
            if (Utilities().isChatRoomPresent(in: self.navigationController) == false){
                if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                }else{
                self.performSegue(withIdentifier: kPushToChatFromQuestions, sender: matchedUserDataFromDb)
                }
            }
        }
        
        switch actionType {
        case .Like:
                profileAction.likeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            break
            
        case .CrushSent:
                profileAction.crushActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            break
            
        default:
            break
        }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }

    
    //MARK: Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if questionsArray.count > 0 {
            questionsTableView.isHidden = false
            questionsTableView.addSubview(questionFloatingButton)
            
            return questionsArray.count
        }
        questionsTableView.isHidden = true
        self.view.addSubview(questionFloatingButton)
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "QuestionCell"
        let cellObj:QuestionCell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? QuestionCell)!
        
        if let questionObj:MyQuestions = (self.questionsArray.object(at: (indexPath as NSIndexPath).row) as! MyQuestions) {
            
            cellObj.setDataOnCellFromModelObj(questionObj)

            cellObj.deleteAction = {(questionObj:MyQuestions) in
                
                if !Utilities().reachable() { // If there is no internet connection
                    
                    Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
                    return
                }
                
                let deleteAlert:UIAlertController = UIAlertController(title: NSLocalizedString("Delete question?", comment:"Delete question actionsheet text" ), message:"" , preferredStyle: .actionSheet)
                
                let deleteAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete button text"), style: .default, handler: { (action) in
                    
                    if self.questionsArray.count > 0 {
                        
                        self.questionsArray = []
                        
                    }
                    
                    QuestionAnswerAPIClass.deleteQuestion(withQuestionID: String(questionObj.qid as! Int), withDeletionCompletionHandler:
                    { (completion) in

                        if MyQuestions.getAllMyQuestions() != nil{
                            print(MyQuestions.getAllMyQuestions().count)
                            self.questionsArray = MyQuestions.getAllMyQuestions() as NSMutableArray
                            
                        }
                        
                        self.questionsTableView.reloadData()
                    })
                    
                })
                
                let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button text"), style: .cancel, handler: { (action) in
                    
                })
                
                deleteAlert.addAction(deleteAction)
                deleteAlert.addAction(cancelAction)
                
                self.present(deleteAlert, animated: true, completion: {
                    // nothing to do here
                })
                
                
            }
            
        }
        
        return cellObj
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        
        if !Utilities().reachable() { // If there is no internet connection
            
            Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
            return
        }

        if self.questionsArray.count <= 0 {
            return
        }
        if let questionObj:MyQuestions = (self.questionsArray.object(at: indexPath.row) as? MyQuestions) {
            
            selectedQuestion = questionObj
            
            if Int(truncating: questionObj.totalAnswers) < 1 {
//                show alert
                var noAnswerAlert:UIAlertController = UIAlertController()
                let dismissAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                })
                
                
                //var moreInfoAction:UIAlertAction = UIAlertAction()
                
                if (BoostModel.sharedInstance().checkIfUserNeedsToPurchase() && (indexPath as NSIndexPath).row == 0){
                    // If boost not purchased & selected row is first
                    noAnswerAlert = UIAlertController(title: NSLocalizedString("No answers yet?", comment:""), message:NSLocalizedString("We will let you know as soon as you get an answer.", comment:"") , preferredStyle: .alert)
                    noAnswerAlert.addAction(dismissAction)
                }else{ // If boost Purchased
                    noAnswerAlert = UIAlertController(title: NSLocalizedString("No answers yet?", comment:""), message:NSLocalizedString("We will let you know as soon as you get an answer.", comment:"") , preferredStyle: .alert)
                    noAnswerAlert.addAction(dismissAction)
                }
                self.present(noAnswerAlert, animated: true, completion: {
                    // nothing to do here
                })
            }
            else{
                MyAnswers.markAllAsnwersAsRead(forQuestionID: questionObj.qid.int64Value,withInsertionCompletionHandler: {
                    (completion) in
                    MyQuestions.markAllAnswersRead(forQuestionID: questionObj.qid.int64Value,withInsertionCompletionHandler: {
                        (completion) in
                        
                        self.performSegue(withIdentifier: "MyQuestionsToMyAnswersSegue", sender: self)
                    })
                })
            }
        }
    }
}
