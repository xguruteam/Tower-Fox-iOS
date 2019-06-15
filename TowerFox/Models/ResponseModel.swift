//
//  ResponseModel.swift
//  CloseOut
//
//  Created by cgc on 8/27/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import SwiftyJSON
class ResponseModel: NSObject {
    var status: Bool?
    var supportEmailAddress :String?
    var supportPhone :String?
    var supportWebAddress :String?
    var targetMaxImageCaptureHeight :String?
    var targetMaxImageCaptureWidth :String?
    var useAWSImageUpload :String?
    
    override init() {
    }
    init(with info: [String: JSON]) {
        if let status = info["Status"]?.string {
            if status == "true" {
                self.status = true
            }else{
                self.status = false
            }
        }
        if let supportEmailAddress = info["supportEmailAddress"]?.string {
            self.supportEmailAddress = supportEmailAddress
        }
        if let supportPhone = info["supportPhone"]?.string {
            self.supportPhone = supportPhone
        }
        if let supportWebAddress = info["supportWebAddress"]?.string {
            self.supportWebAddress = supportWebAddress
        }
        if let targetMaxImageCaptureHeight = info["targetMaxImageCaptureHeight"]?.string {
            self.targetMaxImageCaptureHeight = targetMaxImageCaptureHeight
        }
        if let targetMaxImageCaptureWidth = info["targetMaxImageCaptureWidth"]?.string {
            self.targetMaxImageCaptureWidth = targetMaxImageCaptureWidth
        }
        if let useAWSImageUpload = info["useAWSImageUpload"]?.string {
            self.useAWSImageUpload = useAWSImageUpload
        }
    }
    
    func save() {
        if self.supportEmailAddress != nil {
            storage_saveObject("supportEmailAddress", self.supportEmailAddress as Any)
        }
        if self.supportWebAddress != nil {
            storage_saveObject("supportWebAddress", self.supportWebAddress as Any)
        }
        if self.supportPhone != nil {
            storage_saveObject("supportPhone", self.supportPhone as Any)
        }
        if self.targetMaxImageCaptureWidth != nil {
            storage_saveObject("targetMaxImageCaptureWidth", self.targetMaxImageCaptureWidth as Any)
        }
        if self.targetMaxImageCaptureHeight != nil {
            storage_saveObject("targetMaxImageCaptureHeight", self.targetMaxImageCaptureHeight as Any)
        }
        if self.useAWSImageUpload != nil {
            storage_saveObject("useAWSImageUpload", self.useAWSImageUpload as Any)
        }
    }
    
    func get() -> ResponseModel {
        if storage_loadObject("supportPhone") != nil {
            self.supportPhone = storage_loadObject("supportPhone")
        }
        if storage_loadObject("supportEmailAddress") != nil {
            self.supportEmailAddress = storage_loadObject("supportEmailAddress")
        }
        if storage_loadObject("supportWebAddress") != nil {
            self.supportWebAddress = storage_loadObject("supportWebAddress")
        }
        if storage_loadObject("targetMaxImageCaptureHeight") != nil {
            self.targetMaxImageCaptureHeight = storage_loadObject("targetMaxImageCaptureHeight")
        }
        if storage_loadObject("targetMaxImageCaptureWidth") != nil {
            self.targetMaxImageCaptureWidth = storage_loadObject("targetMaxImageCaptureWidth")
        }
        if storage_loadObject("useAWSImageUpload") != nil {
            self.useAWSImageUpload = storage_loadObject("useAWSImageUpload")
        }
        self.status  = true
        return self
    }
}

class AuthenticateModel: NSObject {
    var AbsoluteExpiration: String?
    var AppUserID :String?
    var Message :String?
    var SlidingExpiration :String?
    var status :Bool!
    var Token :String?
    var VendorContactID :String?
    var VendorID :String?
    
    override init() {
    }
    
    init(with info: [String: JSON]) {
        if let AbsoluteExpiration = info["AbsoluteExpiration"]?.string {
            self.AbsoluteExpiration = AbsoluteExpiration
        }
        if let AppUserID = info["AppUserID"]?.string {
            self.AppUserID = AppUserID
        }
        if let Message = info["Message"]?.string {
            self.Message = Message
        }
        if let SlidingExpiration = info["SlidingExpiration"]?.string {
            self.SlidingExpiration = SlidingExpiration
        }
        if let status = info["Status"]?.bool {
            self.status = status
        }
        if let Token = info["Token"]?.string {
            self.Token = Token
        }
        if let VendorContactID = info["VendorContactID"]?.string {
            self.VendorContactID = VendorContactID
        }
        if let VendorID = info["VendorID"]?.string {
            self.VendorID = VendorID
        }
    }
}
