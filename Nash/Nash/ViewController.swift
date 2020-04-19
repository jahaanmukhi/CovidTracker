//
//  ViewController.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()

    struct Place: Codable {
        var combined_key: String! //name of place
        var confirmed_cases: Int!
        var country: String!
        var county: String! //think there is going to be problem with null values
        var daily_change_cases: Int!
        var daily_change_deaths: Float!
        var confirmed_deaths: Float!
        var fips: Float! //what is this?
        var latitude: Float!
        var longitude: Float!
        var population: Float!
        var state: String!
        var uid: Float!
        var state_abbr: String!
    }

    var allElms: [Place] = []
    let myLocation = APILocation()


    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        createAlert(title: "Daily Coronavirus Update", message: bodyofReturnNotification())
    }

    func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))

        self.present(alert, animated: true, completion: nil)
    }

        func bodyofReturnNotification() -> String{

         getAllData()
         sleep(3)
         var ret = "Total local cases: " + String(myLocation.iconfirmedcases)
         ret += "\nTotal local deaths: " + String(myLocation.ideaths)
         ret += "\nDaily change in local cases: " + String(myLocation.ichangeInCases)
         ret += "\nDaily change in local deaths: " + String(myLocation.ichangeInDeaths)
         //ret += "\nPercent change in local cases: " + String(Int((Float(myLocation.locationChangeInCases)/Float(myLocation.locationConfirmedCases)) * 100.0)) + "%"
         print(ret)
         return ret

     }


    func getAllData() {

            //totalCases = 0
            print("starting getAllData")
            let mySession = URLSession(configuration: URLSessionConfiguration.default)

            let url = URL(string: "https://nash-273721.df.r.appspot.com/map")!

            let task = mySession.dataTask(with: url) {data, response, error in

                guard error == nil else {
                    print ("error: \(error!)")
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

                   // get current location
                    let currLoc = self.locationManager.location
                    if (currLoc == nil) {
                        print("No location available")
                        return
                    }
                    print(currLoc)
                    //get city state country from lat and long

                    self.myLocation.fetchCityStateAndCountry(from: (currLoc ?? nil)!) { city, state, country, error in
                                        guard let city = city, let state = state, let country = country, error == nil else { return }
                                print("THIS IS IT " + city + ", " + state + ", ", country)
                        self.myLocation.icounty = city
                        self.myLocation.icountry = country
                        print("IVAR: " + String((self.myLocation.icounty ?? "")!))
                        print("IVAR: " + String((self.myLocation.istate ?? "")!))
                        print("IVAR: " + String((self.myLocation.icountry ?? "")!))

                        }
                        sleep(1)

                        print("IVARl: " + String((self.myLocation.icounty ?? "")!))
                        print("IVARl: " + String((self.myLocation.istate ?? "")!))
                        print("IVARl: " + String((self.myLocation.icountry ?? "")!))

                        //begin for loop
                        for Place in self.allElms{
                            //print("loop")
                            //print(Place.county)
                            //print(self.myLocation.icounty)
                            if (Place.county == self.myLocation.icounty && Place.state_abbr == self.myLocation.istate) {
            //&& Place.country == self.myLocation.icountry && Place.state == self.myLocation.istate
                                print("true")
                                self.myLocation.iconfirmedcases = Place.confirmed_cases
                                self.myLocation.ideaths = Place.confirmed_deaths
                                self.myLocation.ichangeInDeaths = Place.daily_change_deaths
                                self.myLocation.ichangeInCases = Place.daily_change_cases
                            }
                        }

                    print("done!!!")

                }catch {
                    print("JSON Decode error")
                }
            }

            task.resume()
            sleep(2)

        }
}




