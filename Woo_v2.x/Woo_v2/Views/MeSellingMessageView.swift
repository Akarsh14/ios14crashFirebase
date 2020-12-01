//
//  MeSellingMessageView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 26/09/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class MeSellingMessageView: UIView {

    @IBOutlet weak var sellingMessageButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sellingMessageButton: UIButton!
    @IBOutlet weak var sellingMessageLabel: UILabel!
    var purchaseHandler:(()->Void)!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
    class func loadViewFromNib(frame:CGRect) -> MeSellingMessageView {
        let sellingMessageView: MeSellingMessageView =
            Bundle.main.loadNibNamed("MeSellingMessageView", owner: self, options: nil)!.first as! MeSellingMessageView
        sellingMessageView.frame = frame
        sellingMessageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return sellingMessageView
    }
    
    func updateDataAndUI(sellingMessage:String, actionButtonText:String){
        sellingMessageLabel.text = sellingMessage
        sellingMessageButton.setTitle(actionButtonText, for: .normal)
        sellingMessageButton =    Utilities().addingShadow(on: sellingMessageButton)
        sellingMessageButton.layer.shadowColor = UIColor.darkGray.cgColor
        sellingMessageButton.layer.shadowOpacity = 0.4
        sellingMessageButton.layer.shadowRadius = 3.0
        sellingMessageButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        if actionButtonText.count <= 0{
            sellingMessageButtonHeightConstraint.constant = 0
        }
    }
    
    @IBAction func sellingMessageButtonTapped(_ sender: Any) {
        purchaseHandler()
    }

}
