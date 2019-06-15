//
//  SettingsViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import MessageUI
class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: Int = 0
    let sections:[String] = ["About CloseOut", "Support", "Sync Server Address", "Account"]
    var txtServerIP: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if storage_loadObject("setting_index") != nil {
            self.selectedIndex = Int(storage_loadObject("setting_index")!)!
        }else{
            self.selectedIndex = 0
            storage_saveObject("setting_index", "0")
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)

    }
    
    @objc func changeSyncServer(_ sender: MKButton) {
        self.view.endEditing(true)
        let position = sender.convert(CGPoint(), to: self.tableView)
        _ = self.tableView.indexPathForRow(at: position)
        let ip = self.txtServerIP.text
        if ip != storage_loadObject("SERVER_IP") {
            let alertController = UIAlertController(title: "IP Address", message: "Changeing IP Address clears your Local Data. Do you want to change IP?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "YES", style: .cancel) { (_) in
                self.checkConnectivity(ip!)
            }
            let cancelAction = UIAlertAction(title: "NO", style: .default) { (_) in
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }else{
            self.showErrorMessage("Please Enter Different IP Address", title: "Error")
        }
        
    }
    
    func checkConnectivity(_ ip: String) {
        self.view.endEditing(true)
        self.showHUD()
        ApiRequest.serverConnectivityTest(ip) { (message, data) in
            self.hideHUD()
            if let response = data as? ResponseModel {
                if response.status! {
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    Database.sharedInstance.projectsGlobalArray = []
                    storage_saveObject("SERVER_IP", ip)
                    storage_saveObject("change_server", "true")
                    Database.sharedInstance.cleanDBQuery {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "rootNav") as! UINavigationController
                        appDel.window?.rootViewController = vc
                        appDel.window?.makeKeyAndVisible()
                    }
                }else{
                    self.showErrorMessage("Server IP address is not valid", title: TITLE)
                }
            }else{
                self.showErrorMessage("Server IP address is not valid", title: TITLE)
            }
        }

    }
    

    @objc func Logout() {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: "Logout", message: "Changing User clears your Local Data. Do you want to change User?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "YES", style: .cancel) { (_) in
            self.sendLogoutDeviceInfo()
        }
        let cancelAction = UIAlertAction(title: "NO", style: .default) { (_) in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)

    }
    
    func sendLogoutDeviceInfo() {
        Sync.sharedInstance.sendLogoutDeviceInfo { (b, message) in
            if message != "" {
                self.showErrorMessage(message, title: "Error")
            }else{
                Database.sharedInstance.cleanDBQuery {
                    let ip = storage_loadObject("SERVER_IP")
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    storage_saveObject("SERVER_IP", ip!)
                    Database.sharedInstance.projectsGlobalArray = []
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "rootNav") as! UINavigationController
                    appDel.window?.rootViewController = vc
                    appDel.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    @objc func OnCheckClicked(_ sender: MKButton) {
        self.view.endEditing(true)
        let phone = "16025403771"
        let alert = UIAlertController(title: "Support Call", message: "Call the Help Desk for assistance at 602-540-3771", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
        }
        let call = UIAlertAction(title: "Call", style: .default) { (_) in
            phone.makeACall()
        }
        alert.addAction(ok)
        alert.addAction(call)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func SendLogEmail( _ sender: MKButton) {
        self.view.endEditing(true)
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.setSubject("CMP Support Request")
            vc.delegate = self
            vc.mailComposeDelegate = self
            vc.setToRecipients(["info@foxridgellc.com"])
            vc.setMessageBody("Hi\nPlease describe your issue below this line:", isHTML: false)
            self.present(vc, animated: true, completion: nil)
        }else{
            self.showErrorMessage("No mail account found", title: TITLE)
        }
    }
    
    func removeSync() {
        self.view.endEditing(true)

    }
}

extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedIndex == section {
            return 1
        }else{
            return 0
        }
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell\(indexPath.section + 1)"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            let cell1 = cell as! AboutCell
            cell1.lblVersion.text = String(format: "Version %@",  (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String))
            cell1.lblDeviceModel.text = String(format: "Devce Model: %@", UIDevice.current.model)
            cell1.lblPlatform.text = "CloseOut for iOS"
            cell1.lblDeviceVersion.text = String(format: "Device Version: %@", UIDevice.current.systemVersion)
        }else if indexPath.section == 2 {
            let cell2 = cell as! ServerAddressCell
            cell2.lblServerIPAddress.text = storage_loadObject("SERVER_IP")
            self.txtServerIP = cell2.lblServerIPAddress
            cell2.btnChangeSyncServer.addTarget(self, action: #selector(changeSyncServer(_ :)), for: .touchUpInside)
        }else if indexPath.section == 3 {
            let cell3 = cell as! AccountCell
            cell3.lblUserName.text = storage_loadObject("UserName")
            cell3.btnLogout.addTarget(self, action: #selector(Logout), for: .touchUpInside)
        }else if indexPath.section == 1 {
            let cell4 = cell as! LogCell
            cell4.btnCall.addTarget(self, action: #selector(OnCheckClicked(_ :)), for: .touchUpInside)
            cell4.btnRequest.addTarget(self, action: #selector(SendLogEmail(_ :)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section]
        header.setCollapsed(self.selectedIndex == section)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
}

//
// MARK: - Section Header Delegate
//
extension SettingsViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        if self.selectedIndex == section {
            self.selectedIndex = -1
        }else{
            self.selectedIndex = section
        }
        storage_saveObject("setting_index", String(format: "%d", self.selectedIndex))
        header.setCollapsed(self.selectedIndex == -1)
        self.tableView.reloadData()
//        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
class AboutCell: UITableViewCell {
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblPlatform: UILabel!
    @IBOutlet weak var lblDeviceModel: UILabel!
    @IBOutlet weak var lblDeviceVersion: UILabel!
}

class ServerAddressCell: UITableViewCell {
    @IBOutlet weak var lblServerIPAddress: UITextField!
    @IBOutlet weak var btnChangeSyncServer: UIButton!
}

class AccountCell: UITableViewCell {
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var btnLogout: UIButton!
}

class LogCell: UITableViewCell {
    @IBOutlet weak var btnRequest: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    
}

extension SettingsViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == MFMailComposeResult.sent {
            
        }else{
            
        }
        if error != nil {
            showErrorMessage(error?.localizedDescription, title: TITLE)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
