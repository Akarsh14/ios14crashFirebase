//
//  BoostCell.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 21/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import Foundation

enum SellingViewForMeSection: Int {
    case none = -1
    case sellBoost
    case sellCrush
    case sellWooPlus
    case sellWooGlobe
    case freeTrail
}


class BoostCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var boostedLabel: UILabel!
    @IBOutlet weak var boostMeButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    var currentSellingView: SellingViewForMeSection = SellingViewForMeSection.none  //0 > Boost, 1 > Crush, 2 > Sub
    
//    var parentSellingTextMsg = ""
    
    var getBoostHandler:((_ senderObj: AnyObject, _ currentSellingViewValue: Int) -> (Void))?
    
    @IBAction func boostMeButtonTapped(_ sender: AnyObject) {
        
        if boostMeButton.isHidden {
            return
        }
        
        switch currentSellingView {
        case SellingViewForMeSection.sellBoost :
            if BoostModel.sharedInstance().availableBoost > 0 && BoostModel.sharedInstance().currentlyActive == false {
                BoostProductsAPICalss.activateBoost(forWooID: (UserDefaults.standard.object(forKey: kWooUserId) as?String), withCompletionBlock: { (successFlag, responseObj, statusCode) in
                    
                    if  successFlag{
                        
                        // lets do something here for handling boosted stuff
                        self.updateDataOnCellFromBoostModel()
                        WooScreenManager.sharedInstance.oHomeViewController?.checkIfBoostActive()
                    }else{
                        
                    }
                })
            }else if (BoostModel.sharedInstance().availableBoost < 1){
                // take user to purchase screen
                
                if getBoostHandler != nil {
                    self.getBoostHandler!(sender, currentSellingView.rawValue)
                }
            }
            break
        case SellingViewForMeSection.sellCrush:
            if getBoostHandler != nil {
                self.getBoostHandler!(sender, currentSellingView.rawValue)
            }
            break
        case SellingViewForMeSection.sellWooPlus:
            if getBoostHandler != nil {
                //(Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MeSectionLanding", withEventName: "3-MeSection.MeSectionLanding.MSL_WPAd_Tap")
                self.getBoostHandler!(sender, currentSellingView.rawValue)
            }
            break
        case SellingViewForMeSection.sellWooGlobe:
            if getBoostHandler != nil {
                self.getBoostHandler!(sender, currentSellingView.rawValue)
            }
            break
        case SellingViewForMeSection.freeTrail:
            if getBoostHandler != nil {
                self.getBoostHandler!(sender, currentSellingView.rawValue)
            }
            break
        default:
            if BoostModel.sharedInstance().availableBoost > 0 && BoostModel.sharedInstance().currentlyActive == false {
                BoostProductsAPICalss.activateBoost(forWooID: (UserDefaults.standard.object(forKey: kWooUserId) as?String), withCompletionBlock: { (successFlag, responseObj, statusCode) in
                    
                    if  successFlag{
                        
                        // lets do something here for handling boosted stuff
                        self.updateDataOnCellFromBoostModel()
                        
                    }else{
                        
                    }
                })
            }else if (BoostModel.sharedInstance().availableBoost < 1){
                // take user to purchase screen
                
                if getBoostHandler != nil {
                    self.getBoostHandler!(sender, currentSellingView.rawValue)
                }
            }
            break
        }
  
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setBoostCellDetail(cellDetail:NSDictionary) -> Void{
        
        iconImage.image = UIImage(named: cellDetail["image"] as! String)
        
        self.updateDataOnCellFromBoostModel()
    }
    
    
    func updateDataOnCellFromBoostModel(){
        
        newBoostWooPlusLogic()
        boostMeButton.layer.shadowColor = UIColor.darkGray.cgColor
        boostMeButton.layer.shadowOpacity = 0.4
        boostMeButton.layer.shadowRadius = 3.0
        boostMeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
//        currentSellingView = 0
        
        
        switch currentSellingView {
            case SellingViewForMeSection.sellBoost:
                iconImage.image = UIImage(named: "ic_me_boost.png")
                if BoostModel.sharedInstance().checkIfUserNeedsToPurchase() {
                    boostedLabel.isHidden = true
                    boostMeButton.isHidden = false
                    titleLabel.text = NSLocalizedString("Get seen by more people", comment: "Number of boosts left")
                    boostMeButton.setTitle(NSLocalizedString("GET BOOST", comment: "text which will come on button when user has boost but not active"), for: UIControl.State())
                }
                else{
                    
                    if ((BoostModel.sharedInstance().availableBoost > 0) && BoostModel.sharedInstance().currentlyActive == false){
                        if BoostModel.sharedInstance().availableBoost == 1 {
                            titleLabel.text = String(format:NSLocalizedString("%ld boost remaining.", comment: "%ld boost remaining."),BoostModel.sharedInstance().availableBoost)
                        }
                        else{
                            titleLabel.text = String(format:NSLocalizedString("%ld boosts remaining.", comment: "%ld boosts remaining."),BoostModel.sharedInstance().availableBoost)
                        }
                        
                        boostedLabel.text = NSLocalizedString("ACTIVATE", comment: "text which will appear on me section when user is boosted")
                        //                boostMeButton.titleLabel?.text = NSLocalizedString("BOOST ME", comment: "text which will appear on me section when user is boosted")
                        boostMeButton.setTitle(NSLocalizedString("ACTIVATE", comment: "text which will appear on me section when user is boosted"), for: UIControl.State())
                        boostedLabel.isHidden = true
                        boostMeButton.isHidden = false
                    }
                    else{
                        
                        if BoostModel.sharedInstance().availableBoost == 1 {
                            titleLabel.text = String(format:NSLocalizedString("Boosting... %ld boost remaining.", comment: "%ld boosts remaining."),BoostModel.sharedInstance().availableBoost)
                        }
                        else{
                            titleLabel.text = String(format:NSLocalizedString("Boosting... %ld boosts remaining.", comment: "%ld boosts remaining."),BoostModel.sharedInstance().availableBoost)
                        }
                        
                        boostedLabel.text = NSLocalizedString("ACTIVATE", comment: "text which will appear on me section when user is boosted")
                        //                boostMeButton.titleLabel?.text = NSLocalizedString("BOOST ME", comment: "text which will appear on me section when user is boosted")
                        boostMeButton.setTitle(NSLocalizedString("", comment: "text which will appear on me section when user is boosted"), for: UIControl.State())
                        boostedLabel.isHidden = true
                        boostMeButton.isHidden = true
                    }
                }
                break
            case SellingViewForMeSection.sellCrush:
                iconImage.image = UIImage(named: "ic_me_boost.png")
                titleLabel.text = NSLocalizedString("Get seen by more people", comment: "Number of boosts left")
                boostMeButton.setTitle(NSLocalizedString("Get Crush", comment: "Get Crush"), for: UIControl.State())
                boostedLabel.isHidden = true
                boostMeButton.isHidden = false
                break
            case SellingViewForMeSection.sellWooPlus:
                iconImage.image = UIImage(named: "ic_me_wooplus")
                titleLabel.text = NSLocalizedString("Get member privileges", comment: "Get member privileges")
                boostMeButton.setTitle(NSLocalizedString("BUY WOOPLUS", comment: "BUY WOOPLUS"), for: UIControl.State())
                boostedLabel.isHidden = true
                boostMeButton.isHidden = false
                break
            case SellingViewForMeSection.sellWooGlobe:
                iconImage.image = UIImage(named: "ic_me_wooplus")
                titleLabel.text = NSLocalizedString("Get member privileges", comment: "Number of boosts left")
                boostMeButton.setTitle(NSLocalizedString("WOO GLOBE", comment: "WOO GLOBE"), for: UIControl.State())
                boostedLabel.isHidden = true
                boostMeButton.isHidden = false
                break
        case SellingViewForMeSection.freeTrail:
            iconImage.image = UIImage(named: "ic_me_wooplus")
            titleLabel.text = "Unlock everything with WooPlus"
            boostMeButton.setTitle("TRY FOR FREE", for: UIControl.State())
            boostedLabel.isHidden = true
            boostMeButton.isHidden = false
            break
            
        default:
            // do nothing
            break
        }        
    }
    
    func newBoostWooPlusLogic(){
        let _: Int = AppLaunchModel.sharedInstance().numberOfTimesAboutMeLaunched
        if(FreeTrailModel.sharedInstance().planId.count > 0){
            print(FreeTrailModel.sharedInstance().planId)
            currentSellingView = SellingViewForMeSection.freeTrail
        }
        else if ((BoostModel.sharedInstance().checkIfUserNeedsToPurchase() == false) &&  (BoostModel.sharedInstance().availableBoost > 0) && (BoostModel.sharedInstance().currentlyActive == false)){
            currentSellingView = SellingViewForMeSection.sellBoost
        }
        else if ((MeDashboard.getAllBoostProfiles().count > 0) && (LikedMe.getAllLikedMeProfiles().count > 0)) {
            if ((WooPlusModel.sharedInstance().isExpired == true) && (WooPlusModel.sharedInstance().availableInRegion == true)) {
                // Woo plus becho
                currentSellingView = SellingViewForMeSection.sellWooPlus
            }
            else{
                //Boost becho
                currentSellingView = SellingViewForMeSection.sellBoost
            }
        }
        else if (MeDashboard.getAllBoostProfiles().count > 0){
            
            if WooPlusModel.sharedInstance().isExpired && WooPlusModel.sharedInstance().availableInRegion {
                
                /*
                if (numberOfTimesMeSectionAppeared % 2 == 1) {
                    // Woo plus becho
                    currentSellingView = SellingViewForMeSection.sellWooPlus
                }
                else{
                    //Boost becho
                    currentSellingView = SellingViewForMeSection.sellBoost
                }
                */
                currentSellingView = SellingViewForMeSection.sellWooPlus

            }
            else{
                //Boost becho
                currentSellingView = SellingViewForMeSection.sellBoost
            }

//            text : See your visitors 
            //CTA : woo Plus / Boost
        }
        else if (LikedMe.getAllLikedMeProfiles().count > 0){
            
            if WooPlusModel.sharedInstance().isExpired && WooPlusModel.sharedInstance().availableInRegion {
                
                currentSellingView = SellingViewForMeSection.sellWooPlus
            }
            else{
                //Boost becho
                currentSellingView = SellingViewForMeSection.sellBoost
            }
            //text : See who liked you
            //CTA : Woo plus
        }
        else
        {
            
            //Boost becho bus
            //text : ???
            // CTA : boost 
            currentSellingView = SellingViewForMeSection.sellBoost
            
            
        }
    }
    
}
