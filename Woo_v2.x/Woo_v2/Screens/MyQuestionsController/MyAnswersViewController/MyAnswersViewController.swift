//
//  MyAnswersViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 14/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MyAnswersViewController: BaseClassViewController {

    @IBOutlet weak var myAnswersTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var myAnswersTableView: UITableView!
    
    var relatedQuestion:MyQuestions?
    
    var answersArray:NSArray = []
    
    var customLoader:WooLoader?
    
    var selectedProfileCardModel:ProfileCardModel?
    
    var currentUserDetail:ProfileCardModel?
    
    var crushText:String = ""
    
    var indexPathSelected:IndexPath?
    
    var buttonActivity:PerformActionBasedOnActivity = PerformActionBasedOnActivity.DoNothing
    
    var dismissHandler:((String, PerformActionBasedOnActivity, String, ProfileCardModel?)->Void)!
    
    let profileAction:ProfileActionManager = ProfileActionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myAnswersTableView.register(UINib(nibName:"MyAnswersTableViewCell", bundle: nil), forCellReuseIdentifier: "MyAnswersTableViewCell")
        
        myAnswersTableView.register(UINib(nibName:"MyQuestionForAnswersTableViewCell", bundle: nil), forCellReuseIdentifier: "MyQuestionForAnswersTableViewCell")
        
        myAnswersTableView.rowHeight = UITableView.automaticDimension
        myAnswersTableView.estimatedRowHeight = 50.0
        // Do any additional setup after loading the view.
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navBar!.setStyle(NavBarStyle.myQuestions, animated: false)
        self.navBar?.setTitleText("My Answers")
        self.navigationController?.isNavigationBarHidden = true;
        
        self.navBar?.customSwitch?.isHidden = true
        self.navBar!.backButton.isHidden = false
        self.navBar?.addBackButtonTarget(self, action: #selector(MyAnswersViewController.backButton))
    }
    @objc func backButton(){
       // self.navigationController?.popViewController(animated: true)
        
        if answersArray.count > 0 {
            if self.dismissHandler != nil {
                self.dismissHandler("", self.buttonActivity, "", nil)
            }
        }
        else{
            if self.dismissHandler != nil {
                if self.currentUserDetail != nil {
                    self.dismissHandler("", self.buttonActivity, self.crushText, self.currentUserDetail!)
                }
                else{
                    self.dismissHandler("", self.buttonActivity, self.crushText, nil)
                }
                
            }
        }
        
        if let navController = self.navigationController
        {
            if navController.viewControllers.count > 0
            {
                let _ =  navController.popViewController(animated: true)
            }
            else
            {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        AppLaunchModel.sharedInstance().isNewDataPresentMyQuestionSection = false
        self.myAnswersTableView.isUserInteractionEnabled = true

        if #available(iOS 11.0, *) {
            if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                myAnswersTableViewTopConstraint.constant = 64.0
            }
        }
        syncAnswerData()
    
    }
    
    
    func syncAnswerData()
    {
        if ((relatedQuestion?.totalAnswers.intValue) ?? 0 > 0)
        {
            answersArray = MyAnswers.getAllAnswerForQuestion(withQuestionID: Int64((relatedQuestion?.qid.int32Value)!)) as NSArray
            
            if (answersArray.count == (relatedQuestion?.totalAnswers.intValue) ?? 0) {
                myAnswersTableView.reloadData()
            }
            else
            {
                answersArray = NSArray()
                //APi call
                DispatchQueue.main.async {
                    self.showWooLoader()
                }
                
                QuestionAnswerAPIClass.getAllAnswers(forQuestion: relatedQuestion)
                { (success, response, errorNumber) in
                    
                    self.reloadNewData()
                }
            }
        }
        else
        {
            //APi call
            answersArray = NSArray()
            self.showWooLoader()
            QuestionAnswerAPIClass.getAllAnswers(forQuestion: relatedQuestion)
            { (success, response, errorNumber) in
                
                self.reloadNewData()
            }
        }
    }
    
    func reloadNewData() -> Void {
        
        //Phir Db se le aa
        if MyAnswers.getAllAnswerForQuestion(withQuestionID: Int64((relatedQuestion?.qid.int32Value)!)) != nil {
            answersArray = MyAnswers.getAllAnswerForQuestion(withQuestionID: Int64((relatedQuestion?.qid.int32Value)!)) as NSArray
        }
        else{
            //db se kuch na aaya
            answersArray = NSArray()
        }
            DispatchQueue.main.async {
                self.hideWooLoader()
                self.myAnswersTableView.reloadData()
                
                if (self.answersArray.count == 0){
                    self.backButton()
                }
            }
    }
    
    internal func showWooLoader(){
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    internal func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            }, completion: { (true) in
                (Utilities.sharedUtility() as AnyObject).hideLoaderView
                self.customLoader?.stopAnimation()
        })
    }
    
    internal func getProfileForSelectedUser(_ userID:Int64){
        
        let model:ProfileCardModel = DiscoverProfileCollection.sharedInstance.getProfileCardForWooID(String(userID))
        
        if model.wooId == nil{
            self.showWooLoader()
            ProfileAPIClass.fetchDataForUser(withUserID: userID) { (response, success, statusCode) in
                
                self.hideWooLoader()
                
                if success == true{
                    self.selectedProfileCardModel = ProfileCardModel(userInfoDto: response as! NSDictionary, wooId: String(userID))
                    DiscoverProfileCollection.sharedInstance.addProfileCard(self.selectedProfileCardModel!)
                    self.performSegue(withIdentifier: "MyAnswersToProfileDetailSegue", sender: self)
                }
            }
        }
        else{
            self.selectedProfileCardModel = model
            self.performSegue(withIdentifier: "MyAnswersToProfileDetailSegue", sender: self)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "MyAnswersToProfileDetailSegue"){
            let detailViewControllerObject = segue.destination as! ProfileDeckDetailViewController
            detailViewControllerObject.profileData = selectedProfileCardModel
            detailViewControllerObject.isComingFromDiscover = false
            detailViewControllerObject.isViewPushed = true
            DiscoverProfileCollection.sharedInstance.collectionMode = CollectionMode.discover
            detailViewControllerObject.isMyProfile = false
            detailViewControllerObject.detailProfileParentTypeOfView = DetailProfileViewParent.answers
            detailViewControllerObject.dismissHandler = { (currentImageUrlString:String, needToTakeAction:PerformActionBasedOnActivity, crushString: String, userProfile:ProfileCardModel, onBoardingEditProfileDone:Bool, indexPath:IndexPath) in
                self.currentUserDetail = userProfile
                self.buttonActivity = needToTakeAction
                self.crushText = crushString
                
                if needToTakeAction == .Like{
                    self.likeUser()
                }
                else if needToTakeAction == .CrushSent{
                    self.sendCrush()
                }
                else
                {
                    self.reloadNewData()
                }
            }
        }
        else if (segue.identifier == kPushToChatFromAnswerScreenOverlay) {
//            let chatViewNavControllerObj: UINavigationController = segue.destination as! UINavigationController
            let chatViewControllerObj: NewChatViewController  = segue.destination as! NewChatViewController
            let model = sender as! MyMatches
            chatViewControllerObj.myMatchesData = model
            chatViewControllerObj.isAutomaticallyPushedFromChat = true
            chatViewControllerObj.parentView = .answers
        }
    }

    
    func sendCrush(){
        performActionForType(.CrushSent,answerObject: nil, selectedIndexPath: indexPathSelected!)
    }
    
    func likeUser(){
        performActionForType(.Like, answerObject: nil, selectedIndexPath: indexPathSelected!)
    }
    
    func performActionForType(_ actionType:PerformAction, answerObject:MyAnswers?, selectedIndexPath:IndexPath){
        
        profileAction.currentViewType = .MyAnswers
        profileAction.crushText = self.crushText
        profileAction.indexPathToBeDeleted = selectedIndexPath
        self.myAnswersTableView.isUserInteractionEnabled = false

            profileAction.reloadHandler = {(indexPath:IndexPath) in
//                if self.answersArray.count > 1
//                {
//                    self.reloadNewData()
//                    self.perform(#selector(self.nowEnableTableView), with: nil, afterDelay: 0.2)
//                }
//                else
//                {
                    QuestionAnswerAPIClass.deleteAnswer(forAnswerObject: answerObject, withCompletionHandler: { (completion) in
                        self.reloadNewData()
                        self.perform(#selector(self.nowEnableTableView), with: nil, afterDelay: 0.2)
                    })

//                }
            }
        profileAction.otherActivityHandler = {
            self.reloadNewData()
            self.perform(#selector(self.nowEnableTableView), with: nil, afterDelay: 0.2)
        }
        profileAction.performSegueHandler = {
            (matchedUserDataFromDb:MyMatches) in
            if (Utilities().isChatRoomPresent(in: self.navigationController) == false){
                if(!AppLaunchModel.sharedInstance()!.isChatEnabled){
                    WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(2)
                }else{
                self.performSegue(withIdentifier: kPushToChatFromAnswerScreenOverlay, sender: matchedUserDataFromDb)
                }
            }
        }
        
        switch actionType {
        case .Like:
                profileAction.likeActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
                (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MS_QA_Like")
            break
        
        case .CrushSent:
                profileAction.crushActionPerformed(.ProfileCardModel, userObject: currentUserDetail as AnyObject)
            break
        
        case .Answers:
                profileAction.likeActionPerformed(.MyAnswers, userObject: answerObject as AnyObject)
        case .AnswersDislike:
            profileAction.dislikeActionPerformed(.MyAnswers, userObject: answerObject as AnyObject)
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "MS_QA_Skip")
            break

            
        default:
            break
        }
    }
    
    @objc func nowEnableTableView(){
        self.myAnswersTableView.isUserInteractionEnabled = true
    }

    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if answersArray.count > 0 {
            return answersArray.count + 1
        }
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        
        
        indexPathSelected = indexPath
        
        if (indexPath as NSIndexPath).row == 0 {
            let cellIdentifier = "MyQuestionForAnswersTableViewCell"
            let cellObj:MyQuestionForAnswersTableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyQuestionForAnswersTableViewCell)!
            
            if let questionObj:MyQuestions = relatedQuestion {
                
                cellObj.setDataOnCellFromModelObj(questionObj)
                
                cellObj.deleteAction = {(questionObj:MyQuestions) in
                    
                    if !Utilities().reachable() { // If there is no internet connection
                        
                        Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
                        return
                    }
                    
                    
                    
                    let deleteAlert:UIAlertController = UIAlertController(title: NSLocalizedString("Delete question?", comment:"Delete question actionsheet text" ), message:"" , preferredStyle: .actionSheet)
                    
                    let deleteAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete button text"), style: .default, handler: { (action) in
                        
                        
                        QuestionAnswerAPIClass.deleteQuestion(withQuestionID: String(questionObj.qid as! Int), withDeletionCompletionHandler:
                            {
                                (completion) in
                                
                                if (self.navigationController?.viewControllers.count)! > 0{
                                    self.navigationController?.popViewController(animated: true)
                                }else{
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                                
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
        else{
        let cellIdentifier = "MyAnswersTableViewCell"
        let cellObj:MyAnswersTableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyAnswersTableViewCell)!
            if self.answersArray.count > 0{
        if let answerObj:MyAnswers = (self.answersArray.object(at: indexPath.row - 1) as? MyAnswers) {
            
            cellObj.setDataOnCellFromModelObj(answerObj)
            
            cellObj.performedAction = {(localAnswerObj:MyAnswers, actionType:ActionType) in
                
                if !Utilities().reachable() { // If there is no internet connection
                    
                    Utilities().addingNoInternetSnackBar(withText: NSLocalizedString("No internet connection", comment: "No internet connection"), withActionTitle: "", withDuration: 3.0)
                    return
                }
                
                if actionType == .options {
                    
                let deleteAlert:UIAlertController = UIAlertController(title: NSLocalizedString("Delete Answer?", comment:"Delete answer actionsheet text" ), message:"" , preferredStyle: .actionSheet)
                
                let deleteAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete button text"), style: .default, handler: { (action) in
                    
                    QuestionAnswerAPIClass.deleteAnswer(forAnswerObject: answerObj, withCompletionHandler: { (completion) in
                        self.reloadNewData()
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
                else if actionType == .like_ANSWER{
                    //make like call
                    
                    if ((DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE") &&
                        WooPlusModel.sharedInstance().isExpired &&
                        (AppLaunchModel.sharedInstance().maxLikeToShowLikeMeter <= AppLaunchModel.sharedInstance().likeCount)) {
                        let outOfLikePopup = OutOfLikeView.showView(parentViewController: self)
                        outOfLikePopup.buttonPressHandler = {
                            //More Info
                            
                            if !(Utilities.sharedUtility() as AnyObject).reachable() {
                                self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
                                return
                            }

                            
                            let window:UIWindow = UIApplication.shared.keyWindow!
                            let purchaseObj:PurchasePopup = Bundle.main.loadNibNamed("PurchasePopup", owner: window.rootViewController, options: nil)?.first as! PurchasePopup
                            purchaseObj.purchaseShownOnViewController = self
                            purchaseObj.purchaseDismissedHandler = {
                                (screenType:PurchaseType,dropoffDTO:NSDictionary,modelObject:Any) in
                                let dropOffPurchaseObj:DropOffPurchasePopup = Bundle.main.loadNibNamed("DropOffPurchasePopup", owner: UIApplication.shared.keyWindow!.rootViewController, options: nil)?.first as! DropOffPurchasePopup
                                dropOffPurchaseObj.purchasedHandler = {(purchased:Bool) in
                                    
                                }
                                dropOffPurchaseObj.loadPopupOnWindowWith(productToBePurchased: screenType, andProductDTO: dropoffDTO, andModelObj: modelObject)
                                
                            }

                            purchaseObj.loadPopupOnWindowWith(productToBePurchased: .wooPlus)
                        }
                        return
                    }
                    
                    
                    self.performActionForType(.Answers, answerObject: answerObj, selectedIndexPath: indexPath)
                    
                }
                else if actionType == .dislike_ANSWER{
                    //make like call
                    self.performActionForType(.AnswersDislike, answerObject: answerObj, selectedIndexPath: indexPath)
                }
                else if actionType == .view_USER_PROFILE && answerObj.wooId != nil {
                    self.getProfileForSelectedUser(Int64(answerObj.wooId.int32Value))
                    
                }
                
            }
          }
            
        }
        
        return cellObj
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        // Push to dpv
        if indexPath.row > 0{
        if self.answersArray.count > 0{
        if let answerObj:MyAnswers = (self.answersArray.object(at: indexPath.row - 1) as? MyAnswers)
        {
            if(answerObj.wooId != nil)
            {
                self.getProfileForSelectedUser(Int64(answerObj.wooId.int32Value))
            }
            else
            {
                NSLog("Answer karne wala doesnot have an associated WooId")
            }
          }
         }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


