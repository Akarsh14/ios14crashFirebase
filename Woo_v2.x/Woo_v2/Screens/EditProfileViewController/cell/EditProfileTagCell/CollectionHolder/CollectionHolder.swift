//
//  CollectionHolder.swift
//  Woo_v2
//
//  Created by Suparno Bose on 03/08/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class CollectionHolder: UIView {

    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    var tagArrayUpdateHandler : ((Int)->())?
    
    var addTagHandler : (()->())?
    
    fileprivate var _tagArray : [TagModel]?
    var tagArray : [TagModel]? {
        get{
            return _tagArray
        }
        set(newArray) {
            _tagArray = newArray
            
            tagCollectionView.performBatchUpdates({
                self.tagCollectionView.reloadData()
                }, completion: nil)
        }
    }
    
    class func loadView(_ frame : CGRect) -> CollectionHolder {
        let array = Bundle.main.loadNibNamed("CollectionHolder", owner: self, options: nil)
        let view : CollectionHolder? = array?.first as? CollectionHolder
        
        view?.frame = frame
        
        return view!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagCollectionView.register(UINib(nibName: "EditProfileTagCollectionCell", bundle: nil),
                                      forCellWithReuseIdentifier: "EditProfileTagCollectionCellID")
        
    }

    func sizeForView(_ tagData:TagModel, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = tagData.name
        
        label.sizeToFit()
        if tagData.imageName != nil{
            return CGSize(width: label.frame.size.width + 16 + 32 + 10 , height: height)
        }
        else{
            return CGSize(width: label.frame.size.width + 16 + 32 , height: height)
        }
    }
}

extension CollectionHolder : UICollectionViewDataSource{
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if tagArray == nil {
            return 0
        }
        return (tagArray?.count)!
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        var cell : EditProfileTagCollectionCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProfileTagCollectionCellID", for: indexPath)  as? EditProfileTagCollectionCell
        
        if cell == nil {
            let array = Bundle.main.loadNibNamed("EditProfileTagCollectionCell", owner: self, options: nil)
            cell = array?.first as? EditProfileTagCollectionCell
        }
        //
        cell?.containerView.layer.cornerRadius = 20.0
        cell?.containerView.layer.borderColor = UIColorHelper.color(withRGBA: "#9275DB").cgColor
        cell?.containerView.layer.borderWidth = 1.0
        cell?.containerView.layer.masksToBounds = true
//        cell!.layer.masksToBounds = false
        cell?.layer.cornerRadius = 20.0
//        cell?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        cell?.layer.shadowColor = kTagGreyColor
//        cell?.layer.shadowRadius = 2.0
//        cell!.layer.shadowOpacity = 1.0
        cell?.clipsToBounds = true
        cell?.overlayButton.isHidden = true
        let tag : TagModel = tagArray![(indexPath as NSIndexPath).row] as TagModel
        if let imageName = tag.imageName{
            cell?.tagLabel.text = tag.name!
            cell?.tagImageView.image = UIImage(named: imageName + "_purple")
        }
        else{
            cell?.tagLabel.text = "#" + tag.name!
            cell?.tagImageViewWidthConstraint.constant = 0
            cell?.tagLabelLeadingConstraint.constant = 0
        }
        return cell!
    }
}

extension CollectionHolder : UICollectionViewDelegateFlowLayout{
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let tag : TagModel = tagArray![(indexPath as NSIndexPath).row] as TagModel
        
        return self.sizeForView(tag, font: UIFont(name: "Lato-Medium", size: 14.0)!, height: 40.0)
    }
}

extension CollectionHolder : UICollectionViewDelegate{
    internal func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _tagArray?.remove(at: (indexPath as NSIndexPath).item)
        collectionView.deleteItems(at: [indexPath])
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            if self.tagArrayUpdateHandler != nil {
                self.tagArrayUpdateHandler!((indexPath as NSIndexPath).item)
            }
        })
    }
}

class EditProfileTagCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var crossButton: UILabel!
    @IBOutlet weak var overlayButton: UIButton!
    
    var yoButtonTapped : ((UIButton) -> ())?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if yoButtonTapped != nil {
            yoButtonTapped!(sender)
        }
    }
    
}
