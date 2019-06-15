//
//  MainViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import SwiftyJSON
class MainViewController: UIViewController {

    @IBOutlet weak var btnSetting: MKCardView!
    @IBOutlet weak var btnAddProject: MKCardView!
    @IBOutlet weak var btnProjectList: MKCardView!
    @IBOutlet weak var btnRejectedList: MKCardView!
    @IBOutlet weak var imvProjectList: UIImageView!
    @IBOutlet weak var lblProjectList: UILabel!
    @IBOutlet weak var imvRejectedList: UIImageView!
    @IBOutlet weak var lblRejectedList: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var btnBack: MKCardView!
    @IBOutlet weak var btnTop: MKCardView!
    
    var projectList: [ProjectModel] = []
    var rejects: [RejectDisplayModel] = []
    var rejectDisplayList: [[RejectDisplayModel]] = []
    var rejectHeaders:[String] = []
    @IBOutlet weak var emptyView: UIView!
    
    var categoriesStack: [String] = []
    var navigationStack: [NavigationStack] = []
    var projects: [ProjectDisplayModel] = []
    var isProjectList = true
    var isCategory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomStackView.sendSubview(toBack: self.btnRejectedList)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationStack = Database.sharedInstance.navigationStack
        self.updateView()
    }
    
    func updateView() {
        if self.isCategory {
            self.btnSetting.isHidden = true
            self.btnAddProject.isHidden = true
            self.btnBack.isHidden = false
            if self.navigationStack.count > 1 {
                self.btnTop.isHidden = false
            }else{
                self.btnTop.isHidden = true
            }
            Database.sharedInstance.getPhotoRemainingCount { (data) in
                self.tableView.setContentOffset(CGPoint.zero, animated: true)
                self.tableView.reloadData()
            }
            Database.sharedInstance.getHeaderCount { (data) in
                self.tableView.setContentOffset(CGPoint.zero, animated: true)
                self.tableView.reloadData()
            }
            Database.sharedInstance.getCategoriesList(completionHandler: { (data) in
                appDel.dismissProgressView()
                self.tableView.setContentOffset(CGPoint.zero, animated: true)
                self.tableView.reloadData()
            })
        }else{
            self.navigationStack.removeAll()
            if isProjectList {
                self.btnSetting.isHidden = false
                self.btnAddProject.isHidden = false
                self.btnBack.isHidden = true
                self.btnTop.isHidden = true
                self.checkProject()
            }else{
                self.btnSetting.isHidden = true
                self.btnAddProject.isHidden = true
                self.btnBack.isHidden = true
                self.btnTop.isHidden = true
                self.checkReject()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddProjectButtonClicked(_ sender: MKCardView) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addProjectVC") as! AddProjectViewController
        vc.mainVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TopButtonClicked(_ sender: MKCardView) {
        let nav = self.navigationStack.first
        self.navigationStack.removeAll()
        self.navigationStack.append(nav!)
        self.isCategory = true
        categoriesStack.removeAll()
        categoriesStack.append("")
        
        storage_saveObject("ParentID","0");
        storage_saveObject("SectorID","0");
        storage_saveObject("PositionID","0");
        storage_saveObject("RequireSectorPosition", false);

        updateView()
    }
    
    @IBAction func BackButtonClicked(_ sender: MKCardView) {
        if self.navigationStack.count > 1 {
            self.navigationStack.removeLast()
            let navi = navigationStack[navigationStack.count - 1]
            if(navi.ProjectID != "" && navi.ProjectID != "undefined" && navi.ProjectID != "null")
            {
                storage_saveObject("ProjectID",navi.ProjectID);
            }
            
            if(navi.ParentID != "" && navi.ParentID != "undefined" && navi.ParentID != "null")
            {
                storage_saveObject("ParentID",navi.ParentID);
            }
            storage_saveObject("RequireSectorPosition", navi.RequireSectorPosition);
            
            if (navi.type == "Category" || navi.type == "Sector")
            {
                storage_saveObject("SectorID",navi.SectorID);
            }
            storage_saveObject("Type",navi.type);
            storage_saveObject("PositionID",navi.PositionID)

            Database.sharedInstance.navigationStack = self.navigationStack
        }else{
            self.navigationStack.removeLast()
            Database.sharedInstance.navigationStack = self.navigationStack
        }
        if self.navigationStack.count > 0  {
            self.isCategory = true
        }else{
            self.isCategory = false
        }
        self.updateView()
    }
    
    @IBAction func SettingButtonClicked(_ sender: MKCardView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
            let presentedVC = self.storyboard!.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
            let nvc = UINavigationController(rootViewController: presentedVC)
            nvc.isNavigationBarHidden = true
            self.present(nvc, animated: false, completion: nil)
        })
    }

    @IBAction func ProjectListButtonClicked(_ sender: MKCardView) {
        self.btnProjectList.backgroundColor = UIColor.appMainColor
        self.imvProjectList.image = #imageLiteral(resourceName: "ic_list_white")
        self.lblProjectList.textColor = UIColor.white
        self.btnRejectedList.backgroundColor = UIColor.white
        self.imvRejectedList.image = #imageLiteral(resourceName: "ic_list_blue")
        self.lblRejectedList.textColor = UIColor.appMainColor
        self.btnProjectList.exchangeSubview(at: 0, withSubviewAt: 1)
        self.bottomStackView.sendSubview(toBack: self.btnRejectedList)
        self.isProjectList = true
        self.isCategory = false
        self.updateView()
    }
    
    @IBAction func RejectedListButtonClicked(_ sender: MKCardView) {
        self.btnProjectList.backgroundColor = UIColor.white
        self.imvProjectList.image = #imageLiteral(resourceName: "ic_list_blue")
        self.lblProjectList.textColor = UIColor.appMainColor
        self.btnRejectedList.backgroundColor = UIColor.appMainColor
        self.imvRejectedList.image = #imageLiteral(resourceName: "ic_list_white")
        self.lblRejectedList.textColor = UIColor.white
        self.bottomStackView.sendSubview(toBack: self.btnProjectList)
        self.isProjectList = false
        self.isCategory = false
        self.updateView()
    }
    
    func displayProject() {
        
    }
    
    func checkProject() {
        appDel.updateProgressView("Syncronizing , Please wait", progress: 0, total: 100 )
        do{
            let count = try Database.sharedInstance.db.scalar("SELECT count(*) as Count FROM Projects") as! Int64
            if count > 0 {
                let isFromProjects = !Database.sharedInstance.isFromProjects
                Database.sharedInstance.isFromProjects = isFromProjects
                Database.sharedInstance.displayProjects { (results) in
                    appDel.dismissProgressView()
                    self.projects = results
                    self.tableView.setContentOffset(CGPoint.zero, animated: true)
                    self.tableView.reloadData()
                }
                self.AppAutoConfigrationTest()
            }else{
                appDel.dismissProgressView()
            }
        }catch let error {
            appDel.dismissProgressView()
            print(error.localizedDescription)
        }
    }
    
    func checkReject() {
    
        appDel.updateProgressView("Syncronizing , Please wait", progress: 0, total: 100 )

        Database.sharedInstance.displayRejects { (results) in
            self.rejects = results
            var prev: RejectDisplayModel!
            self.rejectHeaders.removeAll()
            var rejectArr: [RejectDisplayModel] = []
            for i in 0..<self.rejects.count {
                let rej = self.rejects[i]
                if prev != nil {
                    if prev.ProjectID == rej.ProjectID && prev.CategoryName == rej.CategoryName {
                        rejectArr.append(rej)
                    }else{
                        if self.rejectHeaders.count > 0 {
                            self.rejectDisplayList.append(rejectArr)
                        }
                        self.rejectHeaders.append(String(format: "%@ >> %@", rej.ProjectID, rej.CategoryName))
                        rejectArr.removeAll()
                        rejectArr.append(rej)
                    }
                }else{
                    self.rejectHeaders.append(String(format: "%@ >> %@", rej.ProjectID, rej.CategoryName))
                    rejectArr.removeAll()
                    rejectArr.append(rej)
                }
                prev = rej
            }
            if self.rejectDisplayList.count < self.rejectHeaders.count {
                self.rejectDisplayList.append(rejectArr)
            }
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            self.tableView.reloadData()
            appDel.dismissProgressView()
        }
    }
    
    func deleteProject(_ deleteProjectID: String, daletecasperID: String) {
        storage_saveObject("DeleteProjectID",deleteProjectID);
        storage_saveObject("DeleteCasperID",daletecasperID);

        let actualDate = Int64(Date().timeIntervalSince1970 * 1000)
        let device = UIDevice.current
        let uuid = device.identifierForVendor?.uuidString
        let model = device.model
        let paltform = "iOS"
        let version = device.systemVersion

        let jsonData:[String: AnyObject] = ["CreatedDate": "/Date(\(actualDate))/" as AnyObject, "DeviceID": uuid as AnyObject, "DeviceModel": model as AnyObject, "DevicePlatform": paltform as AnyObject, "DeviceToken":storage_loadObject("TokenID") as AnyObject, "DeviceVersion": version as AnyObject, "IsDeleted": "true" as AnyObject, "LoginDate": "/Date(\(actualDate))/" as AnyObject, "ProjectID":storage_loadObject("DeleteProjectID") as AnyObject, "UserName": storage_loadObject("UserName") as AnyObject]
        BMWebRequest.post(url: getDeleteProjectURL(), params: jsonData, isHeader: false) { (result) in
            switch(result) {
            case .Success(let json):
                if let unwrappedJson = json as? JSON {
                    if unwrappedJson["ServiceStatus"].stringValue == "SUCCESS" {
                        self.deleteProject()
                    }else{
                        print(unwrappedJson["ServiceMessage"])
                    }
                }else{
                }
            case .Failure(let error):
                print(error)
            }
            
        }

    }
    
    func deleteProject(){
        Database.sharedInstance.deleteProject {
            storage_removeItem("DeleteProjectID")
            self.checkProject()
        }
    }
}

extension MainViewController {
    func AppAutoConfigrationTest() {
        appDel.window?.rootViewController?.view.endEditing(true)
        ApiRequest.serverConnectivityTest(storage_loadObject("SERVER_IP")!) { (message, data) in
            if let response = data as? ResponseModel {
                if response.status! {
                    appDel.window?.rootViewController?.view.endEditing(true)
                    Database.sharedInstance.uploadData()
                }else{
                    appDel.dismissProgressView()
                    self.showErrorMessage("Server IP address is not valid", title: TITLE)
                }
            }else{
                appDel.dismissProgressView()
                self.showErrorMessage("Server IP address is not valid", title: TITLE)
            }
        }
    }

}
extension MainViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isCategory {
            return 1
        }else{
            if self.isProjectList {
                return 1
            }else{
                return self.rejectHeaders.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCategory {
            return Database.sharedInstance.categories.count + 1
        }else{
            if self.isProjectList {
                if self.projects.count > 0 {
                    self.emptyView.isHidden = true
                }else{
                    self.emptyView.isHidden = false
                }
                return self.projects.count
            }else{
                return self.rejectDisplayList[section].count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isCategory {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryHeaderCell", for: indexPath) as! CategoryHeaderCell
                let remaining = Int(storage_loadObject("ProjectRequiredCount")!)! + Int(storage_loadObject("ProjectRejectedCount")!)!
               
                cell.lblRemaining.text = String(format: "PHOTOS REMAINING: %d", remaining)
                cell.lblTaken.text = storage_loadObject("ProjectRequiredCount")!
                cell.lblRejected.text = storage_loadObject("ProjectRejectedCount")
                cell.lblOutofScope.text = storage_loadObject("ProjectOutOfScopeCount")!
                cell.lblProjectID.text = storage_loadObject("ProjectID")
                cell.lblProjectName.text = storage_loadObject("ProjectName")
                cell.lblPaceID.text = storage_loadObject("PaceID")
                cell.contentView.addSubview(cell.progressBar)
                cell.progressBar.frame = cell.viewProgress.frame
                cell.viewProgress.isHidden = true
                cell.progressBar.dataSource = self
                cell.progressBar.lineCap = .square
                cell.progressBar.delegate = self
                cell.progressBar.trackBackgroundColor = UIColor.appLightGrayColor
                cell.progressBar.isUserInteractionEnabled = false
                cell.progressBar.advance(section: 0, by: Int(Double(storage_loadObject("ProjectApproved")!)!))
                cell.progressBar.advance(section: 1, by: Int(Double(storage_loadObject("ProjectRejected")!)!))
                cell.progressBar.advance(section: 2, by: Int(Double(storage_loadObject("ProjectOutOfScopeCount")!)!))

                return cell
            }else{
                let category = Database.sharedInstance.categories[indexPath.row - 1]
                if category.type == "Category" || category.type == "Sector" || category.type == "Position"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
                    cell.lblCategoryName.text = category.CategoryName
                        if category._required > 0 {
                            cell.lblRequired.text = String(format: "%d Required", category._required)
                        }else{
                            cell.lblRequired.text = ""
                        }
                        if category._rejected > 0 {
                            cell.lblRejected.text = String(format: "%d Rejected", category._rejected)
                        }else{
                            cell.lblRejected.text = ""
                        }
                        if category._taken > 0 {
                            cell.lblPending.text = String(format: "%d Pending", category._taken)
                        }else{
                            cell.lblPending.text = ""
                        }
                        if category._approved > 0 {
                            cell.lblApproved.text = String(format: "%d Approved", category._approved)
                        }else{
                            cell.lblApproved.text = ""
                        }
                        cell.contentView.addSubview(cell.progressBar)
                        cell.progressBar.frame = cell.viewProgress.frame
                        cell.viewProgress.isHidden = true
                        cell.progressBar.dataSource = self
                        cell.progressBar.lineCap = .square
                        cell.progressBar.delegate = self
                        cell.progressBar.trackBackgroundColor = UIColor.appLightGrayColor
                        cell.progressBar.isUserInteractionEnabled = false
                        cell.progressBar.advance(section: 0, by: Int(category._approvedPercent))
                        cell.progressBar.advance(section: 1, by: Int(category._rejectedPercent))
                        cell.progressBar.advance(section: 2, by: Int(category._takenPercent))
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "rejectCell", for: indexPath) as! RejectCell
                    if category.IStatus == StatusEnum.TAKEPIC.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        cell.imvIcon.image = #imageLiteral(resourceName: "ic_camera_gray")
                        cell.lblName.text = category.ItemName
                        cell.lblName.textColor = UIColor.appGrayColor
                    }else if category.IStatus == StatusEnum.PICTAKEN.rawValue {
                        cell.imvIcon.image = #imageLiteral(resourceName: "ic_watch")
                        cell.lblName.text = category.ItemName
                        cell.lblName.textColor = UIColor.appMainColor
                    }else if category.IStatus == StatusEnum.UPLOADED.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        cell.imvIcon.image = #imageLiteral(resourceName: "ic_watch")
                        cell.lblName.text = category.ItemName
                        cell.lblName.textColor = UIColor.appMainColor
                    }else if category.IStatus == StatusEnum.APPROVED.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        cell.imvIcon.image = #imageLiteral(resourceName: "ic_verify")
                        cell.lblName.text = category.ItemName
                        cell.lblName.textColor = UIColor.appGreenColor
                    }else if category.IStatus == StatusEnum.REJECTED.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                        cell.imvIcon.image = #imageLiteral(resourceName: "ic_camera_red")
                        cell.lblName.text = category.ItemName
                        cell.lblName.textColor = UIColor.appRedColor
                    }
                    return cell
                }
            }
        }else{
            if self.isProjectList {
                let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectCell
                let project = projects[indexPath.row]
                cell.contentView.addSubview(cell.progressBar)
                cell.progressBar.frame = cell.viewProgress.frame
                cell.viewProgress.isHidden = true
                cell.progressBar.dataSource = self
                cell.progressBar.lineCap = .square
                cell.progressBar.delegate = self
                cell.progressBar.trackBackgroundColor = UIColor.appLightGrayColor
                cell.progressBar.isUserInteractionEnabled = false
                cell.progressBar.advance(section: 0, by: Int(project.Approved))
                cell.progressBar.advance(section: 1, by: Int(project.Rejected))
                cell.progressBar.advance(section: 2, by: Int(project.Taken))
                cell.btnRightArrow.isUserInteractionEnabled = false
                cell.lblProjectID.text = project.ProjectID
                cell.lblProjectID1.text = project.ProjectName
                cell.lblProjectID2.text = project.CasperID
                
                let remainingCount = project.requiredCount + project.rejectedCount
                let outOfScopeCount = project.OutOfScopeCount
                Database.sharedInstance.projectsGlobalArray[indexPath.row] = project.ProjectID
                if Double(project.Approved).truncatingRemainder(dividingBy: 1) == 0
                {
                    let completePercent = Int(project.Approved)
                    cell.lblProjectStatus.text = String(format: "%d%% Completed / Remaining: %d", completePercent, remainingCount)
                }
                else
                {
                    let completePercent = Double(project.Approved)
                    cell.lblProjectStatus.text = String(format: "%.2lf%% Completed / Remaining: %d", completePercent, remainingCount)
                }
                return cell
            }else{
                let reject = self.rejectDisplayList[indexPath.section][indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "rejectCell", for: indexPath) as! RejectCell
                cell.lblName.text = reject.ItemName
                cell.imvIcon.image = #imageLiteral(resourceName: "ic_camera_red")
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if !self.isCategory && isProjectList {
            return .delete
        }else{
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if !self.isCategory && self.isProjectList {
            let project = self.projects[indexPath.row]
            self.projects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteProject(project.ProjectID, daletecasperID: project.CasperID)

        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isCategory {
            return ""
        }
        if self.isProjectList {
            return ""
        }else{
            return self.rejectHeaders[section]
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.isCategory {
            return UIView()
        }else{
            if self.isProjectList {
                return UIView()
            }else{
                let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36))
                view.backgroundColor = UIColor(rgba: "#EBEBF1")
                let label = UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.size.width - 32, height: 36))
                label.text = self.rejectHeaders[section]
                label.font = UIFont(name: "ProximaNovaSoft-Regular", size: 14.0)
                view.addSubview(label)
                return view
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isCategory {
            return 0
        }else{
            if self.isProjectList {
                return 0
            }else{
                return 36
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isCategory {
            if indexPath.row > 0 {
                let category = Database.sharedInstance.categories[indexPath.row - 1]
                storage_saveObject("Required", category._required);
                storage_saveObject("Taken", category._taken);
                storage_saveObject("Approved", category._approved);
                storage_saveObject("Rejected", category._rejected);
                storage_saveObject("TakenPercent", category._takenPercent);
                storage_saveObject("ApprovedPercent", category._approvedPercent);
                storage_saveObject("RejectedPercent", category._rejectedPercent);
                
                if category.type == "Category" || category.type == "Sector" || category.type == "Position" {
                    if category.ProjectID != "" && category.ProjectID != "undefined" && category.ProjectID != "null" {
                        storage_saveObject("ProjectID", category.ProjectID)
                    }
                    if category.PCategoryID != "" && category.PCategoryID != "undefined" && category.PCategoryID != "null" {
                        storage_saveObject("ParentID", category.PCategoryID);
                    }
                    if category.type == "Category" || category.type == "Sector" {
                        storage_saveObject("SectorID", category.ISectorID)
                    }
                    storage_saveObject("RequireSectorPosition", category.RequireSectorPosition)
                    storage_saveObject("PositionID", category.IPositionID)
                    let navi = NavigationStack()
                    navi.ParentID = storage_loadObject("ParentID")
                    navi.SectorID = storage_loadObject("SectorID")
                    navi.PositionID = storage_loadObject("PositionID")
                    navi.RequireSectorPosition = storage_loadObject("RequireSectorPosition")
                    navi.ProjectID = storage_loadObject("ProjectID")
                    navi.ProjectName = storage_loadObject("ProjectName")
                    navi.CategoryName = storage_loadObject("CategoryName")
                    navi.type = category.type
                    navi.ItemID = ""
                    navi.Required = category._required
                    navi.Taken = category._taken
                    navi.Approved = category._approved
                    navi.Rejected = category._rejected
                    navi.ApprovedPercent = category._approvedPercent
                    navi.RejectedPercent = category._rejectedPercent
                    navi.TakenPercent = category._takenPercent
                    self.navigationStack.append(navi)
                    Database.sharedInstance.navigationStack = self.navigationStack
                    isCategory = true
                    categoriesStack.append(category.CategoryName)
                    self.updateView()
                }else{
                    if category.IItemID != "" && category.IItemID != "undefined" {
                        storage_saveObject("ItemID", category.IItemID)
                    }
                    if category.AdhocPhotoID != "" && category.AdhocPhotoID != "undefined" {
                        storage_saveObject("AdhocPhotoID", category.AdhocPhotoID)
                    }
                    if category.PCategoryID != "" && category.PCategoryID != "undefined" && category.PCategoryID != "null" {
                        storage_saveObject("ParentID", category.PCategoryID);
                    }
//                    let navi = NavigationStack()
//                    navi.ParentID = storage_loadObject("ParentID")
//                    navi.SectorID = storage_loadObject("SectorID")
//                    navi.PositionID = storage_loadObject("PositionID")
//                    navi.RequireSectorPosition = storage_loadObject("RequireSectorPosition")
//                    navi.ProjectID = storage_loadObject("ProjectID")
//                    navi.ProjectName = storage_loadObject("ProjectName")
//                    navi.CategoryName = category.CategoryName
//                    navi.type = category.type
//                    navi.ItemID = storage_loadObject("ItemID")
//                    self.navigationStack.append(navi)
//                    Database.sharedInstance.navigationStack = self.navigationStack
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "takePhotoVC") as! TakePhotoViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            if self.isProjectList {
                self.navigationStack.removeAll()
                let project = projects[indexPath.row]
                if(project.ProjectID != "")
                {
                    storage_saveObject("ProjectID", project.ProjectID);
                }
                if(project.ProjectName != "")
                {
                    storage_saveObject("ProjectName", project.ProjectName);
                }
                if(project.PaceID != "")
                {
                    storage_saveObject("PaceID", project.PaceID);
                }
                if(project.CasperID != "")
                {
                    storage_saveObject("CasprID", project.CasperID);
                }
                if(project.Required != nil)
                {
                    storage_saveObject("ProjectRequired", project.Required);
                }
                if(project.Taken != nil)
                {
                    storage_saveObject("ProjectTaken", project.Taken);
                }
                if(project.Approved != nil)
                {
                    storage_saveObject("ProjectApproved", project.Approved);
                }
                if(project.Rejected != nil)
                {
                    storage_saveObject("ProjectRejected", project.Rejected);
                }
                storage_saveObject("ProjectRequiredCount", project.requiredCount);
                storage_saveObject("ProjectTakenCount", project.takenCount);
                storage_saveObject("ProjectRejectedCount",project.rejectedCount);
                storage_saveObject("ProjectOutOfScopeCount",  project.OutOfScopeCount);
                categoriesStack.append("");
                
                storage_saveObject("ParentID","0");
                storage_saveObject("SectorID","0");
                storage_saveObject("PositionID","0");
                storage_saveObject("RequireSectorPosition", false);
                
                /* Create JSON Object and store in Stack  */
                
                let projectstack = NavigationStack()
                projectstack.ParentID = "0"
                projectstack.SectorID = "0"
                projectstack.PositionID = "0"
                projectstack.RequireSectorPosition = "False"
                projectstack.ProjectID = project.ProjectID!
                projectstack.ProjectName = project.ProjectName!
                projectstack.CategoryName = "Photos"
                navigationStack.append(projectstack)
                Database.sharedInstance.navigationStack = self.navigationStack
                isCategory = true
                self.updateView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

extension MainViewController: MGSegmentedProgressBarDataSource,  MGSegmentedProgressBarDelegate {
    
    func progressBar(_ progressBar: MGSegmentedProgressBar, barForSection section: Int) -> MGBarView {
        let bar =  MGBarView()
        bar.backgroundColor = section % 3 == 0 ? UIColor.appGreenColor : ((section % 3) == 1 ? UIColor.appRedColor : UIColor.appBlueColor)
        return bar
    }
    
    func numberOfSections(in progressBar: MGSegmentedProgressBar) -> Int {
        return 3
    }
    
    func numberOfSteps(in progressBar: MGSegmentedProgressBar) -> Int {
        return 100
    }
    
}

class ProjectCell: MKTableViewCell {
    @IBOutlet weak var btnRightArrow: UIButton!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var lblProjectStatus: UILabel!
    @IBOutlet weak var lblProjectID: UILabel!
    @IBOutlet weak var lblProjectID1: UILabel!
    @IBOutlet weak var lblProjectID2: UILabel!
    let progressBar = MGSegmentedProgressBar()
}

class CategoryHeaderCell: UITableViewCell {
    @IBOutlet weak var btnTakePhoto: MKCardView!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var lblProjectID: UILabel!
    @IBOutlet weak var lblPaceID: UILabel!
    @IBOutlet weak var lblProjectName: UILabel!
    @IBOutlet weak var lblRemaining: UILabel!
    @IBOutlet weak var lblTaken: UILabel!
    @IBOutlet weak var lblRejected: UILabel!
    @IBOutlet weak var lblOutofScope: UILabel!
    let progressBar = MGSegmentedProgressBar()
}

class CategoryCell: MKTableViewCell {
    @IBOutlet weak var btnRightArrow: UIButton!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblRequired: UILabel!
    @IBOutlet weak var lblRejected: UILabel!
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblApproved: UILabel!
    let progressBar = MGSegmentedProgressBar()

}

class RejectCell: MKTableViewCell {
    @IBOutlet weak var imvSync: UIImageView!
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
}
