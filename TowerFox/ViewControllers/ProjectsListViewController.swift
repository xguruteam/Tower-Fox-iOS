//
//  PorjectsListViewController.swift
//  CloseOut
//
//  Created by cgc on 9/5/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import SwiftyJSON
class ProjectsListViewController: UIViewController {

    @IBOutlet weak var ermptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var projectList: [ProjectModel] = []
    var navigationStack: [NavigationStack] = []
    var projects: [ProjectDisplayModel] = []
    @IBOutlet weak var syncView: UIView!
    @IBOutlet weak var syncContentView: UIView!
    @IBOutlet weak var lblSyncDetail: UILabel!
    var progressView: LDProgressView!
    @IBOutlet weak var syncViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(checkProject), name: Notification.Name("updateProject"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveProgressUpdatedNotification(_:)), name: Notification.Name("progressUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndProgressNotification(_:)), name: Notification.Name("closeProgress"), object: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = "Projects"
        self.addRightButton()

        self.progressView = LDProgressView(frame: CGRect(x: 0, y: 0, width: self.syncContentView.frame.size.width, height: 16))
        self.progressView.color = UIColor.appMainColor
        self.progressView.flat = true
        self.progressView.showBackgroundInnerShadow = true
        self.progressView.progress = 1
        self.progressView.animate = true
        self.progressView.borderRadius = 1
        self.progressView.animateDirection = LDAnimateDirection.backward
        self.syncContentView.addSubview(self.progressView)
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.leftAnchor.constraint(equalTo: syncContentView.leftAnchor).isActive = true
        self.progressView.topAnchor.constraint(equalTo: syncContentView.topAnchor).isActive = true
        self.progressView.bottomAnchor.constraint(equalTo: syncContentView.bottomAnchor).isActive = true
        self.progressView.rightAnchor.constraint(equalTo: syncContentView.rightAnchor).isActive = true
        
        self.hideSyncView()
    }
    
    func showSyncView(_ title: String, progress: CGFloat)  {
        self.syncView.isHidden = false
        if self.syncViewHeight.constant > 0 {
            self.progressView.progress = progress
            self.lblSyncDetail.text = title
        }else{
            UIView.animate(withDuration: 0.3) {
                self.syncViewHeight.constant = 60
                self.progressView.progress = progress
                self.lblSyncDetail.text = title
            }
        }
    }
    
    func hideSyncView() {
        UIView.animate(withDuration: 0.3) {
            self.syncViewHeight.constant = 0
            self.syncView.isHidden = true
            self.progressView.progress = 0.0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func addRightButton(){
        
        let settingButton = UIButton(type: .custom)
        settingButton.setImage(#imageLiteral(resourceName: "ic_tune"), for: .normal)
        settingButton.addTarget(self, action: #selector(SettingButtonClicked(_:)), for: .touchUpInside)
        let leftButtonItem = UIBarButtonItem(customView: settingButton)
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = [leftButtonItem]
        
        let addbutton = UIButton(type: UIButtonType.custom)
        addbutton.setImage(#imageLiteral(resourceName: "ic_add"), for: .normal)
        addbutton.addTarget(self, action: #selector(AddProjectButtonClicked(_:)), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: addbutton)
        self.navigationItem.rightBarButtonItems = [rightBarItem]
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarVisible(visible: true, animated: true)
        self.navigationStack = Database.sharedInstance.navigationStack
        self.updateView()
    }
    
    func updateView() {
        self.checkProject()
        
        if storage_loadObject("SYNC") != "TRUE" {
            storage_saveObject("SYNC", "TRUE")
        }else{
            return
        }
        self.AppAutoConfigrationTest()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddProjectButtonClicked(_ sender: MKCardView) {
        if storage_loadObject("SYNC") == "TRUE" {
            showErrorMessage("Synchronizing, Please wait...", title: "Please wait")
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addProjectVC") as! AddProjectViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func SettingButtonClicked(_ sender: MKCardView) {
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
    }
    
    @objc func checkProject() {
//        appDel.updateProgressView("Syncronizing , Please wait", progress: 0, total: 100 )
        do{
            let count = try Database.sharedInstance.db.scalar("SELECT count(*) as Count FROM Projects") as! Int64
            if count > 0 {
                let isFromProjects = !Database.sharedInstance.isFromProjects
                Database.sharedInstance.isFromProjects = isFromProjects
                Database.sharedInstance.displayProjects { (results) in
                    self.projects = results
                    self.tableView.setContentOffset(CGPoint.zero, animated: true)
                    self.tableView.reloadData()
               }
            }else{
                appDel.hideHUD()
            }
        }catch let error {
            appDel.hideHUD()
            print(error.localizedDescription)
        }
    }
    
    func deleteProject(_ deleteProjectID: String, daletecasperID: String) {
        appDel.showHUD("Synchronizing...", subtext: "")
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
                        appDel.hideHUD()
                        print(unwrappedJson["ServiceMessage"])
                    }
                }else{
                }
            case .Failure(let error):
                print(error)
                appDel.hideHUD()
            }
            
        }
        
    }
    
    func deleteProject(){
        Database.sharedInstance.deleteProject {
            storage_removeItem(storage_loadObject("DeleteProjectID")!)
            storage_removeItem("DeleteProjectID")
            appDel.hideHUD()
            self.checkProject()
        }
    }
}

extension ProjectsListViewController {
    func AppAutoConfigrationTest() {
        appDel.showHUD("Synchronizing...", subtext: "")
        ApiRequest.serverConnectivityTest(storage_loadObject("SERVER_IP")!) { (message, data) in
            if let response = data as? ResponseModel {
                if response.status! {
                    appDel.window?.rootViewController?.view.endEditing(true)
                    Database.sharedInstance.uploadData()
                }else{
                    storage_saveObject("SYNC", "")
                    appDel.hideHUD()
                    self.showErrorMessage("Server IP address is not valid", title: TITLE)
                }
            }else{
                appDel.hideHUD()
                storage_saveObject("SYNC", "")
                self.showErrorMessage("Server IP address is not valid", title: TITLE)
            }
        }
    }
    
    @objc func didReceiveProgressUpdatedNotification(_ noti: Notification) {
        let object = noti.object as! [String: Any]
        let progress = CGFloat(object["progress"] as! Double)
        let title = object["text"] as! String
        storage_saveObject("SYNC", "TRUE")
        if projects.count > 0 {
            self.showSyncView(title, progress: progress)
        }else{
            self.hideSyncView()
        }
    }
    
    @objc func didEndProgressNotification(_ noti: Notification) {
        self.hideSyncView()
//        storage_saveObject("SYNC", "")
//        self.checkProject()
    }
    
}

extension ProjectsListViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.projects.count > 0 {
            self.ermptyView.isHidden = true
        }else{
            self.ermptyView.isHidden = false
        }
        return self.projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectCell
        let project = projects[indexPath.row]
        cell.contentView.addSubview(cell.progressBar)
        cell.progressBar.frame = cell.viewProgress.frame
        cell.viewProgress.isHidden = true
        cell.progressBar.dataSource = self
        cell.progressBar.lineCap = .square
        cell.progressBar.delegate = self
        cell.progressBar.isUserInteractionEnabled = false
        cell.progressBar.advance(section: 0, by: Int(project.Taken))
        cell.progressBar.advance(section: 1, by: Int(project.Approved))
        cell.progressBar.advance(section: 2, by: Int(project.Rejected))
        cell.btnRightArrow.isUserInteractionEnabled = false
        cell.lblProjectID.text = project.ProjectID
        cell.lblProjectID1.text = project.ProjectName
        cell.lblProjectID2.text = project.CasperID
        
        
        let remainingCount = project.requiredCount + project.rejectedCount
        _ = project.OutOfScopeCount
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
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if storage_loadObject("SYNC") == "TRUE" {
            return .none
        }

        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let alertcontroller = UIAlertController(title: "Remove Project", message: "Are you sure you want to remove this project from your device?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "NO", style: .default) { (_) in
            
        }
        let ok = UIAlertAction(title: "YES", style: .default) { (_) in
            let project = self.projects[indexPath.row]
            self.projects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteProject(project.ProjectID, daletecasperID: project.CasperID)
        }
        alertcontroller.addAction(cancel)
        alertcontroller.addAction(ok)
        appDel.window?.rootViewController?.present(alertcontroller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        Database.sharedInstance.categories.removeAll()
        Database.sharedInstance.categoriesStack.removeAll()
        Database.sharedInstance.navigationStack = self.navigationStack
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "categoryVC") as! CategoriesViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

extension ProjectsListViewController: MGSegmentedProgressBarDataSource,  MGSegmentedProgressBarDelegate {
    
    func progressBar(_ progressBar: MGSegmentedProgressBar, barForSection section: Int) -> MGBarView {
        let bar =  MGBarView()
        bar.backgroundColor = section % 3 == 0 ? UIColor.appBlueColor : ((section % 3) == 1 ? UIColor.appGreenColor : UIColor.appRedColor)
        return bar
    }
    
    func numberOfSections(in progressBar: MGSegmentedProgressBar) -> Int {
        return 3
    }
    
    func numberOfSteps(in progressBar: MGSegmentedProgressBar) -> Int {
        return 100
    }
    
}
