//
//  WizardCompleteView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 08/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

class WizardCompleteView: UIView {

    @IBOutlet weak var progressBarViewCenterCOnstraint: NSLayoutConstraint!
    @IBOutlet weak var completedLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var continueEditingButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var profileCompletenessLabel: UILabel!
    @IBOutlet weak var profileCompletenessBar: ArcProgressbar!
    
    var closeWizardHandler : (() -> ())?
    var continueHandler : (() -> ())?

    var myProfile:MyProfileModel?
    
    var isTypeComplete = false
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //MARK: View Lifecycle method
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func showView(_ isCompleted : Bool) -> WizardCompleteView{
        
        let window : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let wizardCompletePopup: WizardCompleteView =
            Bundle.main.loadNibNamed("WizardCompleteView", owner: window.rootViewController, options: nil)!.first as! WizardCompleteView
        wizardCompletePopup.frame = window.frame
        wizardCompletePopup.alpha = 0.0
        wizardCompletePopup.setDataForView(isCompleted)
        wizardCompletePopup.isTypeComplete = isCompleted

        if window.subviews.count > 1 {// If Any view is presented
            let window2 = window.subviews.first! as UIView // UIView cannot be added to UITransitionView. So add to its subview
            //            if window2 is MDSnackbar {
            //                window2.removeFromSuperview()
            //            }
            // window2 = window.subviews.last! as UIView
            (window2.subviews.first! as UIView).addSubview(wizardCompletePopup)
        }
        else{
            if String(describing: ((((UIApplication.shared.delegate?.window)!!.subviews).last)?.classForCoder)!) == "UITransitionView" { // If the top view is UITransitionView we have to add the view to its container subview
                let window2 = window.subviews.last! as UIView // UIView cannot be added to UITransitionView. So add to its subview
                (window2.subviews.last! as UIView).addSubview(wizardCompletePopup)
            }
            else{
                (window.subviews.first! as UIView).addSubview(wizardCompletePopup)
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            wizardCompletePopup.alpha = 1.0
        })
        
        return wizardCompletePopup
    }
    
    func setDataForView(_ isCompleted:Bool){
        
        if SCREEN_WIDTH == 320{
            containerViewHeightConstraint = containerViewHeightConstraint.setMultiplier(multiplier: 0.8)
        }
        
        myProfile = DiscoverProfileCollection.sharedInstance.myProfileData
        
        if let imageUrl = myProfile?.wooAlbum?.profilePicUrl()
        {
            profileImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_wizard_default_avatar"), options: SDWebImageOptions.retryFailed, completed: { (image, error, cacheType, url) in
            
            })
        }
        else
        {
            profileImage.image = UIImage(named: "ic_wizard_default_avatar")
        }
        profileCompletenessBar.isShownInWizard = true
        profileCompletenessBar.progressValue = CGFloat(truncating: NumberFormatter().number(from: (myProfile?.profileCompletenessScore ?? "0")!)!)
        profileCompletenessBar.animateCircle()
        profileCompletenessLabel.text = "\(Int(profileCompletenessBar.progressValue))%"
        addGradientToView()
        var bottomText = ""
        
        if isCompleted{
            if DiscoverProfileCollection.sharedInstance.discoverModelCollection.count > 0{
                bottomText = "Continue to discover to meet\nlike-minded people"
            }
            else{
                if myProfile?.gender == "MALE"{
                    bottomText = "Check out who visited or liked you for instant connections"
                }
                else{
                    bottomText = "Check out who visited or liked you for an instant connection."
                }
            }
            continueEditingButton.isHidden = true
            laterButton.isHidden = true
            progressBarViewCenterCOnstraint.constant = 0
            topLabel.font = UIFont(name: "Lato-Bold", size: 24.0)
            if myProfile?.gender == "MALE"{
                topLabel.attributedText = NSAttributedString(string: "Profile visiblity high")
                completedLabel.text = "Your profile is \(Int(profileCompletenessBar.progressValue))% complete"
                
            }
            else{
                topLabel.attributedText = NSAttributedString(string: "Good Job!")

            }
            self.perform(#selector(removeViewAfterSomeTime), with: nil, afterDelay: 2.4)
            
        }
        else{
            if myProfile?.gender == "MALE"{
                bottomText = "Complete upto \(AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold)% to increase your popularity"
            }
            else{
                bottomText = "Complete upto \(AppLaunchModel.sharedInstance().profileCompletenessFallbackThreshold)% for a higher chance to meet the right people."
            }
            activityIndicator.isHidden = true
            completedLabel.isHidden = true
            completedLabelHeightConstraint.constant = 0
            var lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 18.0)! ]
                    let lString = NSMutableAttributedString(string: "Your profile is\n", attributes: lAttribute )
            lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 22.0)! ]
                        let attrString = NSAttributedString(string: " " + "\(Int(profileCompletenessBar.progressValue))% complete", attributes: lAttribute )
                        lString.append(attrString)
                    topLabel.attributedText = lString
        }
        bottomLabel.text = bottomText
    }
    
    @objc fileprivate func removeViewAfterSomeTime(){
        closeWizardHandler!()
        self.removeFromSuperview()
    }
    
    func addGradientToView(){
        
        let gradientForView:CAGradientLayer = CAGradientLayer()

        let utilities = Utilities.sharedUtility() as! Utilities

        let topColor = utilities.getUIColorObject(fromHexString: "#75C4DB", alpha: 1.0).cgColor
        let bottomColor = utilities.getUIColorObject(fromHexString: "#9275DB", alpha: 1.0).cgColor

            gradientForView.colors = [topColor, bottomColor]
            gradientForView.locations = [0.0, 0.7]
            gradientForView.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientForView.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        gradientForView.frame = CGRect(x: 0, y: 0,
                                       width: UIScreen.main.bounds.width,
                                       height: UIScreen.main.bounds.height)
            containerView.layer.insertSublayer(gradientForView, at: 0)
    }
    @IBAction func dismissView(_ sender: Any) {
        if isTypeComplete{
            closeWizardHandler!()
        }
        self.removeFromSuperview()
    }
    
    @IBAction func continueEditing(_ sender: Any) {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Close_Continue")
        if continueHandler != nil{
            continueHandler!()
        }
        self.removeFromSuperview()
    }
    @IBAction func laterButtonTapped(_ sender: Any) {
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "AnalyzeProfile_Close_Later")
        closeWizardHandler!()
        self.removeFromSuperview()
    }
    
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
