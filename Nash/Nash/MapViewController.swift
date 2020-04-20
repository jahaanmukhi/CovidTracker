//
//  MapViewController.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
    @IBOutlet weak var mapView: CoronavirusMapView!
    var locationManagerVC = CLLocationManager()
    var localilty: String = ""
        
    @IBAction func profileButton(_ sender: Any) {
        performSegue(withIdentifier: "MaptoProfile", sender: self)
    }
    
    final let url = URL(string:"https://nash-273721.df.r.appspot.com/map")
    
    var covid = [Covid]()
    
    var resultSearchController: UISearchController? = nil
    
    var selectedPin : MKPlacemark? = nil
    
    func getString(c:Covid) -> String {
        var locationString = ""
        if (c.county != nil) {
            locationString += c.county! + " County, "
        }
        let countryNil = (c.country == nil || c.country == "US") // treat the US as nil because we don't want to display it
        if (c.state != nil) {
            var ending = ", "
            if (countryNil) {
                ending = " "
            }
            locationString += c.state! + ending
        }
        if (!countryNil) {
            locationString += c.country!
        }
        return locationString
    }
    
    func downloadJSON(){
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do{
                if data == nil {
                    print("Connect to Internet")
                }else{
                let decoder = JSONDecoder()
                let results = try decoder.decode([Covid].self, from: data!)
                self.covid = results
                print("loaded")
                }
            }
            catch{
                print(error)
            }
        
            OperationQueue.main.addOperation ({
                 self.addPins()
            })
        }.resume()
    }
    
    func addPins(){
               // Set initial location
               let initialLocation = CLLocation(latitude: 37.733795, longitude: -122.446747)

               // Do any additional setup after loading the view.
               mapView.centerToLocation(initialLocation)
        
            
            
            //populate map with pins
            for c in covid {
                let description = "Cases: \(c.confirmed_cases ?? 0) \n Deaths: \(c.confirmed_deaths ?? 0)"
                let location = getString(c:c)
                let cases = Float(c.confirmed_cases ?? 0)
                var percentage = (cases/1000.0)*100.0 + 10
                if percentage > 100 {
                    percentage = 100
                }
                let color = UIColor.yellow.toColor(UIColor.red, percentage: CGFloat(percentage))
                let annotation = Pin(coordinate: CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude ), title: location, subtitle: description, color:color)
                mapView.addAnnotation(annotation)
            }
    }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }

        let custom = annotation as! Pin
        var annotationView = MKMarkerAnnotationView()
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        
        annotationView.canShowCallout = true
        annotationView.markerTintColor = custom.color!

        return annotationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadJSON()
        
        //set up search results table
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "LocationSearch") as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self 
        
        //configure search bar and embed within navigation bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = resultSearchController?.searchBar
       
        //format search bar and results
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        mapView.userTrackingMode = .follow
        //setup to collect user location
        //let locationManagerVC = CLLocationManager()
        locationManagerVC.delegate = self
        self.mapView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManagerVC.delegate = self
            locationManagerVC.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManagerVC.startUpdatingLocation()
        }
        print("finish location manager")
        
        
        // Set initial location
        let initialLocation = CLLocation(latitude: 37.733795, longitude: -122.446747)

        // Do any additional setup after loading the view.
        mapView.centerToLocation(initialLocation)
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
        
        locationManagerVC.stopUpdatingLocation()
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

protocol HandleMapSearch{
    func dropPinZoomIn(placemark: MKPlacemark)
}

extension MapViewController : HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
    // cache the pin
    selectedPin = placemark
    // clear existing pins
    //mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea
        {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = percentage / 100
        if percentage == 1{
            return color
        }
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                       green: CGFloat(g1 + (g2 - g1) * percentage),
                       blue: CGFloat(b1 + (b2 - b1) * percentage),
                       alpha: CGFloat(a1 + (a2 - a1) * percentage))
}
}
