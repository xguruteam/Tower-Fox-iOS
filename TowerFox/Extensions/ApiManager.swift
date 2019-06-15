//
//  ApiManager.swift
//  BudMeow
//
//  Created by jkc on 7/26/18.
//  Copyright © 2018 budmeow. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
let BASE_URL = "https://api.budmeow.com/"


class BMCompletionHandler: NSObject {
    typealias BMCompletionHandlerType = (Result) -> Void
    enum Result {
        case Success(AnyObject?)
        case Failure(Error)
    }
}
class BMWebRequest: NSObject {
    
    class func getToken() -> String{
//        print(AppData.sharedInstance.getUser().token!)
//        return AppData.sharedInstance.getUser().token!
        return ""
    }
    
   
    class func post(url : String, params : [String: AnyObject]?, isHeader: Bool, completionHandler: @escaping BMCompletionHandler.BMCompletionHandlerType) {
        if !(NetworkReachabilityManager()?.isReachable)! {
            showNetworkLostNotification()
        }else{
            
            var headers = [
                "Content-Type": "application/json"
            ]
            if isHeader {
                headers["Authorization"] = "Bearer \(getToken())"
            }
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    print("get: \(String(describing: response.result.error))")
                    let error : NSError = (response.result.error as NSError?)!
                    completionHandler(BMCompletionHandler.Result.Failure(error))
                    return
                }
                
                guard (response.result.value as? [String: AnyObject]) != nil || (response.result.value as? [[String: AnyObject]]) != nil else {
                    print("get: invalid information received from service")
                    if response.result.isSuccess {
                        let error = NSError(domain: "api.budmeow.com", code: 204, userInfo: nil)
                        completionHandler(BMCompletionHandler.Result.Failure(error))
                        return
                    }else{
                        let error : NSError = (response.result.error as NSError?)!
                        completionHandler(BMCompletionHandler.Result.Failure(error))
                        return
                    }
                }
                
                let responseJson = JSON(response.result.value!)
                completionHandler(BMCompletionHandler.Result.Success(responseJson as AnyObject?))
                
            }
            
        }
    }
    
    class func postArray(url : String, params : [[String: Any]], isHeader: Bool, completionHandler: @escaping BMCompletionHandler.BMCompletionHandlerType) {
        if !(NetworkReachabilityManager()?.isReachable)! {
            showNetworkLostNotification()
        }else{
            
            let headers = [
                "Content-Type": "application/json"
            ]
            do {
                var request = try URLRequest(url: url, method: .post, headers: headers)
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                Alamofire.request(request).responseJSON { (response) in
                    guard response.result.isSuccess else {
                        print("get: \(String(describing: response.result.error))")
                        let error : NSError = (response.result.error as NSError?)!
                        completionHandler(BMCompletionHandler.Result.Failure(error))
                        return
                    }
                    
                    guard (response.result.value as? [String: AnyObject]) != nil || (response.result.value as? [[String: AnyObject]]) != nil else {
                        print("get: invalid information received from service")
                        if response.result.isSuccess {
                            let error = NSError(domain: "api.budmeow.com", code: 204, userInfo: nil)
                            completionHandler(BMCompletionHandler.Result.Failure(error))
                            return
                        }else{
                            let error : NSError = (response.result.error as NSError?)!
                            completionHandler(BMCompletionHandler.Result.Failure(error))
                            return
                        }
                    }
                    
                    let responseJson = JSON(response.result.value!)
                    completionHandler(BMCompletionHandler.Result.Success(responseJson as AnyObject?))
                }
            }catch let error {
                print(error)
                completionHandler(BMCompletionHandler.Result.Failure(error))
            }
        }
    }

    class func postPhotosArray(url : String, params : [[String: Any]], isHeader: Bool, completionHandler: @escaping BMCompletionHandler.BMCompletionHandlerType) {
        if !(NetworkReachabilityManager()?.isReachable)! {
            showNetworkLostNotification()
        }else{
            
            let headers = [
                "Content-Type": "application/json"
            ]
            do {
                var request = try URLRequest(url: url, method: .post, headers: headers)
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                Alamofire.request(request).responseString { (response) in
                    print(response.data as Any)
                    completionHandler(BMCompletionHandler.Result.Success(true as AnyObject))
                }
            }catch let error {
                print(error)
                completionHandler(BMCompletionHandler.Result.Failure(error))
            }
        }
    }

    class func postMultipart(url: String, params: [String: AnyObject]?, avatar: Data?, isHeader: Bool, completionHandler: @escaping BMCompletionHandler.BMCompletionHandlerType) {
        var headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data"
        ]
        if isHeader {
            headers["Authorization"] = "Bearer \(getToken())"
        }
        Alamofire.upload(multipartFormData: { (multipartData) in
            if let data = avatar {
                multipartData.append(data, withName: "avatar", fileName: "avatar.png", mimeType: "image/jpeg")
            }
            for (key, value) in params! {
                multipartData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in 
                    if !response.result.isSuccess {
                        print("# ERROR")
                        let responseJson = response.result.error!
                        completionHandler(BMCompletionHandler.Result.Failure(responseJson))
                    } else {
                        print("# SUCCESS")
                        print(response)
                        let responseJson = JSON(response.result.value!)
                        completionHandler(BMCompletionHandler.Result.Success(responseJson as AnyObject?))
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                completionHandler(BMCompletionHandler.Result.Failure(encodingError))
            }

        }
    }
    
    class func get(url: String, isHeader: Bool, completionHandler: @escaping BMCompletionHandler.BMCompletionHandlerType) {
        var headers: HTTPHeaders = [:]
        if isHeader {
            headers["Authorization"] = "Bearer \(getToken())"
        }
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("get: \(String(describing: response.result.error))")
                let error : NSError = (response.result.error as NSError?)!
                completionHandler(BMCompletionHandler.Result.Failure(error))
                return
            }
            
            guard (response.result.value as? [String: AnyObject]) != nil || (response.result.value as? [[String: AnyObject]]) != nil else {
                print("get: invalid information received from service")
                if response.result.isSuccess {
                    let error = NSError(domain: "api.budmeow.com", code: 204, userInfo: nil)
                    completionHandler(BMCompletionHandler.Result.Failure(error))
                    return
                }else{
                    let error : NSError = (response.result.error as NSError?)!
                    completionHandler(BMCompletionHandler.Result.Failure(error))
                    return
                }
            }
            
            let responseJson = JSON(response.result.value!)
            completionHandler(BMCompletionHandler.Result.Success(responseJson as AnyObject?))
        }
    }
    
    class func showNetworkLostNotification() {
    }
    
    class func setHeader(urlRequest: NSMutableURLRequest, value: String, key: String) -> Void {
        urlRequest.addValue(value, forHTTPHeaderField: key)
    }
    
    class func setBody(urlRequest: NSMutableURLRequest, data: Data?) -> Void {
        urlRequest.httpBody = data
    }
    
    class func setBodyWithString(urlRequest: NSMutableURLRequest, string: String) -> Void {
        let data = string.data(using: String.Encoding.utf8)
        self.setBody(urlRequest: urlRequest, data: data)
    }
    
}


