//
//  VerifyNumberViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 05/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit
import IQKeyboardManager

class VerifyNumberViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var submitShadowView: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    var currentCountryDto:CountryDtoModel?
    var customLoader:WooLoader?
    var verifyFlowdismissHandler:(()->Void)!
    
    var isOpenFromEditProfile:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(dimissTheScreen), name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)

        self.navigationController?.navigationBar.isHidden = true
        setPlaceHolderPropertyForCodeTextFields()
        setDataForCodeLabel()
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        phoneNumberTextField.becomeFirstResponder()
        setPropertyOfSubmitButton(false)
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isOpenFromEditProfile {
            skipButton.isHidden = true
            backButton.isHidden = false
        }
        else{
            skipButton.isHidden = false
            backButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismssScreenNotification"), object: nil)
        
    }
    
    @objc func dimissTheScreen()
    {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    

    
    func setDataForCodeLabel(){
        if DiscoverProfileCollection.sharedInstance.myProfileData?.phoneNumberDto != nil{
        let myProfileCountryDto:NSDictionary = (DiscoverProfileCollection.sharedInstance.myProfileData?.phoneNumberDto?.object(forKey: "countryDto") as? NSDictionary)!
        let countryDtoObject = CountryDtoModel()
        
        countryDtoObject.updateData(withCountryDtoDictionary: myProfileCountryDto as! [AnyHashable : Any])
        currentCountryDto = countryDtoObject
        codeLabel.text = currentCountryDto?.countryCode
        }
        else{
            codeLabel.text = ""
        }
    }
    
    func performAfterTaskAfterCodeCaptured() {
        codeLabel.text = currentCountryDto?.countryCode
        setPropertyOfSubmitButton(false)
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    func setPropertyOfSubmitButton(_ enable:Bool){
        if enable {
            UIView.animate(withDuration: 0.5, animations: {
                self.submitButton.isEnabled = true
                self.submitButton.alpha = 1.0
                self.skipButton.isSelected = true
                self.skipButton.setTitle("NEXT", for: .normal)
            })
        }
        else{
            UIView.animate(withDuration: 0.5, animations: {
                self.submitButton.isEnabled = false
                self.submitButton.alpha = 0.6
                self.skipButton.isSelected = false
                self.skipButton.setTitle("SKIP", for: .normal)
            })
        }
    }
    
    func setPlaceHolderPropertyForCodeTextFields(){
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Enter Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 114/255, green: 119/255, blue: 138/255, alpha: 0.5)])
        
        submitShadowView.layer.masksToBounds = false
        submitShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        submitShadowView.layer.shadowColor = UIColor.black.cgColor
        submitShadowView.layer.shadowRadius = 0.0
        submitShadowView.layer.shadowOpacity = 0.1
        submitShadowView.clipsToBounds = false
        
    }
    
    func showWooLoader(){
        customLoader?.removeFromSuperview()
        customLoader = nil
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
        }, completion: { (true) in
            self.customLoader?.stopAnimation()
            self.customLoader?.removeFromSuperview()
        })
        
    }

    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }

    @IBAction func submitTapped(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        self.phoneNumberTextField.resignFirstResponder()

        let code = "(" + (currentCountryDto?.countryCode)! + ")"
        let mobileNumberText = code + phoneNumberTextField.text!
        let submitAlert = AlertController.showAlert(withTitle: "Confirm your number", andMessage: "Is this your mobile number?\n\(mobileNumberText)", needHandler: true, withController: self)
        
        let editAction = UIAlertAction(title: "Edit", style: .cancel) { (alertAction:UIAlertAction) in
            self.phoneNumberTextField.becomeFirstResponder()
        }
        submitAlert.addAction(editAction)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction:UIAlertAction) in
            self.generateOtp()
        }
        submitAlert.addAction(okAction)
        self.present(submitAlert, animated: true, completion: nil)

    }
    
    func generateOtp(){
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        showWooLoader()
        PhoneVerifyApiClass.generateOTP(forMobileNumber: phoneNumberTextField.text, andCountryDto: currentCountryDto) { (success, response, statusCode) in
            self.hideWooLoader()
            if statusCode == 200{
                self.performSegue(withIdentifier: "verifyNumberToVerifyCode", sender: nil)
            }
            else if statusCode == 429{
                //too many request
                var tryAgainText = ""
                if !self.isOpenFromEditProfile{
                    tryAgainText = "We are unable to verify your OTP for now.\n You can try again later from edit profile.";
                }
                else{
                    tryAgainText = "We are unable to verify your OTP for now.\n Please try again later."
                }
                let unableToVerifyOtpAlert = AlertController.showAlert(withTitle: "", andMessage: tryAgainText, needHandler: true, withController: self)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel) { (alertAction:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }
                unableToVerifyOtpAlert.addAction(okAction)
                self.present(unableToVerifyOtpAlert, animated: true, completion: nil)

                
            }
            else if statusCode == 208{
                //number already verified
                
                let alreadyExistAlert = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: true, withController: self)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel) { (alertAction:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }
                alreadyExistAlert.addAction(okAction)
                self.present(alreadyExistAlert, animated: true, completion: nil)
            }
        }
    }
        
    @objc(textField:shouldChangeCharactersInRange:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if string.count == 0 {
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            if Int32((trimmedString?.count)! - 1) < (currentCountryDto?.minAllowedDigit)! {
                setPropertyOfSubmitButton(false)
             }
            return true
        }
        
        let numericString = "0123456789"
        if numericString.range(of: string) == nil {
            return false
        }
        
        let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
        if (trimmedString?.count)! > 0{
        if Int32((trimmedString?.count)! + 1) >= (currentCountryDto?.minAllowedDigit)! && Int32((trimmedString?.count)! + 1) <= (currentCountryDto?.maxAllowedDigit)! {
            setPropertyOfSubmitButton(true)
        }
        else if Int32((trimmedString?.count)! + 1) > (currentCountryDto?.maxAllowedDigit)!{
            return false
        }
        else{
            setPropertyOfSubmitButton(false)
            }
        }
        
        return true
        
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


    @IBAction func skip(_ sender: Any) {
        if self.skipButton.isSelected{
            submitTapped(UIButton())
        }
        else{
        self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "verifyNumberToSelectCountry"){
            let navigationVC:UINavigationController = segue.destination as! UINavigationController
            let countryVC = navigationVC.viewControllers.first as! SelectCountryViewController
            countryVC.selectedCountryDto = currentCountryDto
            countryVC.selectedCountryHandler = { (countryDto:CountryDtoModel) in
                self.currentCountryDto = countryDto
                self.performAfterTaskAfterCodeCaptured()
            }

        }
        else if (segue.identifier == "verifyNumberToVerifyCode"){
            let navigationVC:UINavigationController = segue.destination as! UINavigationController
            let codeVerifyVC = navigationVC.viewControllers.first as! VerificationCodeViewController
            codeVerifyVC.phoneNumberCaptured = phoneNumberTextField.text!
            codeVerifyVC.isOpenFromEditProfile = self.isOpenFromEditProfile
            codeVerifyVC.currentCountryDto = self.currentCountryDto
            codeVerifyVC.dismissHandler = {() in
                self.dismiss(animated: false, completion: {
                    if self.verifyFlowdismissHandler != nil{
                        self.verifyFlowdismissHandler()
                    }
                })
            }
        }
        
    }
    

}
