//
//  LoginViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var viewControllerToInsertBelow : UIViewController?

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func NextButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
        if !validTextField() {
            return
        }
        self.showHUD()
        ApiRequest.login(self.txtUserName.text!, password: self.txtPassword.text!) { (message, data) in
            self.hideHUD()
            if let response = data as? AuthenticateModel {
                if response.status {
                    storage_saveObject("UserName", self.txtUserName.text!)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTab")  as! MainTabViewController
                    appDel.navigationController = self.navigationController
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.showErrorMessage("Login failed", title: TITLE)
                }
            }else{
                self.showErrorMessage("Login failed", title: TITLE)
            }
        }
    }
    
    func validTextField() -> Bool {
        if (self.txtUserName.text?.isEmpty)! {
            self.showErrorMessage("UserName cannot empty.", title: TITLE)
            return false
        }
        if (self.txtPassword.text?.isEmpty)! {
            self.showErrorMessage("Password cannot empty.", title: TITLE)
            return false
        }
        return true
    }

}

