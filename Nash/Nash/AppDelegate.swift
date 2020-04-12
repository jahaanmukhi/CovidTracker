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
    
    //global variables
    static let geoCoder = CLGeocoder()
    let locationManager = CLLocationManager()
    let center = UNUserNotificationCenter.current()
    
    //MARK: api struct
    struct Place: Codable {
    var combined_key: String //name of place
    var confirmed_cases: Int
    var country: String
    //var county: String //think there is going to be problem with null values
    var daily_change_cases: Int
    var daily_change_deaths: Int
    var deaths: Int
    //var fips: Float //what is this?
    var latitude: Float
    var longitude: Float
    var population: Int
    var state: String
    var uid: Int
    }
    
    //hard coded location
    let country = "US"
    let state = "Alabama"
    
    //var totalCases = 0

    var allElms: [Place] = []
    
   // let currLoc = CLLocationManager.location


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
       // getAllData()
        //MARK: set up location tracking
        //notifications and location setup
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        
        //handle location errors if access is denied
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           if let error = error as? CLError, error.code == .denied {
              // Location updates are not authorized.
        
              manager.stopUpdatingLocation()
              return
           }
           // Notify the user of any errors.
        }
        
        //MARK: set up notifications
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        //request authorization for notifications
        center.requestAuthorization(options:options) { (granted, error) in if granted {
            print ("Notification permission allowed")
            self.setUpNotification()
            }
        }
        
        let notificationAction = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        
        let myCategory = UNNotificationCategory(identifier: "myUniqueCategory", actions: [notificationAction], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([myCategory])
        
        return true
    }
    
    func setUpNotification() {
         //setting content of notification
        let content = UNMutableNotificationContent()
        content.title = "Cases in this area..."
        content.body = bodyofReturnNotification()
        //hardcoded and need to replace with api call to request current location
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "myUniqueCategory"
        
        //trigger notification when it matches dateCompotents
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // add action to Notification
        let notificationAction = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let myCategory = UNNotificationCategory(identifier: "myUniqueIdentifier", actions: [notificationAction], intentIdentifiers: [], options: [])
        
        let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.setNotificationCategories([myCategory])
        
        // Add the request to the main Notification center.
        let request = UNNotificationRequest(identifier: "returnIdentifer",
                               content: content, trigger: trigger)

            
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            } else {
                print("Notification created")
            }
        }
    }

    func bodyofReturnNotification() -> String {
        
        var totalCases = 0
        getAllData()
        let currLoc = self.locationManager.location
        
        fetchCityStateAndCountry(from: (currLoc ?? nil)!) { city, state, country, error in
                    guard let city = city, let state = state, let country = country, error == nil else { return }
            print("THIS IS IT " + city + ", " + state + ", ", country)
            
            for Place in self.allElms{
                
                if (Place.country == country) {
                    //need to fix county codes
                    totalCases += Place.confirmed_cases
                }
                //print(Place.confirmed_cases)
                //print(Place.country)
                //print(Place.county)

            }
        }
        
        

//        var ret = "Total global cases: " + totalCasesString
//        ret += "\nTotal local cases: " + casesString
//        ret += "\nTotal local deaths: " + deathsString
//        ret += "\nDaily change in local cases: " + changeCasesString
//        ret += "\nDaily change in local deaths: " + changeDeathsString
//        ret += "\nPercent change in local cases: " + String(Int((Float(myLocation.locationChangeInCases)/Float(myLocation.locationConfirmedCases)) * 100.0)) + "%"
       // print(ret)
       // return ret
        return ""

        
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        let currLoc = locations.last!
//
//        fetchCityAndCountry(from: currLoc) { city, country, error in
//            guard let city = city, let country = country, error == nil else { return }
//            //print(city + ", " + country)
//
//            //self.bodyofReturnNotification(city : city, country : country)
//        }
//
//
//
//    }
//
    func fetchCityStateAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ state: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.administrativeArea,
                       placemarks?.first?.country,
                       error)
        }
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
    
    //MARK: API Call
    
    func getAllData() {
        //totalCases = 0
        print("starting getAllData")
        let mySession = URLSession(configuration: URLSessionConfiguration.default)
        
        let url = URL(string: "https://nash-273721.df.r.appspot.com/map")!
        
        let task = mySession.dataTask(with: url) {data, response, error in
            
            guard error == nil else {
                print ("error: \(error!)")
//                let alertController = UIAlertController(title: "Error", message: "Request failed. Check internet connection.", preferredStyle: .alert)
//                let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//                alertController.addAction(dismissAction)
//                DispatchQueue.main.async {
//                    self.present(alertController, animated: true)
//                }
                return
            }
            
            guard let jsonData = data else {
                print("No data")
                return
            }
            
            print("Got the data from network")
            
            let decoder = JSONDecoder()

            do {
                self.allElms = try decoder.decode([Place].self, from: jsonData)

//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
                // for Place in self.allElms{
                    
                    
                    //print(Place.confirmed_cases)
                    //print(Place.country)
                    //print(Place.county)
                    
                    
                //}

                print("done!!!")

            }catch {
                print("JSON Decode error")
            }
        }
        
        task.resume()
        sleep(1)
        
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
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)

         //3
        center.add(request) { error in if error != nil {
            print ("something went wrong")
            }
            
        }
    
    
       
   }
}



