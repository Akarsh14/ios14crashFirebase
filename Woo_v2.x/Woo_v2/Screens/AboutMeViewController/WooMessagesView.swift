//
//  WooMessagesView.swift
//  Woo_v2
//
//  Created by Akhil Singh on 07/02/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class WooMessagesView: UIView {

    @IBOutlet weak var tipsPageControl: UIPageControl!
    @IBOutlet weak var wooTipsCollectionView: UICollectionView!
    private var wootipsContainerObject :WooTipsContainer!
    private var wooTipsListViewModel :WooTipsListViewModel!
    private var dataSource :WooTipsDataSource<WooTipsCollectionViewCell,WooTipsViewModel>!
    
    let tipsCollectionViewCellIdentifier = "WooTipsCollectionViewCell"
    
    let cellWidth:CGFloat = UIScreen.main.bounds.width
    let cellHeight:CGFloat = 160
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        return self
    }
    
    /**
     This function loads the nib
     */
    class func loadViewFromNib(frame:CGRect) -> WooMessagesView {
        let messageView: WooMessagesView =
            Bundle.main.loadNibNamed("WooMessagesView", owner: self, options: nil)!.first as! WooMessagesView
        messageView.frame = frame
        messageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        messageView.updateViewBasedOnData()
        return messageView
    }
    
    func updateIndexOfTipsCollectionView(_ index:Int){
        DiscoverProfileCollection.sharedInstance.wooTipsCurrenScreenIndex = index
        tipsPageControl.currentPage = DiscoverProfileCollection.sharedInstance.wooTipsCurrenScreenIndex
        wooTipsCollectionView.setContentOffset(CGPoint(x: Int(SCREEN_WIDTH) * DiscoverProfileCollection.sharedInstance.wooTipsCurrenScreenIndex, y: 0), animated: false)
        if index == self.wooTipsListViewModel.tipsViewModels.count - 1{
            DiscoverProfileCollection.sharedInstance.wooTipsCurrenScreenIndex = 0
        }
        else{         DiscoverProfileCollection.sharedInstance.wooTipsCurrenScreenIndex += 1
        }
    }
    
    private func updateViewBasedOnData(){
        
        let nibName = UINib(nibName: "WooTipsCollectionViewCell", bundle:nil)
        wooTipsCollectionView.register(nibName, forCellWithReuseIdentifier: tipsCollectionViewCellIdentifier)
        
        var tipsImagesArray:[UIImage] = []
        if LoginModel.sharedInstance()?.gender == "FEMALE" || WooPlusModel.sharedInstance()?.isExpired == false{
            tipsImagesArray.append(UIImage(named: "Woo_True_Story") ?? UIImage())
        }
        let tipsNameArray = ["Tips1","Tips2","Tips3","Tips4","Tips5","Tips6"]
        tipsImagesArray.append(contentsOf: tipsNameArray.map({ (tipsName) -> UIImage in
            return UIImage(named: tipsName) ?? UIImage()
        }))
        
        self.wootipsContainerObject = WooTipsContainer(with: tipsImagesArray)
        self.wooTipsListViewModel = WooTipsListViewModel(with: self.wootipsContainerObject)
        self.dataSource = WooTipsDataSource(cellIdentifier: tipsCollectionViewCellIdentifier, items: self.wooTipsListViewModel.tipsViewModels, configureCell: { (cell, viewModel, indexPath) in
            cell.showImageOnTipsImageView(viewModel)
        })
        wooTipsCollectionView.dataSource = self.dataSource
        tipsPageControl.numberOfPages = self.wooTipsListViewModel.tipsViewModels.count
        wooTipsCollectionView.reloadData()
        updateIndexOfTipsCollectionView(0)
    }

}

extension WooMessagesView:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && self.wooTipsListViewModel.tipsViewModels.count > 6{
            WooScreenManager.sharedInstance.oHomeViewController?.presentViewController(.Woo_TrueStory)
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
}

extension WooMessagesView:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffsetX = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.size.width
        let currentImageIndex = currentOffsetX/pageWidth
        updateIndexOfTipsCollectionView(Int(currentImageIndex))
    }
}
