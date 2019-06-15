//
//  ApiRequest.swift
//  BudMeow
//
//  Created by jkc on 7/26/18.
//  Copyright © 2018 budmeow. All rights reserved.
//

import UIKit
import SwiftyJSON
let TITLE = "Tower Fox"
//let LOGIN = "\(BASE_URL)login"
//let FACEBOOK = "\(BASE_URL)facebook"
//let REGISTER = "\(BASE_URL)register"
//let UPDATE = "\(BASE_URL)update"
//let REQUEST_CODE = "\(BASE_URL)send_code"
//let VERIFY_CODE = "\(BASE_URL)code"
//let VERIFY_MEDICAL_CARD = "\(BASE_URL)verify_medical_card"
//let USER_DETAIL = "\(BASE_URL)details"
//let LOGOUT = "\(BASE_URL)logout"
//let NEARBY_RETAILER = "\(BASE_URL)nearby_retailer"
//let FAVORITES_RETAILER = "\(BASE_URL)favorites_retailers"
//let ALL_ORDERS = "\(BASE_URL)all_orders"
//let LIMITS = "\(BASE_URL)limits"
//let ADD_FAVORITE = "\(BASE_URL)add_favorite_retailer"
//let REMOVE_FAVORITE = "\(BASE_URL)delete_favorite_retailer"
//let ITEM = "\(BASE_URL)item"
//let PREMIUM_BUD = "\(BASE_URL)premium_buds"
//let DEALS_OF_DAY = "\(BASE_URL)deals_of_day"
//let SEARCH_RETAILERS = "\(BASE_URL)search_retailers"
//let SEARCH_PRODUCTS = "\(BASE_URL)search"
//let GET_RETAILER = "\(BASE_URL)retailer"
//let DELIVERY = "\(BASE_URL)delivery"
//let POST_ORDER = "\(BASE_URL)order"
//let ORDER_DETAILS = "\(BASE_URL)order_details"
//let AGE_VERIFY = "\(BASE_URL)age_verify"
//let DOC = "\(BASE_URL)doc"

typealias StatusCallback = (_ errorMessage: String, _ response:Any?) -> Void

class ApiRequest: NSObject {
    class func login(_ username: String, password: String, statusCallback: @escaping StatusCallback) {
        let param = ["UserName": username, "Password": password]
        BMWebRequest.post(url: getValidateUserURL(), params: param as [String : AnyObject], isHeader: false) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["Status"].boolValue {
                        let response = AuthenticateModel(with: unwrappedJson.dictionaryValue)
                        statusCallback(errorMessage, response)
                    }else{
                        let response = AuthenticateModel(with: unwrappedJson.dictionaryValue)
                        errorMessage = response.Message!
                        statusCallback(errorMessage, nil)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
        }
    }
    
    class func serverConnectivityTest(_ serverip: String, statusCallback: @escaping StatusCallback) {
        BMWebRequest.get(url: getServiceConnectivityURL(serverip), isHeader: false) { (result) in
            let errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["Status"].string != nil {
                        let response = ResponseModel(with: unwrappedJson.dictionaryValue)
                        response.save()
                        statusCallback(errorMessage, response)
                    }else{
                        statusCallback(errorMessage, nil)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
        }
    }
    
    /*
    class func postPushId(_ token: String, statusCallback: @escaping StatusCallback) {
        let param = ["push_id": token, "device": "1"]
        BMWebRequest.post(url: FACEBOOK, params: param as [String : AnyObject], isHeader: false) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        let user = User(withJSON: unwrappedJson["data"].dictionaryValue)
                        statusCallback(errorMessage, user)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
        }
    }
    
    class func register(_ data: [String: String], avatar: Data?, statusCallback: @escaping StatusCallback) {
        BMWebRequest.postMultipart(url: REGISTER, params: data as [String : AnyObject], avatar: avatar, isHeader: false) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        let user = User(withJSON: unwrappedJson["data"].dictionaryValue)
                        statusCallback(errorMessage, user)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func update(_ data: [String: String], avatar: Data, statusCallback: @escaping StatusCallback) {
        
        BMWebRequest.postMultipart(url: UPDATE, params: data as [String : AnyObject], avatar: avatar, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        let user = User(withJSON: unwrappedJson["data"].dictionaryValue)
                        statusCallback(errorMessage, user)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }

        }
    }
    
    class func requestCode(_ phone: String, statusCallback: @escaping StatusCallback) {
        let param = ["phone": phone]
        BMWebRequest.post(url: REQUEST_CODE, params: param as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, unwrappedJson["error"].boolValue)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback(errorMessage, false)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, false)
            }
        }
    }
    
    class func verifyCode(_ phone: String, code: String, statusCallback: @escaping StatusCallback) {
        let param = ["phone": phone, "code": code]
        BMWebRequest.post(url: VERIFY_CODE, params: param as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, unwrappedJson["error"].boolValue)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback(errorMessage, false)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, false)
            }
        }
    }
    
    class func verifyMedicalCard(_ cardNumber: String, statusCallback: @escaping StatusCallback) {
        let param = ["medical_card_number": cardNumber]
        BMWebRequest.post(url: VERIFY_MEDICAL_CARD, params: param as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, unwrappedJson["error"].boolValue)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback(errorMessage, false)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, false)
            }
        }
    }
    
    class func verifyAge(_ birthday: String, statusCallback: @escaping StatusCallback) {
        let param = ["birthday": birthday]
        BMWebRequest.post(url: AGE_VERIFY, params: param as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, unwrappedJson["error"].boolValue)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback(errorMessage, false)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, false)
            }
        }
    }
    
    class func verifyDoc(_ imagebase64: String, statusCallback: @escaping StatusCallback) {
        let param = ["imagebase64": imagebase64]
        BMWebRequest.post(url: DOC, params: param as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, unwrappedJson["error"].boolValue)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback(errorMessage, false)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, false)
            }
        }
    }
    
    class func getUserDetail(statusCallback: @escaping StatusCallback) {
        
        BMWebRequest.get(url: USER_DETAIL, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        let user = User(withJSON: unwrappedJson["data"].dictionaryValue)
                        statusCallback(errorMessage, user)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
        }
    }
    
    class func logout(statusCallback: @escaping StatusCallback) {
        
        BMWebRequest.post(url: LOGOUT, params: nil, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, false)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback(errorMessage, false)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, false)
            }
        }
    }
    
    class func getNearbyRetailers(_ lat: Double, long: Double, statusCallback:@escaping StatusCallback) {
        let params = ["latitude": lat, "longitude": long]
        BMWebRequest.post(url: NEARBY_RETAILER, params: params as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var retailers: [Retailer] = []
                        let arr = unwrappedJson["data"].arrayValue
                        for a in arr {
                            let retailer = Retailer(withJSON: a.dictionaryValue)
                            retailers.append(retailer)
                        }
                        statusCallback(errorMessage, retailers)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func getFavoriteRetailers(statusCallback:@escaping StatusCallback) {
        BMWebRequest.post(url: FAVORITES_RETAILER, params: nil, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var retailers: [Retailer] = []
                        let arr = unwrappedJson["data"].arrayValue
                        for a in arr {
                            let retailer = Retailer(withJSON: a.dictionaryValue)
                            retailers.append(retailer)
                        }
                        statusCallback(errorMessage, retailers)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func pastOrder(statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: ALL_ORDERS, params: nil, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var orders: [OrderData] = []
                        let arr = unwrappedJson["data"].arrayValue
                        for a in arr {
                            let retailer = OrderData(withJSON: a.dictionaryValue)
                            orders.append(retailer)
                        }
                        statusCallback(errorMessage, orders)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func getTodayLimits(statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: LIMITS, params: nil, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        let limits = Limits(withJSON: unwrappedJson["data"].dictionaryValue)
                        statusCallback(errorMessage, limits)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
        
    }
    
    class func getOrderDetails(_ orderId: String, statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: ORDER_DETAILS, params: ["id": orderId as AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        let data = unwrappedJson["data"].dictionaryValue
                        let order = OrderData(withJSON: data)
                        statusCallback(errorMessage, order)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }

    
    class func getBuds(_ retailerId: Int, statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: ITEM, params: ["retailer_id": retailerId as AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var budcategories: [BudCategory] = []
                        let data = unwrappedJson["data"].dictionaryValue
                        if let categories = data["categories"]?.array {
                            for a in categories {
                                let budcategory = BudCategory(withJSON: a.dictionaryValue)
                                budcategories.append(budcategory)
                            }
                        }
                        statusCallback(errorMessage, budcategories)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func addFavorite(_ retailerId: Int, statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: ADD_FAVORITE, params: ["retailer_id": retailerId as AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func removeFavorite(_ retailerId: Int, statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: REMOVE_FAVORITE, params: ["retailer_id": retailerId as AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        statusCallback(errorMessage, true)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func getPremiumBud(statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: PREMIUM_BUD, params: nil, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var retailer: [Retailer] = []
                        if let data = unwrappedJson["data"].array {
                            for a in data {
                                retailer.append(Retailer(withJSON: a.dictionaryValue))
                            }
                        }
                        statusCallback(errorMessage, retailer)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func getDealsOfDay(statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: DEALS_OF_DAY, params: nil, isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var retailer: [Retailer] = []
                        if let data = unwrappedJson["data"].array {
                            for a in data {
                                retailer.append(Retailer(withJSON: a.dictionaryValue))
                            }
                        }
                        statusCallback(errorMessage, retailer)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func getRetailer(_ retailerId: Int, statusCallback: @escaping StatusCallback) {
        BMWebRequest.post(url: GET_RETAILER, params: ["retailer_id": retailerId as AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var retailer: Retailer!
                        if let data = unwrappedJson["data"].dictionary {
                            retailer = Retailer(withJSON: data)
                        }
                        statusCallback(errorMessage, retailer)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func searchRetailers(_ query: String, lat: Double, long: Double, statusCallback: @escaping StatusCallback) {
        let params: [String: Any]
        if lat != 0 {
            params = ["search": query,
                          "latitude": lat,
                          "longitude": long]

        }else{
            params = ["search": query] as [String : Any]

        }
        BMWebRequest.post(url: SEARCH_RETAILERS, params: params as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var retailer: [Retailer] = []
                        if let data = unwrappedJson["data"].array {
                            for a in data {
                                retailer.append(Retailer(withJSON: a.dictionaryValue))
                            }
                        }
                        statusCallback(errorMessage, retailer)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func searchProducts(_ query: String, lat: Double, long: Double, statusCallback: @escaping StatusCallback) {
        let params: [String: Any]
        if lat != 0 {
            params = ["search": query,
                      "latitude": lat,
                      "longitude": long]
            
        }else{
            params = ["search": query] as [String : Any]

        }
        BMWebRequest.post(url: SEARCH_PRODUCTS, params: params as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var buds: [Bud] = []
                        if let data = unwrappedJson["data"].array {
                            for a in data {
                                buds.append(Bud(withJSON: a.dictionaryValue))
                            }
                        }
                        statusCallback(errorMessage, buds)
                    }
                }else{
                    statusCallback("errorMessage", nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func getDeliveryFee(_ lat: Double, long: Double, retailerId: Int, amount: Double, statusCallback:@escaping StatusCallback) {
        let params = ["latitudeDelivery": lat, "longitudeDelivery": long, "retailerId": retailerId, "amount": amount] as [String : Any]
        BMWebRequest.post(url: DELIVERY, params: params as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var deliveryFee: String = ""
                        if let str = unwrappedJson["data"].dictionary {
                            deliveryFee = (str["deliveryFee"]?.stringValue)!
                        }
                        statusCallback(errorMessage, deliveryFee)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    
    class func postOrder(_ params: [String: Any], statusCallback:@escaping StatusCallback) {
        BMWebRequest.postJson(url: POST_ORDER, params: params as [String : AnyObject], isHeader: true) { (result) in
            var errorMessage = ""
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["error"].boolValue {
                        errorMessage = unwrappedJson["message"].stringValue
                        statusCallback(errorMessage, nil)
                    }else{
                        var orderData: OrderData!
                        if let str = unwrappedJson["data"].dictionary {
                            orderData = OrderData(withJSON: str)
                        }
                        statusCallback(errorMessage, orderData)
                    }
                }else{
                    statusCallback(errorMessage, nil)
                }
            case .Failure(let error):
                statusCallback(error.localizedDescription, nil)
            }
            
        }
    }
    

*/
}
