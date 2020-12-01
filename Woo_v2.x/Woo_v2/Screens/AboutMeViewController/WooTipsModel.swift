//
//  WooTipsModel.swift
//  Woo_v2
//
//  Created by Akhil Singh on 03/06/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import Foundation

struct WooTipsModel{
    
    var tipsImage:UIImage?
    
    init(with image:UIImage){
        self.tipsImage = image
    }
}

class WooTipsContainer{
    var wooTipsArray:[WooTipsViewModel] = []
    
    init(with tipsArray:[UIImage]) {
        self.wooTipsArray = tipsArray.map({ (tipsImage) -> WooTipsViewModel in
            return WooTipsViewModel(with: WooTipsModel(with: tipsImage))
        })
    }
}
