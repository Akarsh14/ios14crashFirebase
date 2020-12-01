//
//  WkWebViewController.swift
//  Woo_v2
//
//  Created by Akarsh Aggarwal u2opia on 21/05/20.
//  Copyright © 2020 Woo. All rights reserved.

import Foundation
import UIKit
import WebKit

class WkWebViewController : UIViewController, WKNavigationDelegate {
    
    
    @IBOutlet weak var webViewObj: WKWebView!
    @IBOutlet weak var webviewTopConstraint: NSLayoutConstraint!
    
    var navTitle: String?
    var webViewUrl: URL?
    var isFrmBrandCardSwipe = false
    var isNotComingThroughLogin = false
    var lblNavTitle: UILabel?
    private var isInjected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        setDataOnNavBar()
        WooScreenManager.sharedInstance.hideHomeViewTabBar(true, isAnimated: true)
        webViewObj.layoutIfNeeded()
        webViewObj.navigationDelegate = self
        print(webViewObj ?? "no url")
        webViewObj.load(URLRequest(url: webViewUrl!))
        
    }
    
    
    override func viewWillLayoutSubviews() {
        let safeAreaTop = (Utilities.sharedUtility() as AnyObject).getSafeArea(forTop: true, andBottom: false)
        webviewTopConstraint.constant = 64 + safeAreaTop
    }
    
    
    func viewWillDisppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDismissTheScreenNotification object:nil];

    }
    
    
    
    func setDataOnNavBar() {
        navigationController?.isNavigationBarHidden = true
        let y = 0
        if isFrmBrandCardSwipe {
            // y = (IS_IPHONE_X || IS_IPHONE_XS_MAX) ? 22 : 0;
        }
        var safeAreaTop = (Utilities.sharedUtility() as AnyObject).getSafeArea(forTop: true, andBottom: false)
        if isNotComingThroughLogin == true {
            safeAreaTop = 0
        }
        
        let viewTop = UIView(frame: CGRect(x: 0, y: CGFloat(y), width: SCREEN_WIDTH + 2, height: 64 + safeAreaTop))
        let headerColor = UIColor(red: 100.0 / 255.0, green: 183.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
        viewTop.backgroundColor = headerColor
        view.addSubview(viewTop)
//        (Utilities.sharedUtility() as AnyObject).colorStatusBar(headerColor)
        colorTheStatusBar(withColor: headerColor);
        let btnBack = UIButton(type:UIButton.ButtonType.custom)
        btnBack.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        btnBack.setImage(UIImage(named: "ic_arrow_back"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 15 + safeAreaTop, width: 50, height: 50)
        viewTop.addSubview(btnBack)
        
        lblNavTitle = UILabel(frame: CGRect(x: 70, y: 25 + safeAreaTop, width: SCREEN_WIDTH - 120, height: 30))
        lblNavTitle?.text = navTitle
        lblNavTitle?.textColor = UIColor.white
        lblNavTitle?.font = UIFont(name: "Lato-Medium", size: 17.0)
        lblNavTitle?.textAlignment = .center
        viewTop.addSubview(lblNavTitle!)
    }
    
    
    
     @objc func backBtnTapped() {

        if navigationController != nil {

            //        [[WooScreenManager sharedInstance]hideHomeViewTabBar:NO isAnimated:YES];
            navigationController?.popViewController(animated: true)
            // [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            dismiss(animated: true)
        }
    }

    func dismissTheScreen() {
        dismiss(animated: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        
        if isInjected == true {
            return
        }
        self.isInjected = true
        
//        let js = "document.body.outerHTML"
//        webView.evaluateJavaScript(js) { (html, error) in
//            let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
//            webView.loadHTMLString(headerString + (html as! String), baseURL: nil)
//        }
        
        if((navTitle == "Guidelines/EULA") || (navTitle == "Guidelines")){
            let js = "document.body.outerHTML"
            webView.evaluateJavaScript(js) { (html, error) in
                let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
                webView.loadHTMLString(headerString + (html as! String), baseURL: nil)
            }
        }
        
       
            if navTitle!.count > 0 {
            } else {
                
                webView.evaluateJavaScript("document.title") { (result, error) in
                    if error != nil {
                        print(result as Any)
                        
                        let theTitle = result
                        self.lblNavTitle?.text = theTitle as? String
                    }
                }
            }
    }
    
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

