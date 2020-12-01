//
//  VoiceCallInviteOverlay.swift
//  Woo_v2
//
//  Created by Ankit Batra on 30/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class VoiceCallInviteOverlay: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var bgGradientView: UIView!
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var inviteText: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    var inviteTappedOnOverlayHandler:(()->Void)!

    override func awakeFromNib()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgGradientView.bounds
        let topColor  = UIColor(red: (209.0/255.0), green: (73.0/255.0), blue: (100.0/255.0), alpha: 1.0).cgColor
        let middleColor  = UIColor(red: (169.0/255.0), green: (77.0/255.0), blue: (153.0/255.0), alpha: 1.0).cgColor
        let bottomColor  = UIColor(red: (134.0/255.0), green: (80.0/255.0), blue: (199.0/255.0), alpha: 1.0).cgColor
        gradientLayer.colors = [topColor,middleColor,bottomColor];
        bgGradientView.layer.insertSublayer(gradientLayer, at:0)
        
        ///
        leftImageView.layer.cornerRadius = 35
        leftImageView.layer.masksToBounds = true
        leftImageView.layer.borderColor = UIColor.white.cgColor
        leftImageView.layer.borderWidth = 2
        
        rightImageView.layer.cornerRadius = 35
        rightImageView.layer.masksToBounds = true
        rightImageView.layer.borderColor = UIColor.white.cgColor
        rightImageView.layer.borderWidth = 2
        
        inviteButton.layer.cornerRadius = 2.0
        inviteButton.layer.masksToBounds = true
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
    }
    @IBAction func inviteFriendsButtonTapped(_ sender: UIButton) {
        self.removeFromSuperview()
        inviteTappedOnOverlayHandler()
    }
    @IBAction func laterButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
    }
}
