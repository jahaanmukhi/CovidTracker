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

    let allData: [Covid] = []
    
    func getAllData() {
           
           // 2. BEGIN NETWORKING code
           //
                   let mySession = URLSession(configuration: URLSessionConfiguration.default)

                   let url = URL(string: "https://nash-273721.df.r.appspot.com/map")!

           // 3. MAKE THE HTTPS REQUEST task
           //
                   let task = mySession.dataTask(with: url) { data, response, error in

                       // ensure there is no error for this HTTP response
                       guard error == nil else {
                           print ("error: \(error!)")
                           return
                       }

                       // ensure there is data returned from this HTTP response
                       guard let jsonData = data else {
                           print("No data")
                           return
                       }
                       
                       print("Got the data from network")
           // 4. DECODE THE RESULTING JSON
           //
                       let decoder = JSONDecoder()

                       do {
                           // decode the JSON into our array of todoItem's
                           let allData = try decoder.decode([Covid].self, from: jsonData)
                        
//                        for data in allData{
//                            print("Country is: \(data.country)")
//                        }
                           
                       } catch {
                           print("JSON Decode error")
                       }
                   }

               // actually make the http task run.
               task.resume()
           
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllData()
        
        for item in allData{
            print("Country (in for loop): \(item.country ?? "no country listed")")
        }
        
        // Set initial location
        let initialLocation = CLLocation(latitude: 39.86746056019632, longitude: -74.19296019422868)

        // Do any additional setup after loading the view.
        mapView.centerToLocation(initialLocation)
        
        //dummy data 
        let Case1: Covid = Covid(uid: 1, fips: 100.1, combined_key: "key", country: "USA", state: "NJ", county: "Ocean", latitude: 39.86746056019632, longitude: -74.19296019422868, confirmed_cases: 5, deaths: 10, daily_change_cases: 0, daily_change_deaths: 0, population: 0)
        
        let Case2: Covid = Covid(uid: 1, fips: 100.1, combined_key: "key", country: "Canada", state: "NJ", county: "Bergen", latitude: 39.868215, longitude: -74.192864, confirmed_cases: 100, deaths: 50, daily_change_cases: 0, daily_change_deaths: 0, population: 0)

        let cases: [Covid] = [Case1, Case2]
        
        //populate map with pins
        for c in cases{
            let description = "Cases: \(c.confirmed_cases ?? 0)) \n Deaths: \(c.deaths ?? 0)"
            let location = "\(c.county ?? "No COUNTY") County, \(c.state ?? "NO STATE")"
            let annotation = Pin(coordinate: CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude ), title: location, subtitle: description)
            mapView.addAnnotation(annotation)
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

}
