//
//  BaseClassViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 24/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit

@objc class BaseClassViewController: UIViewController {

    var navBar :WooNavBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navBar =  WooNavBarView.load("Discover", type: NavBarStyle.discover, searchIsVisible: true);
        if (navBar != nil) {
            self.view.addSubview(navBar!)
            navBar?.snp.makeConstraints({ (make) in
                if #available(iOS 11, *) {
                    if (UIApplication.shared.keyWindow?.safeAreaInsets.top) != nil{
                    if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                        make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(-20)
                    }
                    else{
                        make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(-20)
                    }
                    }
                    else{
                        if(isIphoneXSMAX() || isIphoneXR()){
                            make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(-20)
                        }else if(iPhoneIsAboveIPhoneXS()){
                            make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(0)
                        }else{
                            make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(-20)
                        }
                    }
                }
                else {
                    make.top.equalTo(self.topLayoutGuide as! ConstraintRelatableTarget)
                }
                make.left.equalTo(self.view.snp.left)
                make.right.equalTo(self.view.snp.right)
                make.height.equalTo(64.0)
            })
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        navBar =  WooNavBarView.load("Discover", type: NavBarStyle.discover, searchIsVisible: true);
        if (navBar != nil) {
            self.view.addSubview(navBar!)
            
            navBar?.snp.makeConstraints({ (make) in
                if #available(iOS 11, *) {
                    if (UIApplication.shared.keyWindow?.safeAreaInsets.top) != nil{
                    if Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!) > 0{
                        make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(0)
                    }
                    else{
                        make.top.equalTo(self.view.safeAreaLayoutGuide as ConstraintRelatableTarget).offset(0)
                    }
                    }
                    else{
                        make.top.equalTo(self.topLayoutGuide as! ConstraintRelatableTarget)
                    }
                }
                else {
                    make.top.equalTo(self.topLayoutGuide as! ConstraintRelatableTarget)
                }
                make.left.equalTo(self.view.snp.left)
                make.right.equalTo(self.view.snp.right)
                make.height.equalTo(64.0)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
