//
//  SelectionCardDeck .swift
//  Woo_v2
//
//  Created by Suparno on 23/06/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

class SelectionCardDeck : UIView, UICollectionViewDataSource {
    
    @IBOutlet weak var subHeaderView: UIView!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
  //  @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var selectionCollectionView: UICollectionView!
    @IBOutlet weak var selectionBGImageView: UIImageView!
    
    @IBOutlet weak var collectionViewHeightConstrain: NSLayoutConstraint!
    
    var selectedValueArray : [String] = []
    
    var selectionEndedHandler : (([ProfessionModel]) -> ())?
    
    var otherButtonHandler : (([ProfessionModel]) -> ())?
    
    var actionButtonHandler : (() -> ())?

    var selectionDetails:SelectionCardModel?
    
    let backgroundGradient:CAGradientLayer = CAGradientLayer()

    /**
     This function loads the nib
     */
    class func loadViewFromNib(frame: CGRect) -> SelectionCardDeck {
//        let bundle = Bundle(for: type(of: SelectionCardDeck.classForCoder()))
        let nib = UINib(nibName: "SelectionCardDeck", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        return view as! SelectionCardDeck
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        selectionCollectionView.dataSource = self
        
        selectionCollectionView.delegate = self
                
        selectionCollectionView.register(UINib(nibName: "EditProfileTagCollectionCell", bundle: nil),
                                   forCellWithReuseIdentifier: "EditProfileTagCollectionCellID")
        
        selectionCollectionView.allowsSelection = true
        
        //setDataForSelectionView()
    }
    @IBAction func actionPerformed(_ sender: Any) {
        actionButtonHandler!()
    }
    
    @IBAction func crossButtonTapped(_ sender: AnyObject) {
        //ctaButtonTappedHandler(false)
    }
    
    @IBAction func ctaButtonTapped(_ sender: AnyObject) {
        //ctaButtonTappedHandler(true)
    }
    
    func setDataForSelectionView() {
        
        if selectionDetails == nil {
            return
        }
        
        let utilities = Utilities.sharedUtility() as! Utilities
        
        if selectionDetails?.subCardType == SelectionSubCardType.PERSONAL_QUOTE{
            buttonBackgroundView.backgroundColor = UIColor.clear
            actionButton.backgroundColor = utilities.getUIColorObject(fromHexString:"#FA4849", alpha: 1.0)
            overlayView.isHidden = true
            graphView.isHidden = true
        }
        else if selectionDetails?.subCardType == SelectionSubCardType.WORK_EDUCATION{
            actionButton.backgroundColor = utilities.getUIColorObject(fromHexString:"#0077B5", alpha: 1.0)
            overlayView.isHidden = true
            graphView.isHidden = true
        }
        else if selectionDetails?.subCardType == SelectionSubCardType.ANALYZE_PROFILE{
            overlayView.isHidden = true
            buttonBackgroundView.isHidden = false
            graphView.isHidden = false
            addGradiantToView(graphView, top: false)
            actionButton.backgroundColor = utilities.getUIColorObject(fromHexString:"#FA4849", alpha: 1.0)
        }
        else{
            buttonBackgroundView.isHidden = true
            subHeaderView.isHidden = true
            graphView.isHidden = true
        }
        
        if (selectionDetails?.subHeaderText.count)! > 0{
            subHeaderView.isHidden = false
            subHeaderLabel.text = selectionDetails?.subHeaderText
            addGradiantToView(subHeaderView, top: true)
        }
        else{
            subHeaderView.isHidden = true
        }
        
        if (selectionDetails?.ctaIconAvailable)!{
            actionButton.setImage(UIImage(named: "ic_analyze_button"), for: .normal)
        }
        
        let buttonText:String = "   " + (selectionDetails?.buttonText)! + "   "
        actionButton.setTitle(buttonText, for: .normal)
        
        headerLabel.text = selectionDetails?.headerText
      //  footerLabel.text = selectionDetails?.footerText
        
        selectionBGImageView.sd_setImage(with: URL(string: (selectionDetails?.imageUrl)!))
        
        descriptionLabel.text = selectionDetails?.descriptionText
        
        selectionCollectionView.reloadData()
    }
    
    func addGradiantToView(_ view:UIView, top:Bool){
        if top{
            backgroundGradient.colors = [kGradientColorBlackTop, kGradientColorClear]
        }
        else{
            backgroundGradient.colors = [kGradientColorClear, kGradientColorBlackTop]
        }
        backgroundGradient.frame = CGRect(x: 0, y: 0,
                                   width: SCREEN_WIDTH - 20,
                                   height: view.frame.size.height)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    func selectedTagArrayFull() -> [ProfessionModel] {
        var selectedArray : [ProfessionModel] = []
        for tagName in selectedValueArray {
            for tagDto in (selectionDetails?.tags)! {
                if tagDto.name == tagName {
                    selectedArray.append(tagDto)
                    break
                }
            }
        }
        return selectedArray
    }
    
    func sizeForView(_ text:String, font:UIFont, height:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 16 + 33 , height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.selectionDetails == nil {
            return 0
        }
        return self.selectionDetails!.tags.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var cell : EditProfileTagCollectionCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProfileTagCollectionCellID", for: indexPath)  as? EditProfileTagCollectionCell
        
        if cell == nil {
            let array = Bundle.main.loadNibNamed("EditProfileTagCollectionCell", owner: self, options: nil)
            cell = array?.first as? EditProfileTagCollectionCell
        }
        
        cell?.containerView.backgroundColor = UIColor.clear
        cell!.layer.masksToBounds = false
        cell?.layer.cornerRadius = 2.0
        cell?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell?.layer.shadowColor = UIColor.gray.cgColor
        cell?.layer.shadowRadius = 2.0
        cell!.layer.shadowOpacity = 1.0
        cell?.clipsToBounds = false
        
        if (indexPath as NSIndexPath).row == (self.selectionDetails!.tags.count - 1){
            cell?.crossButton.text = ""
        }
        else{
            cell?.crossButton.text = "+"
        }
        
        cell?.crossButton.textColor = UIColor(red: 55.0/255.0, green: 58.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        
        let tag : ProfessionModel = self.selectionDetails!.tags[(indexPath as NSIndexPath).row] as ProfessionModel
        
        if !selectedValueArray.contains(tag.name!){
            cell?.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
            cell?.tagLabel.textColor = UIColor(red: 55.0/255.0, green: 58.0/255.0, blue: 67.0/255.0, alpha: 1.0)
            cell?.crossButton.isHidden = false
        }
        else{
            cell?.backgroundColor = UIColor(red: 127.0/255.0, green: 91.0/255.0, blue: 210.0/255.0, alpha: 1.0)
            cell?.tagLabel.textColor = UIColor.white
            cell?.crossButton.isHidden = true
        }
        
        cell?.selectedBackgroundView = UIView(frame: (cell?.frame)!)
        
        cell?.selectedBackgroundView?.backgroundColor = UIColor.blue
        
        cell?.tagLabel.text = tag.name!
        
        cell?.overlayButton.isHidden = false
        
        cell?.overlayButton.tag = indexPath.item
        
        cell?.yoButtonTapped = { (button) in
            let tag : ProfessionModel = self.selectionDetails!.tags[button.tag] as ProfessionModel
            
            if self.selectedValueArray.contains(tag.name!){
                self.selectedValueArray.remove(object: tag.name!)
            }
            else{
                if self.selectedValueArray.count < (self.selectionDetails?.maxSelection)! {
                    if (self.selectionDetails?.tags[button.tag].tagId)! == "-1" &&
                        self.otherButtonHandler != nil{
                        self.otherButtonHandler!(self.selectedTagArrayFull())
                    }
                    else{
                        self.selectedValueArray.append(tag.name!)
                        if self.selectionEndedHandler != nil{
                            self.selectionEndedHandler!(self.selectedTagArrayFull())
                        }
                    }
                }
            }
            self.selectionCollectionView.reloadData()
        }
        
        return cell!
    }
}

extension SelectionCardDeck : UICollectionViewDelegate{
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        print("\(indexPath.item)  => \(cell.frame.origin.y)")
        
        if indexPath.item == (self.selectionDetails!.tags.count - 1){
            collectionViewHeightConstrain.constant = cell.frame.origin.y + cell.frame.size.height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tag : ProfessionModel = self.selectionDetails!.tags[(indexPath as NSIndexPath).row] as ProfessionModel
        
        if selectedValueArray.contains(tag.name!){
            selectedValueArray.remove(object: tag.name!)
        }
        else{
            selectedValueArray.append(tag.name!)
        }
        selectionCollectionView.reloadData()
    }
}

extension SelectionCardDeck : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let tag : ProfessionModel = self.selectionDetails!.tags[(indexPath as NSIndexPath).row] as ProfessionModel
                
        return self.sizeForView(tag.name!, font: UIFont(name: "Lato-Regular", size: 14.0)!, height: 38.0)
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
