//
//  ViewController.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var currentLongitude: Double!
    var currentLatitude: Double!
    
    struct Covid: Codable {
        var combined_key: String! //name of place
        var confirmed_cases: Int!
        var country: String!
        var county: String! //think there is going to be problem with null values
        var daily_change_cases: Int!
        var daily_change_deaths: Int!
        var weekly_change_cases: Int!
        var weekly_change_deaths: Int!
        var confirmed_deaths: Int!
        var fips: Int! //what is this?
        var latitude: Float!
        var longitude: Float!
        var population: Int!
        var state: String!
        var uid: Int!
        var state_abbr: String!
    }
    
    @IBOutlet weak var appDescription: UILabel!
    
    final let url = URL(string:"https://nash-273721.df.r.appspot.com/map")
    var covidWorldWide: [Covid] = []

    //var allElms: [Place] = []
    var myLocation = APILocation()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDescription.adjustsFontSizeToFitWidth = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        OperationQueue.main.addOperation ({
            self.downloadJSON()
        })

    }
    
    var alert_msg: String = "Error: Try Again"
    
    @IBAction func dailyUpdate(_ sender: Any) {
        OperationQueue.main.addOperation ({
            self.setAlertData()
        })
        OperationQueue.main.addOperation ({
            let alert = UIAlertController(title: "Daily Update", message: self.alert_msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func downloadJSON(){
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            
            guard error == nil else {

                DispatchQueue.main.async {
                    // create the alert
                    let alert = UIAlertController(title: "Error", message: "Not Connected To Internet", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                    self.alert_msg = "Error: Not Connected To Internet"
                    
                    print ("error: \(error!)")
                }

                return
                
            }
            
            do{
                if data == nil {
                    print("No Data")
                    return
                }
                let decoder = JSONDecoder()
                let results = try decoder.decode([Covid].self, from: data!)
                self.covidWorldWide = results
            } catch{
                print(error)
            }
        }.resume()
        
    }
    
    func setAlertData(){
        var alertPlace: Covid
        for place in self.covidWorldWide {
            if (self.myLocation.icountry == "United States") {
                if (place.county != nil && place.county == self.myLocation.icounty &&
                        place.state_abbr != nil && place.state_abbr == self.myLocation.istate
                        && place.country == "US" ) {
                    print("IDENTIFIED: County in US")
                    alertPlace = place

                    alert_msg =  "\nCurrent Location:\n" + String(alertPlace.combined_key) + "\n\nTotal Population: " + String(alertPlace.population)
                    alert_msg += "\n\nConfirmed Cases: " + String(alertPlace.confirmed_cases) +
                                "\nConfirmed Deaths: " + String(alertPlace.confirmed_deaths)
                    alert_msg += "\n\nDaily Change in Cases: " + String(alertPlace.daily_change_cases) +
                                 "\nDaily Change in Deaths: " + String(alertPlace.daily_change_deaths)
                    alert_msg += "\n\nWeekly Change in Cases: " + String(alertPlace.weekly_change_cases) +
                                 "\nWeekly Change in Deaths: " + String(alertPlace.weekly_change_deaths)
                }
            } else if (place.country != nil && place.country == self.myLocation.icountry) {
                if (place.state != nil && place.state_abbr == self.myLocation.istate){
                    print("IDENTIFIED: Province outside US")
                    alertPlace = place

                    alert_msg =  "\nCurrent Location:\n" + String(alertPlace.state_abbr) + ", " + String(alertPlace.country)
                    alert_msg += "\nConfirmed Cases: " + String(alertPlace.confirmed_cases) +
                                "\nConfirmed Deaths: " + String(alertPlace.confirmed_deaths)
                    alert_msg += "\n\nDaily Change in Cases: " + String(alertPlace.daily_change_cases) +
                                "\nDaily Change in Deaths: " + String(alertPlace.daily_change_deaths) +
                                "\n\nWeekly Change in Cases: " + String(alertPlace.weekly_change_cases) +
                                "\nWeekly Change in Deaths: " + String(alertPlace.weekly_change_deaths)
                } else if (place.state == nil) {
                    print("IDENTIFIED: Country")
                    alertPlace = place
                    alert_msg =  "\nCurrent Location:\n" + String(alertPlace.country) + "\n\nTotal Population: " + String(alertPlace.population)
                    alert_msg += "\n\nConfirmed Cases: " + String(alertPlace.confirmed_cases) +
                                 "\nConfirmed Deaths: " + String(alertPlace.confirmed_deaths)
                    alert_msg += "\n\nDaily Change in Cases: " + String(alertPlace.daily_change_cases) +
                                 "\nDaily Change in Deaths: " + String(alertPlace.daily_change_deaths)
                    alert_msg += "\n\nWeekly Change in Cases: " + String(alertPlace.weekly_change_cases) +
                                 "\nWeekly Change in Deaths: " + String(alertPlace.weekly_change_deaths)
                }
           
            }
        }
        print(
            "LOCATION: " + String(self.myLocation.icounty ?? "No County") +
            ", " + String(self.myLocation.istate  ?? "No State/Province") +
            ", " + String(self.myLocation.icountry ?? "No Country")
            )
        
        print("Alert Process Finished")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLoc = locations.last!
        setMyLocationData(currLoc: currLoc)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func setMyLocationData(currLoc:CLLocation) {
        self.myLocation.fetchCityStateAndCountry(from: (currLoc)) {
            city, state, country, error in
                guard let city = city, let state = state, let country = country, error == nil
                    else { return }
                self.myLocation.icounty = city
                self.myLocation.istate = state
                self.myLocation.icountry = country
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (manager.location != nil && (status == .authorizedAlways || status == .authorizedWhenInUse) ){
            let currLoc = manager.location!
            setMyLocationData(currLoc: currLoc)
        } else {
            alert_msg = "Location services not enabled."
        }
    }
    
}
