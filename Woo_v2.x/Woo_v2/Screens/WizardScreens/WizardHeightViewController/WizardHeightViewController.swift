//
//  WizardHeightViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 06/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage
import VerticalSlider

class WizardHeightViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var heightSlider: VerticalSlider!

    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewCounterLabel: UILabel!
    
    @IBOutlet weak var maximumHeightLabel: UILabel!
    @IBOutlet weak var minimumHeightLabel: UILabel!
    @IBOutlet weak var currentHeight: UILabel!
    fileprivate var profileData : MyProfileModel?
    
    var isCloseTapped = false
    var customLoader:WooLoader?
    var oldHeight = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        
//        if WizardScreensCalculator.sharedInstance.isCropperVisible == true {
//            print("yes popup me ghusa")
//            WizardScreensCalculator.sharedInstance.cropPickerNavigationController?.popViewController(animated: false)
//            WizardScreensCalculator.sharedInstance.isCropperVisible = false
//        }
        
        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            closeTopConstraint.constant = 40
        }
        heightSlider.slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Height_Landing")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileData = DiscoverProfileCollection.sharedInstance.myProfileData
        setValuesForHeightLabels()
        setupBottomArea()
    }
    
    func setValuesForHeightLabels(){
        if let height : Float = heightSlider.minimumValue{
            let feetInchValue : String =  (Utilities.sharedUtility() as AnyObject).getfeetAndInches(height)
            print(feetInchValue)
            minimumHeightLabel.text = feetInchValue
        }
        
        if let height : Float = heightSlider.maximumValue{
            let feetInchValue : String =  (Utilities.sharedUtility() as AnyObject).getfeetAndInches(height)
            print(feetInchValue)
            maximumHeightLabel.text = feetInchValue
        }
        
        if profileData?.height != nil{
            currentHeight.text = profileData?.height
            let centimeterValue : String =  (Utilities.sharedUtility() as AnyObject).getCentimeterFromFeetInches(profileData?.height)
            heightSlider.value = Float(centimeterValue)!
            oldHeight = (profileData?.height)!
        }
        else{
            heightSlider.value = heightSlider.minimumValue
            let currentHeightInFloat = heightSlider.value
            let currentHeightString : String = (Utilities.sharedUtility() as AnyObject).getfeetAndInches(currentHeightInFloat)
            currentHeight.text = currentHeightString
        }
        if heightSlider.value == heightSlider.minimumValue{
            currentHeight.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#E8E8E8", alpha: 1.0)
        }
        else{
            currentHeight.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#75C4DB", alpha: 1.0)
        }
    }
    
    func setupBottomArea(){
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            nextButton.setTitle("DONE", for: .normal)
        }
        else if WizardScreensCalculator.sharedInstance.currentWizardScreen == 1{
            backButton.isHidden = true
        }
        viewCounterLabel.text = "\(WizardScreensCalculator.sharedInstance.currentWizardScreen) of \(WizardScreensCalculator.sharedInstance.wizardScreenArray.count)"
    }
    
    func updateCurrentHeightValue(){
        let currentHeightInFloat = heightSlider.value
        let currentHeightString : String = (Utilities.sharedUtility() as AnyObject).getfeetAndInches(currentHeightInFloat)
        profileData?.height = currentHeightString
        currentHeight.text = profileData?.height
    }
    
    @objc func sliderChanged() {
        updateCurrentHeightValue()
        if heightSlider.value == heightSlider.minimumValue{
            currentHeight.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#E8E8E8", alpha: 1.0)
        }
        else{
        currentHeight.textColor = (Utilities.sharedUtility() as AnyObject).getUIColorObject(fromHexString: "#75C4DB", alpha: 1.0)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        isCloseTapped = true
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Height_Close")

        var newHeight = ""
        if let currentHeight = profileData?.height{
            newHeight = currentHeight
        }
        
        if oldHeight != newHeight{
            showWooLoader()
            sendDataToServer()
        }
        else{
            
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
    }
    
    func showWizardCompleteView(_ isCompleted:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func checkIfFlowIsComplete() -> Bool{
        if WizardScreensCalculator.sharedInstance.currentWizardScreen == WizardScreensCalculator.sharedInstance.wizardScreenArray.count{
            return true
        }
        else{
            return false
        }
    }
    
    func sendDataToServer(){
        let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        
        myProfileDictionary["height"] = profileData?.height
        
        profileData?.showHeightType = .INCHES
        myProfileDictionary["showHeightType"] = profileData?.showHeightType.rawValue
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary))!)
        
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Height_Add")
            let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is WizardHeightViewController
            if !currenViewControllerIsSelf{
                return
            }
            self.hideWooLoader()
            if self.isCloseTapped{
                self.isCloseTapped = false
                if success{
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
            }
            else{
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                }
            }
        }
    }
    
    func checkIfToShowDiscoverOrMe(){
        if DiscoverProfileCollection.sharedInstance.discoverModelCollection.count > 0{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(1)
        }
        else{
            WooScreenManager.sharedInstance.oHomeViewController?.moveToTab(0)
        }
    }
    
    func showWooLoader(){
        customLoader?.removeFromSuperview()
        customLoader = nil
        if customLoader == nil {
            let loaderFrame:CGRect = CGRect(x: 0, y: 34, width: SCREEN_WIDTH , height: SCREEN_HEIGHT - 64)
            customLoader = WooLoader.init(frame: loaderFrame)
        }
        customLoader?.shouldShowWooLoader = false
        
        customLoader?.startAnimation(on: self.view, withBackGround: false)
    }
    
    func hideWooLoader(){
        
        UIView .animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
        }, completion: { (true) in
            self.customLoader?.stopAnimation()
            self.customLoader?.removeFromSuperview()
        })
        
    }
    
    
    @IBAction func next(_ sender: Any) {
        isCloseTapped = false
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Height_Next")
        var newHeight = ""
        if let currentHeight = profileData?.height{
            newHeight = currentHeight
        }
        if oldHeight != newHeight{
            if checkIfFlowIsComplete(){
                showWooLoader()
                sendDataToServer()
            }
            else{
                sendDataToServer()
                WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
            }
        }
        else{
            if self.checkIfFlowIsComplete(){
                self.showWizardCompleteView(true)
            }
            else{
                WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        WizardScreensCalculator.sharedInstance.currentWizardScreen = WizardScreensCalculator.sharedInstance.currentWizardScreen - 1
        
//        self.navigationController?.popViewController(animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if WizardScreensCalculator.sharedInstance.isCropperVisible == true && WizardScreensCalculator.sharedInstance.currentWizardScreen == 1 {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
               
                WizardScreensCalculator.sharedInstance.isCropperVisible = false
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
