//
//  WizardGlobalCitizenViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 05/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

enum GlobalCitizenCellType : String{
    case GlobalCitizenHeaderCell  = "GlobalCitizenHeaderCell"
    case EthnicityCell = "EthnicityCell"
}

import UIKit

class WizardGlobalCitizenViewController: UIViewController {

    @IBOutlet weak var ethnicity2Arrow: UIImageView!
    @IBOutlet weak var ethnicity1Arrow: UIImageView!
    @IBOutlet weak var religionArrow: UIImageView!
    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var religionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ethnicityViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewCounterLabel: UILabel!
    @IBOutlet weak var religionButton: UIButton!
    @IBOutlet weak var religionButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondEthnicityButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondEthnicityButton: UIButton!
    @IBOutlet weak var firstEthnicityButton: UIButton!
    fileprivate var dataArray : NSMutableArray = []
    
    var isCloseTapped = false
    var isReligionChanged = false
    var isEthnicityChanged = false

    fileprivate var profileData : MyProfileModel?
    
    var ethnicity1ShapeLayer:CAShapeLayer?
    var ethnicity2ShapeLayer:CAShapeLayer?
    var religionShapeLayer:CAShapeLayer?

    var customLoader:WooLoader?
    
    var currentReligionId:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            closeTopConstraint.constant = 40
        }
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Religion_Landing")

//        drawBorderAroundBtn(forButton: firstEthnicityButton, withWidth: firstEthnicityButton.frame.size.width + 5)
        drawBorderAroundBtn(forButton: religionButton, withWidth: religionButton.frame.size.width + 5)
        
        self.isEthnicityChanged = false
        self.isReligionChanged = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileData = DiscoverProfileCollection.sharedInstance.myProfileData
        currentReligionId = profileData?.selectedReligion().tagId
        updateEthncityAndReligionButtonText()
        setupBottomArea()
    }
    
    func updateEthncityAndReligionButtonText(){
        
        var ethnicityArrayToShow = profileData?.ethnicity

        if (ethnicityArrayToShow?.count)! > 0 {
            
            ethnicityArrayToShow?.removeAll()
                
            for ethItem in (profileData?.ethnicity)! {
                    if ethItem.isSelected == true {
                        ethnicityArrayToShow?.append(ethItem)
                    }
                }
            }

        if (ethnicityArrayToShow?.count)! > 0{
            if (ethnicityArrayToShow?.count)! > 1{
//                firstEthnicityButton.setTitle((ethnicityArrayToShow?.first?.name)!, for: .normal)
//                ethnicity1Arrow.isHidden = false
//                secondEthnicityButton.setTitle((ethnicityArrayToShow?.last?.name)!, for: .normal)
//                ethnicity2Arrow.isHidden = false
//                secondEthnicityButtonWidthConstraint.constant = 80.0
//                drawBorderAroundBtn(forButton: secondEthnicityButton, withWidth: 85.0)
//                ethnicityViewWidthConstraint.constant = 300.0
            }
            else{
//                firstEthnicityButton.setTitle((ethnicityArrayToShow?.first?.name)!, for: .normal)
//                ethnicity1Arrow.isHidden = false
//                secondEthnicityButton.setTitle("+", for: .normal)
//                ethnicity2Arrow.isHidden = true
//                secondEthnicityButtonWidthConstraint.constant = 30.0
//                ethnicityViewWidthConstraint.constant = 250.0
//                drawBorderAroundBtn(forButton: secondEthnicityButton, withWidth: 35)
            }
        }
        else{
//            firstEthnicityButton.setTitle("Select +", for: .normal)
//            ethnicity1Arrow.isHidden = true
//            secondEthnicityButton.setTitle("+", for: .normal)
//            ethnicity2Arrow.isHidden = true
//            secondEthnicityButtonWidthConstraint.constant = 30.0
//            ethnicityViewWidthConstraint.constant = 250.0
//            drawBorderAroundBtn(forButton: secondEthnicityButton, withWidth: 35)
        }
        
        if profileData?.selectedReligion() != nil{
            if (profileData?.selectedReligion().isSelected)!{
                religionButton.setTitle((profileData?.selectedReligion().name)!, for: .normal)
                religionArrow.isHidden = false
            }
            else{
                religionButton.setTitle("Select +", for: .normal)
                religionArrow.isHidden = true
            }
        }
        else{
            religionButton.setTitle("Select +", for: .normal)
            religionArrow.isHidden = true
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
    @IBAction func moveToEthnicityScreen(_ sender: Any) {
        openEthnicityScreen()
    }
    
    @IBAction func moveToReligionScreen(_ sender: Any) {
        openReligionScreen()
    }
    @IBAction func next(_ sender: Any) {
        isCloseTapped = false
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Religion_Next")

        if isReligionChanged || isEthnicityChanged{
        if checkIfFlowIsComplete(){
            showWooLoader()
            sendDataToServer()
        }
        else{
            sendDataToServer()
            WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
            isReligionChanged = false
            isEthnicityChanged = false
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
        //self.navigationController?.popViewController(animated: true)
        
        if WizardScreensCalculator.sharedInstance.isCropperVisible == true && WizardScreensCalculator.sharedInstance.currentWizardScreen == 1 {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
           
            WizardScreensCalculator.sharedInstance.isCropperVisible = false
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        isCloseTapped = true
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            WizardScreensCalculator.sharedInstance.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Religion_Close")

        if isReligionChanged || isEthnicityChanged{
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
    
    func sendDataToServer(){
        let myProfileDictionary : NSMutableDictionary = NSMutableDictionary()
        var _ethnicity : [NSMutableDictionary] = []
        if isEthnicityChanged && isReligionChanged{
        for item in (profileData?.ethnicity)!{
            _ethnicity.append((item.dictionarify()))
        }
        
        var _religion : [NSMutableDictionary] = []
        
        let item = profileData?.selectedReligion()
        
        if item?.name != "Select" && (item?.isSelected)! {
            _religion.append((item?.dictionarify())!)
            myProfileDictionary["religion"] = _religion
        }
        myProfileDictionary["ethnicity"] = _ethnicity
        }
        else if isEthnicityChanged{
            for item in (profileData?.ethnicity)!{
                _ethnicity.append((item.dictionarify()))
            }
            myProfileDictionary["ethnicity"] = _ethnicity
        }
        else if isReligionChanged{
            var _religion : [NSMutableDictionary] = []
            
            let item = profileData?.selectedReligion()
            
            if item?.name != "Select" && (item?.isSelected)! {
                _religion.append((item?.dictionarify())!)
                myProfileDictionary["religion"] = _religion
            }
        }
        WizardScreensCalculator.sharedInstance.updateProfileForDictionary((DiscoverProfileCollection.sharedInstance.myProfileData?.jsonfyForDictionary(myProfileDictionary))!)
        
        WizardScreensCalculator.sharedInstance.editProfileApiCompletionHandler = {(success) in
            let currenViewControllerIsSelf = self.navigationController?.viewControllers.last is WizardGlobalCitizenViewController
            if !currenViewControllerIsSelf{
                if success{
                    self.isEthnicityChanged = false
                    self.isReligionChanged = false
                WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                }
                return
            }
            self.hideWooLoader()
            if self.isCloseTapped{
                self.isCloseTapped = false
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                    else{
                        self.isReligionChanged = false
                        self.isEthnicityChanged = false
                    if Int((DiscoverProfileCollection.sharedInstance.myProfileData?.profileCompletenessScore)!)! < AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold{
                        self.showWizardCompleteView(false)
                    }
                    else{
                        self.checkIfToShowDiscoverOrMe()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                        WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
                    }
                }
            }
            else{
                if success{
                    if self.checkIfFlowIsComplete(){
                        self.showWizardCompleteView(true)
                    }
                    else{
                    WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
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
    
    func showWizardCompleteView(_ isCompleted:Bool){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(isCompleted)
        wizardPopupView.closeWizardHandler = {() in
            self.checkIfToShowDiscoverOrMe()
            if isCompleted && (self.isReligionChanged || self.isEthnicityChanged){
                WizardScreensCalculator.sharedInstance.makeDiscoverCallIfRequired()
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawBorderAroundBtn(forButton btnObj:UIButton, withWidth widthVal:CGFloat){
        let color = Utilities().getUIColorObject(fromHexString: "D7D7D7", alpha: 1.0).cgColor
        
        if btnObj == firstEthnicityButton{
            if ethnicity1ShapeLayer != nil{
                ethnicity1ShapeLayer?.removeFromSuperlayer()
                ethnicity1ShapeLayer = nil
            }
            ethnicity1ShapeLayer = CAShapeLayer()
            let frameSize = btnObj.frame.size
            let shapeRect = CGRect(x: 0, y: 0, width: widthVal, height: frameSize.height)
            
            ethnicity1ShapeLayer?.bounds = shapeRect
            ethnicity1ShapeLayer?.position = CGPoint(x: widthVal/2, y: frameSize.height/2)
            ethnicity1ShapeLayer?.fillColor = UIColor.clear.cgColor
            ethnicity1ShapeLayer?.strokeColor = color
            ethnicity1ShapeLayer?.lineWidth = 1
            ethnicity1ShapeLayer?.lineJoin = CAShapeLayerLineJoin.miter
            ethnicity1ShapeLayer?.lineDashPattern = [1,1]
            ethnicity1ShapeLayer?.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
            
            btnObj.layer.addSublayer(ethnicity1ShapeLayer!)
        }
        else if btnObj == secondEthnicityButton{
            if ethnicity2ShapeLayer != nil{
                ethnicity2ShapeLayer?.removeFromSuperlayer()
                ethnicity2ShapeLayer = nil
            }
            ethnicity2ShapeLayer = CAShapeLayer()
            let frameSize = btnObj.frame.size
            let shapeRect = CGRect(x: 0, y: 0, width: widthVal, height: frameSize.height)
            
            ethnicity2ShapeLayer?.bounds = shapeRect
            ethnicity2ShapeLayer?.position = CGPoint(x: widthVal/2, y: frameSize.height/2)
            ethnicity2ShapeLayer?.fillColor = UIColor.clear.cgColor
            ethnicity2ShapeLayer?.strokeColor = color
            ethnicity2ShapeLayer?.lineWidth = 1
            ethnicity2ShapeLayer?.lineJoin = CAShapeLayerLineJoin.miter
            ethnicity2ShapeLayer?.lineDashPattern = [1,1]
            ethnicity2ShapeLayer?.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
            
            btnObj.layer.addSublayer(ethnicity2ShapeLayer!)
            
        }
        else if btnObj == religionButton{
            if religionShapeLayer != nil{
                religionShapeLayer?.removeFromSuperlayer()
                religionShapeLayer = nil
            }
            religionShapeLayer = CAShapeLayer()
            let frameSize = btnObj.frame.size
            let shapeRect = CGRect(x: 0, y: 0, width: widthVal, height: frameSize.height)
            
            religionShapeLayer?.bounds = shapeRect
            religionShapeLayer?.position = CGPoint(x: widthVal/2, y: frameSize.height/2)
            religionShapeLayer?.fillColor = UIColor.clear.cgColor
            religionShapeLayer?.strokeColor = color
            religionShapeLayer?.lineWidth = 1
            religionShapeLayer?.lineJoin = CAShapeLayerLineJoin.miter
            religionShapeLayer?.lineDashPattern = [1,1]
            religionShapeLayer?.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
            
            btnObj.layer.addSublayer(religionShapeLayer!)
            
        }
    }
    
    func containSameElements(_ firstArray: [String],secondArray: [String]) -> Bool {
        var first = firstArray
        var second = secondArray
        if first.count != second.count {
            return false
        } else {
            first.sort()
            second.sort()
            return first == second
        }
    }

    
    func openEthnicityScreen() {
        let optionScreen = EthnicitySelectionViewController.loadNib()
        optionScreen.mainDataSource = NSArray(contentsOfFile: Bundle.main.path(forResource: "Ethnicity", ofType:"plist")!)!
        optionScreen.maxmimumSelection = 2
        optionScreen.showSwitchButton = false
        if (self.profileData?.ethnicity.count)! > 0 {
            optionScreen.selectedEthnicity = []
            
            for ethItem in (self.profileData?.ethnicity)! {
                if ethItem.isSelected == true {
                    let ethnicityName = ethItem.name
                    optionScreen.selectedEthnicity.append(ethnicityName!)
                }
            }
            
            //            for item in (self.profileData?.ethnicity)! {
            //                let ethnicityName = item.name
            //                optionScreen.selectedEthnicity.append(ethnicityName!)
            //            }
        }
        
        optionScreen.selectionHandler = { (selectedData) in
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Religion_AddEthnicity")
            //            for ethItem in selectedData {
            //                ethItem.isSelected = true
            //            }
            let selectedEhtnicity = (self.profileData?.professionModelArrayFromDto((selectedData as? [[String : AnyObject]])!))!
            let selectedEthnicityArray = NSMutableArray()
            for ethncity in selectedEhtnicity{
                selectedEthnicityArray.add(ethncity.tagId!)
            }
            let ethnicityBefore = NSMutableArray()
            for ethncity in (self.profileData?.ethnicity)!{
                ethnicityBefore.add(ethncity.tagId!)
            }
            if self.containSameElements(ethnicityBefore as! [String], secondArray: selectedEthnicityArray as! [String]){
                self.isEthnicityChanged = false
            }
            else{
                self.isEthnicityChanged = true
            }
            var currentEthnicityArray = self.profileData?.ethnicity
            for ethItem in selectedEhtnicity {
                ethItem.isSelected = true
            }
            var index = 0
            while index < (currentEthnicityArray?.count)! {
                if selectedEhtnicity.count > index {
                    currentEthnicityArray?[index] = selectedEhtnicity[index].copy()
                }
                index += 1
            }
            self.profileData?.ethnicity = selectedEhtnicity
            self.updateEthncityAndReligionButtonText()

//            BrandCardAPI.updateSelectionCardPassStatus(onServer: "ETHNICITY", and: "0", andSelectedValues: selectedEhtnicity, withCompletionHandler: { (success, ethnicityResponse) in
//                let selectedEhtnicity = (self.profileData?.professionModelArrayFromDto((ethnicityResponse as? [[String : AnyObject]])!))!
//                self.profileData?.ethnicity = selectedEhtnicity
//                self.updateEthncityAndReligionButtonText()
//            })
            
        }
        optionScreen.viewControllerType = EthnicityClassType.TYPE_ETHNICITY
        self.navigationController?.pushViewController(optionScreen, animated: true)
        //present(optionScreen, animated: true, completion: nil)
    }
    
    func openReligionScreen(){
        let optionScreen = OptionSelectionViewController.loadNib("Religion")
        let religionArrayWithoutdoesntMatter = NSMutableArray.init(array: (profileData?.religion)!)
        religionArrayWithoutdoesntMatter.removeLastObject()
        optionScreen.dataSourceArr = NSArray.init(array: religionArrayWithoutdoesntMatter) as! [ProfessionModel]
        optionScreen.showSearchBar = false
        optionScreen.selectionHandler = { (tagId) in
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Religion_AddReligion")
            if !tagId .isEqual("") {
                if self.profileData?.selectedReligion() != nil{
                    if self.currentReligionId == tagId{
                        self.isReligionChanged = false
                    }
                    else{
                        self.isReligionChanged = true
                    }
                }
                else{
                    self.isReligionChanged = false
                }
                self.profileData?.setSelectedReligion(tagId)
            }
            self.updateEthncityAndReligionButtonText()
        }
        self.navigationController?.pushViewController(optionScreen, animated: true)
    }

}

