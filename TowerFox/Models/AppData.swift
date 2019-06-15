//
//  AppData.swift
//  ParcelInfo
//
//  Created by cgc on 7/4/18.
//  Copyright © 2018 ParcelInfo LLC. All rights reserved.
//

import UIKit
import Foundation
import SQLite
public class AppData {
    
    class func getPath(fileName: String) -> String {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentUrl.appendingPathComponent(fileName)
        print(fileUrl)
        return fileUrl.path
    }
    
    class func copyFile(fileName: String) {
        let dbpath = getPath(fileName: fileName)
        let filemanager = FileManager.default
        if !filemanager.fileExists(atPath: dbpath) {
            let documentsURL = Bundle.main.resourceURL
            let frompath = documentsURL?.appendingPathComponent(fileName)
            do {
                try filemanager.copyItem(atPath: (frompath?.path)!, toPath: dbpath)
            }catch let error {
                print(error.localizedDescription)
                return
            }
        }
    }
//    var cUser: User!
//    var mUser: MobileUsers!
//    var stateArray: [StateModel]!
//    var countyArray: [CountyModel]!
//    var selectedStateIndex = -1
//    var selectedCountyIndex = -1
//    var isLoggedIn = false
//    var isSetStateCounty = false
//
//    var tempPassword: String = ""
//    var isForgetPassword: Bool = false
//
//    var isRememberMe: Bool = false
//    var pushToken: String = ""
//    public static let sharedInstance: AppData = {
//        let instance = AppData()
//        return instance
//    }()
//
//    func setUser(_ user: User) {
////        DispatchQueue.main.async {
//            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user)
//            UserDefaults.standard.set(encodedData, forKey: "user")
//            UserDefaults.standard.synchronize()
//            self.cUser = user
////        }
//    }
//
//    func setRememberMe(_ remember: Bool) {
//        UserDefaults.standard.set(remember, forKey: "rememberMe")
//        UserDefaults.standard.synchronize()
//        self.isRememberMe = remember
//    }
//
//    func getRememberMe() -> Bool {
//        if UserDefaults.standard.object(forKey: "rememberMe") == nil {
//            UserDefaults.standard.set(false, forKey: "rememberMe")
//            UserDefaults.standard.synchronize()
//            self.isRememberMe = false
//            return false
//        }else{
//            self.isRememberMe = UserDefaults.standard.bool(forKey: "rememberMe")
//            return self.isRememberMe
//        }
//    }
//
//    func setPushToken(token: String) {
//        UserDefaults.standard.set(token, forKey: "pushToken")
//        UserDefaults.standard.synchronize()
//        self.pushToken = token
//        if self.pushToken != "" {
//            ApiRequest.postPushId(self.pushToken) { (message, data) in
//
//            }
//        }
//    }
//
//    func getPushToken() -> String {
//        if UserDefaults.standard.object(forKey: "pushToken") == nil {
//            UserDefaults.standard.set("", forKey: "pushToken")
//            UserDefaults.standard.synchronize()
//            self.pushToken = ""
//            return self.pushToken
//        }else{
//            self.pushToken = UserDefaults.standard.string(forKey: "pushToken")!
//            return self.pushToken
//        }
//    }
//
//    func setApiUser(_ user: ApiUsers) {
//        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user)
//        UserDefaults.standard.set(encodedData, forKey: "auser")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.aUser = user
//    }
//
//    func setStateArray(_ states: [StateModel]) {
//        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: states)
//        UserDefaults.standard.set(encodedData, forKey: "statearray")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.stateArray = states
//    }
//
//    func setCountyArray(_ counties: [CountyModel]) {
//        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: counties)
//        UserDefaults.standard.set(encodedData, forKey: "countyarray")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.countyArray = counties
//    }
//
//    func setSelectedStateIndex(_ stateIndex: Int) {
//        UserDefaults.standard.set(stateIndex, forKey: "selectedStateIndex")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.selectedStateIndex = stateIndex
//    }
//
//    func setSelectedCountyIndex(_ countyIndex: Int) {
//        UserDefaults.standard.set(countyIndex, forKey: "selectedCountyIndex")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.selectedCountyIndex = countyIndex
//    }
//
//    func setStateCounty(_ b: Bool) {
//        UserDefaults.standard.set(b, forKey: "isSetStateCounty")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.isSetStateCounty = b
//    }
//
//    func setLoggedIn(_ b: Bool) {
//        UserDefaults.standard.set(b, forKey: "isLoggedIn")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.isLoggedIn = b
//    }
//
//    func setIsForgetPassword(_ b: Bool) {
//        UserDefaults.standard.set(b, forKey: "isForgetPassword")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.isForgetPassword = b
//    }
//
//    func setTempPassword(_ b: String) {
//        UserDefaults.standard.set(b, forKey: "tempPassword")
//        UserDefaults.standard.synchronize()
//        AppData.sharedInstance.tempPassword = b
//    }
//
//    func getUser() -> User {
//        if UserDefaults.standard.object(forKey: "user") == nil {
//            return User()
//        }
//        let decoded = UserDefaults.standard.object(forKey: "user") as! Data
//        self.cUser =  NSKeyedUnarchiver.unarchiveObject(with: decoded) as? User
//        return self.cUser
//    }

//    func getApiUser() -> ApiUsers {
//        let decoded = UserDefaults.standard.object(forKey: "auser") as! Data
//        self.aUser =  NSKeyedUnarchiver.unarchiveObject(with: decoded) as? ApiUsers
//        return self.aUser
//    }
//
//    func getStateArray() -> [StateModel] {
//        let decoded = UserDefaults.standard.object(forKey: "statearray") as! Data
//        self.stateArray =  NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [StateModel]
//        return self.stateArray
//    }
//
//    func getCountyArray() -> [CountyModel] {
//        let decoded = UserDefaults.standard.object(forKey: "countyarray") as! Data
//        self.countyArray =  NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CountyModel]
//        return self.countyArray
//    }
//
//    func getSelectedStateIndex() -> Int {
//        self.selectedStateIndex =  UserDefaults.standard.integer(forKey: "selectedStateIndex")
//        return self.selectedStateIndex
//    }
//
//    func getSelectedCountyIndex() -> Int {
//        self.selectedCountyIndex = UserDefaults.standard.integer(forKey: "selectedCountyIndex")
//        return self.selectedCountyIndex
//    }
//
//    func getLoggedIn() -> Bool {
//        if UserDefaults.standard.object(forKey: "isLoggedIn") == nil {
//            self.isLoggedIn = false
//            return self.isLoggedIn
//        }else{
//            self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
//            return self.isLoggedIn
//        }
//    }
//
//    func getSetStateCounty() -> Bool {
//        if UserDefaults.standard.object(forKey: "isSetStateCounty") == nil {
//            self.isSetStateCounty = false
//            return self.isSetStateCounty
//        }else{
//            self.isSetStateCounty = UserDefaults.standard.bool(forKey: "isSetStateCounty")
//            return self.isSetStateCounty
//        }
//    }
//
//    func getTempPassword() -> String {
//        if UserDefaults.standard.object(forKey: "tempPassword") == nil {
//            self.tempPassword = ""
//            return self.tempPassword
//        }else{
//            self.tempPassword = UserDefaults.standard.string(forKey: "tempPassword")!
//            return self.tempPassword
//        }
//    }
//    func IsforgetPassword() -> Bool {
//        if UserDefaults.standard.object(forKey: "isForgetPassword") == nil {
//            self.isForgetPassword = false
//            return self.isForgetPassword
//        }else{
//            self.isForgetPassword = UserDefaults.standard.bool(forKey: "isForgetPassword")
//            return self.isForgetPassword
//        }
//    }
}
