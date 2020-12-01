//
//  WooTipsDataSource.swift
//  Woo_v2
//
//  Created by Akhil Singh on 03/06/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit
import Foundation

class WooTipsDataSource<Cell:UICollectionViewCell, ViewModel>: NSObject, UICollectionViewDataSource {
    
    private var cellIdentifier :String?
    private var items :[ViewModel]!
    var configureCell :(Cell,ViewModel,IndexPath) -> ()
    
    init(cellIdentifier :String, items :[ViewModel], configureCell: @escaping (Cell,ViewModel,IndexPath) -> ()) {
        
        self.cellIdentifier = cellIdentifier
        self.items = items
        self.configureCell = configureCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tipsModel = self.items[indexPath.row]
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier ?? "WooTipsCollectionViewCell", for: indexPath) as! Cell
        self.configureCell(collectionCell,tipsModel,indexPath)
        return collectionCell
    }
    
}
