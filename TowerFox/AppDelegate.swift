//
//  AppDelegate.swift
//  CloseOut
//
//  Created by cgc on 8/23/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import UserNotificationsUI
import SQLite3
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var dismiss = false
    var progressVC: SyncProgressViewController!
    var isProgressViewShowing: Bool = false
    var hud: MBProgressHUD!
    var navigationController: UINavigationController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.appMainColor], for: UIControlState.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "ProximaNovaSoft-Regular", size: 14.0) as Any, NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        IQKeyboardManager.shared.enable = true
        if UserDefaults.standard.object(forKey: "TokenID") == nil {
            storage_saveObject("TokenID", "")
        }
        
        // Override point for customization after application launch.
        getNotificationSettings()
        AppData.copyFile(fileName: "Towerfox.db")
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        self.progressVC = storyboard.instantiateViewController(withIdentifier: "progressVC") as! SyncProgressViewController
        progressVC.modalTransitionStyle = .crossDissolve
        progressVC.modalPresentationStyle = .overCurrentContext
        if storage_loadObject("UserName") != nil {
            let vc = storyboard.instantiateViewController(withIdentifier: "testNav") as! UINavigationController
            self.navigationController = vc
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        // kDeviceToken=tokenString
        print("deviceToken: \(tokenString)")

    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
        completionHandler()
    }
    
    func registerPushNotifications() {
        let application = UIApplication.shared
        
        UNUserNotificationCenter.current().delegate = self
        let notificationCenter = UNUserNotificationCenter.current()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        notificationCenter.requestAuthorization(options: authOptions) {(granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
        application.registerForRemoteNotifications()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                self.registerPushNotifications()
            }
        }
    }
    
    func showProgressView(_ title: String, showValue: Bool) {
        self.progressVC.title = title
        self.progressVC.showValue = showValue
        self.dismiss = false
        appDel.isProgressViewShowing = true
        DispatchQueue.main.async {
            if !(self.window?.visibleViewController?.isKind(of: SyncProgressViewController.self))! {
                self.window?.visibleViewController?.present(self.progressVC, animated: true, completion: {
                })
            }
        }
    }
    
    func updateProgressView(_ title: String, progress: Int, total: Int) {
        if self.isProgressViewShowing {
            self.dismiss = false
            let data: [String: Any] = ["title": title, "total": total, "progress": progress]
            NotificationCenter.default.post(name: NSNotification.Name("UpdateProgress"), object: data)
        }else{
            self.showProgressView(title, showValue: false)
        }
    }
    func dismissProgressView()  {
        DispatchQueue.main.async {
            self.dismiss = true
            self.hideHUD()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeProgress"), object: nil)
        }
    }

    func showHUD(_ text: String, subtext: String)  {
        hud = MBProgressHUD.showAdded(to: self.navigationController.view, animated: true)
        hud.label.text = text
    }
    
    func hideHUD() {
        if hud != nil {
            self.hud.hide(animated: true)
        }
    }
}

