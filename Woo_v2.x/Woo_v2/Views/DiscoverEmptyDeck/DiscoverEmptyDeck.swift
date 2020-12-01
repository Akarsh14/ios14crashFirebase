
//
//  DiscoverEmptyDeck.swift
//  Woo_v2
//
//  Created by Suparno Bose on 29/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

open class DiscoverEmptyDeck: UIView {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var otherImageView: UIImageView!
    
    @IBOutlet weak var multipleFacesView: UIView!
    @IBOutlet weak var blurrTypeView: UIView!
    @IBOutlet weak var oldStyleView: UIView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var blurrTypeImageView: UIImageView!
    @IBOutlet weak var multipleFacesImageView: UIImageView!
    
    @IBOutlet weak var goGlobalImageView : UIImageView!
    @IBOutlet weak var multipleFacesIconImageView: UIImageView!
    @IBOutlet weak var multipleFacesTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var multipleFacesDescriptionLabel: UILabel!
    
    @IBOutlet weak var multipleFacesTopButton: UIButton!
    @IBOutlet weak var topButton: UIButton!
    
    @IBOutlet weak var multipleFacesBottomButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var blurrTypeContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blurrTypeLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var multipleFacesDescriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var multipleFacesContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurrTypeBottomButton: UIButton!
    @IBOutlet weak var blurrTypeTopButton: UIButton!
    @IBOutlet weak var blurrTypeDescriptionLabel: UILabel!
    @IBOutlet weak var blurrTypeIconImageView: UIImageView!
    @IBOutlet weak var blurrTypeTitleLabel: UILabel!
    @IBOutlet weak var mainContainerHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var blurrTypeDescriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var imageContainerHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabelHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabelBottomConstrain: NSLayoutConstraint!
    
    
    var data : DiscoverEmptyModel?
    
    var tapHandler : ((String) -> ())?
    
    /**
     This function loads the nib
     */
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DiscoverEmptyDeck", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let randomValue:UInt32 = arc4random_uniform(3)
        
        topButton.layer.shadowColor = UIColor.gray.cgColor
        topButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        topButton.layer.shadowRadius = 2.0
        topButton.layer.shadowOpacity = 1.0
        
        
        bottomButton.layer.shadowColor = UIColor.gray.cgColor
        bottomButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        bottomButton.layer.shadowRadius = 2.0
        bottomButton.layer.shadowOpacity = 1.0
        
        if randomValue == 0 {
            
            if data!.subCardType == .DISCOVER_EMPTY_GO_GLOBAL {
              goGlobeCardSetup()
            }else{
                oldStyleView.isHidden = false
                blurrTypeView.isHidden = true
                multipleFacesView.isHidden = true
                
            if data!.subCardType == .DISCOVER_EMPTY_SEARCH || data!.subCardType == .DISCOVER_EMPTY_PREFERENCES {
                
                if let myProfile = DiscoverProfileCollection.sharedInstance.myProfileData {
                    
                    let isMale = (Utilities.sharedUtility() as AnyObject).isGenderMale(myProfile.gender as String)
                    var placeHolderImage = "ic_me_avatar_big"
                    if !isMale {
                        placeHolderImage = "ic_me_avatar_big"
                    }
                    
                    if let myWooAlbum = myProfile.wooAlbum {
                        if myWooAlbum.profilePicUrl() != nil {
                            myImageView.sd_setImage(with: URL(string: myWooAlbum.profilePicUrl()!),
                                                           placeholderImage: UIImage(named: placeHolderImage))
                        }
                        else{
                            if myImageView != nil {
                                myImageView.image = UIImage(named: placeHolderImage)
                            }
                        }
                    }
                    else{
                        myImageView.image = UIImage(named: placeHolderImage)
                    }
                    
    //                myImageView.layer.borderWidth = 5.0
                    myImageView.layer.masksToBounds = true
    //                myImageView.layer.borderColor = UIColor.white.cgColor
                    myImageView.layer.cornerRadius = 50.0
                }
                else{
                    myImageView.image = UIImage(named: "ic_me_avatar_big")
    //                myImageView.layer.borderWidth = 5.0
                    myImageView.layer.masksToBounds = true
    //                myImageView.layer.borderColor = UIColor.white.cgColor
                    myImageView.layer.cornerRadius = 50.0
                }
                imageContainerHeightConstrain.constant = 115.0
            }else{
                imageContainerHeightConstrain.constant = 0.0
                mainContainerHeightConstrain.constant -= 115.0
            }
            
            if data?.title == nil {
                titleLabelHeightConstrain.constant = 0.0
                titleLabelBottomConstrain.constant = 0.0
                mainContainerHeightConstrain.constant -= 40.0
            }
            else{
                titleLabel.text = data!.title
            }
            
            descriptionLabel.text = data!.modelDescription
            descriptionHeightConstrain.constant =
                self.heightForView(descriptionLabel.text!,
                                   font: UIFont(name: "Lato-Regular", size: 14.0 )!,
                                   width: (320 - 52.0))
            mainContainerHeightConstrain.constant += descriptionHeightConstrain.constant
            
            if data!.buttons.count == 0 {
                mainContainerHeightConstrain.constant -= 152.0
            }
            else if data!.buttons.count == 1 {
                mainContainerHeightConstrain.constant -= 91.0
                let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                topButton.setTitle(buttonData.buttonText!, for: UIControl.State())
            }
            else {
                let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                topButton.setTitle(buttonData.buttonText!, for: UIControl.State())
                
                let buttonData2 = (data?.buttons[1])! as DiscoverEmptyButtonModel
                bottomButton.setTitle(buttonData2.buttonText!, for: UIControl.State())
            }
            }

        }
        else if randomValue == 1 {
            
            if data!.subCardType == .DISCOVER_EMPTY_GO_GLOBAL {
              goGlobeCardSetup()
            }else{
                
                oldStyleView.isHidden = true
                blurrTypeView.isHidden = false
                multipleFacesView.isHidden = true
                
                if data?.title == nil {
                    blurrTypeLabelHeightConstraint.constant = 0
                }
                else{
                    blurrTypeTitleLabel.text = data!.title
                    blurrTypeLabelHeightConstraint.constant = 27
                }
                
                blurrTypeIconImageView.image = UIImage.init(named: (data?.subCardType?.rawValue ?? ""))
                
                if DiscoverProfileCollection.sharedInstance.intentModelObject?.interestedGender == "FEMALE" {
                    blurrTypeImageView.image = UIImage.init(named: "ic_empty_discover_card_bg_female")
                }
                else{
                    blurrTypeImageView.image = UIImage.init(named: "ic_empty_discover_card_bg")
                }
                if data?.description == nil {
                    blurrTypeDescriptionLabelHeightConstraint.constant = 0
                }
                else{
                    blurrTypeDescriptionLabel.text = data!.modelDescription
                    blurrTypeDescriptionLabelHeightConstraint.constant =
                        self.heightForView(blurrTypeDescriptionLabel.text!,
                                           font: UIFont(name: "Lato-Regular", size: 14.0 )!,
                                           width: (320 - 52.0)) + 50
                    blurrTypeContainerViewHeightConstraint.constant += blurrTypeDescriptionLabelHeightConstraint.constant
                }
                
                if data!.buttons.count == 0 {
                    blurrTypeTopButton.isHidden = true
                    blurrTypeBottomButton.isHidden = true
                }
                else if data!.buttons.count == 1 {
                    blurrTypeTopButton.isHidden = false
                    blurrTypeBottomButton.isHidden = true
                    let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                    blurrTypeTopButton.setTitle(buttonData.buttonText!, for: UIControl.State())
                }
                else {
                    let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                    blurrTypeTopButton.setTitle(buttonData.buttonText!, for: UIControl.State())
                    
                    let buttonData2 = (data?.buttons[1])! as DiscoverEmptyButtonModel
                    blurrTypeBottomButton.setTitle(buttonData2.buttonText!, for: UIControl.State())
                }

            }
            
        }
        else if(randomValue == 2){
            
            if data!.subCardType == .DISCOVER_EMPTY_GO_GLOBAL {
              goGlobeCardSetup()
            }else{
                
                oldStyleView.isHidden = true
                blurrTypeView.isHidden = true
                multipleFacesView.isHidden = false
                blurrTypeTopButton.isHidden = false
                blurrTypeBottomButton.isHidden = false
                
                if data?.title != nil {
                    multipleFacesTitleLabel.text = data!.title
                }
                
                var backImage = UIImage(named: "ic_empty_discover_card_bg_purple")!
                let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                backImage = backImage.resizableImage(withCapInsets: myInsets)
                
                multipleFacesImageView.image = backImage
                
                if DiscoverProfileCollection.sharedInstance.intentModelObject?.interestedGender == "FEMALE" {
                    multipleFacesIconImageView.image = UIImage.init(named: "ic_discover_diaspora_card_female")
                }
                else{
                    multipleFacesIconImageView.image = UIImage.init(named: "ic_discover_diaspora_card")
                }
                if data?.description == nil {
                    multipleFacesDescriptionLabelHeightConstraint.constant = 0
                    multipleFacesContainerViewHeightConstraint.constant = 180
                }
                else{
                    multipleFacesDescriptionLabel.text = data!.modelDescription
                    multipleFacesDescriptionLabelHeightConstraint.constant =
                        self.heightForView(multipleFacesDescriptionLabel.text!,
                                           font: UIFont(name: "Lato-Regular", size: 14.0 )!,
                                           width: (320 - 52.0))
                    multipleFacesContainerViewHeightConstraint.constant = multipleFacesContainerViewHeightConstraint.constant + multipleFacesDescriptionLabelHeightConstraint.constant - 24
                }
                
                if data!.buttons.count == 0 {
                    multipleFacesTopButton.isHidden = true
                    multipleFacesBottomButton.isHidden = true
                }
                else if data!.buttons.count == 1 {
                    multipleFacesTopButton.isHidden = false
                    multipleFacesBottomButton.isHidden = true
                    let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                    multipleFacesTopButton.setTitle(buttonData.buttonText!, for: UIControl.State())
                }
                else {
                    multipleFacesTopButton.isHidden = false
                    multipleFacesBottomButton.isHidden = false
                    
                    let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                    multipleFacesTopButton.setTitle(buttonData.buttonText!, for: UIControl.State())
                    
                    let buttonData2 = (data?.buttons[1])! as DiscoverEmptyButtonModel
                    multipleFacesBottomButton.setTitle(buttonData2.buttonText!, for: UIControl.State())
                }

            }
        }
        
        self.layoutIfNeeded()
    }
    
    func setDataForView(_ data : DiscoverEmptyModel) {
        
        self.data = data

    }
    
    
    func goGlobeCardSetup(){
        
            oldStyleView.isHidden = true
            blurrTypeView.isHidden = true
            multipleFacesView.isHidden = false
            blurrTypeTopButton.isHidden = false
            blurrTypeBottomButton.isHidden = false
            
            if data?.title != nil {
                multipleFacesTitleLabel.text = data!.title
            }
            
            var backImage = UIImage(named: "ic_empty_discover_card_bg_purple")!
            let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            backImage = backImage.resizableImage(withCapInsets: myInsets)
            
            multipleFacesImageView.image = backImage
            goGlobalImageView.image = UIImage.init(named: "Go_global_Whole_Image")
            multipleFacesDescriptionLabelHeightConstraint.constant = 0
            multipleFacesContainerViewHeightConstraint.constant = 180
            
            if data!.buttons.count == 0 {
                multipleFacesTopButton.isHidden = true
                multipleFacesBottomButton.isHidden = true
            }
            else if data!.buttons.count == 1 {
                multipleFacesTopButton.isHidden = false
                multipleFacesBottomButton.isHidden = true
                let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                multipleFacesTopButton.setTitle(buttonData.buttonText!, for: UIControl.State())
            }
            else {
                multipleFacesTopButton.isHidden = false
                multipleFacesBottomButton.isHidden = false
                
                let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
                multipleFacesTopButton.setTitle(buttonData.buttonText!, for: UIControl.State())
                
                let buttonData2 = (data?.buttons[1])! as DiscoverEmptyButtonModel
                multipleFacesBottomButton.setTitle(buttonData2.buttonText!, for: UIControl.State())
            }

    }
    
    fileprivate func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height + 4
    }
    
    open func updateAlphaForOverlayView(_ viewIndex:UInt){
        
        var alphaProperty:CGFloat = 0.0
        
        let viewPercentIndex = viewIndex
        
        switch viewPercentIndex {
        case 0:
            alphaProperty = 0.0
        case 1:
            alphaProperty = 0.5
        case 2:
            alphaProperty = 0.8
        default:
            alphaProperty = 0.0
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView.alpha = alphaProperty
        }) 
    }

    @IBAction func topButtonTapped(_ sender: AnyObject) {
        let buttonData = (data?.buttons[0])! as DiscoverEmptyButtonModel
        
        if buttonData.actionUrl != nil {
            
            print("buttonData.actionUrl top button",buttonData.actionUrl!)
            
            if data!.subCardType == .DISCOVER_EMPTY_GO_GLOBAL {
                
                DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal = true
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    WooScreenManager.sharedInstance.loadDrawerView()
                }
                
            }else{
                tapHandler!(buttonData.actionUrl!)
            }
            
        }
        else{
            tapHandler!("")
        }
        
    }
    
    @IBAction func bottomButtonTapped(_ sender: AnyObject) {
        let buttonData = (data?.buttons[1])! as DiscoverEmptyButtonModel
        
        if buttonData.actionUrl != nil {
            
            print("buttonData.actionUrl bottom button",buttonData.actionUrl!)
            
            if data!.subCardType == .DISCOVER_EMPTY_GO_GLOBAL {
                
                DiscoverProfileCollection.sharedInstance.intentModelObject?.showGoGlobal = true
                
                WooScreenManager.sharedInstance.loadDrawerView()
                
            }else{
                tapHandler!(buttonData.actionUrl!)
            }
            
        }
        else{
            tapHandler!("")
        }
        
    }
    
}
