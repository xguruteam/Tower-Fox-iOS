//
//  ViewController.swift
//  CloseOut
//
//  Created by cgc on 8/23/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class ServiceViewController: UIViewController {
    let progressBar = MGSegmentedProgressBar()
    @IBOutlet weak var ipView: UIView!
    @IBOutlet weak var txtServerIP: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel.navigationController = self.navigationController
        if storage_loadObject("SERVER_IP") != nil || storage_loadObject("change_server") != nil{
            self.txtServerIP.text = storage_loadObject("SERVER_IP")
            storage_removeItem("change_server")
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func NextButtonClicked(_ sender: MKCardView) {
        if !validTextField() {
            return
        }
        self.view.endEditing(true)
        self.showHUD()
        ApiRequest.serverConnectivityTest(self.txtServerIP.text!) { (message, data) in
            self.hideHUD()
            if let response = data as? ResponseModel {
                if response.status! {
                    storage_saveObject("SERVER_IP", self.txtServerIP.text!)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.showErrorMessage("Server IP address is not valid", title: TITLE)
                }
            }else{
                self.showErrorMessage("Server IP address is not valid", title: TITLE)
            }
        }
    }
    
    func validTextField() -> Bool {
        if (self.txtServerIP.text?.isEmpty)! {
            self.showErrorMessage("ServerIP cannot empty.", title: TITLE)
            return false
        }
        return true
    }
    
}

extension ServiceViewController: MGSegmentedProgressBarDataSource,  MGSegmentedProgressBarDelegate {
    
    func progressBar(_ progressBar: MGSegmentedProgressBar, barForSection section: Int) -> MGBarView {
        let bar =  MGBarView()
        bar.backgroundColor = section % 2 == 0 ? UIColor.appGreenColor : UIColor.appRedColor
        return bar
    }
    
    func numberOfSections(in progressBar: MGSegmentedProgressBar) -> Int {
        return 2
    }
    
    func numberOfSteps(in progressBar: MGSegmentedProgressBar) -> Int {
        return 100
    }
    
}
