//
//  PhotosViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class RejectionDetailViewController: UIViewController {

    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblReviewerComment: UILabel!
    @IBOutlet weak var lblReviewerID: UILabel!
    @IBOutlet weak var lblReviewedData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationButton()
        updateView()
    }
    
    func updateView(){
        let itemName = storage_loadObject("ItemName");
        let comments = storage_loadObject("Comments");
        let reviewerName = (storage_loadObject("ReviewerName") != nil) ? storage_loadObject("ReviewerName") : "";
        let reviewDate = (storage_loadObject("ReviewDate") != nil) ? storage_loadObject("ReviewDate") : "";
        self.lblItemName.text = itemName
        self.lblReviewerID.text = reviewerName
        self.lblReviewerComment.text = comments
        self.lblReviewedData.text = reviewDate

    }

    func addNavigationButton() {
        self.navigationItem.title = "Rejection Details"
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func BackButtonClicked( _ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


}
