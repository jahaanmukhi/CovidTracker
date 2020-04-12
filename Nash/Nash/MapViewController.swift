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
    var localilty: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userTrackingMode = .follow
        //setup to collect user location
        //let locationManagerVC = CLLocationManager()
        locationManagerVC.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManagerVC.delegate = self
            locationManagerVC.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManagerVC.startUpdatingLocation()
        }
        print("finish location manager")
                
        
        // Set initial location in Honolulu
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)

        // Do any additional setup after loading the view.
        //mapView.centerToLocation(initialLocation)
        
//        let artwork = Emergency(
//          title: "King David Kalakaua",
//          locationName: "Waikiki Gateway Park",
//          coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
//        mapView.addAnnotation(artwork)

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
        
        //get users current location
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            //print(city + ", " + country)
        }
        
        //locationManagerVC.stopUpdatingLocation()
    }
    
    //get city and country from location coordinates
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
}
