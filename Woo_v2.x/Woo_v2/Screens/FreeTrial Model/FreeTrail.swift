//
//  FreeTrail.swift
//  Woo_v2
//
//  Created by Harish kuramsetty on 29/07/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit
import Alamofire

class FreeTrail: NSObject {
    static let sharedInstance = FreeTrail()
    typealias onSuccess = (_ isSucuess: Bool, _ stautCode: NSInteger, _ response: Any)->Void
    
    func hitFreeTrailDeleteFlow(url: String, afterCall: @escaping onSuccess){
        let utilities = Utilities.sharedUtility() as! Utilities
        let timeStampObj = NSNumber(value: Date().timeIntervalSince1970)
        let stringTimestamp = String(format: "%lld%@", timeStampObj.int64Value, "000000")
        var headers = ["":""]
        if ((utilities.validString(utilities.createHashedToken(forTimestamp: stringTimestamp)!)).count > 0){
            headers = [
                "WOO_ACCESS_TOKEN": utilities.createHashedToken(forTimestamp: stringTimestamp)!,
                "TIME_OF_CALL": stringTimestamp
            ]
        }
       
        Alamofire.request(url, method: .post, parameters: nil,encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                afterCall(true, response.response!.statusCode, response.result.value as Any)
                break
            case .failure(let error):
                if let statusCode  = response.response?.statusCode{
                afterCall(false, statusCode, error)
                }else{
                    afterCall(false, 404, error)

                }
            }
        }
    }
    
    
    

}
