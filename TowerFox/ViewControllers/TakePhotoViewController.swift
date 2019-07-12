//
//  TakePhotoViewController.swift
//  CloseOut
//
//  Created by cgc on 8/24/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import CropViewController

class CustomPhotoModel: NSObject, INSPhotoViewable {
    var image: UIImage?
    
    var thumbnailImage: UIImage?
    
    func loadImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        completion(image, nil)
    }
    
    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        completion(thumbnailImage, nil)
    }
    
    var attributedTitle: NSAttributedString?
}

class TakePhotoViewController: UIViewController {

    @IBOutlet weak var btnRejectionDetails: MKCardView!
    @IBOutlet weak var rejectionDetailHeight: NSLayoutConstraint!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var btnTakePhoto: MKButton!
    var isAdhocPhoto = false
    
    var galleryPath = ""
    
    var photoDetail: [String: Any]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice().iPhoneX {
            btnTakePhoto.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 40, right: 10)
        }
        
        addNavigationButton()
        // Do any additional setup after loading the view.
        imvPhoto.isUserInteractionEnabled = true
        imvPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(handleZoomTap)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Database.sharedInstance.getItemsCountInSelectedCategory(completionHandler: { _ in
            self.checkPhotosDetail()
        } )
    }
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        
        if let _ = imvPhoto.image {
            let textColor = UIColor.white
            let textFont = UIFont(name: "ProximaNovaSoft-Semibold", size: 16)!
            
            let textFontAttributes = [
                NSAttributedStringKey.font: textFont,
                NSAttributedStringKey.foregroundColor: textColor,
                ] as [NSAttributedStringKey : Any]
            let caption = NSAttributedString(string: lblItemName.text ?? "", attributes: textFontAttributes)
            let photo = CustomPhotoModel()
            photo.image = imvPhoto.image
            photo.attributedTitle = caption
            
            let photos: [INSPhotoViewable] = [
                photo
            ]
            
            let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: nil, referenceView: imvPhoto)
            galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [unowned self] _ in
                return self.imvPhoto
            }
            present(galleryPreview, animated: true, completion: nil)
        }
    }
    
    func addNavigationButton() {
        self.navigationItem.title = "Take Photo"

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
        backView.addTarget(self, action: #selector(BackButtonClicked(_:)), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: backView)
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = [backItem]
        
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
    }
    
    func checkPhotosDetail() {
        Database.sharedInstance.getPhotoDetail { (data) in
            print(data)
            self.photoDetail = data
            self.updatePhotoDetail()
        }
    }

    func updatePhotoDetail()  {
        if Int(photoDetail["Status"] as! Int64) == StatusEnum.REJECTED.rawValue {
            rejectionDetailHeight.constant = 44
            btnRejectionDetails.isHidden = false
            storage_saveObject("Description", photoDetail["Description"] as! String)
            storage_saveObject("Comments", (photoDetail["Comments"] != nil) ? photoDetail["Comments"] as! String: "")
            storage_saveObject("ReviewerName", (photoDetail["ReviewerName"] != nil) ? photoDetail["ReviewerName"] as! String: "")
            storage_saveObject("ReviewDate",(photoDetail["ReviewDate"] != nil) ? photoDetail["ReviewDate"] as! String: "")
            storage_saveObject("PhotoStatus", (photoDetail["PhotoStatus"] != nil) ? photoDetail["PhotoStatus"] as! String: "")
        }else{
            rejectionDetailHeight.constant = 0
            btnRejectionDetails.isHidden = true
            
        }
        storage_saveObject("ItemName", photoDetail["ItemName"] as! String)
        storage_saveObject("Description", photoDetail["Description"] as! String)
        
        if Int(photoDetail["Status"] as! Int64) == StatusEnum.APPROVED.rawValue ||  Int(photoDetail["Status"] as! Int64) == StatusEnum.PICTAKEN.rawValue || Int(photoDetail["Status"] as! Int64) == StatusEnum.UPLOADED.rawValue {
            self.lblDescription.text = "Captured Image"
            if (photoDetail["CapturedImageName"] as! String) == "Sample.jpg" {
                self.imvPhoto.image = nil
            }else{
                let imageurl = String(format: "CapturedPhotos/%@", photoDetail["CapturedImageName"] as! String)
//                self.imvPhoto.image = UIImage(contentsOfFile: imageurl)
                self.imvPhoto.sd_setImage(with: IMAGE_LOCATION_PATH.appendingPathComponent(imageurl), placeholderImage: nil, options: [], completed: nil)
            }
        }else{
            self.lblDescription.text = "Example Photo"
            let imageurl = String(format: "ReferencePhotos/%@", photoDetail["ReferenceImageName"] as! String)
            self.imvPhoto.sd_setImage(with: IMAGE_LOCATION_PATH.appendingPathComponent(imageurl), placeholderImage: nil, options: [], completed: nil)
        }
        if Int(photoDetail["Status"] as! Int64) == StatusEnum.APPROVED.rawValue {
            self.btnTakePhoto.isHidden = true
        }else{
            self.btnTakePhoto.isHidden = false
            self.navigationItem.rightBarButtonItems = []
        }
        storage_saveObject("Description",photoDetail["Description"] as! String)
        storage_saveObject("Comments",photoDetail["Comments"] as Any)
        storage_saveObject("ReviewerName",photoDetail["TakenBy"] as! String)
        storage_saveObject("ReviewDate",photoDetail["TakenDate"] as! String)
        storage_saveObject("PhotoStatus", Int(photoDetail["Status"] as! Int64))
        Database.sharedInstance.getLocationMatrix(adhocPhotoID: self.photoDetail!["AdhocPhotoID"] as! String, categoryRelationID: self.photoDetail!["ParentCategoryID"] as! String) { (d) in
            self.lblCategoryName.text = d
            let dirs = d.split(separator: ">").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            self.galleryPath = dirs.joined(separator: "/")
            return
        }
        lblItemName.text = photoDetail["Description"] as? String
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func BackButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func TopButtonClicked(_ sender: MKCardView) {
        self.view.endEditing(true)
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
    
    @IBAction func TakePhotoButtonClicked(_ sender: MKButton) {
        if storage_loadObject("SYNC") == "TRUE" {
            showErrorMessage("Synchronizing, Please wait...", title: "Please wait")
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.showErrorMessage("Camera not Available", title: "Carmera Error")
                return
            }
            let imageController = UIImagePickerController()
            imageController.allowsEditing = false
            imageController.sourceType = UIImagePickerControllerSourceType.camera
            imageController.cameraFlashMode = .auto
            imageController.delegate = self
            self.present(imageController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.showErrorMessage("Photos not Available", title: "Library Error")
                return
            }
            let imageController = UIImagePickerController()
            imageController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imageController.delegate = self
            self.present(imageController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func RejectionDetailClicked(_ sender: MKCardView) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "rejectionDetailVC") as! RejectionDetailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "ProximaNovaSoft-Regular", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}

extension TakePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TakePhotoViewController: TakenPhotoDelegate {
    func didUpdateTakenPhoto() {
    }
}

extension TakePhotoViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! FolderDetailViewController
            vc.capturedImage = image
            vc.isAdhoc = false
            vc.delegate = self
            vc.galleryPath = self.galleryPath
            self.present(vc, animated: true, completion: nil)
        }
        cropViewController.delegate = nil //to avoid memory leaks
    }
}
