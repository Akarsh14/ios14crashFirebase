//
//  OnBoardingGenderViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 10/07/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class OnBoardingGenderViewController: UIViewController {

    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var femaleImageView: UIImageView!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
      
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMaleFemaleOptions()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func maleFemaleClicked(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 100{
            LoginModel.sharedInstance().gender = "MALE"
            setupMaleFemaleOptions()
        }
        else if button.tag == 200{
            LoginModel.sharedInstance().gender = "FEMALE"
            setupMaleFemaleOptions()
        }
    }
    @IBAction func back(_ sender: Any) {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "GENDER_SCREEN_BACK")
        (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "GENDER_SCREEN_BACK")
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
    
    private func setupMaleFemaleOptions(){
        var maleImageName = ""
        var maleTextColor = ""
        var femaleImageName = ""
        var femaleTextColor = ""

        if LoginModel.sharedInstance().gender != nil{
            if LoginModel.sharedInstance().gender == "MALE"{
                maleImageName = "ic_onboarding_male_purple"
                maleTextColor = "#9275DB"
                femaleImageName = "ic_onboarding_female_grey"
                femaleTextColor = "#AFB0B4"
                changeStateOfNextButtonBasedOnSelection(true)
            }
            else if LoginModel.sharedInstance().gender == "FEMALE"{
                maleImageName = "ic_onboarding_male_grey"
                maleTextColor = "#AFB0B4"
                femaleImageName = "ic_onboarding_female_purple"
                femaleTextColor = "#9275DB"
                changeStateOfNextButtonBasedOnSelection(true)
            }
            else{
                maleImageName = "ic_onboarding_male_grey"
                maleTextColor = "#AFB0B4"
                femaleImageName = "ic_onboarding_female_grey"
                femaleTextColor = "#AFB0B4"
                changeStateOfNextButtonBasedOnSelection(false)
            }
        }
        else{
            maleImageName = "ic_onboarding_male_grey"
            maleTextColor = "#AFB0B4"
            femaleImageName = "ic_onboarding_female_grey"
            femaleTextColor = "#AFB0B4"
            changeStateOfNextButtonBasedOnSelection(false)
        }
        
        maleImageView.image = UIImage(named: maleImageName)
        maleLabel.textColor = UIColorHelper.color(fromRGB: maleTextColor, withAlpha: 1.0)
        femaleImageView.image = UIImage(named: femaleImageName)
        femaleLabel.textColor = UIColorHelper.color(fromRGB: femaleTextColor, withAlpha: 1.0)
    }
    
    @IBAction func next(_ sender: Any) {
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "GENDER_SCREEN_NEXT")
        (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: "GENDER_SCREEN_NEXT")

        let storyBoard = UIStoryboard(name: "onboarding", bundle: nil)
        let onboardingAgeScreen:OnBoardingAgeViewController = storyBoard.instantiateViewController(withIdentifier: "OnBoardingAgeViewController") as! OnBoardingAgeViewController
        self.navigationController?.pushViewController(onboardingAgeScreen, animated: true)
        
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
