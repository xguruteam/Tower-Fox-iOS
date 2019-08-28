//
//  Database.swift
//  CloseOut
//
//  Created by cgc on 8/29/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import SQLite

enum StatusEnum: Int {
    case REJECTED = 0
    case TAKEPIC = 1
    case PICTAKEN = 2
    case UPLOADED = 3
    case APPROVED = 4
    case OUTOFSCOPE = 5
    case DELETEDPHOTO = 6
    case RESETPHOTO = 7
    case MISCELLANEOUS = 999
    //        "REJECTED"      : 0,    //Rejected Photo   --  Example Photo
    //        "TAKEPIC"       : 1,    //Take Photo      --  Example Photo
    //        "PICTAKEN"      : 2,    //Captured Photo   --  Captured Photo
    //        "UPLOADED"      : 3,    //Uploaded Photo  --  Captured Photo
    //        "APPROVED"      : 4,    //Approved Photo    --  Captured Photo
    //        "OUTOFSCOPE"    : 5,    // Out of Scope
    //        "DELETEDPHOTO"  : 6,    //Deleted Photo
    //        "RESETPHOTO"    : 7,    //Reset Photo/Delete Photo
    //        "MISCELLANEOUS" : 999
}
var IMAGE_LOCATION_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

public class Database {
    var categoriesStack:[String] = []
    var categoriesListStringArray:[String] = []
    var categoriesListNameArray:[String] = []
    var projectsGlobalArray:[String] = []
    var isFromBagroundSync = true
    var isFromProjects = true
    var isAdhocPhoto = false
    var _fileSystem:String?
    var _loggingFileSystem:String?
    var FILE_LOGGING_ENABLED = true
    var LOGGING_ENABLED = false
    var pushNotification:String?
    var isFromPushNotification = false
    var isPushNotificationSilentSync = false
    var isRLList = false
    var navigationStack: [NavigationStack] = []

    var db: Connection!
    var Projects = Table("Projects")
    var Categories = Table("Categories")
    var Photos = Table("Photos")
    var Sector = Table("Sector")
    var Position = Table("Position")
    
    var categories: [CategoryDisplayModel] = []
    public static let sharedInstance: Database = {
        let instance = Database()
        return instance
    }()

    init() {
        do {
            db = try Connection(AppData.getPath(fileName: "Towerfox.db"))
        }catch let error {
            print(error.localizedDescription)
        }
        self.createTable()
    }
    
    func initial() {
         categoriesStack = []
         categoriesListStringArray = []
         categoriesListNameArray = []
         projectsGlobalArray = []
         isFromBagroundSync = true
         isFromProjects = true
         isAdhocPhoto = false
         isFromPushNotification = false
         isPushNotificationSilentSync = false
         isRLList = false
         navigationStack = []

    }
    
    func createTable() {
        do {
            try db.execute("CREATE TABLE IF NOT EXISTS Projects (\"ProjectID\" VARCHAR PRIMARY KEY NOT NULL UNIQUE , \"ProjectName\" VARCHAR, \"CasperID\" VARCHAR, \"PaceID\" VARCHAR,\"Description\" VARCHAR, \"FirstName\" VARCHAR, \"LastName\" VARCHAR)")
            try db.execute("CREATE TABLE IF NOT EXISTS Categories (\"ProjectID\" VARCHAR NOT NULL , \"CategoryID\" VARCHAR, \"CategoryName\" VARCHAR, \"ParentCategoryID\" VARCHAR, \"ContainsSectorPosition\" BOOL, \"SortOrder\" INTEGER, PRIMARY KEY (\"ProjectID\", \"CategoryID\"))")
            try db.execute("CREATE TABLE IF NOT EXISTS Photos (\"ProjectPhotoID\" VARCHAR, \"ProjectID\" VARCHAR, \"CategoryID\" VARCHAR, \"ItemID\" VARCHAR, \"SectorID\" VARCHAR, \"PositionID\" VARCHAR, \"ItemName\" VARCHAR, \"Description\" VARCHAR, \"Comments\" VARCHAR, \"TakenBy\" VARCHAR, \"TakenDate\" VARCHAR, \"Status\" INTEGER, \"ReferenceImageName\" VARCHAR, \"CapturedImageName\" VARCHAR, \"Quantity\" VARCHAR, \"RequireSectorPosition\" BOOL, \"ParentCategoryID\" VARCHAR, \"Latitude\" VARCHAR, \"Longitude\" VARCHAR, \"IsAdhoc\" BOOL, \"SortOrder\" INTEGER, \"AdhocPhotoID\" VARCHAR PRIMARY KEY NOT NULL)")
            try db.execute("CREATE TABLE IF NOT EXISTS Sector (\"SectorID\" VARCHAR PRIMARY KEY NOT NULL, \"SectorName\" VARCHAR NOT NULL)")
            try db.execute("CREATE TABLE IF NOT EXISTS Position (\"PositionID\" VARCHAR PRIMARY KEY NOT NULL, \"PositionName\" VARCHAR NOT NULL)")
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func displayProjects(completionHandler: @escaping([ProjectDisplayModel]) -> Void) {
        let query = "SELECT p.*, (select count(*) from Photos i1 where i1.projectid=p.projectid) Total, (select count(*) from Photos i1 where status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and i1.projectid=p.projectid) requiredCount, (select count(*) from Photos i1 where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and i1.projectid=p.projectid) takenCount, (select count(*) from Photos i1 where status = \"\(StatusEnum.APPROVED.rawValue)\" and i1.projectid=p.projectid) ApprovedCount, (select count(*) from Photos i1 where status = \"\(StatusEnum.REJECTED.rawValue)\" and i1.projectid=p.projectid) rejectedCount, (select count(*) from Photos i1 where status = \"\(StatusEnum.OUTOFSCOPE.rawValue)\" and i1.projectid=p.projectid) OutOfScopeCount, ROUND(CAST((select count(*) from Photos i1 where status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and i1.projectid=p.projectid) as float)*100/(select count(*) from Photos i1 where i1.projectid=p.projectid), 2) Required, ROUND(CAST((select count(*) from Photos i1 where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and i1.projectid=p.projectid) as float)*100/(select count(*) from Photos i1 where i1.projectid=p.projectid), 2) Taken, ROUND(CAST((select count(*) from Photos i1 where status = \"\(StatusEnum.APPROVED.rawValue)\" and i1.projectid=p.projectid) as float)*100/(select count(*) from Photos i1 where i1.projectid=p.projectid), 2) Approved, ROUND(CAST((select count(*) from Photos i1 where status = \"\(StatusEnum.REJECTED.rawValue)\" and i1.projectid=p.projectid) as float)*100/(select count(*) from Photos i1 where i1.projectid=p.projectid), 2) Rejected FROM projects p left outer join Photos i on p.projectid=i.projectid group by p.projectid"
            print("Projects: " + query)
        do {
            let stmt = try db.prepare(query)
            var projectDisplayModels: [ProjectDisplayModel] = []
            for row in stmt {
                var param: [String: Any] = [:]
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : "null"
                }
                let project = ProjectDisplayModel(with: param)
                projectDisplayModels.append(project)
                if !(self.projectsGlobalArray.contains(project.ProjectID)) {
                    projectsGlobalArray.append(project.ProjectID)
                }
            }
            projectDisplayModels.sort { (first, second) -> Bool in
                let id1 = first.ProjectID!
                let id2 = second.ProjectID!
                let result = id1.compare(id2)
                return result == .orderedAscending
                
            }
            completionHandler(projectDisplayModels)

        }catch let error {
            print(error.localizedDescription)
            completionHandler([])
        }
    }

    func displayRejects(completionHandler: @escaping([RejectDisplayModel]) -> Void) {
        let query = "Select distinct(itemid) AS Sample,  CategoryName, P.* from photos P, categories C where  P.status = \"\(StatusEnum.REJECTED.rawValue)\" and P.categoryid=C.categoryID  Union All Select distinct(itemid) AS Sample, \"\" AS CategoryName, * from Photos where Status = \"\(StatusEnum.REJECTED.rawValue)\" and CategoryId = 0 Order by P.ProjectID, P.CategoryID, P.SortOrder"
        print("Projects: " + query)
        do {
            let stmt = try db.prepare(query)
            var rejectDisplayModels: [RejectDisplayModel] = []
            for row in stmt {
                var param: [String: Any] = [:]
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : ""
                }
                let reject = RejectDisplayModel(with: param)
                rejectDisplayModels.append(reject)
            }
            completionHandler(rejectDisplayModels)
            
        }catch let error {
            print(error.localizedDescription)
            completionHandler([])
        }
    }
    
    
    func uploadData() {
        Sync.sharedInstance.uploadDataToServer()
    }
    
    func getHeaderCount(completionHandler: @escaping([String: Any]) -> Void) {
        var query = "";
        if navigationStack.count < 1 {
          ApiRequest.logOnServer(message: "Invalid Navigation Stack Depth.")
            completionHandler([:])
            return
        }
        
        let jsonObj = navigationStack[navigationStack.count - 1]
        if(jsonObj.SectorID == "0" || jsonObj.SectorID == "99999")
        {
            query = "SELECT Count(*) Total, (Select count(*) from Photos P where status  in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Required, (Select count(*) from Photos P where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Taken, (Select count(*) from Photos P where status = \"\(StatusEnum.APPROVED.rawValue)\" and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Approved, (Select count(*) from Photos P where status = \"\(StatusEnum.REJECTED.rawValue)\" and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Rejected FROM Photos P where P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\" and Status Not in (\"\(StatusEnum.OUTOFSCOPE.rawValue)\", \"\(StatusEnum.MISCELLANEOUS.rawValue)\")"
        }
        else if( (jsonObj.SectorID != "0" || jsonObj.SectorID == "99999") && (jsonObj.PositionID == "0" || jsonObj.PositionID == "99999"))
        {
            query = "SELECT Count(Distinct(ItemID)) Total, (Select count(*) from Photos P where status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and (P.SectorID = \"\(jsonObj.SectorID!)\" OR P.SectorID = \"99999\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Required, (Select count(*) from Photos P where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and P.SectorID = \"\(jsonObj.SectorID!)\" and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Taken, (Select count(*) from Photos P where status = \"\(StatusEnum.APPROVED.rawValue)\" and P.SectorID = \"\(jsonObj.SectorID!)\" and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Approved, (Select count(*) from Photos P where status = \"\(StatusEnum.REJECTED.rawValue)\" and (P.SectorID = \"\(jsonObj.SectorID!)\" OR P.SectorID = \"99999\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Rejected FROM Photos P where (P.SectorID = \"\(jsonObj.SectorID!)\" OR P.SectorID = \"99999\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\" and Status Not in (\"\(StatusEnum.OUTOFSCOPE.rawValue)\", \"\(StatusEnum.MISCELLANEOUS.rawValue)\")"
        }
        else if((jsonObj.SectorID != "0" || jsonObj.SectorID == "99999") && (jsonObj.PositionID != "0" || jsonObj.PositionID == "99999"))
        {
            query = "SELECT Count(Distinct(ItemID)) Total, (Select count(*) from Photos P where status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and (P.PositionID = \"\(jsonObj.PositionID!)\" OR P.PositionID = \"99999\") and (P.SectorID = \"\(jsonObj.SectorID!)\" OR P.SectorID = \"99999\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Required, (Select count(Distinct(ItemID)) from Photos P where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and P.PositionID = \"\(jsonObj.PositionID!)\" and P.SectorID = \"\(jsonObj.SectorID!)\" and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Taken, (Select count(Distinct(ItemID)) from Photos P where status = \"\(StatusEnum.APPROVED.rawValue)\" and P.PositionID = \"\(jsonObj.PositionID!)\" and P.SectorID = \"\(jsonObj.SectorID!)\" and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Approved, (Select count(Distinct(ItemID)) from Photos P where status = \"\(StatusEnum.REJECTED.rawValue)\" and (P.PositionID = \"\(jsonObj.PositionID!)\" OR P.PositionID = \"99999\") and (P.SectorID = \"\(jsonObj.SectorID!)\" OR P.SectorID = \"99999\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\") Rejected FROM Photos P where (P.PositionID = \"\(jsonObj.PositionID!)\" OR P.PositionID = \"99999\") and (P.SectorID = \"\(jsonObj.SectorID!)\" OR P.SectorID = \"99999\") and P.ParentCategoryID like \"%,\(jsonObj.ParentID!),%\" and ProjectID = \"\(jsonObj.ProjectID!)\" and Status Not in (\"\(StatusEnum.OUTOFSCOPE.rawValue)\", \"\(StatusEnum.MISCELLANEOUS.rawValue)\")"
        }
        print("Projects: " + query)
        do {
            let stmt = try db.prepare(query)
            var param: [String: Any] = [:]
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
                var takenPercent = 0.0
                var approvedPercent = 0.0
                var rejectedPercent = 0.0
                if (param["Total"] as! Int64) > 0 {
                    takenPercent = Double(((param["Taken"] as! Int64) * 100) / (param["Total"] as! Int64))
                    approvedPercent = Double(((param["Approved"] as! Int64) * 100) / (param["Total"] as! Int64))
                    rejectedPercent = Double(((param["Rejected"] as! Int64) * 100) / (param["Total"] as! Int64))
                }
                storage_saveObject("Required", Int((param["Total"] as! Int64) - (param["Taken"] as! Int64) - (param["Rejected"] as! Int64) - (param["Approved"] as! Int64)))
                storage_saveObject("Taken", Int(param["Taken"] as! Int64))
                storage_saveObject("Rejected", Int(param["Rejected"] as! Int64))
                storage_saveObject("Approved", Int(param["Approved"] as! Int64))
                storage_saveObject("TakenPercent", takenPercent)
                storage_saveObject("ApprovedPercent", approvedPercent)
                storage_saveObject("RejectedPercent", rejectedPercent)

            }
            completionHandler(param)
            
        }catch let error {
            print(error.localizedDescription)
            completionHandler([:])
        }

    }
    
    func getCategoriesList(completionHandler: @escaping([CategoryDisplayModel]) -> Void) {
        var query = ""
        let check1 = (storage_loadObject("RequireSectorPosition") == "1")
        let check2 = (storage_loadObject("SectorID") == "0" || storage_loadObject("SectorID") == "99999")
        let check3 = (storage_loadObject("PositionID") == "0" || storage_loadObject("PositionID") == "99999")
        if(storage_loadObject("ParentID") == "0" || storage_loadObject("RequireSectorPosition") == "0")
        {
            query = "Select 0 AS TempSort, Null AS PCategoryID, Null AS ProjectID, Null AS CategoryName, RequireSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status, Null AS IParentCategoryID, ItemID AS IItemID, ProjectID AS IProjectID, CategoryID AS ICategoryID, ItemName AS ItemName , Description AS IDescription, ReferenceImageName AS IReferenceImageName, CapturedImageName AS ICapturedImageName, TakenBy AS ITakenBy, TakenDate AS ITakenDate, CASE Status WHEN 7 THEN 1 ELSE Status END AS IStatus, Comments AS IComments, SectorID AS ISectorID, PositionID AS IPositionID, 'Items' AS Type, SortOrder, AdhocPhotoID AS AdhocPhotoID from Photos where CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" Union All Select 1 AS TempSort, CategoryID AS PCategoryID, ProjectID AS PProjectID, CategoryName AS CategoryName, ContainsSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status, ParentCategoryID AS ParentCategoryID, Null AS ItemID, Null AS ProjectID, Null AS CategoryID, Null AS ItemName , Null AS Description, Null AS ReferenceImageName, Null AS CapturedImageName, Null AS TakenBy, Null AS TakenDate, Null AS IStatus, Null AS Comments, \"0\" AS ISectorID, \"0\" AS IPositionID, 'Category' AS Type, SortOrder, Null AS AdhocPhotoID from Categories where ParentCategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" order by TempSort, IStatus, SortOrder";
        }
        else if check1 && check2 && check3
        {
            query = "Select 1 AS TempSort, CategoryID AS PCategoryID, ProjectID AS PProjectID, CategoryName AS CategoryName, ContainsSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status, ParentCategoryID AS ParentCategoryID, Null AS ItemID,Null AS ProjectID, Null AS CategoryID, Null AS ItemName , Null AS Description, Null AS ReferenceImageName, Null AS CapturedImageName, Null AS TakenBy, Null AS TakenDate, Null AS IStatus, Null AS Comments, \"0\" AS ISectorID, \"0\" AS IPositionID, 'Category' AS Type, SortOrder, Null AS AdhocPhotoID from Categories where ParentCategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" Union All Select 2 AS TempSort, Null AS PCategoryID, Null AS ProjectID, SectorName AS CategoryName, Null AS RequireSectorPosition, Null AS Description, Null AS IStatus, Null AS IParentCategoryID, Null AS IItemID, Null AS IProjectID, Null AS ICategoryID, Null AS IItemName , Null AS IDescription, Null AS IReferenceImageName, Null AS ICapturedImageName, Null AS ITakenBy, Null AS ITakenDate, Null AS IStatus, Null AS IComments, SectorID AS ISectorID, \"0\" AS IPositionID, 'Sector' AS Type, Null AS SortOrder, Null AS AdhocPhotoID from Sector Union All Select 0 AS TempSort, Null AS PCategoryID, Null AS ProjectID, Null AS CategoryName, RequireSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status, Null AS IParentCategoryID, ItemID AS ItemID, ProjectID AS IProjectID, CategoryID AS ICategoryID, ItemName AS ItemName , Description AS IDescription,  ReferenceImageName AS IReferenceImageName, CapturedImageName AS ICapturedImageName, TakenBy AS ITakenBy, TakenDate AS ITakenDate, CASE Status WHEN 7 THEN 1 ELSE Status END AS IStatus, Comments AS IComments, SectorID AS ISectorID, PositionID AS IPositionID, 'Items' AS Type, SortOrder, AdhocPhotoID AS AdhocPhotoID from Photos where CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" and SectorID = \"0\" and PositionID = \"0\" order by TempSort, IStatus, SortOrder";
        }
        else if ((storage_loadObject("SectorID") != "0" || storage_loadObject("SectorID") != "99999") && (storage_loadObject("PositionID") == "0" || storage_loadObject("PositionID") == "99999"))
        {
            query = "Select 0 AS TempSort, Null AS PCategoryID, Null AS ProjectID, Null AS CategoryName, RequireSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status, Null AS IParentCategoryID, ItemID AS ItemID, ProjectID AS IProjectID, CategoryID AS ICategoryID, ItemName AS ItemName , Description AS IDescription, ReferenceImageName AS IReferenceImageName, CapturedImageName AS ICapturedImageName, TakenBy AS ITakenBy, TakenDate AS ITakenDate, CASE Status WHEN 7 THEN 1 ELSE Status END AS IStatus, Comments AS IComments, SectorID AS ISectorID, PositionID AS IPositionID, 'Items' AS Type, SortOrder, AdhocPhotoID AS AdhocPhotoID from Photos where CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" and SectorID = \"\(storage_loadObject("SectorID")!)\" and PositionID = \"0\" Union All Select 1 AS TempSort, Null AS CategoryID, Null AS ProjectID, PositionName AS CategoryName, Null AS RequireSectorPosition, Null AS Description, Null AS IStatus,  Null AS IParentCategoryID, Null AS IItemID, Null AS IProjectID, Null AS ICategoryID, Null AS IItemName , Null AS IDescription, Null AS IReferenceImageName,  Null AS ICapturedImageName, Null AS ITakenBy, Null AS ITakenDate, Null AS IStatus, Null AS IComments, \"0\" AS ISectorID, PositionID AS IPositionID, 'Position' AS Type, Null AS SortOrder, Null AS AdhocPhotoID from Position order by TempSort, IStatus, SortOrder"
        }
        else if ((storage_loadObject("SectorID") != "0" || storage_loadObject("SectorID") != "99999") && (storage_loadObject("PositionID") != "0" || storage_loadObject("PositionID") != "99999"))
        {
            query = "Select Distinct ItemID AS ItemID, Null AS PCategoryID, Null AS ProjectID, Null AS CategoryName, RequireSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status, Null AS IParentCategoryID,  ProjectID AS IProjectID, CategoryID AS ICategoryID, ItemName AS ItemName , Description AS IDescription, ReferenceImageName AS IReferenceImageName, CapturedImageName AS ICapturedImageName, TakenBy AS ITakenBy, TakenDate AS ITakenDate, CASE Status WHEN 7 THEN 1 ELSE Status END AS IStatus, Comments AS IComments, SectorID AS ISectorID, PositionID AS IPositionID, 'Items' AS Type, SortOrder, min(AdhocPhotoID) AS AdhocPhotoID from Photos where CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" and (SectorID = \"\(storage_loadObject("SectorID")!)\") and (PositionID = \"\(storage_loadObject("PositionID")!)\") group by ItemID union all Select Distinct ItemID AS ItemID, Null AS PCategoryID, Null AS ProjectID, Null AS CategoryName, RequireSectorPosition AS RequireSectorPosition, Null AS Description, Null AS Status,  Null AS IParentCategoryID,  ProjectID AS IProjectID, CategoryID AS ICategoryID, ItemName AS ItemName , Description AS IDescription,  ReferenceImageName AS IReferenceImageName, CapturedImageName AS ICapturedImageName, TakenBy AS ITakenBy, TakenDate AS ITakenDate, Status AS IStatus,  Comments AS IComments, SectorID AS ISectorID, PositionID AS IPositionID, 'Items' AS Type, SortOrder, min(AdhocPhotoID) AS AdhocPhotoID from Photos where  ICategoryID = \"\(storage_loadObject("ParentID")!)\" and IProjectID = \"\(storage_loadObject("ProjectID")!)\"  and (ISectorID = \"99999\") and (IPositionID = \"99999\") and ItemId Not in (Select Distinct ItemID from Photos where ProjectID= \"\(storage_loadObject("ProjectID")!)\" and CategoryID= \"\(storage_loadObject("ParentID")!)\" and SectorID = \"\(storage_loadObject("SectorID")!)\" and PositionID= \"\(storage_loadObject("PositionID")!)\") group by ItemID order by IStatus, SortOrder"
        }
        print("Projects: " + query)
        self.categories.removeAll()
        do {
            let stmt = try db.prepare(query)
            for row in stmt {
                var param: [String: Any] = [:]
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
                let category = CategoryDisplayModel(with: param)
                var totalCount = 0
                var requiredCount = 0
                var takenCount = 0
                var approvedCount = 0
                var rejectedCount = 0
                var takenPercent = 0.0
                var approvedPercent = 0.0
                var rejectedPercent = 0.0
                var query = ""
                if category.ISectorID != "0" && category.ISectorID != ""{
                    let catID = category.ISectorID
                    query = "SELECT Count(Distinct(ItemID)) Total, SectorID, (Select count(*) from Photos P where status in (\"\(StatusEnum.TAKEPIC.rawValue)\" , \"\(StatusEnum.RESETPHOTO.rawValue)\") and (P.SectorID = \"\(catID)\" or P.SectorID = \"99999\") and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Required, (Select count(*) from Photos P where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and P.SectorID = \"\(catID)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Taken, (Select count(*) from Photos P where status = \"\(StatusEnum.APPROVED.rawValue)\" and P.SectorID = \"\(catID)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Approved, (Select count(*) from Photos P where status = \"\(StatusEnum.REJECTED.rawValue)\" and (P.SectorID = \"\(catID)\" or P.SectorID = \"99999\") and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Rejected FROM Photos P where (P.SectorID = \"\(catID)\" or P.SectorID = \"99999\") and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" and Status Not in (\"\(StatusEnum.OUTOFSCOPE.rawValue)\", \"\(StatusEnum.MISCELLANEOUS.rawValue)\")";
                } else if category.IPositionID != "0" && category.IPositionID != "" {
                    let catID = category.IPositionID
                    query = "SELECT Count(Distinct(ItemID)) Total, PositionID, (Select count(*) from Photos P where status in (\"\(StatusEnum.TAKEPIC.rawValue)\" , \"\(StatusEnum.RESETPHOTO.rawValue)\") and (P.PositionID = \"\(catID)\" or P.PositionID = \"99999\") and P.SectorID = \"\(storage_loadObject("SectorID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Required, (Select count(Distinct(ItemID)) from Photos P where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and P.PositionID = \"\(catID)\" and P.SectorID = \"\(storage_loadObject("SectorID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Taken, (Select count(Distinct(ItemID)) from Photos P where status = \"\(StatusEnum.APPROVED.rawValue)\" and P.PositionID = \"\(catID)\" and P.SectorID = \"\(storage_loadObject("SectorID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Approved, (Select count(Distinct(ItemID)) from Photos P where status = \"\(StatusEnum.REJECTED.rawValue)\" and (P.PositionID = \"\(catID)\" or P.PositionID = \"99999\") and (P.SectorID = \"\(storage_loadObject("SectorID")!)\" or P.SectorID = \"99999\") and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Rejected FROM Photos P where (P.PositionID = \"\(catID)\" or P.PositionID = \"99999\") and (P.SectorID = \"\(storage_loadObject("SectorID")!)\" or P.SectorID = \"99999\") and CategoryID = \"\(storage_loadObject("ParentID")!)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" and Status Not in (\"\(StatusEnum.OUTOFSCOPE.rawValue)\", \"\(StatusEnum.MISCELLANEOUS.rawValue)\")"
                }else {
                    var catID = category.PCategoryID
                    if catID == "" || catID == "null"{
                        catID = storage_loadObject("ParentID")!
                    }
                    query = "SELECT Count(*) Total, (Select count(*) from Photos P where status in (\"\(StatusEnum.TAKEPIC.rawValue)\" , \"\(StatusEnum.RESETPHOTO.rawValue)\") and P.ParentCategoryID like \"%,\(catID),%\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Required, (Select count(*) from Photos P where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and P.ParentCategoryID like \"%,\(catID),%\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Taken, (Select count(*) from Photos P where status = \"\(StatusEnum.APPROVED.rawValue)\" and P.ParentCategoryID like \"%,\(catID),%\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Approved, (Select count(*) from Photos P where status = \"\(StatusEnum.REJECTED.rawValue)\" and P.ParentCategoryID like \"%,\(catID),%\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") Rejected FROM Photos P where P.ParentCategoryID like \"%,\(catID),%\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\" and Status Not in (\"\(StatusEnum.OUTOFSCOPE.rawValue)\", \"\(StatusEnum.MISCELLANEOUS.rawValue)\")"
                }
                print("Projects: " + query)
                let stmt1 = try Database.sharedInstance.db.prepare(query)
                for row1 in stmt1 {
                    var param1: [String: Any] = [:]
                    for (index1, name1) in stmt1.columnNames.enumerated() {
                        print ("\(name1):\(row1[index1] != nil ? row1[index1]! : "null")")
                        // id: Optional(1), email: Optional("alice@mac.com")
                        param1[name1] = row1[index1] != nil ? row1[index1]! : 0
                    }
                    totalCount = Int(param1["Total"] as! Int64)
                    takenCount = Int(param1["Taken"] as! Int64)
                    approvedCount = Int(param1["Approved"] as! Int64)
                    rejectedCount = Int(param1["Rejected"] as! Int64)
                    requiredCount = totalCount - approvedCount - takenCount - rejectedCount
                    if (totalCount > 0)
                    {
                        takenPercent = Double((takenCount * 100) / totalCount)
                        approvedPercent = Double((approvedCount * 100) / totalCount)
                        rejectedPercent = Double((rejectedCount * 100) / totalCount)
                    }
                    else
                    {
                        takenPercent = 0;
                        approvedPercent = 0;
                        rejectedPercent = 0;
                    }
                    
                }
                category._taken = takenCount
                category._approved = approvedCount
                category._approvedPercent = approvedPercent
                category._rejected = rejectedCount
                category._rejectedPercent = rejectedPercent
                category._takenPercent = takenPercent
                category._required = requiredCount
                if category.type == "Items" {
                    self.categories.append(category)
                }else{
                    if category._required != 0 || category._rejected != 0 || category._taken != 0 || category._approved != 0{
                        self.categories.append(category)
                    }
                }

            }
            
            var (rejectedList, todoList, pendingList, approvedList, categoryList) = self.categories.reduce(([], [], [], [], [])) { (result, model) -> ([CategoryDisplayModel], [CategoryDisplayModel], [CategoryDisplayModel], [CategoryDisplayModel], [CategoryDisplayModel]) in
                var (rejectedList, todoList, pendingList, approvedList, categoryList) = result
                if model.type == "Items" {
                    if model.IStatus == StatusEnum.TAKEPIC.rawValue || model.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        todoList.append(model)
                    }else if model.IStatus == StatusEnum.PICTAKEN.rawValue {
                        pendingList.append(model)
                    }else if model.IStatus == StatusEnum.UPLOADED.rawValue || model.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        pendingList.append(model)
                    }else if model.IStatus == StatusEnum.APPROVED.rawValue || model.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        approvedList.append(model)
                    }else if model.IStatus == StatusEnum.REJECTED.rawValue || model.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        rejectedList.append(model)
                    }
                } else {
                    if model._required != 0 || model._rejected != 0 || model._taken != 0 || model._approved != 0{
                        categoryList.append(model)
                    }
                }
                return (rejectedList, todoList, pendingList, approvedList, categoryList)
            }
            
            let comparator: (CategoryDisplayModel, CategoryDisplayModel) -> Bool = { (first, second) -> Bool in
                let name1 = first.ItemName
                let name2 = second.ItemName
                let result = name1.compare(name2)
                return result == .orderedAscending
            }
            
            rejectedList.sort(by: comparator)
            todoList.sort(by: comparator)
            pendingList.sort(by: comparator)
            approvedList.sort(by: comparator)

            categoryList.sort { (first, second) -> Bool in
                let name1 = first.CategoryName
                let name2 = second.CategoryName
                let result = name1.compare(name2)
                return result == .orderedAscending
            }
            
            self.categories = []
            self.categories.append(contentsOf: rejectedList)
            self.categories.append(contentsOf: todoList)
            self.categories.append(contentsOf: pendingList)
            self.categories.append(contentsOf: approvedList)
            self.categories.append(contentsOf: categoryList)
            
            completionHandler(self.categories)
            
        }catch let error {
            print(error.localizedDescription)
            completionHandler(self.categories)
        }

    }
    
    func getPhotoRemainingCount(completionHandler: @escaping([String: Any]) -> Void) {
        let query = "SELECT p.*, (select count(*) from Photos i1 where ProjectID = \"\(storage_loadObject("ProjectID")!)\") Total, (select count(*) from Photos i1 where status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and ProjectID = \"\(storage_loadObject("ProjectID")!)\") requiredCount, (select count(*) from Photos i1 where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and ProjectID = \"\(storage_loadObject("ProjectID")!)\") takenCount, (select count(*) from Photos i1 where status = \"\(StatusEnum.APPROVED.rawValue)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") ApprovedCount, (select count(*) from Photos i1 where status = \"\(StatusEnum.REJECTED.rawValue)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") rejectedCount, (select count(*) from Photos i1 where status = \"\(StatusEnum.OUTOFSCOPE.rawValue)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") OutOfScopeCount, ROUND(CAST((select count(*) from Photos i1 where status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ) and ProjectID = \"\(storage_loadObject("ProjectID")!)\") as float)*100/(select count(*) from Photos i1 where ProjectID = \"\(storage_loadObject("ProjectID")!)\"), 2) Required, ROUND(CAST((select count(*) from Photos i1 where status in (\"\(StatusEnum.PICTAKEN.rawValue)\", \"\(StatusEnum.UPLOADED.rawValue)\") and ProjectID = \"\(storage_loadObject("ProjectID")!)\") as float)*100/(select count(*) from Photos i1 where ProjectID = \"\(storage_loadObject("ProjectID")!)\"), 2) Taken, ROUND(CAST((select count(*) from Photos i1 where status = \"\(StatusEnum.APPROVED.rawValue)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") as float)*100/(select count(*) from Photos i1 where ProjectID = \"\(storage_loadObject("ProjectID")!)\"), 2) Approved, ROUND(CAST((select count(*) from Photos i1 where status = \"\(StatusEnum.REJECTED.rawValue)\" and ProjectID = \"\(storage_loadObject("ProjectID")!)\") as float)*100/(select count(*) from Photos i1 where ProjectID = \"\(storage_loadObject("ProjectID")!)\"), 2) Rejected FROM projects p where ProjectID = \"\(storage_loadObject("ProjectID")!)\""
        print("Projects: " + query)
        do {
            let stmt = try db.prepare(query)
            var param: [String: Any] = [:]
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
            }
            storage_saveObject("ProjectRequiredCount", param["requiredCount"] as Any)
            storage_saveObject("ProjectRejectedCount", param["rejectedCount"] as Any)
            storage_saveObject("ProjectOutOfScopeCount", param["OutOfScopeCount"] as Any)
            
            completionHandler(param)
            
        }catch let error {
            print(error.localizedDescription)
            completionHandler([:])
        }

    }
    
    func getPhotoDetail(completionHandler: @escaping([String: Any]) -> Void) {
        let query = "Select * from Photos where AdhocPhotoID = \"\(storage_loadObject("AdhocPhotoID")!)\""
        print("Projects: " + query)
        do {
            let stmt = try db.prepare(query)
            var param: [String: Any] = [:]
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
            }
            completionHandler(param)
            
        }catch let error {
            print(error.localizedDescription)
            completionHandler([:])
        }
    }
    
    func cleanDBQuery(completionHandler: @escaping()->Void)
    {
        do {
            try db.execute("DELETE FROM Projects")
            try db.execute("DELETE FROM Categories")
            try db.execute("DELETE FROM Photos")
            try db.execute("DELETE FROM Sector")
            try db.execute("DELETE FROM Position")
            completionHandler()
        }catch let error {
            print(error.localizedDescription)
            completionHandler()
        }
    }

    
    func deleteProject(completionHandler: @escaping() -> Void){
        var index = -1
        for i in 0..<projectsGlobalArray.count {
            if projectsGlobalArray[i] == storage_loadObject("DeleteProjectID") {
                index = i
            }
        }
        if index > -1 {
            self.projectsGlobalArray.remove(at: index)
            storage_removeItem(storage_loadObject("DeleteProjectID")!)
        }
        
        let query1 = "DELETE FROM Projects WHERE ProjectID = \"\(storage_loadObject("DeleteProjectID")!)\""
        let query2 = "DELETE FROM Categories WHERE ProjectID = \"\(storage_loadObject("DeleteProjectID")!)\""
        let query3 = "DELETE FROM Photos WHERE ProjectID = \"\(storage_loadObject("DeleteProjectID")!)\""
        do {
            try db.execute(query1)
            try db.execute(query2)
            try db.execute(query3)
            completionHandler()
        }catch let error {
            print(error.localizedDescription)
            completionHandler()
        }

    }
    
    func updateImageTakenData( completionHandler: @escaping(Bool)->Void) {
        let query = "Update Photos set CapturedImageName=\"\(storage_loadObject("ImageName")!)\", Status=\"\(StatusEnum.PICTAKEN.rawValue)\", Longitude=\"\(storage_loadObject("Longitude")!)\", Latitude=\"\(storage_loadObject("Latitude")!)\", TakenBy=\"\(storage_loadObject("UserName")!)\", TakenDate=\"\(storage_loadObject("TakenDate")!)\", SectorID=\"\(storage_loadObject("SectorID")!)\", PositionID=\"\(storage_loadObject("PositionID")!)\" where AdhocPhotoID = \"\(storage_loadObject("AdhocPhotoID")!)\""
        do{
            try db.execute(query)
            completionHandler(true)
        }catch let error {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
    
    func insertAdhocPhotoDataDB(completionHandler: @escaping(Bool)->Void) {
        var parentCategoryID = ","
        for i in 0..<self.navigationStack.count
        {
            if (i != 0) && (i != self.navigationStack.count)
            {
                let jsonObj = navigationStack[i]
                parentCategoryID = String(format: "%@,%@", parentCategoryID, jsonObj.ParentID)
                //console.log("Location: " + location + "CategoryName: " + jsonObj.CategoryName);
            }
        }
        let query =  "INSERT INTO Photos (ProjectPhotoID, ProjectID, CategoryID, ItemID, SectorID, PositionID, ItemName, Description, TakenBy, TakenDate, Status, CapturedImageName, Quantity, Latitude, Longitude, IsAdhoc, AdhocPhotoID, ParentCategoryID) values (\"0\", \"\(storage_loadObject("ProjectID")!)\", \"\(storage_loadObject("ParentID")!)\", \"0\", \"\(storage_loadObject("SectorID")!)\", \"\(storage_loadObject("PositionID")!)\", \"\(storage_loadObject("ItemName")!)\", \"\(storage_loadObject("Description")!)\", \"\(storage_loadObject("UserName")!)\", \"\(storage_loadObject("TakenDate")!)\", \"\(StatusEnum.PICTAKEN.rawValue)\",\"\(storage_loadObject("ImageName")!)\", \"1\", \"\(storage_loadObject("Latitude")!)\", \"\(storage_loadObject("Longitude")!)\", \"true\", \"\(guid())\", \"\(parentCategoryID)\" )"
        do{
            try db.execute(query)
            completionHandler(true)
        }catch let error {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
    
    func getNextItemToDisplay(completionHandler: @escaping([String: Any]) -> Void) {
        var query = "";
        if(Int(storage_loadObject("SectorID")!)! > 0)
        {
            query = "select DISTINCT(ItemID) AS ItemID, AdhocPhotoID, Status, ItemName from photos where ProjectID = \"\(storage_loadObject("ProjectID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and (SectorID = \"99999\") and (PositionID = \"99999\") and Status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ,\"\(StatusEnum.REJECTED.rawValue)\")  and ItemID Not in (Select Distinct ItemID from Photos where ProjectID = \"\(storage_loadObject("ProjectID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and  SectorID = \"\(storage_loadObject("SectorID")!)\" and PositionID = \"\(storage_loadObject("PositionID")!)\") order by SortOrder"
            print("Projects: " + query)
        }
        else
        {
            query = "select ItemID, AdhocPhotoID, Status, ItemName from photos where ProjectID = \"\(storage_loadObject("ProjectID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and (SectorID = \"\(storage_loadObject("SectorID")!)\") and (PositionID = \"\(storage_loadObject("PositionID")!)\") and Status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ,\"\(StatusEnum.REJECTED.rawValue)\") order by SortOrder"
        }
        
        do {
            let stmt = try db.prepare(query)
            var paramArray: [[String: Any]] = []
            var param: [String: Any] = [:]
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    param[name] = row[index] != nil ? row[index]! : 0
                }
                paramArray.append(param)
            }
            
            paramArray.sort { (param1, param2) -> Bool in
                let status1 = Int(param1["Status"] as! Int64)
                let status2 = Int(param2["Status"] as! Int64)
                if status1 < status2 { return true }
                else if status1 > status2 { return false }
                
                let name1 = param1["ItemName"] as! String
                let name2 = param2["ItemName"] as! String
                let result = name1.compare(name2)
                return result == .orderedAscending
            }
            
            
            if paramArray.count > 0 {
                if let itemId = storage_loadObject("ItemID") {
                    let searched = paramArray.firstIndex { (param) -> Bool in
                        if let pitemId = param["ItemID"] as? String, pitemId == itemId {
                            return true
                        }
                        return false
                    }
                    
                    if let _ = searched {
                        if paramArray.count == 1 {
                            param = [:]
                        } else {
                            let index = Int(searched!)
                            if index == paramArray.count - 1 {
                                param = paramArray[0]
                            } else {
                                param = paramArray[index + 1]
                            }
                        }
                    } else {
                        param = paramArray[0]
                    }
                } else {
                    param = paramArray[0]
                }
            } else {
                param = [:]
            }
            if param.count > 0 {
                storage_saveObject("ItemID", param["ItemID"] as! String)
                storage_saveObject("AdhocPhotoID", param["AdhocPhotoID"] as! String)
            }
            completionHandler(param)
            
        }catch let error {
            print(error.localizedDescription)
            completionHandler([:])
        }
    }
    
    func getItemsCountInSelectedCategory(completionHandler: @escaping([String: Any]) -> Void) {
        var query = "";
        if Int(storage_loadObject("SectorID")!)! > 0
        {
            
            query = "select count( Distinct (ItemID)) AS ItemsCount, ItemID from photos where ProjectID = \"\(storage_loadObject("ProjectID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and  SectorID = \"99999\" and  PositionID = \"99999\"  and Status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ,\"\(StatusEnum.REJECTED.rawValue)\") and ItemId Not in (Select Distinct ItemID from Photos where ProjectID = \"\(storage_loadObject("ProjectID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and  SectorID = \"\(storage_loadObject("SectorID")!)\" and PositionID = \"\(storage_loadObject("PositionID")!)\")"
            do {
                let stmt = try db.prepare(query)
                var param: [String: Any] = [:]
                for row in stmt {
                    for (index, name) in stmt.columnNames.enumerated() {
                        print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                        // id: Optional(1), email: Optional("alice@mac.com")
                        param[name] = row[index] != nil ? row[index]! : 0
                    }
                }
                storage_saveObject("ItemsCount", param["ItemsCount"] as! Int64)
                storage_saveObject("ItemsCountItemID", param["ItemID"])
                completionHandler(param)
                
            }catch let error {
                print(error.localizedDescription)
                completionHandler([:])
            }
        }
        else
        {
            query = "select count(ItemID) AS ItemsCount, ItemID, AdhocPhotoID from photos where ProjectID = \"\(storage_loadObject("ProjectID")!)\" and CategoryID = \"\(storage_loadObject("ParentID")!)\" and (SectorID = \"\(storage_loadObject("SectorID")!)\") and (PositionID = \"\(storage_loadObject("PositionID")!)\") and Status in (\"\(StatusEnum.TAKEPIC.rawValue)\", \"\(StatusEnum.RESETPHOTO.rawValue)\" ,\"\(StatusEnum.REJECTED.rawValue)\")"
            do {
                let stmt = try db.prepare(query)
                var param: [String: Any] = [:]
                for row in stmt {
                    for (index, name) in stmt.columnNames.enumerated() {
                        print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                        // id: Optional(1), email: Optional("alice@mac.com")
                        param[name] = row[index] != nil ? row[index]! : 0
                    }
                }
                storage_saveObject("ItemsCount", param["ItemsCount"] as! Int64)
                storage_saveObject("ItemsCountItemID", param["AdhocPhotoID"])
                completionHandler(param)
                
            }catch let error {
                print(error.localizedDescription)
                completionHandler([:])
            }
        }
    }

    func resetPhoto(completionHandler: @escaping(Bool) -> Void) {
        let query = "Update Photos set Status=\"\(StatusEnum.RESETPHOTO.rawValue)\" , TakenBy=\"\(storage_loadObject("UserName")!)\", TakenDate=\"\(storage_loadObject("TakenDate")!)\" where AdhocPhotoID = \"\(storage_loadObject("AdhocPhotoID")!)\" "
        do{
            try db.execute(query)
            completionHandler(true)
        }catch let error {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
    
    func getLocationMatrix(adhocPhotoID: String, categoryRelationID: String, completionHandler: @escaping(String) -> Void) {
        var categoryIdList = "";
        var categoryIds = categoryRelationID.components(separatedBy: ",");
        for i in 0..<categoryIds.count {
            if categoryIds[i] != "" {
                if categoryIdList == "" {
                    categoryIdList = String(format: "\"%@\"", categoryIds[i])
                }else{
                    categoryIdList = String(format: "%@, \"%@\"", categoryIdList, categoryIds[i])
                }
            }
        }
        
        let query = "Select ProjectName AS ProjectName, ProjectName AS CategoryName from Projects where ProjectID = ( Select ProjectID from Categories where categoryId  in (\(categoryIdList))) Union All SELECT ProjectID AS ProjectName, CategoryName FROM Categories where categoryId in (\(categoryIdList)) Union All Select Null AS ProjectName, SectorName AS CategoryName from Sector where SectorID = (select SectorID from Photos where adhocPhotoID = \"\(adhocPhotoID)\") Union All Select Null AS ProjectID,  PositionName AS CategoryName from Position where PositionID = (select PositionID from Photos where adhocPhotoID = \"\(adhocPhotoID)\")"
        print(query)
        do{
            let stmt = try db.prepare(query)
            var value: String = ""
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    print ("\(name):\(row[index] != nil ? row[index]! : "null")")
                    // id: Optional(1), email: Optional("alice@mac.com")
                    if name == "CategoryName" {
                        if value == "" {
                            value = String(format: "%@", row[index] != nil ? row[index]! as! CVarArg : "")
                        }else{
                            value = String(format: "%@ >> %@", value, row[index] != nil ? row[index]! as! CVarArg : "")
                        }
                    }
                }
            }
            completionHandler(value)
        }catch let error {
            print(error.localizedDescription)
            completionHandler("")
        }

    }
}
