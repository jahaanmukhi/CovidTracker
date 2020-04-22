//
//  LocationSearchTableViewController.swift
//  Nash
//
//  Created by Joseph Nagy on 4/13/20.
//  Copyright © 2020 nash. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {
    
    var mapView : MKMapView? = nil
    var handleMapSearchDelegate : HandleMapSearch? = nil
    var allPins: [Pin] = [] 
    
    // MARK: New Search Bar Variables
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPins: [Pin] = []
    var isSearchBarEmpty: Bool { return searchController.searchBar.text?.isEmpty ?? true }
    var isFiltering: Bool = false

    
    func filterContentForSearchText(_ searchText: String) {
        filteredPins = allPins.filter{$0.title!.lowercased().contains(searchText.lowercased())}
                
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ALL_PINS (TOTAL LEN): \(allPins.count)")
        
        // Format searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Territories"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension LocationSearchTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    self.isFiltering = true
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

extension LocationSearchTableViewController {
  override func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredPins.count
    }
      return allPins.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var pin: Pin
    if isFiltering {
      pin = filteredPins[indexPath.row]
    } else {
      pin = allPins[indexPath.row]
    }
    cell.textLabel?.text = pin.title
    let pinSubtitle = pin.subtitle!.components(separatedBy: "\n")
    cell.detailTextLabel?.text = pinSubtitle[0] + ", " + pinSubtitle[1]
    return cell
  }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredPins[indexPath.row]
        handleMapSearchDelegate?.dropPinZoomIn(pin: selectedItem)
        
        dismiss(animated: true, completion: nil)
    }
}
