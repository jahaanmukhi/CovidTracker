//
//  Cases.swift
//  Nash
//
//  Created by Jahaan M on 11/04/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit

class Results: Codable{
    let results: [Case]
    
    init(results: [Case]) {
        self.results = results
    }
}

class Case: Codable{
    let country: String
    let county: String
    let confirmed_cases: Int
    let deaths: Int
    let latitude: Int
    let longitude: Int
    
    init(county: String, country:String, confirmed_cases:Int, deaths:Int, latitude:Int, longitude:Int) {
        self.county = county
        self.country = country
        self.confirmed_cases = confirmed_cases
        self.deaths = deaths
        self.latitude = latitude
        self.longitude = longitude
    }
}

