//
//  Artwork.swift
//  Nash
//
//  Created by Jacob Andrew Derry on 4/4/20.
//  Copyright © 2020 nash. All rights reserved.
//

import Foundation
import MapKit

struct Results: Codable{
    let results: [Covid]
    
    init(results: [Covid]) {
        self.results = results
    }
}

struct Covid: Codable {
    let country: String
    let state: String
    let county: String?
    let latitude: Double
    let longitude: Double
    let confirmed_cases: Int
    let deaths: Int
    let population: Int

  init(
    country:String,
    state:String,
    county:String,
    latitude:Double,
    longitude:Double,
    confirmed_cases:Int,
    deaths:Int,
    population:Int
  ) {
    self.country = country
    self.state = state
    self.county = county
    self.latitude = latitude
    self.longitude = longitude
    self.confirmed_cases = confirmed_cases
    self.deaths = deaths
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
