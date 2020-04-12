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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // not using Google Analytics tool
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
        } //end func didFinishLaunchingWithOptions - CHANGED THIS FOR DAILY NOTIFICATION

        
        func setUpNotification() {
                
                //setting content of notification
                let content = UNMutableNotificationContent()
                content.title = "Daily Coronavirus Update"
                content.body = bodyofDailyNotification()
                
                //specify date/time for trigger - everyday 8am
                var dateComponents = DateComponents()
                dateComponents.calendar = Calendar.current
                //dateComponents.weekday = 6  // sunday is 1
                dateComponents.hour = 12  //  hours
                dateComponents.minute = 39 // minutes
            
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
                
        } // end of func setUpNotification - CHANGED FOR DAILY UPDATE
    
    func bodyofDailyNotification() -> String {
        return "REPLACE"
    }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            //print("func 1")
            let content = notification.request.content
            //print("got here")
            // Process notification content
            print("Received Notification with \(content.title) -  \(content.body)")

            // Display notification as regular alert and play sound
            completionHandler([.alert, .sound])
        } //end func userNotificationCenter - CHANGED FOR DAILY UPDATE
        
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
        }//end func userNotificationCenter #2 - CHANGED FOR DAILY UPDATE
    

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
