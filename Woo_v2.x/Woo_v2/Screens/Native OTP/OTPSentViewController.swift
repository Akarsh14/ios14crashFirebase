//
//  OTPSentViewController.swift
//  Woo_v2
//
//  Created by HARISH on 12/3/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

protocol NativeOTPLoginDelegate {
    func afterOTPServerCall(accessToken: String)
}

class OTPSentViewController: UIViewController {
    @IBOutlet weak var lblTimer: UILabel!
    private var accessToken:String = ""
    @IBOutlet weak var lblEnterOTP: UILabel!
    var phoneNumber = CountryDtoModel()
    var delegate:NativeOTPLoginDelegate?
    var customLoader :WooLoader?
    var mobileNumber = ""
   @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var txtFieldPhoneNumber: UITextField!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    var timerSheduled = Timer()
    var count = 90
    @IBOutlet weak var btnResentOTP: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTimer.text = ""
        txtFieldPhoneNumber.becomeFirstResponder()
        btnProceed.isUserInteractionEnabled = false
        btnResentOTP.isUserInteractionEnabled = false
        lblEnterOTP.text = "Enter the OTP sent to \(self.mobileNumber)"
        timerSheduled = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        txtFieldPhoneNumber.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)


    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
      if(txtFieldPhoneNumber.text!.count > 3){
        btnProceed.isUserInteractionEnabled = true
            btnProceed.backgroundColor = UIColor(hexString: "#fc5b6a", alpha: 1)
            btnProceed.setTitleColor(UIColor(hexString: "#ffffff", alpha: 1), for: .normal)
        }else{
            btnProceed.isUserInteractionEnabled = false
            btnProceed.backgroundColor = UIColor(hexString: "#dbdeeb", alpha: 1)
            btnProceed.setTitleColor(UIColor(hexString: "#323952", alpha: 0.60), for: .normal)
        }
    }
    
    
    @objc func update() {
        if(count > 0){
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            lblTimer.text = minutes + ":" + seconds
            count-=1
        }else if(count == 0){
            btnResentOTP.isUserInteractionEnabled = true
            lblTimer.isHidden = true
            timerSheduled.invalidate()
            btnResentOTP.titleLabel?.textColor = UIColor(hexString: "#0178ff", alpha: 1)
        }
        }
    
    
    func setAcessTokenFromServer(acessToken: String, mobileNumber: String, nativePhoneModel: CountryDtoModel){
        self.accessToken = acessToken
        self.phoneNumber = nativePhoneModel
        self.mobileNumber = mobileNumber
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnProceed(_ sender: Any) {
        self.view.endEditing(true)
        showWooLoader()
        
        PhoneVerifyApiClass.verifyOTP(forMobileNumber:accessToken , otp: txtFieldPhoneNumber.text, andCountryDto: phoneNumber) { (isSucess, response, statusCode) in
            self.removeWooLoader()
            if(statusCode == 200){
                if let responseFromServer = response as? [String:Any]{
                    let accessCode = responseFromServer["accessToken"] as! String
                        self.navigationController?.popViewController(animated: false)
                        self.delegate?.afterOTPServerCall(accessToken: accessCode)
                    
                }
            }else if((statusCode == 401)){
                self.popAlert(withString: "Enter a valid OTP")
            }else if(statusCode == 226) || (statusCode == 403){
                self.popAlert(withString: "OTP is expired")
            }else{
                self.popAlert(withString: NSLocalizedString("Generic_error", comment: "Generic_error"))
            }
        }
    }
    
    func popAlert(withString: String){
        let alert = UIAlertController(title: "Alert", message: withString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnRessendOTP(_ sender: Any) {
        
        btnResentOTP.titleLabel?.textColor = UIColor(hexString: "#0178ff", alpha: 1)
        hitAPI()
    }
    
    func hitAPI(){
        self.view.endEditing(true)
        showWooLoader()
        PhoneVerifyApiClass.generateOTP(forMobileNumber: mobileNumber, andCountryDto: phoneNumber) { (isucess, response, statusCode) in
            self.removeWooLoader()
            self.count = 90
            self.timerSheduled.invalidate()
            self.timerSheduled = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            self.lblTimer.isHidden = false
            self.btnResentOTP.isUserInteractionEnabled = false
            self.btnResentOTP.titleLabel?.textColor = UIColor(hexString: "#323952", alpha: 1)
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

    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
