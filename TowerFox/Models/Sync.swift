//
//  Sync.swift
//  CloseOut
//
//  Created by cgc on 8/29/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import SwiftyJSON
import SQLite
import AWSCore
import AWSS3
import Alamofire
import AFNetworking
import SDWebImage
import Photos

let s3URI = "https://lifecycle-closeout-demo-photos.s3.amazonaws.com/"
//let s3URI = "https://d24mkkhodirsc3.cloudfront.net/"

let policyBase64 = "eyJleHBpcmF0aW9uIjoiMjAyMC0xMi0zMVQxMjowMDowMC4wMDBaIiwiY29uZGl0aW9ucyI6W3siYnVja2V0IjoibGlmZWN5Y2xlLWNsb3Nlb3V0LWRlbW8tcGhvdG9zIn0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCIiXSx7ImFjbCI6InB1YmxpYy1yZWFkIn0sWyJzdGFydHMtd2l0aCIsIiRDb250ZW50LVR5cGUiLCIiXSxbImNvbnRlbnQtbGVuZ3RoLXJhbmdlIiwwLDUyNDI4ODAwMF1dfQ=="
let signature = "fgSHgALFA5vLeXzjoS12rdM6GFQ="
let awsKey = "AKIAJIVNJLWFTIUBQ4PQ"
let acl = "public-read"

public class Sync {
    var projectID: String!
    var projectArray:[String] = []
    var categoryArray:[String] = []
    var photosArray:[String] = []

    var referenceImageNamesList:[String] = []
    var capturedImageNamesList:[String] = []
    var uploadImageNamesList:[String] = []
    var uploadCount = 0
    var downloadCount = 0
    var downloadCapturedCount = 0
    var isResetPhotoAvailable = false
    var intTotalImagesCount = 0
    var intTotalImagesUploadedCount = 0
    var s3Uploader: AWSS3TransferManager!

    public static let sharedInstance: Sync = {
        let instance = Sync()
        return instance
    }()

    init(){
    }
    
    func sendDeviceInfo(completionHandler: @escaping(Bool, String) ->Void) {
        let device = UIDevice.current
        let uuid = device.identifierForVendor?.uuidString
        print(uuid as Any)
        let model = device.model
        let paltform = "iOS"
        let version = device.systemVersion
        let logindate = Int64(Date().timeIntervalSince1970 * 1000)
        let param = ["DeviceID": uuid!, "DeviceModel": model, "DevicePlatform": paltform, "DeviceToken": storage_loadObject("TokenID"), "DeviceVersion":version, "LoginDate":"/Date(\(logindate))/", "ProjectID": storage_loadObject("ProjectID"), "UserName":storage_loadObject("UserName")]
        print(param)
        BMWebRequest.post(url: getDeviceInfoURL(), params: param as [String : AnyObject], isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["ServiceStatus"].stringValue == "SUCCESS" {
                        completionHandler(true, "")
                    }else{
                        print(unwrappedJson["ServiceMessage"])
                        completionHandler(false, unwrappedJson["ServiceMessage"].stringValue)
                    }
                }else{
                    completionHandler(false, "")
                }
            case .Failure(let error):
                print(error)
                completionHandler(false, error.localizedDescription)
            }
            
        }
    }
    
    func sendLogoutDeviceInfo(completionHandler: @escaping(Bool, String) ->Void) {
        let device = UIDevice.current
        let uuid = device.identifierForVendor?.uuidString
        print(uuid as Any)
        let model = device.model
        let paltform = "iOS"
        let version = device.systemVersion
        let logindate = Int64(Date().timeIntervalSince1970 * 1000)
        let param = ["DeviceID": uuid!, "DeviceModel": model, "DevicePlatform": paltform, "DeviceToken": storage_loadObject("TokenID"), "DeviceVersion":version, "LoginDate":"/Date(\(logindate))/", "ProjectID": storage_loadObject("ProjectID"), "UserName":storage_loadObject("UserName")]
        print(param)
        BMWebRequest.post(url: getLogoutDeviceInfoURL(), params: param as [String : AnyObject], isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["ServiceStatus"].stringValue == "SUCCESS" {
                        completionHandler(true, "")
                    }else{
                        print(unwrappedJson["ServiceMessage"])
                        completionHandler(false, unwrappedJson["ServiceMessage"].stringValue)
                    }
                }else{
                    completionHandler(false, "")
                }
            case .Failure(let error):
                print(error)
                completionHandler(false, error.localizedDescription)
            }
            
        }
    }
    
    func SyncProjects(completionHandler: @escaping(Bool, String, [String]) ->Void) {
        projectID = storage_loadObject("ProjectID")
        let params = ["FirstName":storage_loadObject("UserName"), "LastName":storage_loadObject("UserName"), "PaceID": projectID, "ProjectID": projectID, "Username":storage_loadObject("UserName"), "password":storage_loadObject("UserName")]
        BMWebRequest.post(url: getProjectsByProjectIDURL(), params: params as [String : AnyObject], isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    var projectList: [ProjectModel] = []
                    if unwrappedJson.count > 0 {
                        if (unwrappedJson.arrayValue[0])["ServiceStatus"].stringValue == "SUCCESS" {
                            self.projectArray.removeAll()
                            for data in unwrappedJson.arrayValue {
                                let projectModel = ProjectModel(with: data.dictionaryValue)
                                projectList.append(projectModel)
                                self.projectArray.append(projectModel.ProjectID)
                                let query = "INSERT OR REPLACE INTO Projects (ProjectID, ProjectName, CasperID, PaceID, Description, FirstName, LastName) values (\"\(projectModel.ProjectID!)\", \"\(projectModel.ProjectName!)\", \"\(projectModel.casprid!)\", \"\(projectModel.ProjectID!)\", \"\(projectModel.Description!)\", \"\(projectModel.FirstName!)\", \"\(projectModel.LastName!)\")"
                                do{
                                    try Database().db.execute(query)
                                }catch let error {
                                    print(error.localizedDescription)
                                }
                            }
                            completionHandler(true, "", self.projectArray)
                        }else{
                            completionHandler(false, (unwrappedJson.arrayValue[0])["ServiceMessage"].stringValue, self.projectArray)
                        }
                    }else{
                        completionHandler(false, "", self.projectArray)
                    }
                }else{
                    completionHandler(false, "", [])
                }
            case .Failure(let error):
                print(error)
                completionHandler(false, error.localizedDescription, [])
            }
        }
    }
    
    func syncProjectCategories(_ index: Int) {
        if index < projectArray.count {
            let id = projectArray[index]
            BMWebRequest.get(url: getCategorybyprjtIDURL(id), isHeader: false) { (result) in
                switch(result) {
                case .Success(let json):
                    if let unwrappedJson = json as? JSON {
                        var categoryList: [CategoryModel] = []
                        if unwrappedJson.count > 0 {
                            var failed = false
                            for data in unwrappedJson.arrayValue {
                                let categoryModel = CategoryModel(with: data.dictionaryValue)
                                categoryList.append(categoryModel)
                                self.categoryArray.append(categoryModel.CategoryID)
                                let query = "INSERT OR REPLACE INTO Categories (ProjectID, CategoryID, CategoryName, ParentCategoryID, ContainsSectorPosition, SortOrder) values (\"\(categoryModel.ProjectID!)\", \"\(categoryModel.CategoryID!)\", \"\(categoryModel.CategoryName!)\", \"\(categoryModel.ParentCategoryID!)\", \"\(categoryModel.ContainsSectorPosition)\", \"\(categoryModel.SortOrder!)\")";
                                do{
                                    try Database().db.execute(query)
                                }catch let error {
                                    print("Category Error")
                                    failed = true
                                    print(error.localizedDescription)
                                    NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                                }
                            }
                            if !failed {
                                if index < self.projectArray.count {
                                    self.syncProjectCategories(index + 1)
                                }else{
                                    self.syncSector()
                                }
                            }
                        }else{
                            NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                        }
                    }else{
                        NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                    }
                case .Failure(let error):
                    print(error)
                    NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                }
            }
        }else{
            self.syncSector()
        }
    }
    
    func SyncCategories(_ _projectArr:[String], completionHandler: @escaping() ->Void) {
        let group = DispatchGroup()
        group.enter()
        for id in _projectArr {
            BMWebRequest.get(url: getCategorybyprjtIDURL(id), isHeader: false) { (result) in
                switch(result) {
                case .Success(let json):
                    if let unwrappedJson = json as? JSON {
                        var categoryList: [CategoryModel] = []
                        if unwrappedJson.count > 0 {
                            for data in unwrappedJson.arrayValue {
                                let categoryModel = CategoryModel(with: data.dictionaryValue)
                                categoryList.append(categoryModel)
                                self.categoryArray.append(categoryModel.CategoryID)
                                let query = "INSERT OR REPLACE INTO Categories (ProjectID, CategoryID, CategoryName, ParentCategoryID, ContainsSectorPosition, SortOrder) values (\"\(categoryModel.ProjectID!)\", \"\(categoryModel.CategoryID!)\", \"\(categoryModel.CategoryName!)\", \"\(categoryModel.ParentCategoryID!)\", \"\(categoryModel.ContainsSectorPosition)\", \"\(categoryModel.SortOrder!)\")";
                                do{
                                    try Database().db.execute(query)
                                }catch let error {
                                    print("Category Error")
                                    print(error.localizedDescription)
                                }
                            }
                            group.leave()
                        }else{
                            group.leave()
                        }
                    }else{
                        group.leave()
                    }
                case .Failure(let error):
                    print(error)
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completionHandler()
        }
    }
    
    func uploadDataToServer() {
        let actualDate = Int64(Date().timeIntervalSince1970 * 1000)
        storage_saveObject("SyncTime", actualDate);
        print("sync Time: \(actualDate)")
        
        if(Database.sharedInstance.isFromBagroundSync != true && Database.sharedInstance.isFromProjects != false)
        {
//            showProgressBar("Uploading Photos, Please wait calculating" , "0");
        }
        
        intTotalImagesCount = 0
        intTotalImagesUploadedCount = 0
        do {
            let stmt = try Database.sharedInstance.db.prepare("SELECT CapturedImageName, Status FROM Photos WHERE STATUS in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\")")
            var datas: [[String: Any]] = []
            for row in stmt {
                var param: [String: Any] = [:]
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
                datas.append(param)
            }
            if datas.count > 0 {
                intTotalImagesCount = datas.count
                uploadImageNamesList = []
                if intTotalImagesCount > 0 {
                    for i in 0..<datas.count {
                        if Int(datas[i]["Status"] as! Int64) == StatusEnum.PICTAKEN.rawValue {
                            uploadImageNamesList.append(datas[i]["CapturedImageName"] as! String)
                        }else if Int(datas[i]["Status"] as! Int64) == StatusEnum.RESETPHOTO.rawValue {
                            isResetPhotoAvailable = true
                        }
                    }
                    uploadCount = 0
                    self.uploadImages()
                }else
                {
                    appDel.hideHUD()
                    storage_saveObject("SYNC", "")
                }
            }else{
                self.buildProjectPhotosQuery(Database.sharedInstance.projectsGlobalArray)
            }
        }catch let error {
            appDel.hideHUD()
            storage_saveObject("SYNC", "")
            print(error.localizedDescription)
        }

    }
    
    func buildProjectPhotosQuery(_ _projectsGlobalArray: [String]) {
        var jsonData: [[String: Any]] = []
        if(_projectsGlobalArray.count > 0){
            for i in 0..<_projectsGlobalArray.count {
                var param = ["CASPRID": _projectsGlobalArray[i]]
                
                var date = "0";
                
                if((i+1) == _projectsGlobalArray.count)
                {
                    if(storage_loadObject(_projectsGlobalArray[i]) != nil)
                    {
                        date = storage_loadObject(_projectsGlobalArray[i])!
                        if date.count == 13 {
                            param["SyncDate"] = "/Date(\(date))/"
                        }else{
                            param["SyncDate"] = "/Date(0)/"
                        }
                    }
                    else
                    {
                        param["SyncDate"] = "/Date(0)/"
                    }
                }
                else
                {
                    if(storage_loadObject(_projectsGlobalArray[i]) != nil)
                    {
                        date = storage_loadObject(_projectsGlobalArray[i])!
                        if date.count == 13 {
                            param["SyncDate"] = "/Date(\(date))/"
                        }else{
                            param["SyncDate"] = "/Date(0)/"
                        }
                    }
                    else
                    {
                        param["SyncDate"] = "/Date(0)/"
                    }
                }
                jsonData.append(param)
            }
            syncProjectPhotos(jsonData);
        }else{
            storage_saveObject("SYNC", "")
            appDel.hideHUD()
        }
    }
    
    func syncProjectPhotos(_ jsonData: [[String: Any]]) {
        BMWebRequest.postArray(url: getProjectPhotosURL(), params: jsonData, isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    var photos: [ProjectPhotosModel] = []
                    if unwrappedJson.count > 0 {
                        for data in unwrappedJson.arrayValue {
                            let photoModel = ProjectPhotosModel(with: data.dictionaryValue)
                            photos.append(photoModel)
                            self.photosArray.append(photoModel.ProjectPhotoID)
                            var convertedDate = ""
                            if(photoModel.TakenDate == nil || photoModel.TakenDate == "null" || photoModel.TakenDate == "")
                            {
                                convertedDate = ""
                            }
                            else
                            {
                                if let takenDate = photoModel.TakenDate
                                {
                                    let startIndex = takenDate.index(takenDate.startIndex, offsetBy: 6)
                                    let endIndex = takenDate.index( startIndex, offsetBy: 10)
                                    let convertedate = takenDate[startIndex..<endIndex]
                                    if let timeinterval = TimeInterval(String(convertedate)) {
                                        let date = Date(timeIntervalSince1970: timeinterval)
                                        let dateformatter = DateFormatter()
                                        dateformatter.dateFormat = "M/dd/yyyy,  h:mm:ss a"
                                        convertedDate = dateformatter.string(from: date)
                                    } else {
                                        convertedDate = ""
                                    }
                                } else {
                                    convertedDate = ""
                                }
                            }
                            var referenceImageName = ""
                            let referenceImageurl = photoModel.ReferenceImageName.components(separatedBy: "/")
                            if referenceImageurl.count > 0 {
                                referenceImageName = referenceImageurl.last!
                            }
                            var imagepath = ""
                            let imagepathurl = photoModel.ImagePath.components(separatedBy: "/")
                            if imagepathurl.count > 0 {
                                imagepath = imagepathurl.last!
                            }
                            let query = "INSERT OR REPLACE INTO Photos (ProjectPhotoID, ProjectID, CategoryID, ItemID, SectorID, PositionID, ItemName, Description, Comments, TakenBy, TakenDate, Status, ReferenceImageName, CapturedImageName, Quantity, RequireSectorPosition, ParentCategoryID, Latitude, Longitude, IsAdhoc, AdhocPhotoID, SortOrder) values (\"\(photoModel.ProjectPhotoID!)\", \"\(photoModel.ProjectID!)\", \"\(photoModel.CategoryID!)\", \"\(photoModel.ItemID!)\", \"\(photoModel.SectorID!)\", \"\(photoModel.PositionID!)\", \"\(photoModel.ItemName!)\", \"\(photoModel.Description!)\", \"\(photoModel.Comments!)\", \"\(photoModel.TakenBy!)\", \"\(convertedDate)\", \"\(photoModel.ApprovalStatus)\", \"\(referenceImageName)\", \"\(imagepath)\", \"\(photoModel.Quantity)\", \"\(photoModel.RequiresSectorPosition)\", \"\(photoModel.CategoryRelations!)\",\"\(photoModel.Latitude!)\", \"\(photoModel.Longitude!)\", \"\(photoModel.IsAdhoc)\", \"\(photoModel.AdhocPhotoID!)\", \"\(photoModel.SortOrder)\")"
                            do{
                                try Database().db.execute(query)
                                let deleteQuery = "Delete from Photos Where status in (\"\(StatusEnum.DELETEDPHOTO.rawValue)\")"
                                //        console.log("Delete : " + deleteQuery);
                                try Database().db.execute(deleteQuery)
                            }catch let error {
                                print(error.localizedDescription)
                                storage_saveObject("SYNC", "")
                            }
                        }
                        self.buildReferencePhotosQuery(Database.sharedInstance.projectsGlobalArray)
                    }else{
                        appDel.hideHUD()
                        storage_saveObject("SYNC", "")
                    }
                }else{
                    appDel.hideHUD()
                    storage_saveObject("SYNC", "")
                }
            case .Failure(let error):
                appDel.hideHUD()
                storage_saveObject("SYNC", "")
                print(error)
            }
        }
    }
    func buildReferencePhotosQuery(_ _projectsGlobalArray: [String]) {
        //        print("User Name: " + storage_loadObject("UserName") + ', CasprId: ' + storage_loadObject("CasprID")! + "##Sync.js -- buildProjectPhotosQuery")
        var jsonData: [[String: Any]] = []
        if(_projectsGlobalArray.count > 0){
            for i in 0..<_projectsGlobalArray.count {
                var param = ["CASPRID": _projectsGlobalArray[i]]
                
                var date = "0";
                
                if(storage_loadObject(_projectsGlobalArray[i]) != nil)
                {
                    date = storage_loadObject(_projectsGlobalArray[i])!
                    if date.count == 13 {
                        param["SyncDate"] = "/Date(\(date))/"
                    }else{
                        param["SyncDate"] = "/Date(0)/"
                    }
                }
                else
                {
                    param["SyncDate"] = "/Date(0)/"
                }
                jsonData.append(param)
            }
            syncReferencePhotos(jsonData);
        }else{
            appDel.hideHUD()
            storage_saveObject("SYNC", "")
        }
    }
    
    func syncReferencePhotos(_ jsonData: [[String: Any]]) {
        BMWebRequest.postArray(url: getReferencePhotosURL(), params: jsonData, isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    appDel.hideHUD()
                    if unwrappedJson.count > 0 {
                        self.referenceImageNamesList.removeAll()
                        for data in unwrappedJson.arrayValue {
                            print(data)
                            self.referenceImageNamesList.append(data["strURL"].stringValue)
                        }
                        self.downloadReferenceImages()
                    }else{
                        self.buildCapturedPhotosQuery(Database.sharedInstance.projectsGlobalArray)
                    }
                }else{
                    appDel.hideHUD()
                    storage_saveObject("SYNC", "")
                }
            case .Failure(let error):
                appDel.hideHUD()
                storage_saveObject("SYNC", "")
                print(error)
            }
        }
    }

    func buildCapturedPhotosQuery(_ _projectsGlobalArray: [String]) {
        //        print("User Name: " + storage_loadObject("UserName") + ', CasprId: ' + storage_loadObject("CasprID")! + "##Sync.js -- buildProjectPhotosQuery")
        appDel.showHUD("Synchronizing", subtext: "")
        var jsonData: [[String: Any]] = []
        if(_projectsGlobalArray.count > 0){
            for i in 0..<_projectsGlobalArray.count {
                var param = ["CASPRID": _projectsGlobalArray[i]]
                
                var date = "0";
                
                if(storage_loadObject(_projectsGlobalArray[i]) != nil)
                {
                    date = storage_loadObject(_projectsGlobalArray[i])!
                    if date.count == 13 {
                        param["SyncDate"] = "/Date(\(date))/"
                    }else{
                        param["SyncDate"] = "/Date(0)/"
                    }
                }
                else
                {
                    param["SyncDate"] = "/Date(0)/"
                }
                jsonData.append(param)
            }
            syncCapturedPhotos(jsonData);
        }else{
            appDel.dismissProgressView()
            storage_saveObject("SYNC", "")
        }
    }
    
    func syncCapturedPhotos(_ jsonData: [[String: Any]]) {
        self.downloadCount = 0
        BMWebRequest.postArray(url: getCapturedPhotosURL(), params: jsonData, isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    self.capturedImageNamesList.removeAll()
                    if unwrappedJson.count > 0 {
                        for data in unwrappedJson.arrayValue {
                            print(data)
                            self.capturedImageNamesList.append(data["strURL"].stringValue)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name("updateProject"), object: nil)
                        self.downloadCapturedCount = 0
                        self.downloadCapturedImages()
                    }else{
                        appDel.dismissProgressView()
                        NotificationCenter.default.post(name: NSNotification.Name("updateProject"), object: nil)
                        storage_saveObject("SYNC", "")
                    }
                }else{
                    appDel.dismissProgressView()
                    NotificationCenter.default.post(name: NSNotification.Name("updateProject"), object: nil)
                    storage_saveObject("SYNC", "")
                }
            case .Failure(let error):
                appDel.dismissProgressView()
                NotificationCenter.default.post(name: NSNotification.Name("updateProject"), object: nil)
                storage_saveObject("SYNC", "")
                print(error)
            }
        }
    }
    
    func downloadReferenceImages() {
        
        if referenceImageNamesList.count > 0 && (referenceImageNamesList.count > (downloadCount - 1)) {
            let object = ["text": "Downloading Reference Photos, Please wait \(downloadCount) of \(referenceImageNamesList.count)", "progress": (Double(downloadCount) / Double(referenceImageNamesList.count)), "total": referenceImageNamesList.count] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "progressUpdated"), object: object)
            var urlstring = referenceImageNamesList[downloadCount]
            urlstring = urlstring.replacingOccurrences(of: "d2cagqgd5mtm1q.cloudfront.net", with: "s3.amazonaws.com/closeout-app-content")
            let uri = URL(string: urlstring)
            var imagepath = ""
            let imagepathurl = referenceImageNamesList[downloadCount].components(separatedBy: "/")
            if imagepathurl.count > 0 {
                imagepath = imagepathurl.last!
            }
            if imagepath == "" {
                DispatchQueue.main.async {
                    self.downloadCount = self.downloadCount + 1
                    if self.downloadCount < self.referenceImageNamesList.count {
                        self.downloadReferenceImages()
                    }else{
                        self.buildCapturedPhotosQuery(Database.sharedInstance.projectsGlobalArray)
                    }
                }
                return
            }
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("ReferencePhotos/\(imagepath)")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }

            Alamofire.download(uri!, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: [:], to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility), closure: { (progress) in
                print(progress.fractionCompleted)
            })
                .validate { (request, response, tempurl, destinationurl) -> Request.ValidationResult in
                    return .success
                }.responseJSON { (response) in
                    if (response.destinationURL?.path) != nil {
                        DispatchQueue.main.async {
                            self.downloadCount = self.downloadCount + 1
                            if self.downloadCount < self.referenceImageNamesList.count {
                                self.downloadReferenceImages()
                            }else{
                                self.buildCapturedPhotosQuery(Database.sharedInstance.projectsGlobalArray)
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.downloadCount = self.downloadCount + 1
                            if self.downloadCount < self.referenceImageNamesList.count {
                                self.downloadReferenceImages()
                            }else{
                                self.buildCapturedPhotosQuery(Database.sharedInstance.projectsGlobalArray)
                            }
                        }
                    }

            }
            
        }else{
            appDel.dismissProgressView()
            storage_saveObject("SYNC", "")
       }

    }
    func downloadCapturedImages() {
        appDel.hideHUD()
        if capturedImageNamesList.count > 0 && (capturedImageNamesList.count > (downloadCapturedCount - 1)) {
            let object = ["text": "Downloading Captured Photos, Please wait \(downloadCapturedCount) of \(capturedImageNamesList.count)", "progress": (Double(downloadCapturedCount) / Double(capturedImageNamesList.count)), "total": capturedImageNamesList.count] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "progressUpdated"), object: object)
            let uri = URL(string: capturedImageNamesList[downloadCapturedCount])
            var imagepath = ""
            let imagepathurl = capturedImageNamesList[downloadCapturedCount].components(separatedBy: "/")
            if imagepathurl.count > 0 {
                imagepath = imagepathurl.last!
            }
            if imagepath == "" || imagepathurl.contains("noPhoto.jpg")  {
                DispatchQueue.main.async {
                    self.downloadCapturedCount = self.downloadCapturedCount + 1
                    if self.downloadCapturedCount < self.capturedImageNamesList.count {
                        self.downloadCapturedImages()
                    }else{
                        for i in 0..<Database.sharedInstance.projectsGlobalArray.count
                        {
                            storage_saveObject(Database.sharedInstance.projectsGlobalArray[i], storage_loadObject("SyncTime") as Any);
                        }
                        storage_saveObject("SYNC", "")
                        appDel.dismissProgressView()
                    }
                }
                return
            }
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("CapturedPhotos/\(imagepath)")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(uri!, to: destination).response { (response) in
                if (response.destinationURL?.path) != nil {
                    
                    print("--------------->\n\(response.destinationURL!)")
                    
                    let url = response.destinationURL!
                    let path = url.path
                    if let downloadedImage = UIImage(contentsOfFile: path) {
                        let fileName = url.lastPathComponent
                        let infos = fileName.split(separator: "_")
                        if let projectID = infos.first {
                            print("projectID: \(projectID)")
                            PHPhotoLibrary.shared().save(image: downloadedImage, path: String(projectID))
                        }
                    }
                    DispatchQueue.main.async {
                        self.downloadCapturedCount = self.downloadCapturedCount + 1
                        if self.downloadCapturedCount < self.capturedImageNamesList.count {
                            self.downloadCapturedImages()
                        }else{
                            for i in 0..<Database.sharedInstance.projectsGlobalArray.count
                            {
                                storage_saveObject(Database.sharedInstance.projectsGlobalArray[i], storage_loadObject("SyncTime") as Any)
                            }
                            storage_saveObject("SYNC", "")
                            appDel.dismissProgressView()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.downloadCapturedCount = self.downloadCapturedCount + 1
                        if self.downloadCapturedCount < self.capturedImageNamesList.count {
                            self.downloadCapturedImages()
                        }else{
                            for i in 0..<Database.sharedInstance.projectsGlobalArray.count
                            {
                                storage_saveObject(Database.sharedInstance.projectsGlobalArray[i], storage_loadObject("SyncTime") as Any)
                            }
                            storage_saveObject("SYNC", "")
                            appDel.dismissProgressView()

                        }
                    }
                }
            }
        }else{
            storage_saveObject("SYNC", "")
            appDel.dismissProgressView()
        }

    }

    func syncSector() {
        BMWebRequest.get(url: getSectorsURL(), isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    var failed = false
                    if unwrappedJson.count > 0 {
                        for data in unwrappedJson.arrayValue {
                            let query = "INSERT OR REPLACE INTO Sector (SectorID, SectorName) values (\"\(data["SectorID"].intValue)\", \"\(data["Name"].stringValue)\")"
                            do{
                                try Database().db.execute(query)
                            }catch let error {
                                print(error.localizedDescription)
                                failed = true
                                NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                            }
                        }
                    }
                    if !failed {
                        self.syncPosition()
                    }
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                }
                
            case .Failure(let error):
                print(error)
                NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
            }
        }
    }
    func syncPosition() {
        BMWebRequest.get(url: getPositionsURL(), isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    var failed = false
                    if unwrappedJson.count > 0 {
                        for data in unwrappedJson.arrayValue {
                            let query = "INSERT OR REPLACE INTO Position (PositionID, PositionName) values (\"\(data["PositionID"].intValue)\", \"\(data["Name"].stringValue)\")"
                            do{
                                try Database().db.execute(query)
                            }catch let error {
                                failed = true
                                print(error.localizedDescription)
                                NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                            }
                        }
                    }
                    if !failed {
                        NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDB"), object: nil)
                    }
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
                }
            case .Failure(let error):
                print(error)
                NotificationCenter.default.post(name: NSNotification.Name("SyncNewProjectDBFailed"), object: nil)
            }
        }
    }
    
    func uploadImages() {
        if uploadImageNamesList.count > 0
        {
            let object = ["text": "Uploading Captured Photos, Please wait \(uploadCount) of \(uploadImageNamesList.count)", "progress": (Double(uploadCount) / Double(uploadImageNamesList.count)), "total": uploadImageNamesList.count] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "progressUpdated"), object: object)

            do {
                var imagepath = ""
                let imagepathurl = uploadImageNamesList[uploadCount].components(separatedBy: "/")
                if imagepathurl.count > 0 {
                    imagepath = imagepathurl.last!
                }
                if !imagepath.contains(".jpeg") && !imagepath.contains(".jpg") {
                    imagepath.append(".jpeg")
                }
                var strImageName = ""
                if storage_loadObject("useAWSImageUpload") != nil {
                    strImageName = String(format: "%@%@", storage_loadObject("useAWSImageUpload")!, imagepath )
                }else{
                    strImageName = String(format: "%@", imagepath )
                }
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURI = documentsURL.appendingPathComponent("CapturedPhotos/\(imagepath)")
                let data = try Data(contentsOf: fileURI)
                
                let manager = AFHTTPSessionManager()
                manager.responseSerializer = AFHTTPResponseSerializer()
                let parama = ["policy": policyBase64, "signature": signature, "AWSAccessKeyId": awsKey, "Content-Type": "image/jpeg", "key": strImageName, "acl": "public-read"]
                manager.post(s3URI, parameters: nil, constructingBodyWith: { (multipartFormdata) in
                    for key in parama.keys {
                        multipartFormdata.appendPart(withForm: ((parama[key])?.data(using: String.Encoding.utf8)!)!, name: key)
                    }
                    multipartFormdata.appendPart(withFileData: data, name: "file", fileName: strImageName, mimeType: "image/jpeg")
                }, progress: { (progress) in
                    print(progress.fractionCompleted)
                }, success: { (datatask, data) in
                    print(data)
                    
                    self.uploadCount = self.uploadCount + 1
                    if self.uploadCount != self.uploadImageNamesList.count
                    {
                        self.uploadImages();
                    }
                    else
                    {
                        self.uploadCount = 0;
                        self.updatePrejectPhoto()
                    }

                }) { (datatask, error) in
                    self.uploadCount = 0;
                    appDel.dismissProgressView()
                    print(error.localizedDescription)
                }
                
            }catch let e {
                print(e.localizedDescription as Any)
                self.uploadCount = 0;
                appDel.dismissProgressView()
            }
        }
        else if (isResetPhotoAvailable == true)
        {
            uploadCount = 0
            storage_saveObject("SYNC", "")
            appDel.dismissProgressView()
        }
        else
        {
            self.buildProjectPhotosQuery(Database.sharedInstance.projectsGlobalArray)
        }
        
    }

    func updatePrejectPhoto() {
        
        let query = "SELECT * FROM Photos WHERE STATUS in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" )"
        print("Projects: " + query)
        do {
            let stmt = try Database.sharedInstance.db.prepare(query)
            var datas:[[String: Any]] = []
            for row in stmt {
                var param: [String: Any] = [:]
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
                datas.append(param)
            }
            var jsonDatas: [[String: Any]] = []
            let device = UIDevice.current
            let uuid = device.identifierForVendor?.uuidString
            print(uuid as Any)
            let model = device.model
            let paltform = "iOS"
            let version = device.systemVersion
            for p in datas {
                var jsonData: [String: Any] = [:]
                jsonData["ProjectID"] = p["ProjectID"]
                jsonData["ItemID"] = p["ItemID"]
                jsonData["CategoryID"] = p["CategoryID"]
                jsonData["SectorID"] = p["SectorID"]
                jsonData["PositionID"] = p["PositionID"]
                jsonData["ProjectPhotoID"] = p["ProjectPhotoID"]
                jsonData["ItemName"] = p["ItemName"]
                jsonData["Description"] = p["Description"]
                jsonData["DeviceID"] = uuid
                jsonData["DeviceModel"] = model
                jsonData["DevicePlatform"] = paltform
                jsonData["DeviceVersion"] = version
                var imagepath = ""
                let imagepathurl = (p["CapturedImageName"] as! String).components(separatedBy: "/")
                if imagepathurl.count > 0 {
                    imagepath = imagepathurl.last!
                }
                jsonData["ImagePath"] = imagepath
                jsonData["TakenBy"] = p["TakenBy"]
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "M/dd/yyyy, hh:mm:ss a"
                let date = dateformatter.date(from: p["TakenDate"] as! String)
                jsonData["TakenDate"] = "/Date(\(Int((date?.timeIntervalSince1970)! * 1000)))/"
                jsonData["IsAdhoc"] = p["IsAdhoc"]
                jsonData["Latitude"] = p["Latitude"]
                jsonData["Longitude"] = p["Longitude"]
                jsonData["AdhocPhotoID"] = p["AdhocPhotoID"]
                jsonData["ApprovalStatus"] = p["ApprovalStatus"]
                jsonDatas.append(jsonData)
            }
            
            BMWebRequest.postPhotosArray(url: UpdateProjectPhotosURL(), params: jsonDatas, isHeader: false) { (result) in
                switch(result) {
                case .Success(let json):
                    if json as! Bool {
                        self.isResetPhotoAvailable = false
                        let query = "update Photos set Status=\"\(StatusEnum.UPLOADED.rawValue)\" where Status=\"\(StatusEnum.PICTAKEN.rawValue)\" "
                        let query2 = "update Photos set Status=\"\(StatusEnum.TAKEPIC.rawValue)\" where Status=\"\(StatusEnum.RESETPHOTO.rawValue)\" "
                        do{
                            try Database().db.execute(query)
                            try Database().db.execute(query2)
                        }catch let error {
                            print(error.localizedDescription)
                            storage_saveObject("SYNC", "")
                        }
                        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "PhotesUpdated")))
                        self.buildReferencePhotosQuery(Database.sharedInstance.projectsGlobalArray)
                    }else{
                        appDel.hideHUD()
                        storage_saveObject("SYNC", "")
                    }
                case .Failure(let error):
                    appDel.hideHUD()
                    storage_saveObject("SYNC", "")
                    print(error)
                }
            }

            
        }catch let error {
            print(error.localizedDescription)
            appDel.hideHUD()
            storage_saveObject("SYNC", "")
        }

    }
    
    func logtoFile(_ text: String) {
        let file = "closeoutlog.txt" //this is the file. we will write to and read from it
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
            
//            //reading
//            do {
//                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
//            }
//            catch {/* error handling here */}
        }

    }
}
