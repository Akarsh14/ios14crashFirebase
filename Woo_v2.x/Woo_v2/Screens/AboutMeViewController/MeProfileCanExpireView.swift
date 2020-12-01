//
//  MeProfileCanExpireView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 21/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MeProfileCanExpireView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var expiryTrainingLabel: UILabel!
    
    var dismissHandler:(()->Void)!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        return self
    }
    
    /**
     This function loads the nib
     */
    class func loadViewFromNib(frame:CGRect) -> MeProfileCanExpireView {
        let profileView: MeProfileCanExpireView =
            Bundle.main.loadNibNamed("MeProfileCanExpireView", owner: self, options: nil)!.first as! MeProfileCanExpireView
        profileView.frame = frame
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return profileView
    }
    
    func updateExpiryText(){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.3

        let expiryDays = AppLaunchModel.sharedInstance().meSectionProfileExpiryDays - AppLaunchModel.sharedInstance().meSectionProfileExpiryDaysThreshold
        expiryTrainingLabel.text = "You have \(expiryDays) days to like someone who visited/liked you or you skipped before they disappear."
    }

    @IBAction func dismissView(_ sender: Any) {
        dismissHandler()
    }
}
