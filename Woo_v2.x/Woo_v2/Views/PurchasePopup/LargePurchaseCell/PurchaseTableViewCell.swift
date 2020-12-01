//
//  PurchaseTableViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 01/08/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class PurchaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currencyUnitLabel: UILabel!
    @IBOutlet weak var pricePerUnitLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var offerBackground: UIView!
    
    @IBOutlet weak var topSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottonSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var priceTextVerticalAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var quantityLabelcenterY: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setDataOnCellwith(cellData:NSDictionary, isSelected: Bool, isLargeCell:Bool,  productType:PurchaseType){
        
        print(cellData)
        offerBackground.layer.cornerRadius = 9.0
        offerBackground.layer.masksToBounds = true
        roundedView.layer.cornerRadius = 5.0
        roundedView.layer.borderWidth = 1.0
        
        var discountString:String = ""
        
        discountString = cellData.object(forKey: "discount") as! String
        
        if discountString.count < 1 {
            priceTextVerticalAlignmentConstraint.constant = 0
            offerBackground.isHidden = true
            
        }else{
            priceTextVerticalAlignmentConstraint.constant = -13
            offerBackground.isHidden = false
            offerLabel.text = cellData.object(forKey: "discount") as! String?
        }
        
        if let count = cellData.object(forKey: "count") as! NSNumber?{
            quantityLabel.text = "\(count)"
        }else{
            quantityLabel.text = cellData.object(forKey: "count") as! String?
        }
        
        durationLabel.text = cellData.object(forKey: "productName") as! String?
        
        currencyUnitLabel.text = cellData.object(forKey: "priceUnit") as! String?
        
        pricePerUnitLabel.text = cellData.object(forKey: "pricePerUnit") as! String?
        
        let productNamePerUnit = cellData.object(forKey: "productNamePerUnit") as! String?
        
        if (productNamePerUnit?.count)! > 0 {
            unitLabel.text = NSString.init(format: "/%@", productNamePerUnit!) as String
        }
        else{
            unitLabel.text = ""
        }
        
        quantityLabel.font = UIFont(name: "Lato-Bold", size: (SCREEN_WIDTH*0.065625))
        
        switch productType {
        case .boost:
            
            roundedView.layer.borderColor = UIColor(red: 0.57, green: 0.46, blue: 0.86, alpha: 1.0).cgColor
            
            if isSelected{
                
                quantityLabel.textColor = UIColor(red: 0.42, green: 0.27, blue: 0.78, alpha: 1.0)
                roundedView.backgroundColor = UIColor(red: 0.91, green: 0.89, blue: 0.97, alpha: 1.0)
                
            }else{
                
                quantityLabel.textColor = UIColor(red: 0.22, green: 0.23, blue: 0.26, alpha: 1.0)
                roundedView.backgroundColor = UIColor.white
            }
            
            break
            
        case .crush:
            
            roundedView.layer.borderColor = UIColor(red: 0.98, green: 0.28, blue: 0.29, alpha: 1.0).cgColor
            
            if isSelected {
                
                quantityLabel.textColor = UIColor(red: 0.85, green: 0.16, blue: 0.17, alpha: 1.0)
                roundedView.backgroundColor = UIColor(red: 1.00, green: 0.91, blue: 0.91, alpha: 1.0)
                
            }else{
                
                quantityLabel.textColor = UIColor(red: 0.22, green: 0.23, blue: 0.26, alpha: 1.0)

                roundedView.backgroundColor = UIColor.white
                
            }
            break

        case .wooPlus:
            
            roundedView.layer.borderColor = UIColor(red: 0.31, green: 0.76, blue: 0.38, alpha: 1.0).cgColor
            
            if isSelected {
                
                quantityLabel.textColor = UIColor(red: 0.24, green: 0.60, blue: 0.30, alpha: 1.0)
                roundedView.backgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.89, alpha: 1.0)
                
                
            }else{
                
                quantityLabel.textColor = UIColor(red: 0.22, green: 0.23, blue: 0.26, alpha: 1.0)
                roundedView.backgroundColor = UIColor.white
                
            }
            break
        case .wooGlobe:
            
            roundedView.layer.borderColor = UIColor(red: 0.0, green: 145/255, blue: 139/255, alpha: 1.0).cgColor
            
            roundedView.backgroundColor = UIColor(red: 57/255, green: 200/255, blue: 195/255, alpha: 1.0)
            
            quantityLabel.textColor = UIColor.white
            
            quantityLabel.text = quantityLabel.text! + " days access"
            
            quantityLabel.font = UIFont(name: "Lato-Bold", size: 18.0)
            
            quantityLabelcenterY.constant = 0.0
            
            durationLabel.isHidden = true
            
            pricePerUnitLabel.text = "\(cellData.object(forKey: "price")!)"
            
            break
            
        default:
            
            break
            
        }
        
        durationLabel.textColor = quantityLabel.textColor
        currencyUnitLabel.textColor = quantityLabel.textColor
        pricePerUnitLabel.textColor = quantityLabel.textColor
        unitLabel.textColor = quantityLabel.textColor
        offerLabel.textColor = UIColor(red: 0.22, green: 0.23, blue: 0.26, alpha: 1.0)
        
//        var  topBottomSpacingConstraint:CGFloat = 0.0
        
        
//        if isLargeCell {
//            topBottomSpacingConstraint = SCREEN_WIDTH * 0.021875
//        }else{
//            topBottomSpacingConstraint = SCREEN_WIDTH * 0.009375
//        }
        
        
//        topSpacingConstraint.constant = topBottomSpacingConstraint
//        bottonSpacingConstraint.constant = topBottomSpacingConstraint
        
        let bottomTextFont:UIFont = UIFont(name: "Lato-Regular", size: (SCREEN_WIDTH*0.0375))!
        let topTextFont:UIFont = UIFont(name: "Lato-Regular", size: (SCREEN_WIDTH*0.040625))!
        
        offerLabel.font = bottomTextFont
        durationLabel.font = bottomTextFont
        
        pricePerUnitLabel.font = topTextFont
        unitLabel.font = topTextFont
        currencyUnitLabel.font = topTextFont
        
    }
    
}
