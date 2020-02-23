//
//  TakeNewPhotoViewController.swift
//  CloseOut
//
//  Created by cgc on 9/6/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class TakeNewPhotoViewController: UIViewController {

    @IBOutlet weak var txtCategory: UILabel!
    @IBOutlet weak var txtPhotoName: UITextField!
    @IBOutlet weak var txtPhotoDescription: GrowingTextView!
    @IBOutlet weak var btnTakePhoto: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice().iPhoneX {
            btnTakePhoto.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 40, right: 10)
        }
        
        self.addNavigationItem()
        var title = ""
        for cat in Database.sharedInstance.categoriesStack {
            if title == "" {
                title = cat
            }else{
                title = String(format: "%@ >> %@", title, cat)
            }
        }

        self.txtCategory.text = title
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func TakePhotoButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if (txtPhotoName.text?.isEmpty)! {
            self.showErrorMessage("Photo Name is required.", title: "Photo Name Error")
            return
        }
        if (txtPhotoDescription.text?.isEmpty)! {
            self.showErrorMessage("Photo Description is required.", title: "Photo Description Error")
            return
        }
        let splChars = "\\/:*?\"<>|#%.+"
        for ch in splChars {
            if (txtPhotoName.text?.contains(ch))! {
                self.showErrorMessage("The following special characters are not allowed in the photo name: \n / : * \" ? <> | # % . + \n Please remove them and retry.", title: "Warning!")
                return
            }
        }
        for ch in splChars {
            if (txtPhotoDescription.text?.contains(ch))! {
                self.showErrorMessage("The following special characters are not allowed in the photo description: \n / : * \" ? <> | # % . + \n Please remove them and retry.", title: "Warning!")
                return
            }
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
    
    
    func addNavigationItem()  {
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
        backView.addTarget(self, action: #selector(CancelButtonClicked(_:)), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: backView)
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = [backItem]
//        
//        let nextView = MKCardView(frame: CGRect(x: 0, y: 0, width: 56, height: 36))
//        let nextImage = UIImageView(image: #imageLiteral(resourceName: "ic_right"))
//        nextImage.frame = CGRect(x: 40, y: 0, width: 16, height: 36)
//        nextImage.contentMode = .center
//        let nextTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 36))
//        nextTitle.text = "Next"
//        nextTitle.textAlignment = .right
//        nextTitle.font = UIFont(name: "ProximaNovaSoft-Regular", size: 16.0)
//        nextTitle.textColor = UIColor.white
//        nextView.addSubview(nextImage)
//        nextView.addSubview(nextTitle)
//        nextView.addTarget(self, action: #selector(NextButtonClicked(_:)), for: .touchUpInside)
//        let nextItem = UIBarButtonItem(customView: nextView)
//        self.navigationItem.rightBarButtonItems = [nextItem]
//        
    }
    
    
    @objc func CancelButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    

}
extension TakeNewPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as! FolderDetailViewController
            vc.capturedImage = image
            vc.isAdhoc = true
            vc.delegate = self
            vc.galleryPath = "Adhoc"
            storage_saveObject("ItemName", self.txtPhotoName.text!)
            storage_saveObject("Description", self.txtPhotoDescription.text!)
            if let projectName = storage_loadObject("ProjectName") {
                storage_saveObject("AlbumName", projectName)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TakeNewPhotoViewController : TakenPhotoDelegate {
    func didUpdateTakenPhoto() {
        self.navigationController?.popDissolve()
    }
}
