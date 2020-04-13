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
                let description = "Cases: \(c.confirmed_cases ?? 0)) \n Deaths: \(c.deaths ?? 0)"
                let location = "\(c.county ?? "No COUNTY") County, \(c.state ?? "NO STATE")"
                let annotation = Pin(coordinate: CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude ), title: location, subtitle: description)
                mapView.addAnnotation(annotation)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadJSON()
        
        
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
