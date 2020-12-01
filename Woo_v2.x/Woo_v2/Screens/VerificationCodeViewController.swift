//
//  VerificationCodeViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 02/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

private struct Constants {
    static var InvisibleSign = "\u{200B}"
}

class VerificationCodeViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var code1TextField: UITextField!
    @IBOutlet weak var code2TextField: UITextField!
    @IBOutlet weak var code3TextField: UITextField!
    @IBOutlet weak var code4TextField: UITextField!
    @IBOutlet weak var verificationCodeLabel: UILabel!
    @IBOutlet weak var codeExpiryTimeButton: UIButton!
    @IBOutlet weak var submitShadowView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var checkInboxLabel: UILabel!
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var phoneNumberCaptured = ""
    var currentCountryDto:CountryDtoModel?
    var otpEnteredByUserArray:NSMutableArray = NSMutableArray()
    var otpToSendArray:NSMutableArray = NSMutableArray()
    var customLoader:WooLoader?
    var codeExpirytimer: Timer?
    var timeForCodeExpiry:Int = 180
    var isOpenFromEditProfile:Bool = false
    
    var dismissHandler:(()->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //customizeNavBar()
        self.navigationController?.navigationBar.isHidden = true
        setTextForVerificationCodeLabel()
        setPlaceHolderPropertyForCodeTextFields()
        setPropertyOfSubmitButton(false)
        enableOrDisableCodeTextFieldsBasedOnInput(1)
        code1TextField.becomeFirstResponder()
        updateCodeExpiryElements(true)

                // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for _ in 0...3{
            otpToSendArray.add("")
        }
        if self.isOpenFromEditProfile {
            skipButton.isHidden = true
            backButton.setImage(UIImage(named: "ic_match_close_White"), for: .normal)
            backButton.isHidden = false
            
        }
        else{
            skipButton.isHidden = false
            //backButton.setImage(UIImage(named: "ic_arrow_back_white"), for: .normal)
            backButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTextForVerificationCodeLabel(){
        //Enter the verification code sent to your phone number ending in 422
        var lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Medium", size: 16.0)! ]
        let verificationText = "Enter the verification code sent to your phone number ending in"
        let lString = NSMutableAttributedString(string: (verificationText), attributes: lAttribute)
        lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Black", size: 16.0)! ]
        let phoneNumberCount:Int = phoneNumberCaptured.count
        let phoneNumberText:NSString = phoneNumberCaptured as NSString
        let rString = phoneNumberText.substring(with: NSRange(location: phoneNumberCount - 3, length: 3))
        let attrString = NSMutableAttributedString(string: " " + String(rString), attributes: lAttribute)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        lString.append(attrString)
        lString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attrString.length))
        verificationCodeLabel.attributedText = lString
    }
    
    func setPlaceHolderPropertyForCodeTextFields(){
        code1TextField.attributedPlaceholder = NSAttributedString(string: "1", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        code2TextField.attributedPlaceholder = NSAttributedString(string: "2", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        code3TextField.attributedPlaceholder = NSAttributedString(string: "3", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        code4TextField.attributedPlaceholder = NSAttributedString(string: "4", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        
        
        submitShadowView.layer.masksToBounds = false
        submitShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        submitShadowView.layer.shadowColor = UIColor.black.cgColor
        submitShadowView.layer.shadowRadius = 0.0
        submitShadowView.layer.shadowOpacity = 0.1
        submitShadowView.clipsToBounds = false
    }
    
    func updateCodeExpiryElements(_ startTimer:Bool){
        if startTimer {
            codeExpirytimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            checkInboxLabel.text = "Please check your inbox for the OTP"
            codeExpiryTimeButton.isUserInteractionEnabled = false
        }
        else{
            codeExpirytimer?.invalidate()
            codeExpiryTimeButton.isUserInteractionEnabled = true
            checkInboxLabel.text = "Didn't recieve the code?"
            codeExpiryTimeButton.setTitle("RESEND CODE", for: .normal)

        }
    }
    
    @objc func updateTime(){
        let timeInMinutes = Int(timeForCodeExpiry/60)
        if timeForCodeExpiry > 0{
            let timeToDisplayInMinutes = "0\(timeInMinutes)"
            let timeInSeconds = timeForCodeExpiry - 60*timeInMinutes
            var timeToDisplayInSeconds = ""
            if timeInSeconds < 10 {
                timeToDisplayInSeconds = "0\(timeInSeconds)"
            }
            else{
                timeToDisplayInSeconds = String(timeForCodeExpiry - 60*timeInMinutes)
            }
            let timeToDisplay = timeToDisplayInMinutes + ":" + timeToDisplayInSeconds
            codeExpiryTimeButton.titleLabel?.text = timeToDisplay
            codeExpiryTimeButton.setTitle(timeToDisplay, for: .normal)
            timeForCodeExpiry = timeForCodeExpiry - 1
        }
        else{
            updateCodeExpiryElements(false)
        }
    }
    
    func enableOrDisableCodeTextFieldsBasedOnInput(_ value:Int){
        switch value {
        case 1:
            code1TextField.isEnabled = true
            code2TextField.isEnabled = false
            code3TextField.isEnabled = false
            code4TextField.isEnabled = false
            break
        case 2:
            code2TextField.isEnabled = true
            code3TextField.isEnabled = false
            code4TextField.isEnabled = false
            break
        case 3:
            code3TextField.isEnabled = true
            code4TextField.isEnabled = false
            break
        case 4:
            code4TextField.isEnabled = true
            break
        case 5:
            code1TextField.isEnabled = true
            code2TextField.isEnabled = true
            code3TextField.isEnabled = true
            code4TextField.isEnabled = true
            break
            
        default:
            code1TextField.isEnabled = false
            code2TextField.isEnabled = false
            code3TextField.isEnabled = false
            code4TextField.isEnabled = false
            break
        }
    }
    
    func setPropertyOfSubmitButton(_ enable:Bool){
        if enable {
            UIView.animate(withDuration: 0.5, animations: {
                self.submitButton.isEnabled = true
                self.submitButton.alpha = 1.0
                self.skipButton.isSelected = true
                self.skipButton.setTitle("DONE", for: .normal)
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
    
    func generateOtp(){
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        showWooLoader()
        PhoneVerifyApiClass.generateOTP(forMobileNumber: phoneNumberCaptured, andCountryDto: currentCountryDto) { (success, response, statusCode) in
            self.hideWooLoader()
            if statusCode == 200{
                //success
                self.code1TextField.text = ""
                self.code2TextField.text = ""
                self.code3TextField.text = ""
                self.code4TextField.text = ""
                self.enableOrDisableCodeTextFieldsBasedOnInput(1)
                self.otpEnteredByUserArray.removeAllObjects()
                self.code1TextField.becomeFirstResponder()
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
                    self.dismiss(animated: false, completion: {
                        self.dismissHandler()
                    })
                }
                unableToVerifyOtpAlert.addAction(okAction)
                self.present(unableToVerifyOtpAlert, animated: true, completion: nil)
            }
            else if statusCode == 208{
                //number already verified
                let alreadyExistAlert = AlertController.showAlert(withTitle: "", andMessage: "You have entered a mobile number that already exists.", needHandler: true, withController: self)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel) { (alertAction:UIAlertAction) in
                    self.dismiss(animated: false, completion: {
                        self.dismissHandler()
                    })
                }
                alreadyExistAlert.addAction(okAction)
                self.present(alreadyExistAlert, animated: true, completion: nil)
            }
        }
    }


    @IBAction func didChangeEditingInTextField(_ sender: UITextField) {
//        if var text = sender.text {
//            if text.characters.count == 0 && text != Constants.InvisibleSign {
//                text = Constants.InvisibleSign
//                sender.text = text
//            }
//        }
    }
    @IBAction func goToVerifyNumber(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skip(_ sender: Any) {
        if self.skipButton.isSelected{
            submit(UIButton())
        }
        else{
            self.dismiss(animated: false, completion: {
                self.dismissHandler()
            })
        }
    }
    @IBAction func reSendCode(_ sender: Any) {
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        timeForCodeExpiry = 180
        updateCodeExpiryElements(true)
        generateOtp()
    }
    @IBAction func submit(_ sender: Any) {
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        
        if otpEnteredByUserArray.count == 4 {
        var otpToSend = ""
        for otpText in otpToSendArray {
            otpToSend = otpToSend + (otpText as! String)
        }
        showWooLoader()
        PhoneVerifyApiClass.verifyOTP(forMobileNumber: phoneNumberCaptured, otp: otpToSend, andCountryDto: currentCountryDto) { (success, response, statusCode) in
            self.hideWooLoader()
                if statusCode == 200{
                    let numberVerified = AlertController.showAlert(withTitle: "Number Verified!", andMessage: "We've added a Phone verified badge to your profile", needHandler: true, withController: self)
                    
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { (alertAction:UIAlertAction) in
                        DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
                        DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
                        DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
                        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
                        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
                        DiscoverProfileCollection.sharedInstance.paginationToken = ""
                        DiscoverProfileCollection.sharedInstance.paginationIndex = ""
                        
                        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
                            if success{
                            }
                        })
                        
                        let myUserID:String = UserDefaults.standard.object(forKey: kWooUserId) as! String
                        
                        ProfileAPIClass.fetchDataForUser(withUserID: Int64(myUserID)!, withCompletionBlock: { (response, success, statusCode) in
                            
                            if success{
                                self.dismiss(animated: false, completion: {
                                    self.dismissHandler()
                                })
                            }
                        })
                    }
                    numberVerified.addAction(okAction)
                    self.present(numberVerified, animated: true, completion: nil)
                }
                else{
                    self.showSnackBar("Please enter correct OTP")
                }
        }
     }
    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }

    
    @objc(textField:shouldChangeCharactersInRange:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
//        let  char = string.cString(using: String.Encoding.utf8)!
//        let isBackSpace = strcmp(char, "\\b")
//        
//        if (isBackSpace == -92) {
//            print("Backspace was pressed")
//        }
        
        if string.count == 0 {
            switch textField {
            case code1TextField:
                if (code1TextField.text?.count)! > 0 {
                    otpEnteredByUserArray.removeLastObject()
                    otpToSendArray.replaceObject(at: 0, with: "")
                }
                break
            case code2TextField:
                if (code2TextField.text?.count)! > 0 {
                    otpEnteredByUserArray.removeLastObject()
                    otpToSendArray.replaceObject(at: 1, with: "")
                }

                break
            case code3TextField:
                if (code3TextField.text?.count)! > 0 {
                    otpEnteredByUserArray.removeLastObject()
                    otpToSendArray.replaceObject(at: 2, with: "")
                }

                break
            case code4TextField:
                if (code4TextField.text?.count)! > 0 {
                    otpEnteredByUserArray.removeLastObject()
                    otpToSendArray.replaceObject(at: 3, with: "")
                }
                break
            default:
                break
            }
            if otpEnteredByUserArray.count == 4 {
                setPropertyOfSubmitButton(true)
            }
            else{
                if otpEnteredByUserArray.count == 0{
                    enableOrDisableCodeTextFieldsBasedOnInput(1)
                }
                else{
                    enableOrDisableCodeTextFieldsBasedOnInput(5)
                }
                setPropertyOfSubmitButton(false)
            }
            
            return true
        }
        else{
            if (textField.text?.count)! > 0 {
                return false
            }

        }
            
        
        let numericString = "0123456789"
        if numericString.range(of: string) == nil {
            return false
        }
        
        switch textField {
        case code1TextField:
            otpEnteredByUserArray.add(string)
            otpToSendArray.replaceObject(at: 0, with: string)
            if (code2TextField.text?.count)! <= 0 {
                enableOrDisableCodeTextFieldsBasedOnInput(2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.makeTextFieldFirstResponderNow(false, textField: self.code2TextField)
                })
            }
            break
        case code2TextField:
            otpEnteredByUserArray.add(string)
            otpToSendArray.replaceObject(at: 1, with: string)
            if (code3TextField.text?.count)! <= 0 {
                enableOrDisableCodeTextFieldsBasedOnInput(3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.makeTextFieldFirstResponderNow(false, textField: self.code3TextField)
                })
            }
            break
        case code3TextField:
            otpEnteredByUserArray.add(string)
            otpToSendArray.replaceObject(at: 2, with: string)
            if (code4TextField.text?.count)! <= 0 {
                enableOrDisableCodeTextFieldsBasedOnInput(4)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.makeTextFieldFirstResponderNow(false, textField: self.code4TextField)
                })
            }
            break
        case code4TextField:
            otpEnteredByUserArray.add(string)
            otpToSendArray.replaceObject(at: 3, with: string)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.makeTextFieldFirstResponderNow(true, textField: self.code4TextField)
            })
            break
        default:
            break
        }
        
        if otpEnteredByUserArray.count == 4 {
            setPropertyOfSubmitButton(true)
        }
        else{
            setPropertyOfSubmitButton(false)
        }
        
        return true
        
    }
    
    func makeTextFieldFirstResponderNow(_ resign:Bool,textField:UITextField){
        if resign {
            textField.resignFirstResponder()
        }
        else{
        textField.becomeFirstResponder()
        }
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

