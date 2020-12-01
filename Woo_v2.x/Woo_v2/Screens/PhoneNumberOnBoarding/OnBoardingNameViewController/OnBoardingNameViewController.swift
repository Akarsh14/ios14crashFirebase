//
//  OnBoardingNameViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 09/07/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class OnBoardingNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var allowedCharacterLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        if LoginModel.sharedInstance().firstName != nil && LoginModel.sharedInstance().firstName.count > 0{
            firstNameTextField.text = LoginModel.sharedInstance().firstName
            changeStateOfNextButtonBasedOnTextStatus(true)
        }
        
        if LoginModel.sharedInstance().lastName != nil && LoginModel.sharedInstance().lastName.count > 0{
            lastNameTextField.text = LoginModel.sharedInstance().lastName
        }
        
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == firstNameTextField{
            if (textField.text?.count)! > 0{
                changeStateOfNextButtonBasedOnTextStatus(true)
            }
            else{
                changeStateOfNextButtonBasedOnTextStatus(false)
                allowedCharacterLabel.isHidden = true
            }
        }
        else if textField == lastNameTextField{
            if (textField.text?.count)! == 0{
                allowedCharacterLabel.isHidden = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let maxLength = 15
    let currentString: NSString = textField.text! as NSString
    let newString: NSString =
    currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
    }
    

    @IBAction func next(_ sender: Any) {
        var canMoveToNextScreen = false
        var firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (firstName?.count)! > 0{
            firstName?.capitalizeFirstLetter()
        if checkIfTextIsValid(firstName!){
            allowedCharacterLabel.isHidden = true
            canMoveToNextScreen = true
            LoginModel.sharedInstance().firstName = firstName
        }
        else{
            allowedCharacterLabel.isHidden = false
            canMoveToNextScreen = false
        }
        }
        
        var lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (lastName?.count)! > 0{
            lastName?.capitalizeFirstLetter()
            if checkIfTextIsValid(lastName!){
                allowedCharacterLabel.isHidden = true
                canMoveToNextScreen = true
                LoginModel.sharedInstance().lastName = lastName
            }
            else{
                allowedCharacterLabel.isHidden = false
                canMoveToNextScreen = false
            }
        }
        
        if canMoveToNextScreen{
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "NAME_SCREEN_NEXT")
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "NAME_SCREEN_NEXT")

            let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)
            let onboardingGender:OnBoardingGenderViewController = storyBoard.instantiateViewController(withIdentifier: "OnBoardingGenderViewController") as! OnBoardingGenderViewController
            
            //NLP
//            do {
//                if #available(iOS 11.0, *) {
//                    let classificationService = ClassificationService()
//                    if let name = LoginModel.sharedInstance()?.firstName{
//                        let result = try classificationService.predictGender(from: name)
//                        LoginModel.sharedInstance()?.gender = result.gender.string
//                    }
//                }
//            } catch {
//                print(error)
//            }
//
            self.navigationController?.pushViewController(onboardingGender, animated: true)
            }
        else{
            allowedCharacterLabel.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func checkIfTextIsValid(_ input:String) -> Bool{
        for chr in input {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    private func changeStateOfNextButtonBasedOnTextStatus(_ textInputed:Bool){
        if textInputed{
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
