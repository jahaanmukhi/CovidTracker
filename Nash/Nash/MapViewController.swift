//
//  MapViewController.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: CoronavirusMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)

        // Do any additional setup after loading the view.
        mapView.centerToLocation(initialLocation)
        
        let artwork = Emergency(
          title: "King David Kalakaua",
          locationName: "Waikiki Gateway Park",
          coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
        mapView.addAnnotation(artwork)
        
    //create components of DAILY NOTIFICATION____________________
        
    //setting content of notification
        let dailyContent = UNMutableNotificationContent()
        dailyContent.title = "Daily Update on Coronavirus Data"
        dailyContent.body = "REPLACE HERE"
        dailyContent.sound = UNNotificationSound.default
    
    //specify date/time for trigger
        var dailyDate = DateComponents()
        //right now going for 8am every day
        dailyDate.calendar = Calendar.current
        dailyDate.hour = 8
        dailyDate.minute = 0
        
    //trigger notification when it matches dateCompotents
        let dailyTrigger = UNCalendarNotificationTrigger(dateMatching: dailyDate, repeats: true)
    
    //creates the notification request and handles errors
        let request = UNNotificationRequest(identifier: "dailyIdentifier", content: dailyContent, trigger: dailyTrigger)
        
        let notificationCenter = UNUserNotificationCenter.current().add(request) { (error) in if error != nil
            {
                //handle errors
                print("something went wrong")
        } else{
            print("notification scheduled")
            }
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    } //end of func viewDidLoad
} //end of class MapViewController
