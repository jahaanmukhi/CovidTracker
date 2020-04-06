//
//  ViewController.swift
//  Nash
//
//  Created by Alejandro Meza on 3/25/20.
//  Copyright © 2020 Nash. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    let location = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.location.requestWhenInUseAuthorization()
        
        addAnnotations(locations: annotations)
        map.showAnnotations(map.annotations, animated: true)
        
        map.showsUserLocation = true

        if CLLocationManager.locationServicesEnabled() {
            location.delegate = self
            location.desiredAccuracy = kCLLocationAccuracyBest
            location.startUpdatingLocation()
        }
        map.delegate = self
        
    }
    
    let annotations = [["title": "Earthquake", "subtitle": "11 injured", "latitude":37.2044, "longitude":-122.1712],
                       ["title": "Coronavirus Update", "subtitle": "222 confirmed cases", "latitude":37.8044, "longitude":-122.2712],
                       ["title": "Hurricane", "subtitle": "10 injured",
                        "latitude":38.5044, "longitude":-121.2712]]
    
    func addAnnotations(locations: [[String: Any]]) {
        for loc in locations{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: loc["latitude"] as! CLLocationDegrees, longitude: loc["longitude"] as! CLLocationDegrees)
            annotation.title = loc["title"] as? String
            annotation.subtitle = loc["title"] as? String
            self.map.addAnnotation(annotation)
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        // Set initial zoom level
        let span = MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.2)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }


}

