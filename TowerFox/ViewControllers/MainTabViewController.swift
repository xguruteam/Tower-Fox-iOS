//
//  MainTabViewController.swift
//  CloseOut
//
//  Created by cgc on 9/4/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage_saveObject("SYNC", "")
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.appMainColor, size: tabBarItemSize).resizableImage(withCapInsets: UIEdgeInsets.zero)
        for i in 0..<(tabBar.items?.count)!{
            let tabItemIndex = tabBar.items![i]
            tabItemIndex.image = tabItemIndex.image!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        if isLocationEnabled() {
            LocationManager.sharedInstance.locationDelegate = self
        }else{
            LocationManager.sharedInstance.requestWhenInUseAuthorization()
        }
        LocationManager.sharedInstance.startUpdatingLocation()
        // remove default border

        // Do any additional setup after loading the view.
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
}

extension MainTabViewController: LocationManagerProtocol {
    func didUpdateLocation() {
//        print(LocationManager.sharedInstance.currentLocation as Any)
    }
}
