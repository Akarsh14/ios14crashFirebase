//
//  WooTipsViewModel.swift
//  Woo_v2
//
//  Created by Akhil Singh on 03/06/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import Foundation

class WooTipsListViewModel{
    private(set) var tipsViewModels :[WooTipsViewModel] = [WooTipsViewModel]()
    private var tipsContainer:WooTipsContainer?
    init(with tipsContainer:WooTipsContainer){
        self.tipsContainer = tipsContainer
        populateTipsViewModelsArray()
    }
    
    fileprivate func populateTipsViewModelsArray(){
        self.tipsViewModels = self.tipsContainer?.wooTipsArray ?? []
    }
    
    func tipsViewModelAtIndex(_ index:Int) -> WooTipsViewModel{
        return self.tipsViewModels[index]
    }
}

class WooTipsViewModel{
    var tipsImage:UIImage?
    
    init(with tipsModel:WooTipsModel){
        self.tipsImage = tipsModel.tipsImage
    }
}
