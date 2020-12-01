//
//  EthnicityCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 17/01/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class EthnicityCell: UITableViewCell {
    
    @IBOutlet weak var firstEthnicityBtn: UIButton!
    @IBOutlet weak var secondEthnicityBtn: UIButton!
    @IBOutlet weak var proudTextLbl: UILabel!
    @IBOutlet weak var IamTextLbl: UILabel!
    
    @IBOutlet weak var ethniciytContainerView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    
    var firstEthnicityBtn_New: UIButton! = UIButton()
    var secondEthnicityBtn_New: UIButton! = UIButton()
  //  var proudTextLbl_New: UILabel! = UILabel()
    var IamTextLbl_New: UILabel! = UILabel()
    var iconImage_New: UIImageView! = UIImageView()
    
    var isTypeReligon = false
    var isOpenedFromWizard = false
    
//    @IBOutlet weak var firstEthnicityBtnContraint_Width: NSLayoutConstraint!
//    @IBOutlet weak var firstEthnicityBtnContraint_Top: NSLayoutConstraint!
//    @IBOutlet weak var secondEthnicityBtnConstraint_Width: NSLayoutConstraint!
//    @IBOutlet weak var firstEthnicityBtnContraint_Leading: NSLayoutConstraint!
//    @IBOutlet weak var secondEthnicityBtnConstraint_Leading: NSLayoutConstraint!
//    @IBOutlet weak var secondEthnicityBtnConstraint_Trailing: NSLayoutConstraint!
//    @IBOutlet weak var containerViewConstraint_Width: NSLayoutConstraint!
//    
//    //
//    @IBOutlet weak var firstLbl_Iam_Constraint_Height: NSLayoutConstraint!
//    @IBOutlet weak var firstLbl_Iam_Constraint_Width: NSLayoutConstraint!
//    @IBOutlet weak var secondLbl_Proud_contraint_Width: NSLayoutConstraint!
//    @IBOutlet weak var secondLbl_Proud_contraint_Trailing: NSLayoutConstraint!
    
    var ethnicityArrayRecieved: NSArray?
    
    var selectionHandler : (([ProfessionModel], Bool)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func removeAllTheViewFromContainerView(){
     
        for subview in self.ethniciytContainerView.subviews {
            if subview.superview != nil {
                subview.removeFromSuperview()
//                subview = nil
            }
        }
    }
    
    func reinitialiseAllComponentintView(){
//        if firstEthnicityBtn_New != nil {
//            firstEthnicityBtn_New = nil
//        }
//        if secondEthnicityBtn_New != nil {
//            secondEthnicityBtn_New = nil
//        }
//        if proudTextLbl_New != nil {
//            proudTextLbl_New = nil
//        }
//        if IamTextLbl_New != nil {
//            IamTextLbl_New = nil
//        }
//        if iconImage_New != nil {
//            iconImage_New = nil
//        }
        
        let fontForLbl = UIFont.init(name: "Lato-Regular", size: 14)
        let fontForBtn = UIFont.init(name: "Lato-Medium", size: 14)
        let backgroundColorForBtn = Utilities().getUIColorObject(fromHexString: "F5F5F5", alpha: 1.0)
        let textColorForBtn = Utilities().getUIColorObject(fromHexString: "B8B8B8", alpha: 1.0)
        let textColorForLbl = Utilities().getUIColorObject(fromHexString: "72778A", alpha: 1.0)
        
        
        firstEthnicityBtn_New = UIButton()
        firstEthnicityBtn_New.titleLabel?.font = fontForBtn
        firstEthnicityBtn_New.setTitleColor(textColorForBtn, for: .normal)
        firstEthnicityBtn_New.backgroundColor = backgroundColorForBtn
        firstEthnicityBtn_New.addTarget(self, action: #selector(firstBtnTapped), for: .touchUpInside)
        
        secondEthnicityBtn_New = UIButton()
        secondEthnicityBtn_New.titleLabel?.font = fontForBtn
        secondEthnicityBtn_New.setTitleColor(textColorForBtn, for: .normal)
        secondEthnicityBtn_New.backgroundColor = backgroundColorForBtn
        secondEthnicityBtn_New.addTarget(self, action: #selector(secondBtnTapped), for: .touchUpInside)
        
//        proudTextLbl_New = UILabel()
//        proudTextLbl_New.backgroundColor = UIColor.clear
//        proudTextLbl_New.font = fontForLbl
//        proudTextLbl_New.textColor = textColorForLbl
//        proudTextLbl_New.text = "and Proud!"
        
        IamTextLbl_New = UILabel()
        IamTextLbl_New.backgroundColor = UIColor.clear
        IamTextLbl_New.font = fontForLbl
        IamTextLbl_New.textColor = textColorForLbl
        
        iconImage_New = UIImageView()
        if !isOpenedFromWizard{
        iconImage_New.image = UIImage.init(named: "ic_edit_profile_ethnicity")
        iconImage_New.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        }
        
        
        self.ethniciytContainerView.addSubview(firstEthnicityBtn_New)
        self.ethniciytContainerView.addSubview(secondEthnicityBtn_New)
       // self.ethniciytContainerView.addSubview(proudTextLbl_New)
        self.ethniciytContainerView.addSubview(IamTextLbl_New)
        self.ethniciytContainerView.addSubview(iconImage_New)
        
    }
    
    func setEthData(ethnicity ethnicityArray: NSArray) {
        removeAllTheViewFromContainerView()
        reinitialiseAllComponentintView()
        ethnicityArrayRecieved = ethnicityArray
        var ethnicityString = "I am"
        // "proudLbl": proudTextLbl_New,
        let viewsDictionary: [AnyHashable: Any] = ["firstButton": firstEthnicityBtn_New, "secondButton": secondEthnicityBtn_New, "iAmLbl": IamTextLbl_New, "icon": iconImage_New]
        
        var firstEthnicityBtnWidth:CGFloat = 0.0
        var secondEthnicityBtnWidth:CGFloat = 0.0
        
        if ethnicityArray.count > 0 {
            
            self.firstEthnicityBtn_New?.translatesAutoresizingMaskIntoConstraints = false;
            self.secondEthnicityBtn_New?.translatesAutoresizingMaskIntoConstraints = false;
            self.IamTextLbl_New?.translatesAutoresizingMaskIntoConstraints = false;
//            self.proudTextLbl_New?.translatesAutoresizingMaskIntoConstraints = false;
            self.iconImage_New?.translatesAutoresizingMaskIntoConstraints = false;
            
            
            
            let firstEthObj: ProfessionModel = ethnicityArray.firstObject as! ProfessionModel
            let firstEthnicityName = firstEthObj.name!
            if (Utilities().checkIfStringStarts(withVowelOfNot: firstEthnicityName) == true) {
               // ethnicityString = ethnicityString + " an"
            }
            else{
                ethnicityString = ethnicityString + " a"
            }
            
            
            if ethnicityArray.count == 1 {
                // ek ethnicity wala hai
                let firstObj: ProfessionModel = ethnicityArray.firstObject as! ProfessionModel
                
                if (firstObj.isSelected == true) {
                    // ethnicity is selected
                    //mtlb bus text dikhana hai.
                    firstEthnicityBtn_New?.isHidden = true
                    secondEthnicityBtn_New?.isHidden = true
                    //proudTextLbl_New?.isHidden = true
                    ethnicityString = ethnicityString + " " + firstObj.name!
                    ethnicityString = ethnicityString + " and Proud!"
                    IamTextLbl_New?.textAlignment = NSTextAlignment.center
                    IamTextLbl_New.text = ethnicityString
                    
                    let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-1-[iAmLbl]-1-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                    self.ethniciytContainerView.addConstraints(constraint_POS_H)
                    
                    let yConstraint = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                    self.ethniciytContainerView.addConstraint(yConstraint)
                    
                    let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                    self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                }
                else{
                    //not selected
                    //ek hi button dikhana hai and baaki text hoga
                    let firstBtnString = " " + firstObj.name! + " "
                    firstEthnicityBtn_New?.setTitle(firstBtnString, for: .normal)
                    firstEthnicityBtn_New?.isHidden = false
                    
                    secondEthnicityBtn_New?.isHidden = true
                    IamTextLbl_New.text = ethnicityString
                    
                    
                    let maxAllowedWidthOfContainerView: CGFloat = UIScreen.main.bounds.width - 50
                    let iconWidth: CGFloat = 36.0
                    let firstLblWidth: CGFloat = Utilities().getTextWidthHeight(IamTextLbl_New).width + 9
                    let firstBtnWidth: CGFloat = Utilities().getTextWidthHeight(firstEthnicityBtn_New!.titleLabel).width + 10.0
                    let lastLblWidth: CGFloat = 70.0
                    
                    firstEthnicityBtnWidth = firstBtnWidth
                    
                    if (maxAllowedWidthOfContainerView >= (iconWidth + firstLblWidth + firstBtnWidth + lastLblWidth + 8)) {
                        // sab kuch ek line me aa jayega
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[firstButton(\(firstBtnWidth))]-4-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_FirstBtn)
                        
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                    }
                    else if (maxAllowedWidthOfContainerView > (iconWidth + firstLblWidth + firstBtnWidth + 4)){
                        //proud lbl nahi aayega
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[firstButton(\(firstBtnWidth))]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.secondEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_FirstBtn)
                        
//                        let xConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(xConstraint_Proud)
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .top, relatedBy: .equal, toItem: self.firstEthnicityBtn_New, attribute: .bottom, multiplier: 1, constant: 4)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                    }
                    else{
                        // first button and proud lbl dono nahi aayenge.ß
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let xConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: -((firstBtnWidth/2) - 2))
                        self.ethniciytContainerView.addConstraint(xConstraint_FirstBtn)
                        let yConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.IamTextLbl_New, attribute: .bottom, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_FirstBtn)
                        let widthConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: firstBtnWidth)
                        secondEthnicityBtn_New.addConstraint(widthConstraint_FirstBtn)
                        
//                        let xConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: ((lastLblWidth/2) + 4))
//                        self.ethniciytContainerView.addConstraint(xConstraint_Proud)
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.firstEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                    }
                }
            }
            else if ethnicityArray.count == 2 {
                // 2 ethnicity wala case hai
                let firstObj: ProfessionModel = ethnicityArray.firstObject as! ProfessionModel
                let secondObj: ProfessionModel = ethnicityArray.lastObject as! ProfessionModel
                if ((firstObj.isSelected == true) && (secondObj.isSelected == true)  ){
                    // dono selected hai
                    //mtlb ki dono ethnicity selected hai.
                    firstEthnicityBtn_New.isHidden = true
                    secondEthnicityBtn_New.isHidden = true
                    //proudTextLbl_New.isHidden = true
                    
                    ethnicityString = ethnicityString + " " + firstObj.name! + ", "
                    ethnicityString = ethnicityString + "" + secondObj.name!
                    
                    //ethnicityString = ethnicityString + " and Proud!"
                    IamTextLbl_New.textAlignment = NSTextAlignment.center
                    IamTextLbl_New.text = ethnicityString
                    
//                    let viewsDictionary: [AnyHashable: Any] = [ "ethnicityMsgLbl": IamTextLbl, "icon": iconImage]
                    let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-1-[iAmLbl]-1-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                    self.ethniciytContainerView.addConstraints(constraint_POS_H)
                    
                    let yConstraint = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                    self.ethniciytContainerView.addConstraint(yConstraint)
                    
                    let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                    self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                    
                    
                }
                else if((firstObj.isSelected == true) && (secondObj.isSelected == false)){
                    //first selected hai second nahi hai
                    
                    firstEthnicityBtn_New.isHidden = true
                    ethnicityString = ethnicityString + " " + firstObj.name! + ", "
                    
                    let btnString = " " + secondObj.name! + " "
                    secondEthnicityBtn_New.setTitle(btnString, for: .normal)
                    secondEthnicityBtn_New.isHidden = false
                    
                    IamTextLbl_New.text = ethnicityString
                    
                    let maxAllowedWidthOfContainerView: CGFloat = UIScreen.main.bounds.width - 50
                    let iconWidth: CGFloat = 36.0
                    let firstLblWidth: CGFloat = Utilities().getTextWidthHeight(IamTextLbl_New).width + 9
                    let secondBtnWidth: CGFloat = Utilities().getTextWidthHeight(secondEthnicityBtn_New.titleLabel).width + 10.0
                    let lastLblWidth: CGFloat = 70.0
                    
                    
                    
//                    firstEthnicityBtnWidth = firstLblWidth
                    secondEthnicityBtnWidth = secondBtnWidth
                    
                    if (maxAllowedWidthOfContainerView >= (iconWidth + firstLblWidth + secondBtnWidth + lastLblWidth + 8)) {
                        //sab kuch aa jayega ek line me
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[secondButton(\(secondBtnWidth))]-4-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_SecondBtn)
                        
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                    }
                    else if(maxAllowedWidthOfContainerView > (iconWidth + firstLblWidth + secondBtnWidth + 4)){
                        //proud lbl nahi aayega baaki sab aa jayega
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[secondButton(\(secondBtnWidth))]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.secondEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_SecondBtn)
                        
//                        let xConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(xConstraint_Proud)
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .top, relatedBy: .equal, toItem: self.secondEthnicityBtn_New, attribute: .bottom, multiplier: 1, constant: 4)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                        
                    }
                    else{
                        // second button and proudl lbl nahi aayega
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let xConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: -((secondBtnWidth/2) - 2))
                        self.ethniciytContainerView.addConstraint(xConstraint_SecondBtn)
                        let yConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.IamTextLbl_New, attribute: .bottom, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_SecondBtn)
                        let widthConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: secondBtnWidth)
                        secondEthnicityBtn.addConstraint(widthConstraint_SecondBtn)
                        
//                        let xConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: ((lastLblWidth/2) + 4))
//                        self.ethniciytContainerView.addConstraint(xConstraint_Proud)
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.secondEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                        
                    }
                }
                else{
                    //koi bhi selected nahi hai
                    
                    
                    
                    
                    let firstBtnString = " " + firstObj.name! + " "
                    firstEthnicityBtn_New.setTitle(firstBtnString, for: .normal)
                    firstEthnicityBtn_New.isHidden = false
                    
                    let secondBtnString = " " + secondObj.name! + " "
                    secondEthnicityBtn_New.setTitle(secondBtnString, for: .normal)
                    secondEthnicityBtn_New.isHidden = false
                    
                    
                    IamTextLbl_New.text = ethnicityString
                    
                    let maxAllowedWidthOfContainerView: CGFloat = UIScreen.main.bounds.width - 50
                    let iconWidth: CGFloat = 36.0
                    let firstLblWidth: CGFloat = Utilities().getTextWidthHeight(IamTextLbl_New).width + 9
                    let firstBtnWidth: CGFloat = Utilities().getTextWidthHeight(firstEthnicityBtn_New.titleLabel).width + 10.0
                    let secondBtnWidth: CGFloat = Utilities().getTextWidthHeight(secondEthnicityBtn_New.titleLabel).width + 10.0
                    let lastLblWidth: CGFloat = 70.0
                    
                    firstEthnicityBtnWidth = firstBtnWidth
                    secondEthnicityBtnWidth = secondBtnWidth
                    
                    
                    
                    if (maxAllowedWidthOfContainerView >= (iconWidth + firstLblWidth + firstBtnWidth + secondBtnWidth + lastLblWidth + 12)) {
                        //sab kuch aa jayega ek line me
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[firstButton(\(firstBtnWidth))]-4-[secondButton(\(secondBtnWidth))]-4-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_FirstBtn)
                        
                        let yConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_SecondBtn)
                        
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                    }
                    else if (maxAllowedWidthOfContainerView > (iconWidth + firstLblWidth + firstBtnWidth + secondBtnWidth + 8)){
                        //proud lbl nahi aayega baaki sab aa jayega
   
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[firstButton(\(firstBtnWidth))]-4-[secondButton(\(secondBtnWidth))]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.firstEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_FirstBtn)
                        
                        let yConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .centerY, relatedBy: .equal, toItem: self.firstEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_SecondBtn)
                        
//                        let xConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(xConstraint_Proud)
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .top, relatedBy: .equal, toItem: self.secondEthnicityBtn_New, attribute: .bottom, multiplier: 1, constant: 4)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
  
                    }
                    else{
                        // second button and proudl lbl nahi aayega
                        
                        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-0-[iAmLbl]-4-[firstButton(\(firstBtnWidth))]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
                        self.ethniciytContainerView.addConstraints(constraint_POS_H)
                        
                        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_Icon)
                        
                        let yConstraint_Iam = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.firstEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
                        self.ethniciytContainerView.addConstraint(yConstraint_Iam)
                        
                        let yConstraint_FirstBtn = NSLayoutConstraint(item: firstEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .top, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_FirstBtn)
                        
                        let xConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: -((secondBtnWidth/2) - 2))
                        self.ethniciytContainerView.addConstraint(xConstraint_SecondBtn)
                        let yConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .top, relatedBy: .equal, toItem: self.firstEthnicityBtn_New, attribute: .bottom, multiplier: 1, constant: 4)
                        self.ethniciytContainerView.addConstraint(yConstraint_SecondBtn)
                        let widthConstraint_SecondBtn = NSLayoutConstraint(item: secondEthnicityBtn_New, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: secondBtnWidth)
                        secondEthnicityBtn.addConstraint(widthConstraint_SecondBtn)
                        
                        
//                        let xConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerX, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerX, multiplier: 1, constant: ((lastLblWidth/2) + 4))
//                        self.ethniciytContainerView.addConstraint(xConstraint_Proud)
//                        let yConstraint_Proud = NSLayoutConstraint(item: proudTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.secondEthnicityBtn_New, attribute: .centerY, multiplier: 1, constant: 0)
//                        self.ethniciytContainerView.addConstraint(yConstraint_Proud)
                        
                        
                        
                    }
                    
                    
                }
            }
        }
        
        self.ethniciytContainerView.setNeedsLayout()
        
        self.ethniciytContainerView.layoutIfNeeded()
        
        if firstEthnicityBtn_New.isHidden == false{
            drawBorderAroundBtn(forButton: firstEthnicityBtn_New, withWidth: firstEthnicityBtnWidth)
        }
        
        if secondEthnicityBtn_New.isHidden == false{
            drawBorderAroundBtn(forButton: secondEthnicityBtn_New, withWidth: secondEthnicityBtnWidth)
        }
        
        
    }
    
    func setEthString(ethnicity ethnicityText: String) {
        
        removeAllTheViewFromContainerView()
        reinitialiseAllComponentintView()

        firstEthnicityBtn_New.isHidden = true

        secondEthnicityBtn_New.isHidden = true
        IamTextLbl_New.text = ethnicityText
       
        let maxAllowedWidthOfContainerView: CGFloat = UIScreen.main.bounds.width - 50
        self.firstEthnicityBtn_New?.translatesAutoresizingMaskIntoConstraints = false;
        self.secondEthnicityBtn_New?.translatesAutoresizingMaskIntoConstraints = false;
        self.IamTextLbl_New?.translatesAutoresizingMaskIntoConstraints = false;
       // self.proudTextLbl_New?.translatesAutoresizingMaskIntoConstraints = false;
        self.iconImage_New?.translatesAutoresizingMaskIntoConstraints = false;
        
        firstEthnicityBtn_New.isHidden = true
        secondEthnicityBtn_New.isHidden = true
       // proudTextLbl_New.isHidden = true

        let viewsDictionary: [AnyHashable: Any] = ["iAmLbl": IamTextLbl_New, "icon": iconImage_New]

        let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon]-1-[iAmLbl]-1-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
        self.ethniciytContainerView.addConstraints(constraint_POS_H)
        
        let yConstraint = NSLayoutConstraint(item: IamTextLbl_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
        self.ethniciytContainerView.addConstraint(yConstraint)
        
        let yConstraint_Icon = NSLayoutConstraint(item: iconImage_New, attribute: .centerY, relatedBy: .equal, toItem: self.ethniciytContainerView, attribute: .centerY, multiplier: 1, constant: 0)
        self.ethniciytContainerView.addConstraint(yConstraint_Icon)

    }
    
    
    
//    func setEthnicityData(ethnicity ethnicityArray: NSArray){
//        var ethnicityString = "I am"
//        
//        var isTextMovedToNextLine = false
//        
//        var widthOfText = 0
//        widthOfText += (44 + 46)
//        IamTextLbl.textAlignment = NSTextAlignment.left
//        if (ethnicityArray.count > 0) {
//            ethnicityArrayRecieved = ethnicityArray;
//            
//            secondEthnicityBtnConstraint_Width.constant = 0.0
//            secondEthnicityBtnConstraint_Leading.constant = 0.0
//            secondEthnicityBtn.isHidden = true
//            secondEthnicityBtnConstraint_Trailing.constant = 2.0
//            
//            
//            //width of the screen - ( 50 + 44 +
//            
//            
//            let firstObj: ProfessionModel = ethnicityArray.firstObject as! ProfessionModel
//            let firstEthnicityName = firstObj.name!
//            if (Utilities().checkIfStringStarts(withVowelOfNot: firstEthnicityName) == true) {
//                ethnicityString = ethnicityString + " an"
//            }
//            else{
//                ethnicityString = ethnicityString + " a"
//            }
//            if firstObj.isSelected == true {
//                firstEthnicityBtnContraint_Width.constant = 0.0
//                firstEthnicityBtnContraint_Leading.constant = 0.0
//                firstEthnicityBtn.isHidden = true
//                ethnicityString = ethnicityString + " " + firstObj.name!
//            }
//            else{
//                let btnString = " " + firstObj.name! + " "
////                let btnString = " " + "New Caledonia Kanak+" + " "
//                firstEthnicityBtn.setTitle(btnString, for: .normal)
//                firstEthnicityBtn.isHidden = false
//                firstEthnicityBtnContraint_Width.constant = Utilities().getTextWidthHeight(firstEthnicityBtn.titleLabel).width + 10.0
//                firstEthnicityBtnContraint_Leading.constant = 4.0
////                drawBorderAroundBtn(forButton: firstEthnicityBtn, withWidth: firstEthnicityBtnContraint_Width.constant)
//                
//            }
//            
//            if ethnicityArray.count > 1 {
//                let secondObj: ProfessionModel = ethnicityArray.lastObject as! ProfessionModel
//                
//                if secondObj.isSelected == true  {
//                    secondEthnicityBtnConstraint_Width.constant = 0.0
//                    secondEthnicityBtnConstraint_Leading.constant = 0.0
//                    ethnicityString = ethnicityString + ", " + secondObj.name!
//                    secondEthnicityBtn.isHidden = true
//                    secondEthnicityBtnConstraint_Trailing.constant = 2.0
//                }
//                else{
//                    let btnString = " " + secondObj.name! + " "
//                    secondEthnicityBtn.setTitle(btnString, for: .normal)
//                    secondEthnicityBtn.isHidden = false
//                    secondEthnicityBtnConstraint_Width.constant = Utilities().getTextWidthHeight(secondEthnicityBtn.titleLabel).width + 10.0
//                    secondEthnicityBtnConstraint_Leading.constant = 4.0
//                    secondEthnicityBtnConstraint_Trailing.constant = 4.0
////                    drawBorderAroundBtn(forButton: secondEthnicityBtn, withWidth: secondEthnicityBtnConstraint_Width.constant)
//                    
//                    
//                    
//                }
//            }
//            
//            if secondEthnicityBtn.isHidden == false {
//                let viewsDictionary: [AnyHashable: Any] = ["firstButton": firstEthnicityBtn, "secondButton": secondEthnicityBtn, "proudLbl": proudTextLbl, "icon": iconImage]
//                let probableXOfSecond = 36 + firstLbl_Iam_Constraint_Width.constant + 4 + firstEthnicityBtnContraint_Width.constant + 4 // width Of ImageIcon, IamTextLbl, leftPadding, Width of first button, Padding
//                //check if text inlcuding proud text will go to next line or not
//                if (probableXOfSecond + secondEthnicityBtnConstraint_Width.constant + 70) > (UIScreen.main.bounds.width - 50) {
//                    print("Second button should go in next line")
//                    secondEthnicityBtnConstraint_Leading.constant = IamTextLbl.frame.origin.x
//                    let constraint_POS_V: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:[firstButton]-5-[secondButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
////                    let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:[icon]-1-[secondButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
////                    self.ethniciytContainerView.addConstraints(constraint_POS_H)
//                    self.ethniciytContainerView.addConstraints(constraint_POS_V)
//                    if (secondLbl_Proud_contraint_Trailing != nil) {
//                        self.ethniciytContainerView.removeConstraint(secondLbl_Proud_contraint_Trailing)
//                    }
//                    
////                    proudTextLbl.removeConstraint(secondLbl_Proud_contraint_Trailing)
//                    
//                    firstEthnicityBtnContraint_Top.constant = 4
//
//                    let constraint_Lbl_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:[secondButton]-4-[proudLbl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
//                    self.ethniciytContainerView.addConstraints(constraint_Lbl_H)
//                    
//                    isTextMovedToNextLine = true
////                    proudTextLbl.removeConstraint(secondLbl_Proud_contraint_Trailing)
//                    
//                }
//                else{
//                    let probableXOfProudLbl = 36 + 46 + 4 + firstEthnicityBtnContraint_Width.constant + 4 + secondEthnicityBtnConstraint_Width.constant + 4// width Of ImageIcon, IamTextLbl, leftPadding, Width of first button, Padding, width of second button, padding
//                    if (probableXOfProudLbl + secondLbl_Proud_contraint_Width.constant) > (UIScreen.main.bounds.width - 50) {
//                        print("Proud Lbl should go in next line")
//                        isTextMovedToNextLine = true
//                    }
//                    
//                }
//            }
//            
//            if isTextMovedToNextLine == true {
//                let viewsDictionary: [AnyHashable: Any] = ["firstButton": firstEthnicityBtn, "secondButton": secondEthnicityBtn, "proudLbl": proudTextLbl, "icon": iconImage]
//                
//                if ((firstEthnicityBtnContraint_Width.constant + 46) > (secondEthnicityBtnConstraint_Width.constant + 70))  {
//                    containerViewConstraint_Width.constant = firstEthnicityBtnContraint_Width.constant + firstLbl_Iam_Constraint_Width.constant + 4 + 36
//                    let trailingValueforForButton: CGFloat = containerViewConstraint_Width.constant - (36 + firstLbl_Iam_Constraint_Width.constant + 4 + firstEthnicityBtnContraint_Width.constant)
//                    let trailingValueStringFormate = "H:[firstButton]-\(trailingValueforForButton)-|"
//                    let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: trailingValueStringFormate, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
//                    self.ethniciytContainerView.addConstraints(constraint_POS_H)
//                    
//                    //allign second line in center
//                    let xPosForButton = ((containerViewConstraint_Width.constant - 36) - (secondEthnicityBtnConstraint_Width.constant + 70))/2
//                    print("secondEthnicityBtnConstraint_Width.constant \(secondEthnicityBtnConstraint_Width.constant)")
//                    print("containerViewConstraint_Width.constant \(containerViewConstraint_Width.constant)")
//                    secondEthnicityBtnConstraint_Leading.constant = (xPosForButton+36)
//                    print("secondEthnicityBtnConstraint_Leading.constant \(secondEthnicityBtnConstraint_Leading.constant)")
//                    
//                    let viewsDictionary: [AnyHashable: Any] = ["firstButton": firstEthnicityBtn, "secondButton": secondEthnicityBtn, "proudLbl": proudTextLbl, "icon": iconImage]
//                    let formatString = "H:[icon]-\(xPosForButton)-[secondButton]"
//                    let constraint_POS_L: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: formatString, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
//                    self.ethniciytContainerView.addConstraints(constraint_POS_L)
//                    
//                }
//                else{
//                    containerViewConstraint_Width.constant = secondEthnicityBtnConstraint_Width.constant + 70 + 10
//                    let constraint_POS_H: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:[proudLbl]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
//                    self.ethniciytContainerView.addConstraints(constraint_POS_H)
//                    
//                    //allign first  line in center
////                    let xPosForButton = ((containerViewConstraint_Width.constant - 36) - (firstEthnicityBtnContraint_Width.constant + firstLbl_Iam_Constraint_Width.constant))/2
////                    secondEthnicityBtnConstraint_Leading.constant = xPosForButton
//                    
//                    let constraint_POS_L: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:[icon]-1-[secondButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary as! [String : Any])
//                    self.ethniciytContainerView.addConstraints(constraint_POS_L)
//                }
//            }
//            
//            
//            
//            if (firstEthnicityBtn.isHidden && secondEthnicityBtn.isHidden) {
//                //mtlb ki dono ethnicity selected hai.
//                secondLbl_Proud_contraint_Width.constant = 0
//                firstLbl_Iam_Constraint_Height.constant = 38
//                ethnicityString = ethnicityString + " and Proud!"
//                IamTextLbl.textAlignment = NSTextAlignment.center
//            }
//            
////            self.ethniciytContainerView.layoutIfNeeded()
//            
//            
//            if firstEthnicityBtn.isHidden == false {
//                drawBorderAroundBtn(forButton: firstEthnicityBtn, withWidth: firstEthnicityBtnContraint_Width.constant)
//            }
//            if secondEthnicityBtn.isHidden == false {
//                drawBorderAroundBtn(forButton: secondEthnicityBtn, withWidth: secondEthnicityBtnConstraint_Width.constant)
//            }
//            
//            
//            IamTextLbl.text = ethnicityString
//            firstLbl_Iam_Constraint_Width.constant = Utilities().getTextWidthHeight(IamTextLbl).width + 9
//        }
//        
//        
//        
//        
//    }
    
    func drawBorderAroundBtn(forButton btnObj:UIButton, withWidth widthVal:CGFloat){
        let color = Utilities().getUIColorObject(fromHexString: "D7D7D7", alpha: 1.0).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = btnObj.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: widthVal, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: widthVal/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        shapeLayer.lineDashPattern = [1,1]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
        
        btnObj.layer.addSublayer(shapeLayer)
    }
        
    
    @IBAction func firstBtnTapped(_ sender: AnyObject) {
        print("first button tapped")
        let firstObj: ProfessionModel = ethnicityArrayRecieved!.firstObject as! ProfessionModel
        selectionHandler!([firstObj], !firstObj.inPlace)
    }
    @IBAction func secondBtnTapped(_ sender: AnyObject) {
        print("second button tapped")
        let lastObj: ProfessionModel = ethnicityArrayRecieved!.lastObject as! ProfessionModel
        selectionHandler!([lastObj], !lastObj.inPlace)
    }

}
