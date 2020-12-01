//
//  DeckView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 16/05/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: UInt = 5

@IBDesignable @objc class DeckView:UIView
{
    @IBOutlet weak var kolodaView: KolodaView!
    var view:UIView!;
    
    private var dataSource: Array<UIImage> = {
        var array: Array<UIImage> = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "DeckView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view);
    }
    
    
}
