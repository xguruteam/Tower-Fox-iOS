//
//  FolderDetailViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import Photos
import Toaster

protocol TakenPhotoDelegate {
    func didUpdateTakenPhoto()
}

class FolderDetailViewController: UIViewController {

    @IBOutlet weak var stack2: UIStackView!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgCapturedPhoto: UIImageView!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnDelete: MKCardView!
    @IBOutlet weak var btnSave: MKCardView!
    @IBOutlet weak var btnSaveAndReturn: MKCardView!
    @IBOutlet weak var btnDeleteAndContinue: MKCardView!
    var delegate: TakenPhotoDelegate!
    var detailText = ""
    var capturedImage: UIImage!
    var isAdhoc = false
    var isRLList = false
    var deletePhotoFlag = false
    var saveAndContinueFlag = false
    var imageNameStr = ""
    
    var galleryPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fulldate = DateFormatter()
        fulldate.dateFormat = "E MMM dd yyyy HH:mm:ss Z(z)"
        let date = Date()
        let fulldateString = fulldate.string(from: date)
        if storage_loadObject("Latitude") != nil {
            detailText = String(format: "Lat: %@\nLong: %@\n%@", storage_loadObject("Latitude")!, storage_loadObject("Longitude")!, fulldateString)
        }else{
            detailText = String(format: "Lat: 0\nLong: 0\n%@", fulldateString)
        }

        self.lblDetail.text = ""
        self.addNavigationItem()
        if storage_loadObject("ItemsCount") == nil || storage_loadObject("ItemsCount") == "" {
            storage_saveObject("ItemsCount", "0")
        }
        if !isRLList {
            if storage_loadObject("SectorID") != nil {
                if storage_loadObject("ItemsCount") == nil || storage_loadObject("ItemsCount") == "" {
                    if isAdhoc {
                        self.stack1.isHidden = true
                        self.stack2.isHidden = false
                    }else{
                        self.stack1.isHidden = false
                        self.stack2.isHidden = true
                        btnDeleteAndContinue.removeFromSuperview()
                    }
                }else{
                    if Int(storage_loadObject("SectorID")!)! > 0 {
                        if Int(storage_loadObject("ItemsCount")!)! > 1 && !isAdhoc {
                            self.stack1.isHidden = false
                            self.stack2.isHidden = true
                        }else if isAdhoc {
                            self.stack1.isHidden = true
                            self.stack2.isHidden = false
                        }else{
                            self.stack1.isHidden = false
                            self.stack2.isHidden = true
                            btnDeleteAndContinue.removeFromSuperview()
                        }
                    }else{
                        if Int(storage_loadObject("ItemsCount")!)! > 1 && !isAdhoc {
                            self.stack1.isHidden = false
                            self.stack2.isHidden = true
                        }else if isAdhoc {
                            self.stack1.isHidden = true
                            self.stack2.isHidden = false
                        }else{
                            self.stack1.isHidden = false
                            btnDeleteAndContinue.removeFromSuperview()
                            self.stack2.isHidden = true
                        }
                    }
                }
            }else{
                if storage_loadObject("ItemsCount") == nil || storage_loadObject("ItemsCount") == "" {
                    if Int(storage_loadObject("ItemsCount")!)! > 1 && !isAdhoc {
                        self.stack1.isHidden = false
                        self.stack2.isHidden = true
                    }else if isAdhoc {
                        self.stack1.isHidden = true
                        self.stack2.isHidden = false
                    }else{
                        self.stack1.isHidden = false
                        btnDeleteAndContinue.removeFromSuperview()
                        self.stack2.isHidden = true
                    }
                }else{
                    if Int(storage_loadObject("ItemsCount")!)! > 1 && !isAdhoc {
                        self.stack1.isHidden = false
                        self.stack2.isHidden = true
                    }else if isAdhoc {
                        self.stack1.isHidden = true
                        self.stack2.isHidden = false
                    }else{
                        self.stack1.isHidden = false
                        btnDeleteAndContinue.removeFromSuperview()
                        self.stack2.isHidden = true
                    }
                }
            }
        }else{
            self.stack1.isHidden = false
            self.stack2.isHidden = true
        }
        self.capturedImage = self.drawImagesAndText(self.capturedImage)
        self.imgCapturedPhoto.image = self.capturedImage
       let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/dd/yyyy, hh:mm:ss a"
        storage_saveObject("TakenDate", dateformatter.string(from: date))
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
    
    func drawImagesAndText(_ image: UIImage) ->UIImage {
        // 1
        let maxWidth = storage_loadObject("targetMaxImageCaptureWidth") != nil ? storage_loadObject("targetMaxImageCaptureWidth"): "3000"
        let maxHeight = storage_loadObject("targetMaxImageCaptureHeight") != nil ? storage_loadObject("targetMaxImageCaptureHeight") : "3000"
        let currentSize = self.capturedImage.size
        let wf = currentSize.width / CGFloat(Int(maxWidth!)!)
        let hf = currentSize.height / CGFloat(Int(maxHeight!)!)
        var realsize: CGSize!
        if wf > 1 || hf > 1{
            if wf > hf {
                realsize = CGSize(width: CGFloat(Int(maxWidth!)!), height: currentSize.height / wf)
            }else{
                realsize = CGSize(width: currentSize.width / hf, height:  CGFloat(Int(maxHeight!)!))
            }
        }else{
            realsize = currentSize
        }
        let scaledImage = self.resizeImage(image: image, targetSize: realsize)
        UIGraphicsBeginImageContextWithOptions(scaledImage.size, false, 1)
        scaledImage.draw(at: CGPoint(x: 0, y: 0))
        let textheight = scaledImage.size.width / 30
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = textheight / 15
        myShadow.shadowOffset = CGSize(width: textheight / 15, height: textheight / 15)
        myShadow.shadowColor = UIColor.black
        let attrs = [NSAttributedStringKey.font: UIFont(name: "ProximaNovaSoft-Bold", size: textheight)!, NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.shadow: myShadow]
        detailText.draw(in: CGRect(x: 0, y: scaledImage.size.height - (textheight + 4) * 3, width: scaledImage.size.width - 6, height: (textheight + 4) * 3), withAttributes: attrs)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    func saveCapturedImage(_ image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("CapturedPhotos/\(imageNameStr)")
            try? data.write(to: fileURL)
            storage_saveObject("ImageName", imageNameStr)
            if isAdhoc {
                Database.sharedInstance.insertAdhocPhotoDataDB { (success) in
                    appDel.hideHUD()
                   if success {
                        if self.saveAndContinueFlag {
                            Database.sharedInstance.getNextItemToDisplay(completionHandler: { (data) in
                                self.dismiss(animated: true, completion: {
                                    if self.delegate != nil {
                                        self.delegate.didUpdateTakenPhoto()
                                    }
                                })
                            })
                        }else if self.isRLList {
                            Database.sharedInstance.isFromBagroundSync = true
                            Sync.sharedInstance.uploadDataToServer()
                            self.dismiss(animated: true, completion: {
                                if self.delegate != nil {
                                    self.delegate.didUpdateTakenPhoto()
                                }
                            })
                        }else{
                            Sync.sharedInstance.uploadDataToServer()
                            self.dismiss(animated: true, completion: {
                                if self.delegate != nil {
                                    self.delegate.didUpdateTakenPhoto()
                                }
                            })
                        }
                    }
                }
            }else{
                Database.sharedInstance.updateImageTakenData { (success) in
                    appDel.hideHUD()
                    if success {
                        if self.saveAndContinueFlag {
                            Database.sharedInstance.getNextItemToDisplay(completionHandler: { (data) in
                                self.dismiss(animated: true, completion: {
                                    if self.delegate != nil {
                                        self.delegate.didUpdateTakenPhoto()
                                    }
                                })
                            })
                        }else if self.isRLList {
                            Database.sharedInstance.isFromBagroundSync = true
                            Sync.sharedInstance.uploadDataToServer()
                            self.dismiss(animated: true, completion: {
                                if self.delegate != nil {
                                    self.delegate.didUpdateTakenPhoto()
                                }
                            })
                        }else{
                            Sync.sharedInstance.uploadDataToServer()
                            self.dismiss(animated: true, completion: {
                                if self.delegate != nil {
                                    self.delegate.didUpdateTakenPhoto()
                                }
                            })
                        }
                    }
                }
            }
        }

        // save to gallery
        // Skip for now, photos will be saved to gallery automatically after sync
//        PHPhotoLibrary.shared().save(image: image, path: storage_loadObject("ProjectID")!) { (asset) in
//            DispatchQueue.main.async {
//                if let asset = asset {
//                    let toast  = Toast(text: "Successfully saved photo to Photos Gallery", duration: Delay.short)
//                    ToastView.appearance().backgroundColor = UIColor.appMainColor
//                    ToastView.appearance().textColor = .white
//                    ToastView.appearance().font = UIFont(name: "ProximaNovaSoft-Regular", size: 14)
//                    toast.show()
//                }
//                else {
//                    let toast  = Toast(text: "Failed to save photo to Photos Gallery", duration: Delay.short)
//                    ToastView.appearance().backgroundColor = UIColor.appRedColor
//                    ToastView.appearance().textColor = .white
//                    ToastView.appearance().font = UIFont(name: "ProximaNovaSoft-Regular", size: 14)
//                    toast.show()
//                }
//            }
//        }
    }

    
    @IBAction func CancelButtonClicked(_ sender: MKCardView) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func NextButtonClicked(_ sender: Any) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DeleteAndReturnButtonClicked(_ sender: MKCardView) {
        appDel.showHUD("Synchronizing", subtext: "Please wait")
       if deletePhotoFlag {
        appDel.hideHUD()
            deletePhotoFlag = false
            self.backTwo()
            Database.sharedInstance.uploadData()
        }
    }
    
    @IBAction func DeleteAndContinueButtonClicked(_ sender: MKCardView) {
        appDel.showHUD("Synchronizing", subtext: "Please wait")
        if deletePhotoFlag {
            deletePhotoFlag = false
            Database.sharedInstance.getNextItemToDisplay { (data) in
                appDel.hideHUD()
                self.dismiss(animated: true, completion: {
                    if self.delegate != nil {
                        self.delegate.didUpdateTakenPhoto()
                    }
                })
            }
        }
        else
        {
            if isAdhoc {
                storage_saveObject("ItemID", "0")
            }
            saveAndContinueFlag = true
            imageNameStr = "\(storage_loadObject("ProjectID")!)_\(storage_loadObject("ParentID")!)_\(storage_loadObject("ItemID")!)_\(storage_loadObject("SectorID")!)_\(storage_loadObject("PositionID")!)_\(dateConversion()).jpg"
            self.saveCapturedImage(self.capturedImage)
        }

    }
    
    @IBAction func DeletePhotoButtonClicked(_ sender: MKCardView) {
        let alertController = UIAlertController(title: "Attention", message: "Are you sure you want to delete the photo?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.deletePhotoFlag = true
            appDel.showHUD("Synchronizing", subtext: "Please wait")
            if Int(storage_loadObject("PhotoStatus")!)! != StatusEnum.TAKEPIC.rawValue {
                self.resetPhoto()
            }
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            self.deletePhotoFlag = false
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func SaveAndReturnButtonClicked(_ sender: MKCardView) {
        appDel.showHUD("Synchronizing", subtext: "Please wait")
        if deletePhotoFlag {
            deletePhotoFlag = false
            self.backTwo()
            Database.sharedInstance.uploadData()
            appDel.hideHUD()
            if delegate != nil {
                delegate.didUpdateTakenPhoto()
            }
        }
        else
        {
            if isAdhoc {
                storage_saveObject("ItemID", "0")
            }
            saveAndContinueFlag = false
            imageNameStr = "\(storage_loadObject("ProjectID")!)_\(storage_loadObject("ParentID")!)_\(storage_loadObject("ItemID")!)_\(storage_loadObject("SectorID")!)_\(storage_loadObject("PositionID")!)_\(dateConversion()).jpg"
            self.saveCapturedImage(self.capturedImage)
        }

    }
    
    
    func dateConversion() -> String
    {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM-DD-YYYY-HH:mm:ss"
        var shortDate = dateformat.string(from: Date())
        shortDate = shortDate.replacingOccurrences(of: "-", with: "_")
        shortDate = shortDate.replacingOccurrences(of: "/", with: "_")
        shortDate = shortDate.replacingOccurrences(of: ":", with: "_")
        shortDate = shortDate.replacingOccurrences(of: " ", with: "_")

        return shortDate
    }
        
    func resetPhoto() {
        Database.sharedInstance.resetPhoto { (success) in
            appDel.hideHUD()
            if success {
                self.dismiss(animated: true, completion: {
                    if self.delegate != nil {
                        self.delegate.didUpdateTakenPhoto()
                    }
                })
            }
        }
    }

}
