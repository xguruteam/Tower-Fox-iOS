//
//  RegistrationManager.swift
//  Wagg
//
//  Created by admin on 1/8/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import Alamofire
import Reachability

struct UserAuth {
    static var userId: String? {
        get {
            if let userId = UserDefaults.standard.value(forKey: "UserID") as? String {
                return userId
            }
            
            return nil
        }
    }
    
    static var isFirstTime: Bool? {
        get {
            if let userId = UserDefaults.standard.value(forKey: "isFirstTime") as? Bool {
                return userId
            }
            
            return true
        }
    }
    
    static func setUserId(_ id: String) {
        UserDefaults.standard.set(id, forKey: "UserID")
        UserDefaults.standard.synchronize()
    }
    
    static func setIsFirstTime(_ isFirstTime: Bool) {
        UserDefaults.standard.set(isFirstTime, forKey: "isFirstTime")
        UserDefaults.standard.synchronize()
    }
    
    static func deleteIsFirstTime(_ isFirstTime: Bool) {
        if let _ = UserDefaults.standard.value(forKey: "isFirstTime") as? String {
            UserDefaults.standard.removeObject(forKey: "isFirstTime")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    static func deleteUserId() {
        if let _ = UserDefaults.standard.value(forKey: "UserID") as? String {
            UserDefaults.standard.removeObject(forKey: "UserID")
        }
        UserDefaults.standard.synchronize()
    }
}

class AppManager: NSObject {
    static let shareInstance = AppManager()
    
    let reachabaility = Reachability()
    
    override init() {
        super.init()
//
//        reachabaility.whenReachable = { reachabaility in
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NetworkConnected"), object: nil)
//        }
//
//        reachabaility.whenUnreachable = { reachabaility in
//            print("Not Reachable")
//        }
        
        do {
            try reachabaility.startNotifier()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
//    func sendPushNotification(_ to: String, body: String, toId: String) {
//
//        AppManager.shareInstance.loadNotificationsWith(toId) { (notifications) in
//            var messages = ["to": to, "priority" : "high"] as [String : Any]
//            let notification = ["body": body, "title": "New message", "sound": "default", "badge": "\(notifications.count)"]
//            messages["notification"] = notification
//            
//            let header = [
//                "Content-Type": "application/json",
//                "Authorization": "key=AIzaSyBSzMrrkas5sSCgnctRQTT--fO7djEYMVA"
//            ]
//            
//            Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: messages, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
//                switch response.result {
//                case .success(let data):
//                    print(data)
//                    break
//                    
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    break
//                }
//            }
//        }
//    }
    
//    func loadNotifications() {
//        if AppManager.shareInstance.reachabaility?.connection == .none {
//            return
//        }
//
//        let reference = Database.database().reference()
//        reference.child(NotificationMedel.keyPath).observe(.value) { (snapshot) in
//
//            guard let notificationData = snapshot.value as? [String: Any?] else {
//                return
//            }
//
//            var allNotifications = [NotificationMedel]()
//
//            for (key, value) in notificationData {
//                if let value = value as? [String: Any?], let _ = value[NotificationMedel.keyFrom] as? String {
//                    let notification = NotificationMedel(value)
//                    notification.id = key
//                    allNotifications.append(notification)
//                }
//            }
//
//            let notifications = allNotifications.filter({ (notification) -> Bool in
//                return (notification.toId == UserModel.currentUser.userId) && !notification.isRead
//            })
//
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationChanged"), object: ["notification": notifications])
//            }
//        }
//    }
    
//    func loadNotificationsWith(_ userId: String, completionHandler: @escaping ([NotificationMedel]) -> ()) {
//
//        let reference = Database.database().reference()
//        reference.child(NotificationMedel.keyPath).observeSingleEvent(of: .value) { (snapshot) in
//
//            guard let notificationData = snapshot.value as? [String: Any?] else {
//                completionHandler([NotificationMedel]())
//                return
//            }
//
//            var allNotifications = [NotificationMedel]()
//
//            for (key, value) in notificationData {
//                if let value = value as? [String: Any?], let _ = value[NotificationMedel.keyFrom] as? String {
//                    let notification = NotificationMedel(value)
//                    notification.id = key
//                    allNotifications.append(notification)
//                }
//            }
//
//            let notifications = allNotifications.filter({ (notification) -> Bool in
//                return (notification.toId == userId) && !notification.isRead
//            })
//
//           completionHandler(notifications)
//        }
//    }
//
//    func userOffline() {
//        guard let userId = UserModel.currentUser.userId else {
//            return
//        }
//
//        let reference = Database.database().reference()
//        reference.child(ChatInstanceModel.keyPath).observeSingleEvent(of: .value, with: { (snapshot) in
//
//            guard let eventData = snapshot.value as? [String: Any?] else {
//                return
//            }
//
//            var allDialogs = [ChatInstanceModel]()
//            for (key, value) in eventData {
//                let dialog = ChatInstanceModel(value as! [String: Any])
//                dialog.id = key
//                dialog.getLastMessage()
//
//                if ((dialog.createrId == userId) || (dialog.partificientId == userId)) && dialog.status != .deleted {
//                    allDialogs.append(dialog)
//                }
//            }
//
//            for dialog in allDialogs {
//                dialog.updateStatus(InstanceStatus.offline)
//            }
//        })
//    }
}
