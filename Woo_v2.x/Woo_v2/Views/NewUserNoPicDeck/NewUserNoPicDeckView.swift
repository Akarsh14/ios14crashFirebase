//
//  NewUserNoPicDeckView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 23/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

open class NewUserNoPicDeckView: UIView {
    
    @IBOutlet weak var subDescriptionLabel: UILabel!
    @IBOutlet weak var snapShotView: UIView!
    @IBOutlet weak var snapShotImageView: UIImageView!
    @IBOutlet weak var ctaButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var newUserNoPicImageView: UIImageView!
    
    var ctaButtonTappedHandler:((Bool)->Void)!
    
    var newUserNoPicDetails:NewUserNoPicCardModel?
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        loadViewFromNib()
        return self
    }
    
    /**
     This function loads the nib
     */
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NewUserNoPicDeckView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        ctaButton.layer.shadowColor = UIColor.gray.cgColor
        ctaButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        ctaButton.layer.shadowRadius = 2.0
        ctaButton.layer.shadowOpacity = 1.0
        
        self.addSubview(view);
    }

    func addADummyImageViewWithSnapShotToAvoidFlickerWhileReloadingDeck(_ snapImage:UIImage){
        snapShotImageView.image = snapImage
        snapShotView.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0.5, options: UIView.AnimationOptions(), animations: {
            self.snapShotView.alpha = 0
            }, completion: nil)
    }
    
    @IBAction func crossButtonTapped(_ sender: AnyObject) {
        ctaButtonTappedHandler(false)
        
    }
    
    @IBAction func ctaButtonTapped(_ sender: AnyObject) {
        ctaButtonTappedHandler(true)
    }
    
    func setDataForNewUserNoPicView(_ isInCompatible:Bool) {
        
        if newUserNoPicDetails == nil {
            return
        }
       // descriptionLabel.text = newUserNoPicDetails?.cardDescription
       // ctaButton.titleLabel?.text = newUserNoPicDetails?.buttonName
        if isInCompatible{
            newUserNoPicImageView.image = UIImage(named: "ic_new_user_no_pic_incompatible")
            descriptionLabel.text = "The picture you uploaded was incompatible."
            subDescriptionLabel.text = "Upload another to your profile."
        }
        else{
            newUserNoPicImageView.image = UIImage(named: "ic_new_user_no_pic")
            descriptionLabel.text = "Looks like we don't have a picture of you."
            subDescriptionLabel.text = "Upload one to increase your chances of a match"
        }
    }


}
