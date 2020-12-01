//
//  ReviewPhotoCard.swift
//  Woo_v2
//
//  Created by Akhil Singh on 23/10/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SDWebImage

class ReviewPhotoCard: UIView {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reviewPhotoButton: UIButton!

    var dataSource : WooAlbumModel?
    var reviewPhotoModel:ReviewPhotoCardModel?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /**
     This function loads the nib
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    /**
     @IBOutlet weak var commonalityTagsView: UIView!
     InitWithDecoder Method
     
     
     - parameter aDecoder: coder value
     
     - returns: returns Self
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //loadViewFromNib ()
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject { // <== NSCopying
        // *** Construct "one of my current class". This is why init() is a required initializer
        //loadViewFromNib()
        return self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCellID")
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ReviewPhotoCard", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    
    func setDataForReviewPhotoCard() {
        
        if reviewPhotoModel == nil {
            return
        }
        
        reviewPhotoButton.setTitle("          " + (reviewPhotoModel?.buttonName)! + "          ", for: UIControl.State())
        
        descriptionLabel.text = reviewPhotoModel?.cardDescription
        dataSource = reviewPhotoModel?.mediaUrls
        photoCollectionView.reloadData()
    }
}

extension ReviewPhotoCard : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth:CGFloat = collectionView.frame.size.width/3 - 5
        let cellHeight:CGFloat = collectionView.frame.size.height/3 - 5
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension ReviewPhotoCard : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell : PhotoCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellID", for: indexPath)  as? PhotoCollectionViewCell
        
        if cell == nil {
            let array = Bundle.main.loadNibNamed("PhotoCollectionViewCell", owner: self, options: nil)
            cell = array?.first as? PhotoCollectionViewCell
        }
        cell?.deleteButton.isHidden = true
        cell?.backgroundColor = UIColor.clear
        cell?.imageView.backgroundColor = UIColor.clear
        cell?.addImageView.isHidden = true
        cell?.imageView.image = UIImage(named: "ic_brand_card_image_add")
        cell?.lblTopNumber.isHidden = true
        if (indexPath as NSIndexPath).item < (dataSource?.count())! {
            let album = dataSource!.objectAtIndex((indexPath as NSIndexPath).item)! as? AlbumPhoto
            if  album != nil{
                cell?.isUserInteractionEnabled = false
                
                cell?.imageView.sd_setImage(with: URL(string: (album?.url)!), placeholderImage: UIImage(named: "ic_brand_card_image_add"), options: SDWebImageOptions(), completed: { (image, error, cacheType, url) in
                })
                
                if album?.status == "PENDING" {
                    cell?.statusView.isHidden = false
                    cell?.statusView.backgroundColor = UIColor.black
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main - In Review"
                    }
                    else{
                        cell?.statusLabel.text = "In Review"
                    }
                }
                else if album?.status == "APPROVED" {
                    cell?.statusView.backgroundColor = UIColor.black
                    if DiscoverProfileCollection.sharedInstance.pendingListContains(album!) {
                        cell?.statusView.isHidden = false
                        if indexPath.item == 0 {
                            cell?.statusLabel.text = "Main - Approved"
                        }
                        else{
                            cell?.statusLabel.text = "Approved"
                        }
                    }
                    else{
                        if indexPath.item == 0 {
                            cell?.statusLabel.text = "Main"
                            cell?.statusView.isHidden = false
                        }
                        else{
                            cell?.statusView.isHidden = true
                        }
                    }
                }
                else if album?.status == "REJECTED" {
                    cell?.statusView.isHidden = false
                    cell?.statusView.backgroundColor = UIColor(red: 250.0/255.0, green: 72.0/255.0, blue: 73.0/255.0, alpha: 1.0)
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main - Incompatible"
                    }
                    else{
                        cell?.statusLabel.text = "Incompatible"
                    }
                }
                else{
                    if indexPath.item == 0 {
                        cell?.statusLabel.text = "Main"
                        cell?.statusView.isHidden = false
                    }
                }
            }
        }
        else{
            cell?.statusView.isHidden = true
        }
        return cell!
    }
}

extension ReviewPhotoCard : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
