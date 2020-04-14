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

    final let url = URL(string:"https://nash-273721.df.r.appspot.com/map")
    
    var covid = [Covid]()
    
    var resultSearchController: UISearchController? = nil
    
    var selectedPin : MKPlacemark? = nil
    
    
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
            
            //populate map with pins
            for c in covid{
                let description = "Cases: \(c.confirmed_cases ?? 0) \n Deaths: \(c.confirmed_deaths ?? 0)"
                let location = "\(c.county ?? "No COUNTY") County, \(c.state ?? "NO STATE")"
                let annotation = Pin(coordinate: CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude ), title: location, subtitle: description)
                mapView.addAnnotation(annotation)
            }
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
        
        
        
        
        // Set initial location
        let initialLocation = CLLocation(latitude: 39.86746056019632, longitude: -74.19296019422868)

        // Do any additional setup after loading the view.
        mapView.centerToLocation(initialLocation)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
