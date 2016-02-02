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

class SearchLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [String]()
    var timer: NSTimer!
    var currentSearchText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // table view data source- number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // table view data source- cell at index
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultCell", forIndexPath: indexPath) as! ResultTableViewCell
        cell.resultText.text = searchResults[indexPath.row]
        return cell
    }
    
    // table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // table view delegate- cell selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("clicked" + String(indexPath))
    }
    
    // refresh table view
    func refresh(refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    
    // text field changed so search and update search results
    @IBAction func textFieldChanged(sender: AnyObject) {
        currentSearchText = searchBar.text!
        if let timer = timer {
            timer.invalidate()
        }
        if (currentSearchText.characters.count != 0) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "getAddressFromSearch", userInfo: nil, repeats: false)
        } else {
            searchResults.removeAll()
            tableView.reloadData()
        }
    }
    
    func getAddressFromSearch() {
        print("executing forward search on " + currentSearchText)
        LocationUtils.forwardGeocoding(currentSearchText, completion: updateSearchResults)
    }
    
    func updateSearchResults(placemarks: [CLPlacemark]) {
        searchResults.removeAll()
        searchResults.append(LocationUtils.addressFromPlacemark(placemarks))
        tableView.reloadData()
    }
    
    // cancel searching and return to map
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}