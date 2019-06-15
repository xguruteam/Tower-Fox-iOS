//
//  CategoriesViewController.swift
//  CloseOut
//
//  Created by cgc on 9/5/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var categoriesStack: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationReceived(_ :)), name: Notification.Name("PhotesUpdated"), object: nil)
       tableView.delegate = self
        tableView.dataSource = self
        AddNavigationItems()
        // Do any additional setup after loading the view.
    }
    
    func AddNavigationItems() {
        if Database.sharedInstance.categoriesStack.count == 0 {
            self.navigationItem.title = "Photos"
        }else{
            self.navigationItem.title = Database.sharedInstance.categoriesStack.last
        }
        
        let backView = MKCardView(frame: CGRect(x: 0, y: 0, width: 50, height: 36))
        let backimage = UIImageView(image: #imageLiteral(resourceName: "ic_back"))
        backimage.frame = CGRect(x: 0, y: 0, width: 16, height: 36)
        backimage.contentMode = .center
        let backTitle = UILabel(frame: CGRect(x: 16, y: 0, width: 50, height: 36))
        backTitle.text = "Back"
        backTitle.font = UIFont(name: "ProximaNovaSoft-Regular", size: 16.0)
        backTitle.textColor = UIColor.white
        backView.addSubview(backimage)
        backView.addSubview(backTitle)
        backView.addTarget(self, action: #selector(BackButtonClicked(_:)), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: backView)
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = [backItem]
        
        if Database.sharedInstance.categoriesStack.count > 0 {
            let nextView = MKCardView(frame: CGRect(x: 0, y: 0, width: 40, height: 36))
            let nextImage = UIImageView(image: #imageLiteral(resourceName: "ic_top"))
            nextImage.frame = CGRect(x: 0, y: 0, width: 16, height: 36)
            nextImage.contentMode = .center
            let nextTitle = UILabel(frame: CGRect(x: 16, y: 0, width: 40, height: 36))
            nextTitle.text = "Top"
            nextTitle.font = UIFont(name: "ProximaNovaSoft-Regular", size: 16.0)
            nextTitle.textColor = UIColor.white
            nextView.addSubview(nextImage)
            nextView.addSubview(nextTitle)
            nextView.addTarget(self, action: #selector(TopButtonClicked(_:)), for: .touchUpInside)
            let nextItem = UIBarButtonItem(customView: nextView)
            self.navigationItem.rightBarButtonItems = [nextItem]
            
        }else{
            self.navigationItem.rightBarButtonItems = []
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarVisible(visible: true, animated: true)
        self.checkCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func NotificationReceived(_ noti: Notification) {
        self.checkCategories()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func TopButtonClicked(_ sender: MKCardView) {
        let nav = Database.sharedInstance.navigationStack.first
        Database.sharedInstance.navigationStack.removeAll()
        Database.sharedInstance.navigationStack.append(nav!)
        Database.sharedInstance.categoriesStack.removeAll()
        Database.sharedInstance.categories.removeAll()

        storage_saveObject("ParentID","0");
        storage_saveObject("SectorID","0");
        storage_saveObject("PositionID","0");
        storage_saveObject("RequireSectorPosition", false);
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    @objc func BackButtonClicked(_ sender: MKCardView) {
        if Database.sharedInstance.navigationStack.count > 1 {
            Database.sharedInstance.navigationStack.removeLast()
            if Database.sharedInstance.categoriesStack.count > 0 {
                Database.sharedInstance.categoriesStack.removeLast()
            }
            Database.sharedInstance.categories.removeAll()
            let navi = Database.sharedInstance.navigationStack[Database.sharedInstance.navigationStack.count - 1]
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
        }else{
            Database.sharedInstance.navigationStack.removeLast()
            if Database.sharedInstance.categoriesStack.count > 0 {
                Database.sharedInstance.categoriesStack.removeLast()
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkCategories()  {
        Database.sharedInstance.getPhotoRemainingCount { (data) in
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            self.tableView.reloadData()
        }
        Database.sharedInstance.getHeaderCount { (data) in
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            self.tableView.reloadData()
        }
        Database.sharedInstance.getCategoriesList(completionHandler: { (data) in
            appDel.hideHUD()
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            self.tableView.reloadData()
        })

    }
    
    @objc func TakePhoto(_ sender: Any) {
        if storage_loadObject("SYNC") == "TRUE" {
            showErrorMessage("Synchronizing, Please wait...", title: "Please wait")
            return
        }
        self.setTabBarVisible(visible: false, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "takeNewPhoto") as! TakeNewPhotoViewController
        self.navigationController?.pushViewController(vc, animated: true)
//        let imageController = UIImagePickerController()
//        imageController.allowsEditing = false
//        imageController.sourceType = UIImagePickerControllerSourceType.camera
//        imageController.cameraFlashMode = .auto
//        imageController.delegate = self
//        present(imageController, animated: true, completion: nil)
    }
    
}
extension CategoriesViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  1
        }else{
            return Database.sharedInstance.categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
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
                cell.progressBar.isUserInteractionEnabled = false
                cell.progressBar.advance(section: 1, by: Int(Double(storage_loadObject("ProjectApproved")!)!))
                cell.progressBar.advance(section: 2, by: Int(Double(storage_loadObject("ProjectRejected")!)!))
                cell.progressBar.advance(section: 0, by: Int(Double(storage_loadObject("ProjectTaken")!)!))
                cell.btnTakePhoto.addTarget(self, action: #selector(TakePhoto(_ :)), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }else{
                if Database.sharedInstance.categories.count > (indexPath.row) {
                    let category = Database.sharedInstance.categories[indexPath.row]
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
                        cell.progressBar.isUserInteractionEnabled = false
                        cell.progressBar.advance(section: 0, by: Int(category._takenPercent))
                        cell.progressBar.advance(section: 1, by: Int(category._approvedPercent))
                        cell.progressBar.advance(section: 2, by: Int(category._rejectedPercent))
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "rejectCell", for: indexPath) as! RejectCell
                        if category.IStatus == StatusEnum.TAKEPIC.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                            cell.imvIcon.image = #imageLiteral(resourceName: "ic_camera_gray")
                            cell.lblName.text = category.ItemName
                            cell.lblName.textColor = UIColor.appGrayColor
                            cell.imvSync.isHidden = true
                        }else if category.IStatus == StatusEnum.PICTAKEN.rawValue {
                            cell.imvIcon.image = #imageLiteral(resourceName: "ic_watch")
                            cell.lblName.text = category.ItemName
                            cell.lblName.textColor = UIColor.appBlueColor
                            cell.imvSync.isHidden = false
                        }else if category.IStatus == StatusEnum.UPLOADED.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                            cell.imvIcon.image = #imageLiteral(resourceName: "ic_watch")
                            cell.lblName.text = category.ItemName
                            cell.lblName.textColor = UIColor.appBlueColor
                            cell.imvSync.isHidden = true
                        }else if category.IStatus == StatusEnum.APPROVED.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                            cell.imvIcon.image = #imageLiteral(resourceName: "ic_verify")
                            cell.lblName.text = category.ItemName
                            cell.lblName.textColor = UIColor.appGreenColor
                            cell.imvSync.isHidden = true
                        }else if category.IStatus == StatusEnum.REJECTED.rawValue || category.IStatus == StatusEnum.RESETPHOTO.rawValue {
                            cell.imvIcon.image = #imageLiteral(resourceName: "ic_camera_red")
                            cell.lblName.text = category.ItemName
                            cell.lblName.textColor = UIColor.appRedColor
                            cell.imvSync.isHidden = true
                        }
                        return cell
                    }
                }else{
                    return UITableViewCell()
                }
            }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 136
        }else {
            if Database.sharedInstance.categories.count > (indexPath.row) {
                let category = Database.sharedInstance.categories[indexPath.row]
                if category.type == "Category" || category.type == "Sector" || category.type == "Position"{
                    return 90
                }else{
                    return 50
                }
            }else{
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
            return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Database.sharedInstance.categoriesStack.count == 0 {
            return UIView()
        }else{
            if section == 1 {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36))
                view.backgroundColor = UIColor(rgba: "#EBEBF1")
                let label = UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.size.width - 32, height: 36))
                var title = ""
                for cat in Database.sharedInstance.categoriesStack {
                    if title == "" {
                        title = cat
                    }else{
                        title = String(format: "%@ >> %@", title, cat)
                    }
                }
                label.text = title
                label.font = UIFont(name: "ProximaNovaSoft-Regular", size: 14.0)
                view.addSubview(label)
                return view
            }else {
                return UIView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if Database.sharedInstance.categoriesStack.count == 0 {
            return 0
        }else{
            if section == 1 {
                return 36
            }else{
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.section == 1 {
                let category = Database.sharedInstance.categories[indexPath.row]
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
                    Database.sharedInstance.navigationStack.append(navi)
                    Database.sharedInstance.categoriesStack.append(category.CategoryName)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "categoryVC") as! CategoriesViewController
                    self.navigationController?.pushViewController(vc, animated: true)
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
                    self.setTabBarVisible(visible: false, animated: true)

                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "takePhotoVC") as! TakePhotoViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

extension CategoriesViewController: MGSegmentedProgressBarDataSource,  MGSegmentedProgressBarDelegate {
    
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

extension CategoriesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! FolderDetailViewController
        vc.capturedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CategoriesViewController: TakenPhotoDelegate {
    func didUpdateTakenPhoto() {
        
    }
}
