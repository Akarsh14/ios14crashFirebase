//
//  ChatBlockingViewController.swift
//  Woo_v2
//
//  Created by Harish kuramsetty on 17/07/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class ChatBlock: UIView {
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        mainView.layer.cornerRadius = 20
        let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        self.addSubview(blurView)
        self.bringSubviewToFront(mainView)
    }
}
