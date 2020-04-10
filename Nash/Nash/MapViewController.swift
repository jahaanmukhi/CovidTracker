//
//  MapViewController.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: CoronavirusMapView!
    let locationManagerVC = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userTrackingMode = .follow
        
        //setup to collect user location
        //let locationManagerVC = CLLocationManager()
        locationManagerVC.delegate = self
        
        // Set initial location in Honolulu
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)

        // Do any additional setup after loading the view.
        //mapView.centerToLocation(initialLocation)
        
//        let artwork = Emergency(
//          title: "King David Kalakaua",
//          locationName: "Waikiki Gateway Park",
//          coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
//        mapView.addAnnotation(artwork)
        
        
        //
        //
        //create two notifications: daily update and returning to the app
        
        //create components of daily notification
//        let content = UNMutableNotificationContent()
//        content.title = "Daily Update"
//        content.body = "Body"
//        content.sound = UNNotificationSound.default
//
//        var dateComponents = DateComponents()
//        dateComponents.hour = 9
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//        let request = UNNotificationRequest(identifier: "dailyIdentifier", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) {error in if error != nil {
//            print("something went wrong")
//            }
//        }
        
        //create components of notification when returninng to the app
//        let contentTemp = UNMutableNotificationContent()
//        contentTemp.title = "Here's what you missed..."
//        contentTemp.body = "Body"
//        contentTemp.sound = UNNotificationSound.default
//
//        let triggerTemp = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let requestTemp = UNNotificationRequest(identifier: "tempIdentifier", content: contentTemp, trigger: triggerTemp)
//
//        UNUserNotificationCenter.current().add(requestTemp) {error in if error != nil {
//            print("something went wrong")
//            }
//        }
        //done with notification creation
        
        
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
    
    //when user clicks button, alls map to collect their location
    @IBAction func onZoomToUserButton(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManagerVC.startUpdatingLocation()

        } else {
            locationManagerVC.requestAlwaysAuthorization()
        }
        
    }
  
  
    
    //zooms map around user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!

        let coordinateRegion = MKCoordinateRegion (center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

        mapView.setRegion(coordinateRegion, animated: true)

        //locationManagerVC.stopUpdatingLocation()
    }
    
    
}
