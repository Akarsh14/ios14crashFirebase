//
//  MyUiManager.swift
//  AccountKitSwiftSample
//
//  Created by Ankit Batra on 14/11/17.
//  Copyright © 2017 Facebook, Inc. All rights reserved.
//

import UIKit
//import AccountKit

class MyUiManager: NSObject {

  //var theme : Theme?
  var openedFromDiscover = false
  var usedInOnBoarding = false
  
    init(_ themeWithColor:UIColor, isOpenedFromDiscover:Bool, isUsedInOnBoarding:Bool) {
    super.init()
    self.openedFromDiscover = isOpenedFromDiscover
    self.usedInOnBoarding = isUsedInOnBoarding
    createTheme(themeWithColor)
  }
    
    private func createTheme(_ withColor:UIColor){
        
        print("theme created")
//        let utilities = Utilities.sharedUtility() as! Utilities
//
//        self.theme = Theme(primaryColor:.red, primaryTextColor: .white , secondaryColor: .white, secondaryTextColor: utilities.getUIColorObject(fromHexString: "#72778A", alpha: 1.0) , statusBarStyle: .lightContent)
//        self.theme?.statusBarStyle = .lightContent
//        self.theme?.buttonTextColor = .white
//        self.theme?.buttonBackgroundColor = utilities.getUIColorObject(fromHexString: "#FA4849", alpha: 1.0)
//        self.theme?.buttonDisabledTextColor = .white
//        self.theme?.buttonDisabledBackgroundColor = utilities.getUIColorObject(fromHexString: "#FA4849", alpha: 0.8)
//        self.theme?.inputBorderColor = utilities.getUIColorObject(fromHexString: "#DEDEDE", alpha: 1.0)
//        if openedFromDiscover{
//            self.theme?.headerBackgroundColor = utilities.getUIColorObject(fromHexString: "#9275DB", alpha: 1.0)
//        }
//        else{
//            if self.usedInOnBoarding{
//                self.theme?.headerBackgroundColor = .white
//                self.theme?.headerButtonTextColor = .black
//                self.theme?.headerTextColor = .black
//            }
//            else{
//                self.theme?.headerBackgroundColor = utilities.getUIColorObject(fromHexString: "#75C4DB", alpha: 1.0)
//            }
//        }
//        self.theme?.headerTextType = .appName
    }
}
