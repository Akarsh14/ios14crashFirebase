//
//  SwiftUtilities.swift
//  Woo_v2
//
//  Created by Suparno Bose on 22/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import Foundation
import FBSDKLoginKit

typealias getFaceBookToken = (Bool, String)->Void
//Protocal that copyable class should conform
protocol Copying {
    init(original: Self)
}

//Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}

extension Array where Element: NSObject {
    func objcClone() -> NSMutableArray {
        let copiedArray = NSMutableArray()
        for element in self {
            copiedArray.add(element)
        }
        return copiedArray
    }
}

extension String {
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
}

func hideWithAnimation(view:UIView,isHide:Bool, animatingTime:TimeInterval) {
    UIView.animate(withDuration: animatingTime, animations: { 
        if isHide {
            view.alpha = 0.0
        }
        else{
            view.alpha = 1.0
        }
    }) 
}

//Description: Use this method to get facebook token while the user did Alternate login
@objc class SwiftUtilities: NSObject {
    
@objc func getAccessTokenFromFacebook(_ viewController:UIViewController,isAuthNeeded:Bool, accessToken: @escaping getFaceBookToken){
    if UserDefaults.standard.object(forKey: kStoredAccessToken) != nil && !isAuthNeeded{
        accessToken(true, UserDefaults.standard.object(forKey: kStoredAccessToken)  as! String)
    }else{
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["user_photos"], from: viewController) { (loginResult, error) in
            if error != nil{
                accessToken(false, "")
            }else{
                if let token = loginResult?.token{
                    UserDefaults.standard.setValue(token.tokenString, forKey: kStoredAccessToken)
                    accessToken(true, token.tokenString)
                }else{
                    accessToken(false, "")
                }
            }
        }
    }
}
}

func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> NSString {
    let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : []
    if JSONSerialization.isValidJSONObject(value) {
        
        var jsonData : NSData?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: value, options: options) as NSData?
        }
        catch {
            print(error)
        }
        
        if let data = jsonData {
            if var string = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
                
                let newString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as NSString
                
                string = newString.replacingOccurrences(of: "\\", with: "") as NSString
                print(string)
                //                let emojiString:String = string as String
                //                let msgData: NSData = emojiString.dataUsingEncoding(NSNonLossyASCIIStringEncoding)!
                //                let encodedMsg: String = String(data: msgData, encoding: NSUTF8StringEncoding)!
                return newString
            }
        }
    }
    return ""
}


//MARK: Getting Emoji Text after encoding
func gettingStringContainingEmojiFromEncodedString(_ emojiText : String) -> String{
    
    if emojiText.count == 0 {
        return ""
    }
    
    let msgData: Data = emojiText.data(using: String.Encoding.utf8)!
    let encodedMsg: String = String(data: msgData, encoding: String.Encoding.nonLossyASCII)!
    
    return encodedMsg
    

    
}





