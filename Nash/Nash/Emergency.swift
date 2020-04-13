//
//  Artwork.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import Foundation
import MapKit

class Results: Codable{
    let results: [Covid]
    
    init(results: [Covid]) {
        self.results = results
    }
}

class Covid: Codable {
    let uid: Int?
    let fips: Double?
    let combined_key: String?
    let country: String?
    let state: String?
    let county: String?
    let latitude: Double!
    let longitude: Double!
    let confirmed_cases: Int!
    let deaths: Int!
    let daily_change_cases: Int?
    let daily_change_deaths: Int?
    let population: Int?

  init(
    uid:Int?,
    fips:Double?,
    combined_key:String?,
    country:String?,
    state:String?,
    county:String?,
    latitude:Double!,
    longitude:Double!,
    confirmed_cases:Int?,
    deaths:Int?,
    daily_change_cases:Int?,
    daily_change_deaths:Int?,
    population:Int?
  ) {
    self.uid = uid
    self.fips = fips
    self.combined_key = combined_key
    self.country = country
    self.state = state
    self.county = county
    self.latitude = latitude
    self.longitude = longitude
    self.confirmed_cases = confirmed_cases
    self.deaths = deaths
    self.daily_change_cases = daily_change_cases
    self.daily_change_deaths = daily_change_deaths
    self.population = population
  }
}

class Pin: NSObject, MKAnnotation{
    let coordinate: CLLocationCoordinate2D
    let title:String?
    let subtitle:String?
    
    init(
        coordinate:CLLocationCoordinate2D,
        title:String?,
        subtitle:String?
    ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
