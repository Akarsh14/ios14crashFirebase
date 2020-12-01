//
//  PerformanceAnalysisViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 23/12/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

class PerformanceAnalysisViewController: UIViewController {

    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineView: BezierView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topViewSecondLabel: UILabel!
    @IBOutlet weak var topViewFirstLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dottedLineImageView: UIImageView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var smallLineView: BezierView!
    let dataPoints = [150, 40, 0, 130, 80, 50, 150, 150]
    
    @IBOutlet weak var profileFetchIndicator: UIActivityIndicatorView!
    var dataIsRefreshed = false
    var buttonTapped = false
    var bezierViewWidth:Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshProfileData()
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        if SYSTEM_VERSION_LESS_THAN(version: "11"){
            viewTopConstraint.constant = 0
        }
        userImageView.sd_setImage(with: URL(string: (DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicUrl()) ?? ""), placeholderImage: UIImage(named: "ic_wizard_default_avatar"), options: SDWebImageOptions(), completed: { (image, error, cacheType, url) in
            
        })
        
        if DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE"{
            topViewFirstLabel.text = "Low Profile Visibility"
            topViewSecondLabel.text = "Low visibility due to low profile completion"
        }
        else{
            topViewFirstLabel.text = "Lower probability of meeting \nlike-minded people"
            topViewSecondLabel.text = "Due to low profile completion"
        }
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Landing")


        initiateGraph()
        
        activityIndicator.startAnimating()
        self.perform(#selector(nowShowGraph), with: nil, afterDelay: 1.0)

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         colorTheStatusBar(withColor: UIColorHelper .color(fromRGB: "#9275DB", withAlpha: 1.0))
        //SwipeBack
        if let nav = self.navigationController{
            nav.swipeBackEnabled = false
        }
    }
    func refreshProfileData(){
        guard let wooId = UserDefaults.standard.object(forKey: "id") else {
            return
        }
        let userIdNum: CLongLong = Int64(wooId as! String)!
        ProfileAPIClass.fetchDataForUser(withUserID: userIdNum) { (response, success, statusCode) in
            if success{
                DiscoverProfileCollection.sharedInstance.updateMyProfileData(response as! NSDictionary)
                self.dataIsRefreshed = true
                if self.buttonTapped{
                    self.startFlowNow()
                }
            }
        }
    }
    
    func initiateGraph(){
        if SCREEN_WIDTH == 320{
            smallLineView.isHidden = false
            lineView.isHidden = true
            smallLineView.dataSource = self
            bezierViewWidth = smallLineView.frame.width.f
            bottomLabelBottomConstraint.constant = 10
            topLabelTopConstraint.constant = 10
        }
        else if SCREEN_WIDTH == 375{
            smallLineView.isHidden = true
            lineView.isHidden = false
            lineView.dataSource = self
            bezierViewWidth = 230
        }
        else if SCREEN_WIDTH == 414{
            lineViewTopConstraint.constant = -10
            smallLineView.isHidden = true
            lineView.isHidden = false
            lineView.dataSource = self
            bezierViewWidth = lineView.frame.width.f
        }
    }
    
    @objc func nowShowGraph(){
        activityIndicator.stopAnimating()
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseIn, animations: {
            self.avatarView.alpha = 1
            self.topViewFirstLabel.alpha = 1
            self.topViewSecondLabel.alpha = 1
        }) { (complete) in
            UIView.animate(withDuration: 0.3, animations: {
                self.dottedLineImageView.alpha = 1
            })
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if SCREEN_WIDTH == 320{
            smallLineView.layoutSubviews()
        }
        else{
            lineView.layoutSubviews()
        }

    }
    
    
    @IBAction func startWizardFlow(_ sender: Any) {
        if dataIsRefreshed{
            startFlowNow()
        }
        else{
            self.buttonTapped = true
            profileFetchIndicator.startAnimating()
        }
    }
    
    func startFlowNow(){
        profileFetchIndicator.stopAnimating()
        self.buttonTapped = false
        WizardScreensCalculator.sharedInstance.wizardScreenArray = NSMutableArray(array: AppLaunchModel.sharedInstance().profileWidgetsArray)
        WizardScreensCalculator.sharedInstance.totalNumberOfWizardScreens = WizardScreensCalculator.sharedInstance.wizardScreenArray.count
        WizardScreensCalculator.sharedInstance.wizardScreenNavigationController = self.navigationController
        WizardScreensCalculator.sharedInstance.updateWizardScreenArrayBasedOnDataAlreadyPresent()
        WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
    }
    
    @IBAction func goBack(_ sender: Any) {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Close")
        showWizardCompleteView()
    }
    
    func showWizardCompleteView(){
        let wizardPopupView:WizardCompleteView = WizardCompleteView.showView(false)
        wizardPopupView.closeWizardHandler = {() in
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Complete")
            self.navigationController?.popToRootViewController(animated: true)
        }
        wizardPopupView.continueHandler = {() in
            self.startWizardFlow(UIButton())
        }
    }
    
    
    // line Calculation Methods
    var xAxisPoints : [Double] {
        var points = [Double]()
        for i in 0..<dataPoints.count {
            let val = (Double(i)/6.0) * bezierViewWidth
            points.append(val)
        }
        
        return points
    }
    
    var yAxisPoints: [Double] {
        var points = [Double]()
        for i in dataPoints {
            let val = (Double(i)/255) * bezierViewWidth
            points.append(val)
        }
        
        return points
    }
    
    var graphPoints : [CGPoint] {
        var points = [CGPoint]()
        for i in 0..<dataPoints.count {
            let val = CGPoint(x: self.xAxisPoints[i], y: self.yAxisPoints[i])
            points.append(val)
        }
        
        return points
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

extension PerformanceAnalysisViewController: BezierViewDataSource {
    
    func bezierViewDataPoints(_ bezierView: BezierView) -> [CGPoint] {
        
        return graphPoints
    }
}
