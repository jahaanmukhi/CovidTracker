//
//  AppDelegate.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//SAM
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound])
//    } //added april 9
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler:
//        @escaping () -> Void) {
//
//        if response.notification.request.identifier == "tempIdentifier" {
//            print("handling notifications with the TestIdentifier Identifier")
//            completionHandler()
//        }
//    }

//SAM
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions
//        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        UNUserNotificationCenter.current().delegate = self
//        //request authorization for notifications
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
//            print("granted: (\(granted)")
//        }
//        return true
//    } //changed the inside of this function
    
//   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//          // Override point for customization after application launch.
//
//          // Google Analytics tool initialization
//          FirebaseApp.configure()
//
//          // MARK: UserNotifications Center Setup
//          let center = UNUserNotificationCenter.current()
//          center.delegate = self
//          let options: UNAuthorizationOptions = [.alert, .badge, .sound]
//          // request user authorization for notifications
//          center.requestAuthorization(options: options) { (granted, error) in
//              if granted {
//                  //application.registerForRemoteNotifications()
//                  print("Permission Granted")
//                  self.setUpNotification()
//              }
//          }
////    func application(_ application: UIApplication, didFinishLaunchingWithOptions
////        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
////        // Override point for customization after application launch.
////
////        let center = UNUserNotificationCenter.current()
////        center.delegate = self
////        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
////        center.requestAuthorization(options: options) { granted, error} in
////        if granted{
////            print(" Permission Granted")
////            self.setUpNotification()
////        }
////        return true
////    } //from slides
//
//    func setUpNotification() {
//
//        //setting content of notification
//            let dailyContent = UNMutableNotificationContent()
//            dailyContent.title = "Daily Update on Coronavirus Data"
//            dailyContent.body = "REPLACE HERE"
//            dailyContent.sound = UNNotificationSound.default
//
//        //specify date/time for trigger
//            var dailyDate = DateComponents()
//            //right now going for 8am every day
//            dailyDate.calendar = Calendar.current
//            dailyDate.hour = 8
//            dailyDate.minute = 0
//
//        //trigger notification when it matches dateCompotents
//            let dailyTrigger = UNCalendarNotificationTrigger(dateMatching: dailyDate, repeats: true)
//
//        let notificationCenter = UNUserNotificationCenter.current()
//
//        //creates the notification request and handles errors
//        let request = UNNotificationRequest(identifier: "dailyIdentifier", content: dailyContent, trigger: dailyTrigger)
//
//        //add request to main notification center
//        notificationCenter.add(request) { (error) in
//            if error != nil {
//                //handle errors
//            } else {
//                print("Notification Created")
//            }
//        }
//
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let actionIdentifier = response.actionIdentifier
//
//        switch actionIdentifier {
//        case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
//            // Do something
//            completionHandler()
//        case UNNotificationDefaultActionIdentifier: // App was opened from notification
//            // Do something
//            completionHandler()
//        case "remindLater": do {
//                let newDate = Date(timeInterval: 60, since: Date())
//                print("Rescheduling notification until \(newDate)")
//                // TODO: reschedule the notification
//
//            }
//            completionHandler()
//        default:
//            completionHandler()
//        }
//    } //me
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            // Google Analytics tool initialization
            //FirebaseApp.configure()
            
            // MARK: UserNotifications Center Setup
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            // request user authorization for notifications
            center.requestAuthorization(options: options) { (granted, error) in
                if granted {
                    //application.registerForRemoteNotifications()
                    print("Permission Granted")
                    self.setUpNotification()
                }
            }
            //give remind me later option
             let notificationAction = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        
             let myCategory = UNNotificationCategory(identifier: "myUniqueCategory", actions: [notificationAction], intentIdentifiers: [], options: [])

             UNUserNotificationCenter.current().setNotificationCategories([myCategory])

            
            return true
        }

        
        func setUpNotification() {
                
                //setting content of notification
                let content = UNMutableNotificationContent()
                content.title = "Daily Coronavirus Update"
                content.body = "REPLACE THIS"
                
                //specify date/time for trigger
                var dateComponents = DateComponents()
                dateComponents.calendar = Calendar.current
                dateComponents.weekday = 6  // sunday is 1
                dateComponents.hour = 10  //  hours
                dateComponents.minute = 11 // minutes
            
                //trigger notification when it matches dateCompotents
                let trigger = UNCalendarNotificationTrigger(
                         dateMatching: dateComponents, repeats: true)
   

            // add action to Notification
            let notificationAction = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
            let myCategory = UNNotificationCategory(identifier: "myUniqueCategory", actions: [notificationAction], intentIdentifiers: [], options: [])
    
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.setNotificationCategories([myCategory])

            // cutomise the content categoryIdentifier
            content.categoryIdentifier = "myUniqueCategory"

            // add sound to Notification
            content.sound = UNNotificationSound.default

            // Create the request
            let request = UNNotificationRequest(identifier: "myUniqueIdentifierString1234",
                        content: content, trigger: trigger)
            
            // Add the request to the main Notification center.
            
            notificationCenter.add(request) { (error) in
               if error != nil {
                  // Handle any errors.
               } else {
                    print("Notification created")
                }
            }
                
            }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            //print("func 1")
            let content = notification.request.content
            //print("got here")
            // Process notification content
            print("Received Notification with \(content.title) -  \(content.body)")

            completionHandler([])
            //completionHandler([.alert, .sound]) // Display notification as regular alert and play sound
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let actionIdentifier = response.actionIdentifier
            //print("func 2")
            switch actionIdentifier {
            case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
                // Do something
                completionHandler()
            case UNNotificationDefaultActionIdentifier: // App was opened from notification
                // Do something
                completionHandler()
            case "remindLater": do {
                    let newDate = Date(timeInterval: 60, since: Date())
                    print("Rescheduling notification until \(newDate)")
                    // TODO: reschedule the notification
                
                }
                completionHandler()
            default:
                completionHandler()
            }
        }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Nash")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}
