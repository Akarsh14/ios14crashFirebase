//
//  WooPlusTrailViewController.swift
//  Woo_v2
//
//  Created by Harish kuramsetty on 24/07/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit
class WooPlusTrailViewController: UIViewController {
    @IBOutlet weak var btnWooPlus: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        btnWooPlus.layer.masksToBounds = false
        btnWooPlus.layer.shadowRadius = 2
        btnWooPlus.layer.shadowOpacity = 0.7
        btnWooPlus.layer.shadowColor = UIColor.gray.cgColor
        btnWooPlus.layer.shadowOffset = CGSize(width: 0 , height:2)
    }

    @IBAction func btnGetWooPlus(_ sender: Any) {
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
