//
//  FemaleTutorialCollectionViewCell.swift
//  Woo_v2
//
//  Created by Akhil Singh on 01/05/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

class FemaleTutorialCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var firstLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var startImageView: UIImageView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var unmatchImageView: UIImageView!
    @IBOutlet weak var blockReportImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var screen1Label: UILabel!
    
    let animationDuration = 0.3
    let animationDelay = 0.3 * 2
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateViewBasedOnViewType(_ tutorialType:TutorialViewType, isShownInOnBoarding:Bool){

        if SCREEN_WIDTH == 320{
            firstLabelTopConstraint.constant = 15.0
        }
        leftImageView.alpha = 0
        rightImageView.alpha = 0
        callImageView.alpha = 0
        unmatchImageView.alpha = 0
        blockReportImageView.alpha = 0
        likeImageView.alpha = 0
        screen1Label.alpha = 0
        mainImageView.isHidden = false
        startImageView.isHidden = true
        self.firstLabel.alpha = 0
        self.secondLabel.alpha = 0
        firstLabel.transform = CGAffineTransform.identity
        secondLabel.transform = CGAffineTransform.identity
        likeImageView.transform = CGAffineTransform.identity

        switch tutorialType {
        case .Name:
            var baseString = ""
            if isShownInOnBoarding{
                firstLabel.text = "Woo is safe"
                baseString = baseTutorialString
            }
            else{
                baseString = baseSecretTutorialString
                firstLabel.text = "Remain private"
            }
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseString + "Woo is safe")
            secondLabel.text = "People only see your initials, never your full name."
            mainImageView.image = UIImage(named: "ic_leftmenu_mobile1")
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: .curveEaseIn, animations: {
                self.leftImageView.alpha = 1
            }, completion: nil)
            break
        case .Call:
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseSecretTutorialString + "Call smart")
            firstLabel.text = "Call smart"
            secondLabel.text = "Call people without sharing your number.\nJust use the Woo phone when you match with someone."
            mainImageView.image = UIImage(named: "ic_leftmenu_mobile3")
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: .curveEaseIn, animations: {
                self.callImageView.alpha = 1
            }, completion: nil)
            break
        case .Unmatch:
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseSecretTutorialString + "Take charge")
            firstLabel.text = "Take charge"
            secondLabel.text = "You have the power to disconnect with people anytime you like."
            mainImageView.image = UIImage(named: "ic_leftmenu_mobile5")
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: .curveEaseIn, animations: {
                self.unmatchImageView.alpha = 1
            }, completion: nil)
            break
        case .Block:
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseSecretTutorialString + "Feel safe")
            firstLabel.text = "Feel safe"
            secondLabel.text = "Report profiles you feel are not fit for the Woo community. We will take strict actions against them."
            mainImageView.image = UIImage(named: "ic_leftmenu_mobile4")
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: .curveEaseIn, animations: {
                self.blockReportImageView.alpha = 1
            }, completion: nil)
            break
        case .Comfortable:
            var baseString = ""
            if isShownInOnBoarding{
                baseString = baseTutorialString
                firstLabel.text = "Woo is private"
            }
            else{
                baseString = baseSecretTutorialString
                firstLabel.text = "Feel comfortable"
            }
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseString + "Woo is private")
            secondLabel.text = "Your common FB friends will never see you on Woo. Unless you want them too."
            mainImageView.image = UIImage(named: "ic_leftmenu_mobile6")
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: .curveEaseIn, animations: {
                self.rightImageView.alpha = 1
            }, completion: nil)
            rightImageView.image = UIImage(named: "ic_leftmenu_mobile6_facebook")
            break
        case .Like:
            var baseString = ""
            if isShownInOnBoarding{
                baseString = baseTutorialString
                firstLabel.text = "Woo gives you control"
            }
            else{
                baseString = baseSecretTutorialString
                firstLabel.text = "Choose right"
            }
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseString + "Woo gives you control")
            secondLabel.text = "Swipe left to dismiss and right to connect with only those you like."
            mainImageView.image = UIImage(named: "ic_leftmenu_mobile7")
            rightImageView.image = UIImage(named: "ic_leftmenu_mobile7_like")
           
            UIView.animate(withDuration: animationDuration, delay: animationDelay, options: .curveEaseIn, animations: {
                self.rightImageView.alpha = 1
            }) { (success) in
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.likeImageView.alpha = 1
                }, completion: { (success) in
                    UIView.animate(withDuration: self.animationDuration, animations: {
                        self.likeImageView.transform = CGAffineTransform(rotationAngle: 45/360)
                    })
                })
            }
            break
        case .SeeHow:
            (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "You are set!")
            firstLabel.text = "Woo is designed to help women feel safe and comfortable while dating."
            secondLabel.text = ""
            mainImageView.isHidden = true
            startImageView.isHidden = false
            UIView.animate(withDuration: animationDuration) {
                self.screen1Label.alpha = 1
            }
            break
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.firstLabel.alpha = 1
            self.firstLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { (success) in
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.secondLabel.alpha = 1
                self.secondLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            }, completion: nil)
        }
    }

}
