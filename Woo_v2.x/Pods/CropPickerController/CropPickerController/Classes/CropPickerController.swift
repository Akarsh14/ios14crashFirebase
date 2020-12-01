//Copyright (c) 2018 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit
import Photos
import CropPickerView

// PHAssetCollection and PHAssetCollection together, Combine into a tuple, AssortCollection with typealias
typealias AssetCollection = (collection: PHAssetCollection, count: Int)

// Picker Type
public enum CropPickerType {
case single
case complex
}

public protocol CropPickerDelegate: class {
func cropPickerBackAction(_ cropPickerController: CropPickerController)
    func cropPickerCompleteAction(_ cropPickerController: CropPickerController, images: [UIImage]?, error: Error?, navigationController : UINavigationController)
}

public class CropPickerController: UIViewController {
// MARK: Delegate
public weak var delegate: CropPickerDelegate?
var matchingImageFound = 1
var firstTimeCollectionViewReload = 0
var afterEffectCropValue = 1
var titleSelectedNumber = 0
var maximumTitleToBeSelected = 9
var comingFromEditProfile = false
var alreadyCropped = false
public var imageToBeCroppedArray = [UIImage]()
public var imagesInDataPng = [NSData]()
public var getZoomScrollingDictionary = [[String:Any]]()
let spinner = UIActivityIndicatorView(style: .whiteLarge)
//public var saveCropPickerImageForDeletion = [UIImage]()
let defaultImagePlaceHolder = UIImage(named: "ic_wizard_default_avatar.png")
    var navbar = UINavigationBar()
 
// When turned off, the observer of PHPhotoLibrary is also turned off.
deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
}

// MARK: Public Property

// Left Bar Button Item
public var leftBarButtonItem: UIBarButtonItem? {
    willSet {
        self.navigationItem.leftBarButtonItem = newValue
    }
}

// Right Bar Button Item
public var rightBarButtonItem: UIBarButtonItem? {
    willSet {
        self.navigationItem.rightBarButtonItem = newValue
    }
}

// Title Button
public var titleButton: UIButton {
    return self._titleButton
}

// Background color of camera cell
public var cameraBackgroundColor: UIColor {
    set {
        PictureCell.cameraBackgroundColor = newValue
    }
    get {
        return PictureCell.cameraBackgroundColor
    }
}

// Camera image color of camera cell
public var cameraTintColor: UIColor {
    set {
        PictureCell.cameraTintColor = newValue
    }
    get {
        return PictureCell.cameraTintColor
    }
}

// Dim image color of the image cell when the image is selected
public var pictureDimColor: UIColor {
    set {
        PictureCell.dimColor = newValue
    }
    get {
        return PictureCell.dimColor
    }
}

// The color of the background color in the selection box of the image cell.
public var selectBoxBackgroundColor: UIColor {
    set {
        CheckBoxView.selectBackgroundColor = .white
    }
    get {
        return CheckBoxView.selectBackgroundColor
    }
}

// The color of the layer in the Select check box of the image cell.
public var selectBoxLayerColor: UIColor {
    set {
        CheckBoxView.layerColor = newValue
    }
    get {
        return CheckBoxView.layerColor
    }
}

// The color of the image cell's selection checkbox.
public var selectBoxTintColor: UIColor {
    set {
        CheckBoxView.selectTintColor = newValue
    }
    get {
        return CheckBoxView.selectTintColor
    }
}

// The text color of progressView.
public var progressTextColor: UIColor {
    get {
        return ProgressView.textColor
    }
    set {
        ProgressView.textColor = newValue
    }
}

// The color of the progressView.
public var progressColor: UIColor {
    get {
        return ProgressView.progressColor
    }
    set {
        ProgressView.progressColor = newValue
    }
}

// The progress color of the progressView.
public var progressTintColor: UIColor {
    get {
        return ProgressView.progressTintColor
    }
    set {
        ProgressView.progressTintColor = newValue
    }
}

// The background color of the progressView.
public var progressBackgroundColor: UIColor {
    get {
        return ProgressView.progressBackgroundColor
    }
    set {
        ProgressView.progressBackgroundColor = newValue
    }
}

// Line color of crop view
public var cropLineColor: UIColor? {
    set {
        self.cropPickerView.cropLineColor = newValue
    }
    get {
        return self.cropPickerView.cropLineColor
    }
}

// Color of dim view not in the crop area
public var cropDimBackgroundColor: UIColor? {
    set {
        self.cropPickerView.dimBackgroundColor = .white
    }
    get {
        return self.cropPickerView.dimBackgroundColor
    }
}

// Background color of scroll
public var scrollBackgroundColor: UIColor? {
    get {
        return self.cropPickerView.scrollBackgroundColor
    }
    set {
        self.cropPickerView.scrollBackgroundColor = .white
        self.emptyView.backgroundColor = .white
    }
}

// Background color of image
public var imageBackgroundColor: UIColor? {
    get {
        return self.cropPickerView.imageBackgroundColor
    }
    set {
        self.cropPickerView.imageBackgroundColor = newValue
    }
}

// Minimum zoom for scrolling
public var scrollMinimumZoomScale: CGFloat {
    get {
        return self.cropPickerView.scrollMinimumZoomScale
    }
    set {
        self.cropPickerView.scrollMinimumZoomScale = newValue
    }
}

// Maximum zoom for scrolling
public var scrollMaximumZoomScale: CGFloat {
    get {
        return self.cropPickerView.scrollMaximumZoomScale
    }
    set {
        self.cropPickerView.scrollMaximumZoomScale = newValue
    }
}

// Permission Gallery Denied Title
public var permissionGalleryDeniedTitle: String? {
    get {
        return PermissionHelper.permissionGalleryDeniedTitle
    }
    set {
        PermissionHelper.permissionGalleryDeniedTitle = newValue
    }
}

// Permission Gallery Denied Message
public var permissionGalleryDeniedMessage: String? {
    get {
        return PermissionHelper.permissionGalleryDeniedMessage
    }
    set {
        PermissionHelper.permissionGalleryDeniedMessage = newValue
    }
}

// Permission Camera Denied Title
public var permissionCameraDeniedTitle: String? {
    get {
        return PermissionHelper.permissionCameraDeniedTitle
    }
    set {
        PermissionHelper.permissionCameraDeniedTitle = newValue
    }
}

// Permission Camera Denied Message
public var permissionCameraDeniedMessage: String? {
    get {
        return PermissionHelper.permissionCameraDeniedMessage
    }
    set {
        PermissionHelper.permissionCameraDeniedMessage = newValue
    }
}

// Permission Action Cancel Title
public var permissionActionCancelTitle: String? {
    get {
        return PermissionHelper.permissionActionCancelTitle
    }
    set {
        PermissionHelper.permissionActionCancelTitle = newValue
    }
}

// Permission Action Move Title
public var permissionActionMoveTitle: String? {
    get {
        return PermissionHelper.permissionActionMoveTitle
    }
    set {
        PermissionHelper.permissionActionMoveTitle = newValue
    }
}


// MARK: Private Property

// Picker Type
private var cropPickerType: CropPickerType

// Is Camera
private var isCamera: Bool

private let cropPickerView = CropPickerView()

private lazy var progressView: ProgressView = {
    let progressView = ProgressView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    self.view.insertSubview(progressView, aboveSubview: self.view)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    self.view.centerXConstraint(item: self.view, subView: progressView)
    self.view.centerYConstraint(item: self.view, subView: progressView)
    progressView.sizeConstraint(constant: 50)
    return progressView
}()

private lazy var emptyView: UIView = {
    let view = UIView()
    self.view.insertSubview(view, belowSubview: self.cropPickerView)
    view.translatesAutoresizingMaskIntoConstraints = false
    self.view.leadingConstraint(subView: view)
    self.view.trailingConstraint(subView: view)
    self.view.addConstraint(NSLayoutConstraint(item: self.cropPickerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
    view.heightConstraint(constant: 5)
    return view
}()

private lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    self.view.insertSubview(collectionView, aboveSubview: self.cropPickerView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    self.view.leadingConstraint(subView: collectionView)
    self.view.trailingConstraint(subView: collectionView)
    self.view.bottomConstraint(subView: collectionView)
    self.view.addConstraint(NSLayoutConstraint(item: self.emptyView, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0))
    return collectionView
}()

private lazy var _titleButton: UIButton = {
    let button = TitleButton(type: UIButton.ButtonType.system)
    
    button.frame = CGRect(x: 150, y: 40, width: 120, height: 30)
    button.setTitle((String(titleSelectedNumber) + " to " + String(maximumTitleToBeSelected) + " Selected"), for: .normal)
    
    if #available(iOS 9.0, *) {
//        button.semanticContentAttribute = .forceRightToLeft
    }
//    button.addTarget(self, action: #selector(self.albumTap(_:)), for: .touchUpInside)
    return button
}()

private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    self.view.insertSubview(tableView, aboveSubview: self.scrollButton)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    let tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
    tableViewHeightConstraint.priority = UILayoutPriority(950)
    tableView.addConstraint(tableViewHeightConstraint)
    self.tableViewHeightConstraint = tableViewHeightConstraint
    self.view.leadingConstraint(subView: tableView)
    self.view.trailingConstraint(subView: tableView)
    self.view.bottomConstraint(subView: tableView, relatedBy: .greaterThanOrEqual)
    self.view.topConstraint(item: self.cropPickerView, subView: tableView)
    return tableView
}()

private var tableViewHeightConstraint: NSLayoutConstraint?

private lazy var scrollButton: UIButton = {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
    self.view.insertSubview(button, aboveSubview: self.collectionView)
    button.translatesAutoresizingMaskIntoConstraints = false
    self.view.trailingConstraint(subView: button, constant: 20)
    var bottomSize: CGFloat = 20
    if #available(iOS 11.0, *) {
        bottomSize += (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
    }
    self.view.bottomConstraint(subView: button, constant: bottomSize)
    button.sizeConstraint(constant: 48)
    button.addTarget(self, action: #selector(self.scrollBottomTap(_:)), for: .touchUpInside)
    return button
}()

private var topConstant: CGFloat {
    return (self.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height
}

private lazy var imageRequestOptions: PHImageRequestOptions = {
    let imageRequestOptions = PHImageRequestOptions()
    imageRequestOptions.isSynchronous = true
    imageRequestOptions.resizeMode = .fast
    imageRequestOptions.isNetworkAccessAllowed = true
    imageRequestOptions.deliveryMode = .highQualityFormat
    return imageRequestOptions
}()

private var hidesBackButton: Bool?

// ImageAsset Gallery Array
private var galleryArray = [ImageAsset]()

// ImageAsset Camera Array
private var cameraArray = [ImageAsset]()

// ImageAsset Array
private var array = [ImageAsset]()

private var lastIndex: Int? {
    if self.array.isEmpty { return nil }
    let array = self.array
    if self.isCamera && array.count > 1 {
        return array.count - 2
    } else if !self.isCamera && array.count > 0 {
        return array.count - 1
    }
    return nil
}

// AssetCollection Array
private var assetCollectionArray = [AssetCollection]()
private var assetCollectionIndex = 0

private var currentIndexPath = IndexPath(item: -1, section: 0)


// MARK: Init

    public init(_ type: CropPickerType, isCamera: Bool = true, maxAllowedImages : Int, comingFromEditProfile : Bool) {
    self.cropPickerType = type
    self.isCamera = isCamera
    maximumTitleToBeSelected = maxAllowedImages
    self.comingFromEditProfile = comingFromEditProfile
    super.init(nibName: nil, bundle: nil)
}

required init?(coder aDecoder: NSCoder) {
    self.cropPickerType = .single
    self.isCamera = true
    super.init(coder: aDecoder)
}

// MARK: Life Cycle

public override func viewDidLoad() {
    super.viewDidLoad()
    
    PHPhotoLibrary.shared().register(self)
    
    colorTheStatusBar(withColor: UIColor.white)
    
    self.view.backgroundColor = .white
    
    self.view.addSubview(self.cropPickerView)
    self.cropPickerView.translatesAutoresizingMaskIntoConstraints = false
    self.view.leadingConstraint(subView: self.cropPickerView)
    self.view.trailingConstraint(subView: self.cropPickerView)
    self.view.topConstraint(subView: self.cropPickerView, constant: -self.topConstant)
    self.view.heightConstraint(subView: self.cropPickerView, multiplier: 667 / 260)
    if self.cropPickerType == .complex {
        self.cropPickerView.isCrop = true
    }
    
    if(self.comingFromEditProfile == false){
        if(isIphoneX() || isIphoneXR() || isIphoneXSMAX()){
            navbar = UINavigationBar(frame: CGRect(x: 0, y: 40,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.09))
        }else{
            navbar = UINavigationBar(frame: CGRect(x: 0, y: 20,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.09))
        }
    }else{
        navbar = UINavigationBar(frame: CGRect(x: 0, y: 20,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.09))
    }
    
    
    navbar.tintColor = .lightGray
    self.view.addSubview(navbar)

    let navItem = UINavigationItem(title:"")
    navItem.titleView = self.titleButton
    let navBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonClicked(_:)))
    navItem.leftBarButtonItem = navBarButton
    navItem.leftBarButtonItem?.tintColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 1)
    
    let rightNavBarButtonItem = UIBarButtonItem(title: "NEXT", style: .done, target: self, action: #selector(buttonClicked(_:)))
    navItem.rightBarButtonItem = rightNavBarButtonItem
    navItem.rightBarButtonItem?.tintColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 1)
    navbar.items = [navItem]

    self.emptyView.backgroundColor = .white
    
    self.collectionView.backgroundColor = .white
    self.collectionView.register(PictureCell.self, forCellWithReuseIdentifier: PictureCell.identifier)
    self.collectionView.bounces = false
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.allowsMultipleSelection = true
    self.collectionView.allowsSelection = true
    
    self.scrollButton.setImage(ArrowScrollBottomView.imageView(.white), for: .normal)
    self.scrollButton.backgroundColor = .white
    self.scrollButton.layer.cornerRadius = self.scrollButton.frame.width/2
    self.scrollButton.layer.borderWidth = 0.1
    self.scrollButton.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
    self.scrollButton.alpha = 0
    
    self.progressView.isHidden = true
    
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    self.tableView.rowHeight = 56
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    if self.leftBarButtonItem == nil {
        self.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonClicked(_:)))
        self.leftBarButtonItem?.tintColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 1)
    }
    
    if self.rightBarButtonItem == nil {
        self.rightBarButtonItem = UIBarButtonItem(title: "Next", style:.done, target: self, action: #selector(buttonClicked(_:)))
        self.rightBarButtonItem?.tintColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 1)
    }
    
    PermissionHelper.galleryPermission { (alertController) in
        guard let alertController = alertController else {
            self.assetFetchData()
            return
        }
        self.present(alertController, animated: true)
    }
    self.getZoomScrollingDictionary.removeAll()
    
    // important code saving for later use
//    spinner.color = .black
//    self.view.addSubview(spinner)
//    self.view.insertSubview(spinner, aboveSubview: self.view)
//    spinner.translatesAutoresizingMaskIntoConstraints = false
//    self.view.centerXConstraint(item: self.view, subView: spinner)
//    self.view.centerYConstraint(item: self.view, subView: spinner)
    
}
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
  
//54321
func colorTheStatusBar(withColor: UIColor){
    if(isIphoneX() || isIphoneXSMAX() || isIphoneXR()){
//        let view: UIView = UIApplication.shared.value(forKey: "statusBarWindow.statusBar") as! UIView
//        view.backgroundColor = withColor
        
        
        var statusBarUIView: UIView? {
          if #available(iOS 13.0, *) {
              let tag = 38482
              let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

              if let statusBar = keyWindow?.viewWithTag(tag) {
                  return statusBar
              } else {
                  guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
                  let statusBarView = UIView(frame: statusBarFrame)
                  statusBarView.tag = tag
                  keyWindow?.addSubview(statusBarView)
                  return statusBarView
              }
          } else {
              return nil
          }
        }
        
        statusBarUIView?.backgroundColor = withColor
    }
}

    
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        
        
        let loadingView: UIView = UIView()
        let container: UIView = UIView()
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        
        self.showActivityIndicatory(uiView: self.view, containerView: container, loadingView: loadingView, actInd: actInd)
        
        
        if(cropPickerView.image == defaultImagePlaceHolder){
            self.stopActivityIndicatory(containerView: container, loadingView: loadingView, actInd: actInd)
                self.showToast(message: "Please select atleast one photo")
            
        }else if (alreadyCropped == true){
            
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 0.5) {
              self.delegate?.cropPickerCompleteAction(self, images: self.imageToBeCroppedArray, error: nil, navigationController: self.navigationController!)
            }
            
        }else{
            
            self.cropPickerView.crop { (error, lastImageToBeCropped) in
                
                if let image = lastImageToBeCropped {
                    self.imageToBeCroppedArray.append(image)
                    
                    DispatchQueue.main
                        .asyncAfter(deadline: .now() + 0.5) {
                            
                            self.delegate?.cropPickerCompleteAction(self, images: self.imageToBeCroppedArray, error: nil, navigationController: self.navigationController!)
                    }
                    
                }
            }
            
        }
        
    }
       
    @objc func backButtonClicked(_ sender: AnyObject?){
        self.navigationController?.popViewController(animated: true)
    }
    
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 190, y: self.view.frame.size.height-100, width: 400, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
    func isIphoneX ()-> Bool{
        if(UIScreen.main.nativeBounds.height == CGFloat(2436))
            { return true } else { return false }}

    func isIphoneXSMAX()->Bool{
        if(UIScreen.main.nativeBounds.height == CGFloat(2688))
        { return true } else { return false }
    }

    func isIphoneXR()->Bool{
        if(UIScreen.main.nativeBounds.height == CGFloat(1792))
        {return true} else { return false}
    }

// MARK: Public Method

// Back Tap
@objc public func backTap(_ sender: UIBarButtonItem) {
    self.delegate?.cropPickerBackAction(self)
}

// Crop Tap
@objc public func cropTap(_ sender: UIBarButtonItem) {
    
    if(cropPickerView.image == defaultImagePlaceHolder){
        self.showToast(message: "Please select atleast one photo")
        
    }else if (alreadyCropped == true){
        self.delegate?.cropPickerCompleteAction(self, images: self.imageToBeCroppedArray, error: nil, navigationController: self.navigationController!)
    }else{
        self.cropPickerView.crop { (error, lastImageToBeCropped) in
            if let image = lastImageToBeCropped {
//                self.saveCropPickerImageForDeletion.append(image)
                self.imageToBeCroppedArray.append(image)
                self.delegate?.cropPickerCompleteAction(self, images: self.imageToBeCroppedArray, error: nil, navigationController: self.navigationController!)
                
            }
        }
    }
}

// MARK: Private Method

private func makeAsset() {
    var array = [ImageAsset]()
    array.append(contentsOf: self.galleryArray)
    array.append(contentsOf: self.cameraArray)
    if self.isCamera {
        array.append(ImageAsset())
    }
    self.array = array
}

// Album List Data Load
private func assetFetchData() {
    DispatchQueue.global().async {
        var assetCollectionArray = [AssetCollection]()
        PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: PHFetchOptions()).enumerateObjects { (collection, _, _) in
            let count = PHAsset.fetchAssets(in: collection, options: nil).count
            if count != 0 {
                if collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumUserLibrary {
                    assetCollectionArray.insert((collection, count), at: 0)
                } else {
                    assetCollectionArray.append((collection, count))
                }
            }
        }
        self.assetCollectionIndex = 0
        self.assetCollectionArray = assetCollectionArray
        self.albumFetchData()
        
        DispatchQueue.main.async {
            self.makeTitle()
            self.tableView.reloadData()
            self.hideAlbum()
        }
    }
}

// Picture List Load
private func albumFetchData() {
    var array = [ImageAsset]()
    
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    PHAsset.fetchAssets(with: options).enumerateObjects({ (asset, _, _) in
        array.append(ImageAsset(asset))
    })
    
    DispatchQueue.main.async {
        self.galleryArray = array
        self.makeAsset()
        if let lastIndex = self.lastIndex {
            self.currentIndexPath = IndexPath(item: lastIndex, section: 0)
        }
        self.collectionView.reloadData()
        
        if let lastIndex = self.lastIndex {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition.top, animated: false)
            var item = self.array[0]
            item.isCheck = true
            
            if let image = item.image {
                DispatchQueue.main.async {
                    self.cropPickerView.image = image
                    item.isCheck = true
                    self.scrollButton.alpha = 0
                }
            } else if let asset = item.asset {
                let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                PHCachingImageManager().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: self.imageRequestOptions, resultHandler: { (image, _) in
                    DispatchQueue.main.async {
                        self.cropPickerView.image = self.defaultImagePlaceHolder
                        self.scrollButton.alpha = 0
                    }
                })
            }
        } else {
            self.cropPickerView.image = nil
        }
    }
}

// Title Button
private func makeTitle() {
    let title = String(titleSelectedNumber) + " of " + String(maximumTitleToBeSelected) + " Selected"
//
//    self.titleButton.setTitle(String(titleSelectedNumber) + " of " + String(maximumTitleToBeSelected) + " Selected" , for: .normal)
//    self.titleButton.tintColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 1)
//    if(isIphoneXSMAX() || isIphoneXR() || isIphoneX()){
//       self.titleButton.frame = CGRect(x: 150, y: 40, width: 120, height: 30)
////       self.titleButton.center.x = self.view.center.x
//    }else{
//       self.titleButton.frame = CGRect(x: 130, y: 35, width: 120, height: 30)
////       self.titleButton.center.x = self.view.center.x
//    }
//
    
    self.titleButton.setTitle(title, for: .normal)
    self.titleButton.tintColor = UIColor(red: 250/255, green: 72/255, blue: 73/255, alpha: 1)
    
    if(isIphoneX() || isIphoneXR() || isIphoneXSMAX()){
        self.titleButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
    }else{
        self.titleButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
    }
    
    self.titleButton.sizeToFit()
    
//    self.view.addSubview(titleButton)
}

// Scroll To Bottom
@objc private func scrollBottomTap(_ sender: UIButton) {
    if let lastIndex = self.lastIndex {
        self.collectionView.scrollToItem(at: IndexPath(item: lastIndex, section: 0), at: UICollectionView.ScrollPosition.top, animated: true)
    }
}

// Title Button Tap
@objc private func albumTap(_ sender: UIButton) {
    guard let tableViewHeightConstraint = self.tableViewHeightConstraint else { return }
    if tableViewHeightConstraint.constant == 0 {
        self.showAlbum()
    } else {
        self.hideAlbum()
    }
}

// Show Album List UITableView
private func showAlbum() {
    self.tableViewHeightConstraint?.constant = self.view.bounds.height
    
    self.leftBarButtonItem = self.navigationItem.leftBarButtonItem
    self.rightBarButtonItem = self.navigationItem.rightBarButtonItem
    self.hidesBackButton = self.navigationItem.hidesBackButton
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    
    UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
        (self.navigationItem.titleView as? UIButton)?.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(180).degreesToRadians)
    }
    
    if !self.assetCollectionArray.isEmpty {
        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
}

// Hide Album List UITableView
private func hideAlbum() {
    self.tableViewHeightConstraint?.constant = 0
    
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
    if let hidesBackButton = self.hidesBackButton {
        self.navigationItem.hidesBackButton = hidesBackButton
    }
    
    UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
        (self.navigationItem.titleView as? UIButton)?.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(0).degreesToRadians)
    }
}

}

// MARK: PHPhotoLibraryChangeObserver
extension CropPickerController: PHPhotoLibraryChangeObserver {
public func photoLibraryDidChange(_ changeInstance: PHChange) {
    guard !self.assetCollectionArray.isEmpty else { return }
    DispatchQueue.global().async {
        var array = [ImageAsset]()
        PHAsset.fetchAssets(in: self.assetCollectionArray[self.assetCollectionIndex].0, options: PHFetchOptions()).enumerateObjects({ (asset, _, _) in
            array.append(ImageAsset(asset))
        })
        if array.count != self.galleryArray.count {
            DispatchQueue.main.async {
                self.galleryArray = array
                self.makeAsset()
                self.collectionView.reloadData()
            }
        }
    }
}
}

// MARK: UICollectionViewDelegate
extension CropPickerController: UICollectionViewDelegate {
public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Scroll To Bottom Button Alpha
    if scrollView == self.collectionView {
        let deltaOffsetY = (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y
        if deltaOffsetY > UIScreen.main.bounds.height {
            UIView.animate(withDuration: 0.2) {
                self.scrollButton.alpha = 0
            }
        } else if deltaOffsetY < 100 {
            UIView.animate(withDuration: 0.2) {
                self.scrollButton.alpha = 0
            }
        }
    }
}



func checkAdd(indexPathValue : Int) {
    
    self.array[indexPathValue].number = self.array.filter({ $0.isCheck }).count + 1
    self.array[indexPathValue].isCheck = true
    
    if self.array[indexPathValue].type == .image {
        if let index = self.galleryArray.enumerated().filter({ $0.element == self.array[indexPathValue] }).first.map({ $0.offset }) {
            self.galleryArray[index].isCheck = true
            self.galleryArray[index].number = self.array[indexPathValue].number
            titleSelectedNumber = self.array[indexPathValue].number
            makeTitle()
        }
    } else {
        if let index = self.cameraArray.enumerated().filter({ $0.element == self.array[indexPathValue] }).first.map({ $0.offset }) {
            self.cameraArray[index].isCheck = true
            self.cameraArray[index].number = self.array[indexPathValue].number
        }
    }
}


func unCheckCell(indexPathValue : Int) {
    
    let number = self.array[indexPathValue].number
    
    self.array[indexPathValue].checkCancel()
    
    if self.array[indexPathValue].type == .image {
        if let index = self.galleryArray.enumerated().filter({ $0.element == self.array[indexPathValue] }).first.map({ $0.offset }) {
            self.galleryArray[index].checkCancel()
        }
    } else {
        if let index = self.cameraArray.enumerated().filter({ $0.element == self.array[indexPathValue] }).first.map({ $0.offset }) {
            self.cameraArray[index].checkCancel()
        }
    }
    
    for (index, element) in self.array.enumerated() {
        if element.isCheck && element.number > number {
            self.array[index].number -= 1
        }
    }
    
    for (index, element) in self.galleryArray.enumerated() {
        if element.isCheck && element.number > number {
            self.galleryArray[index].number -= 1
        }
    }
    
    
    for (index, element) in self.cameraArray.enumerated() {
        if element.isCheck && element.number > number {
            self.cameraArray[index].number -= 1
        }
    }
}

public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   

    self.cropPickerView.crop { (error, croppedImage) in
        
        
        let loadingView: UIView = UIView()
        let container: UIView = UIView()
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        self.showActivityIndicatory(uiView: self.view, containerView: container, loadingView: loadingView, actInd: actInd)
        
          if let image = croppedImage {
            
            let item = self.array[indexPath.row]
            let fullImageData : NSData = self.cropPickerView.image!.pngData()! as NSData
            var photoIsUnCheckToReloadPreviousPicToCropperImageView = false
             
//            print(self.getZoomScrollingDictionary.count)
//            print(self.imagesInDataPng.count)
            
            if(self.cropPickerView.image != self.defaultImagePlaceHolder){
                for (i, _) in self.imagesInDataPng.enumerated() {

                    if(self.imagesInDataPng[i].isEqual(fullImageData)){
                            self.matchingImageFound = 2
                            self.getZoomScrollingDictionary[i]["ZoomingScale"] = self.cropPickerView.zoomScaleForScrollView
                            self.getZoomScrollingDictionary[i]["contentOffSet"] = self.cropPickerView.setOffSetForScrollZooming
                            break
                      }
                    
                }
            }
            
            if self.currentIndexPath == indexPath {
                
                if self.array[indexPath.row].isCheck {
                    self.titleSelectedNumber = self.titleSelectedNumber - 1
                    self.makeTitle()
                    photoIsUnCheckToReloadPreviousPicToCropperImageView = true
                    var indexForDeletion : Int? = -1
                    for i in self.imagesInDataPng.indices{

                        if(self.imagesInDataPng[i].isEqual(fullImageData)){
                            indexForDeletion = i
                            break
                        }
                    }
//                    print(indexForDeletion)
                    if(indexForDeletion != -1){
                        self.imageToBeCroppedArray.remove(at:indexForDeletion!)
                        self.imagesInDataPng.remove(at: indexForDeletion!)
                        self.getZoomScrollingDictionary.remove(at: indexForDeletion!)
                    }
                    print(self.imagesInDataPng.count)
                    print(self.getZoomScrollingDictionary.count)
                    self.unCheckCell(indexPathValue: indexPath.row)

                } else {
                    if(self.maximumTitleToBeSelected == self.titleSelectedNumber){
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.stopActivityIndicatory(containerView: container, loadingView: loadingView, actInd: actInd)
//                        }
                        
                        self.showToast(message: "You cannot select more than " + String(self.maximumTitleToBeSelected) + " images")
                        
                        return
                    }else{
                        if(self.cropPickerView.image != self.defaultImagePlaceHolder){

                        if(self.alreadyCropped == false){
                            self.imageToBeCroppedArray.append(image)
                            self.imagesInDataPng.append(fullImageData)
                            self.getZoomScrollingDictionary.append([
                                "ZoomingScale":    self.cropPickerView.zoomScaleForScrollView,
                                "contentOffSet" :  self.cropPickerView.setOffSetForScrollZooming
                            ])

                        }else{
                            self.alreadyCropped = false
                        }
                    }

                    self.checkAdd(indexPathValue: indexPath.row)
                  }

                }
            } else if !self.array[indexPath.row].isCheck {
                if(self.maximumTitleToBeSelected == self.titleSelectedNumber){
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.stopActivityIndicatory(containerView: container, loadingView: loadingView, actInd: actInd)
//                    }
                    
                    self.showToast(message: "You cannot select more than " + String(self.maximumTitleToBeSelected) + " images")
                    return
                }else{
                    print(self.alreadyCropped)
                    if(self.cropPickerView.image != self.defaultImagePlaceHolder){
                        if(self.alreadyCropped == true){
                            self.alreadyCropped = false
                        }else{
                            self.imageToBeCroppedArray.append(image)
                            self.imagesInDataPng.append(fullImageData)
                            self.getZoomScrollingDictionary.append([
                                "ZoomingScale":    self.cropPickerView.zoomScaleForScrollView,
                                "contentOffSet" :  self.cropPickerView.setOffSetForScrollZooming
                            ])
                        }
                    }

                    self.checkAdd(indexPathValue: indexPath.row)
                }

            }else{

                for i in self.imagesInDataPng.indices {

                    if(self.imagesInDataPng[i].isEqual(fullImageData)){
                            self.alreadyCropped = true
                            break
                        }
                }
                if(self.alreadyCropped == false){
                    self.alreadyCropped = true
                    self.imageToBeCroppedArray.append(self.cropPickerView.image!)
                    self.imagesInDataPng.append(fullImageData)
                    self.getZoomScrollingDictionary.append([
                        "ZoomingScale":    self.cropPickerView.zoomScaleForScrollView,
                        "contentOffSet" :  self.cropPickerView.setOffSetForScrollZooming
                    ])
                }
        }

        self.currentIndexPath = indexPath
        self.collectionView.reloadData()
            
        if item.type == .cameraImage { // CameraImage
            self.cropPickerView.image = item.image
        } else if item.type == .image { // AlbumImage
            guard let asset = self.array[indexPath.row].asset else { return }
            let imageManager = PHCachingImageManager()
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.isSynchronous = true
            imageRequestOptions.deliveryMode = .highQualityFormat
            imageRequestOptions.isNetworkAccessAllowed = true
            
                imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: imageRequestOptions, resultHandler: { (image, _) in
                    DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.cropPickerView.image = nil
                        
                    if(photoIsUnCheckToReloadPreviousPicToCropperImageView == true){
                        
                        if(self.imageToBeCroppedArray.count == 0){
                            self.cropPickerView.image = self.defaultImagePlaceHolder
                        }else{
                            self.cropPickerView.image = self.imageToBeCroppedArray.last
                            self.alreadyCropped = true
                        }
                        
                    }else{
                           self.cropPickerView.image = image
                    }
                        
                    let cropImageDataForUpdateZoom : NSData = self.cropPickerView.image!.pngData()! as NSData
                    self.cropPickerView.zoomScaleForScrollView = 1
                    self.cropPickerView.setOffSetForScrollZooming = CGPoint(x: 0,y: 0)
                        for (i, _) in self.imagesInDataPng.enumerated() {

                            if(self.imagesInDataPng[i].isEqual(cropImageDataForUpdateZoom)){
                                    self.cropPickerView.zoomScaleForScrollView = self.getZoomScrollingDictionary[i]["ZoomingScale"] as! CGFloat
                                    self.cropPickerView.setOffSetForScrollZooming = self.getZoomScrollingDictionary[i]["contentOffSet"] as! CGPoint
                                break
                            }
                        }
                  }
            })
        }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                container.removeFromSuperview()
//                loadingView.removeFromSuperview()
//                actInd.stopAnimating()
                  self.stopActivityIndicatory(containerView: container, loadingView: loadingView, actInd: actInd)
            }
     }
        

  }

}

    
func showActivityIndicatory(uiView: UIView, containerView: UIView, loadingView: UIView, actInd: UIActivityIndicatorView) {

//    let container: UIView = UIView()
    containerView.frame = uiView.frame
    containerView.center = uiView.center


//    let loadingView: UIView = UIView()
    loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    loadingView.center = uiView.center
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10
    loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.9)
    
    actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
    actInd.style =
        UIActivityIndicatorView.Style.whiteLarge
    actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                            y: loadingView.frame.size.height / 2);
    loadingView.addSubview(actInd)
    containerView.addSubview(loadingView)
    uiView.addSubview(containerView)
    actInd.startAnimating()
}
    
    
    func stopActivityIndicatory(containerView: UIView, loadingView: UIView, actInd: UIActivityIndicatorView){
    containerView.removeFromSuperview()
    loadingView.removeFromSuperview()
    actInd.stopAnimating()
}
    
func imageEqualityCheck(value: UIImage, isEqualTo image2: UIImage) -> Bool {
    let data1: NSData = value.pngData()! as NSData
    let data2: NSData = image2.pngData()! as NSData
    return data1.isEqual(data2)
}

}

// MARK: UICollectionViewDataSource
extension CropPickerController: UICollectionViewDataSource {
public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.array.count
}
public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCell.identifier, for: indexPath) as? PictureCell else { fatalError() }
//        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    
    let row = indexPath.row
    var item = self.array[row]
    
    cell.setEntity(self.cropPickerType, item: item, isSelected: indexPath == self.currentIndexPath)
    
    if item.type == .image, let asset = item.asset {
        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        
            PHCachingImageManager().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: self.imageRequestOptions, resultHandler: { (image, _) in
                
                self.array[row].image = image
                
                    cell.setEntity(self.array[row])
                
            })
        
    }
        
    return cell
}
}

// MARK: UITableViewDelegate
extension CropPickerController: UITableViewDelegate {
public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.assetCollectionIndex = indexPath.row
    self.makeTitle()
    self.hideAlbum()
    
    for (index, _) in self.cameraArray.enumerated() {
        self.cameraArray[index].checkCancel()
    }
    
    DispatchQueue.global().async {
        self.albumFetchData()
    }
}
}

// MARK: UITableViewDataSource
extension CropPickerController: UITableViewDataSource {
public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.assetCollectionArray.count
}
public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    let item = self.assetCollectionArray[indexPath.row]
    cell.textLabel?.text = item.0.localizedTitle?.appending(" (\(item.count))")
    cell.accessoryType = .disclosureIndicator
    return cell
}
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CropPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)?.fixOrientation else { return }
    picker.dismiss(animated: true, completion: nil)
    self.cameraArray.append(ImageAsset(image))
    self.makeAsset()
//        self.cropPickerView.image = image
    self.collectionView.reloadData()
}
}
