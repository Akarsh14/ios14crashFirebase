//
//  OnBoardingAgeViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 11/07/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class OnBoardingAgeViewController: UIViewController, VPImageCropperDelegate, LoginErroFeedbackDelegate {
    

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var customLoader :WooLoader?
    override func viewDidLoad() {
        super.viewDidLoad()

        if LoginModel.sharedInstance().birthday != nil && LoginModel.sharedInstance().birthday.count > 0{
            datePicker.date = getDateFormatter().date(from: LoginModel.sharedInstance().birthday)!
            updateDateButtonsBasedOnAge(true)
        }
        else{
            datePicker.date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
            updateDateButtonsBasedOnAge(false)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func back(_ sender: Any) {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "BIRTHDAY_SCREEN_BACK")
        (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "BIRTHDAY_SCREEN_BACK")

        self.navigationController?.popViewController(animated: true)
    }
    
    private func changeStateOfNextButtonBasedOnSelection(_ isSelected:Bool){
        if isSelected{
            nextButton.isUserInteractionEnabled = true
            nextButton.setTitleColor(UIColorHelper.color(fromRGB: "#FA4849", withAlpha: 1.0), for: .normal)
            nextButton.setImage(UIImage(named: "arrow_Right_red"), for: .normal)
        }
        else{
            nextButton.isUserInteractionEnabled = false
            nextButton.setTitleColor(UIColorHelper.color(fromRGB: "#BABBBE", withAlpha: 1.0), for: .normal)
            nextButton.setImage(UIImage(named: "ic_arrow_right_grey"), for: .normal)
        }
    }
    
    private func updateDateButtonsBasedOnAge(_ hasAge:Bool){
        var buttonColorName = ""
        if hasAge{
            buttonColorName = "#090909"
            updateButtonsText()
            changeStateOfNextButtonBasedOnSelection(true)
        }
        else{
            buttonColorName = "#CDCDD0"
            changeStateOfNextButtonBasedOnSelection(false)
        }
        dayButton.setTitleColor(UIColorHelper.color(fromRGB: buttonColorName, withAlpha: 1.0), for: .normal)
        monthButton.setTitleColor(UIColorHelper.color(fromRGB: buttonColorName, withAlpha: 1.0), for: .normal)
        yearButton.setTitleColor(UIColorHelper.color(fromRGB: buttonColorName, withAlpha: 1.0), for: .normal)
    }
    
    
    private func getDateFormatter()->DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
   
    
    private func updateButtonsText(){
        if let birthday = getDateFormatter().date(from: LoginModel.sharedInstance().birthday){
        let selectedDate: Date = birthday
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        if day > 9{
            dayButton.setTitle("\(day)", for: .normal)
        }
        else{
            dayButton.setTitle("0\(day)", for: .normal)
        }
            
        if month > 9{
            monthButton.setTitle("\(month)", for: .normal)
        }
        else{
            monthButton.setTitle("0\(month)", for: .normal)
        }
        yearButton.setTitle("\(year)", for: .normal)
        }
    }
    
    func showWooLoader() {
        customLoader = WooLoader(frame: self.view.frame)
        customLoader!.startAnimation(on: self.view!, withBackGround: true)
    }
    
    func removeWooLoader() {
        if customLoader != nil {
            customLoader!.removeFromSuperview()
            customLoader = nil
        }
    }
    
    @IBAction func next(_ sender: Any) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }else{
        //
        if (LoginModel.sharedInstance().birthday != nil){
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "BIRTHDAY_SCREEN_NEXT")
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "BIRTHDAY_SCREEN_NEXT")

            self.showWooLoader()
        LogInAPIClass.makeRegistrationCallwithCompletionBlock { (success, response, statusCode, isUserChanged) in
            self.removeWooLoader()
            if statusCode == 416{
                let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)
                let errorLoginViewController:LoginErrorFeedbackViewController = storyBoard.instantiateViewController(withIdentifier: "LoginErrorFeedbackViewController") as! LoginErrorFeedbackViewController
                errorLoginViewController.isShownForAgeLimit = true
                errorLoginViewController.delegate = self
                self.present(errorLoginViewController, animated: true, completion: nil)
            }
            if success{
                let isRegistered:Bool = (response as! NSDictionary).object(forKey: "isUserRegistered") as! Bool
                if isRegistered{
                    self.moveToNextScreenBasedOnLoginResponse(false)
                }
                else{
                    let navViewControllers = self.navigationController?.viewControllers
                    for viewController in navViewControllers!{
                        if viewController is OnBoardingNameViewController{
                            self.navigationController?.popToViewController(viewController, animated: false)
                        }
                    }
                }
            }
            }}else{
            self.popAlert(withString: "Kindly select your Birthday date")
        }
        }
    }
    
    private func popAlert(withString: String){
        let alert = UIAlertController(title: "Alert", message: withString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func moveToNextScreenBasedOnLoginResponse(_ afterNewUserNoPic:Bool){
        let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)
        var showNewUserNoPic = LoginModel.sharedInstance().isNewUserNoPicScreenOn
        if afterNewUserNoPic{
            showNewUserNoPic = false
        }
        else if LoginModel.sharedInstance().profilePicUrl != nil{
            showNewUserNoPic = false
        }
        if showNewUserNoPic{
            let width = SCREEN_WIDTH * 0.7361
            let imgCropperVC: VPImageCropperViewController = VPImageCropperViewController(image: UIImage(named:"crop_default"), cropFrame: CGRect(x: (SCREEN_WIDTH-width)/2, y: 0.122*SCREEN_HEIGHT, width: width, height: 0.655*SCREEN_HEIGHT), limitScaleRatio:Int(3.0))
            imgCropperVC.isImageAdded = true;
            imgCropperVC.delegate = self
            self.navigationController?.pushViewController(imgCropperVC, animated: true)
        }
        else if LoginModel.sharedInstance().isPhotoScreenGridOn{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let  id = UserDefaults.standard.object(forKey: "id") {
                    let wooid:NSString = id as! NSString
                    ProfileAPIClass.fetchDataForUser(withUserID: Int64(wooid.longLongValue)) { (response, success, statusCode) in
                        (Utilities() as AnyObject).increaseOnBoardingPageNumber()
                        let wizardPhotoScreen = WizardPhotoViewController(nibName: "WizardPhotoViewController", bundle: nil)
                       LoginModel.sharedInstance().isNewUserNoPicScreenOn = false
                        self.navigationController?.pushViewController(wizardPhotoScreen, animated: true)
                    }
                }                
            }

        }else if !(LoginModel.sharedInstance()?.userRelationshipTagsAvailable)! || !(LoginModel.sharedInstance()?.userLifestyleTagsAvailable)!{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                let relationshipController = RelationshipViewController.loadNib("Relationship and Lifestyle")
                relationshipController.setViewsfor(.OnBoarding,tagData: .RelationshipAndLifestyle, closeBtn: false, title: "Relationship and Lifestyle")
                self.navigationController?.pushViewController(relationshipController, animated: true)
            }
        }
        else if !(LoginModel.sharedInstance()?.userOtherTagsAvailable)!{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
                wizardTagsVC.isUsedOutOfWizard = true
                wizardTagsVC.isPartOfOnboarding = true
                wizardTagsVC.isThisFirstScreenAfterRegistration = true
                self.navigationController?.pushViewController(wizardTagsVC, animated: true)
            }
        }
        else if (LoginModel.sharedInstance().personalQuoteText) != nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let aboutMeScreenViewController:AboutMeScreenViewController = storyBoard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
               aboutMeScreenViewController.isThisFirstScreenAfterRegistration = true
                self.navigationController?.pushViewController(aboutMeScreenViewController, animated: true)
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            (Utilities() as AnyObject).sendToDiscover()
            }
        }
    }
    
    func gettingResponseFromLoginErrorFeeback(withLoginErrorReference errorFeedback: LoginErrorFeedbackViewController!) {

        errorFeedback.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "feedBackErrorOccured"), object: nil)
            self.navigationController?.popToRootViewController(animated: false)
        }
        
    }
    
    private func updateBirthdayOfUser(){
        let birthdayString = getDateFormatter().string(from: datePicker.date)
        
        LoginModel.sharedInstance().birthday = birthdayString
    }
    
    @IBAction func dismissDatePicker(_ sender: Any) {
        updateBirthdayOfUser()
        dateContainerView.isHidden = true
        updateDateButtonsBasedOnAge(true)
    }
    @IBAction func dateSelected(_ sender: Any) {
        updateBirthdayOfUser()
        dateContainerView.isHidden = true
        updateDateButtonsBasedOnAge(true)
    }
    @IBAction func selectDate(_ sender: Any) {
        dateContainerView.isHidden = false
    }
    
    func imageCropper(_ cropperViewController: VPImageCropperViewController!, didFinished editedImageData: [AnyHashable : Any]!) {
        self.moveToNextScreenBasedOnLoginResponse(true)
    }
    
    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController!) {
        self.moveToNextScreenBasedOnLoginResponse(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



