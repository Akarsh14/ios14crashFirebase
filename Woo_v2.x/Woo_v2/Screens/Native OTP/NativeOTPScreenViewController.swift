//
//  NativeOTPScreenViewController.swift
//  Woo_v2
//
//  Created by Harish Kuramsetty on 11/30/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class NativeOTPScreenViewController: UIViewController, UITextFieldDelegate, CountryListDelegate,NativeOTPLoginDelegate {
  
    @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var txtFieldPhoneNumber: UITextField!
    var countryList = CountryList()
    var delegate:NativeOTPLoginDelegate?
    var customLoader :WooLoader?
    var phoneNumber = CountryDtoModel()
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.countryCode = "91"
        phoneNumber.countryName = "Ind"
        btnProceed.isUserInteractionEnabled = false
        btnProceed.backgroundColor = UIColor(hexString: "#dbdeeb", alpha: 1)
        btnProceed.setTitleColor(UIColor(hexString: "#323952", alpha: 0.60), for: .normal)
        txtFieldPhoneNumber.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        countryList.delegate = self
}
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(self.txtFieldPhoneNumber.text!.count > 0){
                   viewPhoneNumber.backgroundColor = UIColor(hexString: "#323952", alpha: 1)
               }else{
                   viewPhoneNumber.backgroundColor = UIColor(hexString: "#BBBFD0", alpha: 1)
               }
        
        if(txtFieldPhoneNumber.text!.count > 9){
            btnProceed.isUserInteractionEnabled = true
            btnProceed.backgroundColor = UIColor(hexString: "#fc5b6a", alpha: 1)
            btnProceed.setTitleColor(UIColor(hexString: "#ffffff", alpha: 1), for: .normal)
        }else{
            btnProceed.isUserInteractionEnabled = false
            btnProceed.backgroundColor = UIColor(hexString: "#dbdeeb", alpha: 1)
            btnProceed.setTitleColor(UIColor(hexString: "#323952", alpha: 0.60), for: .normal)
       }
    }
    
   
    
   func afterOTPServerCall(accessToken: String) {
        self.navigationController?.popViewController(animated: false)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.delegate?.afterOTPServerCall(accessToken: accessToken)
    }
    }
    
    func selectedCountry(country: Country) {
     self.navigationController?.popViewController(animated: false)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.delegate?.afterOTPServerCall(accessToken: "")
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
      self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnProceed(_ sender: Any) {
        self.view.endEditing(true)
        showWooLoader()
        PhoneVerifyApiClass.generateOTP(forMobileNumber: txtFieldPhoneNumber.text, andCountryDto: phoneNumber) { (isucess, response, statusCode) in
            self.removeWooLoader()
            if(statusCode == 200){
                if let responseFromServer = response as? [String:Any]{
                    let accessCode = responseFromServer["accessToken"] as! String
                    let verifyOTP =  self.storyboard?.instantiateViewController(withIdentifier: "OTPSentViewController") as! OTPSentViewController
                    verifyOTP.setAcessTokenFromServer(acessToken: accessCode, mobileNumber: self.txtFieldPhoneNumber.text!, nativePhoneModel: self.phoneNumber)
                    verifyOTP.delegate = self
                    self.navigationController?.pushViewController(verifyOTP, animated: true)
                }
            }else if((statusCode == 406)){
                self.popAlert(withString: "Enter a valid mobile number")
            }else if(statusCode == 429){
                self.popAlert(withString: "Too many requests")
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
    
    @IBAction func btnCountryCode(_ sender: Any) {
       // let navController = UINavigationController(rootViewController: countryList)
       // self.present(navController, animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
        self.delegate?.afterOTPServerCall(accessToken: "")
               
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
