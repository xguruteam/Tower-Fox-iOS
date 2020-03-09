//
//  RejectedListViewController.swift
//  CloseOut
//
//  Created by cgc on 9/5/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class RejectedListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var rejects: [RejectDisplayModel] = []
    var rejectDisplayList: [[RejectDisplayModel]] = []
    var rejectHeaders:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = "Rejected List"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarVisible(visible: true, animated: true)
        self.checkReject()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkReject() {
        
//        appDel.updateProgressView("Syncronizing , Please wait", progress: 0, total: 100 )
        self.showHUD()
        Database.sharedInstance.displayRejects { (results) in
            self.rejects = results
            self.rejectHeaders.removeAll()
            self.rejectDisplayList.removeAll()
            
            var rejectArr: [RejectDisplayModel] = []
            var header: String = ""
            var prev: RejectDisplayModel!

            var tempArr:[[String: Any]] = []
            
            for rej in self.rejects {
                if prev != nil {
                    if prev.ProjectID == rej.ProjectID && prev.CategoryName == rej.CategoryName {
                        rejectArr.append(rej)
                    }else{
                        rejectArr.sort(by: { (first, second) -> Bool in
                            let name1 = first.ItemName!
                            let name2 = second.ItemName!
                            let result = name1.compare(name2)
                            return result == .orderedAscending
                        })
                        tempArr.append(["header": header, "arr": rejectArr])
                        header = String(format: "%@ >> %@", rej.ProjectID, rej.CategoryName)
                        rejectArr.removeAll()
                        rejectArr.append(rej)
                    }
                }else{
                    header = String(format: "%@ >> %@", rej.ProjectID, rej.CategoryName)
                    rejectArr.removeAll()
                    rejectArr.append(rej)
                }
                prev = rej
            }
            if header.count > 0 {
                rejectArr.sort(by: { (first, second) -> Bool in
                    let name1 = first.ItemName!
                    let name2 = second.ItemName!
                    let result = name1.compare(name2)
                    return result == .orderedAscending
                })
                tempArr.append(["header": header, "arr": rejectArr])
            }
            
            tempArr.sort(by: { (first, second) -> Bool in
                let header1 = first["header"] as! String
                let header2 = second["header"] as! String
                let result = header1.compare(header2)
                return result == .orderedAscending
            })
            
            (self.rejectHeaders, self.rejectDisplayList) = tempArr.reduce(into: (self.rejectHeaders, self.rejectDisplayList), { (result, item) in
                var (headers, displayList) = result
                let header = item["header"] as! String
                let list = item["arr"] as!  [RejectDisplayModel]
                headers.append(header)
                displayList.append(list)
                result = (headers, displayList)
            })
            
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            self.tableView.reloadData()
            self.hideHUD()
        }
    }
    

}

extension RejectedListViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.rejectHeaders.count == 0 {
            self.emptyView.isHidden = false
        }else{
            self.emptyView.isHidden = true
        }
        return self.rejectHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rejectDisplayList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reject = self.rejectDisplayList[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "rejectCell", for: indexPath) as! RejectCell
        cell.lblName.text = reject.ItemName
        cell.lblName.textColor  = UIColor.appRedColor
        cell.imvIcon.image = #imageLiteral(resourceName: "ic_camera_red")
        cell.imvSync.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.rejectHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 36))
        view.backgroundColor = UIColor.appTblHeadBackColor
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: self.view.frame.size.width - 32, height: 36))
        label.text = self.rejectHeaders[section]
        label.font = UIFont(name: "ProximaNovaSoft-Regular", size: 14.0)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reject = self.rejectDisplayList[indexPath.section][indexPath.row]
            storage_saveObject("ItemID", reject.ItemID)
            storage_saveObject("AdhocPhotoID", reject.AdhocPhotoID)
            storage_saveObject("ParentID", reject.CategoryID);
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

