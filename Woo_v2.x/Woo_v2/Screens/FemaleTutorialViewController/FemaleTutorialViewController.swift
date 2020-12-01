//
//  FemaleTutorialViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 01/05/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum TutorialViewType : String {
    case Name           = "name"
    case Call           = "call"
    case Unmatch        = "unmatch"
    case Block          = "block"
    case Comfortable    = "comfortable"
    case Like           = "like"
    case SeeHow         = "seeHow"
}


class FemaleTutorialViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tutorialPageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var tutorialCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var nextButtonWidthConstraint: NSLayoutConstraint!
    var isPartOfOnBoarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tutorialCollectionView.register(UINib(nibName: "FemaleTutorialCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FemaleTutorialCollectionViewCell")

        print("isPartOfOnBoarding",isPartOfOnBoarding)
        
        if isPartOfOnBoarding{
            skipButton.setTitle("SKIP", for: .normal)
            skipButton.setImage(UIImage(), for: .normal)
            closeButton.isHidden = true
        }
        else{
            skipButton.setTitle("SKIP", for: .normal)
            skipButton.setImage(UIImage(named: "ic_woo_secret_back_arrow"), for: .normal)
        }
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
        
        // Do any additional setup after loading the view.
        
        
        if((DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos())! < 1){
            
            _ = AlertController.showAlert(withTitle: "Violate our Guidelines!", andMessage: "To encourage connections between real people, we ask that at least one of your photos has you clearly visible in it.", needHandler: false, withController: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     colorTheStatusBar(withColor: UIColor(red: (209.0/255.0), green: (73.0/255.0), blue: (100.0/255.0), alpha: 1.0))
        WooScreenManager.sharedInstance.hideHomeViewTabBar(false, isAnimated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: false)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let topColor  = UIColor(red: (209.0/255.0), green: (73.0/255.0), blue: (100.0/255.0), alpha: 1.0).cgColor
        let middleColor  = UIColor(red: (169.0/255.0), green: (77.0/255.0), blue: (153.0/255.0), alpha: 1.0).cgColor
        let bottomColor  = UIColor(red: (134.0/255.0), green: (80.0/255.0), blue: (199.0/255.0), alpha: 1.0).cgColor
        gradientLayer.colors = [topColor,middleColor,bottomColor];
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
       
    }
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func skipOrBack(_ sender: Any) {
        if isPartOfOnBoarding{
            switch tutorialPageControl.currentPage{
            case 0:
                (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "You are set!" + "_Skip")
                break
            case 1:
                (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "Woo is safe" + "_Skip")
                break
            case 2:
                (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "Woo is private" + "_Skip")
                break
            default:
                break
            }
            
            print("pop hua hai female tutorial")
            self.navigationController?.dismiss(animated: true, completion: nil)
            
//            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.tutorialCollectionView.scrollToItem(at: IndexPath(row: tutorialPageControl.currentPage - 1, section: 0), at: .left, animated: true)
        }
    }
    @IBAction func next(_ sender: Any) {
        if isPartOfOnBoarding{
            if tutorialPageControl.currentPage == tutorialPageControl.numberOfPages - 1{
                (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "Woo gives you control" + "_GetStarted")
//                self.navigationController?.popViewController(animated: true)
                print("pop hua hai female tutorial")
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            else{
                switch tutorialPageControl.currentPage{
                case 0:
                    (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "You are set!" + "_SeeHow")
                    break
                case 1:
                    (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "Woo is safe" + "_Next")
                    break
                case 2:
                    (Utilities.sharedUtility() as! Utilities).sendMixPanelEvent(withName: baseTutorialString + "Woo is private" + "_Next")
                    break
                default:
                    break
                }
                if tutorialPageControl.currentPage < tutorialPageControl.numberOfPages{
                self.tutorialCollectionView.scrollToItem(at: IndexPath(row: tutorialPageControl.currentPage + 1, section: 0), at: .right, animated: true)
                }
            }
        }
        else{
            if tutorialPageControl.currentPage+1 < tutorialPageControl.numberOfPages{
                self.tutorialCollectionView.scrollToItem(at: IndexPath(row: tutorialPageControl.currentPage + 1, section: 0), at: .right, animated: true)
            }
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isPartOfOnBoarding{
            if (LoginModel.sharedInstance().isAlternateLogin){
                tutorialPageControl.numberOfPages = 3
                
                return 3
            }else{
                tutorialPageControl.numberOfPages = 4
                
                return 4
            }
       
        }
        else{
            if (LoginModel.sharedInstance().isAlternateLogin){
                tutorialPageControl.numberOfPages = 5
                return 5
            }else{
                tutorialPageControl.numberOfPages = 6
                return 6
            }
           
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : FemaleTutorialCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FemaleTutorialCollectionViewCell", for: indexPath) as! FemaleTutorialCollectionViewCell

        nextButton.setTitle("", for: .normal)
        nextButtonWidthConstraint.constant = 110
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tutorialPageControl.currentPage = indexPath.row
        if isPartOfOnBoarding{
            if indexPath.row == 0{
                 nextButton.setTitle("SEE HOW", for: .normal)
                 nextButton.imageEdgeInsets.left = 90
            }
            else if indexPath.row == tutorialPageControl.numberOfPages-1{
                nextButton.setTitle("GET STARTED", for: .normal)
                nextButtonWidthConstraint.constant = 140
                nextButton.imageEdgeInsets.left = 120
            }
            else{
                nextButton.imageEdgeInsets.left = 70
            }
        }
        else{
            skipButton.isHidden = false
            nextButton.isHidden = false
            if indexPath.row == 0{
                skipButton.isHidden = true
                nextButton.isHidden = false
            }
          
            else if indexPath.row == tutorialPageControl.numberOfPages-1{
                skipButton.isHidden = false
                nextButton.isHidden = true
            }
        }
        
        let femaleCell : FemaleTutorialCollectionViewCell = cell as! FemaleTutorialCollectionViewCell
        
        switch indexPath.row {
        case 0:
            if isPartOfOnBoarding{
                femaleCell.updateViewBasedOnViewType(.SeeHow, isShownInOnBoarding: true)
            }
            else{
                femaleCell.updateViewBasedOnViewType(.Name, isShownInOnBoarding: false)
            }
        case 1:
            if isPartOfOnBoarding{
                femaleCell.updateViewBasedOnViewType(.Name, isShownInOnBoarding: true)
            }
            else{
                femaleCell.updateViewBasedOnViewType(.Call, isShownInOnBoarding: false)
            }
        case 2:
            if isPartOfOnBoarding{
                if (LoginModel.sharedInstance().isAlternateLogin){
                    femaleCell.updateViewBasedOnViewType(.Like, isShownInOnBoarding: true)
                }else{
                    femaleCell.updateViewBasedOnViewType(.Comfortable, isShownInOnBoarding: true)
                }
                
            }
            else{
                femaleCell.updateViewBasedOnViewType(.Block, isShownInOnBoarding: false)
            }
        case 3:
            if isPartOfOnBoarding{
                femaleCell.updateViewBasedOnViewType(.Like, isShownInOnBoarding: true)
            }
            else{
                femaleCell.updateViewBasedOnViewType(.Unmatch, isShownInOnBoarding: false)
            }
        
             case 4:
                if (!LoginModel.sharedInstance().isAlternateLogin){
                    femaleCell.updateViewBasedOnViewType(.Comfortable, isShownInOnBoarding: false)
                }else{
                     femaleCell.updateViewBasedOnViewType(.Like, isShownInOnBoarding: false)
                }
            
      
        case 5:
            femaleCell.updateViewBasedOnViewType(.Like, isShownInOnBoarding: false)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
