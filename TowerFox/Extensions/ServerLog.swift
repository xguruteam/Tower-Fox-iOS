//
//  ServerLog.swift
//  Tower Fox
//
//  Created by Guru on 8/21/19.
//  Copyright © 2019 foxridge. All rights reserved.
//

import Foundation
import UIKit

extension ApiRequest {
    class func logOnServer(message: String) {
        guard let userId = storage_loadObject("UserName") else { return }
        let param: [String: AnyObject] = [
            "UserName": userId as AnyObject,
            "DeviceId": UIDevice.current.identifierForVendor!.uuidString as AnyObject,
            "ActionName": "Mobile App Photo Sync - iOS" as AnyObject,
            "MobileAppVersion": String(format: "Tower Fox for iOS %@",  (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)) as AnyObject,
            "ErrorMessage": message as AnyObject,
        ]
        
        BMWebRequest.post(url: getLogURL(), params: param, isHeader: false) { (result) in
            switch(result) {
            case .Success:
                break
            case .Failure(let error):
                print(error)
            }
        }
    }
}
