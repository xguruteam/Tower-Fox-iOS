//
//  MainTabViewController.swift
//  CloseOut
//
//  Created by cgc on 9/4/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import Photos

class MainTabViewController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForground), name: .UIApplicationWillEnterForeground, object: nil)
        
        storage_saveObject("SYNC", "")
        applicationWillEnterForground()
        if isLocationEnabled() {
            LocationManager.sharedInstance.locationDelegate = self
        }else{
            LocationManager.sharedInstance.requestWhenInUseAuthorization()
        }
        LocationManager.sharedInstance.startUpdatingLocation()
        // remove default border

        // Do any additional setup after loading the view.
        if PHPhotoLibrary.authorizationStatus() == .authorized {
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.width = self.view.frame.width + 4
        tabBar.frame.origin.x = -2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func applicationWillEnterForground() {
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.appMainColor, size: tabBarItemSize).resizableImage(withCapInsets: UIEdgeInsets.zero)
        for i in 0..<(tabBar.items?.count)!{
            let tabItemIndex = tabBar.items![i]
            tabItemIndex.image = tabItemIndex.image!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
    }
}

extension MainTabViewController: LocationManagerProtocol {
    func didUpdateLocation() {
//        print(LocationManager.sharedInstance.currentLocation as Any)
    }
}
