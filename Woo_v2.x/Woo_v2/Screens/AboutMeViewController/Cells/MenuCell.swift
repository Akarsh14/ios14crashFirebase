
//  MenuCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 21/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import Foundation

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dividerLine: UILabel!
    @IBOutlet weak var thickDividerLine: UILabel!
    @IBOutlet weak var centerAlignLayout: NSLayoutConstraint!
    @IBOutlet weak var widthContraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorViewObj: UIActivityIndicatorView!
    @IBOutlet weak var unreadDotImage: UIImageView!
    @IBOutlet weak var titleLabelCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCellDetail(cellDetail:NSDictionary) -> Void{
        iconImage.image = UIImage(named: cellDetail["image"] as! String)
        titleLabel.text = cellDetail["title"] as? String
        
        var showExpiringType:ShowExpiringType = .None
        var showExpiring = false
        if let expiringType = cellDetail["showExpiring"]{
            showExpiringType = expiringType as! ShowExpiringType
        }
        
        if let cellType = cellDetail["cellType"]{
            if (cellType as! String) == showExpiringType.rawValue{
                showExpiring = true
            }
            
            if (cellType as! String) == MeSectionCellType.FindTagsTableViewCell.rawValue{
                subtitleLabel.isHidden = false
                titleLabelCenterConstraint.constant = -8
            }
            else{
                subtitleLabel.isHidden = true
                titleLabelCenterConstraint.constant = 0
            }
        }
        
        var count = "0"
        if let unreadCount = cellDetail["count"]{
            count = unreadCount as! String
        }
        if(DiscoverProfileCollection.sharedInstance.myProfileData?.gender == "MALE")
        {
            unreadDotImage.isHidden = true
            if let showLoaderBool = cellDetail["showLoader"] {
                if showLoaderBool as! Bool {
                    showExpiring = false
                    countLabel.isHidden = true
                    activityIndicatorViewObj.isHidden = false
                    activityIndicatorViewObj.startAnimating()
                }
                else{
                    activityIndicatorViewObj.isHidden = true
                    if (count == "0") {
                        countLabel.isHidden = true
                    }else{
                        if let showCounterAsUnreadBool = cellDetail["showCounterAsUnread"] {
                            if showCounterAsUnreadBool as! Bool
                            {
                                countLabel.backgroundColor = UIColor.init(red: 247.0/255.0, green: 74.0/255.0, blue: 78.0/255.0, alpha: 1.0)
                            }
                            else{
                                countLabel.backgroundColor = Utilities().getUIColorObject(fromHexString: "B8BBC4", alpha: 1.0) // UIColor.init(red: 0.54, green: 0.54, blue: 0.54, alpha: 1.0)
                            }
                        }
                        else{
                            countLabel.backgroundColor = Utilities().getUIColorObject(fromHexString: "B8BBC4", alpha: 1.0)
                        }
                        countLabel.isHidden = false
                        countLabel.text = cellDetail["count"] as? String
                    }
                }
            }
            else{
                activityIndicatorViewObj.isHidden = true
                if (count == "0") {
                    countLabel.isHidden = true
                }else{
                    if let showCounterAsUnreadBool = cellDetail["showCounterAsUnread"] {
                        if showCounterAsUnreadBool as! Bool
                        {
                            countLabel.backgroundColor = UIColor.init(red: 247.0/255.0, green: 74.0/255.0, blue: 78.0/255.0, alpha: 1.0)
                        }
                        else{
                            countLabel.backgroundColor = Utilities().getUIColorObject(fromHexString: "B8BBC4", alpha: 1.0)
                        }
                    }
                    else{
                        countLabel.backgroundColor = Utilities().getUIColorObject(fromHexString: "B8BBC4", alpha: 1.0)
                    }
                    countLabel.isHidden = false
                    countLabel.text = cellDetail["count"] as? String
                }
            }
        }
        else
        {
            activityIndicatorViewObj.isHidden = true
            countLabel.isHidden = true
            if let showCounterAsUnreadBool = cellDetail["showCounterAsUnread"] {
                if showCounterAsUnreadBool as! Bool
                {
                    unreadDotImage.isHidden = false
                }
                else
                {
                    unreadDotImage.isHidden = true
                }
            }
                
            else
            {
                unreadDotImage.isHidden = true
            }
            
        }
        let sizeOfLabel = Utilities().getTextWidthHeight(countLabel)
        var widthOfLabel = sizeOfLabel.width
        widthOfLabel = widthOfLabel + 15.0
        if widthOfLabel < 25 {
            widthOfLabel = 25
        }
        widthContraint.constant = widthOfLabel
        
        if UserDefaults.standard.bool(forKey: "expiringForMeSectionShown") == true || WooScreenManager.sharedInstance.oHomeViewController?.currentTabBarIndex.get() != 0{
            showExpiring = false
        }
        showDividerLine(cellDetail["showThickDivider"] as! Bool)
        if showExpiring{
            makeExpiringAnimation((cellDetail["count"] as? String)!)
            UserDefaults.standard.set(true, forKey: "expiringForMeSectionShown")
            UserDefaults.standard.synchronize()
        }
    }
    
    func makeExpiringAnimation(_ countString:String){
        widthContraint.constant = 60
        countLabel.text = "Expiring"
        countLabel.textColor = UIColorHelper.color(fromRGB: "#F74A4E", withAlpha: 1)
        countLabel.backgroundColor = UIColor.white
        countLabel.layer.borderColor = UIColorHelper.color(fromRGB: "#F74A4E", withAlpha: 1).cgColor
        countLabel.layer.borderWidth = 1.0
        UIView.animate(withDuration: 0.0, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            self.widthContraint.constant = 24
            UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseIn, animations: {
                self.layoutIfNeeded()
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.countLabel.text = ""
                }, completion: { (completed) in
                    self.countLabel.backgroundColor = Utilities().getUIColorObject(fromHexString: "F74A4E", alpha: 1.0)
                    self.countLabel.text = countString
                    self.countLabel.textColor = UIColor.white
                    self.countLabel.layer.borderColor = UIColor.clear.cgColor
                    self.countLabel.layer.borderWidth = 0.0
                })
            })
        }
    }
    
    func showDividerLine(_ showThickDividerLine: Bool) -> Void {
        thickDividerLine.isHidden = !showThickDividerLine
        if showThickDividerLine {
            centerAlignLayout.constant = -4
        }
        dividerLine.isHidden = false
    }
}
