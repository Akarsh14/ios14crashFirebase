//
//  WooNavBarView.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum NavBarStyle  {
    case discover
    case me
    case matchBox
    case purchaseProducts
    case myQuestions
    case selectionOption
    case search
    case invite
    
    func color() -> UIColor {
        switch self {
        case .discover:
            return UIColor(red: 146.0/255.0, green: 117.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case .me:
            return UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case .matchBox:
            return UIColor(red: 117.0/255.0, green: 219.0/255.0, blue: 135.0/255.0, alpha: 1.0)
        case .purchaseProducts:
            return UIColor(red:0.28, green:0.57, blue:0.98, alpha:1.0)
        case .myQuestions:
            return UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case .selectionOption:
            return UIColor(red: 117.0/255.0, green: 196.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case .search:
            return UIColor(red: 117.0/255.0, green: 180.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case .invite:
            return UIColor(red: 0.47, green: 0.85, blue: 0.74, alpha: 1.0)
        

        }
    
        
    }
}

class WooNavBarView: UIView {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchHolderView: UIView!
   // @IBOutlet weak var customSwitchView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var switchHolderViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var settingsButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var customSwitch:RSSwitch?
    
    var switchValueChanged : ((_ switchValue: Bool) -> (Void))?

    
    var settingsButtonHasBeenTapped : (() -> ())?
    var DoneButtonHasBeenTapped : (() -> ())?
    var searchButtonHasBeenTapped : (() -> ())?

    
    var typeOfNavBar:NavBarStyle?
    
    class func load(_ title: String, type : NavBarStyle, searchIsVisible : Bool) -> WooNavBarView? {
        let navBar = UINib(nibName: "WooNavBarView",bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WooNavBarView
        
        
        navBar?.frame = CGRect(x: 0.0, y: 0.0,
                               width: UIScreen.main.bounds.width,
                               height: 64.0)
        navBar?.typeOfNavBar = type
        navBar?.settingsButton.isHidden = true
        
      return navBar
    }
    
    func setStyle(_ style : NavBarStyle, animated: Bool) {
        typeOfNavBar = style
        if style == NavBarStyle.discover || style == NavBarStyle.selectionOption {
            self.addCustomSwitch()
            colorTheStatusBar(withColor: style.color())
        }else{
            
        }
        
       
        if !animated {
            self.backgroundColor = style.color()
        }
        else{
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(), animations: { 
                self.backgroundColor = style.color()
                }, completion: nil)
        }
    }
    
    func addCustomSwitch(){
         customSwitch = RSSwitch.init(frame: CGRect(x: 0.0, y: 0.0,
                                                                width: 51,
                                                                height: 31))
        customSwitch?.addTarget(self, action: #selector(switchTapped), for: UIControl.Event.touchUpInside)

        if typeOfNavBar == NavBarStyle.discover {
            settingsButton.isHidden = false
            settingsButtonWidthConstraint.constant = 31
            switchHolderViewWidthConstraint.constant = 94
            customSwitch?.isShown(inDiscover: true)
        }
        else{
            settingsButton.isHidden = true
            settingsButtonWidthConstraint.constant = 0
            switchHolderViewWidthConstraint.constant = 72
            customSwitch?.isShown(inDiscover: false)
        }
        doneButton.isHidden = true
       // searchButton.isHidden = true
      //  customSwitchView.addSubview(customSwitch!)
        
    }
    
    @objc func switchTapped(){
        
        let switchValue:Bool = (customSwitch?.isOn)!
        
        if switchValueChanged != nil {
            switchValueChanged!(switchValue)
        }
    }
    
    func setTitleText(_ text : String) {
        titleLabel.text = NSLocalizedString(text, comment: "Title Text")
    }
    
    func addBackButtonTarget(_ target: AnyObject?, action: Selector){
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
    }
    
    func addSearchButton(){
        searchButton.isHidden = false
    }
    func addDoneButtonTarget(_ target: AnyObject?, action: Selector){
        doneButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
    }
    
    //Iboutlets
    @IBAction func settingsButtonTapped(_ sender: Any) {
        settingsButtonHasBeenTapped!()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if(DoneButtonHasBeenTapped != nil)
        {
            DoneButtonHasBeenTapped!()
        }
    }
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if(searchButtonHasBeenTapped != nil)
        {
            searchButtonHasBeenTapped!()
        }
    }
}
