//
//  MeSectionEmptyView.swift
//  Woo_v2
//
//  Created by Umesh Mishra on 07/04/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

@objc class MeSectionEmptyView: UIView {
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var sellingImage: UIImageView!
    @objc var actionBtnTappedBlock: ((Bool) -> Void)!
    
    @IBOutlet weak var buttonActionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceBetweenButtonAndMessage: NSLayoutConstraint!
    
    @IBOutlet weak var distanceBetweenTitleAndImageCosntraint: NSLayoutConstraint!
    @IBOutlet weak var distanceBetweenMessageAndImageCosntraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    /**
     This function loads the nib
     */
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MeSectionEmptyView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        if Utilities().isitAniPhone4() {
            view.frame = CGRect(x: 0, y: 64, width: bounds.width, height: bounds.height - 64)
        }
        else{
            view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        }
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        actionBtn.layer.shadowColor = UIColor.gray.cgColor
        actionBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        actionBtn.layer.shadowRadius = 2.0
        actionBtn.layer.shadowOpacity = 1.0
        
        self.addSubview(view);
    }
    
    
    
    
    
    @IBAction func actionBtnTapped(_ sender: AnyObject){
        actionBtnTappedBlock(true)
    }
    
    @objc func setEmptyScreenDetail(withTitle title:String, sellingMessage message:String, actionButtonTitle buttonTitle:String, showBoostIcon showIcon:Bool, isUserMale isMaleUser:Bool) -> Void {
        titleLbl.text = title.count > 0 ? title : ""
        messageLbl.text = message.count > 0 ? message : ""
        actionBtn.setTitle((buttonTitle.count > 0 ? buttonTitle : ""), for: .normal)
        if isMaleUser {
            if showIcon {
                //show female image with boost icon
                sellingImage.image = UIImage.init(named: "ic_me_empty_female_boost")
            }
            else{
                sellingImage.image = UIImage.init(named: "ic_me_empty_female")
            }
        }
        else{
            if showIcon {
                //show male image with boost icon
                sellingImage.image = UIImage.init(named: "ic_me_empty_male_boost")
            }
            else{
                sellingImage.image = UIImage.init(named: "ic_me_empty_male")
            }
        }
        
        if Utilities().isitAniPhone4() {
            distanceBetweenTitleAndImageCosntraint.constant = 10
            distanceBetweenMessageAndImageCosntraint.constant = 10
            distanceBetweenButtonAndMessage.constant = 30
        }
        
        
        
    }
    
    @objc func showActionButton(showActionButton showButton:Bool ){
        actionBtn.isHidden = !showButton
        let btnMsgDistance = Utilities().isitAniPhone4() ? 30 : 50
        buttonActionHeightConstraint.constant = showButton ? 40 : 0
        distanceBetweenButtonAndMessage.constant = CGFloat(showButton ? btnMsgDistance : 0)
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
