//
//  SyncProgressViewController.swift
//  CloseOut
//
//  Created by cgc on 9/4/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
protocol SyncProgressViewControllerDelegate {
    func close()
}
class SyncProgressViewController: UIViewController {

    var delegate: SyncProgressViewControllerDelegate!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var viewprogress: UIView!
    @IBOutlet weak var contentView: MKCardView!
    var showValue: Bool = false
    var progressView: LDProgressView!
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView = LDProgressView(frame: CGRect(x: 0, y: 0, width: self.viewprogress.frame.size.width, height: 16))
        progressView.color = UIColor.appBlueColor
        progressView.flat = true
        progressView.showBackgroundInnerShadow = true
        progressView.progress = 1
        progressView.animate = true
        progressView.borderRadius = 1
        progressView.animateDirection = LDAnimateDirection.backward
        self.viewprogress.addSubview(progressView)
        // Do any additional setup after loading the view.
    }
    
    @objc func updateTimer() {
        if appDel.dismiss {
            dismiss(animated: true, completion: {
                appDel.isProgressViewShowing = false
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_ :)), name: NSNotification.Name(rawValue: "UpdateProgress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close(_ :)), name: NSNotification.Name(rawValue: "closeProgress"), object: nil)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.timer != nil {
            if self.timer.isValid {
                self.timer.invalidate()
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func setTitle(_ text: String) {
        self.lbltitle.text = text
    }
    
    func setProgress(_ text: String){
    }
    
    @objc func updateProgress( _ noti: Notification) {
        let userinfo = noti.object as! [String: Any]
        var progress = 0
        if userinfo["progress"] != nil {
            progress = userinfo["progress"] as! Int
        }
        let title = userinfo["title"] as! String
        self.setTitle(title)
        self.progressView.progress = CGFloat(Double(progress) / 100.0)
    }
    
    @objc func close( _ noti: Notification) {
        dismiss(animated: true, completion: {
            appDel.isProgressViewShowing = false
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
