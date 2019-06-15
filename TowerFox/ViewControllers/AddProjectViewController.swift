//
//  AddProjectViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class AddProjectViewController: UIViewController {
    var sync: Sync!
    var projects: [ProjectModel] = []
    @IBOutlet weak var txtProjectId: UITextField!
    var mainVC: MainViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Project"
        NotificationCenter.default.addObserver(self, selector: #selector(SyncNewProjectDB(_:)), name: Notification.Name("SyncNewProjectDB"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SyncNewProjectDBFailed(_:)), name: Notification.Name("SyncNewProjectDBFailed"), object: nil)

        addNavigationItem()
        // Do any additional setup after loading the view.
    }
    
    func addNavigationItem()  {
        let backView = MKCardView(frame: CGRect(x: 0, y: 0, width: 66, height: 36))
        let backimage = UIImageView(image: #imageLiteral(resourceName: "ic_back"))
        backimage.frame = CGRect(x: 0, y: 0, width: 16, height: 36)
        backimage.contentMode = .center
        let backTitle = UILabel(frame: CGRect(x: 16, y: 0, width: 50, height: 36))
        backTitle.text = "Cancel"
        backTitle.font = UIFont(name: "ProximaNovaSoft-Regular", size: 16.0)
        backTitle.textColor = UIColor.white
        backView.addSubview(backimage)
        backView.addSubview(backTitle)
        backView.addTarget(self, action: #selector(CancelButtonClicked(_:)), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: backView)
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = [backItem]
        
        let nextView = MKCardView(frame: CGRect(x: 0, y: 0, width: 56, height: 36))
        let nextImage = UIImageView(image: #imageLiteral(resourceName: "ic_right"))
        nextImage.frame = CGRect(x: 40, y: 0, width: 16, height: 36)
        nextImage.contentMode = .center
        let nextTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 36))
        nextTitle.text = "Next"
        nextTitle.textAlignment = .right
        nextTitle.font = UIFont(name: "ProximaNovaSoft-Regular", size: 16.0)
        nextTitle.textColor = UIColor.white
        nextView.addSubview(nextImage)
        nextView.addSubview(nextTitle)
        nextView.addTarget(self, action: #selector(NextButtonClicked(_:)), for: .touchUpInside)
        let nextItem = UIBarButtonItem(customView: nextView)
        self.navigationItem.rightBarButtonItems = [nextItem]

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarVisible(visible: false, animated: true)
    }
    
    @objc func SyncNewProjectDB(_ noti: Notification) {
        appDel.hideHUD()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func SyncNewProjectDBFailed(_ noti: Notification) {
        appDel.hideHUD()
        self.showErrorMessage("Add New Project Failed, Please try again", title: "Add Project")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CancelButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func NextButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
        if storage_loadObject("SYNC") != "" {
            showErrorMessage("Synchronizing, Please wait...", title: "Please wait")
            return
        }
        if !(self.txtProjectId.text?.isEmpty)! {
            if storage_loadObject(self.txtProjectId.text!) != nil {
                showErrorMessage("Project already exist", title: "Warning!")
            }else{
                storage_saveObject("ProjectID", self.txtProjectId.text!)
                self.sync = Sync()
                appDel.showHUD("Sending Device Detail", subtext: "Please wait...")
                self.sendDeviceInfo()
            }
        }
    }
    
    func sendDeviceInfo() {
        sync.sendDeviceInfo { (status, message) in
            if status {
                self.getProjects()
            }else{
                appDel.hideHUD()
                self.showErrorMessage(message, title: TITLE)
            }
        }
    }

    func getProjects() {
        Sync.sharedInstance.SyncProjects { (status, message, data) in
            if status {
                if data.count > 0 {
                    Sync.sharedInstance.syncProjectCategories(0)
//                    Sync.sharedInstance.SyncCategories(data, completionHandler: {
//                        Sync.sharedInstance.syncSector {
//                            Sync.sharedInstance.syncPosition {
//                                appDel.hideHUD()
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        }
//                    })
                }else{
                    appDel.hideHUD()
                    self.showErrorMessage("Could not find this project identifier", title: TITLE)
                }
            }else{
                appDel.hideHUD()
                self.showErrorMessage(message, title: TITLE)
            }
        }
    }
    
    
}
