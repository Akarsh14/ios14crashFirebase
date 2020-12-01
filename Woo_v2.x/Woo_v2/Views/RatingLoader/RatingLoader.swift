//
//  RatingLoader.swift
//  Woo_v2
//
//  Created by Vaibhav Gautam on 17/08/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class RatingLoader: UIView {

    @IBOutlet weak var firstStar: UIButton!
    @IBOutlet weak var secondStar: UIButton!
    @IBOutlet weak var thirdStar: UIButton!
    @IBOutlet weak var fourthStar: UIButton!
    @IBOutlet weak var fifthStar: UIButton!
    
    @IBOutlet weak var centreView: UIView!
    
    @IBOutlet weak var firstActionButton: UIButton!
    
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallDescriptionLabel: UILabel!
    var selectedStar:CUnsignedInt = 0
    var areButtonsVisible:Bool = false
    
    var sendFeedbackHandler:((_ selectedStars: Int) -> (Void))?

    
    
    @IBAction func starTapped(_ sender: AnyObject) {
        
        let starRef:UIButton = (sender as? UIButton)!
        
        switch starRef {
        case firstStar:
            selectedStar = 1
            break
            
        case secondStar:
            selectedStar = 2
            break
            
        case thirdStar:
            selectedStar = 3
            break
            
        case fourthStar:
            selectedStar = 4
            break
            
        case fifthStar:
            selectedStar = 5
            break
            
        default:
            
            break
        }
        
        self.updateUIForRatingPopup()
        self.updateActionButtons()
        self.updateStars()

    }
    
    func updateUIForRatingPopup(){
        
        
        if selectedStar > 0 && areButtonsVisible == false{
            actionView.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.heightConstraint.constant = 232
                self.centreView.updateConstraints()
                
            })
            areButtonsVisible = true
        }
        
    }
    
    
    func updateActionButtons() {
        
        if selectedStar == 5 {
            
            smallDescriptionLabel.text = NSLocalizedString("We love you too! Let's tell the world.", comment: "5 stars small desctiption text")
            firstActionButton.setTitle(NSLocalizedString("Rate Us On The App Store", comment: "Rating text"), for: UIControl.State())
            
        }else{
            
            smallDescriptionLabel.text = NSLocalizedString("Tell us why.", comment: "5 stars small desctiption text")
            firstActionButton.setTitle(NSLocalizedString("Share Your Feedback", comment: "share feedback text"), for: UIControl.State())
            
        }
    }
    
    func updateStars(){
        switch selectedStar {
        case 1:
            firstStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            secondStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            thirdStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            fourthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            fifthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            break
        case 2:
            firstStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            secondStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            thirdStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            fourthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            fifthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            break
        case 3:
            firstStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            secondStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            thirdStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            fourthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            fifthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            break
        case 4:
            firstStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            secondStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            thirdStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            fourthStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            fifthStar.setBackgroundImage(UIImage(named: "rateStarDeselected"), for: UIControl.State())
            break
        case 5:
            firstStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            secondStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            thirdStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            fourthStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            fifthStar.setBackgroundImage(UIImage(named: "rateStarSelected"), for: UIControl.State())
            break
            
        default:
            
            break
        }
    }
    
    
    
    @IBAction func firstActionButtonTapped(_ sender: AnyObject) {
        
        if selectedStar == 5 {
            //open app store and inform server
            
            UIApplication.shared.openURL(URL(string:"itms-apps://itunes.apple.com/app/id885397079")!)
            self .removeFromSuperview()
            // make api call
            AppSettingsApiClass.sendFeedback(toServer: "", andNumberOfStars: 5, andEmail: "", andPhoneNumber: "", withCompletionBlock: { (success, response, statusCode) in
                
                UserDefaults.standard.set(true, forKey: kUserSubmittedV3Feedback)
                UserDefaults.standard.synchronize()
                
            })
            
        }else{
            //open feedback and inform server
            if sendFeedbackHandler != nil {
                self.sendFeedbackHandler!(Int(selectedStar))
            }
            
            UserDefaults.standard.set(Date(timeIntervalSinceReferenceDate: kCFAbsoluteTimeIntervalSince1970), forKey: "remindMePopupTimestampV3")
            UserDefaults.standard.synchronize()
            
            self.removeFromSuperview()
            
        }
    }
    
    @IBAction func remindButtonTapped(_ sender: AnyObject) {
        
            UserDefaults.standard.set(Date(), forKey: kRemindMePopupTimestampV3)
            UserDefaults.standard.synchronize()
           self.removeFromSuperview()
        
    }
    
    
    class func loadPopup(_ frame : CGRect) -> RatingLoader {
        let array = Bundle.main.loadNibNamed("RatingLoader", owner: self, options: nil)
        let view : RatingLoader? = array?.first as? RatingLoader
        
        view?.frame = frame
        
        return view!
    }
    
    func addRatingPopupOnTop() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    
}
