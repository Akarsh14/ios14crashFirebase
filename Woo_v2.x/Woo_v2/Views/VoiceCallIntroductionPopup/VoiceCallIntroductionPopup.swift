//
//  VoiceCallIntroductionPopup.swift
//  Woo_v2
//
//  Created by Ankit Batra on 30/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class VoiceCallIntroductionPopup: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientBgView.bounds
        let topColor  = UIColor(red: (209.0/255.0), green: (73.0/255.0), blue: (100.0/255.0), alpha: 1.0).cgColor
        let middleColor  = UIColor(red: (169.0/255.0), green: (77.0/255.0), blue: (153.0/255.0), alpha: 1.0).cgColor
        let bottomColor  = UIColor(red: (134.0/255.0), green: (80.0/255.0), blue: (199.0/255.0), alpha: 1.0).cgColor
        gradientLayer.colors = [topColor,middleColor,bottomColor];
        gradientBgView.layer.insertSublayer(gradientLayer, at:0)
        
        ///
        leftImage.layer.cornerRadius = 35
        leftImage.layer.masksToBounds = true
        leftImage.layer.borderColor = UIColor.white.cgColor
        leftImage.layer.borderWidth = 2
        
        rightImage.layer.cornerRadius = 35
        rightImage.layer.masksToBounds = true
        rightImage.layer.borderColor = UIColor.white.cgColor
        rightImage.layer.borderWidth = 2
      
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
    }
    
    @IBOutlet weak var gradientBgView: UIView!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    var closeTappedOnOverlayHandler:(()->Void)!

    @IBAction func closeButtonTapped(_ sender: UIButton)
    {
        self.removeFromSuperview()
        closeTappedOnOverlayHandler()
    }
    
}
