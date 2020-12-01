//
//  OverlayView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 4/24/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

open class OverlayView: UIView {
    open var overlayState: SwipeResultDirection?
    @IBOutlet weak var skipLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var overlayImageView: UIImageView!
    open var overlayStrength: CGFloat = 0.0 {
        didSet {
            self.alpha = overlayStrength
            
            if overlayState == SwipeResultDirection.Left{
                overlayImageView.image = UIImage(named: overlayLeftImageName)
                likeLabel.isHidden = true
                skipLabel.isHidden = false
            }
            else if overlayState == SwipeResultDirection.Right{
                overlayImageView.image = UIImage(named: overlayRightImageName)
                likeLabel.isHidden = false
                skipLabel.isHidden = true
            }
            else{
                overlayImageView.image = nil
                likeLabel.isHidden = true
                skipLabel.isHidden = true
            }
        }
    }

}
