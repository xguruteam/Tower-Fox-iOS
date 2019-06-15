//
//  ProjectModel.swift
//  CloseOut
//
//  Created by cgc on 8/29/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import SwiftyJSON
class ProjectModel: NSObject {
    var Address: String! = ""
    var City: String! = ""
    var Description: String! = ""
    var FirstName: String! = ""
    var IsLocked: Bool = false
    var LastName: String! = ""
    var Latitude: String! = ""
    var LockedBy: String! = ""
    var Longitude: String! = ""
    var ProjectNumber: String! = ""
    var ProjectID: String! = ""
    var ProjectName: String! = ""
    var ServiceMessage: String! = ""
    var ServiceStatus: String! = ""
    var State: String! = ""
    var Status: Int! = 0
    var VenderID: String! = ""
    var casprid: String! = ""
    var faacode: String! = ""
    
    override init() {
    }
    
    init(with info: [String: JSON]){
        if let Address = info["Address"]?.string {
            self.Address = Address
        }
        if let City = info["City"]?.string {
            self.City = City
        }
        if let Description = info["Description"]?.string {
            self.Description = Description
        }
        if let FirstName = info["FirstName"]?.string {
            self.FirstName = FirstName
        }
        if let IsLocked = info["IsLocked"]?.bool {
            self.IsLocked = IsLocked
        }
        if let LastName = info["LastName"]?.string {
            self.LastName = LastName
        }
        if let Latitude = info["Latitude"]?.string {
            self.Latitude = Latitude
        }
        if let LockedBy = info["LockedBy"]?.string {
            self.LockedBy = LockedBy
        }
        if let Longitude = info["Longitude"]?.string {
            self.Longitude = Longitude
        }
        if let ProjectNumber = info["ProjectNumber"]?.string {
            self.ProjectNumber = ProjectNumber
        }
        if let ProjectID = info["ProjectID"]?.string {
            self.ProjectID = ProjectID
        }
        if let ProjectName = info["ProjectName"]?.string {
            self.ProjectName = ProjectName
        }
        if let ServiceMessage = info["ServiceMessage"]?.string {
            self.ServiceMessage = ServiceMessage
        }
        if let ServiceStatus = info["ServiceStatus"]?.string {
            self.ServiceStatus = ServiceStatus
        }
        if let State = info["State"]?.string {
            self.State = State
        }
        if let Status = info["Status"]?.int {
            self.Status = Status
        }
        if let VenderID = info["VenderID"]?.string {
            self.VenderID = VenderID
        }
        if let casprid = info["casprid"]?.string {
            self.casprid = casprid
        }
        if let faacode = info["faacode"]?.string {
            self.faacode = faacode
        }
    }
}

class CategoryModel: NSObject {
    var CategoryID: String! = ""
    var CategoryName: String! = ""
    var ContainsSectorPosition: Bool = false
    var CreatedBy: String! = ""
    var CreatedDate: String! = ""
    var Description: String! = ""
    var ModifiedBy: String! = ""
    var ModifiedDate: String! = ""
    var ParentCategoryID: String! = ""
    var ProjectID: String! = ""
    var SortOrder: Int! = 0
    var Status: Bool = false
    
    override init() {
        
    }
    
    init(with info: [String: JSON]) {
        if let CategoryID = info["CategoryID"]?.string {
            self.CategoryID = CategoryID
        }
        if let CategoryName = info["CategoryName"]?.string {
            self.CategoryName = CategoryName
        }
        if let ContainsSectorPosition = info["ContainsSectorPosition"]?.bool {
            self.ContainsSectorPosition = ContainsSectorPosition
        }
        if let CreatedBy = info["CreatedBy"]?.string {
            self.CreatedBy = CreatedBy
        }
        if let CreatedDate = info["CreatedDate"]?.string {
            self.CreatedDate = CreatedDate
        }
        if let Description = info["Description"]?.string {
            self.Description = Description
        }
        if let ModifiedBy = info["ModifiedBy"]?.string {
            self.ModifiedBy = ModifiedBy
        }
        if let ModifiedDate = info["ModifiedDate"]?.string {
            self.ModifiedDate = ModifiedDate
        }
        if let ParentCategoryID = info["ParentCategoryID"]?.string {
            self.ParentCategoryID = ParentCategoryID
        }
        if let ProjectID = info["ProjectID"]?.string {
            self.ProjectID = ProjectID
        }
        if let SortOrder = info["SortOrder"]?.int {
            self.SortOrder = SortOrder
        }
        if let Status = info["Status"]?.bool {
            self.Status = Status
        }
    }
}

class ProjectPhotosModel:NSObject {
    var ActionType: String! = ""
    var AdhocPhotoID: String! = ""
    var AppUserID: String! = ""
    var ApprovalStatus: Int = 0
    var CategoryID: String! = ""
    var CategoryRelations: String! = ""
    var Comments: String! = ""
    var CreatedBy: String! = ""
    var CreatedDate: String! = ""
    var Description: String! = ""
    var DeviceID: String! = ""
    var DeviceModel: String! = ""
    var DevicePlatform: String! = ""
    var DeviceVersion: String! = ""
    var EpochTakenDate: String! = ""
    var ImageFileName: String! = ""
    var ImagePath: String! = ""
    var IsAdhoc: Bool = false
    var ItemID: String! = ""
    var ItemName: String! = ""
    var Latitude: String! = "0"
    var Longitude: String! = "0"
    var ModifiedBy: String! = ""
    var ModifiedDate: String! = ""
    var NsitePhotoFileName: String! = ""
    var PhotoHierarchyPath: String! = ""
    var PositionID: String! = ""
    var ProjectDriverID: String! = ""
    var ProjectID: String! = ""
    var ProjectName: String! = ""
    var ProjectPhotoID: String! = ""
    var QADocID: String! = ""
    var Quantity: Int = 0
    var ReferenceImageName: String! = ""
    var RequiresSectorPosition: Bool = false
    var Sector: String! = ""
    var SectorID: String! = ""
    var SortOrder: Int = 0
    var TakenBy: String! = ""
    var TakenDate: String! = ""
    var VendorContactID: String! = ""
    
    override init() {
        
    }
    
    init(with info: [String: JSON]) {
        if let ActionType = info["ActionType"]?.string {
            self.ActionType = ActionType
        }
        if let AdhocPhotoID = info["AdhocPhotoID"]?.string {
            self.AdhocPhotoID = AdhocPhotoID
        }
        if let AppUserID = info["AppUserID"]?.string {
            self.AppUserID = AppUserID
        }
        if let ApprovalStatus = info["ApprovalStatus"]?.int {
            self.ApprovalStatus = ApprovalStatus
        }
        if let CategoryID = info["CategoryID"]?.string {
            self.CategoryID = CategoryID
        }
        if let CategoryRelations = info["CategoryRelations"]?.string {
            self.CategoryRelations = CategoryRelations
        }
        if let Comments = info["Comments"]?.string {
            self.Comments = Comments
        }
        if let CreatedBy = info["CreatedBy"]?.string {
            self.CreatedBy = CreatedBy
        }
        if let CreatedDate = info["CreatedDate"]?.string {
            self.CreatedDate = CreatedDate
        }
        if let Description = info["Description"]?.string {
            self.Description = Description
        }
        if let DeviceID = info["DeviceID"]?.string {
            self.DeviceID = DeviceID
        }
        if let DeviceModel = info["DeviceModel"]?.string {
            self.DeviceModel = DeviceModel
        }
        if let DevicePlatform = info["DevicePlatform"]?.string {
            self.DevicePlatform = DevicePlatform
        }
        if let DeviceVersion = info["DeviceVersion"]?.string {
            self.DeviceVersion = DeviceVersion
        }
        if let EpochTakenDate = info["EpochTakenDate"]?.string {
            self.EpochTakenDate = EpochTakenDate
        }
        if let ImageFileName = info["ImageFileName"]?.string {
            self.ImageFileName = ImageFileName
        }
        if let ImagePath = info["ImagePath"]?.string {
            self.ImagePath = ImagePath
        }
        if let IsAdhoc = info["IsAdhoc"]?.bool {
            self.IsAdhoc = IsAdhoc
        }
        if let ItemID = info["ItemID"]?.string {
            self.ItemID = ItemID
        }
        if let ItemName = info["ItemName"]?.string {
            self.ItemName = ItemName
        }
        if let Latitude = info["Latitude"]?.string {
            self.Latitude = Latitude
        }
        if let Longitude = info["Longitude"]?.string {
            self.Longitude = Longitude
        }
        if let ModifiedBy = info["ModifiedBy"]?.string {
            self.ModifiedBy = ModifiedBy
        }
        if let ModifiedDate = info["ModifiedDate"]?.string {
            self.ModifiedDate = ModifiedDate
        }
        if let NsitePhotoFileName = info["NsitePhotoFileName"]?.string {
            self.NsitePhotoFileName = NsitePhotoFileName
        }
        if let PhotoHierarchyPath = info["PhotoHierarchyPath"]?.string {
            self.PhotoHierarchyPath = PhotoHierarchyPath
        }
        if let PositionID = info["PositionID"]?.string {
            self.PositionID = PositionID
        }
        if let ProjectDriverID = info["ProjectDriverID"]?.string {
            self.ProjectDriverID = ProjectDriverID
        }
        if let ProjectID = info["ProjectID"]?.string {
            self.ProjectID = ProjectID
        }
        if let ProjectName = info["ProjectName"]?.string {
            self.ProjectName = ProjectName
        }
        if let ProjectPhotoID = info["ProjectPhotoID"]?.string {
            self.ProjectPhotoID = ProjectPhotoID
        }
        if let QADocID = info["QADocID"]?.string {
            self.QADocID = QADocID
        }
        if let Quantity = info["Quantity"]?.int {
            self.Quantity = Quantity
        }
        if let ReferenceImageName = info["ReferenceImageName"]?.string {
            self.ReferenceImageName = ReferenceImageName
        }
        if let RequiresSectorPosition = info["RequiresSectorPosition"]?.bool {
            self.RequiresSectorPosition = RequiresSectorPosition
        }
        if let Sector = info["Sector"]?.string {
            self.Sector = Sector
        }
        if let SectorID = info["SectorID"]?.string {
            self.SectorID = SectorID
        }
        if let SortOrder = info["SortOrder"]?.int {
            self.SortOrder = SortOrder
        }
        if let TakenBy = info["TakenBy"]?.string {
            self.TakenBy = TakenBy
        }
        if let TakenDate = info["TakenDate"]?.string {
            self.TakenDate = TakenDate
        }
        if let VendorContactID = info["VendorContactID"]?.string {
            self.VendorContactID = VendorContactID
        }
    }

   
}

class ProjectDisplayModel: NSObject {
    var ProjectID: String! = ""
    var ProjectName:String! = ""
    var CasperID:String! = ""
    var PaceID:String! = ""
    var Description:String! = ""
    var FirstName:String! = ""
    var LastName:String! = ""
    var Total: Int = 0
    var requiredCount: Int = 0
    var takenCount: Int = 0
    var ApprovedCount: Int = 0
    var rejectedCount: Int = 0
    var OutOfScopeCount: Int = 0
    var Required:Double! = 0.0
    var Taken:Double! = 0.0
    var Approved:Double! = 0.0
    var Rejected: Double! = 0.0
    
    override init() {
    }
    
    init(with info: [String: Any]) {
        if let ProjectID = info["ProjectID"] as? String {
            self.ProjectID = ProjectID
        }
        if let ProjectName = info["ProjectName"] as? String {
            self.ProjectName = ProjectName
        }
        if let CasperID = info["CasperID"] as? String {
            self.CasperID = CasperID
        }
        if let PaceID = info["PaceID"] as? String {
            self.PaceID = PaceID
        }
        if let Description = info["Description"] as? String {
            self.Description = Description
        }
        if let FirstName = info["FirstName"] as? String {
            self.FirstName = FirstName
        }
        if let LastName = info["LastName"] as? String {
            self.LastName = LastName
        }
        if let Total = info["Total"] as? Int64 {
            self.Total = Int(Total)
        }
        if let requiredCount = info["requiredCount"] as? Int64 {
            self.requiredCount = Int(requiredCount)
        }
        if let takenCount = info["takenCount"] as? Int64 {
            self.takenCount = Int(takenCount)
        }
        if let ApprovedCount = info["ApprovedCount"] as? Int64 {
            self.ApprovedCount = Int(ApprovedCount)
        }
        if let rejectedCount = info["rejectedCount"] as? Int64 {
            self.rejectedCount = Int(rejectedCount)
        }
        if let OutOfScopeCount = info["OutOfScopeCount"] as? Int64 {
            self.OutOfScopeCount = Int(OutOfScopeCount)
        }
        if let Required = info["Required"] as? Double {
            self.Required = Required
        }
        if let Taken = info["Taken"] as? Double {
            self.Taken = Taken
        }
        if let Approved = info["Approved"] as? Double {
            self.Approved = Approved
        }
        if let Rejected = info["Rejected"] as? Double {
            self.Rejected = Rejected
        }
    }
}
class RejectDisplayModel: NSObject {
    var Sample: String! = ""
    var CategoryName:String! = ""
    var ProjectPhotoID:String! = ""
    var ProjectID:String! = ""
    var CategoryID:String! = ""
    var ItemID:String! = ""
    var SectorID:String! = ""
    var PositionID: String! = ""
    var ItemName: String! = ""
    var Description: String! = ""
    var Comments: String! = ""
    var TakenBy: String! = ""
    var TakenDate: String! = ""
    var Status: Int! = 0
    var ReferenceImageName: String! = ""
    var CapturedImageName: String! = ""
    var Quantity: Int! = 0
    var RequireSectorPosition: Bool = false
    var ParentCategoryID: String! = ""
    var Latitude: Double! = 0.0
    var Longitude: Double! = 0.0
    var IsAdhoc: Bool = false
    var SortOrder: Int! = 0
    var AdhocPhotoID: String! = ""

    override init() {
    }
    
    init(with info: [String: Any]) {
        if let Sample = info["Sample"] as? String {
            self.Sample = Sample
        }
        if let CategoryName = info["CategoryName"] as? String {
            self.CategoryName = CategoryName
        }
        if let ProjectPhotoID = info["ProjectPhotoID"] as? String {
            self.ProjectPhotoID = ProjectPhotoID
        }
        if let ProjectID = info["ProjectID"] as? String {
            self.ProjectID = ProjectID
        }
        if let CategoryID = info["CategoryID"] as? String {
            self.CategoryID = CategoryID
        }
        if let ItemID = info["ItemID"] as? String {
            self.ItemID = ItemID
        }
        if let SectorID = info["SectorID"] as? String {
            self.SectorID = SectorID
        }
        if let PositionID = info["PositionID"] as? String {
            self.PositionID = PositionID
        }
        if let ItemName = info["ItemName"] as? String {
            self.ItemName = ItemName
        }
        if let Description = info["Description"] as? String {
            self.Description = Description
        }
        if let Comments = info["Comments"] as? String {
            self.Comments = Comments
        }
        if let TakenBy = info["TakenBy"] as? String {
            self.TakenBy = TakenBy
        }
        if let TakenDate = info["TakenDate"] as? String {
            self.TakenDate = TakenDate
        }
        if let Status = info["Status"] as? Int {
            self.Status = Status
        }
        if let ReferenceImageName = info["ReferenceImageName"] as? String {
            self.ReferenceImageName = ReferenceImageName
        }
        if let CapturedImageName = info["CapturedImageName"] as? String {
            self.CapturedImageName = CapturedImageName
        }
        if let Quantity = info["Quantity"] as? Int {
            self.Quantity = Quantity
        }
        if let RequireSectorPosition = info["RequireSectorPosition"] as? Bool {
            self.RequireSectorPosition = RequireSectorPosition
        }
        if let Latitude = info["Latitude"] as? String , Latitude != "" {
            self.Latitude = Double(Latitude)
        }else if let Latitude = info["Latitude"] as? Double {
            self.Latitude = Latitude
        }else{
            self.Latitude = 0.0
        }
        if let Longitude = info["Longitude"] as? String , Longitude != "" {
            self.Longitude = Double(Longitude)
        }else if let Longitude = info["Longitude"] as? Double {
            self.Longitude = Longitude
        }else{
            self.Longitude = 0.0
        }
        if let IsAdhoc = info["IsAdhoc"] as? Bool {
            self.IsAdhoc = IsAdhoc
        }
        if let SortOrder = info["SortOrder"] as? Int {
            self.SortOrder = SortOrder
        }
        if let AdhocPhotoID = info["AdhocPhotoID"] as? String {
            self.AdhocPhotoID = AdhocPhotoID
        }
    }
}

class NavigationStack: NSObject {
    var ParentID: String! = ""
    var SectorID: String! = ""
    var PositionID: String! = ""
    var RequireSectorPosition: String! = ""
    var ProjectID: String! = ""
    var ProjectName: String! = ""
    var CategoryName: String! = ""

    var type: String! = ""
    var ItemID: String! = ""
    var Required: Int! = 0
    var Taken: Int! = 0
    var Approved: Int! = 0
    var Rejected: Int! = 0
    var TakenPercent: Double! = 0.0
    var ApprovedPercent: Double! = 0.0
    var RejectedPercent: Double! = 0.0

    override init() {
        
    }

}
class CategoryDisplayModel: NSObject {
    var TempSort: Int = 0
    var PCategoryID: String = ""
    var ProjectID: String = ""
    var CategoryName: String = ""
    var Description: String = ""
    var RequireSectorPosition: Bool = false
    var Status: Int = 0
    var IParentCategoryID: String = ""
    var IItemID: String = ""
    var IProjectID: String = ""
    var ICategoryID: String = ""
    var ItemName: String = ""
    var IDescription: String = ""
    var IReferenceImageName: String = ""
    var ICapturedImageName: String = ""
    var ITakenBy: String = ""
    var ITakenDate: String = ""
    var IStatus: Int = 0
    var IComments: String = ""
    var ISectorID: String = ""
    var IPositionID: String = ""
    var type: String = ""
    var SortOrder: Int = 0
    var AdhocPhotoID: String = ""
    var _required: Int = 0
    var _taken: Int = 0
    var _approved: Int = 0
    var _rejected: Int = 0
    var _takenPercent: Double = 0.0
    var _approvedPercent: Double = 0.0
    var _rejectedPercent: Double = 0.0

    override init() {
    }
    
    init(with info:[String: Any]) {
        if let _required = info["_required"] as? Int {
            self._required = _required
        }
        if let _taken = info["_taken"] as? Int {
            self._taken = _taken
        }
        if let _approved = info["_approved"] as? Int {
            self._approved = _approved
        }
        if let _rejected = info["_rejected"] as? Int {
            self._rejected = _rejected
        }
        if let _takenPercent = info["_takenPercent"] as? Double {
            self._takenPercent = _takenPercent
        }
        if let _approvedPercent = info["_approvedPercent"] as? Double {
            self._approvedPercent = _approvedPercent
        }
        if let _rejectedPercent = info["_rejectedPercent"] as? Double {
            self._rejectedPercent = _rejectedPercent
        }
        if let TempSort = info["TempSort"] as? Int64 {
            self.TempSort = Int(TempSort)
        }
        if let PCategoryID = info["PCategoryID"] as? String {
            self.PCategoryID = PCategoryID
        }
        if let ProjectID = info["ProjectID"] as? String {
            self.ProjectID = ProjectID
        }
        if let CategoryName = info["CategoryName"] as? String {
            self.CategoryName = CategoryName
        }
        if let Description = info["Description"] as? String {
            self.Description = Description
        }
        if let RequireSectorPosition = info["RequireSectorPosition"] as? Bool {
            self.RequireSectorPosition = RequireSectorPosition
        }
        if let Status = info["Status"] as? Int64 {
            self.Status = Int(Status)
        }
        if let IParentCategoryID = info["IParentCategoryID"] as? String {
            self.IParentCategoryID = IParentCategoryID
        }
        if let IItemID = info["IItemID"] as? String {
            self.IItemID = IItemID
        }
        if let IProjectID = info["IProjectID"] as? String {
            self.IProjectID = IProjectID
        }
        if let ICategoryID = info["ICategoryID"] as? String {
            self.ICategoryID = ICategoryID
        }
        if let ItemName = info["ItemName"] as? String {
            self.ItemName = ItemName
        }
        if let IDescription = info["IDescription"] as? String {
            self.IDescription = IDescription
        }
        if let IReferenceImageName = info["IReferenceImageName"] as? String {
            self.IReferenceImageName = IReferenceImageName
        }
        if let ICapturedImageName = info["ICapturedImageName"] as? String {
            self.ICapturedImageName = ICapturedImageName
        }
        if let ITakenBy = info["ITakenBy"] as? String {
            self.ITakenBy = ITakenBy
        }
        if let ITakenDate = info["ITakenDate"] as? String {
            self.ITakenDate = ITakenDate
        }
        if let IStatus = info["IStatus"] as? Int64 {
            self.IStatus = Int(IStatus)
        }
        if let IComments = info["IComments"] as? String {
            self.IComments = IComments
        }
        if let ISectorID = info["ISectorID"] as? String {
            self.ISectorID = ISectorID
        }
        if let IPositionID = info["IPositionID"] as? String {
            self.IPositionID = IPositionID
        }
        if let type = info["Type"] as? String {
            self.type = type
        }
        if let SortOrder = info["SortOrder"] as? Int64 {
            self.SortOrder = Int(SortOrder)
        }
        if let AdhocPhotoID = info["AdhocPhotoID"] as? String {
            self.AdhocPhotoID = AdhocPhotoID
        }

    }
}
