//
//  ComboPurchaseTableViewCell.swift
//  Woo_v2
//
//  Created by Ankit Batra on 20/07/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ComboPurchaseTableViewCell: UITableViewCell {

    @IBOutlet weak var comboContainerView: UIView!
    @IBOutlet weak var okTextLabel: UILabel!
    @IBOutlet weak var leftTopLabel: UILabel!
    
    @IBOutlet weak var leftBottomLabel: UILabel!
    @IBOutlet weak var priceUnitLabel: UILabel!
    @IBOutlet weak var comboSeperatorImageView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataOnCellwith(cellData:WooGlobalProductModel,productType:PurchaseType)
    {
        print(cellData)
        if(cellData.wooProductDto != nil)
        {
            let dataDict = cellData.wooProductDto?.first as! [AnyHashable:Any]
            if(dataDict["screenVariant"] as? String ?? "" == "A")
            {
                priceUnitLabel.isHidden = true
                leftBottomLabel.textAlignment = .center
                leftTopLabel.textAlignment = .center
                
            }
            else
            {
                priceUnitLabel.isHidden = false
                leftBottomLabel.textAlignment = .left
                leftTopLabel.textAlignment = .left

            }
            leftBottomLabel.text = dataDict["leftSideBottomText"] as? String ?? "with WooPlus"
            leftTopLabel.text = dataDict["leftSideTopText"] as? String ?? ""
            priceUnitLabel.text = "\(cellData.wooProductDto?.first?.object(forKey: "rightSideText") as? String ?? "")"

            switch productType
            {
            case .boost:

                comboSeperatorImageView.backgroundColor =  UIColorHelper.color(withRGBA: "#DED3F1")

                leftBottomLabel.textColor = UIColorHelper.color(withRGBA: "#936DD1")
                leftTopLabel.textColor = UIColorHelper.color(withRGBA: "#936DD1")
                comboContainerView.backgroundColor = UIColorHelper.color(withRGBA: "#FBF4FF")
                okTextLabel.textColor =  UIColorHelper.color(withRGBA: "#936DD1")
                priceUnitLabel.textColor  =  UIColorHelper.color(withRGBA: "#936DD1")


                break
                
            case .crush:
                comboSeperatorImageView.backgroundColor =  UIColorHelper.color(withRGBA: "#F9C7CE")

                leftBottomLabel.textColor = UIColorHelper.color(withRGBA: "#E7465C")
                leftTopLabel.textColor = UIColorHelper.color(withRGBA: "#E7465C")
                okTextLabel.textColor =  UIColorHelper.color(withRGBA: "#E7465C")
                priceUnitLabel.textColor  =  UIColorHelper.color(withRGBA: "#E7465C")


                comboContainerView.backgroundColor = UIColorHelper.color(withRGBA: "#FEF0F1")

                break
                
            case .wooPlus:
                comboSeperatorImageView.backgroundColor =  UIColorHelper.color(withRGBA: "#BDEACA")
                leftBottomLabel.textColor = UIColorHelper.color(withRGBA: "#11A93E")
                leftTopLabel.textColor = UIColorHelper.color(withRGBA: "#11A93E")
                comboContainerView.backgroundColor = UIColorHelper.color(withRGBA: "#E0FBE8")
                priceUnitLabel.textColor  =  UIColorHelper.color(withRGBA: "#11A93E")

                break
            case .wooGlobe:
//                comboContainerView.layer.borderWidth = 2.0
//                comboContainerView.layer.borderColor = UIColorHelper.color(withRGBA: "#C3EEED").cgColor
                comboSeperatorImageView.backgroundColor =  UIColorHelper.color(withRGBA: "#C3EEED")
                leftBottomLabel.textColor = UIColorHelper.color(withRGBA: "#20ADA8")
                leftTopLabel.textColor = UIColorHelper.color(withRGBA: "#20ADA8")
                priceUnitLabel.textColor  =  UIColorHelper.color(withRGBA: "#20ADA8")
                comboContainerView.backgroundColor = UIColorHelper.color(withRGBA: "#DEFFFE")
                break
            default:
                break
                
            }
         //   let priceUnit = cellData.wooProductDto?.first?.object(forKey: "priceUnit") as? String
                    
//            var productNamePerUnit = cellData.wooProductDto?.first?.object(forKey: "productNamePerUnit") as? String
//            if (productNamePerUnit?.characters.count)! > 0 {
//                productNamePerUnit = NSString.init(format: "/%@", productNamePerUnit!) as String
//            }
//            else{
//                productNamePerUnit = ""
//            }

            let multiplier = SCREEN_WIDTH/320.0
            if(multiplier != 1 && okTextLabel.font.pointSize == 14.0)
            {
                
            priceUnitLabel.font =  UIFont(name: "Lato-Bold", size: multiplier * priceUnitLabel.font.pointSize)!
            leftBottomLabel.font =  UIFont(name: "Lato-Medium", size: multiplier * leftBottomLabel.font.pointSize)!
            leftTopLabel.font =  UIFont(name: "Lato-Bold", size: multiplier * leftTopLabel.font.pointSize)!
            okTextLabel.font = UIFont(name: "Lato-Black", size: multiplier * okTextLabel.font.pointSize)!
            }

        }
    }
    
}
