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
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    //notifications and location setup
    let locationManager = CLLocationManager()
    let center = UNUserNotificationCenter.current()
    
    //setup geocoder
    static let geoCoder = CLGeocoder()
    
    
    

    //handling notifications
    //notification willPresent method
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound])
//    }
    
    //notification DIDRECIEVE method
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//    didReceive response: UNNotificationResponse,
//    withCompletionHandler completionHandler:
//        @escaping () -> Void) {
//
//        if response.notification.request.identifier == "tempIdentifier" {
//               print("handling notifications with the TestIdentifier Identifier")
//
//            let storyboard = UIStoryboard(name: "Notifications", bundle: nil)
//
//            if let notificationVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as? NotificationVC {
//
//                self.window?.rootViewController = notificationVC
//            }
//            completionHandler()
//        }
//
//    }
            
            
 
 //           let viewController = storyboard.instantiateViewController(withIdentifier :"NotificationVC") as! NotificationVC
//            let NotificationNavVC = UINavigationController.init(rootViewController: viewController)

//               if let window = self.window, let rootViewController = window.rootViewController {
//                   var currentController = rootViewController
//                   while let presentedController = currentController.presentedViewController {
//                       currentController = presentedController
//                    }
//                       currentController.present(NotificationNavVC, animated: true)
//
//                 completionHandler()
//               }
//
//
//
//        }
//
//    }
    
   
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        //request authorization for location
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        
        //request authorization for notifications
        center.requestAuthorization(options:[.alert, .badge, .sound]) { (granted, error) in
            print("granted: \(granted)")
            }
        
         
            return true
        }
    //handle location erros if access is denied
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       if let error = error as? CLError, error.code == .denied {
          // Location updates are not authorized.
    
          manager.stopUpdatingLocation()
          return
       }
       // Notify the user of any errors.
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

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
       let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)

        
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let description =  "\(place)"
                self.newVisitReceived(visit, description: description, place: place )
            }
        }
        
    }
    
    func newVisitReceived(_ visit: CLVisit, description: String, place: CLPlacemark) {
        let location = Location(visit: visit, descriptionString: description)
        let locality = place.locality
    
        let content = UNMutableNotificationContent()
        content.title = "Cases in " + locality!
        content.body = "Get data from API"
        content.sound = .default

        // 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)

        // 3
        center.add(request) { error in if error != nil {
            print ("something went wrong")
            }
            
        }
    
    
       
   }
}



