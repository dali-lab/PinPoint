//
//  SearchLocationViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/1/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import Mapbox //needed?

class SearchLocationViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UITextField!
    
    var searchResults = [CLPlacemark]()
    var timer: NSTimer!
    var currentSearchText: String!
    var delegate = searchResultDelegate!()
    
    let searchController = UISearchController(searchResultsController: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ResultCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // table view data source- number of rows
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // table view data source- cell at index; decode placemark and create the cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ResultTableViewCell
        let placemark = searchResults[indexPath.row]
        cell.placemark = placemark
        cell.resultText.text = LocationUtils.addressFromPlacemark(placemark)
        return cell
    }
    
    // table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // table view delegate- cell selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("clicked" + String(indexPath))
        if (self.delegate != nil) {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                self.delegate.searchResultSelected(cell)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // refresh table view
    func refresh(refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    // execute forward geocoding search when user stops typing
    func startTimerForSearch(searchText: String) {
        if let timer = timer { // stop old timer
            timer.invalidate()
        }
        if (searchText.characters.count != 0) { // set new timer
            currentSearchText = searchText
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "startSearch", userInfo: nil, repeats: false)
        } else { // no characters so clear table
            searchResults.removeAll()
            tableView.reloadData()
        }
    }
    
    // start the forward geocoding search
    func startSearch() {
        print("executing forward search on " + currentSearchText)
        LocationUtils.forwardGeocoding(currentSearchText, completion: updateSearchResults)
    }
    
    // update the view presented to the user
    func updateSearchResults(placemarks: [CLPlacemark]) {
        searchResults.removeAll()
        searchResults.appendContentsOf(placemarks)
        tableView.reloadData()
    }
    
    // cancel searching and return to map
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension SearchLocationViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        startTimerForSearch(searchController.searchBar.text!)
    }
}

// what does this do?
protocol searchResultDelegate {
    func searchResultSelected(sender: AnyObject)
}